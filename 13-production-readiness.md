[Index](README.md) · [← Previous: Troubleshooting](12-troubleshooting.md) · [Next: Next steps →](14-next-steps.md)

# 13. Production readiness

**When:** After Test 7 passes  
**Who:** Customer lead + architect + account team  
**Output:** Checklist, real data mapping, consumption estimate

---

## Production readiness checklist

### Code quality

- [ ] All 8 Apex tests pass with ≥ 90% coverage
- [ ] Apex uses `WITH USER_MODE` on every SOQL query
- [ ] Apex handles null safely (no `NullPointerException` in logs)
- [ ] Skill instructions quote totals exactly ("never recompute")
- [ ] Skill handles all 3 error cases (REQUIRED, NOT_FOUND, AMBIGUOUS)
- [ ] No raw record IDs shown in briefs (all names are links)
- [ ] No carry-over between accounts in the same conversation

### Data mapping

Real customer data is different from the seed data. Map each source:

| Seed object | Production object | Notes |
|-------------|-------------------|-------|
| Statement_of_Work__c | ??? | Where does SOW data live in production? Custom object, external system, or Salesforce standard? |
| Customer_Program__c | ??? | |
| Price_Agreement__c | ??? | |
| Account_Priority__c | ??? | Does the priority/recommendation feed write to Salesforce, or is this an API call? |
| Order | Order | Standard object, should work as-is |
| Quote | Quote | |
| Opportunity | Opportunity | |
| Contact | Contact | |
| Case | Case | |

**Action item:** For each "???" above, the architect provides:
- Object API name (or external API endpoint)
- Required fields
- Filter criteria (e.g., "only Active SOWs", "only account priorities refreshed in last 30 days")

### Security

- [ ] All PII fields are excluded from the JSON (no SSN, no credit card, no personal notes)
- [ ] Apex respects sharing rules (`WITH USER_MODE`)
- [ ] Permission set grants only read access (no create, edit, delete)
- [ ] Skill is shared only with authorized sellers (not all users)
- [ ] Sandbox testing complete before deploying to production

### Performance

- [ ] Action completes in < 500ms for a typical account
- [ ] Action uses ≤ 14 SOQL queries (check Governor Limits in logs)
- [ ] Skill produces a brief in < 2 seconds total (action + LLM formatting)
- [ ] No timeout errors in 50 consecutive test runs

### User experience

- [ ] Brief is useful to sellers (validated by seller champion)
- [ ] No hallucinated figures (all totals match SOQL)
- [ ] Seller can run the skill from Account/Contact/Opp pages and by name
- [ ] "No X on file" lines are clear and actionable (not error messages)
- [ ] Follow-up question is specific to the account (not generic)

---

## Consumption estimate

### Model: Assumptions for Claude Sonnet 3.5 (or equivalent)

| Metric | Value | Notes |
|--------|-------|-------|
| **Input tokens per brief** | ~1,500 | Skill instructions (800) + action JSON (500) + conversation context (200) |
| **Output tokens per brief** | ~800 | 8-section brief with 5 contacts, 5 opps, 12 orders, etc. |
| **Total tokens per brief** | ~2,300 | Input + output |
| **Cost per 1M input tokens** | ~$3.00 | Check current Agentforce pricing |
| **Cost per 1M output tokens** | ~$15.00 | |
| **Cost per brief** | ~$0.016 | (1,500 × $3 / 1M) + (800 × $15 / 1M) |

### Projected usage

| Scenario | Briefs per day | Briefs per month | Monthly cost |
|----------|----------------|------------------|--------------|
| Pilot (10 sellers) | 50 | 1,500 | ~$24 |
| Rollout (100 sellers) | 500 | 15,000 | ~$240 |
| Full adoption (500 sellers) | 2,500 | 75,000 | ~$1,200 |

**Note:** These are illustrative. Actual cost depends on:
- Agentforce licensing model (per-conversation, per-agent, or included in license)
- Average JSON size (more data = more input tokens)
- How often sellers ask for briefs (1/day, 5/day, 10/day)

### Cost drivers

| Factor | Impact | How to reduce |
|--------|--------|---------------|
| JSON size | +500 tokens if every account has 12 orders + 9 opps | Cap lists at 5 items, exclude old data |
| Skill instructions length | +200 tokens per 1,000 characters | Keep instructions concise, remove examples |
| Conversation context | +100 tokens per prior turn | Use new conversations for each brief (no multi-turn) |
| Recomputation (if LLM does math) | +200 tokens + risk of errors | Always compute in Apex, quote exactly |

---

## Deployment plan

### Phase 1: Pilot (Weeks 1–2)

- [ ] Deploy to **Sandbox** (not Production yet)
- [ ] 10 volunteer sellers
- [ ] Account Brief skill shared with pilot group
- [ ] Permission set assigned
- [ ] Feedback survey after 2 weeks
- [ ] Track: # briefs requested, # successful, # errors, avg latency

### Phase 2: Rollout (Weeks 3–6)

- [ ] Deploy to **Production**
- [ ] 100 sellers (one region or team)
- [ ] Monitor consumption daily
- [ ] Weekly feedback sessions
- [ ] Tune skill instructions based on feedback

### Phase 3: Full adoption (Month 2+)

- [ ] All 500 sellers
- [ ] Add metrics dashboard (briefs/day, cost/brief, satisfaction score)
- [ ] Build next skill (e.g., "Post-Meeting Recap", "Competitive Landscape")

---

## Risks and mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Hallucinated totals | Low | High | Apex computes all totals, skill instructions say "quote exactly" |
| Seller sees competitor's data | Low | Critical | WITH USER_MODE respects sharing rules |
| Skill doesn't route | Medium | High | Test description with 20 real seller phrasings before rollout |
| Action times out (>10s) | Low | Medium | Cap lists at 5, exclude data older than 12 months |
| Skills not enabled in production | Medium | Critical | Confirm with account team before pilot |
| Cost exceeds budget | Low | Medium | Set a daily brief cap per seller (e.g., 10/day) |

---

## Success metrics (30 days post-launch)

| Metric | Target | How to measure |
|--------|--------|----------------|
| Adoption rate | ≥ 60% of sellers use it at least once/week | Count unique users in Agentforce logs |
| Accuracy | ≥ 95% of briefs have no hallucinated figures | Spot-check 50 briefs, compare to SOQL |
| Latency | ≥ 90% of briefs complete in < 2 seconds | Check action logs (Apex debug) + Agentforce trace |
| Satisfaction | ≥ 4/5 average rating | Seller survey |
| Priority adoption | +20% sellers who mention account priorities in calls | Track keyword "priority" in call transcripts |

---

## What happens next

See [Next steps](14-next-steps.md) for:
- Named owners
- Pilot dates
- What to build next (Post-Meeting Recap, Competitive Landscape, Deal Risk)

---

[Index](README.md) · [← Previous: Troubleshooting](12-troubleshooting.md) · [Next: Next steps →](14-next-steps.md)
