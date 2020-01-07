# shinyserver

The `mk-mohan/raspirshiny` image adds the `quandl` and other quant related suite (and
`devtools` suite) of R packages to the `upadrishta:raspir` images.
Like the `rocker/shiny` images, this stack is versioned so
that a tag, such as `rocker/raspirshiny:3.6.1` will always
provide R v3.6.1, and likewise fix the version of all R
packages installed from CRAN to the [last date that version was
current](https://github.com/rocker-org/rocker-versioned/tree/master/VERSIONS.md).

Additional commonly used dependencies are be added to `upadrishta/raspir`
when appropriate (or at least C libraries needed to ensure other common
packages can be installed from source).
