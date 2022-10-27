## Extract WDPA data at 0.5 degree resolution

#' Set working directory
filedir <- "/media/matt/Data/Documents/Wissenschaft/Data/"
filedir <- "/home/hpc/pn34qo/ge82nob2/globePA/data"

#' Load required library
library(sf)

# Get WDPA Data and read it into R

## Shapefile

#' Download shapefile of PAs by country ISO code
#download.file("http://d1gam3xoknrgr2.cloudfront.net/current/WDPA_Nov2017_DEU-shapefile.zip", 
#              destfile="WDPA/WDPA_Nov2017_DEU.zip")

#' Unzip shapefile
#unzip("WDPA/WDPA_Nov2017_DEU.zip", exdir="E:/Data/WDPA")

#' Read shapefile
#wdpa <- st_read(dsn="WDPA/WDPA_Nov2017_DEU-shapefile", 
#                layer="WDPA_Nov2017_DEU-shapefile-polygons", verbose=FALSE)

## Geodatabase

#' Download Geodatabase of all PAs
#download.file("https://pp-import-production.s3.amazonaws.com/current/WDPA_Nov2017_Public.zip",
#              destfile="WDPA/WDPA_Nov2017_Public.zip")

#' Download shapefile of all PAs
#download.file("http://d1gam3xoknrgr2.cloudfront.net/current/WDPA_Nov2017-shapefile.zip", 
#              destfile="WDPA/WDPA_Nov2017-shapefile.zip")

#' Unzip shapefile
#unzip("WDPA/WDPA_Nov2017_Public.zip", exdir="E:/Data/WDPA")
#unzip("WDPA/WDPA_Nov2017-shapefile.zip", exdir="E:/Data/WDPA")

#' Specify path to geodatabase
#wdpa_path <- paste0(filedir, "/WDPA/WDPA_Nov2017_Public/WDPA_Nov2017_Public.gdb")
#wdpa_path <- paste0(filedir, "/WDPA/WDPA_Jun2019-shapefile/WDPA_Jun2019-shapefile-polygons.shp")

#' List all feature classes in the geodatabase
#st_layers(wdpa_path)

#' Read one feature class into R
#wdpa <- st_read(dsn=wdpa_path, layer="WDPA_Jun2019-shapefile-polygons", type=3)
#wdpa_point <- st_read(dsn=wdpa_path, layer="WDPA_point_Nov2017",type=2)

## Process WDPA Data

#' Only take Protected Areas that are within the IUCN categories
#pa_iucn <- wdpa[wdpa$IUCN_CAT %in% c("II", "III", "IV", "Ia", "Ib", "V", "VI"),]; rm(wdpa)

#' Select protected areas that have a size bigger than 0
#wdpa_spatial <- wdpa_iucn[wdpa_iucn$REP_AREA > 0,]; rm(wdpa_iucn)

#' Divide protected areas in marine and terrestrial protected areas
#mpa <- wdpa_spatial[wdpa_spatial$MARINE != 0,] # Coastal and marine
#pa <- wdpa_spatial[wdpa_spatial$MARINE == 0,]; rm(wdpa_spatial)

#' Save shapefile as RDS
#saveRDS(mpa, paste0(filedir, "/WDPA/WDPA_Sep2017_IUCN_Marine.rds"), compress="xz")
#saveRDS(pa, paste0(filedir, "/WDPA/WDPA_Jun2019_IUCN_Terrestrial.rds"), compress="xz")

## Rasterize annual protected areas

# Read data
pa <- readRDS(paste0(filedir, "/WDPA/WDPA_Jun2019_IUCN_Terrestrial.rds"))

#' Only take Protected Areas with year
pa <- pa[pa$STATUS_YR != 0,]

#' Extract individual years
min_year <- min(pa$STATUS_YR)
max_year <- max(pa$STATUS_YR) # 2019 is not yet complete
years <- seq(min_year, max_year-1)

#' Read ISIMIP landsea mask
data(landseamask_generic, package="rISIMIP")

dat <- raster::disaggregate(landseamask_generic, fact=10)
raster::aggregate(dat,10, fun=sum)

