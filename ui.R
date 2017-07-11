
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
options(scipen = 99999)
library(shiny)
library(shinyjs)
library(ggplot2)

shinyUI(fluidPage(
  useShinyjs(),

  # Application title
  titlePanel("Prevalence calculator"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      radioButtons("br", "value for calculation:",
                   c("pre-calculated" = "pc",
                     "custom" = "cust")),
      radioButtons("country", "country birth rate (pre-calculated):",
                   c("US (4M BPY)" = "us",
                     "EU (5.1M BPY)" = "eu",
                     "Japan (1M BPY)" = "jp",
                     "Saudi Arabia (600K BPY)" = "ksa")),
      textInput("caption", "total births per year (custom)", "1000000"),
      sliderInput("inc_range",
                  "incidence range (1:X):",
                  min = 1000,
                  max = 1000000,
                  value = c(100000, 200000),
                  step = 1000),
      sliderInput("life_range",
                  "median life expectancy range:",
                  min = 1,
                  max = 80,
                  value = c(20, 40)),
      
      sliderInput("bin_size",
                  "contour step size:",
                  min = 5,
                  max = 1000,
                  value = 100),
      actionButton("goButton", "submit"),
      downloadButton("dl", "download plot")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("prevPlot"),
      verbatimTextOutput("value")
    )
  )
))
