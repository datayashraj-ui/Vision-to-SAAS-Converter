# /money — Revenue & Cost Report

**Trigger:** founder says "money", "revenue", "how much", "earnings", "costs", "profit", "financials"

## Data to Gather
1. **Stripe** — MRR, today's revenue, MTD revenue, customer count by plan, last 5 transactions
2. **Langfuse** — LLM cost today, LLM cost MTD
3. **Infrastructure cost** — always $0 (Oracle free tier)
4. **Total cost** — Claude Max ($100/mo fixed) + LLM API costs

## Response Format
```
💰 Money Report — [date]

**Revenue:**
MRR: $[X] /mo
This month: $[Y]
Today: $[Z]
Customers: [N] ([a] Starter / [b] Growth / [c] Scale)

**Costs:**
Claude Max: $100/mo (fixed)
LLM APIs: $[X] today / $[Y] this month
Infrastructure: $0 (Oracle free tier)
Total: $[X]/mo

**Profit:** $[MRR - costs]/mo ([X]% margin)

**Top customer:** [name/email] — $[amount]/mo on [plan]
**Latest signup:** [name] signed up [X hours/days] ago on [plan]

[If MRR = $0]: No paying customers yet. Building toward first $49.
[If growing]: Up [X]% from last month 🚀
[If churned]: [X] customers cancelled this month. Reason logged.
```

## Alerts to Include
- If any customer is past-due on payment: "⚠️ [customer] payment failed — [days] ago"
- If LLM costs are unusually high: "⚠️ LLM spend [X]x above daily average"
- If MRR dropped from last check: "📉 MRR down $X — [customer] cancelled [plan]"
- If new milestone hit: "🎉 New milestone: $[X] MRR!"

## If Founder Wants More Detail
"Want a breakdown by customer, or export to CSV? Just say 'yes' or 'export'."
