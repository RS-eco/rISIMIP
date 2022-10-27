## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = FALSE, fig.width=8, fig.height=8, warning=FALSE, comment=NA, message=FALSE, eval=F)

## -----------------------------------------------------------------------------
#  library(rISIMIP)

## ----global_options-----------------------------------------------------------
#  # Specify path of file directory
#  filedir <- "/media/matt/Data/Documents/Wissenschaft/Data/"

## ----pop_data-----------------------------------------------------------------
#  # Time frames
#  timeframes <- c("1995", "2050", "2080")
#  
#  # rcp26soc only goes until 2100
#  library(raster)
#  population_data <- stack(mapply(FUN=function(x,y){calc(stack(readISIMIP(path=filedir, type="population", scenario="rcp26soc", startyear=x, endyear=y)), mean)}, c(1980, 2036, 2066), c(2009, 2065, 2095)))
#  names(population_data) <- timeframes
#  population_data <- as.data.frame(rasterToPoints(population_data))
#  colnames(population_data) <- c("x", "y", "1995", "2050", "2080")

## ----population_density-------------------------------------------------------
#  library(dplyr)
#  
#  # Set 0 values to NA
#  population_data[population_data == 0] <- NA
#  
#  # Get cell area
#  data("landseamask_generic", package="rISIMIP")
#  area <- data.frame(raster::rasterToPoints(raster::area(landseamask_generic, na.rm=TRUE)))
#  
#  # Load outline
#  data(outline, package="ggmap2")
#  
#  # Turn into long format, calculate density and create plot
#  library(ggplot2)
#  population_data %>% tidyr::gather(year, size, -c(x,y)) %>%
#    mutate(year = factor(year, labels=c("1995", "2050", "2080"))) %>%
#    dplyr::left_join(area) %>% # Calculate population density
#    mutate(density = size/layer) %>%
#    tidyr::drop_na() %>%
#    mutate(density = cut(density, c(0, 25, 75, 150, 300, 500, 700, 1500, 10000))) %>% # Turn population density into categories
#    ggplot() + geom_tile(aes(x=x, y=y, fill=density)) +
#    facet_wrap(~ year, ncol=1) +
#    geom_sf(data=outline, fill="transparent", colour="black") +
#    scale_fill_discrete(name="Population\ndensity (per km2)", na.value="transparent") +
#    theme_bw() + theme(strip.background= element_blank()) +
#    scale_x_continuous(name=expression(paste("Longitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-180, -90, 0, 90, 180)) +
#    scale_y_continuous(name=expression(paste("Latitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-60, -40, -20, 0, 20, 40, 60,80)) +
#    coord_sf(xlim=c(-180,180), ylim=c(-60,84))

## ----population_change--------------------------------------------------------
#  # Calculate change in population
#  delta_pop <- population_data %>%
#    mutate_at(vars(`2050`:`2080`), funs(. - `1995`)) %>%
#    select(-matches("1995")) %>%
#    tidyr::gather(year, size, -c(x,y))
#  
#  # Set 0 values to NA
#  delta_pop[delta_pop == 0] <- NA
#  
#  # Calculate population density
#  data("landseamask_generic", package="rISIMIP")
#  area <- data.frame(raster::rasterToPoints(raster::area(landseamask_generic, na.rm=TRUE)))
#  delta_pop <- dplyr::left_join(delta_pop, area)
#  delta_pop$density <- delta_pop$size/delta_pop$layer
#  
#  # Define Year label
#  delta_pop$year <- factor(delta_pop$year, labels=c("2050", "2080"))
#  
#  # Drop NAs
#  delta_pop <- tidyr::drop_na(delta_pop)
#  
#  # Turn population density into categories
#  delta_pop$density <- cut(delta_pop$density,
#                           c(-2000, -1000, -500, 0, 500, 1000, 2000, 5000, 10000))
#  
#  # Plot change in population density
#  ggplot() +
#    geom_tile(data=delta_pop, aes(x=x, y=y, fill=density)) +
#    facet_wrap(~ year, ncol=1) +
#    geom_sf(data=outline, fill="transparent", colour="black") +
#    scale_fill_manual(name="Population\ndensity (per km2)\nchange",
#                         values=c("#00007F", "blue", "#007FFF", "cyan", "yellow",
#          "#FF7F00", "red", "#7F0000"), na.value="transparent") +
#    theme_bw() + theme(strip.background= element_blank()) +
#    scale_x_continuous(name=expression(paste("Longitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-180, -90, 0, 90, 180)) +
#    scale_y_continuous(name=expression(paste("Latitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-60, -40, -20, 0, 20, 40, 60,80)) +
#    coord_sf(xlim=c(-180,180), ylim=c(-60,84))

## ----population_timeseries----------------------------------------------------
#  # Get data
#  pop_data <- rISIMIP::readISIMIP(path=filedir, type="population", scenario="rcp26soc",
#                                  startyear=2006, endyear=2099)
#  
#  # Calculate total population size for every year
#  pop_size <- data.frame(size=raster::cellStats(pop_data, stat="sum", na.rm=TRUE),
#                         year=c(2006:2099))
#  
#  # Plot total population over time
#  ggplot(data = pop_size, aes(x = year, y = size/1000000000)) +
#    labs(x= "Year", y="Total population size (Billion)") +
#    geom_line() + theme_classic()

