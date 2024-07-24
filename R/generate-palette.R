
#' Set OpenAI API key
#'
#' @param key Key from OpenAI account
#'
#' @return Nothing
#' @export
set_openai_key <- function(key) {
  Sys.setenv(OPENAI_API_KEY = key)
}

#' Generate palette
#'
#' @param n Number of colours in the palette
#' @param prompt Prompt
#' @param name Name for the palette. If left NULL it will
#'
#' @importFrom openai create_image
#' @importFrom stringr str_length
#'
#' @return
#' @export
#'
#' @examples
#' # x <- generate_palette(4, 'colourful balls in a chldrens ball pit', name = 'Ball pit')
generate_palette <- function(n, prompt, name = NULL) {
  x <- create_image(prompt)
  if(str_length(prompt) < 30 & is.null(name)) name <- "pal"
  d <- extract_pal(n, x$data$url, plot_output = TRUE, label = name, save_output = TRUE)
  # print(image_resize(image_read(d$saved_path), "600x"))
  print(swatch(d$pal, d$img_path, .padding = 1))
  list(
    pal = d$pal,
    eyedropper = d,
    img = x$data$url
  )
}
