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

#' Swatch of colour palette
#'
#' @param pal Vector of colours
#' @param img Image address. Either local file or URL
#' @param label Label for the palette.
#' @param padding To add whitespace to the top of image
#' @param radius The radius of the feature image. Choose 50 for a circle, less then 50 for rounded square/rectangle.
#' @param ncols Number of cols in a row
#' @param img_shadow Logical. Apply a shadow to the feature image output.
#' @param shape Either 'original' for the original image dimensions or "square"
#' to crop to square with rounded corners. A high enough radius will turn the square to a circle.
#'
#' @return html doc
#' @export
#'
#' @importFrom gt gt tab_style tab_header tab_options cells_body google_font cell_text default_fonts text_transform px
#' @importFrom tidyr pivot_wider everything
#' @importFrom stringr str_remove_all str_detect
#' @import dplyr
#'
#' @examples
#' url <- "https://github.com/doehm/eyedroppeR/raw/main/dev/images/sunset-south-coast.jpg"
#' x <- extract_pal(4, url)
#' swatch(x$pal, url)
swatch <- function(
    pal,
    img = NULL,
    label = NULL,
    padding = 0,
    radius = 20,
    ncols = 8,
    img_shadow = TRUE,
    shape = "original"
    ) {

  # set the number of cols for the swatch
  if(length(pal) > ncols & length(pal) < 2*ncols) {
    ncols <- ceiling(length(pal)/2)
  } else {
    ncols <- min(ncols, length(pal))
  }

  padding <- paste0(rep("<br>", padding), collapse = "")
  nrows <- ceiling(length(pal)/ncols)

  # radius on x and y for the rounded corners of the image
  rx <- radius
  ry <- radius

  # css and function for the main image
  img_style <- glue("border-radius: {rx}px {ry}px; box-shadow: 0 0 10px 2px rgba(0,0,0,{0.3*img_shadow}); object-fit: cover;")
  img_header <- function(tbl) {
    if(is.null(img)) {
      out <- tbl
    } else {
      if(shape == "original") {
        info <- image_read(img) |>
          image_info()
        wd <- info$width/info$height*300
      } else {
        wd <- 300
      }
      out <- tbl |>
        tab_header(
          title = gt::html(glue("{padding}<img src='{uri}' width={wd} height=300 style='{img_style}';>")),
          subtitle = gt::html(glue("<span style='font-size: 18px;'>{label}</span>"))
        )
    }
  }

  # function and css for the colour dots
  dot_ <- function(bg, circle) {

    txt <- choose_font_colour(bg)

    str_remove_all(glue("height: 150px;
    width: 150px;
    background-color: {bg};
    color: {txt};
    font-weight: 400;
    font-size: 12px;
    border-radius: 50%;
    display: inline-block;
    box-shadow: 0 0 10px 2px rgba(0,0,0,0.3);"),
    "\\n[:space:]")
  }

  # if the image is from a url do this thing so it works in {gt}
  if(!is.null(img)) {
    if(!str_detect(img, "http")) {
      uri <- gt:::get_image_uri(img)
    } else {
      uri <- img
    }
  }

  # make the table
  tibble(
    id =  1:length(pal),
    pal = pal
  ) |>
    mutate(
      row = ceiling(id/ncols),
      col = (id-1) %% ncols + 1,
      col = ifelse(row %% 2 == 0, max(col) - col + 1, col)
    ) |>
    select(row, col, pal) |>
    pivot_wider(id_cols = row, names_from = "col", values_from = "pal") |>
    select(-row) |>
    gt() |>
    tab_style(
      style = cell_text(
        font = c(
          google_font(name = "Poppins"),
          default_fonts()
        )
      ),
      locations = cells_body(columns = everything())
    ) |>
    text_transform(
      locations = cells_body(
        columns = everything()
      ),
      fn = function(k, i){
        col_rgb <- map_chr(1:nrows, ~paste0("rgb(", paste(as.numeric(t(col2rgb(k[.x]))), collapse = ", "), ")"))
        map_chr(1:nrows, ~{
          if(is.na(k[.x])) {
            out <- ""
          } else {
            out <- glue("<center><span style='{dot_(k[.x], radius)}'><br>{k[.x]}<br>{col_rgb[.x]}</span></center>")
          }
          out
        })
      }
    ) |>
    img_header() |>
    tab_options(
      column_labels.font.size = 0,
      table_body.hlines.width = px(0),
      table_body.border.top.width = px(0),
      table_body.border.bottom.width = px(0),
      heading.border.bottom.width = px(0),
      table.border.bottom.width = px(0),
      table.border.top.width = px(0),
      column_labels.border.top.width = px(0),
      column_labels.border.bottom.width = px(0),
      data_row.padding = px(10),
      data_row.padding.horizontal = px(10)
    )
}

#' Manually sort a palette
#'
#' The palette is displayed in the plotting window where you can click
#' the colours in the order you want to sort them. The sorted palette
#' will be returned. This saves you copy/pasting hex codes in your script.
#'
#' @param pal Palette. Character vector of hex codes
#' @param n Number of colours to choose
#' @param label Label for the palette.
#' @param print_output Print output to console to easily copy and paste into your script.
#'
#' @return Character vector
#' @export
#'
#' @examples \dontrun{
#' pal <- sample(c('#57364e', '#566f1b', '#97a258', '#cac58b', '#dbedd5'))
#' sort_pal(pal)
#' }
sort_pal <- function(pal, n = NULL, label = NULL, print_output = TRUE) {

  # show initial palette for clicking on
  print(show_pal(pal))

  # loop to click on image
  if(is.null(n)) n <- length(pal)
  message(white(glue("Click {n} colours in the desired order\n\n")))
  pos_ls <- list()
  for(k in 1:n) {
    pos_ls[[k]] <- grid.locator(unit = "npc")
    cat(glue("colours sorted: {k}/{n}\r"))
  }

  # sort from user input
  id <- map_dbl(pos_ls, ~as.numeric(.x$x))
  new_pal_order <- floor(id*length(pal)) + 1
  pal <- pal[new_pal_order]
  print(show_pal(pal))

  # print palette code
  if(print_output) {
    cat("\n")
    paste_pal_code(pal, label)
  }

  pal

}

#' Auto palette sort
#'
#' Automatically sorts the palette. May not give the desired result. If not you
#' can run `sort_pal()` to manually sort.
#'
#' @param pal Input palette
#' @param label Label for the palette.
#' @param plot_output Logical. Default \code{FALSE}.
#'
#' @return Returns a character vector of hex codes
#' @export
#'
#' @examples
#' pal <- sample(colours(), 8)
#' sort_pal_auto(pal, 'test')
sort_pal_auto <- function(pal, label, plot_output = FALSE) {

  rgb <- col2rgb(pal)
  tsp <- as.TSP(dist(t(rgb)))
  sol <- solve_TSP(tsp, control = list(repetitions = 1e3))
  pal <- pal[sol]
  x <- colSums(col2rgb(pal))
  max_k <- which.min(x)[1]
  if(max_k != 1) pal <- pal[c(max_k:length(pal), 1:(max_k-1))]
  if(plot_output) print(show_pal(pal))

  pal
}

#' Makes eyedroppers output
#'
#' Plots the palette and places the image and label over the top.
#'
#' @param obj Output from \code{extract_pal} or \code{eyedropper}
#' @param pal Palette
#' @param img_path Image path
#'
#' @return ggplot object
make_output <- function(obj = NULL, pal, img_path) {

  if(!is.null(obj)) {
    pal <- obj$pal
    img_path <- obj$img_path
  }

  # read in image
  img_rs <- image_read(img_path)
  info <- image_info(img_rs)
  ht <- info$height
  wd <- info$width

  # temp file for output
  temp_output <- tempfile(fileext = ".png")
  temp_output_stack <- tempfile(fileext = ".png")

  # saving palette
  ggsave(plot = show_pal(pal), filename = temp_output, height = 100, width = 1000, units = "px")

  # stack and output
  img_selector <- image_append(image_scale(c(img_rs, image_read(temp_output)), "1000"), stack = TRUE)
  image_write(img_selector, path = temp_output_stack)

  ggplot() +
    geom_from_path(aes(wd/2, ht/2, path = temp_output_stack)) +
    xlim(0, wd) +
    ylim(0, ht) +
    theme_void() +
    theme(
      plot.background = element_blank()
    )

}


#' Copy + Pasteable palette vector
#'
#' Prints a message to console so you can easily copy and paste the palette
#'
#' @param pal Palette vector
#' @param label Label
#'
#' @return a message
paste_pal_code <- function(pal, label = NULL) {
  if(is.null(label)) label <- "pal"
  message(cyan(paste0("\n", to_snake_case(label)," <- c('", paste0(pal, collapse = "', '"), "')\n")))
}


#' Choose font colour
#'
#' @param bg Background
#' @param light The light text colour
#' @param dark The dark text colour
#' @param threshold The threshold for switching
#'
#' @return hex code
choose_font_colour <- function(bg, light = "#ffffff", dark = "#000000", threshold = 170) {
  x <- drop(c(0.299, 0.587, 0.114) %*% col2rgb(bg) > threshold)
  out <- ifelse(x, dark, light)
  ifelse(is.na(bg), light, out)
}


#' Modify the saturation of a colour palette
#'
#' @param cols Vector of colours
#' @param sat Factor to adjust the saturation
#'
#' @importFrom grDevices rgb2hsv hsv
#'
#' @return A vector of hex codes
#' @export
modify_saturation <- function(cols, sat = 1.2) {
  X <- diag(c(1, sat, 1)) %*% rgb2hsv(col2rgb(cols))
  hsv(X[1,], pmin(X[2,], 1), X[3,])
}


#' Min-max scale function
#'
#' @param x Vector of values
#' @param a Min
#' @param b Max
#' @param a0 Min bound
#' @param b0 Max bound
#'
#' @return numeric vector
min_max <- function(x, a, b, a0 = NULL, b0 = NULL) {
  if(is.null(a0) & is.null(b0)) {
    a0 <- min(x)
    b0 <- max(x)
  }
  (b - a) * (x - a0) / (b0 - a0) + a
}
