source("configurations/lookup.R")

use_virtualenv("py_backend")

source_python("api_clients/aa_chat.py")
source_python("api_clients/aa_client.py")
source_python("api_clients/aa_qna.py")
source_python("api_clients/aa_semantic_search_inmemo.py")
source_python("api_clients/aa_summarization.py")
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
    
    # processing of PDF file
    path = getwd()
    pdf_file = glue("{path}/www/0.pdf")
    txt = pdf_text(pdf_file)
    maxpage = length(txt)
    document = txt[input$selectedPage]
    
    if (input$selectedPage <= 0) {
      return("YIKES !!! SYSTEM ERROR MESSAGE - NO LLM REQUEST HAS BEEN EXECUTED BECAUSE: Negative page input. Do me a favour please enter something within the range of the document. Thank you!")
    } else if (input$selectedPage > maxpage)
    {
      return("YIKES !!! SYSTEM ERROR MESSAGE - NO LLM REQUEST HAS BEEN EXECUTED BECAUSE: Out of page range input. Do me a favour please enter something within the range of the document. Thank you!")
    } else if (length(token) == 0)
    {
      return("YIKES !!! SYSTEM ERROR MESSAGE - NO LLM REQUEST HAS BEEN EXECUTED BECAUSE: No token has been entered. Thank you!")
    } else if (count_tokens(document)  > 2000 ) 
    {
      return("YIKES !!! SYSTEM ERROR MESSAGE - NO LLM REQUEST HAS BEEN EXECUTED BECAUSE: Likely too much text for this light-weight demo application. The max. tokens that can be processed must be under 2.000. Thank you!")
    } else 
    {
      summary = summary(token, document)
      return(summary)
    }
  })
    
  output$summary <- renderText({ 
     rawoutput2()
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
    
    input_cost = count_tokens(query)/1000 * model_price["luminous-extended-control",1] * task_factor["complete",1] 
    + count_tokens(nlg)/1000 * model_price["luminous-extended-control",1] * task_factor["complete",2]
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
    estimatedtokenb = 0
    estimatedtokena = count_tokens(rawoutput())
  })|>
    bindEvent(input$button10)
  
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

    filename = "report.pdf",
    
    content = function(file) {

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
    }
  )
  
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
        token = count_tokens(txt[x])
        tupel = as.integer(c(x, token))
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
