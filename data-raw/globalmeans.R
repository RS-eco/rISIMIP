#' Process ISIMIP2b/DerivedInputData/globalmeans 
#' to include in rISIMIP package

filedir <- "/media/matt/Data/Documents/Wissenschaft/Data/"

yearmean_tas <- list.files(paste0(filedir, "/ISIMIP2b/DerivedInputData/globalmeans"), 
                       pattern="yearmean.txt", recursive=TRUE, full.names=TRUE)
yearmean_tas <- lapply(yearmean_tas, function(x){
  data <- read.table(x)
  colnames(data) <- c("year", "tas(K)")
  data$model <- strsplit(basename(x), split="_")[[1]][3]
  data$scenario <- strsplit(basename(x), split="_")[[1]][4]
  return(data)
})
yearmean_tas <- do.call("rbind", yearmean_tas)
save(yearmean_tas, file="data/yearmean_tas.rda")

runmean31_tas <- list.files(paste0(filedir, "/ISIMIP2b/DerivedInputData/globalmeans"), 
                           pattern="runmean31.txt", recursive=TRUE, full.names=TRUE)
runmean31_tas <- lapply(runmean31_tas, function(x){
  data <- read.table(x)
  colnames(data) <- c("year", "tas(K)")
  data$model <- strsplit(basename(x), split ="_")[[1]][3]
  data$scenario <- strsplit(basename(x), split = "_")[[1]][4]
  return(data)
})
runmean31_tas <- do.call("rbind", runmean31_tas)
save(runmean31_tas, file="data/runmean31_tas.rda")

delta_runmean31_tas <- list.files(paste0(filedir, "/ISIMIP2b/DerivedInputData/globalmeans"), 
                        pattern="^delta(.*)csv$", recursive=TRUE, full.names=TRUE)
delta_runmean31_tas <- lapply(1:length(delta_runmean31_tas), function(x){
  data <- readr::read_csv(delta_runmean31_tas[x], na=c("", "NA", "-"))
  data$rcp <- c("rcp26", "rcp45", "rcp60", "rcp85")[x]
  return(data)
})
delta_runmean31_tas <- do.call("rbind", delta_runmean31_tas)
save(delta_runmean31_tas, file="data/delta_runmean31_tas.rda")
