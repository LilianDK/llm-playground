#tinytex::install_tinytex()
source("library.R")

# See above for the definitions of ui and server
ui <- source("ui.R")

server <- source("server.R")

shinyApp(ui = ui, server = server)