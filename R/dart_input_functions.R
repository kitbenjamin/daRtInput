
dartSeqNewInputs <- function(inputPath, groupNames, propertyNames, newArgs, 
                              dartDir, newPath = inputPath){
  # define the inputs into DART sequencer and run the sequence
  #
  # Args:
  # inputPath: Path to an xml file containing property arguments you would like to change
  # groupNames: name(s) of the group in which the property you would like to change is 
  #   in (can be found using getInputNames function). If multiple then input a vector containing 
  #   groupNames.
  # propertyNames: name(s) of the property which you would like to change the DART input for.
  #   If multiple then input a vector containing propertyNames.
  # newArgs: required property input into DART simulation. Values must be in a string, or vector 
  #   of strings, with each value separated by ';'. For example, if the deisred inputs were 
  #   1,2,3,4 for one property and 5,6,7,8 for another property, newArg would be c("1;2;3;4", "5;6;7;8").
  # newPath: new file path. Default is to replace the input file.
  # dartDir: path to the 'operating system' directory within the DART directory, where DART is installed on your 
  #   system. For example, dartDir for a user 'user' using a windows system will be  
  #   'C:\\User\\DART\\tools\\windows'
  #
  # Output:
  # An xml file with new specified values to input into DART simulation, new folders of 'jobs', 'output' and 
  # 'sequences', which can be used to in a DART simulation.
  
  # inputs are written to xml file, newPath
  applyChangePropInputs(inputPath, groupNames, propertyNames, newArgs, newPath)
  
  # run newPath through DART sequencer
  runDartSequencer(newPath, dartDir)
}

applyChangePropInputs <- function(inputPath, groupNames, propertyNames, newArgsList, newPath) {
  # find the group names and variables in each group
  groupVar <- getInputNames(inputPath, print = FALSE)
  
  # read in xml file
  inputFile <- read_xml(x = inputPath)
  
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
  write_xml(inputFile, newPath)
}

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

