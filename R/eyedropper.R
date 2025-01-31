utils::globalVariables(c("x", "y", "id", "bg", "name", "text"))

#' Eyedropper
#'
#' Plots an image and allows the user to click on the image to
#' return the hex of the pixel. Can select multiple colours at
#' once by setting \code{n}.
#'
#' @param n Number of colours to extract from the image
#' @param img_path Path to image. Can be local or from a URL. If left \code{NULL},
#' \code{eyedropper} will read the image address directly from the clipboard.
#' @param inc_palette Logical. If \code{TRUE} it will automatically extract a palette
#' first and then you can select the desired colours.
#' @param n_swatches Number of swatches to extract from the image prior to selecting colours.s
#' @param print_output Print output to console to easily copy and paste into your script.
#' @param calibrate Set to `TRUE` to calibrate the plot coordinates. Given the monitor
#' resolution, scaling, etc it can throw off the pixel selection. Runs but default the first
#' time the function is used.
#' @param swatch_radius Radius of the image for the swatch. Default 50 to make it a circle. Use 5 for rounded edges.
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
#' The first time the function is run it will initiate a calibration set. This is so the `y` coordinates are
#' scaled properly as this can depend on the monitors resolution, scaling, etc. In only takes a couple of seconds
#' and you only have to do it once.
#'
#' Make sure you click as near as practicable to the top and bottom of the border of the windew within the dot.
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
    inc_palette = TRUE,
    n_swatches = 24,
    print_output = TRUE,
    calibrate = FALSE,
    swatch_radius = 50
    ) {

  # name palette
  # keeping this here in case I add back in the parameter
  label <- "pal"

  # calibrate
  if(calibrate | !exists("eyedropper_calibration", mode = "environment")) {
    plt_calibrate <- tibble(
      x = 0.5,
      y = c(0.9, 0.1),
      text = c("To calibrate,\nfirst click here\nwithin the dot", "Then click here\nwithin the dot")
    ) |>
      ggplot() +
      annotation_raster(image_read(file.path(system.file(package = "eyedroppeR"), "images", "calibration.png")), xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
      geom_text(aes(x-0.1, y, label = text), size = 8, hjust = 1, lineheight = 0.8) +
      ylim(0, 1) +
      xlim(0, 1) +
      theme_void()
    print(plt_calibrate)

    calibration_points <- list()
    lab <- c("Top", "Bottom")
    for(k in 1:2) {
      cat(lab[k])
      calibration_points[[k]] <- grid.locator(unit = "npc")
      cat(" ✔\n")
    }
    cat("-- Calibration done --\n")

    # create a new environment to store the calibration points
    eyedropper_calibration <<- new.env()

    # calculate min and max y
    eyedropper_calibration$max_y <- as.numeric(calibration_points[[1]]$y)
    eyedropper_calibration$min_y <- as.numeric(calibration_points[[2]]$y)

  }

  img_shadow <- TRUE
  if(is.null(img_path)) {
    img_path <- file.path(system.file(package = "eyedroppeR"), "images", "hex.png")
    img_shadow <- FALSE
  }

  err_bad_link <- simpleError("Incorrect path. Please supply the correct link to img_path")
  tryCatch(
    {
      # include palette?
      if(inc_palette) {
        ex_pal <- suppressMessages(extract_pal(n_swatches, img_path, plot_output = FALSE, save_output = TRUE))
        img <- image_read(img_path)
      } else {
        img <- image_read(img_path)
      }
    },
    error = function(e) stop(err_bad_link)
  )

  # resize and write image
  info <- image_info(img)
  ht <- min(info$height, 800)
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
    coords[2] <- 1-min_max(coords[2], 0, 1, a0 = eyedropper_calibration$min_y, b0 = eyedropper_calibration$max_y)
    xpx <- round(coords[1]*dims[2])
    ypx <- round(coords[2]*dims[3])
    paste0("#", paste0(img_dat[, xpx, ypx][1:3], collapse = ""))
  })

  # print pal to copy + paste
  if(print_output) paste_pal_code(pal, label)

  # make plot output
  print(swatch(pal, img = img_path, img_shadow = img_shadow, radius = swatch_radius))

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
#' @param plot_output logical. Default \code{TRUE}. Plots the output of the extracted palette.
#' @param save_output logical. Default \code{FALSE}. Save the output of the extracted palette.
#' @param print_output Print output to console to easily copy and paste into your script.
#' @param swatch_radius Radius of the image for the swatch. Default 50 to make it a circle. Use 5 for rounded edges.
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
extract_pal <- function(
    n,
    img_path,
    sort = "auto",
    plot_output = TRUE,
    save_output = FALSE,
    print_output = TRUE,
    swatch_radius = 50
    ) {

  err_bad_link <- simpleError("Incorrect path. Please supply the correct link to img_path")
  tryCatch(
    {
      img <- image_read(img_path)
    },
    error = function(e) stop(err_bad_link)
  )

  # name palette
  label <- "pal"

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
  if(plot_output) print(swatch(pal, temp, radius = swatch_radius))

  # print pal
  if(print_output) paste_pal_code(pal)

  # return
  list(
    pal = pal,
    img_path = temp
  )

}


