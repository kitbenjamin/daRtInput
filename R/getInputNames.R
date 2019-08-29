#' getInputNames
#'
#' Find what properties are available to be changed in the sequenceFileXML.
#'
#' @param simName Name Name of your simulation.
#' @param sequenceFileXML Name of the xml file containing property(s) of which the arguments you would like to change.
#' @param DARTprogDir Path to the 'DART' directory e.g 'C:/User/<username>/DART'.
#' @param print Whether to print the output.
#'
#' @return A list containing the properties within sequenceFileXML and what group they are in. It also shows whether the argument type is 'linear'
#' or 'enumerate'.
#' @export
#'


getInputNames <- function(simName, sequenceFileXML, DARTprogDir, print = TRUE) {
  #show what groups are available and what variables are available in each group
  require(xml2)

  inputPath = paste0(c(DARTprogDir, 'user_data', 'simulations', simName, sequenceFileXML),  collapse = '/')


  inputFile <- xml2::read_xml(x = inputPath)

  groupPath <- '/DartFile/DartSequencerDescriptor/DartSequencerDescriptorEntries/DartSequencerDescriptorGroup'
  groups <- xml_find_all(inputFile, groupPath)

  groupVar <- list()
  for (i in groups) {
    groupName <- xml_attr(i, 'groupName')

    descriptors <- xml_find_all(i, 'DartSequencerDescriptorEntry')
    propertyNames <- xml_attr(descriptors, 'propertyName')

    type <- xml_attr(descriptors, 'type')
    groupVar[[groupName]] <- cbind(propertyNames, type)
  }
  if (print == TRUE) {
    return(print(groupVar))
  }
  else { return(groupVar)}
}
