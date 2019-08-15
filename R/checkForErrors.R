
checkErrors <- function(groupVar, propertyName, groupName, newArg){
  # checks for errors

  #find available groups and properties
  availableProperties <- unlist(groupVar, use.names = F)
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
  if ((propertyName %in% groupVar[[as.character(groupName)]]) == FALSE) {
    group_property = list()
    for (i in 1:length(groupVar)) {
      if (propertyName %in% groupVar[[i]]) {
        group_property['groups'] <- names(groupVar[i])
      }
    }
    stop('Property: ', propertyName, ' not in ', groupName, '. Groups where property is present: ',
         paste(group_property$groups, collapse = ', '))
  }
}

checkArgLen <- function(inputFile){
  # ensure all args in a group are the same length

  groupPath <- '/DartFile/DartSequencerDescriptor/DartSequencerDescriptorEntries/DartSequencerDescriptorGroup'
  groups <- xml_find_all(inputFile, groupPath)

  for (i in 1:length(groups)) {
    x <- xml_find_all(groups[i], 'DartSequencerDescriptorEntry')
    args <- (xml_attr(x, 'args'))
    if (length(args) > 1){
      argLen <- c()
      for (ii in 1:length(args)) {
        argLen <- c(argLen, length(strsplit(args[ii], ';')[[1]]))
        if ( length(unique(argLen)) > 1) {
          stop('Args within the same group must have the same length. Current arg lengths in ',
               xml_attr(groups[i], 'groupName'), ': ', paste(argLen, collapse = ', '), '.')
        }
      }
    }
  }
}
