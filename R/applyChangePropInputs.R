require(xml2)

applyChangePropInputs <- function(inputPath, groupNames, propertyNames, newArgsList, newPath) {
  # find the group names and variables in each group
  groupVar <- getInputNames(inputPath, print = FALSE)

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

