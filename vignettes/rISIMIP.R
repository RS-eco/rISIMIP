## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, fig.width=14, fig.height=8, warning=FALSE, comment=NA, message=FALSE, eval=F)

## -----------------------------------------------------------------------------
#  library(rISIMIP)

## ----global_options-----------------------------------------------------------
#  # Specify path of file directory
#  filedir <- "/mnt/sda1/Documents/Wissenschaft/Data"
#  # choose.dir() # Only works on Windows

## ----read_climate, eval=FALSE-------------------------------------------------
#  # GCM, CM5A-R, historical and RCP2.6, 1970 - 2000 (Current conditions)
#  tas_1991_2000 <- readISIMIP(path=filedir, var="tas", model="GFDL-ESM2M",
#                        startyear=1991, endyear=2000)

## ----list_climate-------------------------------------------------------------
#  # List hurs files for EWEMBI from 1970 - 1999
#  hurs_1995 <- listISIMIP(path=filedir, var="hurs", model="EWEMBI",
#                         startyear=1980, endyear=2009)
#  hurs_1995

## ----install_processNC, eval=FALSE--------------------------------------------
#  # Install processNC package
#  devtools::install_github("RS-eco/processNC")

## -----------------------------------------------------------------------------
#  library(processNC)

## ----summarise_climate, eval=FALSE--------------------------------------------
#  # Create timeframe summaries
#  mean_hurs_1995 <- summariseNC(files=hurs_1995, filename1="monthly_hurs_1995.grd",
#                               format="raster", overwrite=TRUE)

## -----------------------------------------------------------------------------
#  # Turn climate data into right units (°C and mm)
#  
#  # List all temperature (tas, tasmin, tasmax) files
#  tas_files <- list.files(paste0(filedir, "/ISIMIP2b/ProcessedData/global/ewembi/"),
#                    pattern="monthly_tas_.*\\.grd", full.names=TRUE)
#  tmin_files <- list.files(paste0(filedir, "/ISIMIP2b/ProcessedData/global/ewembi/"),
#                    pattern="monthly_tasmin_.*\\.grd", full.names=TRUE)
#  tmax_files <- list.files(paste0(filedir, "/ISIMIP2b/ProcessedData/global/ewembi/"),
#                     pattern="monthly_tasmax_.*\\.grd", full.names=TRUE)
#  
#  #Convert temperature from Kelvin to ° Celsius
#  tas <- lapply(tas_files, FUN=function(x){
#    x <- raster::stack(x)
#    raster::calc(x, fun=function(x){x-273.15})
#  })
#  tmin <- lapply(tmin_files, FUN=function(x){
#    x <- raster::stack(x)
#    raster::calc(x, fun=function(x){x-273.15})
#  })
#  tmax <- lapply(tmax_files, FUN=function(x){
#    x <- raster::stack(x)
#    raster::calc(x, fun=function(x){x-273.15})
#  })
#  
#  # List precipitation files
#  prec_files <-  list.files(paste0(filedir, "/ISIMIP2b/ProcessedData/global/ewembi/"),
#                      pattern="monthly_pr_.*\\.grd", full.names=TRUE)
#  
#  # Convert precipitation from kg m-2 s-1 to kg m-2 day-1
#  prec <- lapply(prec_files, FUN=function(x){
#    x <- raster::stack(x)
#    raster::calc(x, fun=function(x){x*86400})
#  })

## ----bioclim, eval=FALSE------------------------------------------------------
#  library(dismo)
#  
#  # Create list with bioclim names
#  bioclim_names <- gsub(x = basename(prec_files), pattern = "\\monthly_pr", replacement = "bioclim")
#  
#  # Calculate bioclim variables for all models and time frames and save to file
#  bioclim <- mapply(FUN=function(x,y,z,name){
#    bio <- dismo::biovars(tmin=x, tmax=y, prec=z)
#    writeRaster(bio, filename=paste0(filedir, "/ISIMIP2b/ProcessedData/global/bioclim/", name), format="raster", overwrite=FALSE)
#    return(bio)
#    }, x=tmin, y=tmax, z=prec, name=bioclim_names)

