
<!-- ```{css, echo = FALSE} -->
<!-- .myimg { -->
<!--   max-height: 480px; -->
<!--   <!-- height: 480px; -->

–\> <!--   <!-- width: 360px; --> –\> <!-- } --> <!-- ``` -->

<style type='text/css'> .myimg { max-height: 480px; } </style>

# eyedroppeR <img src='dev/images/hex-amatic.png' align="right" height="240" />

There are fancy ways to extract colours from images but sometimes it’s
easier if you could simply click on the image and choose the colours you
want.

With `eyedroppeR` you can click on the image and it will return the hex
codes of the selected pixel all within R.

## Installation

``` r
devtools::install_github("doehm/eyedroppeR")
```

## Usage

Use `eyedropper` with the following steps:

1.  Find the image you want to pick colours from online.

2.  Right-click and ‘copy image address’. As an example copy the
    following link to the clipboard (right-click \> copy image address).

    <!-- <img src='https://colorpalettes.net/wp-content/uploads/2015/05/cvetovaya-palitra-1781.png' /> -->
    <img class='myimg' src='inst/images/hex.png'/>

3.  Choose how many colours to pick e.g. `n = 4`.

4.  Run
    `eyedropper(n = 4, img_path = '<paste address here>', label = "Spectrum")`.

5.  Click the 4 desired colours. The image will be stretched to the
    borders of the window, but that’s OK.

6.  Done! Copy the returned string and add it to your script and start
    using `pal`.

<img class="myimg" src='dev/images/cat4.png'/>

<!-- <img src='dev/images/eyedropper.gif' align="center" /> -->

The palette, image that is saved at the temporary address, and the label
will also be returned by the function. It will also output to conosole a
message that can be copied and pasted directly to your code. That’s the
best part!

## Automatically extract palette with `extract_pal`

``` r
library(eyedroppeR)

path <- file.path(system.file(package = "eyedroppeR"), "images", "sunset.png")
extract_pal(8, path, label = "Sunset", sort = "auto")
```

<img class="myimg" src='dev/images/sunset.png'/>

    sunset <- c('#989CA2', '#BFB8AF', '#E0A880', '#B5937E', '#827167', '#5D534B', '#413933', '#25201C')

    $label
    [1] "Sunset"

    $pal
    [1] "#989CA2", "#BFB8AF" "#E0A880" "#B5937E" "#827167" "#5D534B" "#413933" "#25201C" 

    $img_path
    [1] "C:\\Users\\Dan\\AppData\\Local\\Temp\\Rtmp6nr45a\\file20f46ed067bf"

## Other functions

- `sort_pal`: Allows you to manually sort a palette by clicking on the
  colours in order. It also allows you to select a specified number of
  colours if you don’t want them all.

- `show_pal`: Simple helper to display the palette.
