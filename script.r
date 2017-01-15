library(tidyverse)
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

# Total messages by type
ggplot(data, aes(x = date)) + geom_point(aes(y = public_msgs, colour = 'public_msgs')) + geom_point(aes(y = direct_msgs, colour = 'direct_msgs')) + geom_point(aes(y = private_msgs, colour = 'private_msgs')) + labs(x = "date", y = "messages")

# stacked plot of message types
melted <- select(data, date, public_msgs, private_msgs, direct_msgs) %>% melt(id.vars = "date")
ggplot(melted, aes(x=date,y=value)) + geom_area(aes(fill=variable), position = "fill")
