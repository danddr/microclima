# Script to download and process climate and topographical data using microclima and NicheMapR

# Install necessary packages if not already installed
# devtools::install_github('mrke/NicheMapR')
# devtools::install_github("ilyamaclean/microclima")
# get.global.climate(folder="path")

# Load required libraries
library(terra)
library(microclima)
library(NicheMapR)
library(mapview)
library(plotly)

# ---- Download DEM for Trento, NE Italy ----
# Download a Digital Elevation Model (DEM) at 100m spatial resolution for Trento (latitude: 46.066667, longitude: 11.116667)
dem <- microclima::get_dem(lat = 46.066667, long = 11.116667, resolution = 100)

# Visualize the DEM
plot(dem)
mapview(dem)

# ---- Inspect Habitat Descriptors ----
# Access a dataset containing habitat descriptors used by the laifromhabitat() function in microclima
microclima::habitats

# ---- Run microclima Simulation for 2 Days ----
# Simulate microclimate for the DEM area for two days (18-19 June 2018) with 2m height above ground
temps <- microclima::runauto(dem, 
                             dstart = "18/06/2018", dfinish= "19/06/2018", 
                             hgt = 2,
                             l = NA, x = NA, coastal = FALSE,
                             habitat = "Deciduous broadleaf forest",
                             plot.progress = TRUE)

# ---- Explore Temperature Data ----
# The resulting array contains hourly temperature values (48 values in the third dimension)
class(temps$temps)  # Check the class of the temperature data
dim(temps$temps)    # Get the dimensions of the temperature array

# ---- Convert Hourly Temperature Data to Raster ----
# Convert the temperature array into a raster stack of hourly values
th <- terra::rast(temps$temps)
names(th) <- temps$tme  # Assign timestamps to raster layers
terra::time(th) <- temps$tme  # Set time for the raster layers

# Plot temperature for a specific hour (12:00 on 18th June 2018)
plot(th$`2018-06-18 12:00:00`)

# ---- Extract Summary Temperatures (Tmin, Tmax, Tmean) ----
# Access the mean, minimum, and maximum temperatures over the period of interest
myT <- c(temps$tmean, temps$tmin, temps$tmax)
names(myT) <- c("Mean temperature (°C) of 18-19/06/2018", 
                "Min temperature (°C) of 18-19/06/2018", 
                "Max temperature (°C) of 18-19/06/2018")

# Plot the extracted summary temperatures
plot(myT)

# ---- Interactive 3D Plot of Mean Temperature ----
# Create an interactive 3D surface plot with mean temperature overlaying the DEM
meantemp <- temps$tmean
zrange <- list(range = c(0, 2200))  # Set z-axis range for the plot (elevation in meters)

plot_ly(z = ~is_raster(dem)) %>%
  add_surface(surfacecolor = ~is_raster(meantemp)) %>%
  layout(scene = list(zaxis = zrange))  # Customize the z-axis range
