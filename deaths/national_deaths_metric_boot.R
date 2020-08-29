source("national_deaths_metric.R")

us_death_boot <- lapply(split(us_death_filter, us_death_filter$region), function(x) {
  set.seed(101)
  dd <- unlist(mapply(rep, x$day, x$deaths))
  
  print(x$region[1])
  
  pp <- data.frame(
    day=seq(min(x$day), max(x$day), by=0.01)
  )
  
  reslist <- vector('list', nboot)
  
  for (i in 1:nboot) {
    
    tmp <- sample(dd, replace = TRUE)
    
    dd_tmp <- as.data.frame(table(tmp))
    dd_tmp$day <- as.numeric(as.character(dd_tmp$tmp))
    
    lfit <- loess(log(Freq)~day, data=dd_tmp)
    
    pred <- unname(exp(predict(lfit, newdata=pp)))
    
    D_P <- max(pred, na.rm=TRUE)
    
    t_P <- pp$day[which(pred==D_P)]
    
    ww <- tail(which(pred <= cutoff * D_P & pp$day < t_P), 1)[1]
    
    tau_R <- t_P - pp$day[ww]
    
    D_r <- pred[which(pp$day>=(t_P + tau_R))[1]]
    D_l <- pred[ww]
    
    metric <- D_l/D_r
    
    reslist[[i]] <- data.frame(
      sim=i,
      metric=metric,
      region=x$region[1],
      t_P=t_P,
      D_l=D_l,
      D_r=D_r,
      D_P=D_P,
      t_1=t_P-tau_R,
      t_2=t_P+tau_R
    )
  }
  
  reslist %>%
    bind_rows
})

us_death_boot_summ <- us_death_boot %>%
  bind_rows %>%
  group_by(region) %>%
  summarize(
    lwr=quantile(metric, 0.025, na.rm=TRUE),
    upr=quantile(metric, 0.975, na.rm=TRUE)
  )

us_death_fit3 <- us_death_fit2 %>%
  merge(us_death_boot_summ) %>%
  arrange(metric)

us_death_fit0a <- us_death_fit0 %>%
  group_by(region) %>%
  mutate(
    day2=(day-t_P)
  )

us_death_fit0a_end <- us_death_fit0a %>%
  group_by(region) %>%
  filter(day2==max(day2))

us_death_filter_plot <- us_death %>%
  filter(region %in% c("MN", "NC", "IN", "MD")) %>%
  mutate(
    region=factor(region, levels=c("MN", "NC", "IN", "MD"))
  )

g1 <- ggplot(us_death_filter_plot) +
  geom_text(x=-Inf, y=Inf, aes(label=region), hjust=-0.1, vjust=1.1) +
  geom_point(aes(date, deaths)) +
  geom_line(aes(date, deaths)) +
  geom_smooth(aes(date, deaths), se=FALSE, col="red", lwd=1.5) +
  scale_x_date("Date", expand=c(0, 0), limits=c(as.Date("2020-03-02"), NA)) +
  scale_y_log10("Daily number of reported deaths", limits=c(1,NA), expand=c(0, 0)) +
  ggtitle("A") +
  facet_wrap(~region, scale="free", nrow=1) +
  theme(
    panel.grid=element_blank(),
    strip.background = element_blank(),
    strip.placement = "none",
    strip.text = element_blank(),
    axis.title.x = element_blank()
  )

g2 <- ggplot(us_death_fit0a) +
  geom_vline(xintercept = 0, lty=2) +
  geom_line(aes(day2, pred, group=region, col=metric, lty=region)) +
  geom_point(data=us_death_fit0a_end, aes(day2, pred, group=region, fill=metric), shape=21, col=1) +
  geom_dl(data=filter(us_death_fit0a, region!="VA"), aes(day2, pred, label=region, col=metric), method=list("last.bumpup", hjust=-0.5, vjust=1, cex=0.5)) +
  geom_dl(data=filter(us_death_fit0a, region=="VA"), aes(day2, pred, label=region, col=metric), method=list("last.bumpup", hjust=-0.5, vjust=2, cex=0.5)) +
  scale_x_continuous("Time since $t_P$ (days)", expand=c(0, 0), limits=c(-60, 60)) +
  scale_y_log10("Smoothed daily number of reported deaths") +
  scale_color_gradientn(colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
  scale_fill_gradientn(colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
  scale_linetype_manual(values=c(1:9, 1:9)) +
  ggtitle("B") +
  theme(
    legend.position = "none",
    panel.grid = element_blank()
  )

g3 <- ggplot(us_death_fit3) +
  geom_point(aes(metric, region, col=metric)) +
  geom_errorbarh(aes(xmin=lwr, xmax=upr, y=region, col=metric), height=0) +
  scale_color_gradientn("Symmetry\ncoefficient", colors=c("black", "#8a0072", "#cf2661", "#f66d4e", "#ffb34a")) +
  scale_x_continuous("Symmetry coefficient") +
  scale_y_discrete("States ranked by symmetry coefficient", limits = rev(us_death_fit3$region)) +
  ggtitle("C") +
  theme(
    legend.position = "right",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )

g4 <- arrangeGrob(g2, g3, nrow=1)

gtot <- arrangeGrob(g1, g4, nrow=2)

tikz(file = "national_deaths_metric_boot.tex", width = 10, height = 8, standAlone = T)
plot(gtot)
dev.off()
tools::texi2dvi('national_deaths_metric_boot.tex', pdf = T, clean = F)
## clean = T somehow deleted all other files...