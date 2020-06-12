library(dplyr)
library(ggplot2); theme_set(theme_bw())
library(lubridate)
library(directlabels)
library(egg)

cutoff <- 0.1

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
  filter(region %in% state.abb)

national_deaths <- read.csv("national_deaths.csv") %>%
  filter(countriesAndTerritories %in% c("United_States_of_America", "United_Kingdom", "Italy", "Iran", "China")) %>%
  mutate(
    dateRep=as.Date(dateRep, format="%d/%m/%Y"),
    countriesAndTerritories=factor(countriesAndTerritories, 
                                   levels=c("China", "Iran", "Italy", "United_Kingdom", "United_States_of_America"),
                                   labels=c("China", "Iran", "Italy", "UK", "USA")),
    deaths=ifelse(deaths <= 0, 0, deaths)
  ) %>%
  rename(
    region=countriesAndTerritories,
    date=dateRep
  )

deathall <- bind_rows(national_deaths, us_death) %>%
  mutate(
    region=factor(region, levels=c("China", "Iran", "Italy", "UK", "USA", 
                                   as.character(unique(us_death$region)))),
    type=ifelse(region %in% c("China", "Iran", "Italy", "UK", "USA"), "1", "2"),
    deaths2=ifelse(deaths==0, NA, deaths) ## for plotting
  ) %>%
  group_by(region) %>%
  filter(
    date >= min(date[which(deaths > 0 & !is.na(deaths))])
  )

deathmin <- deathall %>%
  group_by(region) %>%
  filter(date==min(date))

national_deaths_loess_fit <- lapply(split(deathall, deathall$region), function(x) {
  y <- x %>%
    arrange(date) %>%
    mutate(
      day=yday(date)
    )
  
  y2 <- y %>%
    filter(
      deaths != 0
    )
  
  lfit <- loess(log(deaths)~day, data=y2)
  
  dd <- data.frame(
    day=seq(min(y2$day), max(y2$day), by=0.01)
  )
  
  pred <- exp(predict(lfit, newdata=dd))
  
  data.frame(
    day=dd,
    fit=pred,
    region=y$region[1]
  )
}) %>%
  bind_rows %>%
  ungroup %>%
  mutate(
    region=factor(region, levels=c("China", "Iran", "Italy", "UK", "USA", 
                                   as.character(unique(us_death$region))))
  )

national_deaths_max <- national_deaths_loess_fit %>%
  group_by(region) %>%
  summarize(
    max=max(fit, na.rm=TRUE)
  ) %>%
  filter(max > 10)

national_deaths_loess_fit2 <- national_deaths_loess_fit %>%
  filter(region %in% national_deaths_max$region,
         region %in% state.abb) %>%
  mutate(
    region=as.character(region)
  )

national_deaths_metric <- lapply(split(national_deaths_loess_fit2, national_deaths_loess_fit2$region), function(x) {
  x2 <- arrange(x, day)
  
  D_P <- max(x2$fit, na.rm=TRUE)
  
  t_P <- x2$day[which(x2$fit==D_P)]
  
  tau_R <- t_P - x2$day[which(x2$fit >= cutoff * D_P)[1]]
  
  D_F <- x2$fit[which(x2$day>=(t_P + tau_R))[1]]
  
  ## == doesn't always work
  ## due to numerical issues
  metric <- (x2$fit[which.min((x2$day-round(t_P - tau_R, 2))^2)])/(D_F)
  
  data.frame(
    region=x$region[1],
    metric=metric,
    cutoff=cutoff,
    D_P=D_P,
    t_P=t_P,
    t_1=t_P-tau_R,
    t_2=t_P+tau_R
  )
})%>%
  bind_rows()

national_deaths_metric_filter <- national_deaths_metric %>%
  filter(!is.na(metric))

national_deaths_metric2 <- national_deaths_metric %>%
  filter(region %in% national_deaths_metric_filter$region) %>%
  arrange(metric) %>%
  mutate(
    region=factor(region, levels=region)
  )

national_deaths_loess_fit_filter <- national_deaths_loess_fit %>%
  filter(region %in% national_deaths_metric_filter$region) %>%
  merge(national_deaths_metric) %>%
  group_by(region) %>%
  filter(day >= t_1, day <= t_2) %>%
  mutate(
    fit2=(fit-min(fit))/(max(fit)-min(fit)),
    day=(day-min(day))/(max(day)-min(day))
  )%>%
  ungroup %>%
  mutate(
    region=factor(region, levels=levels(national_deaths_metric2$region))
  )

g1 <- ggplot(national_deaths_loess_fit_filter) +
  geom_line(aes(day, fit2, lty=region, col=region)) +
  scale_y_continuous("Daily number of reported deaths") +
  scale_color_manual(values=rep(1, 18)) +
  scale_linetype_manual(values=c(1:9, 1:9)) +
  theme(
    panel.grid = element_blank(),
    axis.title.x = element_blank(),
    strip.background = element_blank(),
    strip.placement = "none",
    strip.text = element_blank(),
    axis.text.y.right = element_blank(),
    axis.ticks.y.right = element_blank(),
    legend.position="none"
  )

g1a <- direct.label(g1)

g2 <- ggplot(national_deaths_metric2) +
  geom_point(aes(metric, region)) +
  # geom_errorbarh(aes(xmin=lwr, xmax=upr, y=region), height=0) +
  scale_x_continuous("Symmetry coefficient") +
  scale_y_discrete("States", limits = rev(levels(national_deaths_metric2$region))) +
  theme(
    legend.position = "none"
  )

gtot <- ggarrange(g1a, g2, nrow=1)
 
ggsave("national_death_metric2.pdf", gtot, width=12, height=6)
