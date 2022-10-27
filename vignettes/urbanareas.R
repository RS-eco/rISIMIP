## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo=T, warning=F, comment=NA, message=F, fig.width=8, fig.height=6, eval=F)

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
#  times <- data.frame(timeframe=c("1995", "2020","2050","2080"),
#                      startyear=c(1980, 2006,2036,2066),
#                      endyear=c(2009, 2035,2065,2095))
#  
#  # Create unique combination of timeframe, scenario and model
#  df <- expand.grid(timeframe=times$timeframe, scenario=c("rcp26", "rcp60"))
#  
#  # Remove rcp60 scenarios after 2100, as no data is available for this case
#  library(dplyr)
#  df <- full_join(df, times) %>% filter(scenario != "rcp60" | endyear < 2100)
#  
#  # Urban areas data
#  urbanareas <- lapply(1:nrow(df), function(x){
#    data <- readISIMIP(path=filedir, type="landuse", scenario=df$scenario[x],
#                       var="urbanareas", startyear=df$startyear[x],
#                       endyear=df$endyear[x])
#    data <- raster::calc(data, mean)
#    data <- as.data.frame(raster::rasterToPoints(data))
#    colnames(data) <- c("x", "y", "urbanareas")
#    data$year <- df$timeframe[x]
#    data$scenario <- df$scenario[x]
#    return(data)
#  })

## -----------------------------------------------------------------------------
#  # Combine all files into one dataframe
#  library(dplyr)
#  urbanareas <- bind_rows(urbanareas)
#  
#  #Calculate area of each cell in km2
#  data(landseamask_generic, package="rISIMIP")
#  isimip_area <- raster::area(landseamask_generic, na.rm=TRUE) # km2
#  isimip_area <- as.data.frame(raster::rasterToPoints(isimip_area))
#  colnames(isimip_area) <- c("x", "y", "area")
#  sum(isimip_area$area)
#  
#  # Add area to totals and urbanareas dataframe
#  urbanareas <- left_join(urbanareas, isimip_area)
#  
#  # Remove 2005soc data
#  urbanareas <- urbanareas %>% filter(scenario != "2005soc")

## ----urbanareas---------------------------------------------------------------
#  # Create Map
#  library(ggplot2)
#  data(outline, package="ggmap2")
#  urbanareas$total <- urbanareas$urbanareas*urbanareas$area
#  summary(urbanareas)
#  urbanareas <- urbanareas %>% filter(year %in% c(1995,2050,2080))
#  urbanareas$urbanareas <- round(urbanareas$urbanareas*100, digits=0)
#  urbanareas$urbanareas[urbanareas$urbanareas == 0] <- NA
#  ggplot() +
#    geom_tile(data=urbanareas, aes(x=x, y=y, fill=urbanareas)) +
#    facet_grid(year ~ scenario) +
#    geom_sf(data=outline, fill="transparent", colour="black") +
#    scale_fill_gradientn(name="% Cover",
#                         colours=colorRampPalette(c("#00007F", "blue", "#007FFF",
#                                                    "cyan", "#7FFF7F", "yellow", "#FF7F00",
#                                                    "red", "#7F0000"))(255),
#                         na.value="transparent", limits=c(0,100)) +
#    theme_bw() + theme(strip.background= element_blank()) +
#    scale_x_continuous(name=expression(paste("Longitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-180, -90, 0, 90, 180)) +
#    scale_y_continuous(name=expression(paste("Latitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-40, -20, 0, 20, 40, 60,80)) +
#    coord_sf(xlim=c(-180,180), ylim=c(-56,84))

