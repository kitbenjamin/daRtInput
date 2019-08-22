
<!-- README.md is generated from README.Rmd. Please edit that file -->

# daRtInput

<!-- badges: start -->

<!-- badges: end -->

The goal of daRtInput is to provide a quick method of creating inputs to
a Dart simulation.

This readme cannot be run through GitHub but the xml files are availble
from man/data/cesbio. Users with DART installed on their system can
download these and run this readme locally.

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

Define name of your simulation and the sequence xml file (created using
the ‘SequenceLauncher’ in the DART GUI). Also the path to the DART
directory on your system.

``` r
#define path to DART directory
DARTprogDir <-  'C:/Users/kitbe/DART'

# name of your simulation
simName <- 'cesbio'

# sequence file name
sequenceFileXML <- 'sequence1.xml'
```

We can see what properties are available in the xml file and what group
they are in using the getInputNames function. Unfortunately dart uses
very long names.

``` r
# get group and property names
getInputNames(simName, sequenceFileXML, DARTprogDir)
#> Loading required package: xml2
#> $group1
#> [1] "Maket.Scene.CellDimensions.x"
#> 
#> $group2
#> [1] "Maket.Scene.CellDimensions.z"
```

Now lets define what we would like to change in the
xml.

``` r
#define which property you would like to change: here we are changing the horizontal cell dimensions 
propertyNames <- "Maket.Scene.CellDimensions.x"

# define which group the property is in. Be careful to ensure that the properties you would 
# like to change are within this group.
groupNames <- "group1"

# define the input arguments: which horizontal cell dimensions will be input into the model? This should be 
# in the form of a vector of any length.
propertyArgs <- c(1.5, 3, 4.5, 6)
```

Also we must define what DART process we want to use the sequenced files
for.

``` r
# run sequence files with dart-maket
DARTprocess <- 'maket'
```

This function runs dart-sequencer so therefore creates simulation files
for each specified propertyArg. It also creates a script file that can
be exectued to run the sequence simulation.

``` r
#run dertSeqNewInputs
dartSeqNewInputs(simName, sequenceFileXML, groupNames, propertyNames, propertyArgs, DARTprogDir, DARTprocess)
```

The sequence1.xml has been edited such that the property
‘Maket.Scene.CellDimensions.x’ now has the specified property
arguments, ’1.5;3;4.5;6". You will also see the directory
daRtInput/<datettime>/simName has been created and within this directory
is sequence files, one for each combination of propertyArgs. Within each
sequence file is a script file (shell or batch depending on operting
system), which is capable of running the sequence file through
dart-maket.

In summary, dartSeqNewInputs essentially carries out two functions: 1.
editing the xml file that defines the arguments input into DART 2.
creates sequenced simulation files for each combination of arguments and
a script file that can execute the simulation folder for the given DART
process.

These two functions can be carried out seperately. The fist
function:

``` r
#edit sequence xml file. Note that as newSequenceFileXML is not defined, sequenceFileXML will be overwritten
editSequence(simName, sequenceFileXML, groupNames, propertyNames, propertyArgs, DARTprogDir)
```

The second function:

``` r
# make sequenced simulation folders and the scripts to execute them
makeSequenceJobScripts(simName, sequenceFileXML,  DARTprogDir, DARTprocess)
```

## EXAMPLE 2: change multiple properties

This time we are changing arguments for multiple propertys. we will also
choose to run
dart-phase.

``` r
# changing the horizontal and vertical cell dimensions and their corresponding groups
propertyNames <- c("Maket.Scene.CellDimensions.x", "Maket.Scene.CellDimensions.z")
groupNames <- c("group1", "group2")

# define the input arguments as a list of vectors
propertyArgs <- list(c(1, 2, 3, 4, 5, 6), c(2, 4, 6))

#run dart-phase
DARTprocess <- 'phase'
```

This time, instead of overwritting the sequence XML file we shall create
a new file called sequence1\_ex2.xml

``` r
# give the sequence xml a new name
newSequenceFileXML <- 'sequence1_ex2.xml'
```

Also we shall define a description name for the directory containing the
sequence files (as opposed to the datetime).

``` r
# define user description
userDesc <- 'example2'
```

This time when we run the function we must ensure that userDescBool is
set to TRUE so that userDesc is used instead of datetime.

``` r
#run dertSeqNewInputs
dartSeqNewInputs(simName, sequenceFileXML, groupNames, propertyNames, propertyArgs, DARTprogDir, DARTprocess,
                 newSequenceFileXML = newSequenceFileXML, userDescBool = TRUE, userDesc = userDesc)
```

This time, a new xml file named ‘sequence1\_ex2.xml’ has been generated.
In addition, there are 18 sequence files within a directory named
example2. There are 18 because this is the product of the lengths of the
new arguments. A sequence for every combination of x and z is created.
In this case, a sequence is created for x = 1 z = 2, x = 1 z = 4, x = 1
z = 6, x = 2 z = 2 and so on.

## EXAMPLE 3: changing properties in the same group

This time using sequence 2

``` r
# sequence file name
sequenceFileXML <- 'sequence2.xml'
```

``` r
# view the new inputs
getInputNames(simName, sequenceFileXML, DARTprogDir)
#> $group1
#> [1] "Maket.Scene.CellDimensions.x" "Maket.Scene.CellDimensions.z"
#> 
#> $group2
#> [1] "Coeff_diff.Temperatures.ThermalFunction.meanT"
```

Notice two properties in group1- horizontal and vertical cell dimensions
and one property in group2- mean temperature. Properties in the the same
group are sequenced simulataniously so must have the same
length.

``` r
# changing the horizontal and vertical cell dimensions and their corresponding groups
propertyNames <- c("Maket.Scene.CellDimensions.x", "Maket.Scene.CellDimensions.z",
                   "Coeff_diff.Temperatures.ThermalFunction.meanT")
groupNames <- c("group1","group1",  "group2")

# define the input arguments as a list of vectors
propertyArgs <- list(c(1, 2, 3, 4), c(1, 2, 3, 4), c(273, 278, 283, 288, 293, 298))
```

It’s also possible to run multiple processes.

``` r
#run dart-directons and dart-maket
DARTprocess <- DARTprocess <- c('directions', 'maket')
```

To create the sequence files, dart-sequence is run. To avoid the
possiblilty of infinite loops, a timeout is set for dart-sequence. This
‘maxTime’ is set by default to 120 seconds however if you are creating
large number of sequences then you may wish to increase this time my
settin maxTime to 180 for example.

``` r
#run dertSeqNewInputs
dartSeqNewInputs(simName, sequenceFileXML, groupNames, propertyNames, propertyArgs, DARTprogDir, DARTprocess,
                 maxTime = 180)
```

This time 24 sequences have been created- this is the product of the
length of arguments in group 1 (4) and the length of the argument in
group 2 (6). In this case a sequence is created for x = 1 z = 1
temperature = 273, x = 2 z = 2 temperature = 273, x = 3 z = 3
temperature = 273, x = 4 z = 4 temperature = 273, x = 1 z = 1
temperature = 278 and so on.
