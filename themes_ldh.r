# load libraries ----------------------------------------------------------

# Fitting libraries
library(MASS)
library(sandwich)
library(lmtest)
library(plm)
library(animation)
library(gridExtra)
library(grid)

library(ggalt)
library(coefplot)

# Developer libraries
library(roxygen2)
library(testthat)

# Data manipulation
library(dplyr) # Filter, create new variables, summarise, ... Basically, anything you can think to do to a dataset
library(tidyr) # Reshape and merge datasets
library(data.table)
library(stringr) # String manipulation
library(lubridate)

# Plotting / viz functions
library(ggplot2) # Incredibly powerful plotting library built off of the "Grammer of Graphics"
library(ggvis)
library(htmltools)
library(htmlwidgets)
library(metricsgraphics)
library(rCharts)
library(plotly)

library(ggmap) # geocoding and geospatial library

# Libraries to help import files
library(haven) # Imports in files from Stata, SAS, and SPSS
library(readr) # An advanced form of the base 'read.csv' file with some added functionality.
library(readxl) # Functions to import in multiple sheets from Excel
library(googlesheets) # Functions to connect to Google Drive spreadsheets.
library(rvest) # Scrapes websites




library(knitr) # Helper function to produce this RMarkdown document.

# Colors and fonts
library(RColorBrewer)
library(extrafont)
loadfonts()

# library(choroplethrAdmin1)
# library(choroplethr)


# colors ------------------------------------------------------------------
# Custom color libraries
source("~/GitHub/Ethiopia/R/colorPalettes.R")



# recode variables --------------------------------------------------------
# mutate with if/else dictionary function
source("~/GitHub/Ethiopia/R/code2Cat.r")

convert01 = function(varName) {
  paste0('ifelse(', varName, ' == 2, 0, 
                  ifelse(', varName, '== 1, 1, NA))')
  
  # mutate_(.dots= setNames(list(convert01('w4_04')), ''))
}



# clustering function, from dr. essam -------------------------------------
cl   <- function(dat,fm, cluster){
  M <- length(unique(cluster))
  N <- length(cluster)
  K <- fm$rank
  dfc <- (M/(M-1))*((N-1)/(N-K))
  uj  <- apply(estfun(fm),2, function(x) tapply(x, cluster, sum));
  vcovCL <- dfc*sandwich(fm, meat=crossprod(uj)/N)
  coeftest(fm, vcovCL) 
}


# Multiple plot function --------------------------------------------------
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


# formatting numbers ------------------------------------------------------
roundMean = function(x) {
  round(mean(x, na.rm = TRUE), 2)
}

roundStd = function(x) {
  round(sd(x, na.rm = TRUE), 2)
}

percent = function(x, ndigits = 1) {
  paste0(sprintf("%.f", round(x*100, ndigits)), "%")
}



# clean up environment ----------------------------------------------------
rmExcept = function(x) {
  # x must be a string or a list of strings which encode the var names.
  rm(list=setdiff(ls(), x))
}



# remove attributes from dta import ---------------------------------------

removeAttributes <- function (data) {
  data <- lapply(data, function(x) {attr(x, 'labels') <- NULL; x})
  data <- lapply(data, function(x) {attr(x, 'label') <- NULL; x})
  data <- lapply(data, function(x) {attr(x, 'class') <- NULL; x})
  data <- lapply(data, function(x) {attr(x, 'levels') <- NULL; x})
  data = data.frame(data)
}

pullAttributes <- function (data) {
  label = lapply(data, function(x) attr(x, 'label'))
  
  label = data.frame(label)
  # labels = lapply(data, function(x) attr(x, 'labels'))
  
  # attrs = data.frame(label = label, labels = labels)
}




# themes ------------------------------------------------------------------



theme_jointplot <- function() {
  theme_bw() +
    theme(
      text = element_text(family = 'Segoe UI Light'),
      axis.text = element_text(size = 16, color = grey50K, family = 'Segoe UI Light'),
      title =  element_text(size = 18, family = 'Segoe UI', hjust = 0, color = grey60K),
      axis.title.y =  element_text(size = 20, color = grey50K, family = 'Segoe UI Semilight', hjust = 0.5, vjust = 1),
      axis.title.x =  element_text(size = 20, color = grey50K, family = 'Segoe UI Semilight', hjust = 0.5, vjust = -0.25),
      # axis.title.y = element_blank(), 
      # axis.line = element_blank(),
      # axis.ticks = element_blank()
      strip.text = element_text(size=13, color = grey50K, family = 'Segoe UI Semilight'),
      legend.position = c(0.85, 0.85),
      legend.text = element_text(size = 13),
      strip.background = element_blank()
      #           panel.grid.minor.y = element_blank(),
      #           panel.grid.major.y = element_blank())
    )
}

