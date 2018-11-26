################################
################################
### Libraries
library(sf)
library(sp)
library(rgdal)
library(raster)
library(R.matlab)
library(rasterVis)
################################
################################

## write a function that takes a lat, long and cell size of 9/999
## and tells you the row and columns of the raster.  The floor 
## part of print rounds the row number and column numbers down
## if it isn't quite in any cell.
latlon2cell <- function(lat,lon,cellsize){
  
  ROW=((46-lat)/cellsize)+1
  COL=((lon-(-72))/cellsize)+1
  
  print(floor(ROW)) ## we can remove the floor and floor it after the fact
  print(floor(COL))
  
}


## make a raster in WGS84 with the extent of
## lat = 37, 46 and long = -72, -63 to match Dan's previous analysis.
## we also want the resolution to be .009009009 x .009009009
## .009009009 is equivalent to 1 km pixels.  In the end
## the raster should have 999 rows and 999 columns.
r <- raster(ext = extent(-72, -63, 37, 46), res=c(0.009009009,0.009009009)) ## this needs to be changed to 360/8640 this should be the number of degrees per pixel (4 km grid cell size)
p <- rasterToPolygons(r) 

## write the raster of the whole area with no 1's to a tif file
writeRaster(r, filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/grid.lat37.46.long72.63", format = 'GTiff', overwrite = TRUE)



########
########
## CCB DOMAIN
########
########

## make everything in r a 0
r[] <-0
##find the rows and columns of the corners -70.8, -69.5 
## and lat = 41.67 and 42.2
latlon2cell(41.67, -70.8, 9/999)
latlon2cell(42.2, -69.5, 9/999)

## then make the rows and columns of the corners have 1's
#r[row1:row2, col1:col2] <-1
r[481:422, 134:278] <-1
plot(r)


## write raster to a tif file
writeRaster(r, filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/gridCCB", format = 'GTiff', overwrite = TRUE)




## plot the raster with some states to make sure everything looks ok.
# load some spatial data. Administrative Boundary
#us <- getData('GADM', country = 'US', level = 1)
#us$NAME_1
#Massachusetts <- us[us$NAME_1 == "Massachusetts",]
#nh <- us[us$NAME_1 == "New Hampshire",]
#maine <- us[us$NAME_1 == "Maine",]
#ri <- us[us$NAME_1 == "Rhode Island", ]
#plot(p)
##plot(Massachusetts, add = TRUE)
#plot(nh, add = TRUE)
#plot(maine, add = TRUE)


########
########
## Southern GOM and GSC plus 30 DOMAIN
########
########

## put 1's in the pixels of the raster
## in the spatial extent of Southern Maine (Jeffreys)
## to New York long = -72.0, -68.0 and lat = 40.0, 43.5
## includes GSC + 30
## make everything in r a 0
r[] <-0

## find the rows and columns of the corners
latlon2cell(40.0, -72.0, 9/999)
latlon2cell(43.5, -68.0, 9/999)

## then make the rows and columns of the corners have 1's
#r[row1:row2, col1:col2] <-1
r[667:278, 1:445] <-1
plot(r)


## write raster to a tif file
writeRaster(r, filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/gridsouthGOMGSCplus30", format = 'GTiff')


########
########
## southern GOM DOMAIN
########
########

## put 1's in the pixels of the raster
## in the spatial extent of Southern Maine (Jeffreys)
## to New York long = -72.0, -69.5 and lat = 40.0, 43.5
## does not include GSC + 30

## make everything in r a 0
r[] <-0

## find the rows and columns of the corners
latlon2cell(40.0, -72.0, 9/999)
latlon2cell(43.5, -69.5, 9/999)

## then make the rows and columns of the corners have 1's
#r[row1:row2, col1:col2] <-1
r[667:278, 1:278] <-1
plot(r)


## write raster to a tif file
writeRaster(r, filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/gridsouthGOM", format = 'GTiff')



########
########
## GOM DOMAIN
########
########

## put 1's in the pixels of the raster in teh 
## spatial extent of the Gulf of Maine
## lat = 40.0, 45.5 and long = -72.0, -63.0
r[] <- 0
## find the rows and columns of the corners
latlon2cell(40.0, -72.0, 9/999)
latlon2cell(45.5, -63.0, 9/999)

## then make the rows and columns of the corners have 1's
#r[row1:row2, col1:col2] <-1
r[667:56, 1:1000] <-1
plot(r)

## write to raster to a tif file
writeRaster(r, filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/gridGOM", format = 'GTiff', overwrite = TRUE)


### next I need to input the matlab raster dan gave me 
### that has bathy and land.  turn the appropriate cells
## from the above code "on".  And Dan said turn everything less than (deeper)
## -700 m off, and > 5m (land) off.  BUT the bathy file Dan sent me had a max
## value of 4.10, so there was nothing >5 to shut off.  So, I shut off everything
## > 0.  The plot looks roughly right.

#### read in matlab bathy grid from Dan
pathname <- file.path("/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/", "baE.mat")
bathy <- readMat(pathname)

## convert the list to a raster setting it WGS84 with the same extent as the grid
mapmap <- raster(bathy$baE, 
                 xmn = -72, xmx = -63, ymn = 37, ymx = 46,
                 crs = CRS("+proj=longlat +datum=WGS84"))

levelplot(mapmap)

r <- raster(ext = extent(-72, -63, 37, 46), res=c(0.009009009, 0.009009009))
## this takes the GOM grid that is a square and includes land and deep water
## it then takes the bathyfile that dan sent me and turns anything deeper 
## than 700 (m?) and turns it to 0, and anything greater than 0 (land) 
## and turns it to 0.
r[667:56, 1:1000] <-1
r[mapmap < -700] <- 0 ## anything wihtin r that mapmap has as deeper than 700 m make 0
r[mapmap > 0] <- 0
r[is.na(mapmap[])] <- 0 ## this makes the na rim on the outside 0




gplot(r) +  
  geom_raster(aes(fill=factor(value))) + 
  scale_fill_manual(values = c("gray", "royalblue4")) +
  #coord_equal() +
  labs(x = "Longitude", y = "Latitude", title = "GOM domain") +
  theme_light() +
  theme(plot.title = element_text(hjust = 0.5)) +
  ggsave('/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/GOMbathy.png',
         width = 6, height = 5)


########
## clip the raster grid with the massachusetts polygon
us <- getData("GADM", country="USA", level=1)
# extract states (need to uppercase everything)
nestates <- c("Maine", "Massachusetts", "New Hampshire" ,"Connecticut",
              "Rhode Island","New York", "Vermont")

ne = us[match(toupper(nestates),toupper(us$NAME_1)),]


r <- raster(ext = extent(-72, -63, 37, 46), res=c(0.009009009,0.009009009))
## this takes the GOM grid that is a square and includes land and deep water
## it then takes the bathyfile that dan sent me and turns anything deeper 
## then 700 (m?) and turns it to 0, and anything greater than 0 (land) 
## and turns it to 0.
r[667:56, 1:1000] <-1
r[mapmap < -700] <- 0 ## anything wihtin r that mapmap has as deeper than 700 m make 0
r[is.na(mapmap[])] <- 0 ## this makes the na rim on the outside 0


# plot the raster with the boundaries we want to clip against:
plot(r)
plot(ne,add=TRUE)

# now use the mask to mask the raster with teh states
r1 <- mask(r, ne, updatevalue = 0, inverse = TRUE)

# plot, and overlay:
plot(r1);plot(ne,add=TRUE)

gplot(r1) +  
  geom_raster(aes(fill=factor(value))) + 
  scale_fill_manual(values = c("gray", "royalblue4")) +
  #coord_equal() +
  labs(x = "Longitude", y = "Latitude", title = "GOM domain") +
  theme_light() +
  theme(plot.title = element_text(hjust = 0.5)) #+
 ggsave('/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/GOMwithMask.png',
        width = 6, height = 5)


 #######################################################
 #######################################################
 #######################################################
 ############# 4 km GRID CELL SIZE
 #######################################################
 #######################################################
 #######################################################
 

### We changed our minds and want a 4.6 km grid not 1 km grid.
## we want to know if 1 km grid and 4.6 km grid line up at edge
## of the 1 km grid 

## our 999X999 grid has a cell size of 9/999 = .009009009
## our 4.6 grid has cell size of 360/8640 pixels = 0.04166667

 ## make a raster in WGS84 with the extent of
 ## lat = 37, 46 and long = -72, -63 to match Dan's previous analysis.
 ## we also want the resolution to be 0.0416667 X 0.04166667
 ## which is equivalent to 4.6 km pixels.  In the end
 ## the raster should have 216 rows and 216 columns.
 r <- raster(ext = extent(-72, -63, 37, 46), res=c(0.04166667,0.04166667))
 p <- rasterToPolygons(r) 
 
 ## write the raster of the whole area with no 1's to a tif file
 writeRaster(r, 
             filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/grid.4km.lat37.46.long72.63", format = 'GTiff', overwrite = TRUE)
 
 
 ########
 ########
 ## CCB DOMAIN
 ########
 ########
 
 ## make everything in r a 0
 r[] <-0
 ##find the rows and columns of the corners -70.8, -69.5 
 ## and lat = 41.67 and 42.2
 latlon2cell(41.67, -70.8, 360/8640) ## this gives the row first then the column
 latlon2cell(42.2, -69.5, 360/8640)
 

 ## then make the rows and columns of the corners have 1's
 #r[row1:row2, col1:col2] <-1
 r[104:92, 29:61] <-1
 plot(r)
 
 
 ## write raster to a tif file
 writeRaster(r, filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/gridCCB_4km", format = 'GTiff', overwrite = TRUE)
 
 plot(rasterToPolygons(r), add=TRUE, border='black', lwd=1)
 
 
 ## plot the raster with some states to make sure everything looks ok.
 # load some spatial data. Administrative Boundary
 us <- getData('GADM', country = 'US', level = 1)
 us$NAME_1
 Massachusetts <- us[us$NAME_1 == "Massachusetts",]
 #nh <- us[us$NAME_1 == "New Hampshire",]
 #maine <- us[us$NAME_1 == "Maine",]
 #ri <- us[us$NAME_1 == "Rhode Island", ]
 plot(rasterToPolygons(r), border='black', lwd=1)
 plot(Massachusetts, add = TRUE)
 #plot(nh, add = TRUE)
 #plot(maine, add = TRUE)
 
 
 ########
 ########
 ## Southern GOM and GSC plus 30 DOMAIN
 ########
 ########
 
 ## put 1's in the pixels of the raster
 ## in the spatial extent of Southern Maine (Jeffreys)
 ## to New York long = -72.0, -68.0 and lat = 40.0, 43.5
 ## includes GSC + 30
 ## make everything in r a 0
 r[] <-0
 
 ## find the rows and columns of the corners
 latlon2cell(40.0, -72.0, 360/8640)
 latlon2cell(43.5, -68.0, 360/8640)
 
 ## then make the rows and columns of the corners have 1's
 #r[row1:row2, col1:col2] <-1
 r[145:61, 1:97] <-1
 plot(r)
 
 
 ## write raster to a tif file
 writeRaster(r, filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/grid_4km_southGOMGSCplus30", format = 'GTiff')
 
 
 ########
 ########
 ## southern GOM DOMAIN
 ########
 ########
 
 ## put 1's in the pixels of the raster
 ## in the spatial extent of Southern Maine (Jeffreys)
 ## to New York long = -72.0, -69.5 and lat = 40.0, 43.5
 ## does not include GSC + 30
 
 ## make everything in r a 0
 r[] <-0
 
 ## find the rows and columns of the corners
 latlon2cell(40.0, -72.0, 360/8640)
 latlon2cell(43.5, -69.5, 360/8640)
 
 ## then make the rows and columns of the corners have 1's
 #r[row1:row2, col1:col2] <-1
 r[145:61, 1:61] <-1
 plot(r)
 
 
 ## write raster to a tif file
 writeRaster(r, filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/gridsouthGOM_4km", format = 'GTiff')
 
 
 
 ########
 ########
 ## GOM DOMAIN
 ########
 ########
 
 ## put 1's in the pixels of the raster in the 
 ## spatial extent of the Gulf of Maine
 ## lat = 40.0, 45.5 and long = -72.0, -63.0
 r[] <- 0
 ## find the rows and columns of the corners
 latlon2cell(40.0, -72.0, 360/8640)
 latlon2cell(45.5, -63.0, 360/8640)
 
 ## then make the rows and columns of the corners have 1's
 #r[row1:row2, col1:col2] <-1
 r[145:13, 1:216] <-1 ## there should only be 216 cells so this might be an issue (the funciton says 217)
 plot(r)
 
 ## write to raster to a tif file
 writeRaster(r, filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/gridGOM_4km", format = 'GTiff', overwrite = TRUE)
 
 
 ##########################
 ##########################
 ## see if the 1 km grid 
 ## fits in the 4 km grid
 ##########################
 ##########################
 
 ## 1 km grid
 r1 <- raster(ext = extent(-72, -63, 37, 46), res=c(0.009009009,0.009009009)) 
 
 ## 4 km grid
 r <- raster(ext = extent(-72, -63, 37, 46), res=c(0.04166667,0.04166667))
 
 ## make everything in r a 0
 r1[] <-0
 r[] <-0 
 
 e <- extent(-71.0, -70.5, 41.5, 42.0) ## this is the extent of a zoomed in part of CCB
 us.crp <- crop(r, e) ## crop the 4 km raster (r) to extent e
 plot(us.crp) ## plot the 4 km raster at extent e
 plot(rasterToPolygons(us.crp), add=TRUE, border='black', lwd=1) ## add the black cell lines
 
 us.crp.1 <- crop(r1, e) ## crop the 1 km grid to the extent e
 plot(us.crp.1) ## plot the 1 km grid at extent e
 plot(rasterToPolygons(us.crp.1), add=TRUE, border='black', lwd=1) ## 1 km grid cells
 plot(rasterToPolygons(us.crp), add=TRUE, border='red', lwd=1) ## 4 km grid cells
 
 
 ## what happens in the top left corner of the main grid (-72, -63, 37, 46)
 r1 <- raster(ext = extent(-72, -63, 37, 46), res=c(0.009009009,0.009009009)) 
 r <- raster(ext = extent(-72, -63, 37, 46), res=c(0.04166667,0.04166667))
 r1[] <- 0
 r[] <- 0
 ex <- extent(-72, -71.5, 45.5, 46.0)
 main.crp <- crop(r1, ex)
 main.crp.4 <- crop(r, ex)
 plot(main.crp) ## plot hte 1 km grid
 plot(rasterToPolygons(main.crp), add = TRUE, border = 'black', lwd = 1) ## 1 km grid cells
 plot(rasterToPolygons(main.crp.4), add =TRUE, border = 'red', lwd = 1) ## 4 km grid cells
 

 
 
 ## Make sure the global grid and our grid overlap
 ## make a global grid with extent -180 long and 90 lat with cell 
 ## size 360/8640 = 0.04166667 for 4.6 km grid
 global.grid <- raster(ext = extent(-180, 0, 0, 90), res=c(0.04166667, 0.04166667))
 global.grid.raster <- writeRaster(global.grid,
                                   filename = "/Users/laura.ganley001/Documents/R_Projects/eg_risk_assessment/global.grid.4.6km", format = 'GTiff', overwrite = TRUE)

 
 ## OUR 4 km grid
 r <- raster(ext = extent(-72, -63, 37, 46), res=c(0.04166667,0.04166667))
 
 ## make everything in r and the global grid a 0
 r[] <-0 
 global.grid[] <- 0
 
e <- extent(-72, -71.5, 45.5, 46) ## this is the corner of OUR grid
global.crp <- crop(global.grid, e) ## crop the global grid to extent e
r4.crp <- crop(r, e) ## crop our 4 km raster to the same extent e
 
plot(global.crp) ## plot the global grid at extent e
plot(rasterToPolygons(global.crp), add=TRUE, border='black', lwd=1) ## add the black cell lines around the global grid
plot(rasterToPolygons(r4.crp), add = TRUE, border = 'red', lwd = 1) ## add red cell lines around OUR grid
 
 
###### SEE if the png of Dan's CCB grid that he sent me via email on 11/20/2018
### matches what our CCB grid would be
e <- extent(-71, -69, 41.5, 42.5) ## this is the corner of OUR grid
ccb.crp <- crop(r, e) ## crop the grid to extent e


## plot the raster with some states to make sure everything looks ok.
# load some spatial data. Administrative Boundary
us <- getData('GADM', country = 'US', level = 1)
us$NAME_1
Massachusetts <- us[us$NAME_1 == "Massachusetts",]
plot(rasterToPolygons(ccb.crp), border='black', lwd=1)
plot(Massachusetts, add = TRUE)
###### LOOKS PRETTY GOOD :)



##################################
#################################
#*****************DON'T FORGET TO UPDATE THIS ON THE EXTERNAL 
#*****************IF YOU CHANGE SOMETHING!!!!!
##################################
#################################
