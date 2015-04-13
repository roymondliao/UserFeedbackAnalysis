source("D://R_code//R_exe//MainFunction(Package_load).r")
Sys.setlocale(category='LC_ALL', locale='Chinese (Traditional)_Taiwan.950')
#-------------------------load star table-------------------------#
#remove.packages("RSelenium")
#devtools::install_github("ropensci/RSelenium")
#if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") < paste(Sys.Date(), "05:00:00", spe = " ")){
library(RSelenium)
### setting browser driver
browser_setting = 1
if(browser_setting == 1){
  ### Start Selenium server
  ### DOWNLOADING STANDALONE SELENIUM SERVER. THIS MAY TAKE SEVERAL MINUTES
  RSelenium::checkForServer(dir = "D:/R/R-3.0.3/library/RSelenium/bin/selenium-server-standalone-2.44.0")
  ### Start Selenium server
  RSelenium::startServer(dir = "D:/R/R-3.0.3/library/RSelenium/bin/selenium-server-standalone-2.44.0", args = c("-port 5555"), log = FALSE, invisible = FALSE)
  ### opean browser it needs wait a moment to open the browser
  remDr <- remoteDriver(browserName = "firefox", remoteServerAddr = "localhost" , port = 5555)
  remDr$open()
}else if(browser_setting  == 2){
  ### DOWNLOADING STANDALONE SELENIUM SERVER. THIS MAY TAKE SEVERAL MINUTES
  RSelenium::checkForServer()
  RSelenium::startServer(args = c("-Dwebdriver.chrome.driver=D:/R_code/chromedriver.exe"), log = FALSE, invisible = FALSE)
  remDr <- remoteDriver(browserName = "chrome")
  ### opean browser it needs wait a moment to open the browser
  remDr$open()
}
Sys.sleep(10)

### parse web option setting 
#remDr$setTimeout(type = "page load", milliseconds = 100000) ### loading page 10 second
tryCatch({
### loading http://mp.ijinshan.com/ website 
source("D:/R_code/R_exe/account_info.R")
username = username
password = password
remDr$navigate("http://mp.ijinshan.com/")

Sys.sleep(5)
webElems <- remDr$findElements(using = "name", value = "username")
webElems[[1]]$sendKeysToElement(list(username))
webElems <- remDr$findElements(using = "name", value = "password")
webElems[[1]]$sendKeysToElement(list(password, key = "enter")) 

### loading GP platform
Sys.sleep(5)
webElems <- remDr$findElements(using = "xpath", value = "//tr//td//a")
platform <- unlist(lapply(webElems, function(x){x$getElementText()}))
webElem <- webElems[which(platform == platform[2])]
webElem[[1]]$clickElement()

### loading http://gpfk.cm.ijinshan.com/index/go redirect check
#Sys.sleep(5)
#remDr$navigate("http://gpfk.cm.ijinshan.com/index/go")
#webElems <- remDr$findElements(using = "xpath", value = "//body")
#system.check <- unlist(lapply(webElems, function(x){x$getElementText()}))
#if(length(system.check) != 0){
#  while(system.check == "system error"){
#    remDr$navigate("http://gpfk.cm.ijinshan.com/index/go")
#    webElems <- remDr$findElements(using = "xpath", value = "//body")
#    system.check <- unlist(lapply(webElems, function(x){x$getElementText()}))
#  }  
#}

#Sys.sleep(5)
#webElems <- remDr$findElements(using = "xpath", value = "//div//ul//li//a")
#products <- unlist(lapply(webElems, function(x){x$getElementText()}))
#webElem <- webElems[[which(products == "CM Security")]]
#webElem$clickElement()

###  get All cookies
Sys.sleep(5)
remDr$navigate("http://gpfk.cm.ijinshan.com/index/go?app=com.cleanmaster.security")
get_cookies <- unlist(remDr$getAllCookies())
remDr$getCurrentUrl()
cookieslist <- readLines("D:/R_code/R_exe/gp_cookies.txt", n = -1L)
cookieslist <- paste("ATOMCODEUID", get_cookies[["value"]], sep = "=")
writeLines(cookieslist, "D:/R_code/R_exe/gp_cookies.txt")

### close firefox
remDr$close()
remDr$closeServer()

},error = function(e){
  error <- paste("GP download by total Error from AWS:", e)
  sender <- "raymond.liao@ileopard.com" # Replace with a valid address
  recipients <- c("raymond.liao@ileopard.com") # Replace with one or more valid addresses
  send.mail(from = sender,to = recipients,subject = "GP download by total Error from AWS",
            body = error,
            attach.files = "D:/R_code/R_exe/MainFunction(Download_by_Total).Rout",
            smtp = list(host.name = "aspmx.l.google.com", port = 25))
})
#}
#-------------------------all GP data download by date-------------------------#
#date=seq.Date(from=as.Date("2014-08-13"),to=as.Date("2014-08-19"),by="day")
#datetime <- seq.Date(from = Sys.Date()-1, to = Sys.Date(), by = "day")
### date time check 
if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "00:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "06:00:00", sep = " ")){
  # zone one
  date <- Sys.Date()-1
}else if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "06:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "12:00:00", sep = " ")){
  # zone two 
  date <- Sys.Date()
}else if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "12:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "18:00:00", sep = " ")){
  # zone three
  date <- Sys.Date()
}else{
  # zone four 
  date <- Sys.Date()
}

