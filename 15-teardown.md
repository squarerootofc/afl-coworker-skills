[Index](README.md) · [← Previous: Next steps](14-next-steps.md)

# 15. Teardown: Clean up the demo

**⚠️ WARNING: DESTRUCTIVE OPERATIONS**

This removes all demo artifacts from the org. Only run this:
- ✅ In a **sandbox or Developer Edition org**
- ✅ After the session is complete
- ✅ When you want to reset and run the demo again

**DO NOT run in Production.**

---

## Before you start

Confirm the org type:

```sql
SELECT IsSandbox, OrganizationType FROM Organization
```

**If `IsSandbox = false` and this is not a Developer Edition org, STOP.**

---

## Teardown prompts

Paste these prompts **in order**. Each one waits for confirmation before executing.

---

## Step 1: Delete the Coworker skill

**⚠️ Manual step** — Skills cannot be deleted via CLI yet.

1. Open **Coworker > Skills > My Skills**
2. Find **Account Brief**
3. Click the **⋮** menu (three dots)
4. Select **Delete**
5. Confirm

Or:

1. **Agentforce Studio > Skills**
2. Find **Account Brief**
3. **Delete**

---

## Step 2: Delete all DEMO records

**Prompt 15A: Delete DEMO data**

```
ROLE
You are a Salesforce developer cleaning up test data.

TASK
Delete all records created by the demo seed script in this order:
1. Delete all Account_Priority__c records where Account__r.Name LIKE 'DEMO %'
2. Delete all Price_Agreement__c records where Account__r.Name LIKE 'DEMO %'
3. Delete all Customer_Program__c records where Account__r.Name LIKE 'DEMO %'
4. Delete all Statement_of_Work__c records where Account__r.Name LIKE 'DEMO %'
5. Delete all Cases where Account.Name LIKE 'DEMO %'
6. Delete all OrderItems where Order.Account.Name LIKE 'DEMO %'
7. Delete all Orders where Account.Name LIKE 'DEMO %'
8. Delete all Quotes where Opportunity.Account.Name LIKE 'DEMO %'
9. Delete all Opportunities where Account.Name LIKE 'DEMO %'
10. Delete all Contacts where Account.Name LIKE 'DEMO %'
11. Delete all Accounts where Name LIKE 'DEMO %'
12. Delete all PricebookEntries where Product2.Name LIKE 'DEMO %'
    (excluding standard pricebook if protected)
13. Delete all Products where Name LIKE 'DEMO %'

EXPECTED OUTPUT
1. Confirmation prompt showing record counts before deletion
2. After deletion: a table (object, count deleted, status)
3. Verification: SOQL to confirm 0 DEMO records remain

RULES
- Query each object first and show counts for my approval before deleting
- Delete in the order above (respects parent-child relationships)
- Use DELETE DML (not hard delete / ALL ROWS)
- Skip PricebookEntries if they're in the standard pricebook and protected
- After deletion, verify: 
  SELECT COUNT() FROM Account WHERE Name LIKE 'DEMO %' returns 0

EXAMPLE OUTPUT
Confirmation: Found 100 DEMO records to delete.
- 5 Accounts
- 13 Contacts
- 18 Opportunities
- ... (full list)

Type 'yes' to proceed.

[After yes:]
Deleted 100 records:
- Account_Priority__c: 2 deleted
- Price_Agreement__c: 8 deleted
- ... (full list)
- Accounts: 5 deleted

Verification: 0 DEMO records remain.
```

**What to check:**
- Prompt shows correct counts before deletion
- All deletes succeed with 0 errors
- Verification query returns 0

**If it fails:**
- **Protected records error:** Some records might have dependencies. Delete child records first.
- **Cannot delete pricebook entries:** Skip them; they're not critical to clean up.

---

## Step 3: Delete the permission set

**Prompt 15B: Delete permission set**

```
ROLE
You are a Salesforce admin cleaning up metadata.

TASK
Delete the Account_Brief_User permission set from the org.

Steps:
1. Check if the permission set is assigned to any users
2. If assigned: unassign it from all users first
3. Delete the permission set metadata file
4. Deploy the deletion to the org

EXPECTED OUTPUT
1. List of users assigned (if any)
2. After unassignment: "Permission set unassigned from X users"
3. After deletion: "Permission set deleted successfully"

RULES
- Unassign from all users before deleting
- Use `sf project delete source` or delete the file and deploy
- Confirm: Setup > Permission Sets shows no "Account_Brief_User"

EXAMPLE OUTPUT
Account_Brief_User is assigned to 2 users: admin@example.com, seller@example.com
Unassigning...
Unassigned from 2 users.
Deleting permission set metadata...
Permission set deleted successfully.
```

**What to check:**
- Permission set no longer appears in Setup > Permission Sets

