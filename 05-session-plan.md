[Index](README.md) · [← Previous: Configure Agentforce Vibes in VS Code](04-configure-vibes-in-vs-code.md) · [Next: Architecture →](06-architecture-skills-and-code.md)

# 5. Session plan

## The day on one page

| Time | Block | Pages | Output |
|---|---|---|---|
| 9:00 | Welcome and Agentforce overview | | |
| 9:00 to 9:15 | Architecture: Skills + Code pattern | [06](06-architecture-skills-and-code.md) | Shared understanding of the two-layer design |
| 9:15 | Hands-on build | | |
| | **Exercise 1:** Seed sample data | [07](07-exercise-seed-data.md) | 4 custom objects + 100 DEMO records |
| | **Exercise 2:** Build the Apex action | [08](08-exercise-apex-action.md) | `Get_Account_Context` deployed and tested |
| | **Exercise 3:** Build the Coworker skill | [09](09-exercise-build-skill.md) | `Account Brief` skill published |
| 11:30 | **Exercise 4:** Test the skill | [11](11-exercise-test-skill.md) | 7 test cases pass as a seller |
| 12:00 | Working lunch | | |
| 1:00 | Optimization and tuning | [12](12-troubleshooting.md) | Fixes applied, edge cases covered |
| 2:00 | Production readiness | [13](13-production-readiness.md) | Checklist, real data mapping, consumption estimate |
| 3:30 | Closing and next steps | [14](14-next-steps.md) | Owners and dates |
| 4:00 | End | | |

---

## Roles

| Role | Who | Does |
|---|---|---|
| **Driver** | Customer engineer | Shares screen, runs the prompts, builds live |
| **Customer lead** | Customer engineering lead | Decides scope, approves design choices |
| **Architect** | Customer architect | Challenges the design, owns production path |
| **Seller champion** | Customer seller | Tests the skill, judges usefulness |
| **Facilitator** | Salesforce technical architect | Runs the agenda, unblocks, keeps time |
| **Account team** | Salesforce account team | Licensing, consumption, and sandbox support |

---

## How we work

1. **Build live.** We don't paste pre-written code. The driver builds from prompts so the group sees how it's done.
2. **Predictable where it matters.** Data gathering is Apex; reasoning and formatting are the LLM.
3. **Test as a seller.** Admin tests miss permissions issues. The seller champion runs the real tests.
4. **Measure, don't argue.** Latency, cost, and accuracy are measured, not guessed.
5. **Skills + Code.** This session uses the skills-first pattern. If Skills isn't enabled, we pivot to an action-only or subagent approach.

---

## Success checks for the day

- [ ] 4 custom objects deployed (Statement_of_Work__c, Customer_Program__c, Price_Agreement__c, Account_Priority__c)
- [ ] 100 DEMO records inserted across 5 accounts
- [ ] `Get_Account_Context` Apex action returns a complete JSON payload in one call
- [ ] `Account Brief` skill exists in Coworker, toggled on, and shared with the seller champion
- [ ] Test 1 (Lakeshore full brief) shows 8 sections, no hallucinated figures
- [ ] Test 4 (Harbor Supply ambiguous) asks one clarifying question, then produces a brief
- [ ] Test 5 (page context) works from an Account page without asking "which account?"
- [ ] Consumption estimate completed (tokens per brief, cost per 1000 briefs)
- [ ] Named owners and pilot dates recorded

---

## Backup plans

| If this fails | We do this |
|---------------|------------|
| Skills not enabled | Build as an action-only approach (Coworker calls Apex directly, returns raw JSON) or pivot to a design workshop |
| Apex compile error | Driver fixes inline or uses the pre-tested reference code in `code/` |
| Skill doesn't route | Check description, check Target Agent = Coworker, check toggle is on |
| Test seller can't run action | Add Apex class access to permission set |
| Time runs short | Skip optimization, deliver working prototype + homework |

---

[Index](README.md) · [← Previous: Configure Agentforce Vibes in VS Code](04-configure-vibes-in-vs-code.md) · [Next: Architecture →](06-architecture-skills-and-code.md)
