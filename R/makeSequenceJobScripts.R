#' makeSequenceJobScripts
#'
#' Create scripts that run DART simulations.
#'
#' @param sequenceFileXML Name of the xml file containing property(s) of which the arguments you want to sequence and input into
#' DART simulation.
#' @param simName Name of your simulation.
#' @param DARTprogDir Path to the 'DART' directory e.g 'C:/User/<username>/DART'.
#' @param DARTprocess The DART process(s) you would like to run e.g. directions, maket, phase
#' Maximum amount of time dart-sequence.bat is allowed to run.
#' @param userDescBool If True the user must define a new name in which to store the sequence files. Otherwise the datetime in the
#' form YYYY_DOY_H.M.S is used.
#' @param userDesc If userDescBool is TRUE then this will be a string containing the directory name in which the sequence files will be stored.
#'
#' @return Sequence of folders with required args and a job script that will run the sequenced inputs using a designated DART
#' process(es).
#' @export
#'
makeSequenceJobScripts <- function(simName,sequenceFileXML,  DARTprogDir, DARTprocess, maxTime = 120, userDescBool = FALSE,
                                   userDesc = NULL) {

  # run newSequenceFileXML through DART sequencer
  runDartSequencer(sequenceFileXML, simName, DARTprogDir, maxTime)

  #move files from sequence folder and create an executable script file
  moveFilescreateScripts(simName, DARTprogDir, SequenceFileXML, DARTprocess,dbFullPath, userDescBool, userDesc)
}
