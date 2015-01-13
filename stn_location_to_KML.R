## load packages
library(sp)
library(maptools)
library(foreign)
library(rgdal)
library(plotKML)
library(rgeos)
library(brew)
library(RColorBrewer)

options(stringsAsFactors = FALSE)

## my-functions
#source("BEACON_functions.R")

## parameters
tmp.dir <- "//deqhq1/tmdl/TMDL_WR/MidCoast/Models/Sediment/SSN/LSN05/lsn.ssn"
tmp.shp <- "sites.shp"

##
## get csv data information and set data types in files
tmp.stn.data <- read.csv('stns_for_ge.csv')
# chr.csv.file.names <- list.files(path=chr.dir.csv.files, pattern="[0-9]\\.csv$",full.names=TRUE)
# col.classes <- c(rep("character",5),rep("numeric",3))
# ## create df to hold stat and description info
# tmp.stats <- data.frame(site=rep(NA,length(chr.csv.file.names)),
#                         N=rep(NA,length(chr.csv.file.names)),
#                         NaboveCrit=rep(NA,length(chr.csv.file.names)),
#                         dte.start=as.POSIXct(rep(NA,length(chr.csv.file.names))),
#                         dte.end=as.POSIXct(rep(NA,length(chr.csv.file.names))), 
#                         lat.GE=rep(NA,length(chr.csv.file.names)),
#                         lon.GE=rep(NA,length(chr.csv.file.names)),
#                         stringsAsFactors=FALSE)
# ## get site specific information
# for(jj in 1:length(chr.csv.file.names)) {
#   ## get data for sampling location from the csv file
#   ## this ensures the same data used in the plot is provided
#   tmp.data <- read.csv(file=chr.csv.file.names[jj], colClasses = col.classes)
#   ## convert date.time from character to POSIXct date-time class
#   tmp.data$date <- as.POSIXct(tmp.data$date.time)
#   ## all data
#   tmp.stats$site[jj] <- unique(tmp.data$site)
#   tmp.stats$N[jj] <- length(tmp.data$value)
#   tmp.stats$NaboveCrit[jj] <- length(tmp.data[tmp.data$value >= num.crit,"value"])
#   tmp.stats$dte.start[jj] <- as.POSIXct(min(tmp.data$date.time))
#   tmp.stats$dte.end[jj] <- as.POSIXct(max(tmp.data$date.time))
#   rm(tmp.data)
#   
# }
# ## create links for each site
# tmp.links <- data.frame(source.form.url=rep(NA,length(tmp.stats$site)),
#                         boxplot.url=rep(NA,length(tmp.stats$site)),
#                         ts.url=rep(NA,length(tmp.stats$site)),
#                         desc.stat.url=rep(NA,length(tmp.stats$site)),
#                         data.file.csv.url=rep(NA,length(tmp.stats$site)),
#                         stringsAsFactors=FALSE
#                         )
# for(hh in 1:length(tmp.stats$site)) {
#   tmp.links$source.form.url[hh] <- paste0("https://docs.google.com/forms/d/14SpokgJPY-VNxbR8rHG6gqluTNQrASwOHMQNaAaCPCs/viewform?entry.1786451981=",tmp.stats$site[hh],"&amp",";","entry.977364261")
#   tmp.links$boxplot.url[hh] <- paste0("https://s3-us-west-2.amazonaws.com/midcoastbeaches/graph_files/location_",tmp.stats$site[hh],"_boxplot.png")
#   tmp.links$ts.url[hh] <- paste0("https://s3-us-west-2.amazonaws.com/midcoastbeaches/graph_files/location_",tmp.stats$site[hh],"_ts.png")
#   tmp.links$desc.stat.url[hh] <- paste0("https://s3-us-west-2.amazonaws.com/midcoastbeaches/desc_stat_html_files/desc_stat_",tmp.stats$site[hh],".html")
#   tmp.links$data.file.csv.url[hh] <- paste0("https://s3-us-west-2.amazonaws.com/midcoastbeaches/csv_files/data_",tmp.stats$site[hh],".csv")
# }

