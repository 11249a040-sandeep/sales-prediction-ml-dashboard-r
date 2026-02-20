library(shiny)
library(randomForest)
library(bslib)

# Load trained ML model
model <- readRDS("output/model.rds")

ui <- fluidPage(
  
  theme = bs_theme(version = 5, bootswatch = "darkly"),
  
  tags$head(
    tags$style(HTML("
      body { background: linear-gradient(135deg, #1f4037, #99f2c8); }
      .card {
        background: rgba(255,255,255,0.1);
        backdrop-filter: blur(10px);
        border-radius: 15px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 8px 20px rgba(0,0,0,0.3);
      }
      .result-box {
        font-size: 28px;
        font-weight: bold;
        color: #00ffcc;
      }
    "))
  ),
  
  titlePanel("AI Sales Analytics Platform"),
  
  tabsetPanel(
    
    # ================= DASHBOARD TAB =================
    tabPanel("Dashboard",
             
      sidebarLayout(
        
        sidebarPanel(
          div(class="card",
              h4("Input Export Values"),
              
              sliderInput("beef", "Beef", 0, 5000, 1000),
              sliderInput("pork", "Pork", 0, 5000, 1000),
              sliderInput("poultry", "Poultry", 0, 5000, 1000),
              
              actionButton("reset", "Reset Values")
          )
        ),
        
        mainPanel(
          
          div(class="card",
              h3("Prediction Result"),
              div(class="result-box",
                  textOutput("prediction")
              )
          ),
          
          div(class="card",
              h4("Input Summary"),
              tableOutput("summary")
          ),
          
          div(class="card",
              h4("Visualization"),
              plotOutput("chart")
          )
        )
      )
    ),
    
    # ================= UPLOAD TAB =================
    tabPanel("Upload Data",
             
      fileInput("file", "Upload CSV"),
      
      h4("Uploaded Dataset"),
      tableOutput("filedata"),
      
      h4("Predictions"),
      tableOutput("uploadPrediction"),
      
      h4("Visualization"),
      plotOutput("uploadPlot")
    ),
    
    # ================= MODEL INFO TAB =================
    tabPanel("Model Info",
             h4("Machine Learning Model Details"),
             verbatimTextOutput("modelinfo")
    )
  )
)

server <- function(input, output, session) {

  # Reset sliders
  observeEvent(input$reset, {
    updateSliderInput(session, "beef", value = 1000)
    updateSliderInput(session, "pork", value = 1000)
    updateSliderInput(session, "poultry", value = 1000)
  })

  # Prediction for dashboard
  output$prediction <- renderText({
    pred <- predict(model,
                    data.frame(
                      beef = input$beef,
                      pork = input$pork,
                      poultry = input$poultry
                    ))
    paste("Predicted Exports:", round(pred, 2))
  })

  # Summary table
  output$summary <- renderTable({
    data.frame(
      Beef = input$beef,
      Pork = input$pork,
      Poultry = input$poultry
    )
  })

  # Chart for dashboard inputs
  output$chart <- renderPlot({
    values <- c(input$beef, input$pork, input$poultry)
    barplot(values,
            col=c("red","blue","green"),
            main="Export Values",
            names.arg=c("Beef","Pork","Poultry"))
  })

  # ---------- UPLOAD SECTION ----------

  uploadedData <- reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })

  output$filedata <- renderTable({
    uploadedData()
  })

  output$uploadPrediction <- renderTable({
    data <- uploadedData()
    
    if(all(c("beef","pork","poultry") %in% colnames(data))) {
      data$Predicted_Exports <- predict(model, data)
      data
    } else {
      data.frame(Message="CSV must contain columns: beef, pork, poultry")
    }
  })

  output$uploadPlot <- renderPlot({
    data <- uploadedData()
    
    if(all(c("beef","pork","poultry") %in% colnames(data))) {
      barplot(
        colMeans(data[,c("beef","pork","poultry")]),
        col=c("red","blue","green"),
        main="Average Export Values from Uploaded Data",
        names.arg=c("Beef","Pork","Poultry")
      )
    }
  })

  # Model info
  output$modelinfo <- renderPrint({
    model
  })
}

shinyApp(ui = ui, server = server)