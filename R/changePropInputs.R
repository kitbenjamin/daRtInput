changePropertyInput <- function(newInputs, groupVar, sequenceFileXML, sequenceXML, sequenceXMLpath, newSequenceFileXML,
                                newsequenceXMLpath) {
  # Replaces the argument with newArg and saves file
  require(xml2)

  # seclude groups, properties and args
  groupName <- unlist(newInputs['Groupnames'])
  propertyName <- unlist(newInputs['Propertynames'])
  newArg <- unlist(newInputs['Newargs'])

  #check for errors
  checkErrors(groupVar, propertyName, groupName, newArg, sequenceXML, newSequenceFileXML)

  # replace the sequence name with the new sequence name
  if (sequenceFileXML != newSequenceFileXML) {
    changeSeqName(sequenceXML, newSequenceFileXML)
  }

  # replace the old argument with the new argument
  changeArg(sequenceXML, groupName, propertyName, newArg)

  # replace 'numberParallelThreads
  changeNParThre(sequenceXML)
}

changeNParThre <- function(sequenceXML) {
  # changes numberparallelthreads to the product of args in different groups.
  require(xml2)

  seqPrefsPath <- '/DartFile/DartSequencerDescriptor/DartSequencerPreferences'
  seqPrefs <- xml2::xml_find_all(sequenceXML, seqPrefsPath)
  nParThre <- numberParallelThreads(sequenceXML)

  xml2::xml_attr(seqPrefs, 'numberParallelThreads') <- nParThre
}

changeArg <- function(sequenceXML, groupName, propertyName, newArg) {
  #alters the arg to new specified arg
  require(xml2)

  groupIndex <- getGroupIndex(sequenceXML, groupName)
  groupPath <- '/DartFile/DartSequencerDescriptor/DartSequencerDescriptorEntries/DartSequencerDescriptorGroup'
  groups <- xml2::xml_find_all(sequenceXML, groupPath)
  groupNo <- groups[groupIndex]
  propertyPath <- 'DartSequencerDescriptorEntry'
  properties <- xml2::xml_find_all(groupNo, propertyPath)
  propertyIndex <- which(xml2::xml_attr(properties, 'propertyName') == as.character(propertyName))
  propertyNo <- properties[propertyIndex]

  xml2::xml_attr(propertyNo, 'args') <- newArg
}

changeSeqName <- function(sequenceXML, newSequenceFileXML) {
  # changes the sequence name to the name defined in newPath
  require(xml2)
  require(stringr)

  seqDescPath <- '/DartFile/DartSequencerDescriptor'
  seqDesc <- xml2::xml_find_all(sequenceXML, seqDescPath)

  nf <- stringr::str_remove(newSequenceFileXML, '.xml')
  newSeqName <- paste0('sequence;;', nf)

  xml2::xml_attr(seqDesc, 'sequenceName') <- newSeqName
}