total_page <- 500
merge_data <- data.table()
### get GP platform data
tryCatch({
for(d in 1:length(date)){
  d1 <- date[d]
  for (i in 1:total_page){
    try({
      print(c(i))
      url <- sprintf("http://gpfk.cm.ijinshan.com/index?grade=0&sVersion=&name=&assess=&date=%s&edate=%s&text_length=0&page=%d",d1,d1,i)
      today_data <- data.table(getPageData(url))
      merge_data <- rbind(merge_data,today_data)
      if(nrow(today_data)<20){
        break()
      }
    })
  }
  #suppressWarnings(write.table(merge_data,file=sprintf("D://output//Data_by_date//data_%s.csv",d1),append=TRUE,col.names=TRUE,row.names=FALSE,sep="\t",fileEncoding="UTF-8")) 
 }
},error = function(err){
  error <- paste("GP download by total Error from AWS:",err)
  sender <- "raymond.liao@ileopard.com" # Replace with a valid address
  recipients <- c("raymond.liao@ileopard.com") # Replace with one or more valid addresses
  send.mail(from = sender,to = recipients,subject = "GP download by total Error from AWS",
            body = error,
            attach.files = "D:/R_code/R_exe/MainFunction(Download_by_Total).Rout",
            smtp = list(host.name = "aspmx.l.google.com", port = 25))
})

### date time check 
merge_data <- merge_data[order(merge_data$comment_time), ]
if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "00:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "06:00:00", sep = " ")){
  # zone one
  comment_time_start <- paste(Sys.Date()-1, "18:00:00", sep = " ")
  comment_time_end <- paste(Sys.Date()-1, "24:00:00", sep = " ")
  merge_data$comment_time <- as.character(merge_data$comment_time)
  merge_data <- merge_data[which(merge_data$comment_time > comment_time_start & merge_data$comment_time < comment_time_end), ] 

  }else if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "06:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "12:00:00", sep = " ")){
  # zone two 
  comment_time_start <- paste(Sys.Date(), "00:00:00", sep = " ")
  comment_time_end <- paste(Sys.Date(), "06:00:00", sep = " ")
  merge_data$comment_time <- as.character(merge_data$comment_time)
  merge_data <- merge_data[which(merge_data$comment_time > comment_time_start & merge_data$comment_time < comment_time_end), ] 

  }else if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "12:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "18:00:00", sep = " ")){
  # zone three
  comment_time_start <- paste(Sys.Date(), "06:00:00", sep = " ")
  comment_time_end <- paste(Sys.Date(), "12:00:00", sep = " ")
  merge_data$comment_time <- as.character(merge_data$comment_time)
  merge_data <- merge_data[which(merge_data$comment_time > comment_time_start & merge_data$comment_time < comment_time_end), ] 

  }else{
  # zone four
  comment_time_start <- paste(Sys.Date(), "12:00:00", sep = " ")
  comment_time_end <- paste(Sys.Date(), "18:00:00", sep = " ")
  merge_data$comment_time <- as.character(merge_data$comment_time)
  merge_data <- merge_data[which(merge_data$comment_time > comment_time_start & merge_data$comment_time < comment_time_end), ] 
}
  
