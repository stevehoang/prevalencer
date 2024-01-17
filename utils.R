

# define pre-set constants --------------------------------------------------------

# births per year
bpy <- list(us = 4e6,
            eu = 5.1e6,
            jp = 1e6)

# populations
pops <- list(us = 332e6,
             eu = 448e6,
             jp = 126e6)

# countries
cntry <- list(us = "in the US:",
              eu = "in the EU:",
              jp = "in Japan:")


# settings ----------------------------------------------------------------

# ggplot theme
theme_set(theme_minimal(base_size = 18) +
            theme(plot.title = element_text(size = rel(1)),
                  axis.text = element_text(size = rel(0.8)),
                  panel.grid.minor = element_line(colour="grey90", size=0.5),
                  panel.grid.major = element_line(colour="grey90", size=0.5)))


# utility functions -------------------------------------------------------


# calculate prevalence as a function of incidence and life expectancy
prev <- function(inc, life) {
  p <- inc / (1 - exp(-1 * log(2) / life))
  return(p)
}

# calculate a grid of prevalence values given a range of life expectancy
# and incidence values
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


