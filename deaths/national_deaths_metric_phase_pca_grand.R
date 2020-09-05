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
                transit_stations_percent_change_from_baseline,
                workplaces_percent_change_from_baseline, residential_percent_change_from_baseline)

dd_mobility2 <- lapply(split(dd_mobility, dd_mobility$region), function(x) {
  dd <- as.data.frame(lapply(x[,-c(1:2)], zoo::rollmean, k=7, na.pad=TRUE))
  
  dd$region <- x$region
  dd$date <- x$date
  dd
}) %>%
  bind_rows

pc <- prcomp(dd_mobility2[complete.cases(dd_mobility2),-(6:7)], scale.=TRUE)

pcdata <- dd_mobility2[complete.cases(dd_mobility2),6:7]

pcdata$pc1 <- pc$x[,1]

phasedata_pca <- lapply(unique(mobility_US$region), function(x) {
  dd0 <- us_death_fit0 %>% filter(region==x)
  dd1 <- us_death_fit_all %>% filter(region==x)
  
  dd2 <- pcdata %>% 
    filter(region==x) %>%
    arrange(date)
  
  pp <- data.frame(
    day=seq(min(dd1$day), max(dd1$day), by=0.01)
  )
  
  fitdata1 <- data.frame(
    day=yday(dd2$date),
    resp=dd2$pc1
  )
  
  lfit1 <- loess(resp~day, data=fitdata1)
  
  pred1 <- unname(predict(lfit1, newdata=pp))
  
  data.frame(
    day=dd1$day,
    deaths=(dd1$pred),
    pc1=pred1,
    region=dd1$region,
    metric=dd0$metric[1],
    dmin=min(dd0$day),
    dmax=max(dd0$day)
  )  
}) %>%
  bind_rows

phasedata_pca2 <- phasedata_pca %>%
  group_by(region) %>%
  filter(
    day <= dmax
  )

phasedata_pca3 <- phasedata_pca %>%
  group_by(region) %>%
  filter(
    day <= dmax, day >= dmin
  )

x_end <- phasedata_pca3 %>%
  group_by(region) %>%
  filter(day==max(day))

g1 <- ggplot(phasedata_pca3) +
  geom_path(data=phasedata_pca2, aes(-pc1, deaths, group=region),
            col="gray", alpha=0.5) +
  geom_path(aes(-pc1, deaths, group=region, col=metric, lty=region),
            arrow = arrow(length = unit(0.1, "inches"), type = "closed")) +
  geom_dl(data=x_end, aes(-pc1, deaths, label=region, col=metric), method=list("last.bumpup", hjust=-0.1, vjust=1.2)) +
  scale_x_continuous("Smoothed mobility principal component 1") +
  scale_y_log10("Smoothed daily number of reported deaths") +
  scale_color_gradientn("Symmetry\ncoefficient", colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
  scale_fill_gradientn("Symmetry\ncoefficient", colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
  scale_linetype_manual(values=c(1:9, 1:9), guide=FALSE) +
  theme(
    panel.grid = element_blank(),
    strip.background = element_blank()
  )

ggsave("national_deaths_metric_phase_pca_grand.pdf", g1, width=8, height=8)