##
## get the sampling location data
# NAD_1983_Contiguous_USA_Albers
# WKID: 5070 Authority: EPSG
tmp.sp.stn <- readShapeSpatial(paste0(tmp.dir,"/",tmp.shp),proj4string = CRS("+init=epsg:5070"))
# tmp.stn.locs <- read.csv(paste0(tmp.stn.dir,"/",tmp.stn.csv))
# ## create and save stations shapefile
# tmp.sp.stn <- SpatialPointsDataFrame(coords=tmp.stn.locs[,c("lon","lat")], data=tmp.stn.locs[,c("site","data_sourc")], proj4string = CRS("+proj=longlat +datum=NAD83"))
# writeOGR(tmp.sp.stn, dsn=".", layer= "beach_stn_location", driver = "ESRI Shapefile", overwrite_layer=TRUE)
# ## clean up
# rm(tmp.stn.locs)

#Pull in mid coast for processing
midcoast <- readShapeSpatial("C:/Users/pbryant/desktop/midcoasttmdl-GIS/owrd_midcoast.shp",proj4string = CRS("+init=epsg:2992"))
midcoast.GE <- spTransform(midcoast,CRS("+init=epsg:4326"))

#order.to.keep <- data.frame('r' = row.names(tmp.sp.stn@data), 'SVN' = tmp.sp.stn@data$SVN)

tmp.sp.stn@data <- base::merge(tmp.sp.stn@data, tmp.stn.data, by = 'SVN', suffixes = c('','.y'), sort = FALSE)

tmp.sp.stn@data <- tmp.sp.stn@data[,names(tmp.stn.data)]

#tmp.sp.stn@data <- tmp.sp.stn@data[match(as.character(tmp.sp.stn@data$SVN), as.character(order.to.keep$SVN)),]

row.names(tmp.sp.stn@data) <- as.character(as.numeric(row.names(tmp.sp.stn@data))-1)
##
##
## tranform to CRS used by Google Earth ("+init=epsg:4326")
tmp.sp.stn.GE <- spTransform(tmp.sp.stn,CRS("+init=epsg:4326"))

#find stations in midcoast
midcoast.stn <- over(midcoast.GE,tmp.sp.stn.GE,returnList=TRUE)

##
## get coordinates from sp in Google Earth CRS
for(gg in 1:length(tmp.sp.stn.GE$SVN)) {
  tmp.sp.stn.GE$lat.GE[gg] <- tmp.sp.stn.GE@coords[gg,2]
  tmp.sp.stn.GE$lon.GE[gg] <- tmp.sp.stn.GE@coords[gg,1]
}

#Split data frame into 3 different layers
#One for impairments with sediment 
tmp.sp.stn.GE.sed <- tmp.sp.stn.GE[!is.na(tmp.sp.stn.GE$TMDL_Target),]
tmp.sp.stn.GE.sed$SedStress <- "Yes"
#One for the rest
tmp.sp.stn.GE.rest <- tmp.sp.stn.GE[!tmp.sp.stn.GE$SVN %in% as.character(tmp.sp.stn.GE.sed$SVN),]
tmp.sp.stn.GE.rest[grep('dfw|CTSI',tmp.sp.stn.GE.rest$STATION_KEY),'Impaired'] <- 'Not assessed'
tmp.sp.stn.GE.rest[!tmp.sp.stn.GE.rest$STATION_KEY %in% midcoast.stn[1][[1]]$STATION_KEY,'Impaired'] <- 'Outside Mid Coast'
tmp.sp.stn.GE.rest[tmp.sp.stn.GE.rest$STATION_KEY %in% c(34658,34659,34672,33363,25295,33329,23826,33331,34670,35689),'Impaired'] <- "Yes"
tmp.sp.stn.GE.rest$SedStress <- "No"

##
## write KML files for Google Earth
brew(file="./stn_placemark_brew_selmod.kmlt",output="SourceAnalysisDevelopmentStations.kml")
#brew(file="./stn_bimp_placemark_brew.kmlt",output="stn_imp_placemark_brew.kml")
brew(file="./stn_sstress_placemark_brew_selmod.kmlt",output="SedimentStressorStations.kml")
## done
