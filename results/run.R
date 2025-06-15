#!/usr/bin/env Rscript

# create output dir
dir.create("output/",showWarnings= FALSE)

library(readr)
library(forcats)
library(dplyr)
library(stringr)
library(ggplot2)
library(tikzDevice)
library(tinytex)
library(scales)

ggplotTheme <- theme_bw()

# install packages needed for tikz then test that tikz works
if (!(any("pgf" == tinytex::tl_pkgs(only_installed=TRUE)))) {
  tinytex::tlmgr_install(pkgs = "pgf")
}

if (!(any("preview" == tinytex::tl_pkgs(only_installed=TRUE)))) {
  tinytex::tlmgr_install(pkgs = "preview")
}

if (!(any("grfext" == tinytex::tl_pkgs(only_installed=TRUE)))) {
  tinytex::tlmgr_install(pkgs = "grfext")
}

options(tikzDefaultEngine = 'pdftex')

tikzTest()

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
    summarise(`Mean Rewrite Time (s)`=mean(`time_s`)) %>%
    rename(`Model` = `model`) %>%
    mutate(`Model` = case_when(
      (`Model` == "dynamic_guards" & name == "Savile Row") ~ "Comprehension, no guards",
      (`Model` == "dynamic_guards" & name == "MiniZinc") ~ "Forall",
      `Model` == "guards_in_return_expression" ~ "Comprehension, no guards",
      `Model` == "comprehension_guards" ~ "Comprehension, with guards",
      `Model` == "static_guards" ~ "Comprehension, with guards",
    .default = str_to_title(`Model`))) %>%
    mutate(`n` = as.numeric(`n`))

  write_csv(dfGrouped,str_glue("output/{name_lower}_averaged_rewrite_times.csv"))

  tikz(file = str_glue("output/{name_lower}_rewrite_time_plot.tikz"), width = 5, height = 5, sanitize=TRUE)

  time_plot <- ggplot(dfGrouped) +
    ggplotTheme + 
    aes(x=`n`, y=`Mean Rewrite Time (s)`, colour= `Model`, shape = `Model`, group = `Model`) +
    geom_line() + 
    geom_point(size=1) + 
    scale_x_continuous(breaks = scales::breaks_width(50)) +
    xlab("n") + 
    ylab(str_glue("{name} rewrite time (s)")) + 
    labs(colour= "Model variant", shape = "Model variant")

  print(time_plot)
  dev.off()

  ggsave(str_glue("output/{name_lower}_rewrite_time_plot.pdf"))

  tikz(file = str_glue("output/{name_lower}_rewrite_time_plot_log.tikz"), width = 5, height = 5, sanitize=TRUE)
  time_plot_log <- time_plot +
    scale_y_log10(labels = label_log()) + 
    ylab(str_glue("{name} rewrite time (s)"))
  

  print(time_plot_log)
  dev.off()

  ggsave(str_glue("output/{name_lower}_rewrite_time_plot_log.pdf"))
}


# plots for triples unrolling time

