
#' Generate palette
#'
#' ⚠️ DEPRECATED: openai has been archived and I have to work out how to generate
#' images with {ellmer} and the new APIs.
#'
#' @param n Number of colours in the palette
#' @param prompt Prompt
#'
#' @importFrom openai create_image
#' @importFrom stringr str_length
#'
#' @return A vector of hex codes
#' @export
#'
#' @examples
#' # x <- generate_palette(4, 'a trail in a dense rainforest')
generate_palette <- function(n, prompt) {
  x <- create_image(prompt)
  d <- extract_pal(n, x$data$url, plot_output = FALSE, save_output = TRUE)
  print(swatch(d$pal, d$img_path, padding = 1))
  list(
    pal = d$pal,
    eyedropper = d,
    img = x$data$url
  )
}
