#!/usr/bin/env Rscript

library(dplyr)
library(readr)
library(ggplot2)

df <- read_csv("unroll_then_exit_time_data.csv")
df

df_return_expr <- df %>% 
  filter(`model` == "guards_in_return_expression") %>%
  group_by(`bench`,`n`) %>% 
  summarize(`realtime_s_mean` = mean(`realtime_s`), `n_exprs_in_expansion` = first(`n_exprs_in_expansion`), `realtime_s_sd` = sd(`realtime_s`), `samples` = n())
df_return_expr


# plot expressions unrolled
time_to_unroll <- ggplot(df_return_expr) + 
  aes(x=`n`,y=`realtime_s_mean`, group = `bench`, colour=`bench`) + 
  geom_line() +
  geom_point() + 
  scale_x_continuous(breaks=(df_return_expr %>% ungroup() %>% select(`n`) %>% distinct() %>% pull())) + 
  xlab("n") + 
  ylab("Time to unroll (s)")

ggsave("plot_time_to_unroll.png",time_to_unroll)

time_to_unroll_log <- ggplot(df_return_expr) + 
  aes(x=`n`,y=`realtime_s_mean`, group = `bench`, colour=`bench`) + 
  geom_line() +
  geom_point() + 
  scale_x_continuous(breaks=(df_return_expr %>% ungroup() %>% select(`n`) %>% distinct() %>% pull())) + 
  scale_y_log10() + 
  xlab("n") + 
  ylab("Time to unroll (log10 s)")

ggsave("plot_time_to_unroll_log.png",time_to_unroll_log)

expressions_unrolled <- ggplot(df_return_expr) + 
  aes(x=`n`,y=`n_exprs_in_expansion`, group = `bench`, colour=`bench`) + 
  geom_line() +
  geom_point() + 
  scale_x_continuous(breaks=(df_return_expr %>% ungroup() %>% select(`n`) %>% distinct() %>% pull())) + 
  xlab("n") + 
  ylab("Expressions in expansion")

ggsave("plot_expressions_unrolled.png")
ggsave("plot_expressions_unrolled.png",expressions_unrolled)

expressions_unrolled_log <- ggplot(df_return_expr) + 
  aes(x=`n`,y=`n_exprs_in_expansion`, group = `bench`, colour=`bench`) + 
  geom_line() +
  geom_point() + 
  scale_x_continuous(breaks=(df_return_expr %>% ungroup() %>% select(`n`) %>% distinct() %>% pull())) + 
  scale_y_log10() + 
  xlab("n") + 
  ylab("Expressions in expansion (log10)")

ggsave("plot_expressions_unrolled_log.png",expressions_unrolled_log)
