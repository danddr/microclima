# devtools::install_github("ilyamaclean/microclima")
library(raster)
library(sf)
library(microclima)
library(NicheMapR)
library(elevatr)
library(mapview)

#select location: somewhere in Spain
him <- data.frame(lat = 42, long= 1)
him<-sf::st_as_sf(him, coords=c("long", "lat"), crs=4326)  

#get elevation data
dem <- elevatr::get_elev_raster(locations = him,  z = 10)
mapview(dem)

# alternatives for DEM
#bbox <- extent(10.5,11.5,45.6, 46.5)
#bbox <- as(bbox,"SpatialPolygons")
#aoi <- crop(srtm, bbox)
#you can play to get a better DEM
#dem <- microclima::get_dem(lat = 49.97, long = -5.22, resolution = 100)
#dem <- microclima::get_dem(aoi, resolution = 100) 

#just crom the dem to save computation time
raster::extent(dem)
subBbox<-as(raster::extent(c(0.9,1.0,41.9,42.0)), "SpatialPolygons")
proj4string(subBbox)<-proj4string(dem)
plot(dem)
plot(subBbox, add=T)
srtm<- raster::crop(dem, subBbox)

# aggregate to save computational time
srtm <- raster::aggregate(srtm, fact=4)

#run microclima for a couple of days
temps <- microclima::runauto(srtm, "18/06/2018", "19/06/2018", hgt = 0.05,
                             l = NA, x = NA, coastal = F,
                             habitat = "Barren or sparsely vegetated",
                             plot.progress = TRUE)
temps$tmean


