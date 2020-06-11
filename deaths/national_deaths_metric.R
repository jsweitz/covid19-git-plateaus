library(dplyr)
library(ggplot2); theme_set(theme_bw())
library(egg)
library(lubridate)

cutoff <- seq(0.3, 0.7, by=0.01)

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
  filter(region %in% national_deaths_max$region) %>%
  mutate(
    region=as.character(region)
  )

national_deaths_metric <- lapply(split(national_deaths_loess_fit2, national_deaths_loess_fit2$region), function(x) {
  lapply(cutoff, function(cc) {
    x2 <- arrange(x, day)
    
    D_P <- max(x2$fit, na.rm=TRUE)
    
    t_P <- x2$day[which(x2$fit==D_P)]
    
    tau_R <- t_P - x2$day[which(x2$fit >= cc * D_P)[1]]
    
    D_F <- x2$fit[which(x2$day>(t_P + tau_R))[1]]
    
    metric <- (D_P - D_F)/(D_P - x2$fit[x2$day==(t_P - tau_R)])
    
    if (length(metric) == 0) {
       metric <- NA
    }
    
    data.frame(
      region=x$region[1],
      metric=metric,
      cutoff=cc
    )
    
  }) %>%
    bind_rows
}) %>%
  bind_rows()

national_deaths_metric_filter <- national_deaths_metric %>%
  filter(!is.na(metric)) %>%
  group_by(region) %>%
  summarize(
    min=min(cutoff),
    max=max(cutoff)
  ) %>%
  filter(
    min==0.3, max==0.7
  )

national_deaths_metric2 <- national_deaths_metric %>%
  filter(region %in% national_deaths_metric_filter$region,
         region %in% state.abb) %>%
  group_by(region) %>%
  summarize(
    est=metric[cutoff==0.5],
    lwr=min(metric),
    upr=max(metric)
  ) %>%
  arrange(est) %>%
  mutate(
    region=factor(region, levels=region)
  )
deathfilter <- deathall %>%
  filter(region %in% c("MN", "NY", "IN")) %>%
  ungroup %>%
  mutate(
    day=yday(date)
  ) %>%
  mutate(
    region=factor(region, levels=c("IN", "NY", "MN"))
  )

national_deaths_loess_filter <- national_deaths_loess_fit %>%
  filter(region %in% c("MN", "NY", "IN")) %>%
  merge(deathfilter) %>%
  mutate(
    region=factor(region, levels=c("IN", "NY", "MN"))
  )

deathmin <- national_deaths_loess_filter %>%
  group_by(region) %>%
  filter(date==min(date))

g1 <- ggplot(deathfilter) +
  geom_text(data=deathmin, aes(x=date, y=Inf, label=region), hjust=-0.2, vjust=1.3) +
  geom_point(aes(date, deaths2)) +
  geom_line(aes(date, deaths2)) +
  geom_line(data=national_deaths_loess_filter, aes(date, fit), col="blue", lwd=1) +
  scale_y_log10("Daily number of reported deaths") +
  facet_wrap(~region, ncol=1, scale="free") +
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

g2 <- ggplot(national_deaths_metric2) +
  geom_point(aes(est, region)) +
  geom_errorbarh(aes(xmin=lwr, xmax=upr, y=region), height=0) +
  scale_x_continuous("Symmetry coefficient", limits=c(0, 1)) +
  scale_y_discrete("States")

gtot <- ggarrange(g1, g2, nrow=1, draw=FALSE)

ggsave("national_death_metric.pdf", gtot, width=8, height=6)
