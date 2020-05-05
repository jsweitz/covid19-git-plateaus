library(dplyr)
library(ggplot2); theme_set(theme_bw())
library(tikzDevice)

us_death <- read.csv("daily.csv") %>%
  mutate(
    date=sub("(.{4})(.*)", "\\1-\\2", date),
    date=sub("(.{7})(.*)", "\\1-\\2", date),
    date=as.Date(date),
    deathIncrease=ifelse(deathIncrease<=0, NA, deathIncrease)
  ) %>%
  filter(state %in% c("CA", "WA", "NY", "GA", "LA")) %>%
  rename(
    region=state,
    date=date,
    deaths=deathIncrease
  )

national_deaths <- read.csv("national_deaths.csv") %>%
  filter(countriesAndTerritories %in% c("United_States_of_America", "United_Kingdom", "Italy", "Iran", "China")) %>%
  mutate(
    dateRep=as.Date(dateRep, format="%d/%m/%Y"),
    countriesAndTerritories=factor(countriesAndTerritories, 
                                   labels=c("China", "Iran", "Italy", "UK", "USA")),
    deaths=ifelse(deaths <= 0, NA, deaths)
  ) %>%
  rename(
    region=countriesAndTerritories,
    date=dateRep
  )

deathall <- bind_rows(national_deaths, us_death) %>%
  mutate(
    region=factor(region, levels=c("China", "Iran", "Italy", "UK", "USA", 
                                   "CA", "WA", "NY", "GA", "LA"))
  ) %>%
  group_by(region) %>%
  filter(
    date >= min(date[which(deaths > 0 & !is.na(deaths))])
  )

deathmin <- deathall %>%
  group_by(region) %>%
  filter(date==min(date))

## a bit hacky...
g1 <- ggplot(deathall) +
  geom_text(data=deathmin, aes(x=date, y=Inf, label=region), hjust=-0.2, vjust=1.3) +
  geom_point(aes(date, deaths)) +
  geom_line(aes(date, deaths)) +
  geom_smooth(aes(date, deaths), se=FALSE, col="red", lwd=1.5) +
  scale_x_date(expand=c(0, 0), breaks=c(as.Date("2020-02-01"), as.Date("2020-03-01"), as.Date("2020-04-01"), as.Date("2020-05-01")),
               labels=c("Feb", "Mar", "Apr", "May")) +
  scale_y_log10("Daily number of reported deaths",
                sec.axis=sec_axis(~., "Countries\\quad\\quad\\quad\\quad\\quad\\quad US States")) +
  facet_wrap(~region, scale="free", nrow=2) +
  theme(
    panel.grid = element_blank(),
    axis.title.x = element_blank(),
    strip.background = element_blank(),
    strip.placement = "none",
    strip.text = element_blank(),
    axis.text.y.right = element_blank(),
    axis.ticks.y.right = element_blank()
  )

tikz(file = "national_death.tex", width = 9, height = 3, standAlone = T)
plot(g1)
dev.off()
tools::texi2dvi('national_death.tex', pdf = T, clean = T)
