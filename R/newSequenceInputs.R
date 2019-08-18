#' Title
#'
#' @param inputPath Put description for params here
#' @param groupNames Description for groupNames goes here
#' @param propertyNames etc
#' @param newArgs
#' @param dartDir
#' @param newPath
#'
#' @return
#' @export
#'
#' @examples
dartSeqNewInputs <- function(inputPath, groupNames, propertyNames, newArgs,
                             dartDir, newPath = inputPath){
  #move all comments to @* roxygen tabs
  #make names of function args appropriate e.g. "inputPath" should maybe be "sequenceFileXML" or similar.
  #'newArgs' should have name 'propertyArgs' or similar.
  #'dartDir' should be the path to DART (e.g. "C:/User/DART/") and the path to the sequencer.bat can be assumed to
  #'always be the same within that path to DART. So change "dartDir" name to "DARTprogDir" (DART program Dir) and
  #'define the sub-directory for the sequncer .bat in the relevant place(s) within the code
  # define the inputs into DART sequencer and run the sequence
  #
  # Args:
  # inputPath: Path to an xml file containing property arguments you would like to change
  # groupNames: name(s) of the group in which the property you would like to change is
  #   in (can be found using getInputNames function). If multiple then input a vector containing
  #   groupNames.
  # propertyNames: name(s) of the property which you would like to change the DART input for.
  #   If multiple then input a vector containing propertyNames.
  # newArgs: required property input into DART simulation. Values must be in a string, or vector
  #   of strings, with each value separated by ';'. For example, if the deisred inputs were
  #   1,2,3,4 for one property and 5,6,7,8 for another property, newArg would be c("1;2;3;4", "5;6;7;8").
  # newPath: new file path. Default is to replace the input file.
  # dartDir: path to the 'operating system' directory within the DART directory, where DART is installed on your
  #   system. For example, dartDir for a user 'user' using a windows system will be
  #   'C:\\User\\DART\\tools\\windows'
  #
  # Output:
  # An xml file with new specified values to input into DART simulation, new folders of 'jobs', 'output' and
  # 'sequences', which can be used to in a DART simulation.

  # inputs are written to xml file, newPath
  applyChangePropInputs(inputPath, groupNames, propertyNames, newArgs, newPath)

  # run newPath through DART sequencer
  runDartSequencer(newPath, dartDir)
}
