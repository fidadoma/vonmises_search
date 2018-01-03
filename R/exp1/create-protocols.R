rm(list = ls())

masterseed <- 98765

create.protocol <- function(pid) {
  set.seed(masterseed + pid)
  n <- 194
  p <- data.frame(pid = rep(pid, n),
                  block = c(0,0,rep(1:4, each = (n - 2) / 4)),
                  trial = 1:n,
                  file = character(n),
                  trialid = numeric(n),
                  trialType = numeric(n),                  
                  rest_k = numeric(n),
                  stringsAsFactors = F)
  ks <- c(1, 2, 4, 8, 16, 32, 64, 128)
  stopifnot((n - 2) %% length(ks) == 0)
  p$trialType <- c(sample(ks,2), sample(rep(ks, each = (n - 2) / length(ks)))) 
  p$trialid   <- sample(n) 
  p$rest_k   <- c(4,64,sample(c(rep(4,(n - 2) / 3), rep(16, (n - 2) / 3), rep(64,(n - 2) / 3))))
  p$file      <- sprintf("../trajectories/T%03d_%d_rest%d.csv", p$trialid, p$trialType, p$rest_k)
    
  return(p)
}

for (i in 1:100) {
  p <- create.protocol(i)
  write.csv(p,sprintf("../data/exp1/protocols/P%03d.csv", i), row.names = F)
}
