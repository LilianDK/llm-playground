source("configurations/lookup.R")

use_virtualenv("py_backend")

source_python("api_clients/aa_chat.py")
source_python("api_clients/aa_client.py")
source_python("api_clients/aa_qna.py")
source_python("api_clients/aa_semantic_search_inmemo.py")
source_python("api_clients/aa_summarization.py")
source_python("api_clients/aa_keywords.py")
source_python("api_clients/aa_embedding.py")
source_python("api_clients/aa_entityextraction.py")

options(shiny.maxRequestSize=30*1024^2)

server <- function(input, output,session) {

  options(scipen=999)
  pagenumbers = 0
  
  # Communication with aleph alpha compute center for completion job------------

    rawoutput <- eventReactive(input$button1,{
      token = input$text_token
      prompt = input$text_prompt 
      model = input$select_model
      stop_sequences = "###"
      maximum_tokens = as.integer(input$num_maxtoken) 
      
        if (input$switch1 == TRUE) {
          
          # Chat
          token = input$text_token
          request = input$text_prompt 
          
          text = chat(token, request)
          return(text)

        } else {
          
          if (maximum_tokens <= 0) {
            return("YIKES !!! SYSTEM ERROR MESSAGE - NO LLM REQUEST HAS BEEN EXECUTED BECAUSE: Negative or zero value at maximum token input. Do me a favour please enter something larger then 0. Thank you!")
          } else if (count_tokens(prompt)  > 2000 ) 
          {
            return("YIKES !!! SYSTEM ERROR MESSAGE - NO LLM REQUEST HAS BEEN EXECUTED BECAUSE: Likely too much text for this light-weight demo application. The max. tokens that can be processed must be under 2.000. Thank you!")
          } else 
          {
          # Completion

          n = as.integer(input$slider_bestof)
          if (n == 1) { n = 2 } else {}
          best_of = as.integer(n)
          n = as.integer(1)
          temperature = input$slider_temperature
          top_k = as.integer(input$slider_topk)
          top_p = input$slider_topp
          presence_penalty = input$slider_presence
          frequency_penalty = input$slider_frequency 
          
          text = completion(token, prompt, model, stop_sequences, maximum_tokens, best_of, temperature, top_k, top_p, presence_penalty, frequency_penalty, n)
          return(text)
        }}
      
    })
    
    output$text_prompt3 <- renderText({ 
      rawoutput()
    })|>
      bindEvent(input$button1)

  # Communication with aleph alpha compute center for summary job---------------

  rawoutput2 <- eventReactive(input$button2,{
    
    token = input$text_token
    maximum_tokens = 100
    
    # processing of PDF file
    path = getwd()
    pdf_file = glue("{path}/www/0.pdf")
    txt = pdf_text(pdf_file)
    txt = trimws(gsub("[\r\n]", "", txt))
    txt = gsub("\\s+"," ",txt)

    df = data.frame(page="",
                    tokens=""
    )
    x = 1
    for (x in 1:length(txt)) {
      tokens = count_tokens(txt[x])
      tupel = as.integer(c(x, tokens))
      df = rbind(df, tupel)
    } 
    
    df = df[-1,]
    
    df$tokens <- as.integer(df$tokens)  
    sumtokeninput <- sum(df[, 'tokens'])
    
    if (input$select_chunking == "by paragraph") {
      
      # chunk with paragraph
      sumtable = data.frame(matrix(nrow = 0, ncol = 0)) 
      for (x in 1:nrow(as.data.frame(txt))) {
        newrows = as.data.frame(strsplit(txt, "\\n\\n")[[x]]) # chunk after each paragraph
        sumtable = rbind(sumtable, newrows)
      } 
      
      colnames(sumtable) <- c("Text_chunk")
      
      sumtable = sumtable[!(is.na(sumtable$Text_chunk) | sumtable$Text_chunk==""), ]
      sumtable = as.data.frame(sumtable)
      text_chunks = as.list(sumtable[,1])

    } else {
      
      # chunk with sentences
      df = data.frame(matrix(nrow = 0, ncol = 0)) 
      for (x in 1:nrow(as.data.frame(txt))) {
        newrows = as.data.frame(strsplit(txt, "\\n\\n")[[x]]) # chunk after each paragraph
        newrows['page'] <- x # add page number
        colnames(newrows) = colnames(df)
        df = rbind(df, newrows)
      } 
      
      colnames(df) <- c("Text_chunk","page")
      
      df = df[!(is.na(df$Text_chunk) | df$Text_chunk==""), ]
      text_chunks = as.list(df) 
    }
      
    # cluster text chunks
    vectors = embedding(token, text_chunks) 
    vectors
    vectors = matrix(unlist(vectors), ncol = 5120, byrow = TRUE)
    
    #fviz_nbclust(vectors, kmeans, method = "wss") +
    #  geom_vline(xintercept = "", linetype = 2)
    
    # execution of summarization procedure
    set.seed(123)
    groupsize = 10
    km.res <- kmeans(vectors, groupsize, nstart = 25)
    
    if (input$select_chunking == "by paragraph") {
      df2 <- cbind(sumtable, cluster = km.res$cluster)
    } else {
      df2 <- cbind(windowdf, tokendf, cluster = km.res$cluster) 
    }  
    
      summarydf = data.frame(matrix(nrow = 0, ncol = 0))
      for (x in 1:groupsize) {
        group = df2[df2$cluster == x,]
        group
        stringtosum = ""
        for (y in 1:nrow(group)) {
          stringtosum = paste(stringtosum, group[y,1], sep = " ", collapse = " ")
        } 
        tokensize = count_tokens(stringtosum)
        tokensize
        print(glue("------------------------------------------------------------Current group is: {x} with tokensize {tokensize}."))
        if (tokensize > 1500) {
        print(glue("------------------------------------------------------------Subroutine"))
          # Part 1
          part1 = 1
          stringtosum1 = ""
          for (x in 1:part1) {
            stringtosum1 = paste(stringtosum1, group[x,1], sep = " ", collapse = " ")
            tokensize = count_tokens(stringtosum1)
          } 
          document = stringtosum1
          tokensize1 = count_tokens(stringtosum1)
          summary1 = summary(token, document, as.integer(maximum_tokens))
          print(summary1)
          
          # Part 2
          part2 = round(nrow(group)/4)*2
          stringtosum2 = ""
          for (x in part1+1:part2) {
            stringtosum2 = paste(stringtosum2, group[x,1], sep = " ", collapse = " ")
            tokensize = count_tokens(stringtosum2)
          } 
          document = stringtosum2
          summary2 = summary(token, document, as.integer(maximum_tokens))
          print(summary2)
          
          # Part 3
          part3 = round(nrow(group)/4)*3+1
          stringtosum3 = ""
          for (x in part2+1:part3) {
            stringtosum3 = paste(stringtosum3, group[x,1], sep = " ", collapse = " ")
            tokensize = count_tokens(stringtosum3)
          } 
          document = stringtosum3
          summary3 = summary(token, document, as.integer(maximum_tokens))
          print(summary3)
          
          # Part 4
          part4 = nrow(group)
          stringtosum4 = ""
          for (x in part3+1:nrow(group)) {
            stringtosum4 = paste(stringtosum4, group[x,1], sep = " ", collapse = " ")
            tokensize = count_tokens(stringtosum4)
          } 
          document = stringtosum4
          summary4 = summary(token, document, as.integer(maximum_tokens))
          print(summary4)
          
          # All
          document = paste(summary1, summary2, summary3, summary4, sep = " ", collapse = " ")
          summary = summary(token, document, as.integer(maximum_tokens))
          print(summary)
          summarydf = rbind(summarydf, summary)
        } else {
        print(glue("------------------------------------------------------------Routine"))
          document = stringtosum
          summary = summary(token, document, as.integer(maximum_tokens))
          print(summary)
          summarydf = rbind(summarydf, summary)
        }
        print(glue("------------------------------------------------------------Next"))
        colnames(summarydf) = c("Summaries")
      }
      
      for (x in 1:nrow(summarydf)) {
        stringtosum = paste(stringtosum, summarydf[x,1], sep = " ", collapse = " ")
        document = stringtosum
        
        maximum_tokens = 214
        summary = summary(token, document, as.integer(maximum_tokens))

        sumtokeninput = sumtokeninput + count_tokens(document)
        sumtokenoutput = count_tokens(document) + count_tokens(summary)
        
      } 
      document = summary
      keywords = keywords(token, document)
      input_cost = sumtokeninput/1000 * model_price["luminous-supreme-control",1] * task_factor["complete",1] 
      + sumtokenoutput/1000 * model_price["luminous-supreme-control",1] * task_factor["complete",2]
      
      input_cost2 = count_tokens(summary)/1000 * model_price["luminous-extended",1] * task_factor["complete",1] 
      + count_tokens(keywords)/1000 * model_price["luminous-extended",1] * task_factor["complete",2]
      
      summary = paste("SUMMARY:", summary, "-----> TOTAL EST. COSTS:", input_cost, "(excl. 1 x embedding and 10 x prompt costs.)", "(Inputtokens:", sumtokeninput, ", Outputtokens:", sumtokenoutput,")",
                      "-----> KEYWORDS:", keywords, "(est. ",input_cost2, ")" )
      return(summary)
  })
    
  output$summary <- renderText({ 
    result = rawoutput2()
    result = result$val1
    result 
  })   

  rawoutput20 <- eventReactive(input$button22,{
    
    token = input$text_token
    req(input$file_input9)
    
    file.copy(input$file_input9$datapath,"www", overwrite = T)
    filepath = input$file_input9$datapath
    
    # processing of non-PDF file
    df = data.frame(matrix(nrow = 0, ncol = 4)) 
      
    # transcripe audio file
    av_audio_convert(filepath, output = "www/output.wav", format = "wav", sample_rate = 16000)
    transcript = predict(whispermodel, "www/output.wav")
      
    # data preparation
    col1 = as.data.frame(transcript$data$segment)
    col2 = as.data.frame(transcript$data$from)
    col3 = as.data.frame(transcript$data$to)
    col4 = as.data.frame(transcript$data$text)
      
    df = cbind(col1,col2,col3,col4)
    df = df[!duplicated(df[,4]),]
      
    vector = data.frame(matrix(nrow = 0, ncol = 1)) 
    for (x in 1:nrow(df)) {
      tokens = count_tokens(df[x,4])
      tokens
      vector = rbind(vector, tokens)
    } 
    df = cbind(df, vector)
    colnames(df) = c("segment","from","to","text","tokens")
      
    string = ""
    for (x in 1:nrow(df)) {
      string = glue("{string}{df[x,4]}")
    }
      
    if (sum(df[,5]) <= 2048) {
      document = as.character(string)
      summary = summary(token, document)
      summary
    } else {
      summary = "File too large."
      summary
    }
      
    return(list(
      val1 = string,
      val2 = summary
    ))
  })
    
  output$transcription <- renderText({ 
    result = rawoutput20()
    result = result$val1
  })
  
  output$summary2 <- renderText({ 
    result = rawoutput20()
    result = result$val2
  })|>
    bindEvent(input$button22)
  
  output$generatedcosts45 <- renderText({  
    result = rawoutput20()
    input_cost = count_tokens(result)/1000 * model_price["luminous-supreme-control",1] * task_factor["complete",2]
  })|>
    bindEvent(input$button22)
  
  # Logging of the parameter settings for the prompt report
  parameterframe <- eventReactive(input$button1,{ 
    first_column = c("Model","Max tokens","Best of","Temperature","Top k","Top p","Presency penalty","Frequency penalty")
    second_column = c(input$select_model,as.integer(input$num_maxtoken),as.integer(input$slider_bestof),input$slider_temperature,
                      as.integer(input$slider_topk),input$slider_topp,input$slider_presence,input$slider_frequency)
    df = data.frame("Parameter name" = first_column,
                    "Parameter setting" = second_column)
  })
  
  # Communication with aleph alpha compute center for qna job-------------------
  rawoutput9 <- eventReactive(input$button5,{
    
    token = input$text_token
    query = input$text_prompt10 
    
    # Data pre-processing step: Parsing PDF input to input format for semantic search
    pdf_file = "www/0.pdf"
    txt = pdf_text(pdf_file)
    #document = txt[1]
    
    df = data.frame(matrix(nrow = 0, ncol = 0)) 
    for (x in 1:nrow(as.data.frame(txt))) {
      newrows = as.data.frame(strsplit(txt, "\\n\\n")[[x]]) # chunk after each paragraph
      newrows['page'] <- x # add page number
      colnames(newrows) = colnames(df)
      df = rbind(df, newrows)
    } 
    
    colnames(df) <- c("Text_chunk","page")
    
    df = df[!(is.na(df$Text_chunk) | df$Text_chunk==""), ]
    tokencount = ""
    for (x in 1:nrow(df)) {
      test = count_tokens(df[x,1])
      tokencount = append(tokencount, test)
      tokencount
    } 
    tokencount = as.data.frame(tokencount)
    tokencount = tokencount[-1,]
    tokencount = as.data.frame(tokencount)
    
    sumcount = c(as.integer(0), as.integer(0))
    for (x in 1:nrow(tokencount)) {
      test = as.integer(tokencount[x,1]) + as.integer(tokencount[x+1,1]) + as.integer(tokencount[x+2,1])
      sumcount = append(sumcount, test)
    } 
    sumcount = as.data.frame(sumcount)
    sumcount = sumcount[-nrow(sumcount),]
    sumcount = as.data.frame(sumcount)

    df = cbind(df,tokencount,sumcount)
    df2 = cbind(df,tokencount,sumcount)
    df = df[,c(1,2)]
    text_chunks = as.list(df)
    
    # Semantic search
    #query = "Wieviel Euro muss soll die Beklagte zahlen?"
    index = semanticsearch(token, as.character(text_chunks$Text_chunk), query, as.integer(n)) 

    df[,"similarityscore"] = as.data.frame(index)
    index = df %>% 
      slice_max(order_by = similarityscore, n = input$topn)
    index = index[!(index$similarityscore <= 0.49), ]
    
    if (length(index) == 0) {
      qna = "There is no valid answer from the text."
      input_cost = ""
    } else {
    # Data post-processing step: Transform LLM result to expected tabular output format
    string = ""
    for (x in 1:nrow(index)) {
      string = glue("{string}{index[x,1]}")
    }
    
    string = trimws(gsub("[\r\n]", "", string))
    
    qna = qna(token, string, query)
    
    nlg = trimws(qna[[4]])
    
    input_cost = count_tokens(query)/1000 * model_price["luminous-supreme-control",1] * task_factor["complete",1] 
    + count_tokens(nlg)/1000 * model_price["luminous-supreme-control",1] * task_factor["complete",2]
    }
    return(list(
      val1 = qna,
      val2 = index,
      val3 = string,
      val4 = input_cost
    ))
    
  })
  
  output$text_prompt11 <- renderText({ 
    result = rawoutput9()
    result = result$val1
    #localization = result[[3]]
    #score = result[[2]]
    nlg = trimws(result[[4]])
    return(nlg)
  })|>
    bindEvent(input$button5)
  
  output$explain_score <- DT::renderDataTable({ 
    result = rawoutput9()
    result = result$val2
    result
    
    DT::datatable(result,
                  options = list(
                    lengthMenu = list(c(5, 15), c('3', '5')),
                    pageLength = 3
                  ),
                  rownames = FALSE)
  })|>
    bindEvent(input$button5)
  
  # Count cost
  output$embeddcost2 <- renderText({ 
    result = input$text_prompt10
    x = count_tokens(result)
    
    input_cost = x/1000 * model_price["luminous-base",1] * task_factor["embed",1] 
  })|>
    bindEvent(input$button5)
  
  output$embeddcost3 <- renderText({ 
    pdf_file = "www/0.pdf"
    txt = pdf_text(pdf_file)
    df = data.frame(page="",
                    tokens=""
    )
    x = 1
    for (x in 1:length(txt)) {
      token = count_tokens(txt[x])
      tupel = as.integer(c(x, token))
      df = rbind(df, tupel)
    } 
    
    df = df[-1,]
    
    df$tokens = as.integer(df$tokens)  
    x = sum(df[, 'tokens'])
    
    input_cost = x/1000 * model_price["luminous-base",1] * task_factor["embed",1] 
  })|>
    bindEvent(input$button5)
  
  output$generatedcosts <- renderText({  
    result = rawoutput9()
    result = result$val4
    return(result)
  })|>
    bindEvent(input$button5)
  
  # Communication with aleph alpha compute center for documentprocessing job----
  rawoutput11 <- eventReactive(input$button10,{
    
    token = input$text_token
    path = getwd()
    pdf_file = glue("{path}/www/0.pdf")
    txt = pdf_text(pdf_file)
    document = txt[1]
    
    entityextraction = entityextraction(token, document, input$namedentity1, input$namedentity2, input$namedentity3)
    return(entityextraction)
  })
  
  output$namedentityresults <- renderDT({  
    result = rawoutput11()
    result1 = substr(result,0,regexpr("\n", result)-1)
    result2 = gsub(substr(result,0,nchar(result1)+1), '', result)
    result2 = substr(result2,0,regexpr("\n", result2)-2)
    result3 = substr(result,nchar(result1)+2+nchar(result2)+2,nchar(result))
    
    tbl = data.frame(matrix(nrow = 0, ncol = 4)) 
    colnames(tbl) = c("Document ID",trimws(gsub(":.*","",result1)),trimws(gsub(":.*","",gsub(substr(result,0,nchar(result1)+2), '', result))),trimws(gsub(":.*","",result3)))
    tbl[1,2]<-trimws(gsub(".*:","",result1))
    tbl[1,3]<-trimws(gsub(".*:","",result2))
    tbl[1,4]<-trimws(gsub(".*:","",result3))
    tbl
  }, 
  rownames=FALSE,
  options = list(dom = 't'))|>
    bindEvent(input$button10)
  
  output$text_prompt22 <- renderText({ 
    pdf_file = glue("www/0.pdf")
    txt = pdf_text(pdf_file)
    document = txt[1]
    input_cost = count_tokens(document)/1000 * model_price["luminous-base-control",1] * task_factor["complete",1] 
    + input$num_maxtoken/1000 * model_price["luminous-base-control",1] * task_factor["complete",2]
    input_cost
  })
  
  output$text_prompt23 <- renderText({ 
    result = rawoutput11()
    estimatedtoken = count_tokens(result)
    input_cost = count_tokens(result)/1000 * model_price["luminous-base-control",1] * task_factor["complete",2]
    input_cost
  })

  # Tokenizer to estimate tokens -----------------------------------------------
  output$text_prompt2 <- renderText({ 
    estimatedtokena = 0
    estimatedtokena = count_tokens(input$text_prompt)
  })
  
  output$text_prompt4 <- renderText({ 
    text = rawoutput()
    estimatedtokens = count_tokens(text)
    estimatedtokens
  })|>
    bindEvent(input$button1)
  
  # Cost calculation -----------------------------------------------------------
  output$text_prompt5 <- renderText({  
    input_cost = count_tokens(input$text_prompt)/1000 * model_price[input$select_model,1] * task_factor["complete",1] 
    + input$num_maxtoken/1000 * model_price[input$select_model,1] * task_factor["complete",2]
  })
  
  output$text_prompt6 <- renderText({  
    input_cost = count_tokens(input$text_prompt)/1000 * model_price[input$select_model,1] * task_factor["complete",1] 
    + count_tokens(rawoutput())/1000 * model_price[input$select_model,1] * task_factor["complete",2] 
  })
  
  # Output report---------------------------------------------------------------
  
  output$report <- downloadHandler(
    filename = function(){
      paste(sys.date(), "_prompt_report", ".zip", sep = "")
    },
      content = function(file) {
        
        temp_directory <- file.path(tempdir(), as.integer(sys.time()))
        dir.create(temp_directory)
        
        tempReport <- file.path(tempdir(), "report.Rmd")
        file.copy("report.Rmd", tempReport, overwrite = TRUE)
        
        params = list(input_prompt = input$text_prompt,
                      results = rawoutput(),
                      model = input$select_model,
                      max_tokens = as.integer(input$num_maxtoken),
                      best_of = as.integer(input$slider_bestof),
                      temperature = input$slider_temperature,
                      top_k = as.integer(input$slider_topk),
                      top_p = input$slider_topp,
                      presence = input$slider_presence,
                      frequency = input$slider_frequency,
                      parameterframe = parameterframe()
        )
        
        rmarkdown::render(tempReport, output_file = file,
                          params = params,
                          envir = new.env(parent = globalenv())
        )
      
      writeLines(input$text_prompt, glue("{temp_directory}/prompt.txt"))    
      
      zip::zip(
         zipfile = file,
         files = dir(temp_directory),
         root = temp_directory
      )
    })

  # Descriptions ---------------------------------------------------------------
  output$descriptions <- renderUI({           
    includeMarkdown(knitr::knit('configurations/descriptions.md'))           
  })
  
  # PDF handling ---------------------------------------------------------------
  
  # Upload PDF and display in summarization
  observe({
    req(input$file_input)
    
    file.copy(input$file_input$datapath,"www", overwrite = T)
    filepath = input$file_input$datapath
    print(input$file_input$datapath)
    
    # Count token
    output$sumtoken = renderText({  
      pdf_file = filepath
      txt = pdf_text(pdf_file)
      df = data.frame(page="",
                      tokens=""
      )
      x = 1
      for (x in 1:length(txt)) {
        tokens = count_tokens(txt[x])
        tupel = as.integer(c(x, tokens))
        df = rbind(df, tupel)
      } 
      
      df = df[-1,]
      
      df$tokens <- as.integer(df$tokens)  
      x <- sum(df[, 'tokens'])
      
    })

    # Count cost
    output$embeddcost <- renderText({  
      pdf_file = filepath
      txt = pdf_text(pdf_file)
      df = data.frame(page="",
                      tokens=""
      )
      x = 1
      for (x in 1:length(txt)) {
        token = count_tokens(txt[x])
        tupel = as.integer(c(x, token))
        df = rbind(df, tupel)
      } 
      
      df = df[-1,]
      
      df$tokens = as.integer(df$tokens)  
      x = sum(df[, 'tokens'])
      
      input_cost = x/1000 * model_price["luminous-base",1] * task_factor["embed",1] 
    })
    
    output$pdfview = renderUI({
      tags$iframe(style="height:800px; width:100%", src="0.pdf")
    })
    
    # Count token
    output$df = DT::renderDataTable({  
      pdf_file = filepath
      txt = pdf_text(pdf_file)
      df = data.frame(page="",
                      tokens=""
      )
      x = 1
      for (x in 1:length(txt)) {
        token = count_tokens(txt[x])
        tupel = as.integer(c(x, token))
        df = rbind(df, tupel)
      } 
      
      df = df[-1,c(1,2)]
      DT::datatable(df,
                    options = list(
                      lengthMenu = list(c(5, 15), c('3', '5')),
                      pageLength = 3
                    ),
                    rownames = FALSE)
    })
    
    output$summary <- renderText({ 
      rawoutput2()
    })|>
      bindEvent(input$button2)
  })
  
  # Upload PDF and display in qna
  observe({
    req(input$file_input2)
    
    file.copy(input$file_input2$datapath,"www", overwrite = T)
    filepath = input$file_input2$datapath
    print(input$file_input2$datapath)
    
    output$pdfview2 = renderUI({
      tags$iframe(style="height:800px; width:100%", src="0.pdf")
    })
    
  })
  
  # Upload PDF and display in document processing
  observe({
    req(input$file_input3)
    print(input$file_input3$datapath)
    file.copy(input$file_input3$datapath,"www", overwrite = T)
    filepath = input$file_input3$datapath
    
    # Count token
    output$sumtoken5 = renderText({  
      pdf_file = filepath
      txt = pdf_text(pdf_file)
      df = data.frame(page="",
                      tokens=""
      )
      x = 1
      for (x in 1:length(txt)) {
        token = count_tokens(txt[x])
        tupel = as.integer(c(x, token))
        df = rbind(df, tupel)
      } 
      
      df = df[-1,]
      
      df$tokens <- as.integer(df$tokens)  
      x <- sum(df[, 'tokens'])
      
    })
    
    output$pdfview3 = renderUI({
      tags$iframe(style="height:800px; width:100%", src="0.pdf")
    })
    
    # Count token
    output$df5 = DT::renderDataTable({  
      pdf_file = filepath
      txt = pdf_text(pdf_file)
      df = data.frame(page="",
                      tokens=""
      )
      x = 1
      for (x in 1:length(txt)) {
        token = count_tokens(txt[x])
        tupel = as.integer(c(x, token))
        df = rbind(df, tupel)
      } 
      
      df = df[-1,c(1,2)]
      DT::datatable(df,
                    options = list(
                    lengthMenu = list(c(5, 15), c('3', '5')),
                    pageLength = 3
                    ),
                    rownames = FALSE)
    })
    
  })
  
  observe({
    req(input$file_input3)
    
  output$pdfview3 = renderUI({
    tags$iframe(style="height:800px; width:100%", src="0.pdf")
  })
  })
  
  # DAU

  
}
