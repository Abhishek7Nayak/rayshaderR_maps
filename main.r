install.packages('sf')
install.packages('tigris')
install.packages('tidyverse')
install.packages('stars')
install.packages('MetBrewer')
install.packages('colorspace')
install.packages('sp')
install.packages('RColorBrewer')
remotes::install_github("tylermorganwall/rayrender")
remotes::install_github("tylermorganwall/rayshader")



library(sf)
library(tigris)
library(tidyverse)
library(stars)
library(rayshader)
library(MetBrewer)
library(colorspace)
library(sfheaders)
library(rayrender)
library(remotes)
# load data
data <- st_read('kontur_population_IN_20220630.gpkg')

# load karnataka
############################################################################################              
state_level_map <- raster::getData("GADM", country = "India", level = 1) %>% st_as_sf() %>% filter(NAME_1 == "Karnataka")   
# Change crs for intersection
state_level_map <- st_transform(state_level_map, crs= st_crs(data))
state_level_map |> 
  ggplot() +
  geom_sf()

# do intersection on data to limit kontur to Karnataka

st_kar <- st_intersection(data, state_level_map)
# define aspect ratio based on bounding box

bb <- st_bbox(st_kar)

bottom_left <- st_point(c(bb[["xmin"]], bb[["ymin"]])) |> 
  st_sfc(crs = st_crs(data))


bottom_right <- st_point(c(bb[["xmax"]], bb[["ymin"]])) |> 
  st_sfc(crs = st_crs(data))

# check by plotting points

state_level_map |> 
  ggplot() +
  geom_sf() +
  geom_sf(data = bottom_left) +
  geom_sf(data = bottom_right, color = "red")

width <- st_distance(bottom_left, bottom_right)

top_left <- st_point(c(bb[["xmin"]], bb[["ymax"]])) |> 
  st_sfc(crs = st_crs(data))

height <- st_distance(bottom_left, top_left)

# handle conditions of width or height being the longer side

if (width > height) {
  w_ratio <- 1
  h_ratio <- height / width
} else {
  h_ratio <- 1
  w_ratio <- width / height
}

# convert to raster so we can then convert to matrix

size <- 4000

kar_rast <- st_rasterize(st_kar, 
                             nx = floor(size * as.numeric(w_ratio)),
                             ny = floor(size * as.numeric(h_ratio)))

mat <- matrix(kar_rast$population, 
              nrow = floor(size * w_ratio),
              ncol = floor(size * h_ratio))



# create color palette

c1 <- met.brewer("Tam")
swatchplot(c1)
texture <- grDevices::colorRampPalette(c1[1:6], bias = 2)(256)
swatchplot(texture)
# plot that 3d thing!
swatchplot(c1[3])

rgl::rgl.close()

mat |> 
  height_shade(texture = texture) |> 
  plot_3d(heightmap = mat,
          zscale = 100 / 4,
          solid = FALSE,
          shadowdepth = 0)

render_camera(theta = -20, phi = 50, zoom = .7)


outfile <- "final_plot.png"

{
  start_time <- Sys.time()
  cat(crayon::cyan(start_time), "\n")
  if (!file.exists(outfile)) {
    png::writePNG(matrix(1), target = outfile)
  }
  render_highquality(
    filename = outfile,
    interactive = FALSE,
    lightdirection = 280,
    lightaltitude = c(20, 80),
    lightcolor = c(c1[3], "white"),
    lightintensity = c(600, 100),
    samples = 450,
    width = 6000,
    height = 6000
  )
  end_time <- Sys.time()
  diff <- end_time - start_time
  cat(crayon::cyan(diff), "\n")
}