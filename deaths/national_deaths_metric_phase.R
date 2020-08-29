source("national_deaths_metric.R")

firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

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

mobility_type <- c("retail_and_recreation_percent_change_from_baseline", 
                   "grocery_and_pharmacy_percent_change_from_baseline", "parks_percent_change_from_baseline", 
                   "transit_stations_percent_change_from_baseline", "workplaces_percent_change_from_baseline", 
                   "residential_percent_change_from_baseline")

phasedata <- lapply(unique(us_death_fit0$region), function(x) {
  lapply(mobility_type, function(y) {
    dd1 <- us_death_fit0 %>% filter(region==x)
    
    dd2 <- mobility_US %>% 
      filter(region==x, sub_region_2=="") %>%
      select(y, day) %>%
      setNames(c("resp", "day"))
    
    pp <- data.frame(
      day=seq(min(dd1$day), max(dd1$day), by=0.01)
    )
    
    lfit <- loess(resp~day, data=dd2)
    
    pred <- unname(predict(lfit, newdata=pp))
    
    data.frame(
      day=dd1$day,
      deaths=(dd1$pred),
      mobility=pred,
      region=dd1$region,
      metric=dd1$metric,
      type=y
    )  
  }) %>%
    bind_rows
}) %>%
  bind_rows

phasedata_end <- phasedata %>%
  group_by(region, type) %>%
  filter(day==max(day))

tt <- unique(phasedata$type)

for (i in 1:length(tt)) {
  print(i)
  pp <- paste0("national_deaths_metric_phase_", tt[i], ".tex")
  
  x <- filter(phasedata, type==tt[i])
  
  x_end <- filter(phasedata_end, type==tt[i])
  
  gplot <- ggplot(x) +
    geom_path(aes(mobility, deaths, group=region, col=metric, lty=region),
              arrow = arrow(length = unit(0.1, "inches"), type = "closed")) +
    geom_dl(data=x_end, aes(mobility, deaths, label=region, col=metric), method=list("last.bumpup", hjust=-0.2)) +
    scale_x_continuous(firstup(gsub("\\_", " ", tt[i]))) +
    scale_y_log10("Smoothed daily number of reported deaths") +
    scale_color_gradientn("Symmetry\ncoefficient", colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
    scale_fill_gradientn("Symmetry\ncoefficient", colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
    scale_linetype_manual(values=c(1:9, 1:9), guide=FALSE) +
    theme(
      panel.grid = element_blank(),
      strip.background = element_blank()
    )
  
  tikz(file = pp, width = 6, height = 6, standAlone = T)
  plot(gplot)
  dev.off()
  tools::texi2dvi(pp, pdf = T, clean = F)
}
