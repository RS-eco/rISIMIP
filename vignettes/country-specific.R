## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo=T, warning=F, comment=NA, message=F, eval=F)

## -----------------------------------------------------------------------------
#  # Load packages
#  library(raster)
#  library(ggplot2)
#  library(dplyr)
#  library(lubridate)
#  library(rISIMIP) # Needs  to be installed from Github:
#  library(ggmap2) # Needs to be installed from Github:
#  
#  # Set file directory of where
#  filedir <- "/media/matt/Data/Documents/Wissenschaft/Data/"
#  
#  # Specify country
#  country <- "PAK"
#  
#  # Get country outline of Pakistan
#  gadm <- raster::getData(name="GADM", country=country, level=1, path=paste0(filedir, "/GADM"))

## -----------------------------------------------------------------------------
#  # Load EWEMBI Temperature data
#  tas_files <- list.files(path=filedir, recursive=T,
#                          pattern="tas_ewembi1_", full.names = T)
#  
#  tas_gadm <- stack(lapply(tas_files, function(x){
#    tas <- raster::stack(x)
#    mask(crop(tas, gadm), gadm)
#  }))

## -----------------------------------------------------------------------------
#  #' Convert temperature into degrees
#  tas_gadm <- raster::calc(tas_gadm, fun=function(x){x-273.15})

## -----------------------------------------------------------------------------
#  # Universal UTM projection
#  tas_gadm_utm <- projectRaster(tas_gadm, to="+proj=laea +y_0=0 +lon_0=155 +lat_0=-90 +ellps=WGS84 +no_defs")

## -----------------------------------------------------------------------------
#  # Set time information of raster
#  tas_gadm <- setZ(tas_gadm, z=seq(as.Date("1979-01-01"), as.Date("2013-12-31"),
#                                   by=1), name="date")
#  
#  # Calculate 30-average (1980 - 2009)
#  tas_1995<- subset(tas_gadm, which(getZ(tas_gadm) >= as.Date('1980-01-01') &
#                                      getZ(tas_gadm) <= as.Date("2009-12-31")))
#  tas_1995 <- calc(tas_1995, mean, na.rm=TRUE)

## -----------------------------------------------------------------------------
#  # Plot map of tas_1995
#  createMap(data=tas_1995, name="tmean", outline=gadm,
#            width=8, height=9, units="in", dpi=300)

## -----------------------------------------------------------------------------
#  # Wintering season (1st Nov - 31st Jan)
#  tas_wintering <- subset(tas_gadm, which(month(getZ(tas_gadm)) %in% c(11,12,1)))
#  
#  # Breeding season (1st April - 30th June)
#  tas_breeding <- subset(tas_gadm, which(month(getZ(tas_gadm)) %in% c(4,5,6)))

## -----------------------------------------------------------------------------
#  # Calculate mean temperature value over time
#  ts_tas_gadm <- as.data.frame(cellStats(tas_gadm, stat='mean', na.rm=TRUE))
#  colnames(ts_tas_gadm) <- "tmean"
#  ts_tas_gadm$date <- getZ(tas_gadm); rm(tas_gadm)
#  
#  # Save to file
#  readr::write_csv(ts_tas_gadm, "ts_tas_gadm.csv")

