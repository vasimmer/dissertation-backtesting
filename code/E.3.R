colnames(Rstrat) <- colnames(alls)
colnames(alls2)  <- colnames(alls)
 
keep <- complete.cases(Rstrat)          # trim to the common sample first
Rk   <- Rstrat[keep, , drop = FALSE]
idx <- match(rownames(Rk), rownames(alls2))
stopifnot(!anyNA(idx), !anyDuplicated(rownames(alls2)))
a2 <- alls2[idx, , drop = FALSE]
stopifnot(identical(dimnames(Rk), dimnames(a2)))
 
turn <- rbind(rep(0, NCOL(a2)), abs(diff(a2)))   # 1 at each position change
cost <- 0.0010                                   # 10 basis points per change
Rstrat_net <- Rk - turn * cost
 
nyears    <- NROW(Rk) / 52
trades_py <- colSums(turn) / nyears
 
out_net <- matrix.stats(Rstrat_net, xdtp)
write.csv(t(out_net$statistics), paste0(ticker, "_STATISTICS_NET.csv"))
 
mu     <- colMeans(Rk) * 52
excess <- mu - mu[1]
be_bp  <- ifelse(trades_py > 0, (excess / trades_py) * 10000, NA)
write.csv(data.frame(Rule = colnames(a2),
                     Trades_per_year   = round(trades_py, 1),
                     Ann_return_gross  = round(mu, 4),
                     Excess_vs_BH      = round(excess, 4),
                     Breakeven_cost_bp = round(be_bp, 1)),
          paste0(ticker, "_TRANSACTION_COSTS.csv"), row.names = FALSE)
