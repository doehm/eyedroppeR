
library(tidyverse)
library(magick)
library(grid)
library(gridExtra)

img_path <- "dev/images/test.png"

ggplot() +
  ggpubr::background_image(image_read(img_path))

n <- 6
eye_ls <- list()
for(k in 1:n) {
  eye_ls[[k]] <- grid::grid.locator(unit = "npc")
}

eye_ls
pal <- map_chr(eye_ls, ~{
  coords <- as.numeric(str_remove(reduce(.x, c), "npc"))
  coords[2] <- 2-coords[2]
  img_dat <- image_data(image_read(img_path))
  dims <- dim(img_dat)
  xpx <- round(coords[1]*dims[2])
  ypx <- round(coords[2]*dims[3])
  paste0("#", paste0(img_dat[, xpx, ypx][1:3], collapse = ""))
})

scales::show_col(pal)


g1 <- tibble(
  x = 1:length(x),
  y = 1
  ) |>
  ggplot() +
  geom_chicklet(aes(x, y), fill = x, radius = grid::unit(9, "pt")) +
  theme_void()

g2 <- ggplot() +
  ggpath::geom_from_path(aes(0, 0, path = path), width = 0.9) +
  theme_void()

g2 + g1




# 🔪 hex ------------------------------------------------------------------

library(showtext)
library(ggtext)

font_add_google("Caveat", "caveat")
font_add("fa-solid", regular = "C:/Users/Dan/Documents/R/repos/survivorDev/assets/fonts/fontawesome-free-6.2.0-web/webfonts/fa-solid-900.ttf")
showtext_auto()

txt <- "grey20"
icon <- glue("<span style='font-family:fa-solid; color:{txt}'>&#xf1fb;</span>")

ggplot() +
  geom_from_path(aes(0, -0.1, path = "dev/images/eyedropper.jpg")) +
  geom_richtext(aes(0, -0.05, label = icon), size = 100, label.color = NA, fill = NA) +
  geom_text(aes(0, -0.2, label = "eyedroppeR"), colour = txt, size = 48, fontface = "bold", family = "caveat") +
  ylim(-0.5, 0.3) +
  theme_void() +
  theme(plot.background = element_rect(fill = "skyblue"))

ggsave("dev/images/hex.png", height = 5, width = 5)

image_read(cropcircles::hex_crop("dev/images/hex.png")) |>
  image_write("dev/images/hex1.png")
