library(dplyr)
library(ggplot2); theme_set(theme_bw())
library(lubridate)
library(directlabels)
library(egg)
library(tikzDevice)

cutoff <- 0.1

nboot <- 1000

us_death <- read.csv("daily.csv") %>%
  mutate(
    date=sub("(.{4})(.*)", "\\1-\\2", date),
    date=sub("(.{7})(.*)", "\\1-\\2", date),
    date=as.Date(date),
    deathIncrease=ifelse(deathIncrease<=0, 0, deathIncrease)
  ) %>%
  rename(
    region=state,
    date=date,
    deaths=deathIncrease
  ) %>%
  filter(region %in% state.abb, deaths > 0) %>%
  mutate(
    region=as.character(region),
    day=yday(date)
  )

us_death_fit <- lapply(split(us_death, us_death$region), function(x) {
  print(x$region[1])
  pp <- data.frame(
    day=seq(min(x$day), max(x$day), length.out=1000)
  )
  
  lfit <- loess(log(deaths)~day, data=x)
  
  pred <- unname(exp(predict(lfit, newdata=pp)))
  
  D_P <- max(pred, na.rm=TRUE)
  
  t_P <- pp$day[which(pred==D_P)]
  
  ww <- tail(which(pred <= cutoff * D_P & pp$day < t_P), 1)[1]
  
  tau_R <- t_P - pp$day[ww]
  
  D_r <- pred[which(pp$day>=(t_P + tau_R))[1]]
  D_l <- pred[ww]
  
  metric <- D_l/D_r
  
  data.frame(
    metric=metric,
    region=x$region[1],
    t_P=t_P,
    D_l=D_l,
    D_r=D_r,
    D_P=D_P,
    t_1=t_P-tau_R,
    t_2=t_P+tau_R
  )
}) %>%
  bind_rows

us_death_fit2 <- us_death_fit %>%
  filter(D_P > 10, !is.na(metric)) %>%
  arrange(metric)

us_death_filter <- us_death %>%
  filter(region %in% us_death_fit2$region)

us_death_fit0 <- lapply(split(us_death_filter, us_death_filter$region), function(x) {
  print(x$region[1])
  pp <- data.frame(
    day=seq(min(x$day), max(x$day), by=0.01)
  )
  
  lfit <- loess(log(deaths)~day, data=x)
  
  pred <- unname(exp(predict(lfit, newdata=pp)))
  
  D_P <- max(pred, na.rm=TRUE)
  
  t_P <- pp$day[which(pred==D_P)]
  
  ww <- tail(which(pred <= cutoff * D_P & pp$day < t_P), 1)[1]
  
  tau_R <- t_P - pp$day[ww]
  
  D_r <- pred[which(pp$day>=(t_P + tau_R))[1]]
  D_l <- pred[ww]
  
  metric <- D_l/D_r
  
  day2 <- seq(pp$day[ww], pp$day[which(pp$day>=(t_P + tau_R))[1]], length.out=1000)
  
  pp2 <- data.frame(
    day=day2
  )
  
  pred2 <- unname(exp(predict(lfit, newdata=pp2)))
  
  data.frame(
    region=x$region[1],
    day=day2,
    pred=pred2
  )
}) %>%
  bind_rows
