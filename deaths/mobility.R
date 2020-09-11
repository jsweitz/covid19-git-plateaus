source("national_deaths_metric.R")

us_death_fit_all <- lapply(split(us_death_filter, us_death_filter$region), function(x) {
  print(x$region[1])
  pp <- data.frame(
    day=seq(min(x$day), max(x$day), by=0.01)
  )
  
  lfit <- loess(log(deaths)~day, data=x)
  
  pred <- unname(exp(predict(lfit, newdata=pp)))
  
  data.frame(
    region=x$region[1],
    day=seq(min(x$day), max(x$day), by=0.01),
    pred=pred
  )
}) %>%
  bind_rows

mobility <- read.csv("Global_Mobility_Report.csv")

mobility_US <- mobility %>%
  filter(
    country_region=="United States",
    sub_region_1 %in% state.name[match(unique(us_death_fit0$region), state.abb)]
  ) %>%
  mutate(
    region=state.abb[match(sub_region_1, state.name)],
    day=yday(date)
  )

dd_mobility <- mobility_US %>%
  filter(sub_region_2=="") %>%
  arrange(region, date) %>%
  dplyr::select(region, date, retail_and_recreation_percent_change_from_baseline, grocery_and_pharmacy_percent_change_from_baseline,
                parks_percent_change_from_baseline, transit_stations_percent_change_from_baseline,
                workplaces_percent_change_from_baseline, residential_percent_change_from_baseline)

dd_mobility2 <- dd_mobility %>%
  tidyr::gather(key, value, -region, -date) %>%
  mutate(
    date=as.Date(as.character(date)),
    key=gsub("_percent_change_from_baseline", "", key),
    key=gsub("_", " ", key)
  )

g1 <- ggplot(dd_mobility2) +
  geom_hline(yintercept=0, col="gray", lty=2) +
  geom_line(aes(date, value, col=key)) +
  geom_point(aes(date, value, col=key, shape=key), size=0.2) +
  scale_x_date("Month", expand=c(0, 0)) +
  scale_y_continuous("Percent change from baseline") +
  scale_color_viridis_d() +
  facet_wrap(~region, scale="free") +
  theme(
    panel.grid = element_blank(),
    legend.position = "top",
    legend.title = element_blank()
  )

tikz(file = "mobility.tex", width = 8, height = 8, standAlone = T)
plot(g1)
dev.off()
tools::texi2dvi('mobility.tex', pdf = T, clean = T)
