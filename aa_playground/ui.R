source("library.R")
source("www/style.R")

ui <- page_sidebar(

  tags$head(includeCSS("www/styles.css")),
  theme = bs_theme(version = 5, preset = "bootstrap", primary = config_primary ),

  title = "Aleph Alpha Playground Dupe",
  
  navset_tab(
    # Main panel for prompt engineering ----------------------------------------
    nav_panel(title = "Playground", 
              
              card(min_height = 100,
                   card_header("Write your Prompt:"),
                   textAreaInput("text_prompt", "", height = "300px", width = "2000px"),
                   column(width = 7,
                   actionButton("button1", "Submit", icon("paper-plane"), style = config_button, width = "230px")
                   ),
                   column(width = 7,
                     downloadButton("report", "Download Prompt Report", style = config_button)
                   )
              ),
              
              card(
                card_header("Cost estimator:"),
                fluidRow(
                  column(width = 3,
                         h6("Estimated input tokens:"), textOutput("text_prompt2")
                  ),
                  column(width = 3, 
                         h6("Estimated output tokens:"), textOutput("text_prompt4")
                  ),
                  column(width = 3,
                         h6("Theoretical cost in EUR:"), textOutput("text_prompt5")
                  ),
                  column(width = 3, 
                         h6("Estimated cost in EUR:"), textOutput("text_prompt6")
                  )
                ),
                fluidRow(
                  h6("Tokens are calculated with Tiktokens.")
                )
              ),

              card(min_height = 100,
                   card_header("Completion:"),
                   textOutput("text_prompt3")
              )),
    
    nav_panel(title = "Parameter Explanation", 
              htmlOutput("descriptions"),
              ),
    
    # Main panel for summarization ---------------------------------------------
    nav_panel(title = "PDF", 
              fluidRow(
                column(width = 6,
                       card(min_height = 100,
                            card_header("PDF:"),
                            uiOutput("pdfview"),
                            fileInput("file_input", "upload file ( . pdf format only)", accept = c(".pdf"))
                       )
                ),
                column(width = 6,
                       card(min_height = 100,
                            card_header("Calculation:"),
                            h6("Estimated total tokens:"),
                            textOutput("sumtoken"),
                            h6("Estimated total embedding costs in EUR:"),
                            textOutput("embeddcost"),
                            DT::dataTableOutput("df"),
                            numericInput("selectedPage", "Select the page:","1"),
                            actionButton("button2", "Summarize", icon("paper-plane"), style = config_button, width = "230px")
                       )
                ),
                
                card(
                  fluidRow(
                    textOutput("summary")
                             ),
                  
                )
              )
    )),
  
  # Sidebar layout with input definitions --------------------------------------
  sidebar = sidebar(width = 500, title = "Settings:", 
                    bg = config_primary, 
                    fg = config_sidebar_text_color, 
      # Input: Authorization selection -----------------------------------------
      accordion(id = 'id1',accordion_panel("Credentials", 
                                           textInput("text_userid", "User ID input:", value = "Enter user ID..."),
                                           passwordInput("text_token", "Token:"))),
      tags$a(href="https://app.aleph-alpha.com/", "Aleph Alpha Playground (Original)"),
      # Input: Model selection ---------------------------
      hr(),
      selectInput("select_model", "Model:",
                  list(`First generation models` = list("luminous-base", "luminous-extended","luminous-supreme"),
                       `Instruction models` = list("luminous-base-control", "luminous-extended-control","luminous-supreme-control"))
      ),
      h6("Multilingual model trained on English, German, French, Spanisch, and Italian."),
      hr(),
      
      # Input: Parameter selection -----------------------
      numericInput("num_maxtoken", "Maximum Tokens:", 
                   "3"),
      h6("Stop Sequence is default triple hash: ###."),
      sliderInput("slider_bestof", "Best of:",
                  min = 1, max = 10, value = 1),
      hr(),
      sliderInput("slider_temperature", "Temperature:",
                  min = 0, max = 1, value = 0.00),
      sliderInput("slider_topk", "Top K:",
                  min = 0, max = 10, value = 0),
      sliderInput("slider_topp", "Top P:",
                  min = 0, max = 10, value = 0.0),
      hr(),
      sliderInput("slider_frequency", "Frequency Penalty:",
                  min = 0, max = 100, value = 0.0),
      sliderInput("slider_presence", "Presence Penalty Penalty:",
                  min = 0, max = 100, value = 0.0),
    ),

  absolutePanel(id = "logo", class = "card", bottom = 20, right = 100, width = "0", fixed=TRUE, draggable = TRUE, height = "auto",
               tags$a(href="", tags$img(src='shiny-solo.png',height="40",width="80"))),

)

