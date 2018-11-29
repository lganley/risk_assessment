# risk_assessment
right whale ship strike risk assessment

The make_grids.R file has code to make ~4.6 km and 1 km pixel raster grids for the Gulf of Maine.  
Originally we wanted 1 km grid cells, however when Jeff Adams pulled out the AIS data it became obvious
that this grid was too fine scale for the data and we were getting false positives.  
Particularly around Provincetown there were instances of vessels lighting up grid 
cells that they should not (for example, ferries were showing up in grid cells off Race Point
where they likely were not present).  So, we decided to increase the grid cell size to soak up some of these errors. 
The grid that is ~4.6 km lines up with the data that Dan already has.  Jeff is going to give us AIS data based on
the shapefile "whole.grid.poly.4".  
