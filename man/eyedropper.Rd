% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eyedropper.R
\name{eyedropper}
\alias{eyedropper}
\title{Eyedropper}
\usage{
eyedropper(
  n,
  img_path = NULL,
  inc_palette = TRUE,
  n_swatches = 24,
  coord_sys = 1
)
}
\arguments{
\item{n}{Number of colours to extract from the image}

\item{img_path}{Path to image. Can be local or from a URL. If left \code{NULL},
\code{eyedropper} will read the image address directly from the clipboard.}

\item{inc_palette}{Logical. If \code{TRUE} it will automatically extract a palette
first and then you can select the desired colours.}

\item{n_swatches}{Number of swatches to extract from the image prior to selecting colours.s}

\item{coord_sys}{Method for extracting the colour from the graphics window Takes values 1, or 2.  See details for more.}
}
\value{
A character vector of hex codes
}
\description{
Plots an image and allows the user to click on the image to
return the hex of the pixel. Can select multiple colours at
once by setting \code{n}.
}
\details{
Use \code{eyedropper} with the following steps:
\enumerate{
  \item{Find the image you want to pick colours from online.}
  \item{Right-click and 'copy image address'.}
  \item{Choose how many colours to pick e.g. \code{n = 5}.}
  \item{Run \code{pal <- eyedropper(n = 5, img_path = 'paste-image-path-here')}.}
  \item{Click 5 areas of the image. The image will be stretched to the borders of the window, but that's OK.}
  \item{Done! Copy the returned string / message and add it to you script and start using \code{pal}}
}

If the colours returned are not the colours you selected, try setting `coord_sys = 2`. Depending on the OS, resolution or
something else then clicking on the image may return a different set of coordinates. If they are mismatched,
it will return the wrong colours, or it won't work at all. I'm unaware of a way to check the coordinate system
before clicking on the image, so for now I have a toggle.
}
\examples{
\dontrun{

path <- file.path(system.file(package = "eyedroppeR"), "images", "hex.png")

# Run eyedropper and click on 4 colours
pal <- eyedropper(n = 4, path)

pal

}
}
