rm(list = ls())

pth <- "../data/exp1/responses/"

files <- list.files(pth, pattern = "*.csv", full.names = T)

df <- do.call("rbind",lapply(files,FUN=function(f) {read.csv(f, skip = 1, stringsAsFactors = F)}))

str(df)

save(df,file = "../data/exp1/responses/responses_150330.RData")