numberParallelThreads <- function (inputFile) {
  # find the number of parrallel threads
  
  groupPath <- '/DartFile/DartSequencerDescriptor/DartSequencerDescriptorEntries/DartSequencerDescriptorGroup'
  groups <- xml_find_all(inputFile, groupPath)
  
  groupLen <- c()
  for (i in 1:length(groups)) {
    x <- xml_find_all(groups[i], 'DartSequencerDescriptorEntry')
    args <- (xml_attr(x, 'args'))
    lensArgs <- unique(lengths(strsplit(args, ';')))
    groupLen <- c(groupLen, lensArgs)
  }
  nParThre <- as.character(prod(groupLen))
  return(nParThre)
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

getNewSeqName <- function(inputFile, newPath) {
  # create new sequence name
  
  # split up current descriptor name
  seqDescPath <- '/DartFile/DartSequencerDescriptor'
  seqDesc <- xml_find_all(inputFile, seqDescPath)
  seqName <- xml_attr(seqDesc, 'sequenceName') 
  splitSeqName <- strsplit(seqName, ';;')
  
  # get new file name 
  splitPathName <- getSplitPathName(newPath)
  
  fileName <- splitPathName[[1]][length(splitPathName[[1]])]
  fileName <- stringr::str_remove(fileName, '.xml')
  
  # paste new and old together
  newSeqName <- paste0(splitSeqName[[1]][1], ';;', fileName)
  
  return(newSeqName)
}

getGroupIndex <- function(inputFile, groupName) {
  # finds the index of the specified group
  
  groupPath <- '/DartFile/DartSequencerDescriptor/DartSequencerDescriptorEntries/DartSequencerDescriptorGroup'
  groups <- xml_find_all(inputFile, groupPath)
  groupIndex <- which(xml_attr(groups, 'groupName') == as.character(groupName))
  return(groupIndex)
}

get_os <- function() {
  # gets the operating system of device
  
  if (.Platform$OS.type == "windows") {
    "win"
  } else if (Sys.info()["sysname"] == "Darwin") {
    "mac"
  } else if (.Platform$OS.type == "unix") {
    "unix"
  } else {
    stop("Unknown OS")
  }
}

getSplitPathName <- function(newPath) {
  # get the splitPathName fom newPath based on the separator used
  
  splitPathName <- strsplit(newPath, "[\\\\ /]+")
  
  return(splitPathName)
}

deleteDirs <- function(newPathUnsplit){
  # delete jobs, output and sequence directories
  
  delNames <- c('/Jobs', '/Output', '/sequence')
  delDirs <- paste0(newPathUnsplit, delNames)
  unlink(delDirs, recursive = TRUE) 
  if (any(file.exists(delDirs) == TRUE)){
    warning('files not deleted: retrying')
    unlink(delDirs, recursive = TRUE)
  }
}

getFileName <- function(splitPathName2) {  
  # gets the new filename
  fileName <- splitPathName2[length(splitPathName2)]
  fileName <- stringr::str_remove(fileName, '.xml')
  return(fileName)
}

getReqFileNames <- function(newInputFile, sequenceDir, fileName) {
  # get the required file names to be created before process ends
  
  seqPrefsPath <- '/DartFile/DartSequencerDescriptor/DartSequencerPreferences'
  seqPrefs <- xml_find_all(newInputFile, seqPrefsPath)
  nParThre <- xml_attr(seqPrefs, 'numberParallelThreads')
  
  reqiredFileNos <- seq(0, as.numeric(nParThre) - 1, by = 1)
  reqiredFileNames <- paste0(sequenceDir, '/', fileName, '_', reqiredFileNos)
  return(reqiredFileNames)
}


runDartSequencer <- function(newPath, dartDir) {
  # runs DART sequencer using the inputs of newPath
  
  # read new file 
  newInputFile <- read_xml(x = newPath)
  
  # get new file name and directory to sequence folder
  splitPathName <- getSplitPathName(newPath)
  
  splitPathName2 <- splitPathName[[1]][c(length(splitPathName[[1]])-1, length(splitPathName[[1]]))]
  l2FileName <- paste0(splitPathName2, collapse = '/') 
  
  newPathSplit <- splitPathName[[1]][1:length(splitPathName[[1]])-1]
  newPathUnsplit <- paste0(newPathSplit, collapse = '/')
  sequenceDir <- paste0(newPathUnsplit, '/sequence')
  
  # delete re made directories
  deleteDirs(newPathUnsplit)
  
  # find the operating system
  os <- get_os()
  # run process
  if (os == "win") {
    # start dart process for windows
    p <- process$new('dart-sequence.bat', args = c(l2FileName, '-start', '-jobs'), 
                     wd = dartDir, stderr = '|', echo_cmd = TRUE) 
  }
  if (os == "mac" | os == "unix") {
    # start dart process for windows
    p <- process$new('dart-sequence.sh', args = c(l2FileName, '-start', '-jobs'), 
                     wd = dartDir, stderr = '|') 
  }
  
  # test if connection was successful and check for any errors
  status <- p$is_alive()
  
  if (status == FALSE) { 
    warning('Process failed, please check inputs.')
  }
  
  # check for any errors
  p$get_error_connection()
  err <- p$read_error_lines()
  
  if (identical(err,character(0)) == FALSE) {
    warning('DART error message: ', err)
    p$kill()
  }
  
  #get the file name
  fileName <- getFileName(splitPathName2)
  
  # find number of parrallel threads to find how many files should have been created in the folder 'sequence'
  # and what the numbers of the folders should be
  reqiredFileNames <- getReqFileNames(newInputFile, sequenceDir, fileName)
  
  #when all files are created kill process
  while (!all(file.exists(reqiredFileNames))) {
    Sys.sleep(1)
  }
  
  #end process
  p$kill()
  message('MESSAGE: process successful, connection ended.')
}

getInputNames <- function(inputPath, print = TRUE) {
  #show what groups are available and what variables are available in each group
  
  inputFile <- read_xml(x = inputPath)
  
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
