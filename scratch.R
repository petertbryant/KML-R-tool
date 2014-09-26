## load packages
library(sp)
library(maptools)
library(foreign)
library(rgdal)
library(plotKML)
library(rgeos)

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
## get beaches in OR
tmp.sp.beach.ext.or <- tmp.sp.beach.ext[grep("^OR",tmp.sp.beach.ext$SRC_FEATID), ]



## get dbf file for beach attributes
tmp.dbf <-"beach_attributes.dbf"
tmp.beach.attr <- read.dbf(file=paste0(tmp.dir,"/",tmp.dbf))
## get beaches in OR
tmp.beach.attr.or <- tmp.beach.attr[tmp.beach.attr$BEACH_STAT == "OR",]
unique(as.character(tmp.beach.attr.or$BEACH_ID))
tmp.sp.beach.ext.or <- tmp.sp.beach.ext[grep("^OR",tmp.sp.beach.ext$SRC_FEATID), ]


## google CRS is "+init=epsg:4326"
tmp.sp.stn.on.beach.ext.KML <- spTransform(
  snapPointsToLines(points=tmp.sp.stn.ft,lines=tmp.sp.beach.ext.or.ft,maxDist=300),
  CRS("+init=epsg:4326"))
tmp.sp.beach.ext.or.KML <- spTransform(tmp.sp.beach.ext.or,CRS("+init=epsg:4326"))

##
## get the BEACON beach extents that are in the in Mid-Coast
## out the stations and the Oregon Beacon beach extentsin the same CRS
tmp.sp.beach.ext.or.KML <- spTransform(tmp.sp.beach.ext.or,CRS("+init=epsg:4326"))
tmp.sp.stn.KML <- spTransform(tmp.sp.stn,CRS("+init=epsg:4326"))
## create a polygon from the bounding box of the stations layer to use for clipping
clip.bbox <- cbind(floor(bbox(tmp.sp.stn.KML)[,1]),ceiling(bbox(tmp.sp.stn.KML)[,2]))
clip.rec <- rbind(c(clip.bbox[1,1],clip.bbox[2,2]),c(clip.bbox[1,2],clip.bbox[2,2]),c(clip.bbox[1,2],clip.bbox[2,1]),c(clip.bbox[1,1],clip.bbox[2,1]),c(clip.bbox[1,1],clip.bbox[2,2]))
clip.sp.rec <- SpatialPolygons(list(Polygons(list(Polygon(clip.rec)),1)))
proj4string(clip.sp.rec) <- CRS("+init=epsg:4326")
## select the beach extents that are in the stations layer bounding block
## this is "clipping" in the geometric set sense
tmp.vec.in <- as.vector(gIntersects(clip.sp.rec,tmp.sp.beach.ext.or.KML,byid=TRUE))
## beach extents in Mid-Coast by selecting rows of Oregeon beach extents
tmp.sp.beach.ext.or.mc.KML <- tmp.sp.beach.ext.or.KML[tmp.vec.in == TRUE,]
##
## snap sample location to beach extents
## transform to Oregon Lambert projection
tmp.sp.beach.ext.or.mc.ft <- spTransform(tmp.sp.beach.ext.or.mc.KML,CRS("+init=epsg:2992"))
tmp.sp.stn.ft <- spTransform(tmp.sp.stn,CRS("+init=epsg:2992"))
## check distances of stations to beach extent lines
shortest.dists <- numeric(nrow(tmp.sp.stn.ft))
for (i in seq_len(nrow(tmp.sp.stn.ft))) {
  shortest.dists[i] <- gDistance(tmp.sp.stn.ft[i,], tmp.sp.beach.ext.or.mc.ft)
}
df.shortest.dists <- data.frame(site=tmp.sp.stn.ft$site,dist_ft=round(shortest.dists,0))
summary(df.shortest.dists)

# there are 18 sites that are >= 100 ft from a beach extent
length(df.shortest.dists$dist_ft[df.shortest.dists$dist_ft > 1000])
df.shortest.dists[df.shortest.dists$dist_ft > 1000,]



tmp.sp.stn.on.ext.ft <- snapPointsToLines(points=tmp.sp.stn.ft,lines=tmp.sp.beach.ext.or.mc.ft,maxDist=5280)
tmp.sp.stn.on.ext.KML <- spTransform(tmp.sp.stn.on.ext.ft,CRS("+init=epsg:4326"))


kml(tmp.sp.stn.KML,labels=site, size=10, scale=1)
plotKML(tmp.sp.stn.KML,file="tmp.sp.stn.KML.kml")
plotKML(tmp.sp.stn.KML)


plotKML(tmp.sp.beach.ext.or.mc.KML)
plotKML(tmp.sp.stn.on.ext.KML)
## plot in google earth
plotKML(tmp.sp.stn.on.beach.ext.KML)
plotKML(tmp.sp.beach.ext.or.KML)
