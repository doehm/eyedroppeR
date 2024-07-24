
library(ggforce)
library(ggfx)
library(dplyr)
library(tidyr)
library(gt)
library(gtExtras)
library(stringr)
library(magick)
library(showtext)

font_add_google("Poppins", "poppins")
showtext_auto()

x <- generate_palette(4, "anime style picture, hi-res, japanese cherry blossoms and mount fuji")
pal <- x$pal
pal <- c('#3F3A3F', '#AF8290', '#D3C6DA', '#6F96D0')
swatch(pal, x$eyedropper$img_path, .padding = 4)

swatch(pal, "C:\\Users\\danie\\AppData\\Local\\Temp\\RtmpKan5Pm\\file64a02c6c5ea7", .padding = 4)

x <- extract_pal(8, "https://scontent-atl3-1.cdninstagram.com/v/t51.29350-15/452157403_1408150999872775_7030408167239539246_n.jpg?stp=dst-jpg_e35&cb=9ad74b5e-a62970cb&efg=eyJ2ZW5jb2RlX3RhZyI6ImltYWdlX3VybGdlbi4xNDQweDE3ODMuc2RyLmYyOTM1MC5wanBnX3E4MF8wNzEwIn0&_nc_ht=scontent-atl3-1.cdninstagram.com&_nc_cat=107&_nc_ohc=CighHKzCXAsQ7kNvgEGLSx3&gid=c5aa8e4b7c634097b8e58fcbf73bf95c&edm=APs17CUBAAAA&ccb=7-5&ig_cache_key=MzQxNzA3Mzg1OTQxNTIwNjUxNA%3D%3D.2-ccb7-5&oh=00_AYAPgV5jrOsz9PYWIUyYVMxW7CBnQJdcRgtEWAtspZp7vg&oe=66A3B3AA&_nc_sid=10d13b")
swatch(x$pal[c(1:5, 8:6)], x$img_path, .padding = 4)

pal <- x$pal[c(1, 3, 6, 8)]
ft <- "poppins"
txt <- c(4, 4, 1, 1)
.folder <- "misty-forest"

for(k in 1:length(pal)) {

  .rgb <- paste0(as.numeric(t(col2rgb(pal[k]))), collapse = ", ")

  ggplot() +
    geom_circle(aes(x0 = 0.5, y0 = 0.5, r = 0.5), fill = pal[k], colour = NA) +
    annotate("text", x = 0.5, y = 0.84, label = "Hex", colour = pal[txt[k]], family = ft, size = 20) +
    annotate("text", x = 0.5, y = 0.8, label = pal[k], colour = pal[txt[k]], family = ft, size = 32) +
    annotate("text", x = 0.5, y = 0.74, label = "RGB", colour = pal[txt[k]], family = ft, size = 20) +
    annotate("text", x = 0.5, y = 0.7, label = .rgb, colour = pal[txt[k]], family = ft, size = 32) +
    xlim(0, 1) +
    ylim(0, 1) +
    theme_void()

  ggsave(glue("C:/Users/danie/OneDrive/Pictures/palettes/{.folder}/swatch-{k}.png"), height = 9, width = 9)

}

