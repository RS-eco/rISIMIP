# Read bioclim files and save data to compressed .rda file 
# with correct name assignment

# Consider global-landonly vignette for creating bioclim .csv.xz files

# https://dataservices.gfz-potsdam.de/pik/showshort.php?id=escidoc:4855898
# Check-out link for new observed climate data - W5E5

# List bioclim .csv.xz files for 1995, 2050 & 2080
#filedir <- "/media/matt/Data/Documents/Wissenschaft/Data/ISIMIP2b/DerivedInputData/30yr_climate/"
filedir <- "/home/matt/Documents/ClimateData"
(bioclim_files <- c(list.files(filedir, pattern="bioclim.*1995", full.names=T, recursive = T),
                    list.files(filedir, pattern="bioclim.*2050", full.names=T, recursive = T),
                    list.files(filedir, pattern="bioclim.*2080", full.names=T, recursive = T)))


# Write bioclim files to rISIMIP
lapply(bioclim_files, function(x){
  if(!file.exists(paste0("data/", sub(".csv.xz", ".rda", tolower(basename(x)))))){
    dat <- read.csv(x)
    #colnames(dat) <- c("x", "y", paste0("bio", 1:19))
    assign(sub(".csv.xz", "", tolower(basename(x))), dat)
    save(list=sub(".csv.xz", "", tolower(basename(x))), 
         file=paste0("data/", sub(".csv.xz", ".rda", tolower(basename(x)))), compress="xz")
  }
})

# Check available files
(bioclim_files <- list.files("data", pattern="bioclim_.*\\landonly.rda", 
                            full.names=T, recursive=T))


# Consider global-landonly-isimip3b.Rmd vignette for creating bioclim .csv.xz files

filedir <- "I:/ISIMIP3b/DerivedInputData/"
(bioclim_files <- c(list.files(filedir, pattern="bioclim.*1995.*.csv.xz", full.names=T, recursive = T),
                    list.files(filedir, pattern="bioclim.*2000.*.csv.xz", full.names=T, recursive = T),
                    list.files(filedir, pattern="bioclim.*2005.*.csv.xz", full.names=T, recursive = T),
                    list.files(filedir, pattern="bioclim.*2050.*.csv.xz", full.names=T, recursive = T),
                    list.files(filedir, pattern="bioclim.*2080.*.csv.xz", full.names=T, recursive = T)))


# Write bioclim files to rISIMIP
lapply(bioclim_files, function(x){
  if(!file.exists(paste0("data/", sub(".csv.xz", ".rda",
                                     tolower(basename(x)))))){
    dat <- read.csv(x)
    #colnames(dat) <- c("x", "y", paste0("bio", 1:19))
    assign(sub(".csv.xz", "",  tolower(basename(x))), dat)
    save(list=sub(".csv.xz", "",  tolower(basename(x))), 
         file=paste0("data/", sub(".csv.xz", ".rda", tolower(basename(x)))), compress="xz")
  }
})

# Check available files
(bioclim_files <- list.files("data", pattern="bioclim_.*\\landonly.rda", 
                             full.names=T, recursive=T))
