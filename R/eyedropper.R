utils::globalVariables(c("x", "y", "id"))

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
#' @param inc_palette Logical. If \code{TRUE} it will automatically extract a palette
#' first and then you can select the desired colours.
#' @param n_swatches Number of swatches to extract from the image prior to selecting colours.s
#'
#' @details Use \code{eyedropper} with the following steps:
#' \enumerate{
#'   \item{Find the image you want to pick colours from online.}
#'   \item{Right-click and 'copy image address'.}
#'   \item{Choose how many colours to pick e.g. \code{n = 5}.}
#'   \item{Run \code{pal <- eyedropper(n = 5, img_path = 'paste-image-path-here')}.}
#'   \item{Click 5 areas of the image. The image will be stretched to the borders of the window, but that's OK.}
#'   \item{Done! Copy the returned string / message and add it to you script and start using \code{pal}}
#' }
#'
#' @return A character vector of hex codes
#' @export
#'
#' @import ggplot2
#' @importFrom magick image_read image_data image_write image_info image_resize image_append image_scale
#' @importFrom purrr map_chr map_dbl reduce
#' @importFrom grid grid.locator
#' @importFrom glue glue
#' @importFrom ggpath geom_from_path
#' @importFrom stringr str_remove str_split
#' @importFrom stats kmeans dist
#' @importFrom gridExtra grid.arrange
#' @importFrom crayon white cyan
#' @importFrom snakecase to_snake_case
#' @importFrom TSP as.TSP solve_TSP
#' @importFrom ggtext geom_richtext
#' @importFrom grDevices col2rgb
#' @importFrom ggplot2 ggsave
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
eyedropper <- function(
    n,
    img_path = NULL,
    label = NULL,
    inc_palette = TRUE,
    n_swatches = 24
    ) {

  # name palette
  if(is.null(label)) label <- "pal"

  if(is.null(img_path)) img_path <- file.path(system.file(package = "eyedroppeR"), "images", "hex.png")

  err_bad_link <- simpleError("Incorrect path. Please supply the correct link to img_path")
  tryCatch(
    {
      # include palette?
      if(inc_palette) {
        ex_pal <- suppressMessages(extract_pal(n_swatches, img_path, label, plot_output = FALSE, save_output = TRUE))
        img <- image_read(img_path)
      } else {
        img <- image_read(img_path)
      }
    },
    error = function(e) stop(err_bad_link)
  )

  # resize and write image
  hi_res <- FALSE
  info <- image_info(img)
  ht <- min(info$height, 800+hi_res*9999)
  wd <- info$width*ht/info$height
  img_rs <- image_resize(img, geometry = paste0(ht, "x", wd))
  temp <- tempfile()
  image_write(img_rs, path = temp)

  # plot image with extracted palette
  temp_selector <- tempfile(fileext = ".png")
  ggsave(plot = show_pal(ex_pal$pal), filename = temp_selector, height = ht/10, width = wd, units = "px")
  img_selector <- image_append(image_scale(c(img_rs, image_read(temp_selector)), as.character(ht)), stack = TRUE)
  print(ggplot() +
    annotation_raster(img_selector, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf))

  # pick colours
  eye_ls <- list()
  message(white("\nClick on image to select colours\n"))
  for(k in 1:n) {
    message(white(glue("Colours selected: {k-1}/{n}\r")))
    eye_ls[[k]] <- grid.locator(unit = "npc")
    if(info$width*as.numeric(eye_ls[[k]]$x) < 0) stop("...eyedropper killed\n")
  }
  message(white(glue("Colours selected: {n}/{n}")))

  # get image data and extract from image
  img_dat <- image_data(img_selector)
  dims <- dim(img_dat)

  pal <- map_chr(eye_ls, ~{
    coords <- as.numeric(str_remove(reduce(.x, c), "npc"))
    # coords[2] <- ceiling(coords[2])-coords[2]
    coords[2] <- 1-coords[2]+0.5
    xpx <- round(coords[1]*dims[2])
    ypx <- round(coords[2]*dims[3])
    paste0("#", paste0(img_dat[, xpx, ypx][1:3], collapse = ""))
  })

  # print pal to copy + paste
  pastey(pal, label)

  # make plot output
  plt <- make_output(NULL, pal, img_path, label)
  print(plt)

  # return
  list(
    pal = pal,
    img_path = img_path
  )

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
#' @param plot_output logical. Default \code{TRUE}. Plots the output of the extracted palette.
#' @param save_output logical. Default \code{FALSE}. Save the output of the extracted palette.
#'
#' @return Returns a character vector of hex codes
#' @export
#'
#' @examples
#' path <- file.path(system.file(package = "eyedroppeR"), "images", "sunset.png")
#'
#' \dontrun{
#' extract_pal(8, path)
#' }
extract_pal <- function(n, img_path, label = NULL, sort = "auto", plot_output = TRUE, save_output = FALSE) {

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
  rgb_mat <- unique(apply(x, 3, "c"))

  # kmeans
  km <- kmeans(rgb_mat, n)
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
  temp_final <- NULL
  # plt <- make_output(NULL, pal, img_path, label)
  # if(plot_output) print(plt)
  # if(save_output) {
  #   temp_final <- tempfile(fileext = ".png")
  #   ggplot2::ggsave(plot = plt, filename = temp_final, height = 4, width = 6)
  # }

  print(swatch(pal, temp))

  # return
  list(
    label = label,
    pal = pal,
    img_path = temp
    # saved_path = temp_final
  )

}


