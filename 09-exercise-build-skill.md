[Index](README.md) · [← Previous: Exercise 2: Apex action](08-exercise-apex-action.md) · [Next: Next skill: Next Best Action →](10-next-best-action-skill.md)

# Exercise 3: Build the Coworker skill

**Time:** 45 minutes  
**Where:** Agentforce Coworker > Skills > Create Skill  
**Output:** "Account Brief" skill published and toggled on

This skill calls the `Get_Account_Context` Apex action and formats the 8-section brief.

---

## Prerequisites

Before starting:
- [ ] Agentforce Coworker is enabled
- [ ] Skills are enabled (test: "create a skill called Test Skill that says hello" saves under Skills > My Skills)
- [ ] You're logged in as an admin (or a user with Create Skills permission)
- [ ] `AccountContextService` is deployed and tested

---

## Step 1: Do the task once (teach Coworker)

Open Coworker and paste:

```
Brief me on DEMO Lakeshore Medical Group. Cover: company overview, open
opportunities, recently closed opportunities, last quote, last order, the
12-month order trend, active SOW and renewal date, and any priority
recommendation. Say what is missing instead of asking me questions.
```

**What Coworker does:**
- Searches for the account
- Fetches opportunities, quotes, orders, etc. (probably 5+ tool calls)
- Assembles a brief

**Check:**
- The brief has company info, opportunities, orders
- It took 3–5 seconds (because Coworker queried inline)

**Why we're doing this:** We're showing Coworker what the task looks like before turning it into a skill.

---

## Step 2: Turn it into a skill

In the **same conversation**, paste:

```
Create a skill from this conversation called "Account Brief". It runs
on one account, either the record I am on or one I name. It calls the
Get_Account_Context Apex action to fetch all data in one call, then writes
an 8-section brief. It never asks follow-up questions on the first turn
unless the account is unknown or two accounts share the name. It ends with
exactly one suggested next step.
```

Coworker will create a draft skill. **Do not accept the auto-generated name or description yet.** We'll edit them in Step 3.

---

## Step 3: Configure the skill in Skill Builder

Click **Skills** (in Coworker sidebar) or go to **Agentforce Studio > Skills**. Find the new skill.

### Settings

| Field | Value |
|-------|-------|
| **Name** | Account Brief |
| **Description** | Use when a seller asks to brief, prep, summarize or research an account or customer meeting. Examples: "brief me on X", "prep me for my call with X", "what's going on at X", "summarize this account". |
| **Target Agent** | **Coworker** (required — if this says "Default" or anything else, change it to Coworker) |
| **Input** | Account: the record the seller is on, or a name they give |
| **Objective** | One grounded Account Brief on the first turn, no follow-up questions unless the account is unknown or ambiguous |

### Instructions

Click **Edit Instructions**. Delete the auto-generated text and paste this:

