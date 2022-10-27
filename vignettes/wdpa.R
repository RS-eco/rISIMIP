## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = FALSE, fig.width=8, fig.height=6, warning=FALSE, comment=NA, message=FALSE, eval=F)

## -----------------------------------------------------------------------------
#  library(rISIMIP)
#  data("protectedareas_annual_1819_2018_landonly", package="rISIMIP")
#  data(outline, package="ggmap2") # The ggmap2 package is available on Github: http://github.com/RS-eco/ggmap2
#  outline <- sf::st_as_sf(outline)
#  library(ggplot2); library(dplyr)
#  protectedareas_annual_1819_2018_landonly %>%
#    ggplot() + geom_tile(aes(x=x,y=y,fill=`2018`*100)) +
#    geom_sf(data=outline, fill=NA, colour="grey50") +
#    scale_fill_gradientn(name="", colours=colorRampPalette(c("white", "#00007F", "blue", "#007FFF", "cyan",
#                                "#7FFF7F", "yellow", "#FF7F00", "red",
#                                "#7F0000"))(255)) +
#    coord_sf(xlim=c(-160,160), ylim=c(-55,85)) + labs(x="", y="") + theme_bw()

## -----------------------------------------------------------------------------
#  data("protectedareas_iucn_cat_2018_landonly", package="rISIMIP")
#  protectedareas_iucn_cat_2018_landonly %>% tidyr::gather(iucn_cat, perc, -c(x,y)) %>% tidyr::drop_na() %>%
#    ggplot() + geom_tile(aes(x=x,y=y,fill=perc*100)) + facet_wrap(.~iucn_cat) +
#    geom_sf(data=outline, fill=NA, colour="grey50") +
#    scale_fill_gradientn(name="", colours=colorRampPalette(c("white", "#00007F", "blue", "#007FFF", "cyan",
#                                "#7FFF7F", "yellow", "#FF7F00", "red",
#                                "#7F0000"))(255)) +
#    coord_sf(xlim=c(-160,160), ylim=c(-55,85)) + labs(x="", y="") + theme_bw()

## -----------------------------------------------------------------------------
#  data("landseamask_generic", package="rISIMIP")
#  area_df <- as.data.frame(raster::rasterToPoints(raster::area(landseamask_generic)))
#  protectedareas_iucn_cat_2018_landonly %>%  tidyr::gather(iucn_cat, perc, -c(x,y)) %>% tidyr::drop_na() %>%
#    left_join(area_df) %>% group_by(iucn_cat) %>% summarise(total=sum(perc*100*layer/1000000,na.rm=T)) %>%
#    ggplot() + geom_bar(aes(x=iucn_cat,y=total, fill=iucn_cat), stat="identity") + theme_bw() +
#    scale_fill_discrete(name="") + labs(x="IUCN Category", y="Area (km2)") +
#    theme(legend.position = "none") + scale_y_continuous(limits=c(0,400), expand=c(0,0))

## -----------------------------------------------------------------------------
#  data("protectedareas_annual_1819_2018_landonly", package="rISIMIP")
#  protectedareas_annual_1819_2018_landonly %>% tidyr::gather(year, perc, -c(x,y)) %>% tidyr::drop_na() %>%
#    filter(year %in% c(1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015)) %>%
#    ggplot() + geom_tile(aes(x=x,y=y,fill=perc*100)) + facet_wrap(.~year) +
#    geom_sf(data=outline, fill=NA, colour="grey50") +
#    scale_fill_gradientn(name="", colours=colorRampPalette(c("white", "#00007F", "blue", "#007FFF", "cyan",
#                                "#7FFF7F", "yellow", "#FF7F00", "red",
#                                "#7F0000"))(255)) +
#    coord_sf(xlim=c(-160,160), ylim=c(-55,85)) + labs(x="", y="") + theme_bw()

## -----------------------------------------------------------------------------
#  protectedareas_annual_1819_2018_landonly %>% tidyr::gather(year, perc, -c(x,y)) %>%
#    left_join(area_df) %>% group_by(year) %>% summarise(total=sum(perc*100*layer/1000000,na.rm=T)) %>%
#    ggplot() + geom_line(aes(x=as.numeric(year),y=total)) + theme_bw() +
#    labs(x="Year", y="Area (km2)") + scale_y_continuous(limits=c(-10,1200), expand=c(0,0))

