#############################################################################
####                            Sent mail                                ####
#############################################################################
sentmail <- function(fileaddress, Date, partnumber, start_time, end_time){
  library(mailR)
  library(xtable)
  sender <- "raymond.liao@ileopard.com" # Replace with a valid address
  recipients <- c("raymond.liao@ileopard.com", "pandora.syu@ileopard.com", "greg.lin@ileopard.com")
                  #"nelly.chang@ileopard.com", "daniel.huang@ileopard.com", "annie.lin@ileopard.com") # Replace with one or more valid addresses
  send.mail(from = sender, 
            to = recipients,
            subject=sprintf("%s_The user feedback from GP platform %s from %s to %s o'clock",Date, partnumber, start_time, end_time),
            body="The GP platform summary talbe and Problem document file at attached.
            Please check on below. If you have any question, don't hesitate to tell me.",
            html=TRUE,
            smtp = list(host.name = "aspmx.l.google.com", port=25, user.name=sender, passord="roymond20*"),
            attach.files = fileaddress                   
  )
  
  send.mail(from = sender, 
            to = c("zhongjieyun@cmcm.com", "yipan@cmcm.com", "jinhuixia@cmcm.com", "yuanshaolong@cmcm.com", "zhangjun1@cmcm.com",
                   "wangzhongqiu@cmcm.com", "chenliqing@cmcm.com", "zhaojingling@cmcm.com" ,"luocaihong@cmcm.com",
                   "chenwensheng@cmcm.com", "wubin@cmcm.com", "chenliyun@cmcm.com", "zhaoyu@cmcm.com"),
            subject=sprintf("%s_The users feedback from GP platform ",Date),
            body="The GP platform summary talbe and Problem document file at attached.
            Please check on below. If you have any question, don't hesitate to tell me.",
            smtp = list(host.name = "aspmx.l.google.com", port = 25,user.name = "raymond.liao", passwd = "roymond20*"),
            html = TRUE,
            attach.files = fileaddress
  )
  #person_mail <- c("pengzhongyi@conew.com", "yangyinmeng@ijinshan.com")
  #for(p in 1:2){
  #  send.mail(from = sender, 
  #            to = person_mail[p],
  #            subject = sprintf("%s_The users feedback from Mail box's ",Date),
  #            body = "The Mail box's summary talbe and Problem document file at attached.
  #            Please check on below. If you have any question, don't hesitate to tell me.",
  #            smtp = list(host.name = "aspmx.l.google.com", port = 25,user.name = "raymond.liao", passwd = "roymond20*"),
  #            html = TRUE,
  #            attach.files = fileaddress
  #  )
  #}
}