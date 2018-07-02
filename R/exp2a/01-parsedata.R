rm(list = ls())

pth <- here::here("..","data","exp2a","responses")

files <- list.files(pth, pattern = "*.csv", full.names = T)

df <- do.call("rbind",lapply(files,FUN=function(f) {read.csv(f, skip = 1, stringsAsFactors = F)}))

df$restk <- as.numeric(gsub(".*rest(.*)\\.csv","\\1",df$file))
df$type  <- as.numeric(gsub(".*_(.*)_rest.*","\\1",df$file))

str(df)


saveRDS(df,file = "../data/exp2a/responses/responses_150410.rds")