plot_triple_unrolling_time <- function() {
  df1 <- read_csv("raw_data/triples_time_to_unroll.csv")
  df2 <- read_csv("raw_data/colours_time_to_unroll.csv")

  df <- bind_rows(df1,df2)

  dfClean <- df %>% 
    group_by(`model`,`bench`,`n`) %>% 
    summarize(`realtime_s` = mean(`realtime_s`), 
      `n_exprs_in_expansion` = first(`n_exprs_in_expansion`), 
      `samples` = n()) %>%
    ungroup() %>%
    mutate(`n` = as.numeric(`n`)) %>%
    group_by(`model`) %>%
    mutate(`relative_realtime_s` = `realtime_s` / min(`realtime_s`)) %>% 
    mutate(`relative_n_exprs_in_expansion` = `n_exprs_in_expansion` / min(`n_exprs_in_expansion`)) %>%
    mutate(`model` = case_when(
      `model` == "guards_in_return_expression" ~ "Triples, no comprehension guards",
      `model` == "colours1" ~ "Triangle Colouring #1",
      `model` == "colours2" ~ "Triangle Colouring #2", 
      .default = `model`))

  # plot small multiple plots  

  tikz(file = "output/time_to_unroll.tikz", width = 10, height = 5,sanitize=TRUE)

  time_to_unroll <- ggplot(dfClean) + 
    ggplotTheme + 
    aes(x=`n`,y=`relative_realtime_s`, group = `bench`, colour=`bench`, shape=`bench`) + 
    geom_line() +
    geom_point(size=1) + 
    scale_x_continuous(breaks=scales::breaks_width(20)) +
    xlab("n") + 
    ylab("Time to unroll (s, relative to fastest)") +
    labs(colour= "Expansion method",shape="Expansion method") + facet_wrap(~`model`, ncol=2)

  print(time_to_unroll)
  dev.off()

  ggsave("output/time_to_unroll.pdf",time_to_unroll)

  tikz(file = "output/time_to_unroll_log.tikz", width = 10, height = 5, sanitize = TRUE )
  time_to_unroll_log <- time_to_unroll + 
    scale_y_log10(labels = label_log()) + 
    ylab("Time to unroll (s, relative to fastest)")

  print(time_to_unroll_log)
  dev.off()

  ggsave("output/time_to_unroll_log.pdf",time_to_unroll_log)

  tikz(file = "output/expressions_unrolled.tikz", width = 10, height = 5, sanitize=TRUE)

  expressions_unrolled <- ggplot(dfClean) + 
    ggplotTheme + 
    aes(x=`n`,y=`relative_n_exprs_in_expansion`, group = `bench`, colour=`bench`, shape=`bench`) + 
    geom_line() +
    geom_point(size=1) + 
    scale_x_continuous(breaks=scales::breaks_width(20)) +
    xlab("n") + 
    ylab("Expressions in expansion (relative to smallest)") + 
    labs(colour= "Expansion method",shape="Expansion method")  + facet_wrap(~`model`,ncol=2)

  print(expressions_unrolled)
  dev.off()

  ggsave("output/expressions_unrolled.pdf",expressions_unrolled)

  tikz(file = "output/expressions_unrolled_log.tikz", width = 10, height = 5, sanitize=TRUE)

  expressions_unrolled_log <- expressions_unrolled + 
    scale_y_log10(labels = label_log()) + 
    ylab("Expressions in expansion (relative to smallest)")

  print(expressions_unrolled_log)
  dev.off()

  ggsave("output/expressions_unrolled_log.pdf",expressions_unrolled_log)

  # plots for only triples
  tikz(file = "output/triples_expressions_unrolled.tikz", width = 5, height = 5, sanitize=TRUE)
  expressions_unrolled <- ggplot(dfClean %>% filter(`model` == "Triples, no comprehension guards")) +
    ggplotTheme + 
    aes(x=`n`,y=`relative_n_exprs_in_expansion`, group = `bench`, colour=`bench`, shape=`bench`) + 
    geom_line() +
    geom_point(size=1) + 
    scale_x_continuous(breaks=scales::breaks_width(20)) +
    xlab("n") + 
    ylab("Expressions in expansion (relative to smallest)") + 
    labs(colour= "Expansion method",shape="Expansion method")

  print(expressions_unrolled)
  dev.off()
  ggsave("output/triples_expressions_unrolled.pdf",expressions_unrolled)

  tikz(file = "output/triples_expressions_unrolled_log.tikz", width = 5, height = 5, sanitize=TRUE)
  expressions_unrolled_log <- expressions_unrolled + 
    scale_y_log10(labels = label_log()) + 
    ylab("Expressions in expansion (relative to smallest)")

  print(expressions_unrolled_log)
  dev.off()

  ggsave("output/triples_expressions_unrolled_log.pdf",expressions_unrolled_log)

  tikz(file = "output/triples_time_to_unroll.tikz", width = 5, height = 5, sanitize = TRUE )
  time_to_unroll <- ggplot(dfClean %>% filter(`model` == "Triples, no comprehension guards")) + 
    ggplotTheme + 
    aes(x=`n`,y=`relative_realtime_s`, group = `bench`, colour=`bench`, shape=`bench`) + 
    geom_line() +
    geom_point(size=1) + 
    scale_x_continuous(breaks=scales::breaks_width(20)) +
    xlab("n") + 
    ylab("Time to unroll (s, relative to fastest)") +
    labs(colour= "Expansion method",shape="Expansion method")

  print(time_to_unroll)
  dev.off()

  ggsave("output/triples_time_to_unroll.pdf",time_to_unroll)

  tikz(file = "output/triples_time_to_unroll_log.tikz", width = 5, height = 5, sanitize = TRUE )
  time_to_unroll_log <- time_to_unroll + 
    scale_y_log10(labels = label_log()) + 
    ylab("Time to unroll (s, relative to fastest)")

  print(time_to_unroll_log)
  dev.off()

  ggsave("output/triples_time_to_unroll_log.pdf",time_to_unroll_log)
}


plot_rewrite_times("Savile Row")
plot_rewrite_times("MiniZinc")
plot_triple_unrolling_time()
