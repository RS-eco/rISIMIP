#' Download ISIMIP environmental Data from Server
#'
#' Download and read ISIMIP Data
#' 
#' @param version Version of ISIMIP data, default is ISIMIP2b, can be one of ISIMIP2b, ISIMIP3a, ISIMIP3b
#' @param type One of EWEMBI, GCM, landuse or population, 
#' to specify which type of data you want to use.
#' @param extent Extent of data, either global or landonly
#' @param model A character string specifying the Global Climate Model used
#' @param scenario A character string specifying the scenario, either histsoc, 2005soc, rcp26, rcp60 or ssp2soc
#' @param startyear Startyear of timeperiod for required data
#' @param endyear Endyear of timeperiod for required data
#' @param var A character string specifying the variable to use (tas, tmin, tmax, huss, hurss, pr, ...)
#' @param download Logical. If TRUE data will be downloaded if not locally available
#' @param path Character. Path name indicating where to store data. Default is the current working directory
#' @param username Character. Username of ...
#' @param password Character. Corresponding password
#' 
#' @return raster stack or list of raster stacks with all the data 
#' @examples
#' \dontrun{
#' getISIMIP()
#' }
#' @export
rsync <- function(from, to, pattern = ""){
  system(paste("rsync -outi", from, to, sep = " "))
}  
# Use r sync to download data from rsync.pik-potsdam.de.
# Need to request password and implement code.

# SCP works with Ubuntu and internal ISIMIP Account
scp <- function(from="b380501@mistralpp.dkrz.de:/work/bb0820/ISIMIP/ISIMIP2b/InputData/GCM_atmosphere/
                  biascorrected/landonly/piControl/HadGEM2-ES/pr_*_188*.nc4", 
                to="/home/mabi/Documents/Wissenschaft/Data/ISIMIP2b/InputData/landonly/piControl/HadGEM2-ES"){
  system(paste("scp -r", from, to, sep= " "))  
}
# Need to add password option
# sshpass -p "password" scp -r user@example.com:/some/remote/path /some/local/path
# sshpass -f "/path/to/passwordfile" scp -r user@example.com:/some/remote/path /some/local/path

