
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
    following image (right-click \> copy image address).

    <img src='dev/images/sunset-south-coast.jpg' height = 270 width = 480/>

3.  Choose how many colours to pick e.g. `n = 8`.

4.  Run
    `eyedropper(n = 8, img_path = '<paste address here>', label = "Sunset on the South Coast")`.

    <img src='dev/images/sunset-sampler.png' height = 270 width = 480/>

5.  Click the 8 desired colours. You can click on either the image
    itself or the swatch at the bottom. The image will be stretched to
    the borders of the window, but that’s OK.

6.  Done! Copy the returned string and add it to your script and start
    using `pal`.

    <img src='dev/images/sunset-south-coast-output.png' height = 270 width = 480.png/>

The palette, image that is saved at the temporary address, and the label
will also be returned by the function. It will also output to console a
message that can be copied and pasted directly to your code. That’s the
best part!

## Automatically extract a palette with `extract_pal`

To speed up the process and if you’re not looking for specific colours
you can run `extract_pal` to automatically select some for you.

``` r
library(eyedroppeR)

path <- "https://github.com/doehm/eyedroppeR/blob/main/dev/images/belize.jpg?raw=true"
extract_pal(12, path, label = "Caye Caulker, Belize", sort = "auto")
```

<img src='dev/images/belize-s.jpg'/>

    caye_caulker_belize <- c('#2F2C1C', '#75391F', '#D6451F', '#B09268', '#ABAEA2', '#DED3B9', '#E8F0EA', '#ADDAF3', '#3B80D0', '#657F7B', '#7E6E4B', '#4C523D')

    $label
    [1] "Caye Caulker, Belize"

    $pal
     [1] "#2F2C1C" "#75391F" "#D6451F" "#B09268" "#ABAEA2" "#DED3B9" "#E8F0EA" "#ADDAF3" "#3B80D0" "#657F7B"
    [11] "#7E6E4B" "#4C523D"

    $img_path
    [1] "C:\\Users\\Dan\\AppData\\Local\\Temp\\RtmpQtGelS\\file6854916f5f"

<img src='dev/images/belize-output-s.png'/>

## Other functions

- `sort_pal`: Allows you to manually sort a palette by clicking on the
  colours in order. It also allows you to select a specified number of
  colours if you don’t want them all.

- `show_pal`: Simple helper to display the palette.
