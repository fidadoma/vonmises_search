rm(list = ls())

pth <- here::here("..","data","exp1a","responses")

files <- list.files(pth, pattern = "*.csv", full.names = T)

df <- do.call("rbind",lapply(files,FUN=function(f) {read.csv(f, skip = 1, stringsAsFactors = F)}))

str(df)

saveRDS(df,file = "../data/exp1a/responses/responses_150330.rds")
