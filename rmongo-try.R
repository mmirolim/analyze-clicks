library(RMongo)
library(dplyr)
library(parsedate)

today <- as.Date('2015-11-28', format = '%Y-%m-%d')

db <- mongoDbConnect("ltvdb")

output <- dbGetQueryForKeys(db, 'events', '{"regdate": {"$lte":1446249600}, "eventdate": {"$gte": {"$date": "2015-10-31T24:59:37.275Z"}}}', '{"_id":0, "profileid":1, "eventdate":1}', skip=0, limit = 100000)

data <- as.data.table(output)
data$eventdate <- format(parse_date(data$eventdate), "%Y-%m-%d")

clicksByDay <- tally(group_by(data, eventdate), sort = FALSE)

barplot(clicksByDay$n, names.arg = clicksByDay$eventdate)

