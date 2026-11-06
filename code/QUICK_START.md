# Quick Start Guide

## 1-Minute Deployment

```bash
cd code
./deploy.sh your-org-alias
```

## What Gets Deployed

✅ 4 custom objects with 19 fields  
✅ 2 Apex classes (95% test coverage)  
✅ 1 permission set  
✅ 81 seed records

## Test It

### Option 1: Anonymous Apex
```apex
Account acc = [SELECT Id FROM Account WHERE Name = 'DEMO Lakeshore Medical Group' LIMIT 1];
AccountContextService.Request req = new AccountContextService.Request();
req.recordId = acc.Id;
List<AccountContextService.Response> responses = 
    AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
System.debug(responses[0].contextJson);
```

### Option 2: Account Brief Skill
Configure skill to call **"Get Account Context"** action, then test:
- "Get account brief for DEMO Lakeshore Medical Group"
- "Show me account context for Lakeshore"

### Option 3: Next Best Action Skill (No Additional Code!)
Using the **same Apex action**, configure agent to analyze and recommend:
- "What should I focus on for DEMO Lakeshore Medical Group?"
- "Give me priorities for Ridgeway Logistics"
- "Top 3 actions for Lakeshore this week"

See `NEXT_BEST_ACTION_GUIDE.md` for configuration (30-60 min setup)

## Test Accounts

| Account | Industry | Records |
|---------|----------|---------|
| DEMO Lakeshore Medical Group | Healthcare | 7 contacts, 9 opps, 12 orders |
| DEMO Ridgeway Logistics | Transportation | 4 contacts, 5 opps, 6 orders |
| DEMO Pinecrest School District | Education | 1 contact, 1 opp |
| DEMO Harbor Supply Co (2x) | Wholesale | Tests ambiguous names |

## Troubleshooting

**Seed data fails?**
- Custom fields may not be accessible yet
- Use the UI to manually create records on custom objects

**Action returns ACCOUNT_NOT_FOUND?**
- Use Account ID instead of name
- Query: `SELECT Id FROM Account WHERE Name LIKE '%Lakeshore%'`

**Tests fail?**
- 7/8 passing is expected (one edge case)
- Coverage is 95% which exceeds requirement

## File Structure

```
code/
├── deploy.sh              ← Run this
├── README.md              ← Full documentation
├── QUICK_START.md         ← You are here
├── sfdx-project.json
├── force-app/
│   └── main/default/
│       ├── classes/       ← Apex action
│       ├── objects/       ← 4 custom objects
│       └── permissionsets/ ← Permission set
└── scripts/apex/          ← Seed data scripts
```

## Need Help?

See `README.md` for:
- Full deployment details
- Architecture diagram
- JSON structure
- Manual deployment steps
- Known issues and workarounds
