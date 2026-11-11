# Run after E.3 for each asset, using the same evaluation dates.
ii <- match(rownames(Rk), rownames(alls2))
f <- colMeans(alls2[ii, , drop = FALSE])
asset_r <- as.numeric(R[ii])
cash_r <- rf_wk[ii]
mix <- outer(asset_r, f) + outer(cash_r, 1 - f)
colnames(mix) <- colnames(Rk)
rule_total <- Rstrat_total[ii, , drop = FALSE]
dd <- function(x) maxDDD(cumprod(1 + x) - 1)$maxDD
comparison <- data.frame(
  Rule = colnames(Rk), Exposure = f,
  Rule_MDD = apply(rule_total, 2, dd),
  Static_MDD = apply(mix, 2, dd))
write.csv(comparison, paste0(ticker, "_STATIC_EXPOSURE.csv"),
          row.names = FALSE)
# Constant weights require rebalancing. This comparison is gross of costs.
# Full-sample exposure matching is retrospective, not an ex-ante strategy.
