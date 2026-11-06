# Account Brief: Live Build with Coworker Skills

**Audience:** Customer engineering team and seller champion  
**Session:** Hands-on build workshop  
**Format:** Live build from scratch. One driver shares screen, group follows along.  
**Goal:** Build a working Account Brief skill in Agentforce Coworker that produces grounded, 8-section briefs on the first turn.

> **This is a live build.** Org setup and access checks happen before the session. On the day we build sample data, an Apex action, and a Coworker skill from scratch.

> **All data is fictional.** Every account, contact, opportunity, order, and custom object record is made up. Do not use real customer data.

**▶ Start here: [0. Quick start](00-quick-start.md)**: the driver's one-page cheat sheet. Admins and builders do the pre-work on pages 1 to 4 before build day.

---

## Why this design

- **Customer goals:** Less seller research time, higher adoption of account-priority recommendations, and a clear answer on whether skills + code is the right pattern.
- **Skills-first approach.** We build a Coworker skill (not a separate agent) so Coworker routes automatically without Setup UI wiring.
- **Predictable by design.** Data gathering happens in Apex code, so the same account returns the same facts every time. The AI is used for formatting and reasoning only.

## What we build

An **Account Brief skill** in Agentforce Coworker that:
- Calls a single Apex action (`Get_Account_Context`) to fetch all data in one round trip
- Produces an 8-section brief on the first turn without follow-up questions
- Handles ambiguous names (Harbor Supply Co × 2) with one clarifying question
- Works from an Account page, Contact page, Opportunity page, or by typing an account name

```
Seller (Salesforce Chat)
        |
   Agentforce Coworker
        |
   "Account Brief" skill        ← built in Skill Builder
        |
   Get_Account_Context (Apex action)
        |
   Account + Opps + Orders + SOW + Customer Program + Pricing + account priority
```

## Guide index

| # | Page | What's in it | Time |
|---|---|---|---|
| 0 | **[Quick start](00-quick-start.md)** ← start here | Driver's one-page cheat sheet: pre-work, prompt order, time budget | build day |
| 1 | [Before the session](01-before-the-session.md) | Readiness check, org type, user access, Skills enabled | pre-work |
| 2 | [Configure Agentforce Vibes in the org](02-configure-agentforce-vibes-in-org.md) | Admin: turn on Einstein, Vibes license, permission sets | pre-work |
| 3 | [Turn on Agentforce Coworker](03-turn-on-agentforce-coworker.md) | Admin: turn on Coworker and Skills, create the test seller | pre-work |
| 4 | [Configure Agentforce Vibes in VS Code](04-configure-vibes-in-vs-code.md) | Each builder: install the extension, connect the org | pre-work |
| 5 | [Session plan](05-session-plan.md) | Agenda, roles, success checks | 9:00 |
| 6 | [Architecture: Skills + Code](06-architecture-skills-and-code.md) | Why skills, why Apex, the two-layer pattern | 9:00 to 9:15 |
| 7 | [Exercise 1: Seed sample data](07-exercise-seed-data.md) | Create 4 custom objects, deploy, insert 100 DEMO records | 9:15 to 9:45 |
| 8 | [Exercise 2: Build the Apex action](08-exercise-apex-action.md) | Create AccountContextService, write tests, deploy | 9:45 to 10:45 |
| 9 | [Exercise 3: Build the Coworker skill](09-exercise-build-skill.md) | Create "Account Brief" skill in Skill Builder, ground on Apex action | 10:45 to 11:30 |
| 10 | [Next skill: Next Best Action](10-next-best-action-skill.md) | Design for the follow-on skill that reuses the same Apex action | as needed |
| 11 | [Exercise 4: Test the skill](11-exercise-test-skill.md) | Run 7 test cases as a seller (full, sparse, ambiguous, page context) | 11:30 to 12:00 |
| 12 | [Troubleshooting guide](12-troubleshooting.md) | Common issues, fixes, gotchas | as needed |
| 13 | [Production readiness](13-production-readiness.md) | Checklist, real data mapping, consumption estimate | 2:00 |
| 14 | [Next steps](14-next-steps.md) | Owners, dates, what to build next | 3:30 |
| 15 | [Teardown (cleanup)](15-teardown.md) | Remove all demo artifacts from the org | after session |

---

## Folder structure

```
afl-coworker-skills/
├── README.md                    ← You are here (home page)
├── 00-quick-start.md            ← Driver's cheat sheet for build day
├── 01-before-the-session.md     ← Pre-work gates
├── 02-configure-agentforce-vibes-in-org.md  ← Admin: Einstein + Vibes setup
├── 03-turn-on-agentforce-coworker.md  ← Admin: Coworker + Skills setup
├── 04-configure-vibes-in-vs-code.md  ← Builders: VS Code setup
├── 05-session-plan.md           ← Agenda, roles, timeline
├── 06-architecture-skills-and-code.md  ← Why this pattern
├── 07-exercise-seed-data.md     ← Prompts to build custom objects + seed data
├── 08-exercise-apex-action.md   ← Prompts to build Apex action + tests
├── 09-exercise-build-skill.md   ← Build skill in Skill Builder
├── 10-next-best-action-skill.md ← Next skill design (Next Best Action)
├── 11-exercise-test-skill.md    ← 7 test cases as seller
├── 12-troubleshooting.md        ← Common issues and fixes
├── 13-production-readiness.md   ← Checklist, consumption estimate
├── 14-next-steps.md             ← Owners, dates, roadmap
├── 15-teardown.md               ← Cleanup prompts
└── code/                        ← READY-TO-DEPLOY SFDX project
    ├── README.md                ← Deploy instructions
    ├── QUICK_START.md           ← 1-minute deploy guide
    ├── COMPLETED.md             ← What was built and tested
    ├── MANIFEST.txt             ← File inventory
    ├── SKILLS_OVERVIEW.md       ← Account Brief vs. Next Best Action
    ├── NEXT_BEST_ACTION_GUIDE.md  ← Configure the Next Best Action skill
    ├── README_UPDATED.txt       ← Package summary (v2.0)
    ├── force-app/               ← Fixed Apex + metadata
    │   ├── classes/             ← AccountContextService (bugs fixed)
    │   ├── objects/             ← 4 custom objects
    │   └── permissionsets/      ← With Apex class access
    ├── scripts/apex/            ← Seed script + test scripts
    ├── deploy.sh                ← One-command deploy
    ├── validate.sh              ← Post-deploy health check
    └── sfdx-project.json
```

**Start here: [0. Quick start](00-quick-start.md)**

---

## How the prompts are written

Every prompt in this guide uses the **ROLE / TASK / EXPECTED OUTPUT / RULES / EXAMPLE** structure so it can be copied and pasted as-is into Agentforce Vibes or Claude Code.

Use the same structure when you write the next skill or action.

---

## Source material

- The customer's pre-work survey
- Lessons from an earlier build of this exercise (Agentforce Vibes log analysis)
- Skills-first architecture validated with Salesforce PMs

---

## Assumptions

1. Org is a **Developer Edition or Sandbox** (not Production)
2. **Agentforce Coworker is enabled** and at least one non-admin user can access it
3. **Skills are enabled** in the org (test with: "create a skill called Test Skill that says hello")
4. Seed data (opportunities, quotes, orders) lives in Salesforce; SOW/Customer Program/Pricing are modeled as custom objects
5. The driver has **Salesforce CLI** and **Agentforce Vibes** or **Claude Code with Salesforce DX MCP** installed
