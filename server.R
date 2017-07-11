
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyjs)
library(tidyverse)
library(magrittr)
library(viridis)
library(directlabels)

prev <- function(inc, life) {
  p <- inc / (1 - exp(-1 * log(2) / life))
  return(p)
}

prevGrid <- function(inc_range, life_range) {
  inc_step <- quantile(inc_range, probs = seq(0, 1, 0.01))
  life_step <- quantile(life_range, probs = seq(0, 1, 0.01))
  arg_grid <- expand.grid(inc_step, life_step)
  colnames(arg_grid) <- c("inc", "life")
  arg_grid %<>% mutate(prev = prev(inc, life))
  arg_grid %<>% mutate(prev2 = 1/prev)
  arg_grid %<>% mutate(inc2 = 1/inc)
  return(arg_grid)
}

theme_set(theme_minimal(base_size = 18) +
          theme(plot.title = element_text(size = rel(1)),
                # panel.border = element_rect(colour = "black", fill=NA, size=1),
                axis.text = element_text(size = rel(0.8)),
                panel.grid.minor = element_line(colour="grey90", size=0.5),
                panel.grid.major = element_line(colour="grey90", size=0.5)))

bpy <- list(us = 4e6,
            eu = 5.1e6,
            jp = 1e6,
            ksa = 6e5)

cntry <- list(us = "in the US:",
              eu = "in the EU:",
              jp = "in Japan:",
              ksa = "in Saudi Arabia:")

shinyServer(function(input, output) {

  # output$prevPlot <- renderPlot({
  # 
  #   x <- prevGrid(input$inc_range, input$life_range)
  #   
  #   p <- ggplot(x, aes(x = life, y = inc, z = prev)) +
  #          geom_tile(aes(fill = prev)) +
  #          scale_fill_viridis() +
  #          scale_color_distiller(palette = "Spectral") +
  #          stat_contour(aes(color=..level..), linetype = "dashed", binwidth = input$bin_size) +
  #          labs(x = "median life expectancy (years)", 
  #               y = "incidence (births per year)",
  #               fill = "prevalence")
  #   direct.label(p, "bottom.pieces")
  # 
  # })
  
  shinyjs::hide("country")
  observeEvent(input$br, {
    shinyjs::toggleElement("country")
    shinyjs::toggleElement("caption")
  })
  
  plotInput <- eventReactive({input$goButton
                              input$country
                              input$br}, {
    
    if (input$br == "pc") {
      ir <-  bpy[[input$country]] / c(input$inc_range[2], input$inc_range[1])
    }
    else {
      ir <-  as.numeric(input$caption) / c(input$inc_range[2], input$inc_range[1])
    }
    
    # x <- prevGrid(input$inc_range, input$life_range)
    x <- prevGrid(ir, input$life_range)
    
    yl <- paste0("(1:", input$inc_range[2], " to 1:", input$inc_range[1], ")")
    yl <- paste("incidence (births per year)", yl, sep = "\n")

    p <- ggplot(x, aes(x = life, y = inc, z = prev)) +       
      geom_tile(aes(fill = prev)) +
      scale_fill_viridis() +
      scale_color_distiller(palette = "Spectral") +
      stat_contour(aes(color=..level..), linetype = "dashed", binwidth = input$bin_size) +
      labs(x = "median life expectancy (years)",
           y = yl,
           fill = "prevalence")
    direct.label(p, "bottom.pieces")
  })
  
  output$prevPlot <- renderPlot({
    # input$goButton,
    print(plotInput())
  })
  
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
  
  output$dl <- downloadHandler(
    filename <- "prevalence.png",
    content <- function(file) {
      device <- function(..., width=7, height=5) {
        grDevices::png(..., width = 7, height = 5,
                       res = 300, units = "in")
      }
      ggsave(file, plot = plotInput(), device = device)
  })

})
