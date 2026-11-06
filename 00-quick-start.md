[Index](README.md) · [Next: Before the session →](01-before-the-session.md)

# 0. Quick Start: Live Build Session

**For the driver on build day**

---

## Before you start (pre-work)

Full checklist and setup steps: [1. Before the session](01-before-the-session.md), then pages 2 to 4.

✅ Org is a **sandbox** (not Production)  
✅ **Agentforce Coworker** is enabled  
✅ **Skills** are enabled (test: "create a skill called Test Skill that says hello")  
✅ Salesforce CLI authenticated: `sf org display`  
✅ Test seller exists and has Coworker access  
✅ Vibes or Claude Code connected to the org

---

## Build order (paste these prompts in order)

### 1. Create custom objects (30 min)

Open Vibes/Claude Code and paste **Prompt 1A** from [07-exercise-seed-data.md](07-exercise-seed-data.md).

Wait for approval prompt, type "yes", confirm deploy succeeds.

### 2. Insert 100 DEMO records (5 min)

Paste **Prompt 1B** from the same file.

Verify: 5 accounts starting with "DEMO " exist.

### 3. Build the Apex action (60 min)

Paste these prompts in order:
- **Prompt 2A** (create AccountContextService) — from [08-exercise-apex-action.md](08-exercise-apex-action.md)
- **Prompt 2B** (create test class)
- **Prompt 2C** (deploy and test)
- **Prompt 2D** (grant Apex class access)

Verify: All tests pass, 90%+ coverage.

### 4. Build the Coworker skill (45 min)

Follow [09-exercise-build-skill.md](09-exercise-build-skill.md):
1. In Coworker, do the task once (paste the "Brief me on Lakeshore" prompt)
2. Turn it into a skill
3. Edit in Skill Builder (paste the full instructions from the doc)
4. Attach the action (`@Get_Account_Context`)
5. Toggle ON, share with test seller

### 5. Test as seller (30 min)

Log in as test seller. Run the 7 tests from [11-exercise-test-skill.md](11-exercise-test-skill.md):
1. Lakeshore full brief
2. Pinecrest sparse
3. Ridgeway no priority
4. Harbor ambiguous
5. Page context
6. Should not run (3 negatives)
7. No carry-over

---

## If something breaks

See [12-troubleshooting.md](12-troubleshooting.md).

Most common:
- **Skill doesn't run:** Check toggle ON, Target Agent = Coworker
- **Action fails:** Add Apex class access to permission set (Prompt 2D)
- **Wrong figures:** Check seed data (re-run Prompt 1B)

---

## After the session

Fill in the table in [14-next-steps.md](14-next-steps.md):
- Named owners
- Pilot dates
- What to build next

---

## The 5 files you need

1. [07-exercise-seed-data.md](07-exercise-seed-data.md) — Prompts 1A and 1B
2. [08-exercise-apex-action.md](08-exercise-apex-action.md) — Prompts 2A, 2B, 2C, 2D
3. [09-exercise-build-skill.md](09-exercise-build-skill.md) — Skill instructions (copy-paste)
4. [11-exercise-test-skill.md](11-exercise-test-skill.md) — 7 test cases
5. [12-troubleshooting.md](12-troubleshooting.md) — When things break

**After the session:**
- [15-teardown.md](15-teardown.md) — Clean up all demo artifacts (Prompts 15A–15D)

---

**Time budget:**
- Seed data: 30 min
- Apex: 60 min
- Skill: 45 min
- Testing: 30 min
- Buffer: 45 min
- **Total: 3.5 hours hands-on build**

---

[Index](README.md) · [Next: Before the session →](01-before-the-session.md)
