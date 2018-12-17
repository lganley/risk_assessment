## libraries
library(rgdal)
library(sf)
library(rgeos)
library(sp)
library(rgdal)
library(raster)
library(R.matlab)
library(rasterVis)
library(classInt)

## setwd
setwd("/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/ais_shapefiles")

## load in the shapefile grid we sent jeff
grid.poly <- read_sf("/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/",
                     "whole.grid.poly.4")

## load in the shapefile
## I used read_sf instead of read_OGR because read_OGR
## is notoriously slow with big shapefiles.
#s1 <- read_sf("./v_lwta_segs_2009", "v_lwta_segs_2009")


## the shapefiles take a long time to load so save them
## as an RDS file and they should be faster to load
#saveRDS(s1, file = "./s1.rds")
s2 <- readRDS("s1.rds")

## filter out vessel id = 1914
vessels_id_1914 <- s2 %>%
  dplyr::filter(vessels_id == 1914)


## plot only vessel id = 1914
plot(st_geometry(vessels_id_1914))
us <- getData('GADM', country = 'US', level = 1)
us$NAME_1
Massachusetts <- us[us$NAME_1 == "Massachusetts",]
nh <- us[us$NAME_1 == "New Hampshire",]
maine <- us[us$NAME_1 == "Maine",]
ri <- us[us$NAME_1 == "Rhode Island", ]
ct <- us[us$NAME_1 == "Connecticut", ]
vt <- us[us$NAME_1 == "Vermont", ]

plot(Massachusetts, add = TRUE)
plot(st_geometry(grid.poly), pch = 1, col = "transparent", add = TRUE)

##3.) calculate the centroid of each grid cell and plot it on top
## of the AIS data.  This centroid will be the "UniqueId"
grid.poly$poly.uniqueid <- st_centroid(grid.poly)
uniqueid <- st_centroid(grid.poly) %>%
  

## the dot is the center of the cell
plot(st_geometry(poly.uniqueid), pch = 20, cex = .5, col = 'blue', add = TRUE)




## this is a shortcut I'm not quite sure how it works
## use the raster that we created in make_Grids.  rasterize
## the vessels_id_1914, and calculate the mean of the 'sog'
r <- raster(ext = extent(-72, -63, 37, 46), res=c(360/8640,360/8640))
rasterWeightedMean <- rasterize(x=vessels_id_1914, y=r, fun=weighted.mean(x = vessels_id_1914$dist_km, y = vessels_id_1914$sog))
rasterMeanPoints <- rasterize(x=vessels_id_1914, y=r, field = "sog", fun=mean)


## use a color palette
my.palette <- brewer.pal(n = 5, name = "YlOrRd")
plot(Massachusetts, col = "gray80", xlim=c(-72, -69),ylim=c(40.5,44))
plot(nh, add = TRUE, col = "gray80")
plot(ri, add = TRUE, col = "gray80")
plot(maine, add = TRUE, col = "gray80")
plot(ct, add = TRUE, col = "gray80")
plot(vt, add = TRUE, col = "gray80")
plot(rasterMeanPoints,
     breaks = c(0.46, 2.612285, 7.45583, 8.110578, 8.7838782, 10.08), 
     col = my.palette, add = TRUE)


## make the plot in ggplot2
library(ggthemes)
test_spdf <- as(rasterMeanPoints, "SpatialPixelsDataFrame")
test_df <- as.data.frame(test_spdf)
colnames(test_df) <- c("value", "x", "y")


library(ggsn)

ggplot() +  
  geom_tile(data=test_df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  geom_polygon(data=Massachusetts, aes(x=long, y=lat, group=group), 
               fill="grey80", color="grey50", size=0.25) +
  geom_polygon(data=nh, aes(x=long, y=lat, group=group), 
               fill="grey80", color="grey50", size=0.25) +
  geom_polygon(data=maine, aes(x=long, y=lat, group=group), 
               fill="grey80", color="grey50", size=0.25)+
  geom_polygon(data=vt, aes(x=long, y=lat, group=group), 
               fill="grey80", color="grey50", size=0.25)+
  geom_polygon(data=ri, aes(x=long, y=lat, group=group), 
               fill="grey80", color="grey50", size=0.25)+
  geom_polygon(data=ct, aes(x=long, y=lat, group=group), 
               fill="grey80", color="grey50", size=0.25) +
  scale_fill_viridis(option = "inferno", 
                       name = "Mean SOG",
                       breaks = c(0.46, 2.612285, 7.45583, 8.110578, 8.7838782, 10.08)) +
  coord_equal() +
  theme_map() +
  theme(legend.position="bottom") +
  theme(legend.key.width=unit(2, "cm")) +
  labs(x = "Latitude", 
       y = "Longitude", 
       title = "Mean Speed Over Ground", 
       subtitle = "Vessel ID 1914") 