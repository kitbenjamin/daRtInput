

applyChangePropInputs <- function(simName, sequenceFileXML, groupNames, propertyNames, newArgsList, DARTprogDir, newPath) {
  require(xml2)

  #define the path to the xml file
  inputPath = paste0(c(DARTprogDir, 'user_data', 'simulations', simName, sequenceFileXML),  collapse = '/')

  # find the group names and variables in each group
  groupVar <- getInputNames(simName, sequenceFileXML, DARTprogDir, print = FALSE)

  # read in xml file
  inputFile <- xml2::read_xml(x = inputPath)

  #create a dataframe of new arguments
  if (is.list(newArgs)){
    newArgsStr <- unlist(lapply( newArgs, paste0, collapse = ';'))
  } else {newArgsStr <- paste0(newArgs, collapse = ';')}
  newInputs <- data.frame('Groupnames' = groupNames, 'Propertynames' = propertyNames, 'Newargs' = newArgsStr)

  # make all the specifed changes
  apply(newInputs, 1, changePropertyInput, groupVar, inputFile, inputPath, newPath)

  #make sure args in the same group have the same number of inputs
  checkArgLen(inputFile)

  #write file
  xml2::write_xml(inputFile, newPath)
}

