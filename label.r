
  
library(magick)
library(MetBrewer)
library(colorspace)
library(glue)
library(stringr)
library(ggplot2)
library(extrafont)
loadfonts(device = "win", quiet = TRUE) ## load the fonts from your system
img <- image_read('final_plot.png')
colors <- met.brewer("Tam")
swatchplot(colors)
text_color <- darken(colors[5],.25)
swatchplot(text_color)


annot <- glue("Population estimates are bucketed into 400 meter (about 1/4 mile) ",
              "hexagons.") |> 
  str_wrap(40)

img |>
  image_annotate("Karnataka, India",
                 gravity = "northwest",
                 location = "+650+500",
                 color = text_color,
                 size = 400,
                 weight = 700,
                 font = "Berlin Sans FB Demi") |>
  image_annotate("Population Density Map",
                 gravity = "northwest",
                 location = "+650+350",
                 color = text_color,
                 size = 120,
                 weight = 700,
                 font =  "Berlin Sans FB Demi")|>
  image_annotate("Bengaluru",
                 gravity = "northeast",
                 location = "+650+3400",
                 color = text_color,
                 size = 120,
                 weight = 700,
                 font =  "Berlin Sans FB" ) |> 
  image_annotate(annot,
                 gravity = "northeast",
                 location = "+300+2000",
                 color = text_color,
                 size = 125,
                 font = "Berlin Sans FB") |>
  image_annotate(glue("By Abhishek | ",
                      "Data: Kontur Population (Released 2022-06-30)"),
                 gravity = "south",
                 location = "+0+100",
                 font = "Berlin Sans FB",
                 color = alpha(text_color, .5),
                 size = 100) |>
  image_write("titled_1_plot.png")
