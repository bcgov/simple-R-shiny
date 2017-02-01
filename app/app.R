library(shiny)
library(ggplot2)
library(plotly)
options(shiny.sanitize.errors = FALSE)
data <- read.csv(file.path("data", "iris.csv"))

ui <- fluidPage(
  tags$head(
    includeCSS(file.path("www", "main.css"))
  ),
  titlePanel("Test shiny app"),
  sidebarLayout(
    sidebarPanel(
      "You should see an image, a table, and a plot",
      br(), br(),
      img(src = "bcgov.jpg"),
      br(), br(),
      numericInput("size", "Size of points", 1, 1, 10),
      downloadButton("download", "Download data (csv)"),
      br(), br(),
      actionButton("write", "Write data to shiny server disk (csv)")
    ),
    mainPanel(
      plotlyOutput("plot"),
      tableOutput("table")
    )
  )
)

server <- function(input, output, session) {
  output$table <- renderTable(
    data
  )

  output$plot <- renderPlotly({
    p <- ggplot(data, aes(Sepal.Length, Sepal.Width)) +
      geom_point(size = input$size)

    ggplotly(p)
  })

  output$download <- downloadHandler(
    filename = function() {
      paste0("iris-", as.integer(Sys.time()), ".csv")
    },
    content = function(file) {
      write.csv(data, file, row.names = FALSE)
    }
  )

  observeEvent(input$write, {
    write.csv(data, "output/output.csv", row.names = FALSE)
  })
}

shinyApp(ui = ui, server = server)
