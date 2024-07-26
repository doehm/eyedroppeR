
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

x <- extract_pal(6, "https://i.ebayimg.com/images/g/ZJIAAOSwvsVkPy-Z/s-l1600.jpg")
swatch(x$pal, x$img_path, .padding = 1)

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




# urls --------------------------------------------------------------------

urls <- list(
  super_mario_world = "https://i.ebayimg.com/images/g/ZJIAAOSwvsVkPy-Z/s-l1600.jpg",
  secret_of_mana = "https://i.ebayimg.com/images/g/vMAAAOSwi85dfvZb/s-l1200.jpg",
  super_ghouls_and_ghosts = "https://i.ebayimg.com/images/g/DmQAAOSwH~5kXsAY/s-l1200.webp",
  super_probotector = "C:/Users/danie/OneDrive/Pictures/palettes/super-probotector/box-art.png"
)

# swatches ----------------------------------------------------------------

swatch(pencil_case$super_mario_world$cat, urls$super_mario_world, .padding = 4, .radius = 5)
swatch(pencil_case$secret_of_mana$cat, urls$secret_of_mana, .padding = 4, .radius = 5)
swatch(pencil_case$super_ghouls_and_ghosts$cat, urls$super_ghouls_and_ghosts, .padding = 4, .radius = 5)
swatch(pencil_case$super_probotector$cat, urls$super_probotector, .padding = 4, .radius = 5)



css <- str_remove_all("width: 115px;
  height: 100px;
  background-image:
    radial-gradient(circle at 50px 50px, #F00 0, #F00 50px, transparent 50px),
    radial-gradient(circle at 55px 50px, #FF0 0, #FF0 50px, transparent 50px),
    radial-gradient(circle at 60px 50px, #080 0, #080 50px, transparent 50px),
    radial-gradient(circle at 65px 50px, #00F 0, #00F 50px, transparent 50px);", "\\n[:space:]")

tibble(x = glue("<span style='background-image: #ff0000;'></span>")) |>
  gt() |>
  text_transform(
    fn = function(x) {
      gt::html(x)
    },
    locations = cells_body(
      columns = everything()
    )
  )
glue("<span style='background-image: #ff0000;'></span>")

tibble(x = "hi") |>
  gt() |>
  text_transform(
    fn = function(k) {
      gt::html(glue("<left><span style='background-color: red;
          width: 100px;
          height: 100px;
          display: inline-block;
          border-radius: 50%;
          box-shadow: 30px 0 0 -1px #f8ff00,
                      60px 0 0 -2px #009901,
                      90px 0 0 -3px #3531ff;'></span></left>"))
    },
    locations = cells_body(
      columns = everything()
    )
  ) |>
  tab_options(data_row.padding.horizontal = px(100))



pal <- pencil_case$secret_of_mana$cat
map_chr(1:length(pal), function(k) {
  glue("{k*offset}px 0 0 -{k}px {pal[k]}")
}) |>
  paste0(collapse = ", ")



