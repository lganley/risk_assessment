# risk_assessment
right whale ship strike risk assessment

### Ideas for now
* We want to align ourselves with current rules on NOAA ship strike page https://www.fisheries.noaa.gov/national/endangered-species-conservation/reducing-ship-strikes-north-atlantic-right-whales
  + this may include using areas of SMA's and DMA's to see how risk changed during times when these rules were turned on.

### Ideas for later
* A shiny app that allows us to put in a date and serve to the community what the vessel traffic looked like during that time step
* we could take the above bullett a step further by serving the risk assessment map for that time period
* We could compare the backcasted posit of dead eg in CCB with risk assessment for that cell (talk to WAM about NARWC 2018 pres.) 

### make_grids.R 
file has code to make ~4.6 km and 1 km pixel raster grids for the Gulf of Maine.  
Originally we wanted 1 km grid cells, however when Jeff Adams pulled out the AIS data it became obvious
that this grid was too fine scale for the data and we were getting false positives.  
Particularly around Provincetown there were instances of vessels lighting up grid 
cells that they should not (for example, ferries were showing up in grid cells off Race Point
where they likely were not present).  So, we decided to increase the grid cell size to soak up some of these errors. 
The grid that is ~4.6 km lines up with the data that Dan already has.  Jeff is going to give us AIS data based on
the shapefile "whole.grid.poly.4".  

### pleth_clusters.R
file has code to compute the probability of a lethal shipe strike for each grid cell as described by Wiley et al. 2011.  This code uses the logistic model described in Vanderlaan et al. 2007 to convert the mean sog of each vessel to a probaility of a lethal strike if a vessel should hit a whale.  This file is meant to be run on the ghpcc.  
