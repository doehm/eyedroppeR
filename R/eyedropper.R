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
#' @param inc_palette Logical. If \code{TRUE} it will automatically extract a palette
#' first and then you can select the desired colours.
#' @param hi_res Plot a hi-res image for clicking. Can slow down performance.
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
    hi_res = FALSE,
    n_swatches = 24
    ) {

  # name palette
  if(is.null(label)) label <- paste("Palette number", sample(100:999, 1))

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
    coords[2] <- ceiling(coords[2])-coords[2]
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
    label = label,
    pal = pal,
    img_path = img_path
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
    theme(
      plot.margin = margin(l=-12,r=-12,t=-20,b=-20)
    )
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
  plt <- make_output(NULL, pal, img_path, label)
  if(plot_output) print(plt)
  if(save_output) {
    temp_final <- tempfile(fileext = ".png")
    ggplot2::ggsave(plot = plt, filename = temp_final, height = 4, width = 6)
  }

  # return
  list(
    label = label,
    pal = pal,
    img_path = temp,
    saved_path = temp_final
  )

}


#' Auto palette sort
#'
#' Automatically sorts the palette. May not give the desired result. If not you
#' can run `sort_pal()` to manually sort.
#'
#' @param .pal Input palette
#' @param label Label for the palette.
#' @param plot_output Logical. Default \code{FALSE}.
#'
#' @return Returns a character vector of hex codes
#' @export
#'
#' @examples
#' pal <- sample(colours(), 8)
#' sort_pal_auto(pal, 'test')
sort_pal_auto <- function(.pal, label, plot_output = FALSE) {
  rgb <- col2rgb(.pal)
  tsp <- as.TSP(dist(t(rgb)))
  sol <- solve_TSP(tsp, control = list(repetitions = 1e3))
  .pal <- .pal[sol]
  x <- colSums(col2rgb(.pal))
  max_k <- which.min(x)[1]
  if(max_k != 1) .pal <- .pal[c(max_k:length(.pal), 1:(max_k-1))]
  if(plot_output) print(show_pal(.pal))
  pastey(.pal, label)
  .pal
}


#' Makes eyedroppers output
#'
#' Plots the palette and places the image and label over the top.
#'
#' @param obj Output from \code{extract_pal} or \code{eyedropper}
#' @param .pal Palette
#' @param .img_path Image path
#' @param .label Label
#'
#' @return ggplot object
make_output <- function(obj = NULL, .pal, .img_path, .label) {

  if(!is.null(obj)) {
    .pal <- obj$pal
    .img_path <- obj$img_path
    .label <- obj$label
  }

  # read in image
  img_rs <- image_read(.img_path)
  info <- image_info(img_rs)
  ht <- info$height
  wd <- info$width

  # temp file for output
  temp_output <- tempfile(fileext = ".png")
  temp_output_stack <- tempfile(fileext = ".png")

  # saving palette
  ggsave(plot = show_pal(.pal), filename = temp_output, height = 100, width = 1000, units = "px")

  # stack and output
  img_selector <- image_append(image_scale(c(img_rs, image_read(temp_output)), "1000"), stack = TRUE)
  image_write(img_selector, path = temp_output_stack)

  ggplot() +
    geom_from_path(aes(wd/2, ht/2, path = temp_output_stack)) +
    geom_richtext(aes(x = wd*0.5, y = ht*0.15), label = .label, size = 6, fontface = "italic",
                  hjust = 0.5, label.colour = NA, fill = "grey90", alpha = 0.80,
                  label.padding = unit(c(0.5, 0.5, 0.5, 0.5), "lines"),
                  label.r = unit(0.3, "lines")) +
    xlim(0, wd) +
    ylim(0, ht) +
    theme_void() +
    theme(
      plot.background = element_blank()
    )

}


#' Copy + Pastable palette vector
#'
#' Prints a message to console so you can easily copy and paste the palette
#'
#' @param .pal Palette vector
#' @param .label Label
#'
#' @return a message
pastey <- function(.pal, .label = NULL) {
  if(is.null(.label)) .label = "pal"
  message(cyan(paste0("\n", to_snake_case(.label)," <- c('", paste0(.pal, collapse = "', '"), "')\n")))
}
