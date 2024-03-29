## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = FALSE, fig.width=8, fig.height=8, warning=FALSE, comment=NA, message=FALSE, eval=F)

## -----------------------------------------------------------------------------
#  library(rISIMIP)

## ----lu_future----------------------------------------------------------------
#  # Remove all items except filedir
#  rm(list=ls())
#  
#  # Specify path of file directory
#  filedir <- "/media/matt/Data/Documents/Wissenschaft/Data/"
#  
#  # Time frames
#  timeframes <- c("1995", "2050", "2080")
#  
#  library(raster)
#  gdp_data <- stack(mapply(FUN=function(x,y){calc(stack(readISIMIP(path=filedir, type="gdp", scenario="rcp26soc", startyear=x, endyear=y)), mean)},
#                           c(1980, 2036, 2066), c(2009, 2065, 2095)))
#  names(gdp_data) <- timeframes
#  gdp_data <- as.data.frame(rasterToPoints(gdp_data))
#  colnames(gdp_data) <- c("x", "y", "1995", "2050", "2080")

## ----gdp_map------------------------------------------------------------------
#  library(dplyr)
#  # Set 0 values to NA
#  gdp_data[gdp_data == 0] <- NA
#  
#  # Load outline data
#  library(ggplot2)
#  data(outline, package="ggmap2")
#  
#  # Turn into long format and plot
#  gdp_data %>% tidyr::gather(year, gdp, -c(x,y)) %>%
#    mutate(year = factor(year, labels=c("1995", "2050", "2080"))) %>%
#    tidyr::drop_na() %>%
#    mutate(gdp = cut(gdp, c(0, 25, 75, 150, 300, 500, 700, 1500, 10000))) %>%
#    ggplot() + geom_tile(aes(x=x, y=y, fill=gdp)) +
#    facet_wrap(~ year, ncol=1) +
#    geom_sf(data=outline, fill="transparent", colour="black") +
#    scale_fill_manual(name="GDP", values=c("#00007F", "blue", "#007FFF",
#                                                    "cyan", "#7FFF7F", "yellow",
#                                                    "#FF7F00", "red", "#7F0000"),
#                         na.value="transparent") +
#    theme_bw() + theme(strip.background= element_blank()) +
#    scale_x_continuous(name=expression(paste("Longitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-180, -90, 0, 90, 180)) +
#    scale_y_continuous(name=expression(paste("Latitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-60, -40, -20, 0, 20, 40, 60,80)) +
#    coord_sf(xlim=c(-180,180), ylim=c(-60,84))

## ----gdp_change---------------------------------------------------------------
#  # Calculate change in population
#  delta_gdp <- gdp_data %>%
#    mutate_at(vars(`2050`:`2080`), funs(. - `1995`)) %>%
#    dplyr::select(-matches("1995")) %>%
#    tidyr::gather(year, gdp, -c(x,y))
#  
#  # Set 0 values to NA
#  delta_gdp[delta_gdp == 0] <- NA
#  
#  # Define Year label
#  delta_gdp$year <- factor(delta_gdp$year, labels=c("2050", "2080"))
#  
#  # Drop NAs
#  delta_gdp<- tidyr::drop_na(delta_gdp)
#  
#  # Turn gdp into categories
#  delta_gdp$gdp <- cut(delta_gdp$gdp,
#                           c(-2000, -1000, -500, 0, 500, 1000, 2000, 5000, 10000))
#  
#  # Plot change in gdp
#  ggplot() +
#    geom_tile(data=delta_gdp, aes(x=x, y=y, fill=gdp)) +
#    facet_wrap(~ year, ncol=1) +
#    geom_sf(data=outline, fill="transparent", colour="black") +
#    scale_fill_manual(name="GDP change",
#                      values=c("#00007F", "blue", "#007FFF",
#                               "cyan", "#7FFF7F", "yellow",
#                               "#FF7F00", "red", "#7F0000"),
#                         na.value="transparent") +
#    theme_bw() + theme(strip.background= element_blank()) +
#    scale_x_continuous(name=expression(paste("Longitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-180, -90, 0, 90, 180)) +
#    scale_y_continuous(name=expression(paste("Latitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-60, -40, -20, 0, 20, 40, 60,80)) +
#    coord_sf(xlim=c(-180,180), ylim=c(-60,84))

## ----gdp_timeseries-----------------------------------------------------------
#  # Get data
#  gdp_data <- rISIMIP::readISIMIP(path=filedir, type="gdp", scenario="rcp26soc",
#                                  startyear=2006, endyear=2099)
#  
#  # Calculate total gdp for every year
#  gdp_data <- data.frame(gdp=raster::cellStats(gdp_data, stat="sum", na.rm=TRUE),
#                         year=c(2006:2099))
#  
#  # Plot total population over time
#  ggplot(data = gdp_data, aes(x = year, y = gdp)) +
#    labs(x= "Year", y="GDP") +
#    geom_line() + theme_classic()

