## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo=T, warning=F, comment=NA, message=F, eval=F)

## -----------------------------------------------------------------------------
#  library(rISIMIP)

## -----------------------------------------------------------------------------
#  # Choose one of totals, 5crops, 15crops
#  lu_type <- "totals"

## -----------------------------------------------------------------------------
#  # Specify path of file directory
#  filedir <- "/media/matt/Data/Documents/Wissenschaft/Data"

## -----------------------------------------------------------------------------
#  data("landuse-totals_2005soc")

## -----------------------------------------------------------------------------
#  # Get summarised landuse data
#  d <- data(package="rISIMIP")
#  landuse <- d$results[,"Item"][grep(x=d$results[,"Item"], pattern="landuse-totals_")]
#  
#  # Read files into dataframe
#  crops <- lapply(landuse, function(x){
#    data <- get(data(list=x))
#    data$year <- strsplit(strsplit(basename(x), split="_")[[1]][4], split="[.]")[[1]][1]
#    data$scenario <- strsplit(basename(x), split="_")[[1]][1]
#    data$model <- strsplit(basename(x), split="_")[[1]][2]
#    return(data)
#  })
#  crops <- do.call(plyr::rbind.fill, crops)
#  
#  #Calculate area of each cell in km2
#  data(landseamask_generic, package="rISIMIP")
#  isimip_area <- raster::area(landseamask_generic, na.rm=TRUE) # km2
#  isimip_area <- as.data.frame(raster::rasterToPoints(isimip_area))
#  colnames(isimip_area) <- c("x", "y", "area")
#  sum(isimip_area$area)
#  
#  # Add area to crops dataframe
#  library(dplyr)
#  crops <- left_join(crops, isimip_area)
#  
#  # Remove 2005soc data
#  crops <- crops %>% filter(scenario != "2005soc")

## -----------------------------------------------------------------------------
#  # Remove duplicate of 1995 data
#  #crops <- crops %>% filter(year != 1995 | scenario != "rcp60")
#  
#  # Calculate remaining area not considered by land-use types
#  crops$other <- 1 - (crops %>% dplyr::select(-c(x,y,area, year, scenario, model, matches("total"))) %>%
#                        rowSums(na.rm=TRUE))
#  
#  # Calculate total area per category and turn into long format
#  crops_sum <- crops %>%
#    mutate_at(vars(-c(x,y,area,year,scenario,model)), funs(. * area)) %>%
#    group_by(year, scenario, model) %>% summarise_at(vars(-c(x,y,area)), sum) %>%
#    dplyr::select(-matches("total")) %>% filter(year < 2090) %>%
#    tidyr::gather(var, value, -c(year, scenario, model)) %>%
#    tidyr::unite(time_rcp, year, sep=" ")# Adapt unite accordingly
#  
#  # Calculate mean across models
#  crops_mean <- crops_sum %>% group_by(time_rcp, var, scenario) %>%
#    dplyr::summarise(mean=mean(value, na.rm=T))
#  crops_mean <- tidyr::drop_na(crops_mean)
#  crops_mean$perc <- crops_mean$mean/sum(isimip_area$area)*100
#  
#  library(ggplot2)
#  colnames(crops_mean) <- c("time_rcp", "var", "scenario", "area", "perc")
#  crops_mean$var <- factor(crops_mean$var)
#  ggplot(data=crops_mean, aes(x=time_rcp, y=area/1000000, fill=var)) +
#    geom_bar(stat="identity", position="stack") + facet_wrap(~scenario, ncol=1) +
#    #geom_text(aes(label=round(perc, digits=2))) +
#    scale_fill_discrete(name="Land-use type") +
#    #scale_x_discrete(name="", labels=c("1995", "2050 \n RCP2.6", "2050 \n RCP6.0", "2080 \n RCP2.6", "2080 \n RCP6.0")) +
#    scale_y_continuous(name="Area (km² x 1,000,000)", limits=c(0,150), expand=c(0,0)) +
#    theme_bw() +
#    theme(legend.title=element_text(face="bold"),
#          axis.title.y=element_text(face="bold"),
#          rect = element_rect(fill = "transparent", colour=NA))

