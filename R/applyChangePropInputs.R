

applyChangePropInputs <- function(simName, sequenceFileXML, groupNames, propertyNames, propertyArgs, DARTprogDir, newSequenceFileXML) {
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
  if (is.list(propertyArgs)){
    newArgsStr <- unlist(lapply( propertyArgs, paste0, collapse = ';'))
  } else {newArgsStr <- paste0(propertyArgs, collapse = ';')}
  newInputs <- data.frame('Groupnames' = groupNames, 'Propertynames' = propertyNames, 'Newargs' = newArgsStr)

  # make all the specifed changes
  apply(newInputs, 1, changePropertyInput, groupVar, sequenceFileXML, sequenceXML, sequenceXMLpath, newSequenceFileXML, newsequenceXMLpath)

  #make sure args in the same group have the same number of inputs
  checkArgLen(sequenceXML)

  #write file
  xml2::write_xml(sequenceXML, newsequenceXMLpath)
}

