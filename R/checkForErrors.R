
checkErrors <- function(groupVar, propertyName, groupName, newArg, sequenceXML, newSequenceFileXML){
  # checks for errors

  #find available groups and properties
  availableProperties <- unlist(lapply(groupVar, function(x){x[, "propertyNames"]}), use.names = F)
  availableGroups <- names(groupVar)

  #warnings
  # is it a valid property name
  if ((propertyName %in% availableProperties) == FALSE) {
    stop('propertyName ' , propertyName,' not available. Please select from: ', paste(availableProperties, collapse = ' ;;; '))
  }
  # is it a valid group
  if ((groupName %in% availableGroups) == FALSE) {
    stop('groupName ', groupName, ' not available. Please select from: ', paste(availableGroups, collapse = ' , '))
  }
  # is the property in the group
  if ((propertyName %in% groupVar[[as.character(groupName)]][, "propertyNames"]) == FALSE) {
    group_property = list()
    for (i in 1:length(groupVar)) {
      if (propertyName %in% groupVar[[i]][, "propertyNames"]) {
        group_property['groups'] <- names(groupVar[i])
      }
    }
    stop('Property: ', propertyName, ' not in ', groupName, '. Group where property is present: ',
         paste(group_property$groups, collapse = ', '))
  }

  #if linear is it length 3
  groupVarGroup <- groupVar[[as.character(groupName)]]
  if ((groupVarGroup[groupVarGroup[, "propertyNames"] == propertyName, 2] == 'linear') &
      (length(strsplit(newArg, ';')[[1]]) != 3)){
    stop('Argument of type "linear" must be of length 3 (start, increment, number of args). Current length: ',
         length(strsplit(newArg, ';')[[1]]) )
  }

  #ensure .xml is at the end of file name
  if (!grepl('.xml' , sequenceFileXML)) {
    stop( 'sequenceFileXML must be an xml file (name must end in .xml)')
  }

  #ensure .xml is at the end of file name
  if (!grepl('.xml' ,newSequenceFileXML)) {
    stop( 'newSequenceFileXML must be an xml file (name must end in .xml)')
  }

  #check id generate LUT was selected
  LUTvalBool <- isLUTselected(sequenceXML)
  if (LUTvalBool == TRUE) {
    warning( 'Generate LUT is selected but a LUT cannot be generated. Please deselect generate LUT in the DART GUI.')
  }
}

checkArgLen <- function(sequenceXML){
  # ensure all args in a group are the same length
  require(xml2)

  groupPath <- '/DartFile/DartSequencerDescriptor/DartSequencerDescriptorEntries/DartSequencerDescriptorGroup'
  groups <- xml2::xml_find_all(sequenceXML, groupPath)

  for (i in 1:length(groups)) {
    x <- xml2::xml_find_all(groups[i], 'DartSequencerDescriptorEntry')
    args <- (xml2::xml_attr(x, 'args'))
    if (length(args) > 1){
      argLen <- c()
      for (ii in 1:length(args)) {
        argLen <- c(argLen, length(strsplit(args[ii], ';')[[1]]))
        if ( length(unique(argLen)) > 1) {
          stop('Args within the same group must have the same length. Current arg lengths in ',
               xml2::xml_attr(groups[i], 'groupName'), ': ', paste(argLen, collapse = ', '), '.')
        }
      }
    }
  }
}


checkProcess <- function(DARTprocess){
  valProcesses <- c('full', 'only', 'directions', 'maket', 'vegetation', 'phase' )
  if ( !(all(DARTprocess %in% valProcesses))) {
    stop('Not a valid process, please choose from: ', paste(valProcesses, collapse = ', '))
  }
}


