createJTT <- function(dbFullPath, simName, seqFiles){
  #check if the database and the table identifying the simName exists
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

  # get all the sequence file names
  seqFiles <- list.files(newDir)

  #create the table
  RSQLite::dbSendQuery(conn = dbConn,
                       statement = paste("CREATE TABLE", simName,
                                         "(sequenceIndex INTEGER,
                                     scriptDirectory VARCHAR,
                                     exitStatus INTEGER,
                                     startTime VARCHAR,
                                     endTime VARCHAR)"))

  # add the index and file path
  for (i in seqFiles){
    sindex <- strsplit(i, '_')[[1]]
    index <- sindex[length(sindex)]

    seqFilePath <- paste0(newDir,  '/' , i)
    scriptDir <- paste0( newDir, '/', i, '.sh')

    RSQLite::dbSendQuery(conn = dbConn, paste('INSERT INTO', simName, '(sequenceIndex, scriptDirectory)',
                                              'VALUES(', index, ', "', scriptDir , '"' , ')'))
  }

  # fill exitstatus with 999
  RSQLite::dbSendQuery(conn = dbConn, paste('UPDATE', simName, 'SET exitStatus = 999'))

  #disconnect
  RSQLite::dbDisconnect(dbConn)
}

createJTT(dbFullPath, simName, seqFiles)

dbFullPath <- 'C:/Users/kitbe/DART/user_data/simulations/cesbio/daRtinput/2019_235_13.29.43/cesbio_JTT.db'
newDir <- 'C:/Users/kitbe/DART/user_data/simulations/cesbio/daRtinput/2019_235_13.29.43/cesbio'
simName <- 'cesbio'
