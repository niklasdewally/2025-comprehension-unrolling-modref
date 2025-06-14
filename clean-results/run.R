#!/usr/bin/env Rscript

# create output dir
dir.create("output/",showWarnings= FALSE)

library(readr)
library(dplyr)
library(stringr)
library(ggplot2)
library(tikzDevice)


# https://iltabiai.github.io/tips/latex/2015/09/15/latex-tikzdevice-r.html

# savile row and minizinc rewrite times

# open and plot the rewrite times for the given tool
plot_rewrite_times <- function(name) {
  # name in lower case without spaces, for filename
  name_lower <- str_remove(tolower(name)," ")

  input_file <- str_glue("raw_data/{name_lower}_rewrite_times.dat")

  df <- read_table(input_file)

  dfCleaned <- df %>% filter(`n` <= 200, `exit_code` == 0)

  dfGrouped <- dfCleaned %>% 
    group_by(`model`,`n`) %>% 
    summarise(`Mean Rewrite Time (s)`=mean(`time_s`), 
      `sd` = sd(`time_s`), 
      `Samples` =n()) %>%
    rename(`Model` = `model`)

  write_csv(dfGrouped,str_glue("output/{name_lower}_averaged_rewrite_times.csv"))

  # tikz(file = "output/{name_lower}_rewrite_time_plot.tex", width = 5, height = 5)

  time_plot <- ggplot(dfGrouped) +
    aes(x=`n`, y=`Mean Rewrite Time (s)`, colour= `Model`, group = `Model`) +
    geom_line() + 
    geom_point() + 
    xlab("n") + 
    ylab(str_glue("{name} rewrite time (s)")) + 
    labs(colour = "Varient")

  # print(time_plot)
  # dev.off()

  ggsave(str_glue("output/{name_lower}_rewrite_time_plot.pdf"))

  # tikz(file = "output/{name_lower}_rewrite_time_plot_log.tex", width = 5, height = 5)
  # time_plot_log <- time_plot +
  #   scale_y_log10() + 
  #   ylab(str_glue("{name} rewrite time (log s)"))
  

  # print(time_plot_log)
  # dev.off()

  ggsave(str_glue("output/{name_lower}_rewrite_time_plot_log.pdf"))

}


# plots for triples unrolling time

plot_triple_unrolling_time <- function() {
  df <- read_csv("raw_data/triples_time_to_unroll.csv")

  df_return_expr <- df %>% 
    filter(`model` == "guards_in_return_expression") %>%
    group_by(`bench`,`n`) %>% 
    summarize(`realtime_s_mean` = mean(`realtime_s`), 
      `n_exprs_in_expansion` = first(`n_exprs_in_expansion`), 
      `realtime_s_sd` = sd(`realtime_s`), 
      `samples` = n())

  # plot expressions unrolled


  # tikz(file = "output/triples_time_to_unroll.tex", width = 5, height = 5)

  time_to_unroll <- ggplot(df_return_expr) + 
    aes(x=`n`,y=`realtime_s_mean`, group = `bench`, colour=`bench`) + 
    geom_line() +
    geom_point() + 
    scale_x_continuous(breaks=(df_return_expr %>% ungroup() %>% select(`n`) %>% distinct() %>% pull())) + 
    xlab("n") + 
    ylab("Time to unroll (s)")

  # print(time_to_unroll)
  # dev.off()

  ggsave("output/triples_time_to_unroll.pdf",time_to_unroll)

  # tikz(file = "output/triples_time_to_unroll_log.tex", width = 5, height = 5)
  time_to_unroll_log <- time_to_unroll + 
    scale_y_log10() + 
    ylab("Time to unroll (log s)")

  # print(time_to_unroll_log)
  # dev.off()

  ggsave("output/triples_time_to_unroll_log.pdf",time_to_unroll_log)

  # tikz(file = "output/triples_expressions_unrolled.tex", width = 5, height = 5)

  expressions_unrolled <- ggplot(df_return_expr) + 
    aes(x=`n`,y=`n_exprs_in_expansion`, group = `bench`, colour=`bench`) + 
    geom_line() +
    geom_point() + 
    scale_x_continuous(breaks=(df_return_expr %>% ungroup() %>% select(`n`) %>% distinct() %>% pull())) + 
    xlab("n") + 
    ylab("Expressions in expansion")

  # print(expressions_unrolled)
  # dev.off()

  ggsave("output/triples_expressions_unrolled.pdf",expressions_unrolled)

  # tikz(file = "output/triples_expressions_unrolled_log.tex", width = 5, height = 5)

  expressions_unrolled_log <- expressions_unrolled + 
    scale_y_log10() + 
    ylab("Expressions in expansion (log)")

  # print(expressions_unrolled_log)
  # dev.off()

  ggsave("output/triples_expressions_unrolled_log.pdf",expressions_unrolled_log)

}


plot_rewrite_times("Savile Row")
plot_rewrite_times("MiniZinc")
plot_triple_unrolling_time()