#suppressWarnings(write.table(merge_data,file = sprintf("D://output//Data_by_date//data_%s.xls",date),
#                             , append = TRUE, col.names = TRUE, row.names = FALSE, sep = "\t")) 
#write.xlsx2(merge_data,file = sprintf("D://output//Data_by_date//data_%s.xlsx",date), sheetName = "first",
#            append = TRUE, col.names = TRUE, row.names = FALSE)
#-------------------------The GP user's comment analysis-------------------------#
IssuesData <- data.frame(merge_data)
### use google translate platform
translate_setting = 2 # 1:google translate、 2:microsoft translater api
if(translate_setting ==1){ 
  for(t in 1:nrow(IssuesData)){
    print(c(t))
    try({
    if(t == round(nrow(IssuesData)/2, 0)){
      Sys.sleep(60)
    }else{
      if(substr(IssuesData$language[t], 1, 2) == "EN"){
        IssuesData$Tran_comment[t] <- with(IssuesData,tolower(comment[t])) 
      }else{
        IssuesData$Tran_comment[t] <- with(IssuesData,tolower(google_translate(comment[t])))
      }
    }
    })
  }
}else if(translate_setting == 2){
  ### use microsoft translator api
  ### language compare table
  language.table <- read.xlsx("D:\\R_code\\TranslatorLanguageCompare.xlsx", header = TRUE, sheetIndex = 1) 
  
  IssuesData$language.code <- with(IssuesData, substr(language, 1, 2))
  IssuesData$microsoft.code <- sapply(IssuesData$language.code, function(x) language.table$CODE[match(x, language.table$LANGUAGE)])
  IssuesData$microsoft.code <- as.character(IssuesData$microsoft.code)
  
  if (!require(translateR)) install.packages("translateR")
  require(translateR)
  require(rjson)
  require(RCurl)
  require(httr)
  cn.idx <- which(IssuesData$language == "ZH_CN")
  tw.idx <- which(IssuesData$language == "ZH_TW")
  hk.idx <- which(IssuesData$language == "ZH_HK")  
  no.code.idx <- which(IssuesData$microsoft.code == "no_code")
  
  IssuesData$microsoft.code[cn.idx] <- "zh-CHS"
  IssuesData$microsoft.code[tw.idx] <- "zh-CHT" 
  IssuesData$microsoft.code[hk.idx] <- "zh-CHT"
  IssuesData$microsoft.code[no.code.idx] <- ""
  IssuesData$comment <- as.character(IssuesData$comment)
  
  ### key paramter setting
  source("D:/R_code/R_exe/account_info.R")
  client.id.data <- client.id.data
  client.secret.data <- client.secret.data
  
  library(date)
  todaydate <- date.mdy(Sys.Date())
  if(todaydate$day >0 & todaydate$day <11){
    client.id <- client.id.data[1]
    client.secret <- client.secret.data[1]
  }else if(todaydate$day >10 & todaydate$day <21){
    client.id <- client.id.data[2]
    client.secret <- client.secret.data[2]
  }else if(todaydate$day >20 & todaydate$day <32){
    client.id <- client.id.data[3]
    client.secret <- client.secret.data[3]
  }
  
  #to.translate <- GP.DATA$Tran_comment[i]
  #target.lang <- "en"
  #source.lang <- GP.DATA$language[i]
  
  ### get access token
  getAccessToken <-function(client.id, client.secret){
    fields <- list(client_id = client.id,
                   client_secret = client.secret,
                   scope = 'http://api.microsofttranslator.com',
                   grant_type = 'client_credentials')
    return(rjson::fromJSON(postForm('https://datamarket.accesscontrol.windows.net/v2/OAuth2-13',
                                    .params = fields,
                                    .opts = list(ssl.verifypeer = FALSE),
                                    style = 'POST'))[['access_token']])
  }
  access.token <- getAccessToken(client.id, client.secret)
  
  ### microsoft Translate API
  microsoftTranslate <-function(x, access.token, source.lang, target.lang){
    params = paste("text=", URLencode(x), "&to=", target.lang, "&from=", source.lang, sep = '')
    translateUrl = paste("http://api.microsofttranslator.com/v2/Http.svc/Translate?", params, sep = '')
    return(
      gsub("<.*?>", "", GET(translateUrl, add_headers(Authorization = paste('Bearer', access.token))) )
    )
  }
  
  ptm <- proc.time()
  for(i in 1:nrow(IssuesData)){
    print(c(i))
    # get access token
    try({
      if((proc.time() - ptm)[3] > 540){
        ptm <- proc.time()
        access.token <- getAccessToken(client.id, client.secret)
      }
      if(IssuesData$microsoft.code[i] == "en"){
        IssuesData$Tran_comment[i] <- as.character(IssuesData$comment[i])
      }else{
        IssuesData$Tran_comment[i] <- as.character(microsoftTranslate(IssuesData$comment[i], access.token, 
                                                                      IssuesData$microsoft.code[i], "en"))
      }
    })
  }
  
  IssuesData <- IssuesData[ , -c(which(colnames(IssuesData) == "language.code"), which(colnames(IssuesData) == "microsoft.code"))]
  #write.xlsx2(IssuesData, file=sprintf("D://output//Data_by_date_tran//data_tran_%s.xlsx",date),sheetName="Sheet1", col.names=TRUE,row.names=FALSE)  
}  

