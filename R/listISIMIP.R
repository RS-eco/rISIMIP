#' List ISIMIP Environmental Data files
#'
#' Creates a list with required ISIMIP2b Data files
#' 
#' @param path Path to files
#' @param version Version of ISIMIP data, default is ISIMIP2b, can be one of ISIMIP2b, ISIMIP3a, ISIMIP3b
#' @param type One of GCM or landuse to specify which type of data you want to get
#' @param extent Extent of data, either global or landonly
#' @param model A character string specifying the Global Climate Model used
#' @param scenario Character specifying the scenario to use, either histsoc, 2005soc, rcp26, rcp60
#' @param startyear Integer specifying the startyear for data retrieval
#' @param endyear Integer specifying the endyear for data retrieval
#' @param var Character specifying the required variable name, one of tas, pr, ...
#' @return list of file paths with required data 
#' @examples
#' \dontrun{
#' listISIMIP(type="landuse", scenario="2005soc", var="urbanareas")
#' }
#' @export
listISIMIP <- function(path=getwd(), version="ISIMIP2b", type="GCM", extent="landonly",
                       model="IPSL-CM5A-LR", scenario="rcp26", startyear=2006,
                       endyear=2010, var="tas"){
  if(version == "ISIMIP2b"){
    # List required files
    if("EWEMBI" == type){
      files <- list.files(path=path, pattern=paste0(var, "_ewembi1_", ".*\\.nc4"),
                          recursive=T, full.names=T)
    } else if("GCM" == type){
      if(startyear < 2006 & scenario != "piControl"){
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(var, "_day_", model, "_historical_", ".*\\.nc4"))
        if(endyear >= 2006){
          files2 <- list.files(path=path, recursive=T, full.names=T,
                               pattern=paste0(var, "_day_", model, "_", scenario, ".*\\.nc4"))
          files <- append(files, files2); rm(files2)
        }
      } else{
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(var, "_day_", model, "_", scenario, ".*\\.nc4"))
      }
      if(extent=="landonly"){
        start <- sapply(files, FUN=function(x) substr(strsplit(x, "_landonly_")[[1]][2], 1, 4))
        end <- sapply(files, FUN=function(x) substr(strsplit(x, "_landonly_")[[1]][2], 10, 13))
      } else{
        start <- sapply(files, FUN=function(x) substr(strsplit(x, "_EWEMBI_")[[1]][2], 1, 4))
        end <- sapply(files, FUN=function(x) substr(strsplit(x, "_EWEMBI_")[[1]][2], 10, 13))
      }
      files <- files[end >= startyear & start <= endyear]
      #data <- raster::stack(lapply(files, FUN=function(x) raster::stack(x, varname=""))); rm(files)
      #data <- data[[which(as.numeric(substr(names(data), 2,5)) >= startyear)]]
      #data <- data[[which(as.numeric(substr(names(data), 2,5)) < endyear)]]
      # Function returns files, need files for aggregateNC function!!!
    } else if(type == "landuse"){
      if(var == "urbanareas"){
        pattern <- paste0(type, "-", var, "_annual_", ".*\\.nc4")
      } else{
        if(scenario %in% c("1860soc", "histsoc", "2005soc")){
          pattern <- paste0(type, "-", var, "_annual_", ".*\\.nc4")
        } else{
          pattern <- paste0(tolower(model), "_", type, "-", var, "_annual_", ".*\\.nc4")
        }
      }
      if(scenario %in% c("rcp26", "rcp60", "rcp85")){
        if(startyear < 2006){
          files <- list.files(path=path, recursive=T, full.names=T,
                              pattern=paste0("^histsoc_", type, "-", var, "_annual_", ".*\\.nc4"))
          if(endyear >= 2006){
            files2 <- list.files(path=path, recursive=T, full.names=T,
                                 pattern=paste0("^", scenario, "soc_", pattern))
            files <- append(files, files2); rm(files2)
          }
        } else if(startyear < 2100){
          files <- list.files(path=path, recursive=T, full.names=T,
                              pattern=paste0("^", scenario, "soc_", pattern))
          if(scenario == "rcp26" & endyear >= 2100){
            files2 <- list.files(path=path, recursive=T, full.names=T,
                                 pattern=paste0("2100", scenario, "soc_", pattern))
            files <- append(files, files2); rm(files2)
          }
        } else if(scenario == "rcp26" & startyear >= 2100){
          files <- list.files(path=path, recursive=T, full.names=T,
                              pattern=paste0("2100", scenario, "soc_", pattern))
        }
      } else{
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(scenario, "_", pattern))
      }
      start <- sapply(files, FUN=function(x) substr(strsplit(x, "_annual_")[[1]][2], 1, 4))
      end <- sapply(files, FUN=function(x) substr(strsplit(x, "_annual_")[[1]][2], 6, 9))
      files <- files[end >= startyear & start <= endyear]
    } else if(type %in% c("population", "gdp")){
      vars <- type
      if(startyear < 2006){
        files <- list.files(path=path, recursive=T,
                            pattern=paste0(type, "_histsoc_0p5deg_", ".*\\.nc4"), 
                            full.names=T)
        if(endyear >= 2006){
          files2 <- list.files(path=path, recursive=T,
                               pattern=paste0(type, "_", scenario, "_0p5deg_", ".*\\.nc4"), 
                               full.names=T)
          files <- append(files, files2); rm(files2)
        }
      } else if(startyear < 2100){
        files <- list.files(path=path, recursive=T,
                            pattern=paste0(type, "_", scenario, "_0p5deg_", ".*\\.nc4"), 
                            full.names=T)
      }
      start <- sapply(files, FUN=function(x) substr(strsplit(x, "_0p5deg_annual_")[[1]][2], 1, 4))
      end <- sapply(files, FUN=function(x) substr(strsplit(x, "_0p5deg_annual_")[[1]][2], 6, 9))
      files <- files[end >= startyear & start <= endyear]
    } else if(type == "ocean"){
      if(startyear < 2006){
        if(var %in% c("o2", "ph", "so", "to", "uo", "vo", "wo")){
          files <- list.files(path=path, recursive=T, full.names=T,
                              pattern=paste0(model, "_historical_", var, "_zs_monthly", ".*\\.nc4"))
        } else if(var %in% c("dphy", "lphy", "lzoo", "sphy", "szoo")){
          files <- list.files(path=path, recursive=T, full.names=T,
                              pattern=paste0(model, "_historical_", var, "_zs2_monthly", ".*\\.nc4"))
        }
        if(endyear >= 2006){
          if(var %in% c("o2", "ph", "so", "to", "uo", "vo", "wo")){
            files2 <- list.files(path=path, recursive=T, full.names=T,
                                 pattern=paste0(model, "_", scenario, "_", var, "_zs_monthly", ".*\\.nc4"))
          } else if (var %in% c("dphy", "lphy", "lzoo", "sphy", "szoo")){
            files2 <- list.files(path=path, recursive=T, full.names=T,
                                 pattern=paste0(model, "_", scenario, "_", var, "_zs2_monthly", ".*\\.nc4"))
          }
          files <- append(files, files2); rm(files2)
        }
      } else{
        if(var %in% c("o2", "ph", "so", "to", "uo", "vo", "wo")){
          files <- list.files(path=path, recursive=T, full.names=T,
                              pattern=paste0(model, "_", scenario, "_", var, "_zs_monthly", ".*\\.nc4"))
        } else if(var %in% c("dphy", "lphy", "lzoo", "sphy", "szoo")){
          files <- list.files(path=path, recursive=T, full.names=T,
                              pattern=paste0(model, "_", scenario, "_", var, "_zs2_monthly", ".*\\.nc4"))
        }
      }
      start <- as.numeric(sapply(files, FUN=function(x) substr(strsplit(x, "_monthly_")[[1]][2], 1, 4)))
      end <- as.numeric(sapply(files, FUN=function(x) substr(strsplit(x, "_monthly_")[[1]][2], 8, 11)))
      files <- files[end >= startyear & start <= endyear]
    }
  } else if(version == "ISIMIP3b"){
    # List required files
    if("GCM" == type){
      if(startyear <= 2014 & model != "GSWP3-W5E5"){
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(tolower(model), ".*\\", "_", scenario, "_", var, "_global_daily_"))
        if(endyear > 2014){
          files2 <- list.files(path=path, recursive=T, full.names=T,
                               pattern=paste0(tolower(model), ".*\\", "_", scenario, "_", var, "_global_daily_"))
          files <- append(files, files2); rm(files2)
        }
      } else{
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=paste0(tolower(model), ".*\\", "_", scenario, "_", var, "_global_daily_"))
      }
      start <- sapply(files, FUN=function(x) substr(strsplit(x, "_daily_")[[1]][2], 1, 4))
      end <- sapply(files, FUN=function(x) substr(strsplit(x, "_daily_")[[1]][2], 6, 9))
      files <- files[end >= startyear & start <= endyear]
    } else if(type == "landuse"){
      if(var == "urbanareas"){
        pattern <- paste0(type, "-", var, "_annual_", ".*\\.nc4")
      } else{
        if(scenario %in% c("1860soc", "histsoc", "2005soc")){
          pattern <- paste0(type, "-", var, "_", scenario, "_annual_.*\\.nc4")
        } else{
          #pattern <- paste0(tolower(model), "_", type, "-", var, "_", scenario, "_annual_.*\\.nc4")
        }
      }
      if(scenario %in% c("ssp126", "ssp370")){
        if(startyear < 2014){
          files <- list.files(path=path, recursive=T, full.names=T, pattern=pattern)
          if(endyear >= 2014){
            #files2 <- list.files(path=path, recursive=T, full.names=T,
            #                     pattern=paste0("^", scenario, "soc_", pattern))
            #files <- append(files, files2); rm(files2)
          }
        } else if(startyear < 2100){
          #files <- list.files(path=path, recursive=T, full.names=T,
          #                    pattern=paste0("^", scenario, "soc_", pattern))
          if(scenario == "ssp126" & endyear >= 2100){
            #files2 <- list.files(path=path, recursive=T, full.names=T,
            #                     pattern=paste0("2100", scenario, "soc_", pattern))
            #files <- append(files, files2); rm(files2)
          }
        } else if(scenario == "ssp126" & startyear >= 2100){
          #files <- list.files(path=path, recursive=T, full.names=T,
          #                    pattern=paste0("^", scenario, "soc_", pattern))
        }
      } else{
        files <- list.files(path=path, recursive=T, full.names=T,
                            pattern=pattern)
      }
      start <- sapply(files, FUN=function(x) substr(strsplit(x, "_annual_")[[1]][2], 1, 4))
      end <- sapply(files, FUN=function(x) substr(strsplit(x, "_annual_")[[1]][2], 6, 9))
      files <- files[end >= startyear & start <= endyear]
    } else if(type %in% c("population", "gdp")){
      vars <- type
      if(startyear < 2014){
        files <- list.files(path=path, recursive=T,
                            pattern=paste0(type, "_", scenario, "_30arcmin_", ".*\\.nc4"), 
                            full.names=T)
        if(endyear >= 2014){
          files2 <- list.files(path=path, recursive=T,
                               pattern=paste0(type, "_", scenario, "_30arcmin_", ".*\\.nc4"), 
                               full.names=T)
          files <- append(files, files2); rm(files2)
        }
      } else if(startyear < 2100){
        files <- list.files(path=path, recursive=T,
                            pattern=paste0(type, "_", scenario, "_30arcmin_", ".*\\.nc4"), 
                            full.names=T)
      }
      start <- sapply(files, FUN=function(x) substr(strsplit(x, "_30arcmin_annual_")[[1]][2], 1, 4))
      end <- sapply(files, FUN=function(x) substr(strsplit(x, "_30arcmin_annual_")[[1]][2], 6, 9))
      files <- files[end >= startyear & start <= endyear]
    }
  }
  return(files)
}
