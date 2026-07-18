# Profitability of Technical Trading Rules — Equity & Commodity Markets

Backtesting and statistical-inference framework evaluating whether technical trading rules generate persistent risk-adjusted returns, applied to the S&P 500 (SPY) and Gold (GLD) using 20 years of weekly data (2005–2024).

This is the code accompanying my MSc Finance and Analytics dissertation at King's College London.

## Overview

The project tests **64 technical trading-rule specifications** across seven indicator families, benchmarks each against a passive buy-and-hold strategy, and formally tests whether any Sharpe-ratio differences are statistically significant — rather than the product of data snooping across many rules.

**Indicator families tested** (following Gerritsen et al., 2020):

- Single moving averages (MA)
- Dual moving-average crossovers
- Trading Range Breakout (TRB)
- MACD
- Rate of Change (ROC)
- On-Balance Volume (OBV)
- Relative Strength Index (RSI)
- Bollinger Bands (BB)

## Methodology

- **Data:** Weekly adjusted prices from Yahoo Finance via `quantmod`, 2005–2024.
- **Signal construction:** Each rule generates long / short / flat positions; short-selling is configurable. A one-period signal lag is applied so returns are never computed on contemporaneous information (avoids look-ahead bias).
- **Performance metrics:** Annualised return, volatility, Sharpe ratio, cumulative return, maximum drawdown, drawdown duration, win rate, and profit/loss ratio.
- **Statistical inference:** Ledoit–Wolf (2008) test on Sharpe-ratio differences vs buy-and-hold, using a studentised circular block bootstrap (1,000 resamples, block length 5) with HAC standard errors, via the `PeerPerformance` package.
- **Robustness:** Results are re-estimated across four five-year subperiods (2005–09, 2010–14, 2015–19, 2020–24) to check whether any outperformance is stable across market regimes.

## Key Findings

- **No statistically significant outperformance:** across the full sample, no technical rule delivered a Sharpe ratio significantly higher than buy-and-hold after accounting for the bootstrap-based inference — consistent with weak-form market efficiency.
- **Drawdown reduction:** trend-following rules substantially reduced downside risk, cutting maximum drawdown from roughly 55% to 26% for SPY and from ~45% to ~30% for GLD. This suggests their value lies in **risk management / downside protection** rather than persistent alpha.

## Repository Contents

| File | Description |
|------|-------------|
| `technical_trading_rules.R` | Full pipeline: data download, signal generation, backtesting, performance stats, and Ledoit–Wolf significance testing |
| `STATISTICS.csv` | Performance metrics for every rule (generated on run) |
| `STATISTICS_LW.csv` | Full-sample Sharpe-difference tests |
| `STATISTICS_LW_subperiods.csv` | Subperiod robustness results |

## How to Run

```r
# Install dependencies
install.packages(c("TTR", "quantmod", "PeerPerformance"))

# Set the ticker, dates, and frequency at the top of the script,
# then source it:
source("technical_trading_rules.R")
```

Outputs (CSV tables and diagnostic PDF figures) are written to the working directory.

## Attribution

The core backtesting framework was originally provided by **Prof. Fotis Papailias** as a teaching template. My own contributions extend it with:

- the Ledoit–Wolf (2008) Sharpe-ratio significance testing block (studentised circular block bootstrap with HAC errors),
- the four-subperiod robustness analysis,
- and the application to SPY and GLD with the specific rule parameterisations used in the dissertation.

## References

- Gerritsen, D. F., Bouri, E., Ramezanifar, E., & Roubaud, D. (2020). The profitability of technical trading rules in the Bitcoin market. *Finance Research Letters.*
- Ledoit, O., & Wolf, M. (2008). Robust performance hypothesis testing with the Sharpe ratio. *Journal of Empirical Finance,* 15(5), 850–859.

---

*MSc Finance & Analytics dissertation, King's College London.*
