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

phasedata_pca <- lapply(unique(mobility_US$region), function(x) {
  dd0 <- us_death_fit0 %>% filter(region==x)
  dd1 <- us_death_fit_all %>% filter(region==x)
  
  dd2 <- mobility_US %>% 
    filter(region==x, sub_region_2=="")
  
  dd3 <- dd2 %>%
    arrange(date) %>%
    dplyr::select(retail_and_recreation_percent_change_from_baseline, grocery_and_pharmacy_percent_change_from_baseline,
                  parks_percent_change_from_baseline, transit_stations_percent_change_from_baseline,
                  workplaces_percent_change_from_baseline, residential_percent_change_from_baseline)
  
  pc <- prcomp(dd3)
  
  print(summary(pc)[[6]])
  
  pp <- data.frame(
    day=seq(min(dd1$day), max(dd1$day), by=0.01)
  )
  
  fitdata1 <- data.frame(
    day=sort(dd2$day),
    resp=pc$x[,1]
  )
  
  fitdata2 <- data.frame(
    day=sort(dd2$day),
    resp=pc$x[,2]
  )
  
  lfit1 <- loess(resp~day, data=fitdata1)
  lfit2 <- loess(resp~day, data=fitdata2)
  
  pred1 <- unname(predict(lfit1, newdata=pp))
  pred2 <- unname(predict(lfit2, newdata=pp))
  
  data.frame(
    day=dd1$day,
    deaths=(dd1$pred),
    pc1=pred1,
    pc2=pred2,
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
  geom_path(data=phasedata_pca2, aes(pc1, deaths, group=region),
            col="gray", alpha=0.5) +
  geom_path(aes(pc1, deaths, group=region, col=metric, lty=region),
            arrow = arrow(length = unit(0.1, "inches"), type = "closed")) +
  geom_dl(data=x_end, aes(pc1, deaths, label=region, col=metric), method=list("last.bumpup", hjust=-0.2, vjust=1.2)) +
  scale_x_continuous("Mobility principal component 1") +
  scale_y_log10("Smoothed daily number of reported deaths") +
  scale_color_gradientn("Symmetry\ncoefficient", colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
  scale_fill_gradientn("Symmetry\ncoefficient", colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
  scale_linetype_manual(values=c(1:9, 1:9), guide=FALSE) +
  theme(
    panel.grid = element_blank(),
    strip.background = element_blank()
  )

g2 <- ggplot(phasedata_pca3) +
  geom_path(data=phasedata_pca2, aes(pc2, deaths, group=region),
            col="gray", alpha=0.5) +
  geom_path(aes(pc2, deaths, group=region, col=metric, lty=region),
            arrow = arrow(length = unit(0.1, "inches"), type = "closed")) +
  geom_dl(data=x_end, aes(pc2, deaths, label=region, col=metric), method=list("last.bumpup", hjust=-0.2, vjust=1.2)) +
  scale_x_continuous("Mobility principal component 2") +
  scale_y_log10("Smoothed daily number of reported deaths") +
  scale_color_gradientn("Symmetry\ncoefficient", colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
  scale_fill_gradientn("Symmetry\ncoefficient", colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
  scale_linetype_manual(values=c(1:9, 1:9), guide=FALSE) +
  theme(
    panel.grid = element_blank(),
    strip.background = element_blank()
  )

gtot <- ggarrange(g1, g2, nrow=1, draw=FALSE)

ggsave("national_deaths_metric_phase_pca.pdf", gtot, width=12, height=6)