getISIMIP <- function(version="ISIMIP2b", type="GCM", extent="landonly", 
                      model="IPSL-CM5A-LR", scenario="rcp26", startyear=2006,
                      endyear=2010, var="tas", download=TRUE, path=getwd()){
  if(version == "ISIMIP2b"){
    # List and read required files
    if("EWEMBI" == type){
      files <- list.files(path=path, pattern=paste0(var, "_ewembi1_"),
                          recursive=T, full.names=T)
    } else if("GCM" == type){
      if(startyear <= 2006){
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(var, "_day_", model, "_historical_"))
        if(endyear >= 2006){
          files2 <- list.files(path=path, recursive=T, full.names=T,
                               pattern=paste0(var, "_day_", model, "_", scenario))
          files <- append(files, files2); rm(files2)
        }
      } else{
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(var, "_day_", model, "_", scenario))
      }
      if(extent=="landonly"){
        start <- sapply(files, FUN=function(x) substr(strsplit(x, "_landonly_")[[1]][2], 1, 4))
        end <- sapply(files, FUN=function(x) substr(strsplit(x, "_landonly_")[[1]][2], 10, 13))
      } else{
        start <- sapply(files, FUN=function(x) substr(strsplit(x, "_EWEMBI_")[[1]][2], 1, 4))
        end <- sapply(files, FUN=function(x) substr(strsplit(x, "_EWEMBI_")[[1]][2], 10, 13))
      }
      files <- files[end >= startyear & start <= endyear]
      data <- raster::stack(lapply(files, FUN=function(x) raster::stack(x, varname=""))); rm(files)
      data <- data[[which(substr(names(data), 2,5) >= startyear)]]
      data <- data[[which(substr(names(data), 2,5) < endyear)]]
    } else if(type == "landuse"){
      if(scenario %in% c("rcp26", "rcp60")){
        if(startyear < 2100){
          files <- list.files(path=path, recursive=T, full.names=T,
                              pattern=paste0(scenario, "soc_ssp2_", tolower(model), "_", 
                                             type, "-", var, "_annual_", ".*\\.nc"))
        } else if(scenario == "rcp26"){
          files <- list.files(path=path, recursive=T, full.names=T,
                              pattern=paste0("2100", scenario, "soc_ssp2_", tolower(model), "_", 
                                             type, "-", var, "_annual_", ".*\\.nc"))
        }
        if(scenario == "rcp26" & startyear < 2100 & endyear >= 2100){
          files2 <- list.files(path=path, recursive=T, full.names=T,
                               pattern=paste0("2100", scenario, "soc_ssp2_", tolower(model), 
                                              "_", type, "-", var, "_annual_", ".*\\.nc"))
          files <- append(files, files2); rm(files2)
        }
      } else{
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(scenario, "_", tolower(model), "_", 
                                           type, "-", var, "_annual_", ".*\\.nc"))
      }
      start <- sapply(files, FUN=function(x) substr(strsplit(x, "_annual_")[[1]][2], 1, 4))
      end <- sapply(files, FUN=function(x) substr(strsplit(x, "_annual_")[[1]][2], 6, 9))
      files <- files[end >= startyear & start <= endyear]
      if(var == "5crops"){
        vars <- c("c3ann_irrigated", "c3ann_rainfed", "c3nfx_irrigated", 
                  "c3nfx_rainfed", "c3per_irrigated", "c3per_rainfed", "c4ann_irrigated", "c4ann_rainfed", 
                  "c4per_irrigated", "c4per_rainfed", "pastures")
      } else if(var == "15crops"){ 
        vars <- c("temperate_cereals_rainfed", "temperate_cereals_irrigated", 
                  "rice_rainfed", "rice_irrigated", "maize_rainfed", "maize_irrigated", 
                  "tropical_cereals_rainfed", "tropical_cereals_irrigated", "pulses_rainfed", 
                  "pulses_irrigated", "temperate_roots_rainfed", "temperate_roots_irrigated", 
                  "tropical_roots_rainfed", "tropical_roots_irrigated", "oil_crops_sunflower_rainfed", 
                  "oil_crops_sunflower_irrigated", "oil_crops_soybean_rainfed", "oil_crops_soybean_irrigated", 
                  "oil_crops_groundnut_rainfed", "oil_crops_groundnut_irrigated", "oil_crops_rapeseed_rainfed", 
                  "oil_crops_rapeseed_irrigated", "c4per_rainfed", "c4per_irrigated", "others_c3ann_rainfed", 
                  "others_c3ann_irrigated", "others_c3nfx_rainfed", "others_c3nfx_irrigated", 
                  "c3per_rainfed", "c3per_irrigated", "pastures")
      } else if(var == "totals"){
        vars <- c("cropland_total", "pastures", "cropland_irrigated", 
                  "cropland_rainfed")
        if(scenario %in% c("rcp26soc", "rcp60soc")){
          vars <- c("biofuel_cropland_irrigated", "biofuel_cropland_rainfed", "cropland_irrigated", 
                    "cropland_rainfed", "cropland_total", "pastures")  
        }
      } else if(var == "urbanareas"){
        vars <- "urbanareas"
      }
      if(length(files) == 1){
        start <- substr(strsplit(files, "_annual_")[[1]][2], 1, 4)
        end <-substr(strsplit(files, "_annual_")[[1]][2], 6, 9)
        data <- lapply(vars, FUN=function(x){
          r <- raster::stack(files, varname=x)
          years <- seq(start, end, 1)
          r <- setZ(r, years, name="Date")
          r <- r[[which(r@z$Date >= startyear)]]
          r[[which(r@z$Date <= endyear)]]
        })
        names(data) <- vars
      } else{
        data <- lapply(vars, FUN=function(x){
          r <- raster::stack(files[1], varname=x)
          r2 <- raster::stack(files[2], varname=x)
          r <- stack(r, r2)
          years <- seq(min(start), max(end), 1)
          r <- setZ(r, years, name="Date")
          r <- r[[which(r@z$Date >= startyear)]]
          r[[which(r@z$Date <= endyear)]]
        })
        names(data) <- vars
      }
    } else if(type == "population"){
      files <- list.files(path=path, recursive=T, pattern=paste0(scenario, "_", type, "_0.5deg_"), 
                          full.names=T)
      start <- sapply(files, FUN=function(x) substr(strsplit(x, "_0.5deg_")[[1]][2], 1, 4))
      end <- sapply(files, FUN=function(x) substr(strsplit(x, "_0.5deg_")[[1]][2], 6, 9))
      files <- files[end >= startyear & start <= endyear]
      data <- stack(lapply(files, FUN=function(x){
        r <- raster::stack(x)
        years <- seq(substr(strsplit(x, "_0.5deg_")[[1]][2], 1, 4), 
                     substr(strsplit(x, "_0.5deg_")[[1]][2], 6, 9), 1)
        r <- setZ(r, years, name="Date")
        r <- r[[which(r@z$Date >= startyear)]]
        r[[which(r@z$Date <= endyear)]]
      }))
    }
  } else if(version == "ISIMIP3b"){
    # List and read required files
    if("GCM" == type){
      if(startyear <= 2014){
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(model, ".*\\", "_historical_", var, "_global_daily_"))
        if(endyear >= 2014){
          files2 <- list.files(path=path, recursive=T, full.names=T,
                               pattern=paste0(model, ".*\\", scenario, "_", var, "_global_daily_"))
          files <- append(files, files2); rm(files2)
        }
      } else{
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(var, "_day_", model, "_", scenario))
      }
      files <- files[end >= startyear & start <= endyear]
      data <- raster::stack(lapply(files, FUN=function(x) raster::stack(x, varname=""))); rm(files)
      data <- data[[which(substr(names(data), 2,5) >= startyear)]]
      data <- data[[which(substr(names(data), 2,5) < endyear)]]
    } else if(type == "landuse"){
      if(scenario %in% c("rcp26", "rcp60")){
        if(startyear < 2100){
          #files <- list.files(path=path, recursive=T, full.names=T,
          #                    pattern=paste0(scenario, "soc_ssp2_", tolower(model), "_", 
          #                                   type, "-", var, "_annual_", ".*\\.nc"))
        } else if(scenario == "rcp26"){
          #files <- list.files(path=path, recursive=T, full.names=T,
          #                    pattern=paste0("2100", scenario, "soc_ssp2_", tolower(model), "_", 
          #                                   type, "-", var, "_annual_", ".*\\.nc"))
        }
        if(scenario == "rcp26" & startyear < 2100 & endyear >= 2100){
          #files2 <- list.files(path=path, recursive=T, full.names=T,
          #                     pattern=paste0("2100", scenario, "soc_ssp2_", tolower(model), 
          #                                    "_", type, "-", var, "_annual_", ".*\\.nc"))
          #files <- append(files, files2); rm(files2)
        }
      } else{
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(type, "-", var, "_", scenario, "_annual_", ".*\\.nc"))
        
      }
      start <- sapply(files, FUN=function(x) substr(strsplit(x, "_annual_")[[1]][2], 1, 4))
      end <- sapply(files, FUN=function(x) substr(strsplit(x, "_annual_")[[1]][2], 6, 9))
      files <- files[end >= startyear & start <= endyear]
      if(var == "5crops"){
        vars <- c("c3ann_irrigated", "c3ann_rainfed", "c3nfx_irrigated", 
                  "c3nfx_rainfed", "c3per_irrigated", "c3per_rainfed", "c4ann_irrigated", "c4ann_rainfed", 
                  "c4per_irrigated", "c4per_rainfed", "pastures")
      } else if(var == "15crops"){ 
        vars <- c("temperate_cereals_rainfed", "temperate_cereals_irrigated", 
                  "rice_rainfed", "rice_irrigated", "maize_rainfed", "maize_irrigated", 
                  "tropical_cereals_rainfed", "tropical_cereals_irrigated", "pulses_rainfed", 
                  "pulses_irrigated", "temperate_roots_rainfed", "temperate_roots_irrigated", 
                  "tropical_roots_rainfed", "tropical_roots_irrigated", "oil_crops_sunflower_rainfed", 
                  "oil_crops_sunflower_irrigated", "oil_crops_soybean_rainfed", "oil_crops_soybean_irrigated", 
                  "oil_crops_groundnut_rainfed", "oil_crops_groundnut_irrigated", "oil_crops_rapeseed_rainfed", 
                  "oil_crops_rapeseed_irrigated", "c4per_rainfed", "c4per_irrigated", "others_c3ann_rainfed", 
                  "others_c3ann_irrigated", "others_c3nfx_rainfed", "others_c3nfx_irrigated", 
                  "c3per_rainfed", "c3per_irrigated", "pastures")
      } else if(var == "totals"){
        vars <- c("cropland_total", "pastures", "cropland_irrigated", 
                  "cropland_rainfed")
        if(scenario %in% c("rcp26soc", "rcp60soc")){
          vars <- c("biofuel_cropland_irrigated", "biofuel_cropland_rainfed", "cropland_irrigated", 
                    "cropland_rainfed", "cropland_total", "pastures")  
        }
      } else if(var == "pastures"){
        vars <- c("managed_pastures", "rangeland")
      } else if(var == "urbanareas"){
        vars <- "urbanareas"
      }
      if(length(files) == 1){
        start <- substr(strsplit(files, "_annual_")[[1]][2], 1, 4)
        end <-substr(strsplit(files, "_annual_")[[1]][2], 6, 9)
        data <- lapply(vars, FUN=function(x){
          r <- raster::stack(files, varname=x)
          years <- seq(start, end, 1)
          r <- setZ(r, years, name="Date")
          r <- r[[which(r@z$Date >= startyear)]]
          r[[which(r@z$Date <= endyear)]]
        })
        names(data) <- vars
      } else{
        data <- lapply(vars, FUN=function(x){
          r <- raster::stack(files[1], varname=x)
          r2 <- raster::stack(files[2], varname=x)
          r <- stack(r, r2)
          years <- seq(min(start), max(end), 1)
          r <- setZ(r, years, name="Date")
          r <- r[[which(r@z$Date >= startyear)]]
          r[[which(r@z$Date <= endyear)]]
        })
        names(data) <- vars
      }
    } else if(type == "population"){
      files <- list.files(path=path, recursive=T, pattern=paste0(type, "_", scenario, "_30arcmin_"), 
                          full.names=T)
      start <- sapply(files, FUN=function(x) substr(strsplit(x, "_30arcmin_")[[1]][2], 1, 4))
      end <- sapply(files, FUN=function(x) substr(strsplit(x, "_30arcmin_")[[1]][2], 6, 9))
      files <- files[end >= startyear & start <= endyear]
      data <- stack(lapply(files, FUN=function(x){
        r <- raster::stack(x)
        years <- seq(substr(strsplit(x, "_30arcmin_")[[1]][2], 1, 4), 
                     substr(strsplit(x, "_30arcmin_")[[1]][2], 6, 9), 1)
        r <- setZ(r, years, name="Date")
        r <- r[[which(r@z$Date >= startyear)]]
        r[[which(r@z$Date <= endyear)]]
      }))
    }
  }
  return(data)
}
