[Index](README.md) · [← Previous: Exercise 3: Build skill](09-exercise-build-skill.md) · [Next: Exercise 4: Test skill →](11-exercise-test-skill.md)

# 10. Next Skill Recommendation: Next Best Action

> **Configuration guide:** [code/NEXT_BEST_ACTION_GUIDE.md](code/NEXT_BEST_ACTION_GUIDE.md) shows how to build this with prompts only, reusing `Get_Account_Context`.

## Context

Typical situation this skill is designed for:
- **Current Challenge**: An existing sales assistant agent needs performance improvement
- **Pain Points**:
  - Latency issues (first token and full response time)
  - Weak first-turn recommendations (requires follow-up questions)
  - Unclear whether to use subagents vs. actions
  - Need to ground responses in account data BEFORE asking follow-ups
- **Data Sources**: Opportunities, Quotes, Orders, SOW, Customer Programs, Pricing, account-priority recommendations
- **Success Metrics**:
  1. Reduce seller prep time with first-response insights
  2. Higher seller adoption and follow-through on account-priority recommendations
  3. Increase opportunity creation, pipeline progression, conversion

## Recommended Skill: **Next Best Action Recommender**

### The Problem It Solves

Sellers often get system-generated account recommendations but:
- They don't know **why** each action is recommended
- They don't know the **priority** when multiple actions are suggested
- They can't see the **ROI/impact** of taking each action
- There's low **follow-through** on recommendations (one of their stated success metrics)

### What It Does

**"Next Best Action Recommender"** analyzes the account context and account priorities to:
1. **Rank** account-priority recommendations by potential impact (revenue opportunity, risk mitigation, relationship building)
2. **Explain** why each action matters for THIS specific account
3. **Provide context** (recent orders declining, contract renewal coming, open case, etc.)
4. **Suggest timing** (do this week, before renewal, urgent)
5. **Show evidence** (quotes the data points that justify the recommendation)

### Example Output

```
📊 Top 3 Actions for DEMO Lakeshore Medical Group

1. URGENT: Schedule furniture contract review (Rank: 1)
   Why now: Declining spend at 3 sites - furniture orders down 25% over last 12 months
            (dropped from $10k/month to $7.5k/month)
   Evidence: 12 orders totaling $98,750 (trailing 12mo)
   Risk: $120k contract up for renewal in 6 months
   Action: Offer site-level furniture review
   Timeline: This week

2. Propose managed print review (Rank: 2)
   Why now: Print volume flat while other spending shows engagement
   Evidence: Steady $2k/month print orders, but no growth
   Opportunity: Cross-sell into managed services
   Timeline: Before EOQ

3. Address open delivery delay case
   Why now: Open medium-priority case could impact satisfaction
   Evidence: "Furniture delivery delay" - open since [date]
   Risk: Could affect renewal decision
   Timeline: Resolve before contract review meeting
```

### Technical Architecture

**Apex Action: `GetNextBestActions`**

**Input**:
- `accountId` (Id) - Account to analyze
- `maxActions` (Integer, default 5) - How many recommendations to return

**Data Sources** (already available from Account Brief):
- Account_Priority__c records (ranked priorities)
- Opportunity trends (open/closed, amounts)
- Order trends (12-month spend patterns)
- Cases (open issues)
- Statement_of_Work__c (contract dates, status)
- Customer_Program__c (renewal dates)
- Price_Agreement__c (discount tiers, pricing)

**Logic**:
1. Get account priorities (already ranked)
2. Enrich each with context from other data sources:
   - Link priority "declining furniture spend" → Order data showing the trend
   - Link priority "print volume flat" → Order data showing flat pattern
   - Add urgency factors (SOW end date, Customer Program renewal, open cases)
3. Calculate impact scores:
   - Revenue at risk (SOW amount, trailing 12mo orders)
   - Time sensitivity (days until renewal, case age)
   - Relationship health (case count, order frequency)
4. Return ranked, contextualized actions with evidence

**Output JSON**:
```json
{
  "topActions": [
    {
      "rank": 1,
      "priority": {
        "reason": "Declining furniture spend at 3 sites",
        "recommendedAction": "Offer site-level furniture review"
      },
      "urgency": "HIGH",
      "timing": "This week",
      "evidence": {
        "orderTrend": "DOWN",
        "trailing12MonthTotal": 98750,
        "percentChange": -25,
        "monthlyAverage": 8229,
        "peakMonth": 10000,
        "currentMonth": 7500
      },
      "context": {
        "sowEndDate": "2027-05-05",
        "daysUntilRenewal": 180,
        "sowAmount": 120000,
        "revenueAtRisk": "HIGH"
      },
      "reasoning": "12-month furniture spend declining 25% ($10k→$7.5k/mo) with $120k contract renewal in 6 months. Site review now prevents further erosion."
    }
  ],
  "accountHealth": {
    "score": 7.2,
    "revenueRisk": "MEDIUM",
    "engagementTrend": "DECLINING",
    "openIssues": 1
  }
}
```

