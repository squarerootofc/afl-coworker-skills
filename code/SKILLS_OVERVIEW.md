# Skills Overview

## Two Skills, One Apex Action

This package provides **two complementary skills** using a single Apex deployment:

```
┌─────────────────────────────────────────────────────────────┐
│                    Apex Foundation                          │
│           AccountContextService.cls                         │
│        (Deployed Once - Queries 12 Data Sources)           │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ JSON Response
                           ▼
        ┌──────────────────┴──────────────────┐
        │                                     │
   ┌────▼─────┐                       ┌──────▼────────┐
   │ SKILL 1  │                       │   SKILL 2     │
   │ Account  │                       │  Next Best    │
   │  Brief   │                       │    Action     │
   └──────────┘                       └───────────────┘
   "What's                            "What should
   happening?"                        I do?"
```

## Skill 1: Account Brief (Foundation)

**Purpose**: Retrieve comprehensive account data  
**User Need**: "What's the current state of this account?"

### Configuration
- **Deployment**: Apex action required
- **Action**: "Get Account Context"
- **Input**: Account ID or name
- **Output**: Raw JSON with all account data

### Example Prompts
- "Get account brief for DEMO Lakeshore Medical Group"
- "Show me the account context for Lakeshore"
- "What's the current state of Ridgeway Logistics?"

### What It Returns
```json
{
  "account": { "name": "...", "industry": "...", ... },
  "contacts": [...],
  "openOpps": [...],
  "recentClosedOpps": [...],
  "orders": {
    "trailing12MonthTotal": 98750,
    "byMonth": [...]
  },
  "openCases": [...],
  "missing": ["priority", "sow", ...]
}
```

### Value
✅ Single call retrieves all account data  
✅ Eliminates multiple SOQL queries from agent  
✅ Consistent data structure  
✅ Grounded responses (no hallucination)

---

## Skill 2: Next Best Action (Extension)

**Purpose**: Analyze account data and recommend prioritized actions  
**User Need**: "What should I focus on?"

