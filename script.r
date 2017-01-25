library(tidyverse)
library(reshape2)
data <- read_csv("data.csv", col_types = cols(
                                                date = col_date(),
                                                total = col_integer(),
                                                public = col_double(),
                                                private = col_double(),
                                                direct = col_double(),
                                                files = col_integer()
                                                )
)
data <- arrange(data, date)
data <- mutate(data, public_msgs = round(public * total), private_msgs = round(private * total), direct_msgs = round(direct * total))

# Total messages by type
ggplot(data, aes(x = date)) + geom_point(aes(y = public_msgs, colour = 'public_msgs')) + geom_point(aes(y = direct_msgs, colour = 'direct_msgs')) + geom_point(aes(y = private_msgs, colour = 'private_msgs')) + labs(x = "date", y = "messages")

ggplot(data) + geom_point(aes(y = total, x = date)) + labs(title = "Messages Sent By Week", x = "Date", y = "Messages")

ggplot(data) + geom_point(aes(y = users, x = date)) + labs(title = "Total Users", x = "Date", y = "Users")

ggplot(data) + geom_point(aes(y = files, x = date)) + labs(title = "Files Uploaded By Week", x = "Date", y = "Files")


# stacked plot of message types
melted <- select(data, date, public_msgs, private_msgs, direct_msgs) %>% melt(id.vars = "date")
ggplot(melted, aes(x=date,y=value)) + geom_area(aes(fill=variable), position = "fill") + labs(title = "Message Type Percentage By Week", x = "Date", y = "Percentage") + scale_fill_manual(values=c("#888888", "#396682", "#EB5043"))