## -----------------------------------------------------------------------------
#  # Calculate dominant landuse per grid cell
#  dominant_lu <- crops %>% filter(year != 1995 | scenario != "rcp60") %>%
#    select(-c(area, matches("total"))) %>%
#    tidyr::gather(var, value, -c(x,y,year,scenario, model)) %>%
#    group_by(x,y,year,scenario, model) %>%
#    summarise(lu=which.max(value)) %>%
#    as.data.frame()
#  
#  labels_lu <- colnames(crops)[!colnames(crops) %in% c("x","y","year","scenario","model", "area")]
#  labels_lu <- labels_lu[unique(dominant_lu$lu)]
#  dominant_lu$lu <- factor(dominant_lu$lu, labels=labels_lu)
#  
#  dominant_lu <- dominant_lu %>% filter(year %in% c("1995", "2080")) %>%
#    filter(scenario %in% c("rcp26", "rcp60")) %>%
#    tidyr::unite(time_rcp, year, scenario, sep=" ")
#  dominant_lu$time_rcp <- factor(dominant_lu$time_rcp,
#                                 labels=c("1995", "2080 RCP2.6", "2080 RCP6.0"))
#  # Create Map
#  data(outline, package="ggmap2")
#  ggplot() +
#    geom_tile(data=dominant_lu, aes(x=x, y=y, fill=factor(lu))) +
#    facet_grid(model ~ time_rcp) +
#    geom_polygon(data=outline, aes(x=long,y=lat, group=group),
#                 fill="transparent", colour="black") +
#    scale_fill_discrete(name="Dominant landuse type", labels=labels_lu) +
#    theme_bw() + theme(strip.background= element_blank()) +
#    scale_x_continuous(name=expression(paste("Longitude (",degree,")")), expand=c(0.01,0.01),
#                       breaks=c(-120, -60, 0, 60, 120, 180)) +
#    scale_y_continuous(name=expression(paste("Latitude (",degree,")")), expand=c(0.01,0.01),
#                       breaks=c(-60, -40, -20, 0, 20, 40, 60,80)) +
#    coord_quickmap(xlim=c(-180,180), ylim=c(-60,80))

## -----------------------------------------------------------------------------
#  #Calculate mean across GCMs
#  landuse <- crops %>% select(-c(area, cropland_total)) %>%
#    tidyr::gather(var, value, -c(x,y,year,scenario,model)) %>%
#    group_by(x,y,year,scenario, var) %>% summarise(value=mean(value,na.rm=T))
#  landuse$var <- factor(landuse$var)
#  
#  # Specify colour ramp
#  colourtheme <- colorRampPalette(c("white", "#00007F", "blue", "#007FFF", "cyan",
#                                    "#7FFF7F", "yellow", "#FF7F00", "red",
#                                    "#7F0000"))(255)
#  
#  # Create Map of 1995
#  landuse_1995 <- landuse[landuse$year == 1995 & landuse$scenario == "rcp26",]
#  landuse_1995 <- landuse_1995[landuse_1995$var %in% c("cropland_irrigated", "cropland_rainfed", "pastures"),]
#  ggplot() + geom_tile(data=landuse_1995, aes(x=x, y=y, fill=value*100)) + facet_wrap(var ~ ., ncol=1) +
#    geom_polygon(data=outline, aes(x=long,y=lat, group=group),
#                 fill="transparent", colour="black") +
#    scale_fill_gradientn(name="% Cover", colours=colourtheme, na.value="transparent", limits=c(0,100)) +
#    theme_bw() + theme(strip.background= element_blank()) +
#    scale_x_continuous(name=expression(paste("Longitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-180, -90, 0, 90, 180)) +
#    scale_y_continuous(name=expression(paste("Latitude (",degree,")")), expand=c(0.05,0.05),
#                       breaks=c(-60, -40, -20, 0, 20, 40, 60, 80)) +
#    coord_cartesian(xlim=c(-180,180), ylim=c(-60,84))
#  
#  #Plot map for individual future years
#  data("outline", package="ggmap2")
#  landuse_rcp26 <- landuse[landuse$year == 2080 & landuse$scenario == "rcp26",]
#  ggplot() + geom_tile(data=landuse_rcp26, aes(x=x, y=y, fill=value*100)) + facet_wrap(. ~ var) +
#    geom_polygon(data=outline, aes(x=long,y=lat, group=group), fill="transparent", colour="black") +
#    scale_fill_gradientn(name="% Cover", colours=colourtheme, na.value="transparent", limits=c(0,100)) +
#    theme_bw() + theme(strip.background= element_blank()) +
#    scale_x_continuous(name=expression(paste("Longitude (",degree,")")),
#                       expand=c(0.05,0.05), breaks=c(-180, -90, 0, 90, 180)) +
#    scale_y_continuous(name=expression(paste("Latitude (",degree,")")),
#                       expand=c(0.05,0.05), breaks=c(-60, -40, -20, 0, 20, 40, 60,80)) +
#    coord_cartesian(xlim=c(-180,180), ylim=c(-60,84))
#  
#  landuse_rcp60 <- landuse[landuse$year == 2080 & landuse$scenario == "rcp60",]
#  ggplot() + geom_tile(data=landuse_rcp60, aes(x=x, y=y, fill=value*100)) + facet_wrap(. ~ var) +
#    geom_polygon(data=outline, aes(x=long,y=lat, group=group), fill="transparent", colour="black") +
#    scale_fill_gradientn(name="% Cover", colours=colourtheme, na.value="transparent", limits=c(0,100)) +
#    theme_bw() + theme(strip.background= element_blank()) +
#    scale_x_continuous(name=expression(paste("Longitude (",degree,")")),
#                       expand=c(0.05,0.05), breaks=c(-180, -90, 0, 90, 180)) +
#    scale_y_continuous(name=expression(paste("Latitude (",degree,")")),
#                       expand=c(0.05,0.05), breaks=c(-60, -40, -20, 0, 20, 40, 60,80)) +
#    coord_cartesian(xlim=c(-180,180), ylim=c(-60,84))

