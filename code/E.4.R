spy <- read.csv("SPY_STATISTICS_LW_subperiods.csv"); spy$Asset <- "SPY"
gld <- read.csv("GLD_STATISTICS_LW_subperiods.csv"); gld$Asset <- "GLD"
d <- rbind(spy, gld)
d$Diff <- as.numeric(d$Diff); d$BH_Sharpe <- as.numeric(d$BH_Sharpe)
d <- d[!is.na(d$Diff), ]
 
# pooled specification (n = 511 rule-window observations)
cor.test(d$BH_Sharpe, d$Diff)
summary(lm(Diff ~ BH_Sharpe, data = d))
 
# aggregated specification (n = 8 asset-window observations)
agg <- aggregate(cbind(Diff, Pos = as.numeric(d$Diff > 0)) ~ Asset + Period + BH_Sharpe,
                 data = d, FUN = mean)
agg$PctPos <- agg$Pos * 100; agg$Pos <- NULL
cor.test(agg$BH_Sharpe, agg$Diff)
cor.test(agg$BH_Sharpe, agg$Diff, method = "spearman")
summary(lm(Diff ~ BH_Sharpe, data = agg))
 
# uncoupled specification reported in Section 5.5
agg$Rule_Sharpe <- agg$BH_Sharpe + agg$Diff
fit <- lm(Rule_Sharpe ~ BH_Sharpe, data = agg)
summary(fit)                         # slope 0.556 (se 0.072), R2 = 0.909
 
# test H0: slope = 1 (rules keep pace with the benchmark one for one)
b  <- coef(summary(fit))["BH_Sharpe", "Estimate"]
se <- coef(summary(fit))["BH_Sharpe", "Std. Error"]
tstat <- (b - 1) / se
2 * pt(-abs(tstat), df = df.residual(fit))   # t = -6.19, p = 0.0008
 
# related descriptive measure, also benchmark-dependent
cor.test(agg$BH_Sharpe, agg$PctPos)
 
# residual against the per-cell random-timing null (Section 5.5)
mm <- aggregate(sqrt(Pct_weeks_invested/100) ~ Asset + Period, data = d, FUN = mean)
names(mm)[3] <- "msqf"; agg <- merge(agg, mm)
agg$resid <- agg$Rule_Sharpe - agg$msqf * agg$BH_Sharpe
summary(lm(resid ~ BH_Sharpe, data = agg))     # slope -0.159 (se 0.063), t = -2.51, p = 0.046
b_null <- coef(lm(I(msqf * BH_Sharpe) ~ BH_Sharpe, data = agg))[2]
t2 <- (b - b_null) / se  # conditional on estimated benchmark
2 * pt(-abs(t2), df = df.residual(fit))        # p = 0.068
write.csv(agg, "REGIME_TABLE.csv", row.names = FALSE)
