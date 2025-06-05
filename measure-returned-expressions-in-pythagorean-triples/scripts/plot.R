#!/usr/bin/env Rscript

# ensure libraries are installed 
if(!require(dplyr)){
    install.packages("dplyr")
    library(dplyr)
}

if(!require(readr)){
    install.packages("readr")
    library(readr)
}

if(!require(ggplot2)){
    install.packages("ggplot2")
    library(ggplot2)
}

if(!require(tidyr)){
    install.packages("tidyr")
    library(tidyr)
}

time_data_path <- "output/time-data.csv"

df <- read_csv(time_data_path) %>% 
  tidyr::unite('group',model,command,remove=FALSE)

df <- df %>% 
  rename(`Model` = `model`) %>%
  rename(`Program`=`command`) #%>%
  # mutate(`Program`=case_when(`Program` == "conjureoxide" ~ "Conjure Oxide",
  #                            `Program` == "savilerow" ~ "Savile Row (-O0)"))



# ggplot(df) + 
#   aes(x=`n`, y=`mean`,group=`group`,color=`Program`,linetype=`Model`) + 
#   geom_path() + 
#   geom_point() + 
#   xlab('n') + 
#   ylab('Mean time (s)') + 
#   ggtitle('Boolean Pythagorean Triples Problem: Time to Unrolled Comprehensions')  + 
#   theme_minimal()

# ggplot(df) + 
#   aes(x=`n`, y=log(`mean`,10),group=`group`,color=`Program`,linetype=`Model`) + 
#   geom_path() + 
#   geom_point() + 
#   xlab('n') + 
#   ylab('Log Mean time (s)') + 
#   ggtitle('Boolean Pythagorean Triples Problem: Time to Unrolled Comprehensions')  + 
#   theme_minimal()

plt <- ggplot(df) + 
  aes(x=`n`, y=log(`mean`,10),group=`Program`,color=`Program`) + 
  geom_path() + 
  geom_point() + 
  xlab('n') + 
  ylab('Log mean time (s)') + 
  ggtitle('Boolean Pythagorean Triples Problem: Time to Unrolled Comprehensions') + facet_wrap(~Model) + theme_linedraw()

ggsave('output/time_figs/plot.png',plt)

# ggplot(df) + 
#   aes(x=`n`, y=log(`mean`,10),group=`Model`,color=`Program`,linetype=`Model`) + 
#   geom_path() + 
#   geom_point() + 
#   xlab('n') + 
#   ylab('Log mean time (s)') + 
#   ggtitle('Boolean Pythagorean Triples Problem: Time to Unrolled Comprehensions') + facet_wrap(~Program) + theme_linedraw()

