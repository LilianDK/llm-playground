# this is the subpage for the aleph alpha playground dupe
aa_playgrounddupe =     nav_panel(title = "Playground", 
                               
                               card(min_height = 100,
                                    materialSwitch(inputId = "switch1", label = "Chatmode on", status = "warning"),
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
                               ))