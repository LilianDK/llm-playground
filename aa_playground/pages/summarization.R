# this is the subpage for showcasing summarization with LLMs
summarization =     nav_panel(title = "Summarization", 
                              fluidRow(
                                column(width = 6,
                                       card(min_height = 100,
                                            card_header("PDF:"),
                                            uiOutput("pdfview"),
                                            fileInput("file_input", "upload file ( . pdf format only)", accept = c(".pdf")),
                                            fileInput("file_input9", "upload file ( . wav, mp3, mp4 format only)", accept = c(".wav",".mp3",".mp4"))
                                       )
                                ),
                                column(width = 6,
                                       card(min_height = 500,
                                            card_header("Calculation:"),
                                            h6("Estimated total tokens:"),
                                            textOutput("sumtoken"),
                                            h6("Estimated total embedding costs in EUR:"),
                                            textOutput("embeddcost"),
                                            DT::dataTableOutput("df"),
                                            numericInput("selectedPage", "Select the page:","1"),
                                            actionButton("button2", "Summarize PDF", icon("paper-plane"), style = config_button, width = "230px"),
                                            actionButton("button22", "Summarize Audio", icon("paper-plane"), style = config_button, width = "230px")
                                       )
                                ),

                                card(min_height = 100,
                                  card_header("Machine generated summary from PDF:"),
                                      shinycssloaders::withSpinner(
                                        textOutput("summary")
                                      ),
                                    ),
                                card(
                                  h6("Est. cost to answer generation in EUR:"),
                                  textOutput("generatedcosts44")
                                ),
                                card(
                                  card_header("Machine generated summary from Audio:"),
                                      shinycssloaders::withSpinner(
                                        textOutput("summary2")
                                      )
                                ),
                                card(
                                  h6("Est. cost to answer generation in EUR:"),
                                  textOutput("generatedcosts45")
                                ),
                                card(min_height = 100,
                                     card_header("Transcription from audio:"),
                                     fluidRow(
                                         shinycssloaders::withSpinner(
                                           textOutput("transcription")
                                         ),
                                       ))
                              )
)