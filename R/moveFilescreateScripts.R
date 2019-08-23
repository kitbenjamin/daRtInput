moveFilescreateScripts <- function(simName, DARTprogDir, newSequenceFileXML, DARTprocess,dbFullPath,  userDescBool, userDesc){
  # moves filles from simulation folder to new folder

  #path to the simulation folder
  simPath <- paste0(c(DARTprogDir, 'user_data', 'simulations', simName), collapse = '/')

  #create directory to be moved to
  if (userDescBool == FALSE) {
    newDir <- paste0(simPath, '/daRtinput', '/', strftime(Sys.time(), format = "%Y_%j_%H.%M.%S"), '/', simName )
    dir.create(newDir, recursive = TRUE)
  } else if (userDescBool == TRUE) {
    if (is.null(userDesc )) {
      stop('userDesc must be a string')
    }
    else {
    newDir <- paste0(simPath, '/daRtinput', '/', userDesc,  '/', simName)
    dir.create(newDir, recursive = TRUE)}
  } else { stop( 'userDescBool must be a boolean' )}

  # get all files in sequence folder
  seqDir <- paste0(simPath, '/sequence')
  seqFiles <- list.files(seqDir)
  seqFilePaths <- paste0(seqDir, '/', seqFiles)

  # move all to new folder
  a <- lapply(seqFilePaths, function(x) {file.copy(x, newDir, recursive = TRUE)
    unlink(x, recursive = TRUE)})

  # create batch or shell scripts
  os <- get_os()
  if (os == 'mac' | os == 'unix') {
    createShellScripts(DARTprogDir, newDir, DARTprocess)
  }
  if (os == 'win') {
    createBatScripts(DARTprogDir, newDir, DARTprocess)
  }

  dbName <- paste0(simName, '_JTT.db')
  newDirSp <- strsplit(newDir, '/')[[1]]
  newDirm1 <- paste(newDirSp[1:length(newDirSp) -1], collapse = '/')
  dbFullPath <- paste0(newDirm1, '/', dbName )
  createJTT(dbFullPath, simName, newDir)
}
