[Index](README.md) · [← Previous: Architecture](06-architecture-skills-and-code.md) · [Next: Exercise 2: Apex action →](08-exercise-apex-action.md)

# Exercise 1: Seed sample data

**Time:** 30 minutes  
**Tool:** Agentforce Vibes / Claude Code with Salesforce DX MCP  
**Output:** 4 custom objects + 100 DEMO records

All data is fictional. Use exact names (DEMO Lakeshore, DEMO Ridgeway, etc.) so test prompts work as written.

---

## Step 1: Create the 4 custom objects

**Prompt 1A: Create custom objects and permission set**

Paste this into Agentforce Vibes or Claude Code:

```
ROLE
You are a Salesforce developer working in my default org through the
Salesforce DX tools.

TASK
Create these 4 custom objects and a permission set as metadata in force-app,
then deploy them to the org.

Custom objects (all with standard Name field):
1. Statement_of_Work__c
   - Account__c (Lookup to Account, required)
   - Status__c (Picklist: Active, Expired, Draft; default: Draft)
   - Start_Date__c (Date)
   - End_Date__c (Date)
   - Scope_Summary__c (Long Text Area, length 1000)

2. Customer_Program__c
   - Account__c (Lookup to Account, required)
   - Program_Type__c (Picklist: Healthcare, Education, Commercial, Gov)
   - Renewal_Date__c (Date)
   - Coverage_Summary__c (Long Text Area, length 1000)

3. Price_Agreement__c
   - Account__c (Lookup to Account, required)
   - Product_Class__c (Text 100)
   - Tier__c (Picklist: Contract, Tier 1, Tier 2)
   - Discount_Pct__c (Percent, 2 decimal places)
   - Effective_Date__c (Date)

4. Account_Priority__c
   - Account__c (Lookup to Account, required)
   - Priority_Rank__c (Number, 0 decimal places)
   - Priority_Reason__c (Text 255)
   - Recommended_Action__c (Text 255)
   - Refreshed_On__c (Date)

Permission set: Account_Brief_User
- Read access on all 4 custom objects (with viewAllFields)
- Read access on Account, Contact, Opportunity, Quote, Order, OrderItem,
  Product2, Case (standard objects)

EXPECTED OUTPUT
1. A component list (object, fields) for me to approve before deploying
2. After deploy: a results table (component, type, status)
3. One-line deploy summary

RULES
- Show me the component list and wait for my approval before deploying
- Use the exact API names and picklist values above
- Do not create any records yet (that's the next prompt)
- Do not modify standard objects

EXAMPLE OUTPUT
Deploy succeeded: 24 components, 0 errors.
```

**What to check:**
- All 4 objects listed with correct field counts
- Permission set includes all 4 custom objects
- Deploy succeeds with 0 errors

**If it fails:** Check the error message. Common issues:
- Object already exists → decide whether to delete and rebuild or skip
- Field type mismatch → review the prompt for typos

---

## Step 2: Seed the 100 DEMO records

**Prompt 1B: Insert sample data**

