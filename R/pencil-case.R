#' Pencil Case
#'
#' A list of palettes
#'
#' @importFrom purrr map_dfr
#'
#' @export
pencil_case <- list(
  secret_of_mana = list(
    cat = c('#E92E2C', '#F1E32F', '#91A14A', '#373321')
  ),
  super_mario_world = list(
    cat = c('#37e605', '#0d6cfd', '#fdfc05', '#fe0000')
  ),
  super_ghouls_and_ghosts = list(
    cat = c('#CF2023', '#EF7434', '#89883D', '#6C6E85')
  ),
  super_probotector = list(
    div = c('#373140', '#79484D', '#CB4C45', '#E09D5C', '#E1D4C8', '#9C99A9', '#536E9A', '#134B8A'),
    cat = c('#373140', '#134B8A', '#9C99A9', '#CB4C45')
  ),
  paw_patrol = list(
    cat = c('#11c1b9', '#fde55d', '#f13837', '#2f406e', '#f37c3e', '#6fb455', '#b4485e')
  ),
  skittles = list(
    cat = c('#05beed', '#10df0b', '#fdf405', '#f67a19', '#f11941')
  ),
  bright = list(
    cat = c("#540d6e", "#ee4266", "#ffd23f", "#3bceac")
  ),
  blue_pink = list(
    cat = c('#587DB3', '#42BFDD', '#BBE6E4', '#F0F6F6', '#FF66B3')
  ),
  blue_orange = list(
    cat = c('#244157', '#219ebc', '#88B2C7', '#ffb703', '#fb8500', '#AD5A00')
  ),
  prgr = list(
    div = c('#231942', '#3D3364', '#584E87', '#7566A0', '#937CB6', '#AAA1BC', '#BDD0B7', '#BFE7B2', '#A6DCAE', '#8ACFAB', '#5FBFAB', '#35B0AB')
  ),
  lakes = list(
    cat = c("#788FCE", "#e07a5f", "#f2cc8f", "#81b29a", "#f4f1de")
  ),
  spec = list(
    div = c("#005f73", "#0a9396", "#94d2bd", "#e9d8a6", "#ee9b00", "#ca6702", "#bb3e03", "#ae2012", "#9b2226")
  ),
  d5 = list(
    cat = c("#ef476f", "#ffd166", "#06d6a0", "#118ab2", "#073b4c")
  ),
  d10 = list(
    cat = c("#788FCE", "#BD8184", "#E6956F", "#F2CC8F", "#A6BA96", "#C5E8E3", "#F4F1DE", "#CDC3D4", "#A88AD2", "#60627C")
  ),
  mt_fuji = list(
    cat = c("#3F3A3F", "#AF8290", "#D3C6DA", "#6F96D0")
  ),
  remission = list(
    div = c('#5C4155', '#865D7B', '#98819D', '#7791A8', '#446783', '#2F485C'),
    cat = c('#61542a', '#446783', '#865d7b', '#0a080b', '#7791a8', '#98819d', '#8996a7', '#352b43'),
    seq = c('#0a080b', '#352b43', '#865d7b', '#98819d')
  ),
  leviathan = list(
    cat = c('#66211C', '#7C6A3F', '#0C87A2', '#355355'),
    seq = c('#C2D2D0', '#97AFAE', '#5F8B8C', '#355355')
  ),
  crack_the_skye = list(
    cat = c('#912716', '#bf7b29', '#4b7d57', '#2f3c68', '#8d7ca9', '#b2b7a6', '#332b28', '#151413')
  ),
  once_more_around_the_sun = list(
    div = c('#720F08', '#C41C0C', '#C47020', '#90952E', '#4D732F', '#2A4831'),
    cat = c('#151412', '#720f08', '#d9200d', '#b7a62e', '#cecfc0', '#769879', '#577e2f', '#2a4831')
  ),
  emperor_of_sand = list(
    div = c('#392B26', '#614640', '#978E86', '#EBD0A2', '#F6B45C', '#EF7945', '#C86446', '#984E3A'),
    seq = c('#EBD0A2', '#F6B45C', '#EF7945', '#C86446', '#984E3A')
  ),
  mountains_in_autumn = list(
    div = c('#965b0d', '#c06e08', '#da980a', '#355238', '#093c34', '#131c0d'),
    cat = c('#c06e08', '#da980a', '#68603c', '#355238', '#093c34', '#131c0d', '#245f84', '#3298d1')
  ),
  jupiter = list(
    div = c('#38343a', '#564b4a', '#d2bca8', '#c59784', '#9c6861')
  ),
  colorado_mountains = list(
    div = c('#49392D', '#664F3D', '#826952', '#9D8468', '#C8A887', '#D8D2CC', '#919AA0', '#545E5F', '#384945', '#1D3335'),
    cat = c('#0F1713', '#2B291F', '#49392D', '#664F3D', '#826952', '#9D8468', '#C8A887', '#D8D2CC', '#919AA0', '#545E5F', '#384945', '#1D3335')
  ),
  graffiti = list(
    div = c('#2A1E0F', '#516367', '#7AA3BA', '#D4E2E4', '#E1CF8C', '#CBAA4C', '#BE8311', '#7C490E'),
    seq = c('#E1CF8C', '#CBAA4C', '#BE8311', '#7C490E')
  )
)


#' Shows all palettes in the pencil case
#'
#' @param offset Controls the overlapping circles
#'
#' @return graphic of colour palettes
#' @export
#'
#' @importFrom gt cols_hide cols_width
#'
#' @examples
#' show_pencil_case()
show_pencil_case <- function(offset = 50) {
  df <- map_dfr(1:length(pencil_case), ~{
    pal <- pencil_case[[.x]][[1]]
    bg <- map_chr(2:length(pal), function(k) {
      glue("{(k-1)*offset}px 0 0 -1px {pal[k]}")
    }) |>
      paste0(collapse = ", ")

    tibble(
      id = .x,
      name = snakecase::to_title_case(names(pencil_case)[[.x]]),
      first = pal[1],
      bg = bg
    )
  })

  df |>
    gt() |>
    cols_width(
      bg ~ px(700)
    ) |>
    text_transform(
      fn = function(k, i) {
        glue("<left><span style='background-color: {df$first[i]};
          width: 100px;
          height: 100px;
          display: inline-block;
          border-radius: 50%;
          box-shadow: {k};'></span></left>")
      },
      locations = cells_body(
        columns = bg
      )
    ) |>
    tab_style(
      style = cell_text(
        size = px(24),
        align = "right",
        font = c(
          google_font(name = "Lexend"),
          default_fonts()
        )
      ),
      locations = cells_body(columns = c(id, name))
    ) |>
    cols_hide("first") |>
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

#' Easily get a palette from the pencil case
#'
#' @param id Number
#'
#' @return A vector of hexcodes
#' @export
#'
#' @examples
#' palette(1)
palette <- function(id) {
  pencil_case[[id]][[1]]
}
