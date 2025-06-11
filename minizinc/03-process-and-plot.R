#!/usr/bin/env Rscript
library(readr)
library(dplyr)
library(ggplot2)
library(tikzDevice)

df <- read_table("times.dat",col_names=c("time_s","model","n"))

df_g <- df %>% group_by(`model`,`n`) %>% summarise(mean_time_s=mean(`time_s`), sd=sd(`time_s`), samples=n())
df_g

write_csv(df_g,"avgtimes.csv")


df_times_slower <- df_g %>% mutate(`prev` = lag(`mean_time_s`)) %>% summarise(`times_slower`=`mean_time_s`/`prev`)
df_times_slower

write_csv(df_times_slower,"times_slower.csv")

time_plot <- ggplot(df_g) + aes(x=`n`,y=`mean_time_s`, colour=`model`) + 
  geom_line() + 
  geom_point() +
  xlab("n") + 
  ylab("Minizinc rewrite time (s)") + 
  labs(colour = "Model")
time_plot

ggsave("timeplot.png")
# ggsave("timeplot.tex", dev=tikzDevice::tikz)

time_plot_log <- ggplot(df_g) + aes(x=`n`,y=`mean_time_s`, colour=`model`) + 
  geom_line() + 
  geom_point() +
  scale_y_log10() +
  xlab("n") + 
  ylab("Minizinc rewrite time (log10 s)") + 
  labs(colour = "Model")
time_plot_log

ggsave("timeplot_log.png")
# ggsave("timeplot_log.tex", dev=tikzDevice::tikz)
