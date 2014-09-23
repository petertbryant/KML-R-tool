## load packages
library(sp)
library(maptools)
library(rgdal)

##
## get the list of bacteria stations and the assciated watersheds
## Get stations and coordinates from shapefile
tmp.dir <- "//deqhq1/tmdl/TMDL_WR/MidCoast/GIS/BacteriaTMDL/General/stations/"
tmp.shp <- "freshwater_stations_loc_modified_on_100KNHD_NAD_1983"
tmp.sp.stn <- readShapePoints(paste0(tmp.dir,tmp.shp), proj4string = CRS("+proj=longlat +datum=NAD83"), verbose = FALSE,repair=FALSE)
unique(tmp.sp.stn$TMDLWTSD)