library(dplyr)
library(ggplot2); theme_set(theme_bw())

death <- read.csv("daily.csv") %>%
  mutate(
    date=sub("(.{4})(.*)", "\\1-\\2", date),
    date=sub("(.{7})(.*)", "\\1-\\2", date),
    date=as.Date(date),
    deathIncrease=ifelse(deathIncrease<=0, NA, deathIncrease)
  ) %>%
  filter(!(state %in% c("AS", "DC", "FM", "GU", "MH", "MP", "PW", "PR", "VI")))

g1 <- ggplot(death) +
  geom_text(x=-Inf, y=Inf, aes(label=state), hjust=-0.1, vjust=1.1) +
  geom_point(aes(date, deathIncrease)) +
  geom_line(aes(date, deathIncrease)) +
  geom_smooth(aes(date, deathIncrease), se=FALSE, col="red", lwd=1.5) +
  scale_x_date("Date", expand=c(0, 0), limits=c(as.Date("2020-03-02"), NA)) +
  scale_y_log10("Daily number of reported deaths", limits=c(1,NA), expand=c(0, 0)) +
  facet_wrap(~state, scale="free_y", nrow=10) +
  theme(
    panel.grid=element_blank(),
    strip.background = element_blank(),
    strip.placement = "none",
    strip.text = element_blank()
  )

tikz(file = "deaths.tex", width = 12, height = 10, standAlone = T)
plot(g1)
dev.off()
tools::texi2dvi('deaths.tex', pdf = T, clean = T)
