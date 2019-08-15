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
