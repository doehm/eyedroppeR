utils::globalVariables(c("x", "y"))

#' Eyedropper
#'
#' Plots an image and allows the user to click on the image to
#' return the hex of the pixel. Can select multiple colours at
#' once by setting \code{n}.
#'
#' @param n Number of colours to extract from the image
#' @param img_path Path to image. Can be local or from a URL. If left \code{NULL},
#' \code{eyedropper} will read the image address directly from the clipboard.
#' @param label Label for the palette.
#'
#' @details Use \code{eyedropper} with the following steps:
#' \enumerate{
#'   \item{Find the image you want to pick colours from online.}
#'   \item{Right-click and 'copy image address'.}
#'   \item{Choose how many colours to pick e.g. \code{n = 5}.}
#'   \item{Run \code{pal <- eyedropper(n = 5, img_path = 'paste-image-path-here')}.}
#'   \item{Click 5 areas of the image. The image will be stretched to the borders of the window, but that's OK.}
#'   \item{Done! Copy the returned string and add it to you script and start using \code{pal}}
#' }
#'
#' @return A character vector of hex codes
#' @export
#'
#' @import ggplot2
#' @importFrom magick image_read image_data image_write image_info image_resize
#' @importFrom purrr map_chr map_dbl reduce
#' @importFrom grid grid.locator
#' @importFrom glue glue
#' @importFrom seecolor print_color
#' @importFrom ggpath geom_from_path
#' @importFrom stringr str_remove str_split
#' @importFrom stats kmeans dist
#' @importFrom gridExtra grid.arrange
#' @importFrom crayon white cyan
#' @importFrom snakecase to_snake_case
#' @importFrom TSP as.TSP solve_TSP
#' @importFrom ggtext geom_richtext
#' @importFrom grDevices col2rgb
#'
#' @examples \dontrun{
#'
#' path <- file.path(system.file(package = "eyedroppeR"), "images", "hex.png")
#'
#' # Run eyedropper and click on 4 colours
#' pal <- eyedropper(n = 4, path)
#'
#' pal
#'
#' }
eyedropper <- function(n, img_path = NULL, label = NULL) {

  err_bad_link <- simpleError("Incorrect path. Please supply the correct link to img_path")
  tryCatch(
    {
      img <- image_read(img_path)
      },
    error = function(e) stop(err_bad_link)
  )

  # name palette
  if(is.null(label)) label <- paste("Palette number", sample(100:999, 1))

  # resize and write image
  info <- image_info(img)
  ht <- min(info$height, 800)
  wd <- info$width*ht/info$height
  img_rs <- image_resize(img, geometry = paste0(ht, "x", wd))
  temp <- tempfile()
  image_write(img_rs, path = temp)

  # plot resized image
  image_path <- temp
  print(
    ggplot() +
      annotation_raster(
        image_read(img_path),
        xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf)
  )

  # pick colours
  eye_ls <- list()
  message(white("\nClick on image to select colours\n"))
  for(k in 1:n) {
    message(white(glue("Colours selected: {k-1}/{n}\r")))
    eye_ls[[k]] <- grid.locator(unit = "npc")
  }
  message(white(glue("Colours selected: {n}/{n}")))

  # get image data and extract from image
  img_dat <- image_data(image_read(img_path))
  dims <- dim(img_dat)

  pal <- map_chr(eye_ls, ~{
    coords <- as.numeric(str_remove(reduce(.x, c), "npc"))
    coords[2] <- ceiling(coords[2])-coords[2]
    xpx <- round(coords[1]*dims[2])
    ypx <- round(coords[2]*dims[3])
    paste0("#", paste0(img_dat[, xpx, ypx][1:3], collapse = ""))
  })

  # print pal to copy + paste
  pastey(pal, label)

  # make plot output
  print(make_output(pal, temp, label))

  # return
  list(
    label = label,
    pal = pal,
    img_path = temp
  )

}


#' Show palette
#'
#' Plots the supplied palette for quick inspection
#'
#' @param pal Palette. Vector of hex codes
#'
#' @return ggplot
#' @export
#'
#' @examples
#' pal <- c('#57364e', '#566f1b', '#97a258', '#cac58b', '#dbedd5')
#' show_pal(pal)
show_pal <- function(pal) {
  ggplot(data.frame(x = 1:length(pal),y = 1)) +
    geom_col(aes(x, y), fill = pal, width = 1) +
    theme_void() +
    theme(plot.margin = margin(l=-38,r=-38,t=-20,b=-20))
}


#' Manually sort a palette
#'
#' The palette is displayed in the plotting window where you can click
#' the colours in the order you want to sort them. The sorted palette
#' will be returned.
#'
#' @param pal Palette. Character vector of hex codes
#' @param n Number of colours to choose
#'
#' @return Character vector
#' @export
#'
#' @examples \dontrun{
#' pal <- sample(c('#57364e', '#566f1b', '#97a258', '#cac58b', '#dbedd5'))
#' sort_pal(pal)
#' }
sort_pal <- function(pal, n = NULL) {
  print(show_pal(pal))
  if(is.null(n)) n <- length(pal)
  message(white(glue("Click {n} colours in the desired order\n\n")))
  pos_ls <- list()
  for(k in 1:n) {
    pos_ls[[k]] <- grid.locator(unit = "npc")
  }

  id <- map_dbl(pos_ls, ~as.numeric(.x$x))
  new_pal_order <- floor(id*length(pal)) + 1
  pal <- pal[new_pal_order]
  print(show_pal(pal))
  pastey(pal)

  pal

}


