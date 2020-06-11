library(dplyr)
library(ggplot2); theme_set(theme_bw())

dat <- (read.csv(input_files[[1]])
	%>% mutate(
		date=sub("(.{4})(.*)", "\\1-\\2", date)
		, date=sub("(.{7})(.*)", "\\1-\\2", date)
		, date=as.Date(date)
	) %>% transmute(
		state=state
		, deaths=ifelse(deathIncrease<=0, NA, deathIncrease)
		, day = as.numeric(date-min(date))
	)
)

curr <- (filter(dat, state=="IN")
	%>% select(-state)
)
summary(curr)

print(ggplot(curr)
	+ aes(x=day, y=deaths)
	+ geom_line()
	+ scale_y_log10()
)
