# this is the subpage for showcasing question and answering with LLMs
questionandanswering =     nav_panel(title = "Question and Answering", 
                                     fluidRow(
                                       column(width = 6,
                                              card(min_height = 100,
                                                   card_header("PDF:"),
                                                   uiOutput("pdfview2"),
                                                   fileInput("file_input2", "upload file ( . pdf format only)", accept = c(".pdf"))
                                              )
                                       ),
                                       column(width = 6,
                                              card(min_height = 100,
                                                   h5("Machine generated answer:"),
                                                   shinycssloaders::withSpinner(
                                                     textOutput("text_prompt11")
                                                   ),

                                                   card_header("Your question:"),
                                                   textAreaInput("text_prompt10", "", height = "50px", width = "2000px"),
                                                   numericInput("topn", "Input the top n chunks:","3"),
                                                   actionButton("button5", "Request Answer", icon("paper-plane"), style = config_button, width = "230px")
                                              )
                                       )
                                     ),
                                     fluidRow(
                                       card(
                                         h5("Top three chunks for the answer generation:"),
                                         DT::dataTableOutput("explain_score"),
                                       ),
                                       
                                       card(
                                         card_header("Estimated cost calcuations (EUR):"),
                                         fluidRow(
                                           column(width = 3,
                                                  h6("Est. cost to embedd the file:"), textOutput("embeddcost3")
                                           ),
                                           column(width = 3, 
                                                  h6("Est. cost to embedd the query:"), textOutput("embeddcost2")
                                           ),
                                           column(width = 3, 
                                                  h6("Est. cost to answer generation:"), textOutput("generatedcosts")
                                           )
                                         )
                                       )
                                     )
                                )