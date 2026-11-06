[Index](README.md) · [← Previous: Turn on Agentforce Coworker](03-turn-on-agentforce-coworker.md) · [Next: Session plan →](05-session-plan.md)

# 4. Configure Agentforce Vibes in VS Code

Each builder does this on their own laptop, after the admin finishes [page 2](02-configure-agentforce-vibes-in-org.md) and assigns them the **Agentforce Developer and Admin Tools** permission set.

**Who:** every builder. **Time:** about 30 minutes. **Due:** before the session.

## Prerequisites

| Requirement | How to check |
|---|---|
| VS Code, current release | macOS: Code > Check for Updates. Windows: Help > Check for Updates |
| Salesforce CLI v2.91.5 or later (or Node.js 20+) | `sf version` |
| Git (needed for checkpoints, which let you roll back changes) | `git --version` |
| Windows only: Microsoft Visual C++ Redistributable | Without it, the extension fails to start |
| Network | AI endpoints exempted from SSL inspection or proxy. Salesforce can supply the hostname list |

Install the CLI if needed:

```bash
npm install --global @salesforce/cli
sf version
```

## Step 1: Install the extension

1. In VS Code, open Extensions (⇧⌘X on Mac, Ctrl+Shift+X on Windows).
2. Search for **Salesforce Extension Pack** and install it. Agentforce Vibes is included.
3. Reload VS Code when prompted.

## Step 2: Turn off other AI extensions

Multiple AI extensions running together give unpredictable results. In Extensions, **Disable** other AI assistants (for example GitHub Copilot) for this workspace.

## Step 3: Create a project and connect the sandbox

```bash
sf project generate --name account-brief
cd account-brief
code .
sf org login web --alias account-brief-sandbox --instance-url https://test.salesforce.com --set-default
```

Or use the Command Palette: **SFDX: Create Project**, then **SFDX: Authorize an Org**.

## Step 4: Complete the first-run checklist

Click the Agentforce Vibes icon in the VS Code activity bar. The **Getting Setup for Success** checklist checks each item and marks it **Ready**:

- [ ] Salesforce CLI is current
- [ ] Salesforce Extension Pack is current
- [ ] A Salesforce DX project is open (it has `sfdx-project.json`)
- [ ] An org is connected

## Step 5: Allow telemetry

The extension needs telemetry turned on to start. Your admin should already have cleared this with IT ([page 2](02-configure-agentforce-vibes-in-org.md#step-6-review-the-telemetry-policy)).

1. VS Code Settings > search `salesforcedx-vscode-core.telemetry.enabled` and tick it.
2. Settings > search `telemetry` > set **Telemetry Level** to **all**.
3. Terminal: `sf config set disable-telemetry=false --global`
4. Command Palette: **Developer: Reload Window**.

## Step 6: Smoke test

Open the Agentforce Vibes chat and paste:

```
ROLE
You are the Agentforce Vibes assistant connected to my Salesforce org.

TASK
Confirm which org you are connected to and list its custom objects.

EXPECTED OUTPUT
The username and org type, then a list of custom object API names.

RULES
- Do only read from the org.
- Do not create, change or deploy anything.

EXAMPLE OUTPUT
Connected as builder@example.com.sandbox (Sandbox).
Custom objects (3): Invoice__c, Region__c, Sales_Target__c
```

You should see the sandbox username and a list of objects.

## Step 7 (recommended): Reduce approval prompts

By default Vibes asks before every action. In Agentforce Vibes Settings, set **Default Session Mode** to **Run safe defaults**. It will then run read-only, build and test commands without asking, and still ask before anything that changes the org.

## Step 8 (optional): Add the Salesforce DX MCP server to other AI tools

Only needed if you also use Claude Code or Cursor alongside Vibes:

```bash
claude mcp add salesforce-dx -- npx -y @salesforce/mcp --orgs DEFAULT_TARGET_ORG --toolsets all
```

## Done when

- [ ] The first-run checklist shows Ready for every item
- [ ] The smoke test returns the sandbox username
- [ ] Builder confirms before the session (part of the [readiness check](01-before-the-session.md#checklist))

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Chat gives no response, or the model list is empty | Permission set or license not assigned | Admin completes Steps 3 and 4 on [page 2](02-configure-agentforce-vibes-in-org.md); restart VS Code |
| Extension fails to start (Windows) | Visual C++ Redistributable missing | Install it, then reopen VS Code |
| Extension does not start after install | Telemetry is off | Complete Step 5 |
| Setup checklist blocks on CLI or Extension Pack | Out-of-date version | Update, then reload the window |
| Odd or inconsistent suggestions | Another AI extension is active | Disable it and reload |
| Network or certificate errors | Proxy or SSL inspection | Exempt the AI endpoints, or try another network |
| Laptop is locked down and nothing works | IT policy | Use the browser-based Agentforce Vibes IDE ([page 2](02-configure-agentforce-vibes-in-org.md#step-5-optional-turn-on-agentforce-vibes-ide), Step 5) |

## Salesforce documentation

- [Get started with Agentforce Vibes](https://developer.salesforce.com/docs/platform/agentforcevibes/guide/afv-get-started.html)
- [First-run setup checklist](https://developer.salesforce.com/docs/platform/agentforcevibes/guide/afv-user-setup.html)
- [FAQs](https://developer.salesforce.com/docs/platform/agentforcevibes/guide/afv-faqs.html)

---

[Index](README.md) · [← Previous: Turn on Agentforce Coworker](03-turn-on-agentforce-coworker.md) · [Next: Session plan →](05-session-plan.md)
