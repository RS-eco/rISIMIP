## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo=T, warning=F, comment=NA, message=F, eval=T)

## ---- eval=FALSE--------------------------------------------------------------
#  # Install remotes if not previously installed
#  if(!"remotes" %in% installed.packages()[,"Package"]) install.packages("remotes")
#  
#  # Install rISIMIP from Github if not previously installed
#  if(!"rISIMIP" %in% installed.packages()[,"Package"]) remotes::install_github("RS-eco/rISIMIP")

## -----------------------------------------------------------------------------
library(rISIMIP)

## ----global_options-----------------------------------------------------------
# Specify path of file directory
filedir <- "I:/"

## ----install_processNC--------------------------------------------------------
# Install processNC from Github if not previously installed
if(!"processNC" %in% installed.packages()[,"Package"]) remotes::install_github("RS-eco/processNC")

## ----load_processNC-----------------------------------------------------------
library(processNC)

## -----------------------------------------------------------------------------
#Timeframes
timeframe <- c("1995","2000","2005","2050","2080")
startyear <- c(1980,1985,1990,2036,2066)
endyear <- c(2009,2014,2019,2065,2095)
timeperiods <- data.frame(timeframe=timeframe, startyear=startyear,endyear=endyear)

#Climate variables
vars <- c("pr", "tasmax", "tasmin")

#Climate models
models <- c("GFDL-ESM4", "IPSL-CM6A-LR", "MPI-ESM1-2-HR", "MRI-ESM2-0", "UKESM1-0-LL")

#SSP scenarios
ssps <- c("ssp126", "ssp370", "ssp585")

#Create list of variable, climate model and time frame combination
var_mod_time <- expand.grid(var = vars, model = models, 
                            timeframe = timeframe[4:5], ssp = ssps)

# Add historical scenario
df <- expand.grid(ssp="historical", var=vars, model=models, timeframe = c("1995", "2000"))
var_mod_time <- rbind(df, var_mod_time)

# Add GSWP3-W5E5 scenario
df <- expand.grid(ssp="obsclim", var=vars, model="GSWP3-W5E5", timeframe=c("1995", "2000", "2005"))
var_mod_time <- rbind(df, var_mod_time)
rm(vars, models, timeframe, ssps)

var_mod_time <- dplyr::left_join(var_mod_time, timeperiods, by="timeframe"); rm(timeperiods)

## ---- eval=F------------------------------------------------------------------
#  # Create output directory
#  dir.create(paste0(filedir, "/ISIMIP3b/DerivedInputData/GCM/global/"))
#  
#  # Run summariseNC for all combinations
#  lapply(1:nrow(var_mod_time), FUN=function(x){
#    files <- listISIMIP(path=filedir, var=var_mod_time$var[x], extent="global",
#                        model=var_mod_time$model[x], version="ISIMIP3b",
#                        scenario=var_mod_time$ssp[x], type="GCM",
#                        startyear=var_mod_time$startyear[x],
#                        endyear=var_mod_time$endyear[x])
#    filename1 <- paste0(filedir, "/ISIMIP3b/DerivedInputData/GCM/global/",
#                        var_mod_time$ssp[x], "/monthly_",
#                        var_mod_time$var[x], "_", var_mod_time$model[x], "_",
#                        var_mod_time$ssp[x], "_", var_mod_time$timeframe[x],
#                        ".nc")
#    if(length(files)==4){
#      if(!file.exists(filename1)){
#        data_sub <- summariseNC(files=files,
#                                startdate=var_mod_time$startyear[x],
#                                enddate=var_mod_time$endyear[x],
#                                cores=round(0.75*parallel::detectCores()),
#                                filename1=filename1, overwrite=FALSE)
#      }
#    }
#    print(round(x/nrow(var_mod_time)*100,2))
#  })

## ----filelist-----------------------------------------------------------------
#List all tasmin and tasmax files
tmin_files <- list.files(
  paste0(filedir, "/ISIMIP3b/DerivedInputData/GCM/global/"),
  pattern="monthly_tasmin_.*\\.nc", full.names=T, recursive=T)
tmax_files <- list.files(
  paste0(filedir, "/ISIMIP3b/DerivedInputData/GCM/global/"), 
  pattern="monthly_tasmax_.*\\.nc", full.names=T, recursive=T)

# List precipitation files
prec_files <-  list.files(
  paste0(filedir, "/ISIMIP3b/DerivedInputData/GCM/global/"),
  pattern="monthly_pr_.*\\.nc", full.names=T, recursive=T)

