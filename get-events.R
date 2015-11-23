library(rmongodb)
require(data.table)
library(plyr)

m <- mongo.create(db = "ltvdb")
# collection
ec <- "ltvdb.events"
mongo.is.connected(m)
# get all events for audience registered before oct 31 2015
qjson <- '{"regdate":{"$lte":1446249600}}'
# return only regdate, eventdate, profileid fields
fldjson <- '{"_id":false, "regdate":true,"eventdate":true,"profileid":true}'
query <- mongo.bson.from.JSON(qjson)
fldbson <- mongo.bson.from.JSON(fldjson)
cursor <- mongo.find(m, ec, query, fields = fldbson, limit = 40000L)
# prepare data frame
events <- data.frame("eventdate" = as.Date(as.character(), format = "%Y-%m-%d"), "profileid" = integer(), "regdate" = integer(), stringsAsFactors = FALSE)
while (mongo.cursor.next(cursor)) {
  value <- mongo.cursor.value(cursor)
  list <- mongo.bson.to.list(value)
  events[nrow(events) + 1, ] <- list  
   #str(list)
}
#print(events)
# convert events to date table
events <- as.data.table(events)
# group and count clicks by date
data <- count(events, "eventdate")
days <- data$eventdate
freqs <- data$freq
barplot(freqs, names.arg = days)
clicksByProf <- count(events, "profileid")
trans <- count(clicksByProf, "freq")
barplot(trans$freq.1, names.arg = trans$freq)