### Configuration
- **Deployment**: No code (reuses Skill 1's Apex action)
- **Action**: Same "Get Account Context" action
- **Method**: Agent reasoning via prompts
- **Setup Time**: 30-60 minutes

### Example Prompts
- "What should I focus on for DEMO Lakeshore Medical Group?"
- "Give me priorities for Ridgeway Logistics"
- "Top 3 actions for Lakeshore this week"
- "What are the urgent items for this account?"

### What It Returns
```
Here are your top 3 priorities for Lakeshore Medical Group:

1. 🎯 Accelerate 5 near-term opportunities (Next 2 weeks)
   Why: $143.5k pipeline closing in 15-60 days
   Evidence: 
   - $65k Emergency Room Upgrade (45 days, Needs Analysis)
   - $18k Waiting Room Seating (15 days, Value Proposition)
   Impact: Quick revenue realization
   Next step: Schedule check-ins this week

2. ⚠️ Address declining spend pattern (This week)
   Why: Order volume down 25% over 12 months
   Evidence: Orders decreased from $10k/month → $7.5k/month
   Impact: Risk to $340k annual relationship
   Next step: Schedule account review; resolve open delivery case

3. 🚀 Leverage recent wins for expansion (This month)
   Why: Strong trust from recent $120k renewal
   Evidence: 2 closed-won deals totaling $148k (last 3 months)
   Impact: Warm relationship, receptive to new offerings
   Next step: Present complementary products/services

Account Health: 7.5/10 - Strong pipeline, declining spend needs attention
```

### How It Works

```
User Prompt: "What should I focus on for Lakeshore?"
      ↓
Agent (with instructions):
  1. Call Get_Account_Context
  2. Analyze JSON for patterns:
     - Order trend (increasing/flat/declining)
     - Opportunity urgency (close dates)
     - Open issues (cases)
     - Engagement (contacts, recent wins)
  3. Prioritize by:
     - URGENCY: Days to deadline, severity
     - IMPACT: Revenue, relationship risk
     - EFFORT: Quick win vs. complex
  4. Format with evidence and next steps
      ↓
Natural Language Response (prioritized actions with reasoning)
```

### Value
✅ Actionable recommendations (not just data)  
✅ Prioritized by urgency + impact  
✅ Evidence-based (cites specific numbers)  
✅ Concrete next steps  
✅ No additional code deployment  
✅ Easy to iterate (just update prompts)

---

## Comparison

| Aspect | Account Brief | Next Best Action |
|--------|--------------|------------------|
| **Question** | "What's happening?" | "What should I do?" |
| **Output** | Raw data | Prioritized recommendations |
| **Format** | JSON | Natural language |
| **Deployment** | Apex required | Prompt configuration only |
| **Setup Time** | 1-2 hours | 30-60 minutes |
| **Use Case** | Data retrieval | Decision support |
| **Value** | Comprehensive context | Actionable priorities |

## User Workflow

### Scenario 1: Seller preparing for call

**Old way** (multiple queries):
1. "Tell me about Lakeshore" → General info
2. "Show me opportunities" → Opportunity list
3. "Any urgent items?" → Cases, dates
4. "What should I focus on?" → Generic advice

**Total**: 4 prompts, ~20-30 seconds

**New way** (single query):
1. "What should I focus on for Lakeshore?" → Top 3 priorities with evidence

**Total**: 1 prompt, ~5-8 seconds

**Result**: 60-70% fewer tokens, 70-85% faster

### Scenario 2: Manager reviewing team's accounts

**Old way**:
- Check each account manually
- Read through opportunities
- Scan cases
- Review order history
- Make mental notes
- Decide priorities

**Total**: 10-15 minutes per account

**New way**:
- "Give me priorities for [account name]"
- Review recommendations
- Take action

**Total**: 2-3 minutes per account

**Result**: 80% time savings

## Technical Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                 User Prompt                                 │
│  "What should I focus on for Lakeshore Medical Group?"     │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Agentforce Agent                               │
│  (with Next Best Action instructions)                       │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Calls action
                           ▼
┌─────────────────────────────────────────────────────────────┐
│         AccountContextService.cls                           │
│  @InvocableMethod: Get Account Context                     │
│                                                             │
│  Bulkified Queries:                                         │
│  1. Account          7. Orders (12mo)                       │
│  2. Contacts         8. OrderItems                          │
│  3. Opportunities    9. Cases (open)                        │
│  4. Opportunities    10. Statement_of_Work__c               │
│     (open)           11. Customer_Program__c                │
│  5. Opportunities    12. Price_Agreement__c                 │
│     (closed)                                                │
│  6. Quotes                                                  │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Returns JSON
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Agent Reasoning Layer                          │
│  (Next Best Action instructions)                            │
│                                                             │
│  Analyzes:                                                  │
│  - Order trends (increasing/flat/declining)                 │
│  - Opportunity pipeline (value, stages, close dates)        │
│  - Open issues (cases, delivery problems)                   │
│  - Relationship health (contacts, recent activity)          │
│  - Data gaps (missing array)                                │
│                                                             │
│  Prioritizes by:                                            │
│  - Urgency (days to deadline, severity)                     │
│  - Impact (revenue, relationship risk)                      │
│  - Effort (quick win vs. complex)                           │
│                                                             │
│  Formats with:                                              │
│  - Action statement                                         │
│  - Why it matters (pattern observed)                        │
│  - Evidence (specific numbers)                              │
│  - Impact (business outcome)                                │
│  - Next step (concrete action)                              │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Generates
                           ▼
┌─────────────────────────────────────────────────────────────┐
│         Natural Language Response                           │
│  Top 3 priorities with evidence and next steps              │
└─────────────────────────────────────────────────────────────┘
```

## Cost Comparison

### Account Brief Only
- Apex execution: ~500 tokens
- JSON response: ~2,000-5,000 tokens
- **Total**: ~2,500-5,500 tokens per query

### Next Best Action (includes Account Brief)
- Apex execution: ~500 tokens
- JSON response: ~2,000-5,000 tokens
- Agent reasoning: ~1,500-3,000 tokens
- **Total**: ~4,000-8,500 tokens per query

### ROI Calculation
**Old flow** (no skills):
- 3-4 separate queries
- Multiple SOQL queries per turn
- Follow-up questions
- **Estimated**: ~15,000-25,000 tokens

**New flow** (Next Best Action):
- 1 query with full analysis
- **Cost**: ~4,000-8,500 tokens

**Savings**: 60-75% fewer tokens + better user experience

## Getting Started

### Phase 1: Deploy Account Brief (1-2 hours)
```bash
cd code
./deploy.sh your-org-alias
./validate.sh your-org-alias
```

Test:
```
"Get account brief for DEMO Lakeshore Medical Group"
```

### Phase 2: Configure Next Best Action (30-60 minutes)

1. Read `NEXT_BEST_ACTION_GUIDE.md`
2. Add topic to your agent
3. Add sample utterances
4. Copy instructions
5. Test with DEMO accounts

Test:
```
"What should I focus on for DEMO Lakeshore Medical Group?"
```

### Phase 3: Iterate and Measure

Track:
- Usage frequency
- Follow-through on recommendations
- Outcome (did actions lead to opportunity progression?)
- User feedback

Adjust instructions based on results.

## Summary

**What You Get**:
1. ✅ Account Brief skill (comprehensive data retrieval)
2. ✅ Next Best Action skill (intelligent recommendations)

**What You Deploy**:
- 1 Apex class with test coverage
- 4 custom objects
- 1 permission set
- 81 seed records

**Configuration Effort**:
- Apex deployment: 1-2 hours (one time)
- Next Best Action: 30-60 minutes (prompt engineering)

**Result**: 
Two powerful skills that answer "What's happening?" and "What should I do?" - delivering comprehensive, actionable intelligence grounded in real account data.

---

**Package**: Account Brief + Next Best Action  
**Code Required**: 1 Apex class (reused by both skills)