---

## Step 4: Delete the Apex classes

**Prompt 15C: Delete Apex classes**

```
ROLE
You are a Salesforce developer removing Apex code.

TASK
Delete these Apex classes from the org:
- AccountContextService
- AccountContextServiceTest

EXPECTED OUTPUT
1. Confirmation: "Found 2 Apex classes to delete"
2. After deletion: "2 classes deleted successfully"
3. Verification: Setup > Apex Classes shows neither class

RULES
- Delete both the .cls and .cls-meta.xml files
- Deploy the deletion using `sf project delete source` or equivalent
- Confirm: Setup > Apex Classes > search "AccountContext" returns 0 results

EXAMPLE OUTPUT
Found 2 Apex classes to delete:
- AccountContextService
- AccountContextServiceTest

Type 'yes' to proceed.

[After yes:]
Deleting classes...
Deploy succeeded: 2 components deleted.
Verification: 0 AccountContext classes remain.
```

**What to check:**
- Setup > Apex Classes shows no AccountContextService classes

---

## Step 5: Delete the custom objects

**Prompt 15D: Delete custom objects**

```
ROLE
You are a Salesforce developer removing custom metadata.

TASK
Delete these 4 custom objects from the org:
- Statement_of_Work__c
- Customer_Program__c
- Price_Agreement__c
- Account_Priority__c

EXPECTED OUTPUT
1. Confirmation: "Found 4 custom objects to delete (with X total fields)"
2. After deletion: "4 objects deleted successfully"
3. Verification: Setup > Object Manager shows none of these objects

RULES
- Confirm all DEMO records are already deleted (Prompt 15A)
- Delete the object metadata folders
- Deploy the deletion to the org
- Some orgs protect custom objects; if deletion fails, leave them (they're empty)

EXAMPLE OUTPUT
Found 4 custom objects to delete:
- Statement_of_Work__c (7 fields)
- Customer_Program__c (6 fields)
- Price_Agreement__c (6 fields)
- Account_Priority__c (6 fields)

Type 'yes' to proceed.

[After yes:]
Deleting objects...
Deploy succeeded: 4 objects deleted (25 total components including fields).
Verification: Setup > Object Manager shows none of the 4 demo custom objects.
```

**What to check:**
- Setup > Object Manager > search shows no Statement_of_Work__c, Customer_Program__c, Price_Agreement__c, or Account_Priority__c

**If it fails:**
- **Cannot delete: Object in use:** The object might be referenced in a report, dashboard, or Flow. Find and remove those first.
- **Permission denied:** You might not have Delete Metadata permission. Contact an admin.

---

## Step 6: Verify clean slate

Run these SOQL queries to confirm everything is removed:

```sql
-- Should return 0
SELECT COUNT() FROM Account WHERE Name LIKE 'DEMO %'

-- Should return 0
SELECT COUNT() FROM Product2 WHERE Name LIKE 'DEMO %'
```

Check Setup:
- [ ] Object Manager: No Statement_of_Work__c, Customer_Program__c, Price_Agreement__c, Account_Priority__c
- [ ] Apex Classes: No AccountContextService
- [ ] Permission Sets: No Account_Brief_User
- [ ] Skills: No "Account Brief" skill

---

## Optional: Remove local metadata files

If you want to clean up your local `force-app` directory too:

```bash
cd /path/to/your/dx-project

# Remove Apex classes
rm -rf force-app/main/default/classes/AccountContextService*

# Remove custom objects
rm -rf force-app/main/default/objects/Statement_of_Work__c
rm -rf force-app/main/default/objects/Customer_Program__c
rm -rf force-app/main/default/objects/Price_Agreement__c
rm -rf force-app/main/default/objects/Account_Priority__c

# Remove permission set
rm -rf force-app/main/default/permissionsets/Account_Brief_User*

# Remove seed script (optional)
rm -f scripts/apex/seed-account-brief-demo.apex

# Verify
git status  # Should show deleted files
```

---

## What you have now

- ✅ Org is clean (0 DEMO records, 0 custom objects, 0 Apex classes)
- ✅ Ready to run the demo again from scratch
- ✅ No orphaned metadata

**To rebuild:** Start from [Exercise 1: Seed data](07-exercise-seed-data.md)

---

## Safety checklist before tearing down

Only proceed if **all** of these are true:

- [ ] I confirmed `IsSandbox = true` or this is a Developer Edition org
- [ ] I exported any data I want to keep
- [ ] I am not in Production
- [ ] I am not in a shared sandbox with other teams
- [ ] I verified the DEMO accounts are test data (not real customer names)
- [ ] The session is complete and I don't need the data anymore

---

[Index](README.md) · [← Previous: Next steps](14-next-steps.md)