## -----------------------------------------------------------------------------
#  bioclim_files <- list.files(paste0(filedir, "/ISIMIP2b/ProcessedData/global/bioclim/"),
#                    pattern="bioclim_.*\\.grd", full.names=TRUE)
#  bioclim <- lapply(bioclim_files, stack)

## ---- eval=FALSE--------------------------------------------------------------
#  # Install ggmap2 package from Github
#  devtools::install_github("RS-eco/ggmap2")

## -----------------------------------------------------------------------------
#  library(ggmap2)

## ---- bioclim_2050, eval=FALSE------------------------------------------------
#  # Read Bioclim data files
#  bioclim_2050 <- lapply(list.files(paste0(filedir, "ISIMIP2b/ProcessedData/bioclim"),
#                                  pattern="rcp_2050.grd", full.names=TRUE), stack)
#  
#  # Create Map of bioclim data
#  bio04_2050 <- stack(lapply(bioclim_2050, function(x) x[[4]]))
#  createMap(bioclim[[20]][[4]], name="Bio04", split=FALSE, ncol=2, width=8, height=12, units="in", filename=NA, dpi=100)

## ----landuse, eval=FALSE------------------------------------------------------
#  # Landuse histsoc
#  crops5_1985 <- readISIMIP(path=filedir, type="landuse", scenario="histsoc",
#                            var="5crops", startyear=1970, endyear=1999)
#  crops15_1985 <- readISIMIP(path=filedir, type="landuse", scenario="histsoc",
#                             var="15crops", startyear=1970, endyear=1999)
#  totals_1985 <- readISIMIP(path=filedir, type="landuse", scenario="histsoc",
#                            var="totals", startyear=1970, endyear=1999)
#  urban_1985 <- stack(readISIMIP(path=filedir, type="landuse", scenario="histsoc",
#                           var="urbanareas", startyear=1970, endyear=1999))

## ----summarise_lu, eval=FALSE-------------------------------------------------
#  # Reference data
#  crops5_1985 <- stack(lapply(crops5_1985, FUN=function(x) calc(x, mean)))
#  crops15_1985 <- stack(lapply(crops15_1985, FUN=function(x) calc(x, mean)))
#  totals_1985 <- stack(lapply(totals_1985, FUN=function(x) calc(x, mean)))
#  urban_1985 <- calc(urban_1985, mean)

## ---- eval=FALSE--------------------------------------------------------------
#  createMap(totals_1985, name="% Cover", subnames=names(crops5_1985), split=FALSE, ncol=4, width=12, height=8, units="in", dpi=100)

## ---- eval=FALSE--------------------------------------------------------------
#  lu_files <- list(crops5_1985, crops15_1985, totals_1985, urban_1985)
#  filenames <- c("crops5_histsoc_1985.tif", "crops15_histsoc_1985.tif", "totals_histsoc_1985.tif", "urbanareas_histsoc_1985.tif")
#  mapply(FUN=function(x,y) writeRaster(x=x, filename=paste0("extdata/", y), format="GTiff", overwrite=T), x=lu_files, y=filenames)

## ---- eval=FALSE--------------------------------------------------------------
#  # Landuse 2005soc - future time periods
#  totals_2005soc <- stack(readISIMIP(path=filedir, type="landuse", scenario="2005soc", var="totals", startyear=2006, endyear=2007))[[c(1,3,5,7)]]
#  urban_2005soc <- stack(readISIMIP(path=filedir, type="landuse", scenario="2005soc",
#                           var="urbanareas", startyear=2006, endyear=2007))[[1]]
#  
#  lu_files <- list(totals_2005soc, urban_2005soc)
#  filenames <- c("totals_2005soc.tif", "urbanareas_2005soc.tif")
#  mapply(FUN=function(x,y) writeRaster(x=x, filename=paste0("extdata/", y), format="GTiff", overwrite=T), x=lu_files, y=filenames)
#  
#  lu_files <- list(totals_2005soc, urban_2005soc)
#  filenames <- c("totals_2005soc.csv", "urbanareas_2005soc.csv")
#  colnames <- list(c("x", "y", "cropland_total", "pastures", "cropland_irrigated", "cropland_rainfed"), c("x", "y", "urbanareas"))
#  mapply(FUN=function(x,y,z){
#    data <- as.data.frame(rasterToPoints(x))
#    colnames(data) <- z
#    readr::write_csv(x=data, path=paste0("extdata/", y))},
#    x=lu_files, y=filenames,z=colnames)

