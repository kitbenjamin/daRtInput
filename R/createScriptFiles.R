createShellScripts <- function(DARTprogDir, newDir, DARTprocess) {
  # create shell files for each sequence folder

  #all folders shell must be created for
  seqFiles <- list.files(newDir)
  # split to get required directory to put into batch file
  newDir2 <- getND2_lin(newDir)

  #first and last lines
  line1 <- '#!/bin/sh'

  #loop over all sequence folder
  for (i in seqFiles) {
    # get path to file and path to file in shell
    seqFilePath <- paste0(newDir,  '/' , i)
    seqFilePath2 <- paste0(newDir2,  '/' , i)

    #get cd line
    cd <- paste('cd', DARTprogDir, sep = ' ')
    cd2 <- paste0(cd, '/tools/linux/;')

    #create new file
    newFile <- paste0(seqFilePath, '/', i, '.sh')
    fileConn <- file(newFile)

    #write first line
    cat(line1, file = fileConn)
    cat('\n',file = newFile, append = TRUE)
    for (ii in DARTprocess){
      # create the first dart process dir
      DARTprocessName <- paste0('./dart', '-', ii, '.sh')
      DARTprocessDir <- paste(cd2, DARTprocessName, sep = ' ')

      # write new line
      line <- paste(DARTprocessDir, seqFilePath2, sep = ' ')
      cat(line, file = newFile, append = TRUE)
      cat('\n\n',file = newFile, append = TRUE)
    }
    close(fileConn)
  }
}

createBatScripts <- function(DARTprogDir, newDir, DARTprocess) {
  # create batch files for each sequence folder

  #all folders batch must be created for
  seqFiles <- list.files(newDir)

  # split to get required directory to put into batch file
  newDir2 <- getND2_win(newDir)

  #define the echo line
  line1 <- '@echo OFF'

  #loop over all sequence folder
  for (i in seqFiles) {
    # get path to file and path to file in batch
    seqFilePath <- paste0(newDir,  '/' , i)
    seqFilePath2 <- paste0(newDir2,  '\\' , i)

    #create new file
    newFile <- paste0(seqFilePath, '\\', i, '.bat')
    fileConn <- file(newFile)

    #write first line
    cat(line1, file = fileConn)
    cat('\n',file = newFile, append = TRUE)
    for (ii in DARTprocess){
      # create the first dart process dir
      DARTprocessName <- paste0('dart', '-', ii, '.bat')

      DARTprogDir2 <- changeSep(DARTprogDir, '/', '\\')
      DARTprocessDir <- paste0(DARTprogDir2, '\\tools\\windows\\' , DARTprocessName )

      # write new line
      line <- paste('START', DARTprocessDir, seqFilePath2, sep = ' ')
      cat(line, file = newFile, append = TRUE)
      cat('\n\n',file = newFile, append = TRUE)
    }
    close(fileConn)
  }
}



