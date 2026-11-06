[Index](README.md) · [← Previous: Configure Agentforce Vibes in the org](02-configure-agentforce-vibes-in-org.md) · [Next: Configure Agentforce Vibes in VS Code →](04-configure-vibes-in-vs-code.md)

# 3. Turn on Agentforce Coworker

Agentforce Coworker is the assistant sellers talk to. On build day it runs the "Account Brief" skill we build when a seller asks "brief me on this account". It must be on in the sandbox, with a test seller who can use it, **before the session**.

**Who:** Customer Salesforce admin. **Time:** 15 to 30 minutes, plus a few minutes of automated processing. **Due:** before the session.

## Before you begin

| Requirement | What is needed |
|---|---|
| Edition | Enterprise, Unlimited or Agentforce 1 Edition. |
| Data Cloud (Data 360) | **Activated** in the org, not just provisioned |
| Licenses, usage-based | Foundations or Flex Foundations license, plus Flex Credits entitlements |
| Licenses, seat-based (alternative) | Agentforce 1 Edition, or Agentforce for Sales, Service, and Industries license |
| The admin doing the setup | Salesforce Admin role and the **Agentforce Coworker Admin** permission set |

> **If any of these is missing,** stop and contact the Salesforce account team. The setup page shows a warning and will not let you turn Coworker on until the prerequisites are complete.

> **Why Data Cloud appears here:** Coworker runs on Data Cloud (Data 360), so it has to be activated in the org. The Account Brief itself still reads its data from Salesforce objects through one Apex action; it does not use Data Cloud data.

## Step 1: Turn on Coworker

When Coworker turns on, Einstein turns on automatically. Keep Einstein on.

1. Setup > Quick Find **Agentforce Coworker**.
2. Select **Get Started with Agentforce Coworker** in the side panel.
3. Click **Turn On**.
4. In the *Turn on Agentforce Coworker* window, click **Confirm**.

Setup is mostly automated and can take a few minutes. If a warning appears, complete the steps it lists, then try again.

## Step 2: Give builders and the test seller access

1. In Agentforce Coworker Setup, find the **Manage Users** section.
2. Next to *Manage Access to Agentforce Coworker*, click **Manage**.
3. In *Assign Permission Groups to Users*, select:
   - every builder
   - the **test seller** user (see Step 3)
4. Click **Assign**, then **Done**.

You can also grant access from the main Setup menu by assigning the permission set group with API name `Access_Ai_Search`. Salesforce recommends the Manage Users section instead.

## Step 3: Create the test seller

Exercise 4 ([page 11](11-exercise-test-skill.md)) tests the skill in Coworker as a real seller, not as an admin, so sharing and permissions behave as they will in production.

1. Create a user with a standard sales profile. Not a System Administrator.
2. Give them Coworker access (Step 2).
3. On build day, after Exercise 1, they also get the `Account_Brief_User` permission set and ownership of (or sharing on) the DEMO accounts. See [Exercise 4](11-exercise-test-skill.md#setup).
4. Confirm you can log in as them: Setup > Users > **Login** next to the user. If the Login link is missing, turn on Setup > Login Access Policies > *Administrators Can Log in as Any User*.

## Step 4 (only if seat-based): Assign the unmetered license

Skip this step if the customer uses usage-based (Flex Credits) access.

1. Assign the **Unmetered User Based AI** permission set license to the builders and the test seller.
2. Create a permission set that uses that license.
3. Assign the new permission set to the same users.

## Step 5: Turn on Skills (needed for Exercise 3)

Coworker being on does not turn Skills on. In an org where it is off, Coworker can draft a skill in chat but cannot save it, and reports that the Skills feature is not enabled. Skills is a separate org-level setting that an admin must turn on.

1. Setup > Quick Find **Skills** or **Skill Builder** (the label varies by release **(to confirm)**), or Agentforce Studio > **Skills** tab.
2. If a Skills setting or toggle exists, turn it on. If the tab or setting is missing, the org does not have the feature yet.
3. Assign the builders and the test seller whatever access the Skills page asks for **(to confirm the permission name)**.
4. Test it: in Coworker, ask *create a skill called Test Skill that says hello*, then confirm it saves and appears under **Skills > My Skills**. Delete it afterwards.

> An error from Coworker that names `EinsteinAiAgentSkillsIdlFamily` points at this org setting. That name came from a Coworker error message and is **not yet confirmed** against the sandbox metadata; check it with the account team. If Skills cannot be turned on before the session, use the backup plan in the [session plan](05-session-plan.md#backup-plans).

## Step 6: Smoke test

1. Log in as the test seller.
2. Open the Sales app and open Coworker **(to confirm the entry point in the sandbox release, for example the Agentforce icon in the header)**.
3. Ask: *what can you help me with?*

Coworker should answer. The Account Brief does not exist yet; it is built on build day in [Exercise 3](09-exercise-build-skill.md).

## Done when

- [ ] Agentforce Coworker Setup shows Coworker as on, with no warnings
- [ ] Every builder and the test seller have Coworker access
- [ ] The test seller exists, is not an admin, and you can log in as them
- [ ] The test seller gets an answer from Coworker in the Sales app
- [ ] A throwaway skill saves and shows under Skills > My Skills (or you have told the facilitator Skills is not available)

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Agentforce Coworker not found in Setup | Edition or license missing | Confirm the edition and licenses with the account team |
| Warning on the setup page; Turn On is blocked | A prerequisite is missing, often Data Cloud not activated | Complete the steps in the warning |
| You cannot turn it on or manage users | Missing admin permission | Assign yourself the Agentforce Coworker Admin permission set |
| Test seller cannot see Coworker | Access not assigned | Repeat Step 2 for that user; they log out and in again |
| Coworker drafts a skill but cannot save it; says Skills is not enabled | The org-level Skills setting is off, or the feature is not in this release | Step 5; if absent, ask the account team to enable it, else use the [backup plan](05-session-plan.md#backup-plans) |

## Salesforce documentation

- [Set up Agentforce Coworker](https://developer.salesforce.com/docs/data/agentforce-coworker/guide/agentforce-coworker-a-setup-home.html)
- [Turn on Agentforce Coworker](https://developer.salesforce.com/docs/data/agentforce-coworker/guide/agentforce-coworker-turn-on-infrastructure.html)
- [Add or remove user access](https://developer.salesforce.com/docs/data/agentforce-coworker/guide/agentforce-coworker-manage-user-access.html)

---

[Index](README.md) · [← Previous: Configure Agentforce Vibes in the org](02-configure-agentforce-vibes-in-org.md) · [Next: Configure Agentforce Vibes in VS Code →](04-configure-vibes-in-vs-code.md)