# Select certain years
years <- unique(var_mod_time$timeframe)

tmin_files <- unlist(lapply(years, function(x) tmin_files[grep(tmin_files, pattern=x)]))
tmax_files <- unlist(lapply(years, function(x) tmax_files[grep(tmax_files, pattern=x)]))
prec_files <- unlist(lapply(years, function(x) prec_files[grep(prec_files, pattern=x)]))

head(tmin_files); tail(tmin_files); length(tmin_files)

# Check tmin, tmax and prec files are identical, 
#not just same number of files

## ----landonly, eval=F---------------------------------------------------------
#  # Read landonly mask
#  data("landseamask_generic", package="rISIMIP")
#  
#  # Mask data by landonly mask
#  library(raster)
#  tmin_lo <- lapply(tmin_files, FUN=function(x) mask(stack(x), landseamask_generic))
#  tmax_lo <- lapply(tmax_files, FUN=function(x) mask(stack(x), landseamask_generic))
#  prec_lo <- lapply(prec_files, FUN=function(x) mask(stack(x), landseamask_generic))
#  
#  plot(tmin_lo[[5]])
#  plot(tmax_lo[[5]])
#  plot(prec_lo[[5]])
#  
#  # Merge lists into one list
#  data_lo <- c(tmin_lo, tmax_lo, prec_lo)
#  data_files <- c(tmin_files, tmax_files, prec_files)
#  
#  # Create Output directories
#  paste0(filedir, "/ISIMIP3b/DerivedInputData/GCM/landonly/", c("historical", "obsclim", "ssp126", "ssp370", "ssp585"))
#  
#  # Save to file in landonly subfolder
#  mapply(FUN=function(x,y){
#    filename <- sub(".nc", "_landonly.nc", gsub("global", "landonly", y))
#    if(!file.exists(filename)){
#      x <- stack(x)
#      #x <- as.data.frame(rasterToPoints(x))
#      #colnames(x) <- c("x", "y", month.abb)
#      raster::writeRaster(x, filename=filename, format="CDF",
#                          xname="lon", yname="lat", zname="time",
#                          zunit="years since 1661-1-1 00:00:00",
#                          force_v4=TRUE, compression=9)
#    }
#  }, x=data_lo, y=data_files)

## ----units, eval=F------------------------------------------------------------
#  #Turn climate data into right units (degree Celsius and mm)
#  
#  #Convert temperature from Kelvin to degree Celsius
#  tmin_lo <- lapply(tmin_lo, FUN=function(x){
#    raster::calc(x, fun=function(x){x-273.15})
#  })
#  tmax_lo <- lapply(tmax_lo, FUN=function(x){
#    raster::calc(x, fun=function(x){x-273.15})
#  })
#  
#  # Convert precipitation from kg m-2 s-1 to kg m-2 day-1
#  prec_lo <- lapply(prec_lo, FUN=function(x){
#    raster::calc(x, fun=function(x){x*86400})
#  })
#  
#  plot(tmin_lo[[1]][[1]])
#  plot(tmax_lo[[1]][[1]])
#  plot(prec_lo[[1]][[1]])

## ----bioclim, eval=F----------------------------------------------------------
#  library(raster)
#  
#  # Create list with bioclim names
#  bioclim_names <- gsub(x = prec_files, pattern = "\\monthly_pr",
#                        replacement = "bioclim")
#  bioclim_names <- sub(".nc", "_landonly.nc",
#                       gsub("global", "landonly", bioclim_names))
#  
#  # Calculate bioclim variables for all models and time frames and save to file
#  bioclim <- mapply(FUN=function(x,y,z,name){
#    if(!file.exists(name)){
#      bio <- dismo::biovars(tmin=x, tmax=y, prec=z)
#      raster::writeRaster(bio, filename=name, format="CDF",
#                          xname="lon", yname="lat", zname="time",
#                          zunit="years since 1661-1-1 00:00:00",
#                          force_v4=TRUE, compression=9)
#    }
#  }, x=tmin_lo, y=tmax_lo, z=prec_lo, name=bioclim_names)

## -----------------------------------------------------------------------------
bioclim_files <- list.files(
  paste0(filedir, "/ISIMIP3b/DerivedInputData/GCM/landonly"),
  pattern="bioclim_.*\\.nc", full.names=T, recursive=T)
bioclim <- lapply(bioclim_files, raster::stack)

# Need to implement bioclim_names here!
#bioclim_names 

