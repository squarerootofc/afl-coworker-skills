[Index](README.md) · [← Previous: Next skill: Next Best Action](10-next-best-action-skill.md) · [Next: Troubleshooting →](12-troubleshooting.md)

# Exercise 4: Test the skill

**Time:** 30 minutes  
**Who:** Test seller (non-admin)  
**Output:** 7 test cases pass

Run these tests **as the test seller** (not as admin). Admin tests miss permissions issues.

---

## Setup

1. Log in as the **test seller** (Setup > Users > Login as the test seller)
2. Open the **Sales app**
3. Open **Coworker**
4. Confirm the skill is toggled ON: **Skills > Browse > Account Brief** shows ON

---

## Test 1: Full brief (Lakeshore)

**Where:** Any page (no record open)

**Prompt:**
```
Brief me on DEMO Lakeshore Medical Group
```

**Expected:**
- 8 sections in order
- Company overview: "DEMO Lakeshore Medical Group. Healthcare. 1,800 employees. lakeshoremedical.example. Chicago, IL."
- Selling strategy: One sentence with the first priority (furniture spend declining)
- Top focus areas: Lists both priorities (furniture + print)
- Contacts: 5 contacts shown (of 7 total)
- Opportunities: Open early-stage (3 opps), late-stage (2 opps), won/lost (3 opps)
- Service insights: 1 open case
- Recent order insights: Trailing 12-month total: **$64,500** (verify this exact figure)
- Contract details: SOW Active (ends ~6 months), Customer Program Healthcare (renews ~90 days), 5 pricing agreements
- No "No X on file" lines
- Ends with one follow-up question

**Pass criteria:**
- ✅ All 8 sections present
- ✅ Trailing 12-month total = $64,500 (not $64,000 or $65,000)
- ✅ No raw record IDs shown (all names are links)
- ✅ One follow-up question at the end

---

## Test 2: Sparse account (Pinecrest)

**Where:** Any page

**Prompt:**
```
Prep me for my meeting with DEMO Pinecrest School District
```

**Expected:**
- Short brief
- Company overview: "DEMO Pinecrest School District. Education. 320 employees. No website. Portland, OR."
- "No account priority on file." in both Selling strategy and Top focus areas
- "No contacts on file."
- "No closed opportunities on file."
- "No quote on file." (or just missing from lastQuote)
- "No orders in the last 12 months."
- "No open cases on file."
- "No SOW on file."
- "No Customer Program on file."
- "No pricing on file."
- 1 open opportunity shown (Classroom Furniture, Prospecting, $14,000)
- No question asked **before** the brief (only after)

**Pass criteria:**
- ✅ Brief is short (only 1 opportunity, rest missing)
- ✅ Lists 9 "No X on file" lines (for all missing sources)
- ✅ No hallucinated data
- ✅ One follow-up question

---

## Test 3: No account priority (Ridgeway)

**Where:** Any page

**Prompt:**
```
What should I know about DEMO Ridgeway Logistics?
```

**Expected:**
- Company overview: "DEMO Ridgeway Logistics. Transportation. 650 employees. ridgewaylogistics.example. Dallas, TX."
- "No account priority on file." in both Selling strategy and Top focus areas
- Contacts: 4 contacts shown
- Opportunities: 4 open (1 early-stage, 3 late-stage), 1 won
- Service insights: 1 open case (Missing print order)
- Recent order insights: Trailing 12-month total: **$15,900** (verify this)
- Contract details: SOW Active, Customer Program Commercial, 3 pricing agreements

**Pass criteria:**
- ✅ "No account priority on file" appears twice
- ✅ Trailing 12-month total = $15,900
- ✅ SOW and Customer Program both present
- ✅ No invented priorities

---

## Test 4: Ambiguous (Harbor Supply)

**Where:** Any page

**Prompt:**
```
Brief me on DEMO Harbor Supply Co
```

**Expected:**
- Lists both Harbor accounts by name as clickable links:
  * DEMO Harbor Supply Co (Seattle)
  * DEMO Harbor Supply Co (Tacoma)
- Asks: "Which account did you mean?"
- **No brief yet**

**Follow-up (in the same conversation):**
```
The first one
```

**Expected after follow-up:**
- Produces a brief for the Seattle Harbor account
- 1 contact, 1 opportunity
- Most other sources show "No X on file"
- Ends with one follow-up question

**Pass criteria:**
- ✅ First response lists 2 candidates and asks which one
- ✅ No brief until the seller clarifies
- ✅ Second response produces a brief for the chosen account

---

## Test 5: Record page context

**Where:** Navigate to the **DEMO Lakeshore Medical Group Account page** (Accounts tab > search "Lakeshore" > open the record)

**Prompt:**
```
Brief me on this account
```

**Expected:**
- Lakeshore brief appears (same as Test 1)
- **No "Which account?" question** — the skill uses the record Id from page context

**Pass criteria:**
- ✅ Brief appears without asking for an account name
- ✅ Same content as Test 1

---

## Test 6: Should NOT run

Test each of these (open a **new conversation** for each):

1. `Recap my meeting with Lakeshore`
2. `What's the price for bulk paper orders?`
3. `Create a task to call Lakeshore on Friday`

**Expected:** Skill does **not** run for any of these.

**Pass criteria:**
- ✅ Coworker answers from built-in tools or says "I can't do that"
- ✅ The skill does not run (check Skills tab or reasoning panel to confirm)

---

## Test 7: No carry-over

**In ONE conversation:**

1. `Brief me on DEMO Lakeshore Medical Group`
2. Wait for the brief, then: `Now brief me on DEMO Ridgeway Logistics`

**Expected:**
- The Ridgeway brief has **no Lakeshore figures**:
  * No $64,500 (should be $15,900)
  * No David Chen or James Baxter (should be Andre Beaumont, Marcus Delgado, etc.)
  * No Waiting Room Upgrade opportunity

**Pass criteria:**
- ✅ Each brief shows only its own account's data
- ✅ No figures or names carried over from the first brief to the second

---

## Test summary table

| # | Test | Pass | Notes |
|---|------|------|-------|
| 1 | Lakeshore full brief | ☐ | Check $64,500 exactly |
| 2 | Pinecrest sparse | ☐ | 9 "No X on file" lines |
| 3 | Ridgeway no priority | ☐ | Check $15,900 exactly |
| 4 | Harbor ambiguous | ☐ | Asks once, then briefs |
| 5 | Page context | ☐ | No "which account?" on record page |
| 6 | Should not run (3 negatives) | ☐ | Skill doesn't fire |
| 7 | No carry-over | ☐ | No Lakeshore data in Ridgeway brief |

---

## If a test fails

See [Troubleshooting guide](12-troubleshooting.md).

Common issues:
- **Skill doesn't run:** Check toggle is ON, Target Agent = Coworker, description matches
- **Seller can't run action:** Add Apex class access to permission set (Exercise 2 Step 4)
- **Wrong figures:** Check the Apex query (orders date range, MAX_OPPS limit)
- **Page context doesn't work:** Coworker may not be passing recordId yet (use name-based prompts)

---

## What you have now

- A working skill tested by a seller (not just admin)
- 7 test cases pass
- Confidence that the skill handles full, sparse, and ambiguous cases

**Next:** [Troubleshooting guide](12-troubleshooting.md) or [Production readiness](13-production-readiness.md)

---

[Index](README.md) · [← Previous: Next skill: Next Best Action](10-next-best-action-skill.md) · [Next: Troubleshooting →](12-troubleshooting.md)