## -----------------------------------------------------------------------------
#  # Change land-use categories
#  landuse_all <- crops %>% dplyr::select(-c(area, matches("total")))
#  landuse_all$biofuel_cropland <- landuse_all$biofuel_cropland_irrigated + landuse_all$biofuel_cropland_rainfed
#  landuse_all$biofuel_cropland[is.na(landuse_all$biofuel_cropland)] <- 0
#  landuse_all$cropland <- landuse_all$cropland_rainfed + landuse_all$cropland_irrigated
#  
#  # Change format of land-use data
#  landuse_fut <- landuse_all %>% select(-c(cropland_irrigated, cropland_rainfed,
#                                           biofuel_cropland_irrigated,
#                                           biofuel_cropland_rainfed)) %>%
#    tidyr::gather(var, value, -c(x,y,year, scenario, model))
#  landuse_fut <- tidyr::spread(landuse_fut, year, value)
#  landuse_fut <- landuse_fut %>% tidyr::replace_na(list(`1995`=0, `2080`=0))
#  
#  # Calculate delta landuse
#  delta_landuse <- landuse_fut %>% group_by(x,y,scenario,var) %>%
#    dplyr::summarise_at(vars(`1995`:`2080`), mean, na.rm=TRUE)
#  delta_landuse <- delta_landuse %>%
#    mutate_at(vars(`2080`), funs(. - `1995`))
#  delta_landuse <- tidyr::gather(delta_landuse, year, value, -c(x, y, scenario, var))
#  delta_landuse$year <- as.numeric(delta_landuse$year)
#  
#  #Subset data for plotting
#  landuse <- delta_landuse[delta_landuse$year == 2080,]
#  landuse <- landuse %>% tidyr::unite(year, scenario, col="time_rcp")
#  landuse$time_rcp <- factor(landuse$time_rcp, labels=c("2080 RCP2.6", "2080 RCP6.0"))
#  landuse$var <- factor(landuse$var, labels=c("Biofuel cropland", "Cropland", "Other", "Pastures"))
#  ggplot() +
#    geom_tile(data=landuse, aes(x=x, y=y, fill=value*100)) +
#    facet_grid(var ~ time_rcp, scale="free_y", switch="y") +
#    geom_polygon(data=outline, aes(x=long,y=lat, group=group),
#                 fill="transparent", colour="black") +
#    scale_fill_gradientn(name="%", colours=rev(colorRampPalette(
#      c("#00007F", "blue", "#007FFF", "cyan", "white", "yellow",
#        "#FF7F00", "red", "#7F0000"))(255)), breaks=c(-90,-60,-30,0,30,60,90),
#      values=c(1,0.7,0.52,0.5,0.48,0.3,0), limits=c(-90,90), na.value="transparent") +
#    theme_classic() + theme(axis.title = element_blank(),axis.line = element_blank(),
#                            axis.ticks = element_blank(), axis.text = element_blank(),
#                            panel.grid = element_blank(), strip.background= element_blank(),
#                            strip.placement = "outside",
#                            strip.text = element_text(size=10, face="bold"),
#                            rect = element_rect(fill = "transparent")) +
#    coord_quickmap(xlim=c(-180,180), ylim=c(-60,85), expand=FALSE)