# List internal bioclim files
#(bioclim_files <- list.files("data", pattern="bioclim_.*\\landonly.rda", 
#                            full.names=T, recursive=T))

## ---- eval=F------------------------------------------------------------------
#  library(raster); library(readr); library(ggplot2)
#  tmin_files <- list.files(paste0(filedir, "ISIMIP3b/DerivedInputData/GCM/landonly"),
#                           pattern="monthly_tasmin_.*\\.nc", full.names=TRUE, recursive=T)
#  for(i in 1:length(tmin_files)){
#    tasmin <- stack(tmin_files[i])
#    tasmin_df <- as.data.frame(rasterToPoints(tasmin))
#    colnames(tasmin_df) <- c("x", "y", month.abb)
#    ggplot() + geom_raster(data=tasmin_df, aes(x=x, y=y, fill=Jul)) +
#      scale_fill_gradientn(colours=
#                             colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
#                                                "#7FFF7F", "yellow",
#                                                "#FF7F00", "red", "#7F0000"))(255))
#    ggsave(sub(pattern=".nc", ".png", tmax_files[i]))
#    readr::write_csv(tasmin_df, sub(pattern=".nc", ".csv.xz", tmax_files[i]))
#  }
#  
#  bioclim_files <- list.files(paste0(filedir, "ISIMIP3b/DerivedInputData/GCM/landonly"),
#                              pattern="bioclim_.*\\.nc", full.names=TRUE, recursive=T)
#  for(i in 1:length(bioclim_files)){
#    bioclim <- stack(bioclim_files[i])
#    bioclim_df <- as.data.frame(rasterToPoints(bioclim))
#    colnames(bioclim_df) <- c("x", "y", paste0("bio", 1:19))
#    ggplot() + geom_tile(data=bioclim_df, aes(x=x, y=y, fill=bio5)) +
#      scale_fill_gradientn(colours=
#                             colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
#                                                "#7FFF7F", "yellow",
#                                                "#FF7F00", "red", "#7F0000"))(255)) +
#      geom_sf()
#    ggsave(sub(pattern=".nc", ".png", bioclim_files[i]))
#    readr::write_csv(bioclim_df, sub(pattern=".nc", ".csv.xz", bioclim_files[i]))
#  }

