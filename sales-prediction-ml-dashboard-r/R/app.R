library(shiny)

# Load trained model
model <- readRDS("output/model.rds")

ui <- fluidPage(
  titlePanel("📊 Sales Prediction Dashboard"),

  sidebarLayout(
    sidebarPanel(
      sliderInput("beef", "Beef Exports", 0, 5000, 1000),
      sliderInput("pork", "Pork Exports", 0, 5000, 1000),
      sliderInput("poultry", "Poultry Exports", 0, 5000, 1000)
    ),

    mainPanel(
      h3("Predicted Total Exports"),
      textOutput("prediction")
    )
  )
)

server <- function(input, output) {

  output$prediction <- renderText({
    pred <- predict(model,
                    data.frame(
                      beef = input$beef,
                      pork = input$pork,
                      poultry = input$poultry
                    ))

    paste("Predicted Sales:", round(pred, 2))
  })
}

shinyApp(ui = ui, server = server)