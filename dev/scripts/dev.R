
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