## ---- eval=F------------------------------------------------------------------
#  bioclim_1995 <- read.csv(list.files(
#    paste0(filedir, "/ISIMIP3b/DerivedInputData/GCM/landonly"),
#    pattern="bioclim_GSWP3-W5E5_obsclim_1995.*\\.csv.xz",
#    full.names=T, recursive=T))[,c("x", "y", "bio4", "bio5", "bio12", "bio15", "bio18", "bio19")]
#  bioclim_1995$year <- 1995
#  bioclim_1995 <- tidyr::gather(bioclim_1995, var, value, -c(x,y,year))
#  bioclim_1995 <- tidyr::spread(bioclim_1995, year, value)
#  
#  bioclim_fut <- c(list.files(
#    paste0(filedir, "/ISIMIP3b/DerivedInputData/GCM/landonly"),
#    pattern="bioclim_.*2050.*\\.csv.xz", full.names=T, recursive=T), list.files(
#      paste0(filedir, "/ISIMIP3b/DerivedInputData/GCM/landonly"),
#      pattern="bioclim_.*2080.*\\.csv.xz", full.names=T, recursive=T))
#  bioclim_fut <- lapply(bioclim_fut, function(x){
#    data <- read.csv(x)
#    data$year <- strsplit(basename(x), split="_")[[1]][4]
#    data$model <- strsplit(basename(x), split="_")[[1]][2]
#    data$scenario <- strsplit(basename(x), split="_")[[1]][3]
#    return(data)
#  })
#  bioclim_fut <- do.call("rbind", bioclim_fut)
#  
#  library(dplyr); library(ggplot2); library(patchwork)
#  bioclim_fut <- bioclim_fut %>%
#    dplyr::select(c(x,y,model,scenario,year,bio4,bio5,bio12,bio15,bio18,bio19))
#  bioclim_fut <- tidyr::gather(bioclim_fut, var, value, -c(x,y,model,scenario,year))
#  bioclim_fut <- tidyr::spread(bioclim_fut, year, value)
#  
#  # Calculate delta climate
#  bioclim_all <- left_join(bioclim_fut, bioclim_1995, by=c("x", "y", "var"))
#  delta_climate <- bioclim_all %>%
#    mutate_at(vars(`2050`:`2080`), list(~.-bioclim_all$`1995`)) %>% dplyr::select(-c(`1995`))
#  delta_climate <- tidyr::gather(delta_climate, year, value, -c(x,y,model,scenario,var))
#  delta_climate <- delta_climate %>% group_by(x,y,scenario,var, year) %>%
#    summarise(value=mean(value, na.rm=TRUE))
#  
#  #Subset data for plotting
#  lapply(c("2050", "2080"), function(x){
#    climate <- delta_climate[delta_climate$year == x,]
#    climate <- climate %>% tidyr::unite(year, scenario, col="time_rcp")
#    climate$time_rcp <- factor(climate$time_rcp, labels=c(paste0(x, " ssp126"),
#                                                          paste0(x, " ssp370"),
#                                                          paste0(x, " ssp585")))
#    data(outline, package="ggmap2")
#    p1 <- ggplot() +
#      geom_raster(data=climate[climate$var == "bio4",], aes(x=x, y=y, fill=value)) +
#      facet_wrap(~ time_rcp, ncol=3) +
#      geom_sf(data=outline, fill="transparent", colour="black") +
#      scale_fill_gradientn(name="Temperature \nseasonality", colours=rev(colorRampPalette(
#        c("#00007F", "blue", "#007FFF", "cyan", "white", "yellow",
#          "#FF7F00", "red", "#7F0000"))(255)), values=scales::rescale(unique(c(seq(min(climate$value[climate$var == "bio4"]), 0, length=5), seq(0, max(climate$value[climate$var == "bio4"]), length=5)))), na.value="transparent") +
#      theme_classic() + theme(axis.title = element_blank(), axis.line = element_blank(),
#                              axis.ticks = element_blank(), axis.text = element_blank(),
#                              panel.grid = element_blank(),
#                              strip.background= element_blank(),
#                              strip.placement = "outside",
#                              strip.text = element_text(size=10, face="bold"),
#                              rect = element_rect(fill = "transparent")) +
#      coord_sf(xlim=c(-180,180), ylim=c(-60,85), expand=FALSE)
#    p2 <- ggplot() +
#      geom_raster(data=climate[climate$var == "bio12",], aes(x=x, y=y, fill=value)) +
#      facet_wrap(~ time_rcp, ncol=3) +
#      geom_sf(data=outline, fill="transparent", colour="black") +
#      scale_fill_gradientn(name="Annual \nprecipitation", colours=colorRampPalette(
#        c("#00007F", "blue", "#007FFF", "cyan", "white", "yellow",
#          "#FF7F00", "red", "#7F0000"))(255),
#        values=scales::rescale(unique(c(seq(min(climate$value[climate$var == "bio12"]),
#                                            0, length=5), seq(0, max(climate$value[climate$var == "bio12"]), length=5)))), na.value="transparent") +
#      theme_classic() + theme(axis.title = element_blank(),axis.line = element_blank(),
#                              axis.ticks = element_blank(), axis.text = element_blank(),
#                              panel.grid = element_blank(),
#                              strip.background= element_blank(),
#                              strip.placement = "outside",
#                              strip.text = element_blank(),
#                              rect = element_rect(fill = "transparent")) +
#      coord_sf(xlim=c(-180,180), ylim=c(-60,85), expand=FALSE)
#    p3 <- ggplot() +
#      geom_raster(data=climate[climate$var == "bio19",], aes(x=x, y=y, fill=value)) +
#      facet_wrap(~ time_rcp, ncol=3) +
#      geom_sf(data=outline, fill="transparent", colour="black") +
#      scale_fill_gradientn(name="Precipitation \nof coldest \nquarter",
#                           colours=colorRampPalette(
#                             c("#00007F", "blue", "#007FFF", "cyan", "white", "yellow",
#                               "#FF7F00", "red", "#7F0000"))(255), values=scales::rescale(unique(c(seq(min(climate$value[climate$var == "bio19"]), 0, length=5), seq(0, max(climate$value[climate$var == "bio19"]), length=5)))), na.value="transparent") +
#      theme_classic() + theme(axis.title = element_blank(),axis.line = element_blank(),
#                              axis.ticks = element_blank(), axis.text = element_blank(),
#                              panel.grid = element_blank(),
#                              strip.background= element_blank(),
#                              strip.placement = "outside", strip.text = element_blank(),
#                              rect = element_rect(fill = "transparent")) +
#      coord_sf(xlim=c(-180,180), ylim=c(-60,85), expand=FALSE)
#  
#    # Turn plots into grob elements
#    p <- p1 / p2 / p3
#    ggsave(filename=paste0("figures/top_clim_change_", x, ".png"), p,
#           width=14, height=6, unit="in", dpi=600)
#    return(NULL)
#  })

