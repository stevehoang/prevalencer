options(scipen = 99999)
library(shiny)
library(shinyjs)
library(ggplot2)

shinyUI(fluidPage(
  useShinyjs(),

  # Application title
  titlePanel("Prevalence Calculator"),

  # Sidebar
  sidebarLayout(
    sidebarPanel(
      # select pre-set or custom birth rate data
      radioButtons("br", "birth rate data:",
                   c("pre-set" = "pc",
                     "custom" = "cust")),
      # select birth rate
      radioButtons("country", "country (births per year):",
                   c("US (4M BPY)" = "us",
                     "EU (5.1M BPY)" = "eu",
                     "Japan (1M BPY)" = "jp")),
      textInput("caption", "total births per year (custom)", "1000000"),
      
      # incidence slider
      sliderInput("inc_range",
                  "incidence range (1:X):",
                  min = 10000,
                  max = 1000000,
                  value = c(100000, 200000),
                  step = 1000),
      
      # life expectancy slider
      sliderInput("life_range",
                  "median life expectancy range:",
                  min = 1,
                  max = 80,
                  value = c(20, 40)),
      
      # step size for plot contours 
      sliderInput("bin_size",
                  "contour step size:",
                  min = 5,
                  max = 1000,
                  value = 100),
      downloadButton("dl", "download plot")
    ),

    # Show a plot of the function
    mainPanel(
      plotOutput("prevPlot"),
      verbatimTextOutput("value")
    )
  )
))