### input data to monog db
### Mongo server setting 
library(rmongodb)
### definition mongo server and connection
mongo <- mongo.create() # connection to local server
mongo.is.connected(mongo) # connect to mongo server check

### show database
#mongo.get.databases(mongo) # get database in mongo server
db <- "GPDailyData"
#mongo.get.database.collections(mongo, "MailDailyData") # get collection from database

### create new mongo database and collection
#sort(mongo.get.database.collections(mongo, db)) # mongo.get.database.collections function also can create database

#star function change
#Sys.setlocale(category='LC_ALL', locale='C')
StarTable <- rjson::fromJSON(paste(readLines("D://R_code//R_exe//Setting//StarTable.json"), collapse=""))
#Sys.setlocale(category='LC_ALL', locale='Chinese (Traditional)_Taiwan.950')
StarTable
change.star <- function(data, S.Table){
  data <- mutate(data, star = iconv(star, "UTF-8", "UTF-8"))
  index_5 <- which(data$star==S.Table$star[5])
  index_4 <- which(data$star==S.Table$star[4])
  index_3 <- which(data$star==S.Table$star[3])
  index_2 <- which(data$star==S.Table$star[2])
  index_1 <- which(data$star==S.Table$star[1])
  data$star_no <- 0
  data$star_no[index_5] <- 5
  data$star_no[index_4] <- 4
  data$star_no[index_3] <- 3
  data$star_no[index_2] <- 2
  data$star_no[index_1] <- 1
  return(data)
}
### show how many document in database and create a data table 
#mongo.count(mongo, namespace)
### create a document to insert and change data type to list and insert the document into our data table
# function 
input.data.to.mongo <- function(data.list, mongo.name, mongo.collections) {
  if(is.list(data.list)) {
    bson <- mongo.bson.from.list(list(number = 1:length(data.list$name),
                                      name = as.character(data.list$name),
                                      id = as.character(data.list$id),
                                      star = as.character(data.list$star),
                                      language = as.character(data.list$language),
                                      software = as.character(data.list$software),
                                      phone = iconv(as.character(data.list$phone), from = "UTF-8", to = "UTF-8"),
                                      comment_time = as.character(data.list$comment_time),
                                      comment = as.character(data.list$comment),
                                      reply = as.character(data.list$reply),
                                      reply_time = as.character(data.list$reply_time),
                                      Tran_comment = as.character(data.list$Tran_comment),
                                      star_no = as.character(data.list$star_no)))
    mongo.insert(mongo.name, mongo.collections, bson)
  }else{
    error <- "GP data's class is not 'list' in mongodb "
    sender <- "raymond.liao@ileopard.com" # Replace with a valid address
    recipients <- c("raymond.liao@ileopard.com") # Replace with one or more valid addresses
    send.mail(from = sender,to = recipients,subject="MongoDB Server Error from AWS(Mongo input data code)",body =error,
              smtp = list(host.name = "aspmx.l.google.com", port = 25))
  }
}