#' Extracts palette from an image
#'
#' The image is read in using \code{magick}, converted to RGB and clustered using kmeans. The user
#' must specify the number of clusters. The cluster centroids become the palette values.
#' The function will ask the user to sort the palette values after clustering
#'
#' @param n Number of colours to extract
#' @param img_path Path to image. If `NULL` the function will read from the clipboard
#' @param sort Sort method. Either 'manual' or 'auto'
#' @param label Label for the palette.
#'
#' @return Returns a character vector of hex codes
#' @export
#'
#' @examples \dontrun{
#' path <- file.path(system.file(package = "eyedroppeR"), "images", "sunset.png")
#' extract_pal(8, path)
#' }
extract_pal <- function(n, img_path, label = NULL, sort = "auto") {

  err_bad_link <- simpleError("Incorrect path. Please supply the correct link to img_path")
  tryCatch(
    {
      img <- image_read(img_path)
    },
    error = function(e) stop(err_bad_link)
  )

  # name palette
  if(is.null(label)) label <- paste("Palette number", sample(100:999, 1))

  # resize and write image
  info <- image_info(img)
  ht <- min(info$height, 600)
  wd <- info$width*ht/info$height
  img_rs <- image_resize(img, geometry = paste0(ht, "x", wd))
  temp <- tempfile()
  image_write(img_rs, path = temp)

  # setting array for clustering
  x <- as.integer(as.array(image_data(img_rs, "rgb")))
  rgb_mat <- matrix(0, nrow = prod(dim(x)[1:2]), ncol = 5)
  k <- 0
  for(i in 1:dim(x)[1]) {
    for(j in 1:dim(x)[2]) {
      k <- k + 1
      rgb_mat[k, ] <- c(i, j, x[i, j, ])
    }
  }

  # kmeans
  km <- kmeans(rgb_mat[,3:5], n)
  km <- round(km$centers)

  # pal from centers
  pal <- map_chr(1:n, ~rgb(km[.x,1], km[.x,2], km[.x,3], maxColorValue = 255))

  # sort
  pal <- sort_pal_auto(pal, label)
  if(sort == "manual") {
    print(show_pal(pal))
    nx <- as.numeric(readline("How many colours to pick? "))
    pal <- sort_pal(pal, n = nx)
  }

  # make plot output
  print(make_output(pal, temp, label))

  # return
  list(
    label = label,
    pal = pal,
    img_path = temp
  )

}

#' Auto palette sort
#'
#' Automatically sorts the palette. May not give the desired result. If not you
#' can run `sort_pal()` to manually sort.
#'
#' @param .pal Input palette
#' @param label Label for the palette.
#'
#' @return Returns a character vector of hex codes
#' @export
#'
#' @examples
#' pal <- sample(colours(), 8)
#' sort_pal_auto(pal, 'test')
sort_pal_auto <- function(.pal, label) {
  rgb <- col2rgb(.pal)
  tsp <- as.TSP(dist(t(rgb)))
  sol <- solve_TSP(tsp, control = list(repetitions = 1e3))
  .pal <- .pal[sol]
  x <- colSums(col2rgb(.pal))
  max_k <- which.max(x)[1]
  if(max_k != 1) .pal <- .pal[c(max_k:length(.pal), 1:(max_k-1))]
  print(show_pal(.pal))
  pastey(.pal, label)
  .pal
}


#' Makes eyedroppers output
#'
#' Plots the palette and places the image and label over the top.
#'
#' @param .pal Palette
#' @param .img_path Image path
#' @param .label Label
#'
#' @return ggplot object
make_output <- function(.pal, .img_path, .label) {
  show_pal(.pal) +
    geom_from_path(aes(length(.pal)/2+0.5, 0.5, path = .img_path), width = 0.4, height = 0.6) +
    geom_richtext(aes(x = length(.pal), y = 0.1), label = .label, size = 6, fontface = "italic",
                  hjust = 1, label.colour = NA, fill = "grey90", alpha = 0.25,
                  label.padding = unit(c(0.5, 0.5, 0.5, 0.5), "lines"),
                  label.r = unit(0.3, "lines"))
}


#' Copy + Pastable palette vector
#'
#' Prints a message to console so you can easily copy and paste the palette
#'
#' @param .pal Palette vector
#' @param .label Label
#'
#' @return a message
#' @export
pastey <- function(.pal, .label = NULL) {
  if(is.null(.label)) .label = "pal"
  message(cyan(paste0("\n", to_snake_case(.label)," <- c('", paste0(.pal, collapse = "', '"), "')\n")))
}
