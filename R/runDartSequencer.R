
runDartSequencer <- function(newSequenceFileXML, simName, DARTprogDir, maxTime) {
  # runs DART sequencer using the inputs of newPath
  require(xml2)
  require(processx)
  require(R.utils)

  #required paths
  simPath <- paste0(c(DARTprogDir, 'user_data', 'simulations', simName), collapse = '/')
  newsequenceXMLpath <- paste0(c(simPath, newSequenceFileXML),  collapse = '/')

  l2FileName <- paste0(c(simName, newSequenceFileXML), collapse = '/')
  sequenceDir <- paste0(simPath, '/sequence')

  # read new file
  newSequemceXML <- xml2::read_xml(x = newsequenceXMLpath)

  # delete re made directories
  deleteDirs(simPath)

  # find the operating system
  os <- get_os()
  # run process
  if (os == "win") {
    # start dart process for windows
    dartSequenceDir <- paste0(c(DARTprogDir, 'tools', 'windows'), collapse = '/')
    p <- process$new('dart-sequence.bat', args = c(l2FileName, '-start', '-jobs'),
                     wd = dartSequenceDir, stderr = '|')
    }

  if (os == "mac" | os == "unix") {
    # start dart process for windows
    dartSequenceDir <- paste0(c(DARTprogDir, 'tools', 'linux'), collapse = '/')
    p <- process$new('./dart-sequence.sh', args = c(l2FileName, '-start', '-jobs'),
                     wd = dartSequenceDir, stderr = '|')
  }

  # test if connection was successful and check for any errors
  status <- p$is_alive()

  if (status == FALSE) {
    stop('Process failed, please check inputs.')
  }

  # check for any errors
  # check for any errors
  # check for any errors
  p$get_error_connection()
  err <- p$read_error_lines()

  if (!identical(err, character(0))) {
    p$kill_tree()
    stop('DART error message: ', err)
  }

  # find number of parrallel threads to find how many files should have been created in the folder 'sequence'
  # and what the numbers of the folders should be
  reqiredFileNames <- getReqFileNames(newSequemceXML, sequenceDir, newSequenceFileXML)

  #when all files are created kill process
  #potential for infinite loop - add a timeout (optional argument to function?)
  # check if all the required files are created. If they are end the process.
  start <- Sys.time()
  while (!all(file.exists(reqiredFileNames))) {
    Sys.sleep(1)
    if( as.numeric((Sys.time()-start), units = 'secs') > maxTime) {
      warning( 'maxTime surpassed, process ended')
      p$kill_tree() }
  }

  #end process
  p$kill_tree()
  message('Sequence folders configured.')
}


