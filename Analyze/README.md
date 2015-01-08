# See the original Trelliscope README Below.  For the Alacer Trelliscope version, the change includes the following:

Instead of running the command
```
view()
```
following set up of displays, run the following commands:
```
library(shiny)
runApp("inst/trelliscopeViewerAlacer", launch.browser=TRUE)
```

The command assumes that your working directory is the ~/trelliscope.  Change the runApp command as necessary to reflect the path.

For an example, run the analaysis.R file in the data/mimic2db folder.

# Trelliscope: Detailed Visualization of Large Complex Data in R

Trelliscope is an R package to be used in conjunction with [datadr](https://github.com/tesseradata/datadr) and [RHIPE](https://github.com/tesseradata/RHIPE) to provide a framework for detailed visualization of large complex data.

## Installation

For simple use, all that is needed for Trelliscope is R.  Trelliscope depends on the `datadr` package.  To install this package from github, do the following from the R console:

```s
library(devtools)
install_github("datadr", "tesseradata")
install_github("trelliscope", "tesseradata")
```

## Tutorial

To get started, see the package documentation and function reference located [here](http://tesseradata.github.io/docs-trelliscope/).

## License

This software is currently under the BSD license.  Please read the [license](https://github.com/hafen/trelliscope/blob/master/LICENSE.md) document.

## Acknowledgement

Trelliscope development is sponsored by the DARPA XDATA program.