## -----------------------------------------------------------------------------
#  # Read file
#  ts_tmean_gadm <- read.csv(paste0("ts_tmean_", country, ".csv"))
#  ts_tmean_gadm$date <- as.Date(ts_tmean_gadm$date)
#  
#  # Calculate monthly and annual mean temperature
#  ts_tmean_gadm$month <- month(ts_tmean_gadm$date)
#  ts_tmean_gadm$year <- year(ts_tmean_gadm$date)
#  
#  ts_month <- aggregate(tmean ~ month + year, ts_tmean_gadm, mean)
#  ts_month$date <- as_date(paste("15", ts_month$month, ts_month$year),
#                           format="%d %m %Y")
#  ts_year <- aggregate(tmean ~ year, ts_tmean_gadm, mean)
#  ts_year$date <- as_date(paste("15", "06", ts_year$year),
#                          format="%d %m %Y")
#  
#  # Plot daily, monthly and annual mean temperature
#  p1 <- ggplot(data=ts_tmean_gadm, aes(x=date, y=tmean)) +
#    geom_line() + geom_smooth(method="gam", se=TRUE) +
#    scale_x_date(date_breaks="2 years", date_labels = "%Y", expand=c(0.01,0)) +
#    labs(x="Date", y="Mean daily temperature (°C)") + theme_bw()
#  p2 <- ggplot(data=ts_month, aes(x=date, y=tmean)) + geom_line() +
#    geom_smooth(method="gam", se=TRUE) +
#    scale_x_date(date_breaks="2 years", date_labels = "%Y", expand=c(0.01,0)) +
#    labs(x="Date", y="Mean monthly temperature (°C)") + theme_bw()
#  p3 <- ggplot(data=ts_year, aes(x=date, y=tmean)) + geom_point() +
#    geom_path() + geom_smooth(method="gam", se=TRUE) +
#    scale_x_date(date_breaks="2 years", date_labels = "%Y", expand=c(0.01,0),
#                 limits=as.Date(c("1979-01-01", "2013-12-31"))) +
#    scale_y_continuous(breaks=c(19,20,21,22), limits=c(19,22)) +
#    labs(x="Year", y="Mean annual temperature (°C)") + theme_bw()
#  g <- gridExtra::grid.arrange(p1,p2,p3)
#  ggsave(paste0("tmean_", country, ".png"), g, width=10, height=8, dpi=300)
#  
#  ggplot(data=ts_year, aes(x=year, y=tmean)) + geom_point() +
#    geom_path() + geom_smooth(method="gam", se=TRUE) +
#    scale_x_continuous(breaks=seq(1979,2013, by=2)) +
#    scale_y_continuous(breaks=c(19.5,20.0, 20.5, 21.0, 21.5)) +
#    labs(x="Year", y="Mean annual temperature (°C)") + theme_bw()

## -----------------------------------------------------------------------------
#  # Get ISIMIP2b bioclim data
#  bioclim_files <- list.files(
#    paste0(filedir, "/ISIMIP2b/DerivedInputData/GCM/landonly"),
#    pattern="bioclim_.*\\.csv", full.names=TRUE, recursive=TRUE)
#  bioclim <- lapply(bioclim_files, readr::read_csv)
#  
#  # Mask by country boundaries
#  bioclim  <- lapply(bioclim, FUN=function(x){
#    data <- rasterFromXYZ(x)
#    data <- mask(crop(data, gadm), gadm)
#    as.data.frame(rasterToPoints(data))
#  })
#  
#  # Save to file
#  mapply(FUN=function(x,y){
#    readr::write_csv(x, path=gsub("landonly", country, y))
#  }, x=bioclim, y=bioclim_files)

## -----------------------------------------------------------------------------
#  #' List ISIMIP2b bio files of country
#  bioclim_files <- list.files(filedir, pattern=paste0("^bioclim_.*\\_", country, ".csv"), recursive=TRUE, full.names=TRUE)
#  
#  #' Read ISIMIP2b bio data of country and plot
#  lapply(bioclim_files, function(x){
#    data <- readr::read_csv(x)
#    # Plot bio1
#    ggplot() + geom_raster(data=data, aes(x=x, y=y, fill=bio1)) +
#      scale_fill_gradientn(colours=
#                             colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
#                                                "#7FFF7F", "yellow",
#                                                "#FF7F00", "red", "#7F0000"))(255)) +
#      geom_polygon(data=gadm, aes(x=long, y=lat, group=group),
#                   fill=NA, colour="black")
#    # Save to file
#    ggsave(sub(".csv", ".png", sub("bioclim", "bio1", x)),
#           dpi=300, width=8, height=6)
#  })

