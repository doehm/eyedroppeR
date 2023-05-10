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