```
STEPS
1. Call Get_Account_Context before writing anything. If the seller is on an
   Account, Contact or Opportunity page, pass that record Id as recordId.
   Otherwise pass the account name the seller typed as accountName.

2. Check the response:
   - If isSuccess is false and errorType is ACCOUNT_AMBIGUOUS: parse the
     candidates array from contextJson and list each candidate as a clickable
     Salesforce record link (use the candidate's id, show the candidate's
     name as the link text). Then ask: "Which account did you mean?" Stop.
     Do not write a brief.
   
   - If isSuccess is false and errorType is ACCOUNT_REQUIRED: ask "Which
     account would you like me to brief? Please give me the account name."
     Stop. Do not write a brief.
   
   - If isSuccess is false and errorType is ACCOUNT_NOT_FOUND: say "I couldn't
     find an account matching that name. Could you check the spelling or give
     me the full account name?" Stop.

3. If isSuccess is true: compose the brief now using only the data in
   contextJson. Write as direct prose with bold section headers. Do NOT call
   the action again.

Structure the brief with exactly 8 bold sections in this order:

**Company overview**
Name, industry, number of employees, website, billing city and state (from
the account object in the JSON).

**Selling strategy**
Exactly one sentence: state the first account priority's reason and its
recommended action in plain English.
If "priority" appears in the missing array, write: "No account priority on file."

**Top focus areas**
List every account priority by rank — reason followed by recommended action.
If "priority" appears in the missing array, write: "No account priority on file."

**Contacts to approach**
List each contact as a Salesforce record link (build the link from the
contact's id field) with their title shown after the link.
If "contacts" appears in the missing array, write: "No contacts on file."

**Opportunity insights**
Group as three labelled sub-items:
- Open (early-stage): opps in Prospecting, Needs Analysis, Value Proposition
  — each as a record link with stage and amount.
- Late-stage open: opps in Proposal/Price Quote, Id. Decision Makers, or
  later — each as a record link with stage and amount.
- Won/lost this year: closed opps from recentClosedOpps — each as a record
  link with Closed Won or Closed Lost and amount.
If both "openOpps" and "recentClosedOpps" are in the missing array, write:
"No opportunities on file."

**Service insights**
List each open case as a Salesforce record link with its subject.
If "openCases" appears in the missing array, write: "No open cases on file."

**Recent order insights**
Show the most recent order's effective date, then the trailing12MonthTotal
(quote it exactly as returned — do not add up or recompute).
List every entry in byMonth as a record link with effective date, product
name, and amount.
If "orders" appears in the missing array, write: "No orders in the last 12
months."

**Contract details**
SOW: status and end date.
Customer Program: program type and renewal date.
Pricing: list each price agreement with product class, tier, and discount %.
For every item that appears in the missing array write one line, for example:
"No SOW on file.", "No Customer Program on file.", "No pricing on file."

4. After all 8 sections, ask exactly one follow-up question that is directly
   relevant to this account's current situation.

GUIDELINES
- Use only data returned by Get_Account_Context. Never invent, estimate or
  recompute a figure. Quote trailing12MonthTotal exactly as returned.
- Show record names as clickable record links. Never show a raw record Id or
  an internal field name.
- Treat each brief as independent. Never reuse figures from an earlier account
  in the same conversation.
- Do not ask a question before calling the action, except as stated in step 2.
- Do not call the action a second time after a successful result.
```

### Attach the action

1. In the Instructions canvas, type `@` or `/` (check which one opens the resource picker)
2. Search for **Get Account Context** or **AccountContextService**
3. Select the action
4. Confirm it appears as a linked resource in the instructions

### Save

Click **Save** or **Save Draft**. The skill should now appear under **Skills > My Skills**.

---

## Step 4: Turn it on

1. Go to **Skills** tab
2. Find **Account Brief**
3. Toggle it **ON** (the switch should be blue/green)
4. Confirm **Target Agent** still shows **Coworker**

---

## Step 5: Share with the test seller

1. In **Skills** tab, click **Share** (next to the skill)
2. Add the test seller's name or email
3. Set their permission to **Can use** (not Can edit)
4. Click **Share**

**Tell the test seller:**
- Go to Coworker > Skills > Browse
- Find "Account Brief"
- Toggle it ON

---

## Step 6: Smoke test (as admin)

Open a new Coworker conversation and type:

```
Brief me on DEMO Lakeshore Medical Group
```

**Expected:**
- 8 sections appear in order
- Company overview shows "DEMO Lakeshore Medical Group. Healthcare. 1,800 employees..."
- Trailing 12-month total: $64,500
- 5 contacts listed
- 2 account priorities in Selling strategy and Top focus areas
- No "No X on file" lines (Lakeshore has everything)
- Ends with one follow-up question

**If it doesn't run:**
- Check the skill toggle is ON
- Check Target Agent = Coworker
- Check the description (Coworker matches by description)
- Check the action is attached (linked resource in instructions)

---

## What you have now

- A working "Account Brief" skill
- It's toggled ON and shared with the test seller
- It calls the Apex action in one round trip (~200ms)
- Admin smoke test passes

**Next:** [Exercise 4: Test the skill](11-exercise-test-skill.md)

---

[Index](README.md) · [← Previous: Exercise 2: Apex action](08-exercise-apex-action.md) · [Next: Next skill: Next Best Action →](10-next-best-action-skill.md)