## ---- eval=F------------------------------------------------------------------
#  lapply(c("2050", "2080"), function(time){
#    climate <- delta_climate[delta_climate$year == time,]
#    climate <- climate %>% tidyr::unite(year, scenario, col="time_rcp")
#    climate$time_rcp <- factor(climate$time_rcp, labels=c(paste0(time, " ssp126"),
#                                                          paste0(time, " ssp370"),
#                                                          paste0(time, " ssp585")))
#    data(outline, package="ggmap2")
#     p1 <- ggplot() +
#      geom_raster(data=climate[climate$var == "bio5",], aes(x=x, y=y, fill=value)) +
#      facet_wrap(~ time_rcp, ncol=3) +
#      geom_sf(data=outline,fill="transparent", colour="black") +
#      scale_fill_gradientn(name="Maximum \ntemperature", colours=rev(colorRampPalette(
#        c("#00007F", "blue", "#007FFF", "cyan", "white", "yellow",
#          "#FF7F00", "red", "#7F0000"))(255)),
#        values=scales::rescale(unique(c(seq(min(climate$value[climate$var == "bio5"]), 0, length=5),
#                                        seq(0, max(climate$value[climate$var == "bio5"]), length=5)))),
#        na.value="transparent") +
#      theme_classic() + theme(axis.title = element_blank(),axis.line = element_blank(),
#                              axis.ticks = element_blank(), axis.text = element_blank(),
#                              panel.grid = element_blank(), strip.background= element_blank(),
#                              strip.placement = "outside",
#                              strip.text = element_text(size=10, face="bold"),
#                              rect = element_rect(fill = "transparent")) +
#      coord_sf(xlim=c(-180,180), ylim=c(-60,85), expand=FALSE)
#    p2 <- ggplot() +
#      geom_raster(data=climate[climate$var == "bio15",], aes(x=x, y=y, fill=value)) +
#      facet_wrap(~ time_rcp, ncol=3) +
#      geom_sf(data=outline, fill="transparent", colour="black") +
#      scale_fill_gradientn(name="Precipitation \nseasonality", colours=colorRampPalette(
#        c("#00007F", "blue", "#007FFF", "cyan", "white", "yellow",
#          "#FF7F00", "red", "#7F0000"))(255), values=scales::rescale(unique(c(seq(min(climate$value[climate$var == "bio15"]), 0, length=5), seq(0, max(climate$value[climate$var == "bio15"]), length=5)))), na.value="transparent") +
#      theme_classic() + theme(axis.title = element_blank(),axis.line = element_blank(),
#                              axis.ticks = element_blank(), axis.text = element_blank(),
#                              panel.grid = element_blank(), strip.background= element_blank(),
#                              strip.placement = "outside", strip.text = element_blank(),
#                              rect = element_rect(fill = "transparent")) +
#      coord_sf(xlim=c(-180,180), ylim=c(-60,85), expand=FALSE)
#    p3 <- ggplot() +
#      geom_raster(data=climate[climate$var == "bio18",], aes(x=x, y=y, fill=value)) +
#      facet_wrap(~ time_rcp, ncol=3) +
#      geom_sf(data=outline, fill="transparent", colour="black") +
#      scale_fill_gradientn(name="Precipitation \nof warmest \nquarter",
#                           colours=colorRampPalette(
#                             c("#00007F", "blue", "#007FFF", "cyan", "white", "yellow",
#                               "#FF7F00", "red", "#7F0000"))(255), values=scales::rescale(unique(c(seq(min(climate$value[climate$var == "bio18"]), 0, length=5), seq(0, max(climate$value[climate$var == "bio18"]), length=5)))), na.value="transparent") +
#      theme_classic() + theme(axis.title = element_blank(),axis.line = element_blank(),
#                              axis.ticks = element_blank(), axis.text = element_blank(),
#                              panel.grid = element_blank(), strip.background= element_blank(),
#                              strip.placement = "outside", strip.text = element_blank(),
#                              rect = element_rect(fill = "transparent")) +
#      coord_sf(xlim=c(-180,180), ylim=c(-60,85), expand=FALSE)
#  
#    # Turn plots into grob elements
#    p <- p1 / p2 / p3
#    ggsave(filename=paste0("figures/low_clim_change_", time, ".png"), p, width=14, height=6,
#           unit="in", dpi=600)
#    return(NULL)
#  })

