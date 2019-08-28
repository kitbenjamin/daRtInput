numberParallelThreads <- function (sequenceXML) {
  # find the number of parrallel threads
  require(xml2)

  groupPath <- '/DartFile/DartSequencerDescriptor/DartSequencerDescriptorEntries/DartSequencerDescriptorGroup'
  groups <- xml2::xml_find_all(sequenceXML, groupPath)

  groupLen <- c()
  for (i in 1:length(groups)) {
    x <- xml2::xml_find_all(groups[i], 'DartSequencerDescriptorEntry')
    args <- (xml2::xml_attr(x, 'args'))
    if (xml2::xml_attr(x, 'type') == 'enumerate'){
      lensArgs <- unique(lengths(strsplit(args, ';')))
    } else if (xml2::xml_attr(x, 'type') == 'linear'){
      spl <-  strsplit(args, ';')[[1]]
      lensArgs <- as.integer(unique(spl[length(spl)]))
    }
    groupLen <- c(groupLen, lensArgs)
  }
  nParThre <- as.character(prod(groupLen))
  return(nParThre)
}


getGroupIndex <- function(sequenceXML, groupName) {
  # finds the index of the specified group
  require(xml2)

  groupPath <- '/DartFile/DartSequencerDescriptor/DartSequencerDescriptorEntries/DartSequencerDescriptorGroup'
  groups <- xml2::xml_find_all(sequenceXML, groupPath)
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


deleteDirs <- function(simPath){
  # delete jobs, output and sequence directories

  delNames <- c('/Jobs', '/Output', '/sequence')
  delDirs <- paste0(simPath, delNames)
  if (any(file.exists(delDirs) == TRUE)){
    unlink(delDirs, recursive = TRUE)
  }
}

getFileName <- function(splitPathName2) {
  # gets the new filename
  require(stringr)

  fileName <- splitPathName2[length(splitPathName2)]
  fileName <- stringr::str_remove(fileName, '.xml')
  return(fileName)
}

getReqFileNames <- function(newSequemceXML, sequenceDir, newSequenceFileXML) {
  # get the required file names to be created before process ends
  require(xml2)
  require(stringr)

  seqPrefsPath <- '/DartFile/DartSequencerDescriptor/DartSequencerPreferences'
  seqPrefs <- xml2::xml_find_all(newSequemceXML, seqPrefsPath)
  nParThre <- xml2::xml_attr(seqPrefs, 'numberParallelThreads')

  fileName <- stringr::str_remove(newSequenceFileXML, '.xml')

  reqiredFileNos <- seq(0, as.numeric(nParThre) - 1, by = 1)
  reqiredFileNames <- paste0(sequenceDir, '/', fileName, '_', reqiredFileNos)
  return(reqiredFileNames)
}

isLUTselected <- function(sequenceXML){
  #return bool value for: is the lookup table selected?
  require(xml2)
  LUTinfo <- xml2::xml_find_all(x = sequenceXML, "/DartFile/DartSequencerDescriptor/DartLutPreferences")
  LUTattr <- xml2::xml_attr(x = LUTinfo, "generateLUT")
  LUTval <- match.arg(LUTattr, c("true", "false"), several.ok = FALSE)
  LUTvalBool <- ifelse(LUTval == "false", FALSE, TRUE)
  return(LUTvalBool)

}

getND2_lin <- function (newDir) {
  newDirSplit <- strsplit(newDir, '/')[[1]]
  newDir2 <- paste0(newDirSplit[(length(newDirSplit) - 3) :length(newDirSplit)], collapse = '/')
  return(newDir2)
}

getND2_win <- function (newDir) {
  newDirSplit <- strsplit(newDir, '/')[[1]]
  newDir2 <- paste0(newDirSplit[(length(newDirSplit) - 3) :length(newDirSplit)], collapse = '\\')
  return(newDir2)
}

changeSep <- function(path, oldSep, newSep) {
  pathSplit <- strsplit(path, oldSep)[[1]]
  paste0(pathSplit, collapse = newSep)
}
