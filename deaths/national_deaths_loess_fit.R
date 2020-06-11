library(dplyr)
library(lubridate)

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
  
  y$fit <- exp(predict(lfit, newdata=y))
  y
}) %>%
  bind_rows %>%
  ungroup %>%
  mutate(
    region=factor(region, levels=c("China", "Iran", "Italy", "UK", "USA", 
                                   as.character(unique(us_death$region))))
  )

save("national_deaths_loess_fit", file="national_deaths_loess_fit.rda")
