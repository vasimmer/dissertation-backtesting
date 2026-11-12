# Dissertation v16: calculation replay and verification files

This supplement contains the six Appendix E listings, cached verification inputs, original dated CSV exports, and the verification outputs. It is separate from the dissertation Word file.

## Running

Use R with quantmod, zoo, PeerPerformance, moments and tseries installed. The recorded verification environment is in verified_outputs/sessionInfo.txt. Open this folder as the working directory and run `Rscript run.R`. This reruns the bootstrap and the other Appendix E calculations for both assets. Output is written to replayed_outputs. The bootstrap can take several minutes and can issue warnings for degenerate resamples.

For a fast replay of the exposure, drawdown, turnover and distribution diagnostics, run `Rscript run.R --diagnostics`. This mode explicitly reuses the supplied verification bootstrap exports. It does not rerun or independently verify the bootstrap.

## Input provenance and scope

GLD uses the saved project workspace. SPY uses a saved reconstruction. The per-asset inputs contain the signal and return objects produced by the base implementation, the Treasury-bill series, and the matrix.stats and maxDDD functions. Separate price caches support Appendix E.5. This is a replay from cached base-script objects, not a standalone recreation of all signals from raw downloads. It avoids later Yahoo/FRED revisions during verification. The original supervisor base script remains in the dissertation project.

The original 26 August exports are preserved in published. They remain the basis for the existing dissertation tables. The verified_outputs folder is separate so the two sets cannot be confused.

## Verified agreement and differences

Both assets reproduced all 64 rounded full-sample rule Sharpe ratios and full-sample p-values. All defined subperiod rule Sharpe ratios also matched. GLD subperiod p-values matched, including 21 unavailable values.

For reconstructed SPY, three subperiod p-values changed availability and two others changed by 0.001:

| Rule | Window | Original p-value | Verification p-value |
|---|---|---:|---:|
| MA(4,52) | 2010–2014 | 0.312 | unavailable |
| MA(2,52) | 2015–2019 | unavailable | 0.148 |
| MA(12,24) | 2015–2019 | 0.231 | 0.232 |
| MA(12,52) | 2015–2019 | 0.085 | unavailable |
| TRB(38) | 2015–2019 | 0.563 | 0.564 |

Thus SPY has 22 unavailable subperiod p-values in the original exports and 23 in the verification run. The absence of significantly positive differences is unchanged. These differences are disclosed in Section 5.8. Exact reproduction of every original SPY bootstrap result is not claimed.

## New comparison and interpretation

Appendix E.6 and Appendix G compare rule drawdowns with constant asset/Treasury-bill weights equal to each rule's full-sample average exposure. Weights are maintained weekly. This requires rebalancing, and costs are excluded. The weights are fitted retrospectively. The comparison is descriptive, not an out-of-sample strategy or a test based on 37 independent rules.

Appendix E.4 compares the observed slope with the slope implied by window-specific mean square-root exposure. The corrected comparison is approximately 0.556 versus 0.715. Its nominal tests use eight asset-windows and do not fully account for estimated-input uncertainty or shared calendar periods.

## Additional v16 diagnostics

Run `Rscript code/E.7.R` from this folder to reproduce the new drawdown-window comparisons and covariance-based timing attribution. This uses the same cached inputs and runs 10,000 joint circular-block bootstrap resamples at each of three block lengths. The original E.1–E.6 replay remains unchanged. New verified results are in verified_additional_outputs, and replay results go to additional_outputs. The design was recorded before calculating these additions, after the original results had been reviewed. They are exploratory, not preregistered or independent holdout evidence.

Drawdowns in the new window comparisons use a wealth path starting at one and include the first return in the running peak. The original base routine omitted the first observation from its peak update. The corrected full-period trend-grid computation changes SPY MA(4) drawdown by about 0.12 percentage points, without changing the displayed G1 examples, medians or lower-drawdown counts. The convention comparison is included in the outputs.

The return timing component applies the sample identity discussed by Lo (2008), Where do alphas come from? A measure of the value of active investment management, Journal of Investment Management 6(2), 1–29. It measures the sample covariance of lagged positions and subsequent excess returns, not risk-adjusted alpha. Averaging rule positions before jointly resampling dates retains dependence across rules for the reported mean statistic. Each resample re-estimates average exposure and asset returns. The intervals assume a sufficiently stable, weakly dependent return-position process and are gross of costs.
