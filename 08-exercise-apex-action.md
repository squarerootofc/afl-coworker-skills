[Index](README.md) · [← Previous: Exercise 1: Seed data](07-exercise-seed-data.md) · [Next: Exercise 3: Build skill →](09-exercise-build-skill.md)

# Exercise 2: Build the Apex action

**Time:** 60 minutes  
**Tool:** Agentforce Vibes / Claude Code with Salesforce DX MCP  
**Output:** `AccountContextService` deployed and tested

This Apex class is an **@InvocableMethod** that the skill will call. It returns one JSON string with all account data.

> **💡 Fallback available:** If the live build generates buggy Apex, a pre-tested, debugged version exists in the `code/` folder. See [Troubleshooting](12-troubleshooting.md#fallback-use-the-pre-tested-version) for deployment steps.

---

## What the action does

**Input:** `recordId` (Id) OR `accountName` (String)  
**Output:** `contextJson` (String), `isSuccess` (Boolean), `errorType` (String)

The action:
1. Resolves the input to an Account Id (handles Contact/Opportunity lookups)
2. Runs 14 SOQL queries (bulkified, one per object)
3. Assembles a JSON map with: account, priority, openOpps, recentClosedOpps, lastQuote, orders (with trailing12MonthTotal), openCases, sow, customerProgram, pricing, contacts, missing
4. Returns the JSON as a string

**Error cases:**
- No input → `{"error":"ACCOUNT_REQUIRED"}`
- Name not found → `{"error":"ACCOUNT_NOT_FOUND"}`
- 2+ name matches → `{"error":"ACCOUNT_AMBIGUOUS", "candidates":[...]}`

---

## Step 1: Create the Apex class

**Prompt 2A: Build AccountContextService**

Paste into Agentforce Vibes or Claude Code:

```
ROLE
You are a Salesforce Apex developer building an invocable action for
Agentforce skills.

TASK
Create an Apex class AccountContextService with an @InvocableMethod
labeled "Get Account Context" (category "Sales Assistant") that
assembles a JSON account brief.

Requirements:
1. CLASS STRUCTURE
   - public with sharing class AccountContextService
   - Inner class Request with @InvocableVariable fields:
     * recordId (Id, not required): Account/Contact/Opportunity Id
     * accountName (String, not required): exact or partial account name
   - Inner class Response with @InvocableVariable fields:
     * contextJson (String): the JSON brief or error envelope
     * isSuccess (Boolean): false for errors, true for success
     * errorMessage (String): human-readable error
     * errorType (String): ACCOUNT_REQUIRED, ACCOUNT_NOT_FOUND,
       or ACCOUNT_AMBIGUOUS

2. @InvocableMethod signature:
   public static List<Response> getAccountContext(List<Request> requests)

3. RESOLUTION LOGIC (bulkified, 3 queries before loops)
   - Contact Id → resolve to Account via Contact.AccountId
   - Opportunity Id → resolve to Account via Opportunity.AccountId
   - Account name → query Account WHERE Name LIKE '%<name>%'
     * 0 matches → {"error":"ACCOUNT_NOT_FOUND"}, isSuccess=false,
       errorType="ACCOUNT_NOT_FOUND"
     * 1 match → use it
     * 2+ matches → {"error":"ACCOUNT_AMBIGUOUS",
       "candidates":[{id,name}]}, isSuccess=false,
       errorType="ACCOUNT_AMBIGUOUS"
   - No input → {"error":"ACCOUNT_REQUIRED"}, isSuccess=false,
       errorType="ACCOUNT_REQUIRED"

4. DATA QUERIES (11 queries, all WITH USER_MODE)
   After resolving Account Ids, query these objects once for all accounts:
   - Account: Id, Name, Industry, Website, NumberOfEmployees,
     BillingCity, BillingState
   - Account_Priority__c: Priority_Rank__c, Priority_Reason__c,
     Recommended_Action__c, Refreshed_On__c (ORDER BY Priority_Rank__c)
   - Opportunity (open): IsClosed=false, up to 5 per account
     (ORDER BY CloseDate ASC)
   - Opportunity (closed): IsClosed=true, CloseDate in last 365 days,
     up to 5 per account (ORDER BY CloseDate DESC)
   - Quote: most recent per account (ORDER BY CreatedDate DESC, 1 per account)
   - Order: last 12 months (EffectiveDate >= 12 months ago), with first
     OrderItem's Product2.Name via subquery
   - Case: IsClosed=false
   - Statement_of_Work__c: Status__c='Active' (1 per account)
   - Customer_Program__c: (1 per account, earliest Renewal_Date__c)
   - Price_Agreement__c: all for each account
   - Contact: up to 5 per account (ORDER BY Name)

5. JSON STRUCTURE
   Build a Map<String, Object> with these keys:
   - account: {id, name, industry, website, numberOfEmployees,
     billingCity, billingState}
   - priority: [{rank, reason, action, refreshedOn}]
   - openOpps: [{id, name, stage, amount, closeDate}]
   - recentClosedOpps: [{id, name, stage, amount, closeDate}]
   - lastQuote: {id, name, status, expirationDate} or null
   - orders: {trailing12MonthTotal: <sum of TotalAmount>,
     byMonth: [{id, effectiveDate, totalAmount, product}]}
   - openCases: [{id, subject, priority, status}]
   - sow: {id, name, status, startDate, endDate, scopeSummary} or null
   - customerProgram: {id, name, type, renewalDate, coverageSummary} or null
   - pricing: [{id, name, productClass, tier, discountPct, effectiveDate}]
   - contacts: [{id, name, title, email}]
   - missing: ["priority", "sow", ...] (every empty source)

6. ERROR HANDLING
   - For ACCOUNT_REQUIRED, ACCOUNT_NOT_FOUND, ACCOUNT_AMBIGUOUS:
     set isSuccess=false, errorType to the error code,
     contextJson to the error JSON
   - For success: isSuccess=true, errorType=null

7. CONSTANTS
   - MAX_OPPS = 5
   - MAX_CONTACTS = 5
   - TWELVE_MONTHS_AGO = Date.today().addMonths(-12).toStartOfMonth()

EXPECTED OUTPUT
1. File created: force-app/main/default/classes/AccountContextService.cls
2. File created: force-app/main/default/classes/AccountContextService.cls-meta.xml
3. Class compiles with 0 errors
4. One-line summary

RULES
- Use WITH USER_MODE on every SOQL query (respects sharing and FLS)
- Bulkify: query each object once for all accounts, not once per account
- Handle null safely (check for null before accessing fields)
- Return isSuccess=false for all error cases (REQUIRED, NOT_FOUND, AMBIGUOUS)
- Use LIKE matching for account names so "Lakeshore" matches
  "DEMO Lakeshore Medical Group"
- Do not write the test class yet (that's Prompt 2B)

EXAMPLE OUTPUT
AccountContextService created: 450 lines, 14 SOQL queries, bulkified.
Meta file created (API version 68.0).
```

**What to check:**
- Class compiles with 0 errors
- Contains @InvocableMethod with label "Get Account Context"
- Has Request and Response inner classes
- Uses WITH USER_MODE on all queries

**If it fails:**
- **Account__c not found:** Custom objects didn't deploy. Re-run Exercise 1 Prompt 1A.
- **Syntax error:** Review the generated code for typos.

---

## Step 2: Write the test class

**Prompt 2B: Create test class**

```
ROLE
You are a Salesforce Apex developer writing unit tests.

TASK
Create a test class AccountContextServiceTest that covers all paths
in AccountContextService with at least 90% code coverage.

Test setup (@TestSetup):
- 1 Product2 + PricebookEntry
- 3 test accounts:
  * "QCSSTest Full Account" (has every child object)
  * "QCSSTest Sparse Account" (only 1 Opportunity, missing most sources)
  * "QCSSTest Ambiguous Dupe" (duplicate name, 2 accounts)
- 2 Contacts for Full Account
- 6 Opportunities for Full Account (3 open, 3 closed in last year)
- 1 Quote for Full Account
- 12 Orders for Full Account (one per month, last 12 months)
- 12 OrderItems (one per order)
- 1 Case (open) for Full Account
- 1 Statement_of_Work__c (Active) for Full Account
- 1 Customer_Program__c for Full Account
- 2 Price_Agreement__c for Full Account
- 2 Account_Priority__c for Full Account (rank 1 and 2)
- 1 Opportunity for Sparse Account (open)
- 2 Accounts with name "QCSSTest Ambiguous Dupe"

Test methods:
1. shouldReturnFullContext_WhenFullAccountIdProvided
   - Pass Full Account Id as recordId
   - Assert: isSuccess=true, all 8 sources present, missing=[]
   - Assert: trailing12MonthTotal > 0 and matches sum of orders
   - Assert: priority has 2 entries
   - Assert: openOpps has 3 entries
   - Assert: contacts has 2 entries

2. shouldReturnSparseContext_WhenSparseAccountIdProvided
   - Pass Sparse Account Id as recordId
   - Assert: isSuccess=true, most sources in missing array

3. shouldReturnAmbiguous_WhenDuplicateAccountNameProvided
   - Pass "QCSSTest Ambiguous Dupe" as accountName
   - Assert: isSuccess=false, errorType='ACCOUNT_AMBIGUOUS'
   - Assert: contextJson contains "candidates" with 2 entries

4. shouldReturnNotFound_WhenAccountNameNotFound
   - Pass "QCSS_DOES_NOT_EXIST_XYZ_99999" as accountName
   - Assert: isSuccess=false, errorType='ACCOUNT_NOT_FOUND'

5. shouldReturnAccountRequired_WhenNoInputProvided
   - Pass empty Request (no recordId, no accountName)
   - Assert: isSuccess=false, errorType='ACCOUNT_REQUIRED'

6. shouldResolveToAccount_WhenContactIdProvided
   - Pass Contact Id as recordId
   - Assert: resolves to Full Account, isSuccess=true

7. shouldResolveToAccount_WhenOpportunityIdProvided
   - Pass Opportunity Id as recordId
   - Assert: resolves to Full Account, isSuccess=true

8. shouldMatchPartialName_WhenPartialAccountNameProvided
   - Pass "Full Account" as accountName (partial, no "QCSSTest" prefix)
   - Assert: isSuccess=true, resolves to Full Account

EXPECTED OUTPUT
1. File created: force-app/main/default/classes/AccountContextServiceTest.cls
2. All 8 test methods pass
3. Code coverage: 90% or higher
4. Summary: X tests pass, Y% coverage

RULES
- Use @TestSetup to create data once
- Use Test.startTest() and Test.stopTest() in each test method
- Use Assert.isTrue, Assert.areEqual, Assert.isNotNull (not System.assert)
- Check JSON keys exist before asserting values
- Make sure trailing12MonthTotal is computed correctly (sum all orders)

EXAMPLE OUTPUT
AccountContextServiceTest created: 8 test methods, 90% coverage.
All tests pass.
```

**What to check:**
- All 8 tests pass
- Coverage ≥ 90%
- Tests cover ACCOUNT_REQUIRED, ACCOUNT_NOT_FOUND, ACCOUNT_AMBIGUOUS

**If it fails:**
- **Test fails:** Check the assertion. The JSON keys might differ from what the test expects.
- **Coverage < 90%:** Add tests for uncovered branches (null handling, empty lists).

---

## Step 3: Deploy and run tests

**Prompt 2C: Deploy and test**

```
ROLE
You are a Salesforce developer deploying Apex to the org.

TASK
1. Deploy AccountContextService and AccountContextServiceTest
   to the org
2. Run the test class with code coverage
3. Show the results

EXPECTED OUTPUT
1. Deploy succeeded: 2 classes
2. Test results: X/X pass, Y% coverage
3. One-line summary

RULES
- Deploy both classes together (not one at a time)
- Run tests with --code-coverage flag
- Show any failures with line numbers

EXAMPLE OUTPUT
Deploy succeeded: 2 Apex classes, 0 errors.
Tests: 8/8 pass, 92% coverage.
```

**What to check:**
- Deploy succeeds
- All tests pass
- Coverage ≥ 90%

---

## Step 4: Add Apex class access to the permission set

The permission set from Exercise 1 has no Apex class access. Without it, a non-admin seller will get `INSUFFICIENT_ACCESS`.

**Prompt 2D: Grant Apex class access**

```
ROLE
You are a Salesforce admin managing permission sets.

TASK
Update the Account_Brief_User permission set to grant Apex class
access to AccountContextService, then redeploy it.

EXPECTED OUTPUT
1. Permission set updated (show the classAccesses block)
2. Redeployed to the org
3. One-line confirmation

RULES
- Add a <classAccesses> block with:
  <apexClass>AccountContextService</apexClass>
  <enabled>true</enabled>
- Do not change existing object permissions

EXAMPLE OUTPUT
Permission set updated: added AccountContextService to classAccesses.
Redeployed successfully.
```

**What to check:**
- Permission set XML now has a `<classAccesses>` block
- Redeploy succeeds

---

## Step 5: Test the action manually

Run this Apex script to confirm the action works:

```apex
// Test: Full account (Lakeshore)
AccountContextService.Request req = new AccountContextService.Request();
req.accountName = 'Lakeshore';
List<AccountContextService.Response> resp =
    AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
System.debug('=== LAKESHORE ===');
System.debug('isSuccess: ' + resp[0].isSuccess);
System.debug('errorType: ' + resp[0].errorType);
System.debug('JSON length: ' + resp[0].contextJson.length());
System.debug('JSON preview: ' + resp[0].contextJson.substring(0, 200));
```

Expected output:
```
isSuccess: true
errorType: null
JSON length: ~3000–5000 characters
JSON preview: {"account":{"id":"001...","name":"DEMO Lakeshore Medical Group",...
```

---

## What you have now

- `AccountContextService` deployed with 90%+ coverage
- `Account_Brief_User` permission set grants Apex class access
- The action returns a complete JSON brief for Lakeshore in one call

**Next:** [Exercise 3: Build the Coworker skill](09-exercise-build-skill.md)

---

[Index](README.md) · [← Previous: Exercise 1: Seed data](07-exercise-seed-data.md) · [Next: Exercise 3: Build skill →](09-exercise-build-skill.md)
