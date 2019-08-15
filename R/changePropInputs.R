changePropertyInput <- function(newInputs, groupVar, inputFile, inputPath, newPath) {
  # Replaces the argument with newArg and saves file

  # seclude groups, properties and args
  groupName <- newInputs['Groupnames']
  propertyName <- newInputs['Propertynames']
  newArg <- newInputs['Newargs']

  #check for errors
  checkErrors(groupVar, propertyName, groupName, newArg)

  # replace the sequence name with the new sequence name
  changeSeqName(inputFile, newPath)

  # replace the old argument with the new argument
  changeArg(inputFile, groupName, propertyName, newArg)

  # replace 'numberParallelThreads
  changeNParThre(inputFile)
}

changeNParThre <- function(inputFile) {
  # changes numberparallelthreads to the product of args in different groups.

  seqPrefsPath <- '/DartFile/DartSequencerDescriptor/DartSequencerPreferences'
  seqPrefs <- xml_find_all(inputFile, seqPrefsPath)
  nParThre <- numberParallelThreads(inputFile)

  xml_attr(seqPrefs, 'numberParallelThreads') <- nParThre
}

changeArg <- function(inputFile, groupName, propertyName, newArg) {
  #alters the arg to new specified arg

  groupIndex <- getGroupIndex(inputFile, groupName)
  groupPath <- '/DartFile/DartSequencerDescriptor/DartSequencerDescriptorEntries/DartSequencerDescriptorGroup'
  groups <- xml_find_all(inputFile, groupPath)
  groupNo <- groups[groupIndex]
  propertyPath <- 'DartSequencerDescriptorEntry'
  properties <- xml_find_all(groupNo, propertyPath)
  propertyIndex <- which(xml_attr(properties, 'propertyName') == as.character(propertyName))
  propertyNo <- properties[propertyIndex]

  xml_attr(propertyNo, 'args') <- newArg
}

changeSeqName <- function(inputFile, newPath) {
  # changes the sequence name to the name defined in newPath

  newSeqName <- getNewSeqName(inputFile, newPath)
  seqDescPath <- '/DartFile/DartSequencerDescriptor'
  seqDesc <- xml_find_all(inputFile, seqDescPath)

  xml_attr(seqDesc, 'sequenceName') <- newSeqName
}