```
ROLE
You are a Salesforce developer creating fictional test data.

TASK
Create a script at scripts/apex/seed-account-brief-demo.apex that inserts exactly
100 fictional DEMO records (seeded data for testing), then run the script.

Data to create:
- 2 Products: "DEMO Furniture", "DEMO Print" (both IsActive=true)
- Standard Pricebook entries for both products
- 5 Accounts (all with Name starting with "DEMO "):
  1. "DEMO Lakeshore Medical Group" (Healthcare, 1800 employees, Chicago IL,
     website lakeshoremedical.example)
  2. "DEMO Ridgeway Logistics" (Transportation, 650 employees, Dallas TX,
     website ridgewaylogistics.example)
  3. "DEMO Pinecrest School District" (Education, 320 employees, Portland OR,
     no website)
  4. "DEMO Harbor Supply Co" (Wholesale, Seattle WA) — deliberately sparse
  5. "DEMO Harbor Supply Co" (Wholesale, Tacoma WA) — duplicate name to test
     ambiguity handling

- 7 Contacts for Lakeshore, 4 for Ridgeway, 1 for each Harbor (13 total)
- 13 Opportunities: 9 for Lakeshore (6 open, 3 closed), 5 for Ridgeway
  (4 open, 1 closed), 1 for Pinecrest (open), 1 for each Harbor (18 total)
- 5 Quotes (linked to first 4 Lakeshore opps + first Ridgeway opp)
- 18 Orders: 12 for Lakeshore (one per month, last 12 months, amounts
  descending from $10k to $7.5k for furniture, $2k for print), 6 for
  Ridgeway (one per month, last 6 months, alternating $3.5k furniture and
  $1.8k print)
- 18 OrderItems (one per order, linked to DEMO Furniture or DEMO Print)
- 6 Cases: 4 for Lakeshore (1 open), 2 for Ridgeway (1 open)
- 2 Statement_of_Work__c: Lakeshore (Active, ends in 6 months),
  Ridgeway (Active, ends in 9 months)
- 2 Customer_Program__c: Lakeshore (Healthcare, renews in 90 days),
  Ridgeway (Commercial, renews in 180 days)
- 8 Price_Agreement__c: 5 for Lakeshore (Furniture Contract 12%, Print Tier 1
  8%, Technology Tier 2 5%, Supplies Tier 1 7%, Services Contract 10%),
  3 for Ridgeway (Furniture Tier 1 6%, Print Tier 2 4%, Supplies Tier 2 3%)
- 2 Account_Priority__c: both for Lakeshore only (rank 1: "Declining furniture
  spend at 3 sites" / "Offer site-level furniture review", rank 2: "Print
  volume flat" / "Propose managed print review")

Total: 100 records across 13 objects.

Deliberate gaps (for testing sparse/missing cases):
- Pinecrest: only 1 Account + 1 Opportunity (2 records)
- Ridgeway: 0 account priorities (tests "No account priority on file")
- Harbor #1 and #2: 1 Contact + 1 Opportunity each, no other records

EXPECTED OUTPUT
1. File created: scripts/apex/seed-account-brief-demo.apex
2. Script runs and inserts 100 records
3. Verification: a count table (object as rows, account columns showing counts)

RULES
- Use exact account names (start with "DEMO ")
- Use Date.today() so dates stay relative (e.g., today.addMonths(-6))
- Lakeshore orders: 12 months, descending amounts (furniture $10k→$7.5k,
  print flat $2k). This creates a spend trend to call out in the brief.
- Harbor Supply Co: both have the identical name to test ACCOUNT_AMBIGUOUS
- Check for existing DEMO data first; if found, delete before inserting
- Output a final line: "=== SEED COMPLETE: 100 records ==="

EXAMPLE OUTPUT
Seed complete: 100 records inserted.
Lakeshore: 58 child records (7 contacts, 9 opps, 12 orders, 12 order items,
  4 cases, 5 quotes, 1 SOW, 1 customer program, 5 pricing, 2 priorities)
Ridgeway: 30 child records (no priorities)
Pinecrest: 2 records
Harbor #1: 3 records
Harbor #2: 3 records
Shared: 2 products + 2 pricebook entries
```

**What to check:**
- Script creates the file and runs
- Final count: 100 records
- Lakeshore has the most data (tests full brief)
- Pinecrest and Harbor are sparse (tests missing handling)
- No compile errors

**If it fails:**
- **Account__c not found:** The custom objects didn't deploy in Step 1. Re-run Prompt 1A.
- **Duplicate name error:** DEMO data already exists. Decide whether to delete first or skip seeding.
- **Pricebook2 error:** Standard pricebook might be inactive. Check Setup > Products > Price Books.

---

## Step 3: Verify the data

Run this SOQL to confirm all 5 accounts exist:

```sql
SELECT Id, Name, Industry, BillingCity FROM Account WHERE Name LIKE 'DEMO %'
```

Expected:
- DEMO Lakeshore Medical Group
- DEMO Ridgeway Logistics
- DEMO Pinecrest School District
- DEMO Harbor Supply Co (Seattle)
- DEMO Harbor Supply Co (Tacoma)

Check one account's children:

```sql
SELECT COUNT() FROM Opportunity WHERE Account.Name = 'DEMO Lakeshore Medical Group'
```

Expected: 9 opportunities

---

## What you have now

- 4 custom objects in the org
- 5 accounts, 13 contacts, 18 opportunities, 5 quotes, 18 orders, 6 cases
- 2 SOWs, 2 Customer Programs, 8 price agreements, 2 account priorities
- A permission set ready to assign (needs Apex class access in Exercise 2)

**Next:** [Exercise 2: Build the Apex action](08-exercise-apex-action.md)

---

[Index](README.md) · [← Previous: Architecture](06-architecture-skills-and-code.md) · [Next: Exercise 2: Apex action →](08-exercise-apex-action.md)