theme_box_ygrid<- function() {
  theme_bw() +
    theme(
      rect = element_blank(),
      plot.background = element_blank(),
      # panel.background = element_rect(fill = 'white'),
      axis.text = element_text(size = 10, color = '#4D525A'),
      title =  element_text(size = 14, face = "bold", hjust = 0, color = '#4D525A'),
      axis.title.x =  element_text(size = 12, face = "bold", color = '#4D525A', hjust = 0.5, vjust = -0.25),
      axis.title.y = element_blank(), 
      # axis.line = element_blank(),
      # axis.ticks = element_blank()
      strip.text = element_text(size=14, face = 'bold', hjust = 0.05, vjust = -2.5, color = '#4D525A'),
      legend.position = 'none',
      strip.background = element_blank(),
      axis.ticks.y = element_blank(),
      panel.margin = unit(3, 'lines'),
      panel.grid.major.y = element_line(size = 0.2, color = '#bababa'),
      panel.grid.minor.y = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank())
}

theme_xylab<- function() {
  theme_bw() +
    theme(
      text = element_text(family = 'Segoe UI Light', colour = grey60K),
      rect = element_blank(),
      plot.background = element_blank(),
      axis.text = element_text(size = 12,  color = grey60K),
      title =  element_text(size = 15, family = "Segoe UI", hjust = 0, color = grey90K),
      axis.title =  element_text(size = 14, family = "Segoe UI Semilight", color = grey60K, hjust = 0.5, vjust = -0.25),
      strip.text = element_text(size=14, family = "Segoe UI Semilight", hjust = 0.05, vjust = -2.5, color = grey90K),
      legend.position = 'none',
      strip.background = element_blank(),
      axis.ticks = element_blank(),
      panel.margin = unit(1, 'lines'),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank())
}

theme_xygrid<- function() {
  theme_bw() +
    theme(
      text = element_text(family = 'Segoe UI Light', colour = grey60K),
      rect = element_blank(),
      plot.background = element_blank(),
      # panel.background = element_rect(fill = 'white'),
      axis.text = element_text(size = 12,  color = grey60K),
      title =  element_text(size = 15, family = "Segoe UI", hjust = 0, color = grey90K),
      axis.title.x =  element_text(size = 14, family = "Segoe UI Semilight", color = grey60K, hjust = 0.5, vjust = -0.25),
      axis.title.y = element_blank(), 
      # axis.line = element_blank(),
      # axis.ticks = element_blank()
      strip.text = element_text(size=14, face = 'bold', hjust = 0.05, vjust = -2.5, color = '#4D525A'),
      legend.position = 'none',
      strip.background = element_blank(),
      axis.ticks = element_blank(),
      panel.margin = unit(3, 'lines'),
      panel.grid.major.y = element_line(size = 0.2, color = '#bababa'),
      panel.grid.minor.y = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_line(size = 0.1, color = '#bababa'))
}

theme_blankbox <- function() {
  theme_bw() +
    theme(
      axis.text = element_text(size = 16, color = 'white'),
      title =  element_text(size = 18, face = "bold", hjust = 0, color = 'white'),
      axis.title =  element_text(size = 20, face = "bold", color = 'white', hjust = 0.5, vjust = -0.25),
      # axis.title.y = element_blank(), 
      # axis.line = element_blank(),
      axis.ticks = element_blank(),
      strip.text = element_text(size=11),
      strip.background = element_blank(),
      legend.position="none",
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.border = element_blank()
    )
}


theme_blankLH <- function() {
  theme(
    title = element_blank(),
  axis.title = element_blank(),
  axis.text = element_blank(),
  axis.ticks = element_blank(),
  axis.ticks.length = unit(0, units = 'points'),
  axis.ticks.margin = unit(0, units =  'points'),
  panel.border = element_blank(),
  plot.margin = rep(unit(0, units = 'points'),4),
  panel.grid = element_blank(),
  panel.background = element_blank(), 
  plot.background = element_blank(), 
  legend.position="none"
  )
}


theme_heatmap <- function() {
  theme(
    title =  element_text(size = 16, hjust = 0, color = grey90K,
                          family = 'Segoe UI'),
    axis.title = element_blank(),
    axis.text = element_text(size = 12, hjust = 0.5, 
                             color = grey60K, family = 'Segoe UI Light'),
    axis.ticks = element_blank(),
    # axis.text.margin = unit(0, units =  'points'),
    panel.border = element_blank(),
    plot.margin = rep(unit(0, units = 'points'),4),
    panel.grid = element_blank(),
    panel.background = element_blank(), 
    plot.background = element_blank(), 
    legend.position="none"
  )
}