IssuesData <- change.star(IssuesData, StarTable)
GP.data.list <- as.list(IssuesData)
db <- "GPDailyData"
namespace <- paste(db, date, sep = ".")
result.mongo <- input.data.to.mongo(GP.data.list, mongo, namespace)
print(paste(date, result.mongo, sep = ":"))

#-------------------------keyword search and analysis-------------------------#
index_bad <- bad_key_word_store_Tran(IssuesData)
index <- key_word_store_Tran(IssuesData)
index <- index[!index %in% index_bad]
ProsCommentData <- IssuesData[index,]  #Pros
ProsCommentData$type <- with(ProsCommentData, "pros")
ConsData <- IssuesData[-index, ] #Cons
ConsData$type <- with(ConsData, "cons")
ConsCommentData <- ConsData[!nchar(ConsData$Tran_comment)<71, ]
SpamCommentData <- ConsData[nchar(ConsData$Tran_comment)<71, ] #Spam
SpamCommentData$type <- with(SpamCommentData, "spam")
All_Data <- rbind(ProsCommentData, ConsCommentData, SpamCommentData)
#write.xlsx2(All_Data, sprintf("D://output//Data_by_gp_type//GP_Data_%s.xlsx", date), sheetIndex=1, row.names=FALSE)
ProsCommentData$GP_type <- with(ProsCommentData, "5_CMS")
ConsCommentData$GP_type <- with(ConsCommentData, "5_CMS")
SpamCommentData$GP_type <- with(SpamCommentData, "5_CMS")
All_CommentData <- rbind(ProsCommentData, ConsCommentData, SpamCommentData)
#-------------------------separate different type 1-------------------------#
index_applock_total <- vector()
index_scan_total <- vector()
index_privacy_total <- vector()
index_junk_total <- vector()
index_phone_total <- vector()
index_family_total <- vector()
index_backup_total <- vector()
applock <- fromJSON(paste(readLines("D://R_code//R_Gmail//R_Gmail_Project//applock.JSON"), collapse=""))
scan <- fromJSON(paste(readLines("D://R_code//R_Gmail//R_Gmail_Project//scan.JSON"), collapse=""))
privacy <- fromJSON(paste(readLines("D://R_code//R_Gmail//R_Gmail_Project//privacy.JSON"), collapse=""))
clean <- fromJSON(paste(readLines("D://R_code//R_Gmail//R_Gmail_Project//clean.JSON"), collapse=""))
phone <- fromJSON(paste(readLines("D://R_code//R_Gmail//R_Gmail_Project//phone.JSON"), collapse=""))
family <- fromJSON(paste(readLines("D://R_code//R_Gmail//R_Gmail_Project//family.JSON"), collapse=""))
backup <- fromJSON(paste(readLines("D://R_code//R_Gmail//R_Gmail_Project//backup.JSON"), collapse=""))
keyword.search <- function(word.list, data = All_CommentData) {
  index_total <- vector()
  for(i in 1:length(word.list)){
    index_1 <- grep(word.list[i], data$Tran_comment) 
    if (length(index_1) != 0 ){
      index_total <- append(index_total, index_1)
    } else {
      index_total <- index_total
    }
  }
  return(index_total)
}
index_applock_total <- suppressWarnings(keyword.search(applock$applock))
index_privacy_total <- suppressWarnings(keyword.search(privacy$privacy))
index_phone_total <- suppressWarnings(keyword.search(phone$phone))
index_family_total <- suppressWarnings(keyword.search(family$family))
index_scan_total <- suppressWarnings(keyword.search(scan$scan))
index_junk_total <- suppressWarnings(keyword.search(clean$clean))
index_backup_total <- suppressWarnings(keyword.search(backup$backup))