## Why This Skill After Account Brief

**Natural Progression**:
1. **Account Brief** (done) = "What's happening?" → Raw data dump
2. **Next Best Action** (proposed) = "What should I do?" → Prioritized, contextualized recommendations

**Addresses Common Customer Needs**:
- ✅ Improves first-turn recommendations (grounded in data)
- ✅ Reduces follow-up questions (action is clear)
- ✅ Increases follow-through on account-priority recommendations (shows WHY and impact)
- ✅ Can measure impact (track which actions lead to opp creation/progression)
- ✅ Low latency (reuses Account Brief data, just adds ranking logic)

**Seller Workflow**:
```
Seller: "What should I focus on for Lakeshore Medical?"
          ↓
Sales Agent: [calls Account Brief skill]
          ↓ (has all account data)
Sales Agent: [calls Next Best Action skill]
          ↓
Response: "Here are your top 3 priorities with Lakeshore:
          1. Schedule contract review this week (declining spend, renewal in 6mo)
          2. Propose managed print review (flat volume, cross-sell opportunity)
          3. Resolve delivery delay case (open issue affecting satisfaction)"
```

## Implementation Effort

**Low** - Reuses Account Brief infrastructure:
- ✅ Custom objects already exist (Account_Priority__c, etc.)
- ✅ Permission set already grants access
- ✅ Seed data already loaded
- ✅ Apex pattern established

**New Code Required**:
- ~300 lines Apex for ranking/scoring logic
- ~200 lines Apex test class
- Reuses existing queries from AccountContextService

**Estimated Time**: 4-6 hours
- 2 hours: Apex action with scoring algorithm
- 1 hour: Test class
- 1 hour: Skill configuration and testing
- 1-2 hours: Polish and edge cases

## Alternative Skill Ideas

### Option 2: **Contract Renewal Health Score**
Predict renewal risk based on:
- Order frequency and trend
- Case volume
- SOW/Customer Program dates
- Last activity date
- Return a health score (1-10) with risk factors

**Pro**: Very focused, measurable impact on renewals  
**Con**: Narrower use case than Next Best Action

### Option 3: **Competitive Intelligence Tracker**
Track mentions of competitors in:
- Opportunity notes
- Case descriptions  
- Activity history
- Return competitive threats and win/loss patterns

**Pro**: Unique value, hard to get elsewhere  
**Con**: Requires data fields that may not exist (competitor tracking)

### Option 4: **Cross-Sell Opportunity Finder**
Analyze current purchases vs. full product catalog:
- What they're buying (Orders, OrderItems)
- What they're NOT buying (Product2 catalog)
- Price Agreement gaps (product classes with no agreement)
- Return cross-sell opportunities with justification

**Pro**: Direct revenue impact, uses existing data  
**Con**: Requires full product catalog and usage patterns

## Recommendation

**Build Next Best Action Recommender first** because:
1. ✅ Directly addresses a common success metric ("follow-through on account-priority recommendations")
2. ✅ Natural extension of Account Brief skill
3. ✅ Reuses all existing infrastructure
4. ✅ Low implementation effort (~4-6 hours)
5. ✅ High perceived value to sellers (tells them what to do, not just what's happening)
6. ✅ Measurable impact (track action → outcome conversion)
7. ✅ Can be extended later with ML scoring if it proves valuable

**Then consider**:
- Contract Renewal Health Score (if renewals are a priority)
- Cross-Sell Opportunity Finder (if revenue expansion is the focus)

---

## Quick Start for Next Best Action Skill

```bash
# Copy the Account Brief foundation
cp -r code next-best-action/code

# Create new Apex class: NextBestActionService
# Reuse: AccountContextService queries
# Add: Scoring/ranking algorithm, urgency calculation, evidence linking

# Deploy
cd next-best-action/code
./deploy.sh your-org

# Test
"What should I focus on for DEMO Lakeshore Medical Group?"
```

---

**Next Skill**: Next Best Action Recommender → prioritize and contextualize account-priority recommendations

---

[Index](README.md) · [← Previous: Exercise 3: Build skill](09-exercise-build-skill.md) · [Next: Exercise 4: Test skill →](11-exercise-test-skill.md)
