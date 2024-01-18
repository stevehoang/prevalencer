library(shiny)
library(shinyjs)
library(dplyr)
library(magrittr)
library(viridis)
library(directlabels)


# load constants, settings, and utility functions
source("utils.R")


shinyServer(function(input, output) {
  
  # hide/show birth rate data based on selection
  shinyjs::hide("country")
  observeEvent(input$br, {
    shinyjs::toggleElement("country")
    shinyjs::toggleElement("total_pop")
    shinyjs::toggleElement("bpy")
  })
  
  # hide/show contour selector
  shinyjs::hide("bin_size")
  observeEvent(input$plot_type, {
    shinyjs::toggleElement("prev_bin_size")
    shinyjs::toggleElement("bin_size")
  })
  
  # make a reactive plot
  plotInput <- reactive({
    
    # get byp and population values based on ui
    if (input$br == "pc") { # pre-set data
      bpy_set <- bpy[[input$country]]
      pop_set <- pops[[input$country]]
      # plot caption
    }
    else { # custom data
      bpy_set <- as.numeric(input$bpy)
      pop_set <- input$total_pop
    }
    # incidence rate 
    ir <-  bpy_set / c(input$inc_range[2], input$inc_range[1]) 
    
    # calculate the grid of frequency/patient pop values
    grid_vals <- prevGrid(ir, input$life_range)
    
    # frequency plot vs patient population plot 
    if (input$plot_type == "prev_plot") {
      grid_vals$prev <- grid_vals$prev / pop_set
      fill_label <- "frequency"
      plot_title <- "Disease Prevalence (Frequency)"
      bin_size <- input$prev_bin_size
    } else {
      fill_label <- "patient pop."
      plot_title <- "Disease Prevalence (Patient Population Size)"
      bin_size <- input$bin_size
    }
    
    # plot caption
    pop_caption <- paste("total population size:", format(pop_set, 
                                                       big.mark = ","))
    br_caption <- paste("total births per year:", format(bpy_set, big.mark=","))
    inc_caption <- paste0("y-axis range is equivalent to ",
                          "1:", format(input$inc_range[2], big.mark=","),
                          " to 1:", format(input$inc_range[1], big.mark=","))
    capt_txt <- paste(pop_caption, br_caption, inc_caption, sep="\n")
    
    # make the plot
    p <- ggplot(grid_vals, aes(x = life, y = inc, z = prev)) +       
      geom_tile(aes(fill = prev)) +
      scale_fill_viridis() +
      scale_color_distiller(palette = "Spectral") +
      stat_contour(aes(color=..level..), linetype = "dashed", binwidth = bin_size) +
      labs(x = "median life expectancy (years)",
           y = "incidence (births per year)",
           fill = fill_label,
           title = plot_title,
           caption = capt_txt) +
      theme(plot.caption = element_text(size = rel(0.7)))
    
    # label the contours
    direct.label(p, "bottom.pieces")
  })
  
  # render plot
  output$prevPlot <- renderPlot({
    print(plotInput())
  }, height = 600, width = 900)
  
  # download handler
  output$dl <- downloadHandler(
    filename <- "prevalence.png",
    content <- function(file) {
      device <- function(..., width=9, height=6) {
        grDevices::png(..., width = 9, height = 6,
                       res = 300, units = "in")
      }
      ggsave(file, plot = plotInput(), device = device)
    })
  
})
