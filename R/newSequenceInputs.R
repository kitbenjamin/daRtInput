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
#' @param DARTprocess The DART process(s) you would like to run e.g. directions, maket, phase
#' @param newSequenceFileXML Name of the xml file with new propertyArgs defined. Default is to overwrite sequenceFileXML
#' @param maxTime Maximum amount of time dart-sequence.bat is allowed to run.
#' @param userDescBool If True the user must define a new name in which to store the sequence files. Otherwise the datetime in the
#' form YYYY_DOY_H.M.S is used.
#' @param userDesc If userDescBool is TRUE then this will be a string containing the directory name in which the sequence files will be stored.
#'
#' @return A sequence of files that together can be used input all propertyArgs into a DART simulation.
#' @export
#'
dartSeqNewInputs <- function(simName, sequenceFileXML, groupNames, propertyNames, propertyArgs,
                             DARTprogDir, DARTprocess, newSequenceFileXML = sequenceFileXML, maxTime = 120,
                             userDescBool = FALSE, userDesc = NULL){
  # inputs are written to xml file, newSequenceFileXML
  editSequence(simName, sequenceFileXML, groupNames, propertyNames, propertyArgs, DARTprogDir, newSequenceFileXML)

  makeSequenceJobScripts(simName, newSequenceFileXML, DARTprogDir, DARTprocess,  maxTime, userDescBool, userDesc)
}
