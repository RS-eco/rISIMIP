#' Read ISIMIP Environmental Data from NetCDF Files
#'
#' Read and pre-process ISIMIP Data
#' 
#' @param path Path to ISIMIP files
#' @param version Version of ISIMIP data, default is ISIMIP2b, can be one of ISIMIP2b, ISIMIP3a, ISIMIP3b
#' @param type One of EWEMBI, GCM, landuse or population, to specify which type of data you want to use.
#' @param extent Extent of data, either global or landonly
#' @param model A character string specifying the Global Climate Model used
#' @param scenario A character string specifying the scenario, either histsoc, 2005soc, rcp26, rcp60 or ssp2soc
#' @param startyear Startyear of timeperiod for required data
#' @param endyear Endyear of timeperiod for required data
#' @param var A character string specifying the variable to use (tas, tmin, tmax, huss, hurss, pr, ...)
#' @return raster stack or list of raster stacks with all the data 
#' @examples
#' \dontrun{
#' readISIMIP(type="landuse", scenario="rcp26", var="urbanareas", startyear=2010, endyear=2020)
#' }
#' @export
readISIMIP <- function(path=getwd(), version="ISIMIP2b", type="GCM", extent="landonly",
                       model="IPSL-CM5A-LR", scenario="rcp26", startyear=2006,
                       endyear=2010, var="tas"){
  # scenario 2005soc is always the same data only return one layer
  if(scenario == "2005soc"){
    startyear=2006
    endyear=2006
  }
  
  # List files
  files <- listISIMIP(path=path, version=version, type=type, extent=extent,
                      model=model, scenario=scenario, startyear=startyear,
                      endyear=endyear, var=var)
  
  # Read data
  if("GCM" == type){
    data <- raster::stack(lapply(files, FUN=function(x) raster::stack(x, varname=""))); rm(files)
    data <- data[[which(substr(names(data), 2,5) >= startyear)]]
    data <- data[[which(substr(names(data), 2,5) < endyear)]]
  } else if(type == "landuse"){
    if(var == "5crops"){
      vars <- c("c3ann_irrigated", "c3ann_rainfed", "c3nfx_irrigated", "c3nfx_rainfed", 
                "c3per_rainfed_food", "c3per_irrigated_food", "c3per_irrigated_bf", 
                "c3per_rainfed_bf", "c4ann_irrigated", "c4ann_rainfed", "c4per_irrigated_food", 
                "c4per_rainfed_food", "c4per_irrigated_bf", "c4per_rainfed_bf", "pastures")
    } else if(var == "15crops"){ 
      vars <- c("temperate_cereals_rainfed", "temperate_cereals_irrigated", 
                "rice_rainfed", "rice_irrigated", "maize_rainfed", "maize_irrigated", 
                "tropical_cereals_rainfed", "tropical_cereals_irrigated", "pulses_rainfed", 
                "pulses_irrigated", "temperate_roots_rainfed", "temperate_roots_irrigated", 
                "tropical_roots_rainfed", "tropical_roots_irrigated", "oil_crops_sunflower_rainfed", 
                "oil_crops_sunflower_irrigated", "oil_crops_soybean_rainfed", "oil_crops_soybean_irrigated", 
                "oil_crops_groundnut_rainfed", "oil_crops_groundnut_irrigated", "oil_crops_rapeseed_rainfed", 
                "oil_crops_rapeseed_irrigated", "c4per_rainfed_food", "c4per_irrigated_food", 
                "others_c3ann_rainfed", "others_c3ann_irrigated", 
                "others_c3nfx_rainfed", "others_c3nfx_irrigated", 
                "c3per_rainfed_food", "c3per_irrigated_food", "pastures", "c3per_rainfed_bf", 
                "c3per_irrigated_bf", "c4per_rainfed_bf", "c4per_irrigated_bf")
    } else if(var == "totals"){
      if(scenario %in% c("rcp26", "rcp60") & startyear >= 2006){
        vars <- c("biofuel_cropland_irrigated", "biofuel_cropland_rainfed", "cropland_irrigated", 
                  "cropland_rainfed", "cropland_total", "pastures")
      } else{
        vars <- c("cropland_irrigated", "cropland_rainfed", "cropland_total", "pastures")  
      }
    } else if(var == "pastures"){
      vars <- c("managed_pastures", "rangeland")
    } else if(var == "urbanareas"){
      vars <- "urbanareas"
    }
    if(length(files) == 1){
      start <- substr(strsplit(files, "_annual_")[[1]][2], 1, 4)
      end <- substr(strsplit(files, "_annual_")[[1]][2], 6, 9)
      data <- lapply(vars, FUN=function(x){
        r <- raster::stack(files, varname=x)
        years <- seq(start, end, 1)
        r <- raster::setZ(r, years, name="Date")
        names(r) <- years
        r <- r[[which(r@z$Date >= startyear)]]
        r[[which(r@z$Date <= endyear)]]
      })
    } else{
      start <- substr(strsplit(files, "_annual_")[[1]][2], 1, 4)
      end <- substr(strsplit(files, "_annual_")[[2]][2], 6, 9)
      data <- lapply(vars, FUN=function(x){
        r <- raster::stack(files[1], varname=x)
        r2 <- raster::stack(files[2], varname=x)
        r <- raster::stack(r, r2)
        years <- seq(min(start), max(end), 1)
        r <- raster::setZ(r, years, name="Date")
        names(r) <- years
        r <- r[[which(r@z$Date >= startyear)]]
        r[[which(r@z$Date <= endyear)]]
      })
    }
  } else if(type %in% c("population", "gdp")){
    vars <- type
    data <- stack(lapply(files, FUN=function(x){
      r <- raster::stack(x)
      years <- seq(substr(strsplit(x, "_0p5deg_annual_")[[1]][2], 1, 4), 
                   substr(strsplit(x, "_0p5deg_annual_")[[1]][2], 6, 9), by=1)
      r <- raster::setZ(r, years, name="Date")
      names(r) <- years
      r <- r[[which(r@z$Date >= startyear)]]
      r[[which(r@z$Date <= endyear)]]
    }))
  }
  if(raster::nlayers(data[[1]]) == 1){
    data <- raster::stack(data)
  } else if(length(data) == 1){
    data <- data[[1]]
  } else{
    # Set names of list
    names(data) <- vars
  }
  return(data)
}