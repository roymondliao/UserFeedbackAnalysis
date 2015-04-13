Sys.setenv(JAVA_HOME="C:\\Program Files (x86)\\Java\\jre7")
library(rJava)
library(xlsx)
### data check and reload R script
tasklist <- c("R.exe", "Rterm.exe", "java.exe","firefox.exe")
if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "00:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "06:00:00", sep = " ")){
 # zone one
  file.address <- sprintf("D:/output/Data_by_date/data_%s.xlsx", Sys.Date()-1)
  wb <- loadWorkbook(file.address)
  sheet.number <- getSheets(wb) 
  if(length(sheet.number) != 8){
    #system("tasklist", intern = TRUE)
    for(t in 1:length(tasklist)){
      task_index <- unlist(strsplit(grep(tasklist[t],readLines(textConnection(system("tasklist", intern = TRUE))), value = TRUE), split = " "))
      PID <- task_index[grep("^[0-9]+", task_index)[1]]
      system(sprintf('taskkill /pid %s', PID), intern = TRUE)
    }
    system("D:/R/R-3.0.3/bin/i386/R.exe R CMD BATCH --no-restore --save D:/R_code/R_exe/MainFunction(Download_by_Total).R", 
           intern = TRUE)
    q(save = "no")
  } 
}else if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "06:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "12:00:00", sep = " ")){
  # zone two 
  file.address <- sprintf("D:/output/Data_by_date/data_%s.xlsx", Sys.Date())
  wb <- loadWorkbook(file.address)
  sheet.number <- getSheets(wb) 
  if(file.exists(file.address) == FALSE){
    for(t in 1:length(tasklist)){
      task_index <- unlist(strsplit(grep(tasklist[t],readLines(textConnection(system("tasklist", intern = TRUE))), value = TRUE), split = " "))
      PID <- task_index[grep("^[0-9]+", task_index)[1]]
      system(sprintf('taskkill /pid %s', PID), intern = TRUE)
    }
    system("D:/R/R-3.0.3/bin/i386/R.exe R CMD BATCH --no-restore --save D:/R_code/R_exe/MainFunction(Download_by_Total).R", 
           intern = TRUE)
    q(save = "no")
  }
}else if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "12:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "18:00:00", sep = " ")){
  # zone three
  file.address <- sprintf("D:/output/Data_by_date/data_%s.xlsx", Sys.Date())
  wb <- loadWorkbook(file.address)
  sheet.number <- getSheets(wb) 

  if(length(sheet.number) != 4){
    for(t in 1:length(tasklist)){
      task_index <- unlist(strsplit(grep(tasklist[t],readLines(textConnection(system("tasklist", intern = TRUE))), value = TRUE), split = " "))
      PID <- task_index[grep("^[0-9]+", task_index)[1]]
      system(sprintf('taskkill /pid %s', PID), intern = TRUE)
    }
    system("D:/R/R-3.0.3/bin/i386/R.exe R CMD BATCH --no-restore --save D:/R_code/R_exe/MainFunction(Download_by_Total).R", 
           intern = TRUE)
    q(save = "no")
  } 
}else{
  # zone four
  file.address <- sprintf("D:/output/Data_by_date/data_%s.xlsx", Sys.Date())
  wb <- loadWorkbook(file.address)
  sheet.number <- getSheets(wb) 

  if(length(sheet.number) != 6){
    for(t in 1:length(tasklist)){
      task_index <- unlist(strsplit(grep(tasklist[t],readLines(textConnection(system("tasklist", intern = TRUE))), value = TRUE), split = " "))
      PID <- task_index[grep("^[0-9]+", task_index)[1]]
      system(sprintf('taskkill /pid %s', PID), intern = TRUE)
    }
    system("D:/R/R-3.0.3/bin/i386/R.exe R CMD BATCH --no-restore --save D:/R_code/R_exe/MainFunction(Download_by_Total).R", 
           intern = TRUE)
    q(save = "no")
  }
 }
