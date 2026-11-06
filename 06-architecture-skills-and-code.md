[Index](README.md) · [← Previous: Session plan](05-session-plan.md) · [Next: Exercise 1: Seed data →](07-exercise-seed-data.md)

# 6. Architecture: Skills + Code

This session uses a **two-layer architecture**: Apex for data, a skill for reasoning.

---

## The pattern

```
┌─────────────────────────────────────────────────────────────┐
│  Seller                                                     │
│  "Brief me on DEMO Lakeshore Medical Group"                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Agentforce Coworker (built-in)                            │
│  Routes by matching skill description                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  "Account Brief" skill (Exercise 3)                        │
│  Plain-language instructions:                               │
│  - When to call Get_Account_Context                         │
│  - How to format the 8-section brief                        │
│  - How to handle errors (ambiguous, not found)              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Get_Account_Context (Apex action, Exercise 2)              │
│  @InvocableMethod that:                                     │
│  - Takes recordId or accountName                            │
│  - Runs 14 SOQL queries (bulkified)                         │
│  - Returns one JSON string                                  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Data layer (Exercise 1)                                    │
│  - Standard: Account, Contact, Opportunity, Quote,          │
│    Order, Case                                              │
│  - Custom: Statement_of_Work__c, Customer_Program__c,       │
│    Price_Agreement__c, Account_Priority__c                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Why two layers?

| Layer | What it does | Why code | Why not LLM |
|-------|--------------|----------|-------------|
| **Data (Apex)** | Fetch, filter, sort, aggregate | Deterministic, fast (200ms), testable | LLM can hallucinate totals, skip filters, or query in the wrong order |
| **Reasoning (Skill)** | Format, route, handle ambiguity | Natural language understanding, adapts to seller phrasing | Code can't interpret "prep me for my call" or "what's going on at X" |

---

## Why a skill (not a separate agent)?

A **skill** is built inside Coworker using Skill Builder. Once it's toggled on, Coworker can call it automatically when the description matches.

A **separate agent** (like a standalone `Account_Brief.agent` subagent) would require Setup UI wiring to connect it to Coworker. That wiring step:
- Is manual (not code-deployable)
- Can fail silently (agent is Active but Coworker can't call it)
- Adds a third entity to manage (Coworker + subagent + wiring)

**Skills eliminate the wiring problem.**

---

## Why Apex (not inline queries)?

The skill COULD instruct Coworker to query 10+ objects natively, then sum Order.TotalAmount in the LLM's head.

**Problems with that approach:**
1. **10+ tool calls** instead of 1 (3–5 seconds instead of 200ms)
2. **The LLM does math** (risk of hallucinated totals)
3. **Business rules become prompt instructions** (`Status__c = 'Active'`, `LIMIT 5`, `ORDER BY CloseDate`)
4. **Non-deterministic** (CRM search results can vary)
5. **No unit testing** (can't assert exact output for a given input)

**The Apex action:**
- Returns `trailing12MonthTotal = 64500` exactly as computed
- Encodes "only active SOWs" and "last 5 opps" in SOQL, not prompts
- Same account → same JSON → same brief, every time
- 369-line test class with 10 test methods

---

## What the Apex action returns

One JSON string with these keys:

| Key | Type | Example |
|-----|------|---------|
| `account` | object | `{id, name, industry, website, numberOfEmployees, billingCity, billingState}` |
| `priority` | array | account priorities by rank: `[{rank, reason, action}]` |
| `openOpps` | array | Up to 5: `[{id, name, stage, amount, closeDate}]` |
| `recentClosedOpps` | array | Closed last year, up to 5 |
| `lastQuote` | object or null | Most recent quote |
| `orders` | object | `{trailing12MonthTotal, byMonth: [{id, effectiveDate, totalAmount, product}]}` |
| `openCases` | array | `[{id, subject, priority, status}]` |
| `sow` | object or null | Active Statement of Work |
| `customerProgram` | object or null | Customer Program with renewal date |
| `pricing` | array | Price agreements: `[{productClass, tier, discountPct}]` |
| `contacts` | array | Up to 5: `[{id, name, title, email}]` |
| `missing` | array | Every empty source: `["priority", "sow", "contacts"]` |

**Error cases:**
- `{"error":"ACCOUNT_REQUIRED"}` — no input provided
- `{"error":"ACCOUNT_AMBIGUOUS", "candidates":[{id, name}]}` — 2+ matches
- `{"error":"ACCOUNT_NOT_FOUND"}` — 0 matches

---

## The skill's job

1. **Call the action** (pass recordId from page context or accountName from the seller's message)
2. **Handle errors:**
   - ACCOUNT_AMBIGUOUS → list candidates, ask "Which account?"
   - ACCOUNT_REQUIRED → ask "Which account would you like me to brief?"
   - ACCOUNT_NOT_FOUND → ask "Could you check the spelling?"
3. **Format the 8-section brief** using only the JSON data
4. **End with one follow-up question** specific to this account

**The skill never queries Salesforce directly.** It just formats what the Apex returns.

---

## Industry analogy

| Pattern | What we're building |
|---------|---------------------|
| Backend API + Frontend | Apex action (returns JSON) + Skill (renders it) |
| Database view + Report | Apex (pre-joins and filters) + Skill (displays) |
| Stored procedure + App | Apex (aggregates data) + Skill (formats) |

This is the **standard separation** between data access and presentation.

---

## What we're NOT building

- ❌ A separate employee agent (`Account_Brief.agent`)
- ❌ A skill that does its own SOQL queries
- ❌ An action-only approach (returns raw JSON to Coworker without formatting)

We're building the **skills + code pattern** that Salesforce recommends for grounded, deterministic agents.

---

[Index](README.md) · [← Previous: Session plan](05-session-plan.md) · [Next: Exercise 1: Seed data →](07-exercise-seed-data.md)