## ----landuse------------------------------------------------------------------
#  ## Landuse histsoc
#  
#  # Get and join data
#  histsoc <- append(readISIMIP(path=filedir, type="landuse", scenario="histsoc", var="totals", startyear=1861, endyear=2005), list(readISIMIP(path=filedir, type="landuse", scenario="histsoc", var="urbanareas", startyear=1861, endyear=2005)))
#  names(histsoc)[5] <- "urbanareas"
#  
#  # Crop and mask data
#  histsoc <- lapply(histsoc, function(x) mask(crop(x, gadm), gadm))
#  
#  # Turn into dataframe
#  histsoc <- lapply(1:length(histsoc), function(x){
#    data <- as.data.frame(rasterToPoints(histsoc[[x]])) %>% tidyr::gather(year, value, -c(x,y))
#    colnames(data)[4] <- names(histsoc)[x]
#    return(data)
#  })
#  histsoc <- Reduce(function(...) dplyr::left_join(..., by=c("x","y","year"), all.x=TRUE), histsoc)
#  
#  # Turn years into numeric
#  histsoc$year <- as.numeric(sub("X", "", histsoc$year))
#  colnames(histsoc)
#  
#  # Save to file
#  readr::write_csv(histsoc, "histsoc_landuse_pak.csv")
#  
#  ## Landuse 2005soc
#  
#  # Read and join data
#  soc2005 <- stack(readISIMIP(path=filedir, type="landuse", scenario="2005soc", var="totals"), readISIMIP(path=filedir, type="landuse", scenario="2005soc", var="urbanareas"))
#  names(soc2005) <- c("cropland_irrigated", "cropland_rainfed", "cropland_total", "pastures", "urbanareas")
#  
#  # Crop and mask data
#  soc2005 <- mask(crop(soc2005, gadm), gadm)
#  soc2005 <- as.data.frame(rasterToPoints(soc2005))
#  
#  # Save to file
#  readr::write_csv(soc2005, "2005soc_landuse_pak.csv")
#  
#  ## Landuse RCP2.6
#  
#  # Totals & Urban data
#  rcp26 <- lapply(c("GFDL-ESM2M", "HadGEM2-ES", "IPSL-CM5A-LR", "MIROC5"), function(model){
#    # Read data
#    data <- append(readISIMIP(path=filedir, type="landuse", scenario="rcp26", model=model, var="totals", startyear=2006, endyear=2099), list(readISIMIP(path=filedir, type="landuse", scenario="rcp26", model=model, var="urbanareas", startyear=2006, endyear=2099)))
#    names(data)[5] <- "urbanareas"
#  
#    # Crop data
#    data <- lapply(data, function(x) mask(crop(x, gadm), gadm))
#    # Turn into dataframe
#    colname <- names(data)
#    data <- lapply(1:length(data), function(x){
#      data <- as.data.frame(rasterToPoints(data[[x]])) %>% tidyr::gather(year, value, -c(x,y))
#      colnames(data)[4] <- colname[x]
#      return(data)
#    })
#    data <- Reduce(function(...) dplyr::left_join(..., by=c("x","y","year"), all.x=TRUE), data)
#  
#    # Turn years into numeric
#    data$year <- as.numeric(sub("X", "", data$year))
#  
#    # Add model column
#    data$model <- model
#    return(data)
#  })
#  rcp26 <- do.call("rbind", rcp26)
#  
#  # Save to file
#  readr::write_csv(rcp26, "rcp26soc_landuse_pak.csv")
#  
#  ## Landuse RCP6.0
#  
#  rcp60 <- lapply(c("GFDL-ESM2M", "HadGEM2-ES", "IPSL-CM5A-LR", "MIROC5"), function(model){
#    # Read data
#    data <- append(readISIMIP(path=filedir, type="landuse", scenario="rcp60", model=model, var="totals", startyear=2006, endyear=2099), list(readISIMIP(path=filedir, type="landuse", scenario="rcp60", model=model, var="urbanareas", startyear=2006, endyear=2099)))
#    names(data)[5] <- "urbanareas"
#  
#    # Crop data
#    data <- lapply(data, function(x) mask(crop(x, gadm), gadm))
#    # Turn into dataframe
#    colname <- names(data)
#    data <- lapply(1:length(data), function(x){
#      data <- as.data.frame(rasterToPoints(data[[x]])) %>% tidyr::gather(year, value, -c(x,y))
#      colnames(data)[4] <- colname[x]
#      return(data)
#    })
#    data <- Reduce(function(...) dplyr::left_join(..., by=c("x","y","year"), all.x=TRUE), data)
#  
#    # Turn years into numeric
#    data$year <- as.numeric(sub("X", "", data$year))
#  
#    # Add model column
#    data$model <- model
#    return(data)
#  })
#  rcp60 <- do.call("rbind", rcp60)
#  
#  # Save to file
#  readr::write_csv(rcp60, "rcp60soc_landuse_pak.csv")
#  
#  ## Landuse 2100RCP2.6
#  rcp26_2100 <- lapply(c("GFDL-ESM2M", "HadGEM2-ES", "IPSL-CM5A-LR", "MIROC5"), function(model){
#    # Read data
#    data <- append(readISIMIP(path=filedir, type="landuse", scenario="rcp26", model=model, var="totals", startyear=2100, endyear=2299), list(readISIMIP(path=filedir, type="landuse", scenario="rcp26", model=model, var="urbanareas", startyear=2100, endyear=2299)))
#    names(data)[5] <- "urbanareas"
#  
#    # Crop data
#    data <- lapply(data, function(x) mask(crop(x, gadm), gadm))
#    # Turn into dataframe
#    colname <- names(data)
#    data <- lapply(1:length(data), function(x){
#      data <- as.data.frame(rasterToPoints(data[[x]])) %>% tidyr::gather(year, value, -c(x,y))
#      colnames(data)[4] <- colname[x]
#      return(data)
#    })
#    data <- Reduce(function(...) dplyr::left_join(..., by=c("x","y","year"), all.x=TRUE), data)
#  
#    # Turn years into numeric
#    data$year <- as.numeric(sub("X", "", data$year))
#  
#    # Add model column
#    data$model <- model
#    return(data)
#  })
#  rcp26_2100 <- do.call("rbind", rcp26_2100)
#  
#  # Save to file
#  readr::write_csv(rcp26_2100, "2100rcp26soc_landuse_pak.csv")

