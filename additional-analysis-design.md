# Additional analysis design

Set before running the additional calculations, 5 September 2026.

Purpose: challenge the interpretation of defensive performance, without selecting winning rules or changing the original rule grid.

1. Recalculate the matched-exposure drawdown comparison for the existing four calendar windows. Report all 37 MA, TRB, MACD and ROC specifications, the count with smaller drawdowns, and the median paired drawdown difference. Match exposure within each window. This remains retrospective. Use a wealth series starting at one and including the first return in the running maximum. Also reconcile the original full-period drawdowns to identify any effect of its initial-value convention.
2. For the three later windows, use each rule's exposure from the previous calendar window as a fixed comparator weight. This benchmark weight uses prior information, but does not necessarily match the rule's subsequent realised exposure. Label this a chronological sensitivity check, not an untouched holdout.
3. Decompose annualised sample mean excess return exactly into average exposure times benchmark mean plus 52 times the sample covariance (denominator n) between the already lagged position and subsequent excess return. This timing component is relative to an exposure-matched allocation, not alpha or Sharpe improvement.
4. Report the mean timing component across the pre-existing 37 trend specifications. Estimate percentile 95% confidence intervals with 10,000 paired circular-block resamples, recomputing exposure and mean returns in each resample. Block lengths 5, 13 and 26 weeks are fixed here. Resample common calendar rows jointly across both assets. Cross-rule dependence is retained by averaging positions within each asset before resampling, which is algebraically identical for this statistic. Also report an equal-family average as a sensitivity check because the grid has unequal numbers per family. These are exploratory full-period diagnostics under weak-dependence/stationarity assumptions, not confirmatory tests of a new strategy.

No choice to retain a result will depend on its sign or significance. Interpretation and claims will be revised to reflect all main results.
