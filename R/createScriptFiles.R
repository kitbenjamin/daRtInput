createShellScripts <- function(DARTprogDir, newDir, DARTprocess) {
  seqFiles <- list.files(newDir)
  line1 <- '#!/bin/sh'
  line3 <- '##end script'

  DARTprocessName <- paste0('dart', '-', DARTprocess, '.sh')
  DARTprocessDir <- paste0(DARTprogDir, '/tools/linux/',DARTprocessName )
  for (i in seqFiles) {
    seqFilePath <- paste0(newDir,  '/' , i)
    line2 <- paste(DARTprogDir, seqFilePath, sep = ' ')
    newFile <- paste0(seqFilePath, '/', i, '.sh')
    fileConn<-file(newFile)
    writeLines(c(line1,line2, line3), fileConn, sep = "\n\n")
    close(fileConn)
  }
}

createBatScripts <- function(DARTprogDir, newDir, DARTprocess) {
  seqFiles <- list.files(newDir)
  line1 <- '@echo OFF'

  DARTprocessName <- paste0('dart', '-', DARTprocess, '.bat')
  DARTprocessDir <- paste0(DARTprogDir, '/tools/windows/',DARTprocessName )
  for (i in seqFiles) {
    seqFilePath <- paste0(newDir,  '/' , i)
    line2 <- paste('START', DARTprocessDir, seqFilePath, sep = ' ')
    newFile <- paste0(seqFilePath, '/', i, '.bat')
    fileConn<-file(newFile)
    writeLines(c(line1,line2), fileConn, sep = "\n\n")
    close(fileConn)
  }
}
