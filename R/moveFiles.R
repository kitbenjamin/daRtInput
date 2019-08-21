moveFiles <- function(simName, DARTprogDir, newSequenceFileXML, DARTprocess, userDescBool, userDesc){
  # moves files from simulation folder to new folder

  #path to the simulation folder
  simPath <- paste0(c(DARTprogDir, 'user_data', 'simulations', simName), collapse = '/')

  #create directory to be moved to
  if (userDescBool == FALSE) {
    newDir <- paste0(simPath, '/daRtinput', '/', strftime(Sys.time(), format = "%Y_%j_%H.%M.%S") )
    dir.create(newDir, recursive = TRUE)
  } else if (userDescBool == TRUE) {
    if (is.null(userDesc )) {
      stop('userDesc must be a string')
    }
    else {
    newDir <- paste0(simPath, '/daRtinput', '/', userDesc)
    dir.create(newDir, recursive = TRUE)}
  } else { stop( 'userDescBool must be a boolean' )}

  # get all files in sequence folder
  seqDir <- paste0(simPath, '/sequence')
  seqFiles <- list.files(seqDir)
  seqFilePaths <- paste0(seqDir, '/', seqFiles)

  # move all to new folder
  a <- lapply(seqFilePaths, function(x) {file.copy(x, newDir, recursive = TRUE)
    unlink(x, recursive = TRUE)})

  os <- get_os()
  if (os == 'mac' | os == 'unix') {
    createShellScripts(DARTprogDir, newDir, DARTprocess)
  }
  if (os == 'win') {
    createBatScripts(DARTprogDir, newDir, DARTprocess)
  }
}
