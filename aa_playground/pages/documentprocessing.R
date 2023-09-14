# this is the subpage for showcasing document processing with LLMs
################################################################################
# OUTPUT VARIABLES
# "pdfview3" for display of PDF upload
# "namedentityresults" for display extracted entities
# INPUT VARIABLES
# "file_input3" for uploading a PDF
# "namedentity1" for named entity recognition
# "namedentity2" for named entity recognition
# "namedentity3" for named entity recognition
# EVENT VARIABLES
# "button5" for uploading a PDF
documentprocessing =     nav_panel(title = "Document processing", 
                                     fluidRow(
                                       column(width = 6,
                                              card(min_height = 100,
                                                   card_header("PDF:"),
                                                   uiOutput("pdfview3"),
                                                   fileInput("file_input3", "upload file ( . pdf format only)", accept = c(".pdf"), multiple = TRUE)
                                              )
                                       ),
                                       column(width = 6,
                                              card(min_height = 100,
                                                   h5("Machine generated answer:"),
                                                   shinycssloaders::withSpinner(
                                                     DT::dataTableOutput("namedentityresults")
                                                   ),
                                                   card_header("Your requested variables:"),
                                                   textAreaInput("namedentity1", "", height = "50px", width = "300px"),
                                                   textAreaInput("namedentity2", "", height = "50px", width = "300px"),
                                                   textAreaInput("namedentity3", "", height = "50px", width = "300px"),
                                                   actionButton("button10", "Request Answer", icon("paper-plane"), style = config_button, width = "230px")
                                              )
                                       )
                                     ),
                                     fluidRow(
                                       card(
                                         card_header("Estimated cost calcuations (EUR):"),
                                         fluidRow(
                                           column(width = 3,
                                                  h6("Est. cost to process the file:"), textOutput("text_prompt22")
                                           ),
                                           column(width = 3, 
                                                  h6("Est. cost to answer generation:"), textOutput("text_prompt23")
                                           )
                                         )
                                       )
                                     )
)