All_CommentData$GP_type[index_family_total] <- "7_Family"
All_CommentData$GP_type[index_phone_total] <- "6_Phone"
All_CommentData$GP_type[index_backup_total] <- "8_Backup"
All_CommentData$GP_type[index_privacy_total] <- "3_Private"
All_CommentData$GP_type[index_junk_total] <- "4_Junk"
All_CommentData$GP_type[index_scan_total] <- "2_Scan"
All_CommentData$GP_type[index_applock_total] <- "1_Applock"
#-------------------------separate different type 2-------------------------#
### text mining
library(tm)
All.Comment.corpus <- Corpus(VectorSource(All_CommentData$Tran_comment),readerControl=list(language="english"))
AllCorpusClean <- tm_map(All.Comment.corpus, tolower)
AllCorpusClean <- tm_map(AllCorpusClean, removeNumbers)
AllCorpusClean <- tm_map(AllCorpusClean, removeWords, stopwords("english"))
AllCorpusClean <- tm_map(AllCorpusClean, removePunctuation)
AllCorpusClean <- tm_map(AllCorpusClean, stripWhitespace)

### perpare training and testing data
#pt <- 0.7
#train.idx <- sample(1:nrow(gp.data), nrow(gp.data)*pt, replace  = FALSE)
#All.training <- All.dtm[train.idx, ]
#All.testing <- All.dtm[-train.idx, ]
# Original data divide to train and test set
#original.data.train <- gp.data[train.idx, ]
#original.data.test <- gp.data[-train.idx, ]
# Corpus data with train and test set 
#All.corpus.train <- AllCorpusClean[train.idx]
#All.corpus.test <- AllCorpusClean[-train.idx]
#table(original.data.train$final_type)

### item's keyword
item.keyword <- c(applock, scan, clean, privacy, backup, phone, family)

### dictionary 
Dictionary.word <- sort(c(applock$applock, privacy$privacy, phone$phone, family$family, scan$scan, 
                          clean$clean, backup$backup))
#Dictionary.word <- findFreqTerms(All.dtm, 3)
All.dict <- suppressWarnings(as.data.frame(inspect(DocumentTermMatrix(AllCorpusClean,
                                                                      list(dictionary = Dictionary.word)))))
### count keyword appear times fcuntion
kewyword.weight <- function(text.data, item.keyword){
  match.idx <- match(names(text.data), item.keyword)
  keyword.match.idx <- which(!is.na(match(names(text.data), item.keyword)))
  weight <- apply(text.data[ ,keyword.match.idx], 1, sum)
  return(weight)
}
item.name <- c("applock", "scan", "clean", "privacy", "backup", "phone", "family")
weight.table <- data.frame()
for(t in 1:length(item.name)){
  weight.table[1:nrow(All.dict), t] <- kewyword.weight(All.dict, item.keyword[[t]])  
}
colnames(weight.table) <- item.name

### check the item 
item.name.fun<- function(index){
  idx.name <- switch(index, "1_Applock", "2_Scan", "4_Junk", "3_Private", "8_Backup", "6_Phone", "7_Family")
  return(idx.name)
}

