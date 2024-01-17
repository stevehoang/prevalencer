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
      radioButtons("country", "country:",
                   c("US (population: 332M total, 4M BPY)" = "us",
                     "EU (population: 448M total, 5.1M BPY)" = "eu",
                     "Japan (population: 126M total, 1M BPY)" = "jp")),
      
      # custom population input
      textInput("total_pop", "total population size (custom)", "100000000"),
      textInput("bpy", "total births per year (custom)", "1000000"),
      
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
      
      numericInput("bin_size",
                   "contour step size:",
                   value = 100,
                   step = 100,
                   min = 10, max = 10000),
      
      # step size for plot contours (prevalence)
      numericInput("prev_bin_size",
                   "contour step size:",
                   value = 1e-6,
                   step = 1e-6,
                   min = 0, max = 1),
      
      # select prevalence plot or total population plot
      radioButtons("plot_type", "plot type:",
                   c("patient population" = "pop_plot",
                     "prevalence" = "prev_plot")),
      
      # download button
      downloadButton("dl", "download plot")
    ),

    # Show a plot of the function
    mainPanel(
      plotOutput("prevPlot"),
    )
  )
))
