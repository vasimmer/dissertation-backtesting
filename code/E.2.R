library("PeerPerformance")
 
colnames(Rstrat) <- colnames(alls)
Rstrat <- na.omit(Rstrat)          # common evaluation sample for all rules
 
runLW <- function(Rmat) {
  bh    <- Rmat[, 1]               # buy-and-hold benchmark returns
  rules <- colnames(Rmat)[-1]
  res   <- data.frame(Rule = rules, Sharpe = NA, BH_Sharpe = NA,
                      Diff = NA, p_value = NA)
  for (i in seq_along(rules)) {
    x <- Rmat[, rules[i]]; y <- bh
    ctr <- list(type = 2, nBoot = 1000, bBoot = 5, hac = TRUE)
    tt <- tryCatch(sharpeTesting(x, y, control = ctr), error = function(e) NULL)
    sx <- mean(x, na.rm = TRUE) / sd(x, na.rm = TRUE) * sqrt(xdtp)
    sy <- mean(y, na.rm = TRUE) / sd(y, na.rm = TRUE) * sqrt(xdtp)
    res$Sharpe[i]    <- round(sx, 3)
    res$BH_Sharpe[i] <- round(sy, 3)
    res$Diff[i]      <- round(sx - sy, 3)
    res$p_value[i]   <- if (is.null(tt)) NA else round(tt$pval, 3)
  }
  res$sig <- ""
  res$sig[!is.na(res$p_value) & res$p_value < 0.10] <- "*"
  res$sig[!is.na(res$p_value) & res$p_value < 0.05] <- "**"
  res$sig[!is.na(res$p_value) & res$p_value < 0.01] <- "***"
  res
}
 
set.seed(1234)
full <- runLW(Rstrat)
write.csv(full, paste0(ticker, "_STATISTICS_LW.csv"), row.names = FALSE)
 
subperiods <- list("2006-2009" = c("2005-01-01", "2009-12-31"),  # warm-up trims the window to 2006,
                   "2010-2014" = c("2010-01-01", "2014-12-31"),
                   "2015-2019" = c("2015-01-01", "2019-12-31"),
                   "2020-2024" = c("2020-01-01", "2024-12-31"))
dates  <- as.Date(rownames(Rstrat))
allsub <- NULL
for (nm in names(subperiods)) {
  w   <- subperiods[[nm]]
  sel <- dates >= as.Date(w[1]) & dates <= as.Date(w[2])
  set.seed(1234)
  r <- runLW(Rstrat[sel, , drop = FALSE]); r$Period <- nm
  f_win <- colMeans(alls2[rownames(Rstrat), , drop = FALSE][sel, , drop = FALSE])
  r$Pct_weeks_invested <- round(100 * f_win[r$Rule], 1)
  allsub <- rbind(allsub, r)
}
write.csv(allsub, paste0(ticker, "_STATISTICS_LW_subperiods.csv"), row.names = FALSE)