for(i in 1:nrow(weight.table)){
  if(length(which(weight.table[i, ] > 6)) != 0 ){
    idx <- which(weight.table[i, ] > 6)
    weight.table[i, "item"]<- item.name.fun(idx[1])
  }else if(length(which(weight.table[i, ] > 5)) != 0 ){
    idx <- which(weight.table[i, ] > 5)
    weight.table[i, "item"]<- item.name.fun(idx[1])
  }else if(length(which(weight.table[i, ] > 4)) != 0 ){
    idx <- which(weight.table[i, ] > 4)
    weight.table[i, "item"]<- item.name.fun(idx[1])
  }else if(length(which(weight.table[i, ] > 3)) != 0 ){
    idx <- which(weight.table[i, ] > 3)
    weight.table[i, "item"]<- item.name.fun(idx[1])
  }else if(length(which(weight.table[i, ] > 2)) != 0 ){
    idx <- which(weight.table[i, ] > 2)
    weight.table[i, "item"]<- item.name.fun(idx[1])
  }else if(length(which(weight.table[i, ] > 1)) != 0 ){
    idx <- which(weight.table[i, ] > 1)
    weight.table[i, "item"]<- item.name.fun(idx[1])
  }else{
    weight.table[i, "item"]<- "5_CMS"
  }
}
All_CommentData$GP_type_2 <- weight.table$item

input.data.to.mongo.type <- function(data.list, mongo.name, mongo.collections) {
  if(is.list(data.list)) {
    bson <- mongo.bson.from.list(list(number = 1:length(data.list$name),
                                      name = as.character(data.list$name),
                                      id = as.character(data.list$id),
                                      star = as.character(data.list$star),
                                      language = as.character(data.list$language),
                                      software = as.character(data.list$software),
                                      phone = iconv(as.character(data.list$phone), from = "UTF-8", to = "UTF-8"),
                                      comment_time = as.character(data.list$comment_time),
                                      comment = as.character(data.list$comment),
                                      reply = as.character(data.list$reply),
                                      reply_time = as.character(data.list$reply_time),
                                      Tran_comment = as.character(data.list$Tran_comment),
                                      star_no = as.character(data.list$star_no),
                                      type = as.character(data.list$type),
                                      GP_type = as.character(data.list$GP_type),
                                      GP_type_2 = as.character(data.list$GP_type_2)))
    mongo.insert(mongo.name, mongo.collections, bson)
  }else{
    error <- "GP data's class is not 'list' in mongodb "
    sender <- "raymond.liao@ileopard.com" # Replace with a valid address
    recipients <- c("raymond.liao@ileopard.com") # Replace with one or more valid addresses
    send.mail(from = sender,to = recipients,subject="MongoDB Server Error from AWS(Mongo input data code)",body =error,
              smtp = list(host.name = "aspmx.l.google.com", port = 25))
  }
}
GP.data.list <- as.list(All_CommentData)
db <- "GPDailyDataType"
namespace <- paste(db, date, sep = ".")
result.mongo.type <- input.data.to.mongo.type(GP.data.list, mongo, namespace)
print(paste(date, result.mongo.type, sep = ":"))

### import sent mail function
source("D:/R_code/R_exe/MainFunction(Sent_mail_gp).R")

