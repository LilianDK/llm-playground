source("library.R")
source("www/style.R")

source("pages/aaplaygrounddupe.R")
source("pages/parameterexplanation.R")
source("pages/summarization.R")
source("pages/questionandanswering.R")
source("pages/documentprocessing.R")

ui <- page_sidebar(

  tags$head(includeCSS("www/styles.css")),
  theme = bs_theme(version = 5, preset = "bootstrap", primary = config_primary ),

  title = "Aleph Alpha Playground Dupe",
  
  navset_tab(
    # Main panel for prompt engineering ----------------------------------------
    aa_playgrounddupe,
    
    # Main panel for parameter explanation -------------------------------------
    parameterexplanation,

    # Main panel for summarization ---------------------------------------------
    summarization,
    
    # Main panel for Question and Answering ------------------------------------
    questionandanswering,
    
    # Main panel for document processing ---------------------------------------
    documentprocessing
    ),
  
  # Sidebar layout with input definitions --------------------------------------
  sidebar = sidebar(width = 500, title = "Settings:", 
                    bg = config_primary, 
                    fg = config_sidebar_text_color, 
      # Input: Authorization selection -----------------------------------------
      accordion(id = 'id1',accordion_panel("Credentials", 
                                           textInput("text_userid", "User ID input:", value = "Enter user ID..."),
                                           passwordInput("text_token", "Token:"))),
      tags$a(href="https://app.aleph-alpha.com/", "Aleph Alpha Playground (Original)"),
      # Input: Model selection -------------------------------------------------
      hr(),
      selectInput("select_model", "Model:",
                  list(`First generation models` = list("luminous-base", "luminous-extended","luminous-supreme"),
                       `Instruction models` = list("luminous-base-control", "luminous-extended-control","luminous-supreme-control"))
      ),
      h6("Multilingual model trained on English, German, French, Spanisch, and Italian."),
      hr(),
      
      # Input: Parameter selection ---------------------------------------------
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

