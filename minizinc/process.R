library(readr)
library(dplyr)

df <- read_table("times.dat",col_names=c("time_s","model","n"))
df

df_g <- df %>% group_by(`model`,`n`) %>% summarise(mean_time_s=mean(`time_s`), sd=sd(`time_s`), samples=n())
df_g

write_csv(df_g,"avgtimes.csv")


df_times_slower <- df_g %>% mutate(`prev` = lag(`mean_time_s`)) %>% summarise(`times_slower`=`mean_time_s`/`prev`)
df_times_slower

write_csv(df_times_slower,"times_slower.csv")