## -----------------------------------------------------------------------------
#  #' getData from the raster package downloads automatically GADM data per country
#  deu <- raster::getData(name="GADM", country="DEU", level=1, path=paste0(filedir, "/GADM")) # Level1 gives regional boundaries
#  #' Subset data by Bayern
#  bavaria <- deu[deu$NAME_1 == "Bayern",]
#  
#  #Subset data for plotting
#  landuse <- delta_landuse[delta_landuse$year == 2080,]
#  landuse <- landuse %>% tidyr::unite(year, scenario, col="time_rcp")
#  landuse$time_rcp <- factor(landuse$time_rcp, labels=c("2080 RCP2.6", "2080 RCP6.0"))
#  landuse$var <- factor(landuse$var, labels=c("Biofuel cropland", "Cropland", "Other",
#                                              "Pastures"))
#  ggplot() +
#    geom_tile(data=landuse, aes(x=x, y=y, fill=value*100)) +
#    facet_grid(var ~ time_rcp, scale="free_y", switch="y") +
#    geom_polygon(data=outline, aes(x=long,y=lat, group=group),
#                 fill="transparent", colour="black") +
#    geom_polygon(data=bavaria, aes(x=long, y=lat, group=group),
#                 fill="transparent", colour="black", lty="dashed") +
#    scale_fill_gradientn(name="%", colours=rev(colorRampPalette(
#      c("#00007F", "blue", "#007FFF", "cyan", "white", "yellow",
#        "#FF7F00", "red", "#7F0000"))(255)), breaks=c(-100,-75,-50,-25,0,25,50,75,100),
#      values=c(1,0.7,0.52,0.5,0.48,0.3,0), limits=c(-100,100), na.value="transparent") +
#    theme_classic() + theme(axis.title = element_blank(),axis.line = element_blank(),
#                            axis.ticks = element_blank(), axis.text = element_blank(),
#                            panel.grid = element_blank(), strip.background= element_blank(),
#                            strip.placement = "outside",
#                            strip.text = element_text(size=10, face="bold"),
#                            rect = element_rect(fill = "transparent")) +
#    coord_quickmap(xlim=c(-11.5,40.5), ylim=c(35.5,70), expand=FALSE)

## -----------------------------------------------------------------------------
#  # Calculate threshold value
#  (threshold <- delta_landuse %>% group_by(var, year) %>% filter(value > 0) %>%
#     summarise(threshold = quantile(value, probs=0.75)))
#  
#  # Subset data by threshold
#  top25_lu <- left_join(delta_landuse, threshold)
#  top25_lu <- top25_lu %>% group_by(x,y,scenario, var, year) %>%
#    filter(value > threshold) %>% select(-threshold)
#  top25_lu$value <- 1
#  
#  # Plot
#  top25_lu %>% filter(year==2080) %>%
#    ggplot(aes(x=x,y=y)) + geom_tile() +
#    geom_polygon(data=outline, aes(x=long,y=lat, group=group),
#                 fill="transparent", colour="black") +
#    facet_grid(var~scenario, switch="y") +
#    labs(x="", y="") + theme_bw() +
#    theme(strip.placement = "outside", strip.background = element_blank())

