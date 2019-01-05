library(dplyr)
library(rgdal)
library(sf)
library(raster)


## load in the shapefile (this is the old (notgood) line string data for 2009 and
## will need to be replaced)
s2 <- readRDS("/home/lg11b/risk_assessment/s1.rds")


## split the shapefile into multiple shapefiles based on step
#s2.sf <- st_as_sf(s2) ## convert the tbl_df to an sf object
#s2.spatial <- as(s2.sf, "Spatial") ## convert it to an SP object so we can use writeOGR
#unique.2 <- unique(s2.spatial@data$step) ## take teh unique steps
## this for loop splits teh shapefile into many shapefiles
## by step.
#for (i in 1:length(unique.2)) {
#  tmp <- s2.spatial[s2.spatial$step == unique.2[i], ] 
#  writeOGR(tmp, 
#           dsn="/home/lg11b/shapefiles",
#           unique.2[i], driver="ESRI Shapefile",
#           overwrite_layer=TRUE)
#}

## read in each shapefile individually
first <- readOGR("/home/lg11b/shapefiles", "01")
second <- readOGR("/home/lg11b/shapefiles", "02")
third <- readOGR("/home/lg11b/shapefiles", "03")
fifth <- readOGR("/home/lg11b/shapefiles", "05")


## convert the shapefiles from sp to sf objects
## so we can use dplyr
first.sf <- st_as_sf(first)
second.sf <- st_as_sf(second)
third.sf <- st_as_sf(third)
fifth.sf <- st_as_sf(fifth)

##compute the pleth
##write function to compute the mean SOG of each vessel
## within each grid cell
mean.sog.fun <- function(sf.shapefile){
  mean.sog <- sf.shapefile %>%
    ## group by grid id and then vessels id within each grid cell
    dplyr::group_by(grid_id, vessels_id) %>% 
    ## use summarise to compute the mean sog for each vessel in each grid cell 
    ## and store it in a column named mean.vessel.sog
    dplyr::summarise(mean.vessel.sog = mean(sog))
  return(mean.sog)
}

pleth.first <- mean.sog.fun(first.sf)
pleth.second <- mean.sog.fun(second.sf)
pleth.third <- mean.sog.fun(third.sf)
pleth.fifth <- mean.sog.fun(fifth.sf)


## write a function that takes the mean.vessel.sog within each grid
## cell and converts the speed to the probability of a lethal strike
## by using the logistic curve from Vanderlaan et al. 2007.Put this value
## in a column called "pleth".  Then calculate the mean pleth for each grid cell
## by taking the sum of all the pleth scores for each grid cell and dividing that
## by the number of distinct vessels that used the grid cell.

pleth.fun <- function(table){
  pleth.total <- table %>%
    ## convert the mean SOG for each vessel to a probability of ship strike
    ## using the Vanderlaan et al. 2007 logistic curve.  Store these
    ## values in a column called pleth.
    dplyr::mutate(pleth = dplyr::case_when(mean.vessel.sog <= 8 ~ .2,
                                           mean.vessel.sog > 8 & mean.vessel.sog < 10  ~ .3,
                                           mean.vessel.sog >= 10 & mean.vessel.sog < 12 ~ .4,
                                           mean.vessel.sog >= 12 & mean.vessel.sog < 16 ~.86,
                                           mean.vessel.sog >= 16 ~ 1)) %>%
    dplyr::group_by(grid_id) %>%
    ## sum the pleth for each grid cell and put in a column called pleth.grid
    dplyr::mutate(pleth.grid = sum(pleth)) %>%
    ## get the number of distinct vessels in each cell and put in a column called number.vessels
    dplyr::mutate(number.vessels = n_distinct(vessels_id)) %>%
    ## get the mean pleth for each cell by dividing the pleth.grid/number.vessels and put in
    ## a column called pleth.total
    dplyr::mutate(pleth.total = pleth.grid/number.vessels) 
  ##the above chunk uses mutate so we end up with multiple pleths
  ## of the same value for each grid.  Now remove the duplicates
  ## so we are left with only one value for each grid cell
  distinct.pleth <- pleth.total[!duplicated(pleth.total$grid_id),]
  return(distinct.pleth)
  
}

pleth.first.final <- pleth.fun(pleth.first)
pleth.second.final <- pleth.fun(pleth.second)
pleth.third.final <- pleth.fun(pleth.third)
pleth.fifth.final <- pleth.fun(pleth.fifth)

## convert to raster with pleth.total as the value for each cell
## using r which is the original grid we sent Jeff Adams.
r <- raster(ext = extent(-72, -63, 37, 46), res=c(360/8640,360/8640))
raster.first <- rasterize(pleth.first.final, r, "pleth.total")
raster.second <- rasterize(pleth.second.final, r, "pleth.total")
raster.third <- rasterize(pleth.third.final, r, "pleth.total")
raster.fifth <- rasterize(pleth.fifth.final, r, "pleth.total")
#create a raster stack of all the rasters


## write a function 
## to make the raster a dataframe to put in ggplot
function(raster){
  raster.spdf <- as(raster, "SpatialPixelsDataFrame")
  raster.df <- as.data.frame(raster.spdf)
  colnames(raster.df) <- c("value", "x", "y")
  return(raster.df)
}

raster.first.df <- raster2df(raster.first)
raster.second.df <- raster2df(raster.second)
raster.third.df <- raster2df(raster.third)
raster.fifth.df <- raster2df(raster.fifth)

## write the dataframe to an rda file that can then be pulled
## off the cluster and mapped

save(raster.first.df, file = "/home/lg11b/eg_risk_assessment/pleth.df/raster.first.df.rda")
save(raster.second.df, file = "/home/lg11b/eg_risk_assessment/pleth.df/raster.second.df.rda")
save(raster.third.df, file = "/home/lg11b/eg_risk_assessment/pleth.df/raster.third.df.rda")
save(raster.fifth.df, file = "/home/lg11b/eg_risk_assessment/pleth.df/raster.fifth.df.rda")






