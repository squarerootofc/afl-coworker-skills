[Index](README.md) · [← Previous: Production readiness](13-production-readiness.md) · [Next: Teardown →](15-teardown.md)

# 14. Next steps

**When:** End of session (3:30 PM)  
**Who:** Customer lead, architect, facilitator  
**Output:** Owners and dates, roadmap

---

## Immediate next steps (Week 1)

| Task | Owner | Due (days after session) | Status |
|------|-------|-----|--------|
| Map real customer data sources (SOW, Customer Program, Pricing, Priorities) | Customer architect | Day +3 | ☐ |
| Provision Production sandbox for pilot | Customer admin + Salesforce account team | Day +3 | ☐ |
| Recruit 10 pilot sellers | Customer sales lead | Day +6 | ☐ |
| Deploy Apex + skill to Sandbox | Customer engineer (driver) | Day +7 | ☐ |
| Assign permission set to pilot sellers | Customer admin | Day +7 | ☐ |
| Run 50 test briefs (10 accounts × 5 sellers) | Pilot sellers | Day +8 | ☐ |
| Collect feedback survey | Facilitator | Day +10 | ☐ |
| Tune skill instructions based on feedback | Customer engineer | Day +13 | ☐ |

---

## Pilot phase (Weeks 2–4)

| Milestone | When (days after session) | Success criteria |
|-----------|------|------------------|
| Pilot kickoff | Day +7 | 10 sellers have access, skill toggled ON |
| Week 1 check-in | Day +14 | ≥ 30 briefs requested, < 5% errors |
| Week 2 check-in | Day +21 | ≥ 60% adoption (6+ sellers used it), feedback collected |
| Pilot retro | Day +24 | Decision: deploy to Production or iterate |

---

## Production rollout (Month 2)

| Phase | Sellers | Start (weeks after session) | Success gate |
|-------|---------|------------|--------------|
| Region 1 (East) | 50 | Week 5 | ≥ 70% adoption, < 3% errors |
| Region 2 (Central) | 50 | Week 6 | Same |
| Region 3 (West) | 100 | Week 8 | Same |
| Full deployment | 500 | Week 10 | ≥ 60% adoption org-wide |

---

## What to build next

Based on the customer's pre-work survey, these are the top 3 use cases after Account Brief:

### 1. Post-Meeting Recap (High priority)

**Use case:** After a customer meeting, seller asks: "Write a follow-up email summarizing what we discussed and the next steps."

**Pattern:** Skill + Apex action (or Flow)
- Skill: interprets the seller's notes (Event record, Slack thread, or typed summary)
- Action: fetches the account context + open opportunities + last brief
- Output: 3-paragraph email draft with action items

**Effort:** 2 weeks (reuses `Get_Account_Context`)

---

### 2. Deal Risk (Medium priority)

**Use case:** Seller asks: "What are the risks on the DEMO Lakeshore East Wing Buildout deal?"

**Pattern:** Skill + Apex action
- Skill: identifies the opportunity by name or Id
- Action: checks: close date < 7 days, no activity in 14 days, no quote, late-stage with low engagement score
- Output: Risk score + 3 specific flags + recommended actions

**Effort:** 3 weeks

---

### 3. Competitive Landscape (Lower priority)

**Use case:** "Who else is Lakeshore talking to? What's our win rate against them?"

**Pattern:** Skill + external API (if competitive data lives outside Salesforce) or Apex
- Skill: fetches competitor mentions from notes, lost opp reasons, and battle cards
- Output: Top 3 competitors for this account + win/loss record + positioning

**Effort:** 4 weeks (depends on data source)

---

## Design questions for the architect

These came up during the session. Decide before the pilot:

1. **Should the brief show owner name?**
   - Useful for: "Who owns this account?"
   - Risk: Multi-owner accounts (split territories)
   - Decision: ☐ Add ownerName to the JSON ☐ Exclude it

2. **How far back should "recent closed opportunities" go?**
   - Current: 365 days
   - Alternatives: 180 days, 90 days, or "last fiscal year"
   - Decision: ☐ Keep 365 ☐ Change to _____

3. **Should the brief compute a spend trend?**
   - Current: Shows trailing12MonthTotal as one number
   - Enhancement: "Lakeshore's furniture spend declined 25% over the last 12 months (from $10k/month to $7.5k/month)"
   - Decision: ☐ Compute trend in Apex ☐ Keep it simple

4. **What happens if account priority is stale (refreshed > 30 days ago)?**
   - Current: Shows it regardless of age
   - Alternatives: Flag it as stale, or exclude it
   - Decision: ☐ Show age ☐ Exclude if > 30 days ☐ Keep as-is

5. **Should the skill work in Slack?**
   - If yes: the customer needs Einstein Copilot for Slack license, and the skill must be enabled for that channel
   - Decision: ☐ Pilot in Salesforce first ☐ Enable Slack from Day 1

---

## Open questions for Salesforce account team

1. **Is Skills generally available in our Production org, or is it still in pilot?**
   - If pilot: when does it GA?
   - If GA: confirm it's enabled

2. **What's the Agentforce consumption model for skills?**
   - Per-conversation, per-agent, or included in license?
   - Are action calls (Apex @InvocableMethod) billed separately?

3. **Can we get a consumption dashboard?**
   - Tokens per day, cost per brief, # of active users
   - Where: Setup > Agentforce Analytics, or custom report?

---

## Golden rules to keep on screen

Write these on a sticky note and keep them visible:

1. **Data in code, reasoning in AI.**  
   Apex computes totals; the skill formats them.

2. **Quote, never recompute.**  
   If the JSON says $64,500, the brief says $64,500.

3. **Test as a seller, not as admin.**  
   Admin tests miss permissions issues.

4. **One brief = one action call.**  
   If you see 5+ tool calls, the skill isn't using the action.

5. **Missing is not an error.**  
   "No SOW on file" is honest. Inventing one is not.

---

## Session recording and artifacts

Archive these for the next builder:

- [ ] This runbook (this repo)
- [ ] Deployed Apex class + test class
- [ ] Skill export (if Salesforce supports exporting skills as metadata)
- [ ] 7 test prompts + expected outputs
- [ ] Pilot feedback survey results
- [ ] Consumption report (first 30 days)

---

## Contact for follow-up

| Role | Name | Email | Slack |
|------|------|-------|-------|
| Customer lead | _____ | _____ | _____ |
| Customer architect | _____ | _____ | _____ |
| Customer engineer (driver) | _____ | _____ | _____ |
| Salesforce facilitator | _____ | _____ | _____ |
| Salesforce account team | _____ | _____ | _____ |

---

**End of runbook.** Thank you for building with Agentforce!

---

## After the session: Cleanup

If you need to remove all demo artifacts and reset the org, see [Teardown (cleanup)](15-teardown.md).

---

[Index](README.md) · [← Previous: Production readiness](13-production-readiness.md) · [Next: Teardown →](15-teardown.md)
