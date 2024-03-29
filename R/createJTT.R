createJTT <- function(dbFullPath, simName, newDir, DARTprogDir){
  #check if the database and the table identifying the simName exists
  # get all files in sequence folder
  seqDir <- paste0(c(DARTprogDir, 'user_data', 'simulations', simName, 'sequence'), collapse = '/')
  seqFiles <- list.files(seqDir)
  #try to connect 10 times
  dbExists <- file.exists(dbFullPath)
  if(dbExists) return(NULL)
  #incase the db is "locked"
  for(i in 1:10){
    try({
      #in case another process has created a DB
      dbExists <- file.exists(dbFullPath)
      if (dbExists) break
      dbConn <- RSQLite::dbConnect(RSQLite::SQLite(), dbname = dbFullPath)
      break #break/exit the for-loop
    }, silent = FALSE)
    RSQLite::dbDisconnect(dbConn)
    print(i)
    Sys.sleep(1)
  }

  #create the table
  RSQLite::dbSendQuery(conn = dbConn,
                       statement = paste("CREATE TABLE", simName,
                                         "(sequenceIndex INTEGER,
                                     scriptDirectory VARCHAR,
                                     scriptName VARCHAR,
                                     exitStatus INTEGER,
                                     startTime VARCHAR,
                                     endTime VARCHAR)"))


  os <- get_os()
  # add the index and file path
  for (i in seqFiles){
    sindex <- strsplit(i, '_')[[1]]
    index <- sindex[length(sindex)]

    seqFilePath <- paste0(newDir,  '/' , i)

    if (os == 'mac' | os == 'unix'){
      scriptName <- paste0(i,'.sh')
    } else if (os == 'win') {
      scriptName <- paste0(i,'.bat')
    }

    RSQLite::dbSendQuery(conn = dbConn, paste('INSERT INTO', simName, '(sequenceIndex, scriptDirectory, scriptName)',
                                              'VALUES(', index, ', "', seqFilePath , '"' , ', "', scriptName, '")'))
  }

  # fill exitstatus with 999
  RSQLite::dbSendQuery(conn = dbConn, paste('UPDATE', simName, 'SET exitStatus = -2'))

  #disconnect
  RSQLite::dbDisconnect(dbConn)
}