## ----urbanareas_change--------------------------------------------------------
#  # Change format of land-use data
#  urbanareas <- urbanareas %>% dplyr::select(-area) %>%
#    tidyr::gather(var, value, -c(x,y,year, scenario)) %>%
#    tidyr::spread(year, value)
#  
#  # Calculate delta landuse
#  delta_urban <- urbanareas %>% group_by(x,y,scenario,var) %>%
#    dplyr::summarise_at(vars(`1995`, `2050`, `2080`), mean, na.rm=TRUE) %>%
#    mutate_at(vars(`2050`:`2080`), funs(. - `1995`)) %>%
#    dplyr::select(-`1995`) %>%
#    tidyr::gather(year, value, -c(x, y, scenario, var))
#  
#  #Subset data for plotting
#  ggplot() + geom_tile(data=delta_urban, aes(x=x, y=y, fill=value)) +
#    facet_grid(year ~ scenario, switch="y") +
#    geom_sf(data=outline, fill="transparent", colour="black") +
#    scale_fill_gradientn(name="%", colours=rev(colorRampPalette(
#      c("#00007F", "blue", "#007FFF", "cyan", "white", "yellow",
#        "#FF7F00", "red", "#7F0000"))(255)), breaks=c(-20,-15, -10, -5,0,5,10,15,20),
#      values=c(1,0.7,0.52,0.5,0.48,0.3,0), limits=c(-20,20), na.value="transparent") +
#    theme_classic() + theme(axis.title = element_blank(),axis.line = element_blank(),
#                            axis.ticks = element_blank(), axis.text = element_blank(),
#                            panel.grid = element_blank(), strip.background= element_blank(),
#                            strip.placement = "outside",
#                            strip.text = element_text(size=10, face="bold"),
#                            rect = element_rect(fill = "transparent")) +
#    coord_sf(xlim=c(-180,180), ylim=c(-56,84), expand=FALSE)

## ----urbanareas_ts------------------------------------------------------------
#  # List data files
#  (data_urban <- list.files(paste0(filedir, "/ISIMIP2b/InputData/landuse"),
#                           pattern="urbanareas", recursive=T, full.names=T))
#  
#  #Calculate area of each cell in km2
#  library(raster)
#  data(landseamask_generic, package="rISIMIP")
#  isimip_area <- raster::area(landseamask_generic) # km2
#  
#  # Turn into raster files
#  urban_areas <- lapply(data_urban, function(x){
#    data <- stack(x)
#    data_urban_ts <- as.data.frame(raster::cellStats(data*isimip_area, stat='sum', na.rm=TRUE))
#    nc <- ncdf4::nc_open(x)
#    timeref <- lubridate::year(strsplit(nc$dim[["time"]]$units, " ")[[1]][3])
#    if(ncdf4::ncvar_get(nc, nc$dim$time)[1] == 0){
#      data_urban_ts$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time)
#    } else if (ncdf4::ncvar_get(nc, nc$dim$time)[1] != 0){
#      data_urban_ts$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time) - 1
#    }
#    ncdf4::nc_close(nc)
#    data_urban_ts$var <- "urbanareas"
#    colnames(data_urban_ts)[1] <- "area"
#    data_urban_ts$scenario <- strsplit(basename(x), split="_")[[1]][1]
#    return(data_urban_ts)
#  })
#  urban_areas <- do.call("rbind", urban_areas)
#  
#  urban_areas$scenario <- as.character(urban_areas$scenario)
#  urban_areas$scenario[urban_areas$scenario == "rcp26soc"] <- "rcp26"
#  urban_areas$scenario[urban_areas$scenario == "rcp60soc"] <- "rcp60"
#  urban_areas$scenario[urban_areas$scenario == "2100rcp26soc"] <- "rcp26"
#  urban_areas$scenario <- factor(urban_areas$scenario)
#  
#  ggplot(data = urban_areas, aes(x = year, y = area/1000000, colour=factor(scenario))) + scale_colour_discrete(name="Scenario") + labs(x= "Year", y="Area (km² x 1,000,000)") + scale_linetype_discrete(name="Scenario") + geom_line() + theme_bw() + theme(strip.background= element_blank())

