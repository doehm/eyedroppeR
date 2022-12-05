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
#' @importFrom magick image_read image_data
#' @importFrom purrr map_chr map_dbl reduce
#' @importFrom grid grid.locator
#' @importFrom glue glue
#' @importFrom seecolor print_color
#' @importFrom ggchicklet geom_chicklet
#' @importFrom ggpath geom_from_path
#' @importFrom stringr str_remove str_split
#' @importFrom stats kmeans
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
  cat(paste0("\n\npal <- c('", paste0(pal, collapse = "', '"), "')\n"))

  g1 <- show_pal(pal)

  g2 <- ggplot() +
    geom_from_path(aes(0, 0, path = img_path), width = 0.9) +
    theme_void()

  print(g2 + g1)

  pal

}


#' Show palette
#'
#' Plots the palette
#'
#' @param pal Palette. Vector of hex codes
#'
#' @return ggplot
#' @export
#'
#' @examples \dontrun{
#' pal <- c('#57364e', '#566f1b', '#97a258', '#cac58b', '#dbedd5')
#' show_pal(pal)
#' }
show_pal <- function(pal) {
  ggplot(data.frame(x = 1:length(pal),y = 1)) +
    geom_chicklet(aes(x, y), fill = pal, radius = grid::unit(9, "pt")) +
    theme_void()
}


#' Manually sort palette
#'
#' The palette is displayed in the plotting window where you can click
#' the colours in the order you want to sort them. The sorted palette
#' will be returned.
#'
#' @param pal Palette. Character vector of hex codes
#'
#' @return
#' @export
#'
#' @examples \dontrun{
#' pal <- sample(c('#57364e', '#566f1b', '#97a258', '#cac58b', '#dbedd5'))
#' sort_pal(pal)
#' }
sort_pal <- function(pal, n = NULL) {
  print(show_pal(pal))
  if(is.null(n)) n <- length(pal)
  cat(glue("Click {n} colours in the desired order\n"))
  pos_ls <- list()
  for(k in 1:n) {
    pos_ls[[k]] <- grid::grid.locator(unit = "npc")
  }

  id <- as.numeric(map_chr(pos_ls, "x"))
  new_pal <- floor(id*length(pal)) + 1
  pal <- pal[new_pal]
  print(show_pal(pal))
  cat(paste0("\npal <- c('", paste0(pal, collapse = "', '"), "')\n"))
  pal
}


#' Extracts palette from image
#'
#' The image is read in using \code{magick}, converted to RGB and clustered using kmeans. The user
#' must specify the number of clusters. The cluster centroids become the palette values.
#'
#' @param n
#' @param img_path
#'
#' @importFrom purrr map_chr
#'
#' @return Returns a character vector of hex codes
#' @export
#'
#' @examples \dontrun{
#' path <- "https://colorpalettes.net/wp-content/uploads/2015/05/cvetovaya-palitra-1781.png"
#' extract_pal(path)
#' }
extract_pal <- function(n, img_path = NULL) {

  if(is.null(img_path)) img_path <- read.table(text = readClipboard())[1,1]

  img <- image_read(img_path)
  x <- as.integer(as.array(image_data(img, "rgb")))
  rgb_mat <- matrix(0, nrow = prod(dim(x)[1:2]), ncol = 5)
  k <- 0
  for(i in 1:dim(x)[1]) {
    for(j in 1:dim(x)[2]) {
      k <- k + 1
      rgb_mat[k, ] <- c(i, j, x[i, j, ])
    }
  }

  km <- kmeans(rgb_mat[,3:5], n)
  km <- round(km$centers)

  pal <- map_chr(1:n, ~rgb(km[.x,1], km[.x,2], km[.x,3], maxColorValue = 255))

  cat("\nSort palette")
  print(show_pal(pal))
  nx <- as.numeric(readline("How many colours to pick? "))
  pal <- sort_pal(pal, n = nx)

  g1 <- ggplot() +
    geom_from_path(aes(0, 0, path = img_path), width = 0.9) +
    theme_void()

  g2 <- show_pal(pal)

  print(g1 + g2)

  pal

}
