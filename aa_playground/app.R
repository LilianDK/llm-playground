# tell shiny to log all reactivity

reactlog_enable()

ui <- source("ui.R")

server <- source("server.R")

shinyApp(ui = ui, server = server)

shiny::reactlogShow()
