[Index](README.md) · [← Previous: Before the session](01-before-the-session.md) · [Next: Turn on Agentforce Coworker →](03-turn-on-agentforce-coworker.md)

# 2. Configure Agentforce Vibes in the org

Agentforce Vibes is Salesforce's AI coding assistant. In this session it writes the metadata and Apex from the prompts in each exercise. This page covers the **one-time org setup** a Salesforce admin does in the sandbox. Each builder then sets up VS Code on [page 4](04-configure-vibes-in-vs-code.md).

**Who:** Customer Salesforce admin. **Time:** about 30 minutes. **Due:** before the session.

## Check the edition

Agentforce Vibes is available in Developer, Enterprise, Partner Developer, Performance and Unlimited Editions. It is not available in Group, Professional or Essentials Editions, or in EU Operating Zone and Government Cloud.

## Step 1: Turn on Einstein

Setup > Quick Find **Einstein Setup** > **Turn on Einstein**. Every AI feature depends on this toggle.

## Step 2: Confirm Agentforce Vibes is enabled

It is on by default in supported editions. To check: Setup > Quick Find **Agentforce Vibes** and confirm the toggle is on. If Agentforce Vibes is not listed in Setup, the edition does not support it.

## Step 3: Confirm the license is provisioned

Setup > **Company Information** > **Permission Set Licenses**. Look for **Agentforce Platform Developer and Admin**.

If it is missing, the org needs a qualifying Flex Credits entitlement. Ask your Salesforce account executive; there is nothing more to do in Setup until the license appears. In a sandbox, licenses come from the production org.

## Step 4: Assign the permission set to each builder

1. Setup > Quick Find **Permission Sets**.
2. Open **Agentforce Developer and Admin Tools**.
3. **Manage Assignments** > **Add Assignments**.
4. Select every builder and save.

This gives metered access, which uses Flex Credits. If the customer has the unmetered add-on, also follow the "Add Unmetered Access" steps in the Salesforce guide linked below.

## Step 5 (optional): Turn on Agentforce Vibes IDE

On the Agentforce Vibes Setup page, review and accept the terms to turn on **Agentforce Vibes IDE**, the browser-based version. It needs nothing installed, which makes it the fallback if a builder's laptop is locked down. It is available to sandbox users who have the *View All Data* permission.

## Step 6: Review the telemetry policy

The Vibes extension needs telemetry turned on to start. Check that this is allowed by the customer's data collection and privacy policy before build day, so builders are not blocked on the day. Builders can turn it off again after setup if policy allows.

## Done when

- [ ] Einstein is on
- [ ] Agentforce Vibes shows as enabled in Setup
- [ ] **Agentforce Platform Developer and Admin** appears under Permission Set Licenses
- [ ] Every builder has the **Agentforce Developer and Admin Tools** permission set
- [ ] Telemetry is cleared with IT, or the Vibes IDE is turned on as the fallback

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Agentforce Vibes not listed in Setup | Unsupported edition | Confirm the org edition |
| Permission set license missing | No Flex Credits entitlement | Ask the Salesforce account executive to provision one |
| A builder's chat gives no response, or the model list is empty | Permission set not assigned | Repeat Step 4 for that user; they restart VS Code |

## Salesforce documentation

- [Set up Agentforce Vibes for your org](https://developer.salesforce.com/docs/platform/agentforcevibes/guide/afv-admin-settings.html)
- [Assign licenses for Agentforce Vibes](https://developer.salesforce.com/docs/platform/agentforcevibes/guide/afv-entitlement-setup.html)
- [FAQs](https://developer.salesforce.com/docs/platform/agentforcevibes/guide/afv-faqs.html)

---

[Index](README.md) · [← Previous: Before the session](01-before-the-session.md) · [Next: Turn on Agentforce Coworker →](03-turn-on-agentforce-coworker.md)