theme_xOnly<- function() {
  theme(title = element_text(size = 32, color = grey90K),
        axis.line = element_line(color = grey60K, size = 1),
        axis.ticks.x = element_line(color = grey60K, size = 0.5),
        axis.text.x = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        axis.title.x = element_text(size = 22, color = grey60K, family = 'Segoe UI Semilight'),
        axis.text.y = element_blank(),
        axis.title.y = element_blank(), 
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position="none",
        panel.background = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.border = element_blank(),
        plot.margin = rep(unit(0, units = 'points'),4),
        panel.grid = element_blank(),
        panel.background = element_blank(), 
        strip.text = element_text(size=13, face = 'bold'),
        strip.background = element_blank()
  )
}


theme_xAxis_yText<- function() {
  theme(title = element_text(size = 32, color = grey90K),
        axis.line = element_line(color = grey60K, size = 1),
        axis.ticks.x = element_line(color = grey60K, size = 0.5),
        axis.text.x = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        axis.title.x = element_text(size = 22, color = grey60K, family = 'Segoe UI Semilight'),
        axis.text.y = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        axis.title.y = element_blank(), 
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position="none",
        panel.background = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.border = element_blank(),
        plot.margin = rep(unit(0, units = 'points'),4),
        panel.grid = element_blank(),
        panel.background = element_blank(), 
        strip.text = element_text(size=13, face = 'bold'),
        strip.background = element_blank()
  )
}


theme_xGrid<- function() {
  theme(title = element_text(size = 16, color = grey90K, 
                             family = 'Segoe UI'),
        axis.line = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        axis.title.x = element_text(size = 18, color = grey60K, family = 'Segoe UI Semilight'),
        axis.text.y = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        axis.title.y = element_blank(), 
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position="none",
        panel.background = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_line(size = 0.1, colour = grey60K),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.border = element_blank(),
        plot.margin = rep(unit(0, units = 'points'),4),
        panel.background = element_blank(), 
        strip.text = element_text(size=13, face = 'bold'),
        strip.background = element_blank()
  )
}



theme_yGrid<- function() {
  theme(title = element_text(size = 16, color = grey90K, 
                             family = 'Segoe UI'),
        axis.line = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        axis.title.y = element_text(size = 18, color = grey60K, family = 'Segoe UI Semilight'),
        axis.text.y = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        axis.title.x = element_blank(), 
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position="none",
        panel.background = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_line(size = 0.1, colour = grey60K),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.border = element_blank(),
        plot.margin = rep(unit(0, units = 'points'),4),
        panel.background = element_blank(), 
        strip.text = element_text(size=13, face = 'bold'),
        strip.background = element_blank()
  )
}


theme_bump<- function() {
  theme(title = element_text(size = 32, color = '#4D525A'),
        axis.line = element_blank(),
        axis.ticks.length = unit(7, 'points'),
        axis.ticks.y = element_line(color = '#4D525A', size = 0.5),
        axis.text.y = element_text(size = 16, color = '#4D525A'),
        axis.title.y = element_text(size = 22, color = '#4D525A'),
        axis.text.x = element_text(size = 16, color = '#4D525A'),
        axis.title.x = element_blank(), 
        axis.line.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.position="none",
        panel.background = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_blank(),
        strip.text = element_text(size=13, face = 'bold'),
        strip.background = element_blank()
  )
}


theme_classicLH<- function() {
  theme(title = element_text(size = 32, color = '#4D525A'),
        axis.line = element_blank(),
        axis.ticks.x = element_line(color = '#4D525A', size = 1),
        axis.text.x = element_text(size = 16, color = '#4D525A'),
        axis.title.x = element_text(size = 22, color = '#4D525A'),
        axis.ticks.y = element_line(color = '#4D525A', size = 1),
        axis.text.y = element_text(size = 16, color = '#4D525A'),
        axis.title.y = element_text(size = 22, color = '#4D525A'),
        legend.position="none",
        panel.background = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_blank())
}

theme_pairGrid = function() {
  theme(legend.position="none",
        plot.background = element_blank(),
        panel.background = element_blank(),
        axis.text = element_text(size = 16, color = grey60K, family = 'Segoe UI Light'),
        title =  element_text(size = 18, face = "bold", hjust = 0, color = grey90K, family = 'Segoe UI'),
        axis.title =  element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y= element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.minor.y= element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(size = 0.2, colour = grey60K),
        axis.ticks.x = element_blank(),
        plot.margin = rep(unit(0, units = 'points'),4),
        panel.margin = rep(unit(0, units = 'points'),4),
        panel.border = element_blank(),
        # axis.text.x  = element_blank(), axis.title.x  = element_blank(),
        # axis.ticks = element_blank(), axis.line = element_blank(),
        axis.ticks.y = element_blank(), axis.line.y = element_blank(),
        axis.text.y = element_blank(), axis.title.y = element_blank())
}