## ----lu_future, eval=FALSE, echo=FALSE----------------------------------------
#  # Time frames rcp26
#  timeframes <- c("2020","2050","2080","2100","2150")
#  startyears <- c(2006,2036,2066,2086,2136)
#  endyears <- c(2035,2065,2095,2115,2165)
#  
#  # Only totals land use data is available
#  totals_rcp26_all <- mapply(FUN=function(x,y){
#    data <- readISIMIP(path=filedir, type="landuse", scenario="rcp26",
#                       var="totals", startyear=x, endyear=y)
#    data <- stack(lapply(data, FUN=function(x) calc(x, mean)))
#    return(data)
#  }, startyears, endyears)
#  names(totals_rcp26_all) <- timeframes
#  
#  # Urban data
#  urban_rcp26_all <- mapply(FUN=function(x,y){
#    data <- stack(readISIMIP(path=filedir, type="landuse", scenario="rcp26",
#                           var="urbanareas", startyear=x, endyear=y))
#    data <- calc(data, mean)
#    return(data)
#  }, startyears, endyears)
#  names(urban_rcp26_all) <- timeframes
#  
#  # Time frames rcp60
#  timeframes <- c("2020","2050","2080")
#  startyears <- c(2006,2036,2066)
#  endyears <- c(2035,2065,2095)
#  
#  # Only totals land use data is available
#  totals_rcp60_all <- mapply(FUN=function(x,y){
#    data <- readISIMIP(path=filedir, type="landuse", scenario="rcp60soc",
#                       var="totals", startyear=x, endyear=y)
#    data <- stack(lapply(data, FUN=function(x) calc(x, mean)))
#    return(data)
#  }, startyears, endyears)
#  names(totals_rcp60_all) <- timeframes
#  
#  # Urban data
#  urban_rcp60_all <- mapply(FUN=function(x,y){
#    data <- stack(readISIMIP(path=filedir, type="landuse", scenario="rcp60soc", var="urbanareas", startyear=x, endyear=y))
#    data <- calc(data, mean)
#    return(data)
#  }, startyears, endyears)
#  names(urban_rcp60_all) <- timeframes

## ---- eval=FALSE, echo=FALSE--------------------------------------------------
#  # Create boxplot of the different scenarios
#  library(ggplot2)
#  ggplot() + geom_boxplot(data=landuse_data, aes(x=year, y=value, fill=var,linetype=scenario))
#  ggsave("landuse_scenarios.png", dpi=300, width=12, height=6)

## ----pop_data, eval=FALSE-----------------------------------------------------
#  # Timeframes (Horizon 2050, 2080)
#  startyears <- c(2036,2066)
#  endyears <- c(2065,2095)
#  
#  population_ref <- calc(readISIMIP(path=filedir, type="population", scenario="histsoc",
#                               startyear=1970, endyear=1999), mean)
#  population_2005 <- stack(readISIMIP(path=filedir, type="population", scenario="2005soc", startyear=2010, endyear=2020))[[1]]
#  # 2005soc layers are the same for every year, so no point in summarising them.
#  
#  # ssp2soc only goes until 2100
#  population_ssp2soc <- stack(mapply(FUN=function(x,y){calc(readISIMIP(path=filedir, type="population", scenario="ssp2soc", startyear=x, endyear=y), mean)}, startyears, endyears))
#  
#  # Merge all population data
#  population_data <- stack(population_ref, population_2005, population_ssp2soc)
#  population_data <- setZ(population_data, c("1985", "2005", "2050","2080"), name="time")

## ---- eval=FALSE--------------------------------------------------------------
#  createMap(population_data, name="Population", split=TRUE, subnames=c("1985", "2005", "2050", "2080"),
#            filename="figures/population_all.tiff", ncol=1, width=8, height=12,
#            units="in", dpi=100)