#' Create list of rasterized protected areas by year
protectedareas_annual_1819_2018 <- lapply(years, function(x){
  # Extract wdpas for one year
  #pa_sub <- pa[pa$STATUS_YR == x,]
  
  # Extract wdpas for current and all subsequent years
  pa_sub <- pa[pa$STATUS_YR <= x,]
  
  # Rasterize data according to ISIMIP2b Landsea mask
  r_pa <- fasterize::fasterize(pa_sub, dat)
  print(x)
  return(r_pa)
})
protectedareas_annual_1819_2018 <- raster::stack(protectedareas_annual_1819_2018); rm(pa)
protectedareas_annual_1819_2018 <- raster::aggregate(protectedareas_annual_1819_2018, 10, fun="sum")
protectedareas_annual_1819_2018 <- raster::calc(protectedareas_annual_1819_2018, function(x) x/100)
names(protectedareas_annual_1819_2018) <- years
raster::setZ(protectedareas_annual_1819_2018, z=years, name="time")

#' Crop by landseamask
protectedareas_annual_1819_2018_landonly <- raster::mask(protectedareas_annual_1819_2018, landseamask_generic)

# Plot maps
raster::plot(protectedareas_annual_1819_2018_landonly[[200]])
  
#' Save to file
#raster::writeRaster(protectedareas_annual_1819_2016_landonly, 
#                    filename="protectedareas_annual_1819_2016_landonly.nc", 
#                    format="CDF", varname="protectedareas", varunit="", 
#                    longname="iucn_protected_area_coverage", xname="long", 
#                    yname="lat", zname="time", zunit="years", 
#                    force_v4=TRUE, compression=9)

protectedareas_annual_1819_2018_landonly <- as.data.frame(raster::rasterToPoints(protectedareas_annual_1819_2018_landonly))
head(protectedareas_annual_1819_2018_landonly)
colnames(protectedareas_annual_1819_2018_landonly) <- c("x", "y", 1819:2018)
save(protectedareas_annual_1819_2018_landonly, file="protectedareas_annual_1819_2018_landonly.rda", compress="xz")

#'**Note:** Re-start RStudio after saving files, to free the memory of your computer.

# Rasterize current WDPAs by category

pa <- readRDS(paste0(filedir, "/WDPA/WDPA_Jun2019_IUCN_Terrestrial.rds"))

#' Read ISIMIP landsea mask
data(landseamask_generic, package="rISIMIP")
dat <- raster::disaggregate(landseamask_generic, fact=10)

# Specify categories
cat <- c("Ia", "Ib", "II", "III", "IV", "V", "VI")

#' Create list of rasterized protected areas by category
protectedareas_iucn_cat_landonly <- lapply(cat, function(x){
  # Extract wdpas for one IUCN cat
  pa_sub <- pa[pa$IUCN_CAT == x,]
  
  # Rasterize data according to ISIMIP2b Landsea mask
  r_pa <- fasterize::fasterize(pa_sub, dat)
  print(x)
  return(r_pa)
})
protectedareas_iucn_cat_landonly <- raster::stack(protectedareas_iucn_cat_landonly); rm(pa)
protectedareas_iucn_cat_landonly <- raster::aggregate(protectedareas_iucn_cat_landonly, 10, fun="sum")
protectedareas_iucn_cat_landonly <- raster::calc(protectedareas_iucn_cat_landonly, function(x) x/100)

# Set names
names(protectedareas_iucn_cat_landonly) <- cat
raster::setZ(protectedareas_iucn_cat_landonly, z=cat, name="time")

#' Crop by land extent
protectedareas_iucn_cat_landonly <- raster::mask(protectedareas_iucn_cat_landonly, landseamask_generic)

# Plot maps
raster::plot(protectedareas_iucn_cat_2018_landonly[[2]])

#' Save to file
#raster::writeRaster(protectedareas_iucn_cat_landonly, 
#                    filename="protectedareas_iucn_cat_landonly.nc", 
#                    format="CDF", varname="protectedareas", varunit="", 
#                    longname="iucn_category_coverage", xname="long", 
#                    yname="lat", zname="time", zunit="years", 
#                    force_v4=TRUE, compression=9)

protectedareas_iucn_cat_2018_landonly <- as.data.frame(raster::rasterToPoints(protectedareas_iucn_cat_2018_landonly))
save(protectedareas_iucn_cat_2018_landonly, file="data/protectedareas_iucn_cat_2018_landonly.rda", compress="xz")
