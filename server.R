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
    shinyjs::toggleElement("caption")
  })
  
  # make a reactive plot
  plotInput <- reactive({
    
    if (input$br == "pc") { # incidence rate for a pre-set birth rate
      ir <-  bpy[[input$country]] / c(input$inc_range[2], input$inc_range[1])
    }
    else { # incidence rate for a custom birth rate
      ir <-  as.numeric(input$caption) / c(input$inc_range[2], input$inc_range[1])
    }
    
    # calculate the grid of prevalence values
    x <- prevGrid(ir, input$life_range)
    
    # plot caption
    capt_txt <- paste0("1:", input$inc_range[2], " to 1:", input$inc_range[1])
    capt_txt <- paste0("The y-axis is equivalent to a range of ", capt_txt, ".")
    
    # make the plot
    p <- ggplot(x, aes(x = life, y = inc, z = prev)) +       
      geom_tile(aes(fill = prev)) +
      scale_fill_viridis() +
      scale_color_distiller(palette = "Spectral") +
      stat_contour(aes(color=..level..), linetype = "dashed", binwidth = input$bin_size) +
      labs(x = "median life expectancy (years)",
           y = "incidence (births per year)",
           fill = "prevalence",
           title = "Prevalence as a function of incidence and life expectancy",
           caption = capt_txt) +
      theme(plot.caption = element_text(size = rel(0.7)))
    
    # label the contours
    direct.label(p, "bottom.pieces")
  })
  
  # render plot
  output$prevPlot <- renderPlot({
    print(plotInput())
  })
  
  # render birth rate in text below plot 
  x <- reactive({
    if (input$br == "pc") {
      paste("total births per year", cntry[[input$country]], 
            bpy[[input$country]])
    }
    else {
      paste("total births per year:", input$caption)
    }
  })
  output$value <- renderText({x()})
  
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
