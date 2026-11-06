[Index](README.md) · [← Previous: Exercise 4: Test skill](11-exercise-test-skill.md) · [Next: Production readiness →](13-production-readiness.md)

# 12. Troubleshooting guide

Common issues and fixes during the build session.

---

## Skill doesn't run

| Symptom | Cause | Fix |
|---------|-------|-----|
| Coworker answers from built-in tools instead of the skill | Description too narrow or doesn't match the phrasing | Edit the skill description to include the seller's exact words (e.g., add "summarize", "research", "what's going on") |
| Skill never appears in the Skills list | Target Agent not set to Coworker | Edit skill settings, set Target Agent = **Coworker**, save |
| Skill exists but toggle is greyed out | User doesn't have Create/Use Skills permission | Admin: grant the user Skills permission, or share the skill explicitly |
| Coworker says "I don't have access to that skill" | Skill not shared, or user didn't toggle it ON in Browse | Admin: share the skill. User: go to Skills > Browse > toggle ON |

---

## Action fails

| Symptom | Cause | Fix |
|---------|-------|-----|
| Error: `INSUFFICIENT_ACCESS` | Seller doesn't have Apex class access | Edit `Account_Brief_User` permission set, add `<classAccesses><apexClass>AccountContextService</apexClass>` |
| Error: `Account__c not supported` | Custom objects not deployed | Re-run Exercise 1 Prompt 1A |
| Error: `No such column 'Account__c'` | Metadata didn't refresh after deploy | Wait 30 seconds, retry. Or: Setup > Apex Classes > Compile All |
| Apex returns `isSuccess=true` but JSON is `{"error":"ACCOUNT_AMBIGUOUS"}` | Bug in the Apex (error contract broken) | The Apex should return `isSuccess=false` for errors. Re-prompt 2A with the fix. |
| Action returns null for all fields | Seller doesn't own the records and has no sharing | Assign `Account_Brief_User` to the seller, or make them owner of DEMO accounts |

---

## Skill produces wrong output

| Symptom | Cause | Fix |
|---------|-------|-----|
| Brief has 6 sections instead of 8 | Instructions were truncated or not saved | Re-paste the full instructions, save, try again |
| Shows raw record IDs (001...) instead of links | Apex didn't return a `url` field, or skill instructions don't know the instance | The skill should build links from id fields. Check the JSON returned by the action. |
| Totals don't match SOQL | LLM recomputed the total instead of quoting it | Strengthen the guideline: "Quote trailing12MonthTotal **exactly as returned** — never add, round or estimate." |
| Hallucinated figures (e.g., $70,000 for Lakeshore) | LLM invented a number | Check: did the action return the figure? If yes, the instructions need "use ONLY the returned data." If no, fix the Apex query. |
| Says "No contacts on file" but contacts exist | `missing` array incorrectly includes "contacts" | Fix the Apex: the `buildContactList` method should NOT add "contacts" to missing if the list is non-empty. |
| Asks "Which account?" on an Account page | recordId not passed from page context | Coworker may not support this yet. Fallback: use name-based prompts. |
| Reuses figures from a prior account (carry-over) | Skill instructions don't say "treat each brief as independent" | Add to GUIDELINES: "Never reuse figures from an earlier account in the same conversation." |

---

## Data issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| No DEMO accounts exist | Seed script never ran, or ran in the wrong org | Re-run Exercise 1 Prompt 1B |
| Lakeshore has 6 opportunities, not 9 | Seed script was edited or data was deleted | Re-run seed script, or adjust test expectations |
| Orders show product = null | OrderItems weren't created, or Product2 link is broken | Check: `SELECT Id, (SELECT Product2.Name FROM OrderItems) FROM Order`. Re-run seed if broken. |
| Harbor Supply shows only 1 account | One of the duplicate accounts was deleted | Re-run seed script to create both |

---

## Build-time errors

| Symptom | Cause | Fix |
|---------|-------|-----|
| Vibes says "chat turn already in progress" | Previous prompt is still running | Wait for the first prompt to finish, then paste the next one. Do NOT paste two prompts in parallel. |
| Deploy fails: `bundleType Required field is missing` | (Not relevant — we're not deploying .agent files) | Skip this; it's a subagent issue, not a skill issue. |
| Test fails: `Assert.areEqual expected 64500 but was 64000` | Order amounts in seed script don't add up correctly | Check the seed script's order loop. Lakeshore: 12 orders, $10k → $7.5k (furniture) + 12 × $2k (print) = $64,500. |
| Coverage < 90% | Test class doesn't cover all error branches | Add tests for: ACCOUNT_NOT_FOUND, Contact/Opp resolution, empty lists. |

---

## Timing issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Brief takes 3–5 seconds | Skill is querying inline (not using the Apex action) | Check: is the action attached? Type `@` in instructions, confirm Get_Account_Context is linked. |
| Action call times out | Too many child records, or Governor Limit hit | Check limits: `System.debug(Limits.getQueries())` after the action. Should be ≤ 14 queries. |

---

## Permission issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Admin test passes, seller test fails | Seller missing object or field access | Assign `Account_Brief_User` to seller. Check: Setup > Permission Sets > Manage Assignments. |
| Seller sees "You don't have access to Agentforce Coworker" | Coworker not enabled for this user | Setup > Agentforce Coworker > Manage User Access > add the seller |
| Seller can't see Skills tab | Skills not enabled, or user doesn't have permission | Check the Skills item in [1. Before the session](01-before-the-session.md#org-readiness). Contact account team if Skills isn't enabled. |

---

## "It works for me but not for the seller"

This always means **permissions**. Check:

1. Seller has `Account_Brief_User` assigned
2. Permission set includes Apex class access
3. Seller owns or has read sharing on DEMO accounts
4. Seller has Coworker access
5. Skill is shared and toggled ON for the seller

---

## Fallback: Use the pre-tested version

If Vibes/Claude Code generates buggy Apex (wrong error handling, missing LIKE matching, or permission set issues), deploy the **already-debugged version** from the code folder:

```bash
# Deploy the pre-tested Apex (has all 6 bugs fixed)
cd code
sf project deploy start --target-org <your-org-alias>
```

Or use the one-command deploy script:
```bash
cd code
./deploy.sh <your-org-alias>
```

This deploys:
- ✅ AccountContextService (with `isSuccess=false` for errors, LIKE matching)
- ✅ AccountContextServiceTest (90%+ coverage)
- ✅ 4 custom objects (Statement_of_Work__c, etc.)
- ✅ Permission set with Apex class access

Then skip to Exercise 3 to build the skill.

---

[Index](README.md) · [← Previous: Exercise 4: Test skill](11-exercise-test-skill.md) · [Next: Production readiness →](13-production-readiness.md)
