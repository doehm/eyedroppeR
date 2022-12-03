#' Eyedropper
#'
#' Plots an image and allows the user to click on the image to
#' return the hex of the pixel. Can select multiple colours at
#' once by setting \code{n}.
#'
#' @param n Number of colours to extract from the image
#' @param img_path Path to image. Can be local or from a URL. If left \code{NULL},
#' \code{eyedropper} will read the image address directly from the clipboard.
#'
#' @details Use \code{eyedropper} with the following steps:
#' \enumerate{
#'   \item{Find the image you want to pick colours from online.}
#'   \item{Right-click and 'copy image address'.}
#'   \item{Choose how many colours to pick e.g. \code{n = 5}.}
#'   \item{Run \code{pal <- eyedropper(n = 5)}. The function will read the copied address from the clipboard.}
#'   \item{Click 5 areas of the image. The image will be stretched to the borders of the window, but that's OK.}
#'   \item{Done! Copy the returned string and add it to you script and start using \code{pal}}
#' }
#'
#' @return A character vector of hex codes
#' @export
#'
#' @import ggplot2
#' @importFrom utils readClipboard read.table
#' @importFrom magick image_read
#' @importFrom purrr map_chr
#' @importFrom grid grid.locator
#' @importFrom glue glue
#' @importFrom seecolor print_color
#' @importFrom ggchicklet geom_chicklet
#' @importFrom ggpath geom_from_path
#' @import patchwork
#'
#' @examples \dontrun{
#' # image from https://colorpalettes.net/color-palette-1781/
#' path <- "https://colorpalettes.net/wp-content/uploads/2015/05/cvetovaya-palitra-1781.png"
#'
#' # Run eyedropper and click on 5 colours
#' x <- eyedropper(n = 5, path)
#'
#' x
#' }
eyedropper <- function(n, img_path = NULL) {

  if(is.null(img_path)) img_path <- read.table(text = readClipboard())[1,1]

  print(
    ggplot() +
      ggpubr::background_image(image_read(img_path))
  )

  eye_ls <- list()
  cat("\nClick on image to select colours\n")
  for(k in 1:n) {
    cat(glue("Colours selected: {k-1}/{n}\r"))
    eye_ls[[k]] <- grid.locator(unit = "npc")
  }
  cat(glue("Colours selected: {n}/{n}"))

  pal <- map_chr(eye_ls, ~{
    coords <- as.numeric(str_remove(reduce(.x, c), "npc"))
    coords[2] <- 2-coords[2]
    img_dat <- image_data(image_read(img_path))
    dims <- dim(img_dat)
    xpx <- round(coords[1]*dims[2])
    ypx <- round(coords[2]*dims[3])
    paste0("#", paste0(img_dat[, xpx, ypx][1:3], collapse = ""))
  })

  print_color(pal)
  cat(paste0("\n\npal <- c('", paste0(pal, collapse = "', '"), "')"))

  g1 <- ggplot(data.frame(x = 1:length(pal),y = 1)) +
    geom_chicklet(aes(x, y), fill = pal, radius = grid::unit(9, "pt")) +
    theme_void()

  g2 <- ggplot() +
    geom_from_path(aes(0, 0, path = img_path), width = 0.9) +
    theme_void()

  print(g2 + g1)

  pal

}