## -----------------------------------------------------------------------------
#  library(ggmap2)
#  ggmap2(totals_1985_df, name="% Cover", subnames=names(crops5_1985), split=FALSE, ncol=4, width=12, height=8, units="in", dpi=100)

## ----landuse_summary_gadm-----------------------------------------------------
#  # Merge historic and future data
#  totals_future_df
#  landuse_data <- rbind(totals_1985_df, totals_future_df)
#  rm(totals_1985_df, totals_future_df)
#  
#  # Create boxplot of the different scenarios
#  library(ggplot2)
#  ggplot() + geom_boxplot(data=landuse_data,
#                          aes(x=year, y=value, fill=var, linetype=scenario));rm(landuse_data)

## -----------------------------------------------------------------------------
#  # Climate models
#  models <- c("gfdl-esm2m", "ipsl-cm5a-lr", "miroc5")
#  
#  # Process discharge data
#  library(processNC)
#  dist_list_pak <- lapply(models, FUN=function(x){
#    #' Load ISIMIP2b Discharge data
#    dis_global <- list.files(paste0("E:/Data/ISIMIP2b/OutputData/mpi-hm/", x),
#                             pattern="dis_global", full.names = T)
#    dis_picontrol_2005soc_2050 <- summariseNC(files=dis_global[1:4], startyear=2036, extent=gadm, endyear=2065, filename1=paste0("mpi-hm_", x, "_picontrol_2005soc_co2_dis_", country, "_monthly_2050.grd"), format="raster")
#    dis_picontrol_2005soc_2080 <- summariseNC(files=dis_global[4:7], startyear=2066, extent=gadm, endyear=2095, filename1=paste0("mpi-hm_", x, "_picontrol_2005soc_co2_dis_", country, "_monthly_2080.grd"), format="raster")
#    dis_picontrol_histsoc_1985 <- summariseNC(files=dis_global[8:11], startyear=1970, extent=gadm, endyear=1999, filename1=paste0("mpi-hm_", x, "_picontrol_histsoc_co2_dis_", country, "_monthly_1985.grd"), format="raster")
#    dis_rcp26_2005soc_2050 <- summariseNC(files=dis_global[12:15], startyear=2036, extent=gadm, endyear=2065, filename1=paste0("mpi-hm_", x, "_rcp26_2005soc_co2_dis_", country, "_monthly_2050.grd"), format="raster")
#    dis_rcp26_2005soc_2080 <- summariseNC(files=dis_global[15:18], startyear=2066, extent=gadm, endyear=2095, filename1=paste0("mpi-hm_", x, "_rcp26_2005soc_co2_dis_", country, "_monthly_2080.grd"), format="raster")
#    dis_rcp60_2005soc_2050 <- summariseNC(files=dis_global[19:22], startyear=2036, extent=gadm, endyear=2065, filename1=paste0("mpi-hm_", x, "_rcp60_2005soc_co2_dis_", country, "_monthly_2050.grd"), format="raster")
#    dis_rcp60_2005soc_2080 <- summariseNC(files=dis_global[22:25], startyear=2066, extent=gadm, endyear=2095, filename1=paste0("mpi-hm_", x, "_rcp60_2005soc_co2_dis_", country, "_monthly_2080.grd"), format="raster")
#  
#    # Create list of files
#    dis_list <- list(dis_picontrol_histsoc_1985, dis_picontrol_2005soc_2050,
#                     dis_picontrol_2005soc_2080, dis_rcp26_2005soc_2050,
#                     dis_rcp26_2005soc_2080, dis_rcp60_2005soc_2050,
#                     dis_rcp60_2005soc_2080)
#  
#    # Calculate annual sum
#    dis_list_gadm <- stack(lapply(dis_list, function(x) calc(x, sum)))
#    names(dis_list_gadm) <- c("picontrol_histsoc_1985", "picontrol_2005soc_2050",
#                              "picontrol_2005soc_2080", "rcp26_2005soc_2050",
#                              "rcp26_2005soc_2080", "rcp60_2005soc_2050",
#                              "rcp60_2005soc_2080")
#    rasterVis::levelplot(dis_list_gadm, par.settings=rasterVis::rasterTheme(region=rev(hexbin::BTC(n=9))),
#                         layout=c(4,2), main="Discharge")
#    return(dis_list_gadm)
#  })

## -----------------------------------------------------------------------------
#  library(ggplot2)
#  discharge_files <- list.files("E:/Data/ISIMIP2b/DerivedOutputData/",
#                                pattern=".grd", full.names=TRUE)
#  lapply(1:length(discharge_files), function(i){
#    discharge <- stack(discharge_files[i])
#    discharge_df <- as.data.frame(rasterToPoints(discharge))
#    colnames(discharge_df) <- c("x", "y", month.abb)
#    ggplot() + geom_raster(data=discharge_df, aes(x=x, y=y, fill=Jul)) +
#      scale_fill_gradientn(colours=
#                             colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
#                                                "#7FFF7F", "yellow",
#                                                "#FF7F00", "red", "#7F0000"))(255))
#    ggsave(sub(pattern=".grd", ".png", discharge_files[i]), width=8, height=6, dpi=300)
#    readr::write_csv(discharge_df, sub(pattern=".grd", ".csv", discharge_files[i]))
#  })
#  file.remove(discharge_files)
#  file.remove(sub(pattern=".grd", ".gri", discharge_files))

