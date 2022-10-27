#' Process ISIMIP2b/InputData/ISIMIP2b_landseamask 
#' to include in rISIMIP package

# List files
filedir <- "/media/matt/Data/Documents/Wissenschaft/Data/ISIMIP2b/"
landseamask_generic <- list.files(filedir, pattern="ISIMIP2b_landseamask_generic", full.names=T, recursive=T)

# Read Raster file to memory
landseamask_generic <- SpaDES.core::rasterToMemory(landseamask_generic)

# Plot maps
raster::plot(landseamask_generic)

# Save as .Rda file
save(landseamask_generic, file="data/landseamask_generic.rda", compress="xz")
