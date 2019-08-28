#' editSequence
#'
#' Change the arguments of an DART sequence XML file.
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
#' @param newSequenceFileXML Name of the xml file with new propertyArgs defined. Default is to overwrite sequenceFileXML
#'
#' @return A XML file newSequenceFileXML with the desired arguments.
#' @export
#'
#' @examples
editSequence <- function(simName, sequenceFileXML, propertyArgs, DARTprogDir, newSequenceFileXML) {
  #for each row in propertyArgs, change the arg in the XML file
  require(xml2)

  #define the path to the xml file
  sequenceXMLpath = paste0(c(DARTprogDir, 'user_data', 'simulations', simName, sequenceFileXML),  collapse = '/')
  newsequenceXMLpath = paste0(c(DARTprogDir, 'user_data', 'simulations', simName, newSequenceFileXML),  collapse = '/')

  # find the group names and variables in each group
  groupVar <- getInputNames(simName, sequenceFileXML, DARTprogDir, print = FALSE)

  # read in xml file
  sequenceXML <- xml2::read_xml(x = sequenceXMLpath)

  #create a dataframe of new arguments
  propertyNames <- names(propertyArgs)
  newArgsStr <- unlist(lapply( propertyArgs, paste0, collapse = ';'), use.names = FALSE)

  namms <- names(groupVar)
  groupNames <- c()
  for (i in propertyNames){
    for (ii in namms){
      if (i %in% groupVar[[ii]]) {
        groupNames <- c(groupNames, ii)}}}

  newInputs <- data.frame('Groupnames' = groupNames, 'Propertynames' = propertyNames, 'Newargs' = newArgsStr)

  # make all the specifed changes
  apply(newInputs, 1, changePropertyInput, groupVar, sequenceFileXML, sequenceXML, sequenceXMLpath, newSequenceFileXML, newsequenceXMLpath)

  #make sure args in the same group have the same number of inputs
  checkArgLen(sequenceXML)

  #write file
  xml2::write_xml(sequenceXML, newsequenceXMLpath)
}

