# this is the subpage for showcasing summarization with LLMs
summarization =     nav_panel(title = "Summarization", 
                              fluidRow(
                                column(width = 8,
                                       card(min_height = 100,
                                            card_header("PDF:"),
                                            uiOutput("pdfview"),
                                            fileInput("file_input", "upload file ( . pdf format only)", accept = c(".pdf"))
                                       )
                                ),
                                column(width = 4,
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
                                    shinycssloaders::withSpinner(
                                      textOutput("summary")
                                    ),
                                  ),
                                  
                                )
                              )
)