library(shiny)
library(ggplot2)
library(gridlayout)
library(bslib)


ui <- navbarPage(
  title = "Chick Weights",
  selected = "Line Plots",
  collapsible = TRUE,
  theme = bslib::bs_theme(),
  tabPanel(
    title = "Line Plots",
    grid_container(
      layout = c(
        "num_chicks area1"
      ),
      row_sizes = c(
        "1fr"
      ),
      col_sizes = c(
        "250px",
        "1fr"
      ),
      gap_size = "10px",
      grid_card(
        area = "num_chicks",
        card_header("Settings"),
        card_body_fill(
          sliderInput(
            inputId = "numChicks",
            label = "Number of chicks",
            min = 1,
            max = 15,
            value = 5,
            step = 1,
            width = "100%"
          )
        )
      ),
      grid_card(
        area = "area1",
        card_body_fill(
          grid_container(
            layout = c(
              "area1 area1",
              "area0 area0"
            ),
            row_sizes = c(
              "1fr",
              "1fr"
            ),
            col_sizes = c(
              "1fr",
              "1fr"
            ),
            gap_size = "10px",
            grid_card(
              area = "area0",
              card_body_fill(textOutput(outputId = "textOutput"))
            ),
            grid_card(
              area = "area1",
              card_body_fill(
                textInput(
                  inputId = "myTextInput",
                  label = "Text Input",
                  value = ""
                )
              )
            )
          )
        )
      )
    )
  ),
  tabPanel(
    title = "Distributions",
    grid_container(
      layout = c(
        "facetOption",
        "dists"
      ),
      row_sizes = c(
        "165px",
        "1fr"
      ),
      col_sizes = c(
        "1fr"
      ),
      gap_size = "10px",
      grid_card_plot(area = "dists"),
      grid_card(
        area = "facetOption",
        card_header("Distribution Plot Options"),
        card_body_fill(
          radioButtons(
            inputId = "distFacet",
            label = "Facet distribution by",
            choices = list("Diet Option" = "Diet", "Measure Time" = "Time")
          )
        )
      )
    )
  )
)


server <- function(input, output) {
   
  output$linePlots <- renderPlot({
    obs_to_include <- as.integer(ChickWeight$Chick) <= input$numChicks
    chicks <- ChickWeight[obs_to_include, ]
  
    ggplot(
      chicks,
      aes(
        x = Time,
        y = weight,
        group = Chick
      )
    ) +
      geom_line(alpha = 0.5) +
      ggtitle("Chick weights over time")
  })
  
  output$dists <- renderPlot({
    ggplot(
      ChickWeight,
      aes(x = weight)
    ) +
      facet_wrap(input$distFacet) +
      geom_density(fill = "#fa551b", color = "#ee6331") +
      ggtitle("Distribution of weights by diet")
  })
  
}

shinyApp(ui, server)
  

