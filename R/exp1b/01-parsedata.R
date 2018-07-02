rm(list = ls())

pth <- here::here("..","data","exp1b","responses")

files <- list.files(pth, pattern = "*.csv", full.names = T)

df <- do.call("rbind",lapply(files,FUN=function(f) {read.csv(f, skip = 1, stringsAsFactors = F)}))

str(df)
df <- filter(df, subject != 1)
saveRDS(df,file = "../data/exp1b/responses/responses_150622.rds")
