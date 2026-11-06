[Index](README.md) · [← Previous: Quick start](00-quick-start.md) · [Next: Configure Agentforce Vibes in the org →](02-configure-agentforce-vibes-in-org.md)

# 1. Before the session

Complete these checks **before the session**. On the day we build; we don't troubleshoot org access or licensing.

---

## Checklist

### Org readiness

- [ ] **Org type:** Developer Edition or Sandbox (NOT Production)
  - Run: `SELECT IsSandbox FROM Organization` in Developer Console
  - Or: `sf data query --query "SELECT IsSandbox FROM Organization"`
  - Must return `IsSandbox = true` or be a Developer Edition org

- [ ] **Agentforce Coworker is enabled**
  - Setup > Agentforce Coworker shows "On"
  - See [3. Turn on Agentforce Coworker](03-turn-on-agentforce-coworker.md) for steps

- [ ] **Skills are enabled**
  - Open Coworker and ask: `create a skill called Test Skill that says hello`
  - If it saves under Skills > My Skills, Skills is enabled
  - If it says "Skills feature isn't enabled", contact your account team to enable it
  - Delete the test skill after confirming

- [ ] **Clean slate**
  - No DEMO accounts exist: `SELECT COUNT() FROM Account WHERE Name LIKE 'DEMO %'` returns 0
  - Custom objects don't exist yet: Statement_of_Work__c, Customer_Program__c, Price_Agreement__c, Account_Priority__c
  - If they exist from a prior run, decide whether to delete and rebuild or use existing data

### User access

- [ ] **Driver has System Administrator profile**
  - Or a custom profile with:
    - Modify All Data
    - Author Apex
    - Customize Application
    - Manage Agents

- [ ] **Test seller exists**
  - Standard Sales User profile (NOT System Administrator)
  - Has Agentforce Coworker access (Setup > Agentforce Coworker > Manage User Access)
  - Can log into Salesforce from Setup > Users > Login
  - Record the username for Exercise 4 testing

- [ ] **Driver can create and share skills**
  - Skills > My Skills is accessible
  - Skills > Share button works

### Tools installed

- [ ] **Salesforce CLI**
  - Run: `sf --version`
  - Minimum version: 2.x
  - Install from [developer.salesforce.com/tools/salesforcecli](https://developer.salesforce.com/tools/salesforcecli)

- [ ] **VS Code with Salesforce Extension Pack** (if using Vibes)
  - Includes Agentforce Vibes extension
  - See [2. Configure Agentforce Vibes in the org](02-configure-agentforce-vibes-in-org.md) and [4. Configure Agentforce Vibes in VS Code](04-configure-vibes-in-vs-code.md)

- [ ] **OR Claude Code with Salesforce DX MCP** (alternative to Vibes)
  - Claude Code connected to the sandbox

- [ ] **Org authenticated**
  - Run: `sf org login web --alias account-brief-demo`
  - Or use an existing alias
  - Confirm: `sf org display` shows the correct username and org ID

### Pre-session data request (optional)

If the customer wants to use real data shapes instead of seed data:
- [ ] Export 5 representative accounts with all child records (opportunities, contacts, orders, quotes, cases)
- [ ] Scrub all PII and customer names (replace with DEMO Lakeshore, DEMO Ridgeway, etc.)
- [ ] Provide as CSVs or a metadata package
- [ ] Confirm which objects hold SOW, Customer Program, and pricing data in production

---

## What happens if a gate fails

| Gate fails | Impact | Fix |
|------------|--------|-----|
| Skills not enabled | Cannot build the skill; must use a subagent or action-only approach | Contact account team to enable Skills |
| Not a sandbox | Cannot use fictional data; session becomes a design workshop only | Provision a sandbox or Developer Edition org |
| Test seller doesn't exist | Cannot test as a non-admin; all tests run as admin (may miss permissions issues) | Create a test seller with Sales User profile |
| Coworker not enabled | No routing; skill cannot be invoked | Enable Coworker (requires Agentforce license) |

---

## On the day

1. **Driver shares screen** showing Salesforce Setup (logged in as admin)
2. **Test seller is ready** in a separate browser window or profile
3. **Facilitator confirms** everyone can see the screen
4. **Customer lead confirms** the use case and data scope before Exercise 1 starts

---

[Index](README.md) · [← Previous: Quick start](00-quick-start.md) · [Next: Configure Agentforce Vibes in the org →](02-configure-agentforce-vibes-in-org.md)
