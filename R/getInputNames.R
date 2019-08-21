#' Title
#'
#' @param inputPath
#' @param print
#'
#' @return
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

    groupVar[[groupName]] <- propertyNames
  }
  if (print == TRUE) {
    return(print(groupVar))
  }
  else { return(groupVar)}
}
