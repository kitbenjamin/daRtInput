
<!-- README.md is generated from README.Rmd. Please edit that file -->

# daRtInput

<!-- badges: start -->

<!-- badges: end -->

The goal of daRtInput is to provide a quick method of creating inputs to
a Dart simulation.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("kitbenjamin/daRtInput")
```

## Example 1: change a property and create a sequence

\#How to view groups and parameters and change the arguments of
parameter

Load the package.

``` r
library(daRtInput)
```

Define directory locations (change as required). Example1 can be
downloaded from this repository from man/data and can be saved in
DART/user\_data/simulations on your local machine.

``` r
#define path to folder containing dart-sequence.bat
dartDir <-  'C:/Users/username/DART/tools/windows'

# define the path to the xml file
inputPath <- 'man/data/example1/example1.xml'
```

Displays what properties are present in the xml file and what group they
are in. Unfortunately dart uses very long names.

``` r
getInputNames(inputPath)
#> Loading required package: xml2
#> Warning: package 'xml2' was built under R version 3.6.1
#> $group1
#> [1] "Directions.ExactDateHour.day"
#> 
#> $group2
#> [1] "Directions.ExactDateHour.month"
```

Now lets define what we would like to change in the
xml.

``` r
#define which property you would like to change: here we are changing the day 
propertyNames <- "Directions.ExactDateHour.day"

# define which group the property is in. Be careful to ensure that the properties you would 
# like to change are within the group you define here.
groupNames <- "group1"

# define the input arguments: which days would you like to input into the model? This should be 
# in the form of a vector of any length. For example here days 1, 100 and 200 will be input
newArgs <- c(1, 100, 200)
```

Rrunning this will overwrite the xml file with the new arguments. It
also runs dart-sequencer. This therefore will create simulation files
that can be run in
dart.

``` r
dartSeqNewInputs(inputPath, groupNames, propertyNames, newArgs, dartDir, newPath = inputPath)
```

You should notice that a new file named example1Edited.xml has been
created in the example1 folder. If you open this file you will see that
the args have been changed to “1;100;200” as we specified. You will also
see the folders ‘Jobs’ and ‘sequence’ have been created and populated.
Three sequences are created, one for each argument (i.e. 1, 100 and
200). Each of these sequences can be run in DART, e.g. example1Edited\_0
can be run in DART.