require(xml2)
numberParallelThreads <- function (inputFile) {
  # find the number of parrallel threads

  groupPath <- '/DartFile/DartSequencerDescriptor/DartSequencerDescriptorEntries/DartSequencerDescriptorGroup'
  groups <- xml2::xml_find_all(inputFile, groupPath)

  groupLen <- c()
  for (i in 1:length(groups)) {
    x <- xml2::xml_find_all(groups[i], 'DartSequencerDescriptorEntry')
    args <- (xml2::xml_attr(x, 'args'))
    lensArgs <- unique(lengths(strsplit(args, ';')))
    groupLen <- c(groupLen, lensArgs)
  }
  nParThre <- as.character(prod(groupLen))
  return(nParThre)
}

require(stringr)
getNewSeqName <- function(inputFile, newPath) {
  # create new sequence name

  # split up current descriptor name
  seqDescPath <- '/DartFile/DartSequencerDescriptor'
  seqDesc <- xml2::xml_find_all(inputFile, seqDescPath)
  seqName <- xml2::xml_attr(seqDesc, 'sequenceName')
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
  groups <- xml2::xml_find_all(inputFile, groupPath)
  groupIndex <- which(xml2::xml_attr(groups, 'groupName') == as.character(groupName))
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
  seqPrefs <- xml2::xml_find_all(newInputFile, seqPrefsPath)
  nParThre <- xml2::xml_attr(seqPrefs, 'numberParallelThreads')

  reqiredFileNos <- seq(0, as.numeric(nParThre) - 1, by = 1)
  reqiredFileNames <- paste0(sequenceDir, '/', fileName, '_', reqiredFileNos)
  return(reqiredFileNames)
}





