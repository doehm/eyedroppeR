library(magick)
library(cropcircles)
library(ggtext)

img <- image_read("dev/images/eyedropper1.jpg")

img_crop <- hex_crop(img, border_size = 16)

image_read(img_crop)

font_add("fa-brands", regular = "C:/Users/Dan/Documents/R/repos/survivorDev/assets/fonts/fontawesome-free-6.2.0-web/webfonts/fa-brands-400.ttf")
font_add("fa-solid", regular = "C:/Users/Dan/Documents/R/repos/survivorDev/assets/fonts/fontawesome-free-6.2.0-web/webfonts/fa-solid-900.ttf")
font_add("fa-reg", regular = "C:/Users/Dan/Documents/R/repos/survivorDev/assets/fonts/fontawesome-free-6.2.0-web/webfonts/fa-regular-400.ttf")
mastodon <- glue("<span style='font-family:fa-brands; color:{txt}'>&#xf4f6;</span>")
twitter <- glue("<span style='font-family:fa-brands; color:{txt}'>&#xf099;</span>")
github <- glue("<span style='font-family:fa-brands; color:{txt}'>&#xf09b;</span>")
space <- glue("<span style='color:{bg};font-size:1px'>'</span>")
space2 <- glue("<span style='color:{bg}'>--</span>") # can't believe I'm doing this
caption <- glue("{mastodon}{space2}@danoehm@{space}fosstodon.org{space2}{twitter}{space2}@danoehm{space2}{github}{space2}doehm/tidytuesday{space2}{floppy}{space2}Bob Ross Paintings data")


library(showtext)

font_add_google("Amatic SC", "amatic")
showtext_auto()
ft <- "amatic"

ggplot() +
  geom_from_path(aes(0.5, 0.5, path = img_crop)) +
  annotate("text", x=0.68, y = 0.2, label = "EYEDROPPER", family = ft, size = 70, angle = 30, colour = "black", fontface = "bold") +
  annotate("richtext", x=0.51, y = 0.005, label = "<span style='font-family:fa-brands; color:#000000'>&#xf09b;</span> doehm/eyedroppeR",
           family = ft, size = 14, angle = 30, colour = "black", fontface = "bold", hjust = 0, label.color = NA, fill = NA) +
  xlim(0, 1) +
  ylim(0, 1) +
  theme_void()

ggsave("dev/images/hex-amatic.png", height = 6, width = 6)
image_read("dev/images/hex-amatic.png") |>
  image_fill("none", fuzz = 10) |>
  image_fill("none", point = "+1000+5", fuzz = 10) |>
  image_write("dev/images/hex-amatic.png")
