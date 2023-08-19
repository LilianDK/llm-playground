source("configurations/lookup.R")
source_python("api_clients/aa_client.py")
source_python("api_clients/aa_summarization.py")
#py_run_file(glue("api_clients/aa_client.py"))

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
  })
  
  output$text_prompt3 <- renderText({ 
    rawoutput()
  })|>
    bindEvent(input$button1)
  
  # Communication with aleph alpha compute center for summary job---------------
  rawoutput2 <- eventReactive(input$button2,{
    
    token = input$text_token
    print(input$selectedPage)
    path = getwd()
    pdf_file = glue("{path}/www/0.pdf")
    txt = pdf_text(pdf_file)
    document = txt[input$selectedPage]
    summary = summary(token, document)
    return(summary)
  })
  
  # Logging of the parameter settings for the prompt report
  parameterframe <- eventReactive(input$button,{ 
    first_column = c("Model","Max tokens","Best of","Temperature","Top k","Top p","Presency penalty","Frequency penalty")
    second_column = c(input$select_model,as.integer(input$num_maxtoken),as.integer(input$slider_bestof),input$slider_temperature,
                      as.integer(input$slider_topk),input$slider_topp,input$slider_presence,input$slider_frequency)
    df = data.frame("Parameter name" = first_column,
                    "Parameter setting" = second_column)
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
  
  output$downloader <- 
    downloadHandler(
      "results_from_shiny.pdf",
      content = 
        function(file)
        {
          rmarkdown::render(
            input = "output/report.Rmd",
            output_file = "built_report.pdf",
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
          ) 
          readBin(con = "output/built_report.pdf", 
                  what = "raw",
                  n = file.info("output/built_report.pdf")[, "size"]) %>%
            writeBin(con = file)
        }
    )
  
  # Descriptions ---------------------------------------------------------------
  output$descriptions <- renderUI({           
    includeMarkdown(knitr::knit('configurations/descriptions.md'))           
  })
  
  # PDF handling ---------------------------------------------------------------
  # Upload PDF and display
  
  observe({
    req(input$file_input)
    
    file.copy(input$file_input$datapath,"www", overwrite = T)
    filepath = input$file_input$datapath
    
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
    output$df = renderDT({  
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
      df
    })
    
    output$summary <- renderText({ 
      rawoutput2()
    })|>
      bindEvent(input$button2)
    
  })
}
