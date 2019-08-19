#' dartSeqNewInputs
#'
#'Create a DART sequence based on the arguents defined.
#'
#'
#'
#' @param simName Name of your simulation.
#' @param sequenceFileXML Name of the xml file containing property(s) of which the arguments you would like to change.
#' @param groupNames Name(s) of the group in which the property whos args you would like to define is
#   in (can be found using getInputNames function). If multiple then input a vector containing
#   groupNames.
#' @param propertyNames Name(s) of the property which you would like to define the DART input for.
#   If multiple then input a vector containing propertyNames.
#' @param propertyArgs Required property input into DART simulation. This should be a vector if changing one arg or a list of vectors
#' if changing multiple.
#' @param DARTprogDir Path to the 'DART' directory e.g 'C:/User/<username>/DART'.
#' @param newFileXML Name of the xml file with new propertyArgs defined. Default is to overwrite sequenceFileXML
#'
#' @return A sequence of files that together can be used input all propertyArgs into a DART simulation.
#' @export
#'
#' @examples
dartSeqNewInputs <- function(simName, sequenceFileXML, groupNames, propertyNames, propertyArgs,
                             DARTprogDir, newFileXML = sequenceFileXML){
  #move all comments to @* roxygen tabs \/
  #make names of function args appropriate e.g. "inputPath" should maybe be "sequenceFileXML" or similar.
  #'newArgs' should have name 'propertyArgs' or similar.
  #'dartDir' should be the path to DART (e.g. "C:/User/DART/") and the path to the sequencer.bat can be assumed to
  #'always be the same within that path to DART. So change "dartDir" name to "DARTprogDir" (DART program Dir) and
  #'define the sub-directory for the sequncer .bat in the relevant place(s) within the code
  # define the inputs into DART sequencer and run the sequence
  # change to new file name

  # inputs are written to xml file, newPath
  applyChangePropInputs(simName, sequenceFileXML, groupNames, propertyNames, propertyArgs, DARTprogDir, newPath)

  # run newPath through DART sequencer
  runDartSequencer(newPath, dartDir)
}
