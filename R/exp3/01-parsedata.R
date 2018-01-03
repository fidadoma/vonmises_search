rm(list = ls())

pth <- "../data/exp3/responses/"

files <- list.files(pth, pattern = "*.csv", full.names = T)

df <- do.call("rbind",lapply(files,FUN=function(f) {read.csv(f, skip = 1, stringsAsFactors = F)}))

df$restk <- as.numeric(gsub(".*rest(.*)\\.csv","\\1",df$file))
df$type  <- as.numeric(gsub(".*_(.*)_rest.*","\\1",df$file))

str(df)

save(df,file = "../data/exp3/responses/responses_150410.RData")
