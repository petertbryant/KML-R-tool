## load packages
library(sp)
library(maptools)
library(foreign)
library(rgdal)
library(plotKML)

##
## get the sampling location data
## Get stations shapefile
tmp.dir <- "//deqhq1/tmdl/TMDL_WR/MidCoast/GIS/BacteriaTMDL/Beaches/Layers"
tmp.shp <- "stations_in_group_areas"
tmp.sp.stn <- readShapePoints(paste0(tmp.dir,"/",tmp.shp), proj4string = CRS("+proj=longlat +datum=NAD83"), verbose = FALSE,repair=FALSE)
unique(tmp.sp.stn$site)
rm(tmp.dir,tmp.shp)


## get EPA BEACON beach extents
## downloaded shapefiles on 2014-09-23 from USEPA Geospatial downloads at
## http://water.epa.gov/scitech/datait/tools/waters/data/downloads.cfm#BEACH Datasets
## direct link address for shapefiles is:
## http://www.epa.gov/waters/data/rad_beach_20140804_shp.zip
## Get beach extent shapefile
tmp.dir <- "//deqhq1/tmdl/TMDL_WR/MidCoast/GIS/BacteriaTMDL/Beaches/EPA_Beach_Data/rad_beach_20140804_shp/rad_beach_20140804"
tmp.shp <- "rad_beach_l"
tmp.sp.beach.ext <- readShapeLines(paste0(tmp.dir,"/",tmp.shp), proj4string = CRS("+proj=longlat +datum=NAD83"), verbose = FALSE,repair=FALSE)
## get dbf file for beach attributes
tmp.dbf <-"beach_attributes.dbf"
tmp.beach.attr <- read.dbf(file=paste0(tmp.dir,"/",tmp.dbf))
## get beaches in OR
tmp.beach.attr.or <- tmp.beach.attr[tmp.beach.attr$BEACH_STAT == "OR",]
unique(as.character(tmp.beach.attr.or$BEACH_ID))
tmp.sp.beach.ext.or <- tmp.sp.beach.ext[grep("^OR",tmp.sp.beach.ext$SRC_FEATID), ]
## transform to Oregon Lambert projection
tmp.sp.beach.ext.or.ft <- spTransform(tmp.sp.beach.ext.or,CRS("+init=epsg:2992"))
tmp.sp.stn.ft <- spTransform(tmp.sp.stn,CRS("+init=epsg:2992"))

##tmp.beach.attr.or <- merge(x=tmp.sp.beach.ext.or,y=tmp.beach.attr.or, by.x="SRC_FEATID", by.y="BEACH_ID")



tmp.sp.stn.on.beach.ext.KML <- spTransform(
  snapPointsToLines(points=tmp.sp.stn.ft,lines=tmp.sp.beach.ext.or.ft,maxDist=300),
  CRS("+init=epsg:4326"))
tmp.sp.beach.ext.or.KML <- spTransform(tmp.sp.beach.ext.or,CRS("+init=epsg:4326"))


## trying to clip to get the beach lines only for the extent of the stations. 
## I can clip the geometry, but I lose the attribute from "tmp.sp.beach.ext.or.KML"
## which means I lose the names of the beaches. This is what I wanted in the first place!!!

clip.bbox <- cbind(floor(bbox(tmp.sp.stn.on.beach.ext.KML)[,1]),ceiling(bbox(tmp.sp.stn.on.beach.ext.KML)[,2]))
junk.box <- rbind(c(clip.bbox[1,1],clip.bbox[2,2]),c(clip.bbox[1,2],clip.bbox[2,2]),c(clip.bbox[1,2],clip.bbox[2,1]),c(clip.bbox[1,1],clip.bbox[2,1]),c(clip.bbox[1,1],clip.bbox[2,2]))

junk.poly <- Polygon(junk.box)
junk.polys <- Polygons(list(junk.poly),1)
junk.sp.polys <- SpatialPolygons(list(junk.polys))
proj4string(junk.sp.polys) <- CRS("+init=epsg:4326")
junk.sp.polys.df <- SpatialPolygonsDataFrame(junk.sp.polys,data.frame(a=99.9))

junk <- gIntersection(junk.sp.polys.df,tmp.sp.beach.ext.or.KML)

junk.U <- gUnion(junk,tmp.sp.beach.ext.or.KML)
names(junk.U)
names(tmp.sp.beach.ext.or.KML)
summary(junk)
junk$SRC_FEATID
str(junk)
plot(junk)
junk.sp.df <- SpatialLinesDataFrame(junk,data.frame(a=rep(-1,length(junk))))
names(junk)
plotKML()
summary(junk.sp.polys.df)

plotKML(junk.sp.polys.df)

## plot in google earth
plotKML(tmp.sp.stn.on.beach.ext.KML)
plotKML(tmp.sp.beach.ext.or.KML)
