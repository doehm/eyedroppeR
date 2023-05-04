
test_pal <- function(.label) {

  iris <- iris |>
    janitor::clean_names() |>
    as_tibble()

  g_hist <- ggplot() +
    geom_histogram(aes(displ, fill = class), mpg, colour = "black") +
    scale_fill_manual(values = pencil_case[[.label]]$cat) +
    theme_minimal()

  g_point <- ggplot() +
    geom_point(aes(petal_length, petal_width, colour = species), iris, size = 5, alpha = 0.5) +
    scale_colour_manual(values = pencil_case[[.label]]$cat) +
    theme_minimal()

  print(g_hist + g_point)
}

test_pal("remission")
test_pal("leviathan")
