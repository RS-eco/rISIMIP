# Read landuse files and save data to compressed .rda file 
# with correct name assignment

# Load rISIMIP functions
source("R/readISIMIP.R")
source("R/listISIMIP.R")

## Specify land-use type resolution
# Choose one of totals, 5crops, 15crops
lu_type <- "totals"

# Specify path of file directory
filedir <- "/media/matt/Data/Documents/Wissenschaft/Data"

## 2005soc Scenario

#  Get Landuse 2005soc data
soc2005 <- readISIMIP(path=filedir, type="landuse", scenario="2005soc", var=lu_type)
soc2005 <- as.data.frame(raster::rasterToPoints(soc2005))
filename <- paste0("landuse-", lu_type, "_2005soc")
assign(filename, soc2005)
save(list=filename, file=paste0("data/", filename, ".rda"), compress="xz")

## Present and future scenarios

# Calculate 30-yr averages for the different time periods, rcp scenarios and models and save to file.

# Time frames
times <- data.frame(timeframe=c(1995, 2080), startyear=c(1980,2066), endyear=c(2009,2095))

# Create unique combination of timeframe, scenario and model
df <- expand.grid(timeframe=times$timeframe, scenario=c("rcp26", "rcp60"), 
                  model=c("IPSL-CM5A-LR", "HadGEM2-ES", "MIROC5", "GFDL-ESM2M"))

# Remove rcp60 scenarios after 2100, as no models are available for this case
library(dplyr)
df <- full_join(df, times) %>% filter(scenario != "rcp60" | endyear < 2100) %>%
  filter(endyear < 2100 | model != "GFDL-ESM2M")

# Totals land use data
crops_all <- lapply(1:nrow(df), function(x){
  filename <- paste0("landuse-", lu_type, "_", df$scenario[x], "_", 
                     tolower(df$model[x]), "_", df$timeframe[x])
  if(!file.exists(paste0("data/", filename, ".rda"))){
    data <- readISIMIP(path=filedir, type="landuse", 
                       scenario=df$scenario[x], model=df$model[x],
                       var=lu_type, startyear=df$startyear[x], endyear=df$endyear[x])
    data <- raster::stack(lapply(data, FUN=function(z) raster::calc(z, fun=mean)))
    data <- as.data.frame(raster::rasterToPoints(data))
    data <- data[!!rowSums(abs(data[-c(1,2)]),na.rm=TRUE),]
    assign(filename, data)
    save(list=filename, file=paste0("data/", filename, ".rda"), compress="xz")
    rm(data)
    print(x)
  }
})
