## load packages
library(sp)
library(maptools)
library(rgdal)

##
## get the sampling location data
## Get stations shapefile
tmp.dir <- "//deqhq1/tmdl/TMDL_WR/MidCoast/GIS/BacteriaTMDL/Beaches/Layers"
tmp.shp <- "stations_in_group_areas"
tmp.sp.stn <- readShapePoints(paste0(tmp.dir,"/",tmp.shp), proj4string = CRS("+proj=longlat +datum=NAD83"), verbose = FALSE,repair=FALSE)
unique(tmp.sp.stn$site)