## ---- eval=F------------------------------------------------------------------
#  # List data files
#  data_total <- list.files(paste0(filedir, "/ISIMIP2b/InputData/landuse"),
#                           pattern="totals", recursive=T, full.names=T)
#  data_urban <- list.files(paste0(filedir, "/ISIMIP2b/InputData/landuse"),
#                           pattern="urbanareas", recursive=T, full.names=T)
#  
#  # Re-create isimip area
#  data(landseamask_generic, package="rISIMIP")
#  isimip_area <- raster::area(landseamask_generic, na.rm=TRUE) # km2
#  
#  # Calculate total area of each land use class
#  varnames <- c("cropland_total", "pastures", "cropland_irrigated", "cropland_rainfed")
#  data_crop_areas <- lapply(varnames, function(x){
#    data_total_area_sum <- lapply(data_total, function(y){
#      data <- raster::stack(y, varname=x)
#      data_total_area <- data*isimip_area
#      data_total_area_sum <- as.data.frame(raster::cellStats(data_total_area, stat='sum', na.rm=TRUE))
#      colnames(data_total_area_sum)[1]  <- "area"
#      nc <- ncdf4::nc_open(y)
#      timeref <- lubridate::year(strsplit(nc$dim[["time"]]$units, " ")[[1]][3])
#      if(ncdf4::ncvar_get(nc, nc$dim$time)[1] == 0){
#        data_total_area_sum$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time)
#      } else if (ncdf4::ncvar_get(nc, nc$dim$time)[1] != 0){
#        data_total_area_sum$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time) - 1
#      }
#      ncdf4::nc_close(nc)
#      data_total_area_sum$scenario <- strsplit(basename(y), split="_")[[1]][1]
#      data_total_area_sum$var <- x
#      return(data_total_area_sum)
#    })
#    data_crop_areas <- do.call("rbind", data_total_area_sum)
#    return(data_crop_areas)
#  })
#  data_crop_areas <- do.call("rbind", data_crop_areas)
#  
#  varnames <- c("biofuel_cropland_irrigated", "biofuel_cropland_rainfed")
#  data_bio_crop_areas <- lapply(varnames, function(x){
#    data_total_area_sum <- lapply(data_total[c(4,6,7)], function(y){
#      data <- raster::stack(y, varname=x)
#      data_total_area <- data*isimip_area
#      data_total_area_sum <- as.data.frame(raster::cellStats(data_total_area, stat='sum', na.rm=TRUE))
#      colnames(data_total_area_sum)[1]  <- "area"
#      nc <- ncdf4::nc_open(y)
#      timeref <- lubridate::year(strsplit(nc$dim[["time"]]$units, " ")[[1]][3])
#      if(ncdf4::ncvar_get(nc, nc$dim$time)[1] == 0){
#        data_total_area_sum$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time)
#      } else if (ncdf4::ncvar_get(nc, nc$dim$time)[1] != 0){
#        data_total_area_sum$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time) - 1
#      }
#      ncdf4::nc_close(nc)
#      data_total_area_sum$scenario <- strsplit(basename(y), split="_")[[1]][1]
#      data_total_area_sum$var <- x
#      return(data_total_area_sum)
#    })
#    data_crop_areas <- do.call("rbind", data_total_area_sum)
#    return(data_crop_areas)
#  })
#  data_bio_crop_areas <- do.call("rbind", data_bio_crop_areas)
#  
#  data_crop_areas <- dplyr::bind_rows(data_crop_areas, data_bio_crop_areas)
#  
#  # Turn into raster files
#  data_urban_areas <- lapply(data_urban, function(x){
#    data <- raster::stack(x)
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
#  data_urban_areas <- do.call("rbind", data_urban_areas)

## ---- eval=F------------------------------------------------------------------
#  data_ts <- dplyr::bind_rows(data_crop_areas, data_urban_areas)
#  data_ts$scenario[data_ts$scenario == "2100rcp26soc"] <- "rcp26"
#  data_ts$scenario[data_ts$scenario == "rcp26soc"] <- "rcp26"
#  data_ts$scenario[data_ts$scenario == "rcp60soc"] <- "rcp60"
#  data_ind <- data_ts[data_ts$var != "cropland_total",]
#  
#  ggplot(data = data_ind, aes(x = year, y = area/1000000, colour = factor(var), linetype=factor(scenario))) +
#    scale_colour_discrete(name="Landuse type", labels=c("Biofuel cropland irrigated", "Biofuel cropland rainfed", "Cropland irrigated", "Cropland rainfed", "Pastures", "Urban areas")) +
#    labs(x= "Year", y="Area (km² x 1,000,000)") + scale_linetype_discrete(name="Scenario") +
#    geom_line() + theme_bw() + theme(strip.background= element_blank())
#  
#  data_total <- data_ts[!data_ts$var %in% c("biofuel_cropland_irrigated",
#                                            "biofuel_cropland_rainfed",
#                                            "cropland_irrigated", "cropland_rainfed"),]
#  ggplot(data = data_total,
#         aes(x = year, y = area/1000000, colour = factor(var), linetype=factor(scenario))) +
#    scale_colour_discrete(name="Landuse type",
#                          labels=c("Cropland total", "Pastures", "Urban areas")) +
#    scale_linetype_discrete(name="Scenario") +
#    labs(x= "Year", y="Area (km² x 1,000,000)") +
#    geom_line() + theme_bw() + scale_x_continuous(breaks=c(1700,1800,1900,2000,2100,2200)) +
#    theme(strip.background= element_blank())