tryCatch({  
  ### date time check 
  if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "00:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "06:00:00", sep = " ")){
    # zone one
    ### show how many document in database and create a data table 
    #namespace <- paste(db, Sys.Date()-1, sep = ".")
    #mongo.count(mongo, namespace)
    ### Find records in a collection
    #collection.record <- mongo.find.all(mongo, namespace, mongo.bson.empty())
    #names(collection.record[[1]])
    #GPDataFormMongo <- gpdataencoding(collection.record[[4]])
    GPDataFormMongo <- All_CommentData
    date <- Sys.Date()-1
    write.xlsx2(GPDataFormMongo[which(GPDataFormMongo$type == "cons"), ], 
                sprintf("D:/output/Data_by_date/data_%s.xlsx", date), append = TRUE, row.names = FALSE, sheetName = "Part4_cons")
    write.xlsx2(GPDataFormMongo[-which(GPDataFormMongo$type == "cons"), ], 
                sprintf("D:/output/Data_by_date/data_%s.xlsx", date), append = TRUE, row.names = FALSE, sheetName = "Part4_others")
    sentmail(sprintf("D:/output/Data_by_date/data_%s.xlsx", date), date, "part4", "18", "24")
    
  }else if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "06:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "12:00:00", sep = " ")){
    # zone two 
    ### show how many document in database and create a data table 
    #namespace <- paste(db, Sys.Date(), sep = ".")
    #mongo.count(mongo, namespace)
    #collection.record <- mongo.find.all(mongo, namespace, mongo.bson.empty())
    #GPDataFormMongo <- gpdataencoding(collection.record[[1]])
    GPDataFormMongo <- All_CommentData
    date <- Sys.Date()
    write.xlsx2(GPDataFormMongo[which(GPDataFormMongo$type == "cons"), ], 
                sprintf("D:/output/Data_by_date/data_%s.xlsx", date), append = TRUE, row.names = FALSE, sheetName = "Part1_cons")
    write.xlsx2(GPDataFormMongo[-which(GPDataFormMongo$type == "cons"), ], 
                sprintf("D:/output/Data_by_date/data_%s.xlsx", date), append = TRUE, row.names = FALSE, sheetName = "Part1_others")
    sentmail(sprintf("D:/output/Data_by_date/data_%s.xlsx", date), date, "part1", "00", "06")
  
    }else if(format(Sys.time(), "%Y-%m-%d %H:%M:%S") > paste(Sys.Date(), "12:00:00", sep = " ") & format(Sys.time(), "%Y-%m-%d %H:%M:%S") <= paste(Sys.Date(), "18:00:00", sep = " ")){
    # zone three
    ### show how many document in database and create a data table 
    #namespace <- paste(db, Sys.Date(), sep = ".")
    #mongo.count(mongo, namespace)
    #collection.record <- mongo.find.all(mongo, namespace, mongo.bson.empty())
    #GPDataFormMongo <- gpdataencoding(collection.record[[2]])
    GPDataFormMongo <- All_CommentData
    date <- Sys.Date()
    write.xlsx2(GPDataFormMongo[which(GPDataFormMongo$type == "cons"), ], 
                sprintf("D:/output/Data_by_date/data_%s.xlsx", date), append = TRUE, row.names = FALSE, sheetName = "Part2_cons")
    write.xlsx2(GPDataFormMongo[-which(GPDataFormMongo$type == "cons"), ], 
                sprintf("D:/output/Data_by_date/data_%s.xlsx", date), append = TRUE, row.names = FALSE, sheetName = "Part2_others")
    sentmail(sprintf("D:/output/Data_by_date/data_%s.xlsx", date), date, "part2", "06", "12")
  
    }else{
    # zone four 
    ### show how many document in database and create a data table 
    #namespace <- paste(db, Sys.Date(), sep = ".")
    #mongo.count(mongo, namespace)
    #collection.record <- mongo.find.all(mongo, namespace, mongo.bson.empty())
    #GPDataFormMongo <- gpdataencoding(collection.record[[3]])
    GPDataFormMongo <- All_CommentData
    date <- Sys.Date()
    write.xlsx2(GPDataFormMongo[which(GPDataFormMongo$type == "cons"), ], 
                sprintf("D:/output/Data_by_date/data_%s.xlsx", date), append = TRUE, row.names = FALSE, sheetName = "Part3_cons")
    write.xlsx2(GPDataFormMongo[-which(GPDataFormMongo$type == "cons"), ], 
                sprintf("D:/output/Data_by_date/data_%s.xlsx", date), append = TRUE, row.names = FALSE, sheetName = "Part3_others")
    sentmail(sprintf("D:/output/Data_by_date/data_%s.xlsx", date), date, "part3", "12", "18")
  }
},error = function(e){
  errormassage <- e
  sender <- "raymond.liao@ileopard.com" # Replace with a valid address
  recipients <- c("raymond.liao@ileopard.com") # Replace with one or more valid addresses
  send.mail(from = sender,to = recipients,subject=sprintf("%s_error from MainFunction(SEND_GP_DATA)", date),body = errormassage,
            smtp = list(host.name = "aspmx.l.google.com", port = 25))
}) 
Sys.setlocale(category='LC_ALL', locale='')      
