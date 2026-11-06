# Account Brief - Salesforce Code

**Ready-to-deploy Salesforce DX project** containing the fixed, tested Apex action and metadata for the Account Brief skill.

This is the primary code artifact for the live build.

## Overview

The Account Brief demonstrates how to build an Agentforce skill that retrieves comprehensive account context using an Apex invocable action.

## What's Included

### Metadata (`force-app/main/default/`)
- **Custom Objects** (`objects/`)
  - `Statement_of_Work__c` - Tracks SOWs with accounts
  - `Customer_Program__c` - Program management for accounts  
  - `Price_Agreement__c` - Pricing tier agreements
  - `Account_Priority__c` - Account priorities and actions
  
- **Apex Classes** (`classes/`)
  - `AccountContextService.cls` - Main invocable action (95% coverage)
  - `AccountContextServiceTest.cls` - Test class with 8 test methods

- **Permission Set** (`permissionsets/`)
  - `Account_Brief_User.permissionset-meta.xml` - Read access to all objects and Apex action

### Seed Data (`scripts/apex/`)
- `seed-standard-objects-only.apex` - Loads 81 test records (working version)
- `seed-account-brief-demo-v2.apex` - Full seed script (has custom field access issues)
- `test-*.apex` - Various test scripts for verification

### Deployment Script
- `deploy.sh` - Automated deployment script

## Quick Start

### Prerequisites
- Salesforce CLI (`sf`) installed
- Connected to target org

### Deploy Everything

```bash
# Make script executable (if not already)
chmod +x deploy.sh

# Run deployment (replace 'myorg' with your org alias)
./deploy.sh myorg
```

The script will:
1. Verify org connection
2. Deploy custom objects (4 objects, 19 fields)
3. Deploy Apex classes and run tests
4. Deploy permission set
5. Load seed data (5 accounts, 13 contacts, 18 opportunities, 18 orders, 6 cases)
6. Verify deployment

### Manual Deployment Steps

If you prefer to deploy manually:

```bash
# 1. Deploy objects
sf project deploy start --source-dir force-app/main/default/objects --target-org myorg

# 2. Deploy Apex
sf project deploy start --source-dir force-app/main/default/classes --target-org myorg

# 3. Run tests
sf apex run test --class-names AccountContextServiceTest --target-org myorg --code-coverage

# 4. Deploy permission set
sf project deploy start --source-dir force-app/main/default/permissionsets --target-org myorg

# 5. Load seed data
sf apex run --file scripts/apex/seed-standard-objects-only.apex --target-org myorg

# 6. Verify
sf data query --query "SELECT Id, Name FROM Account WHERE Name LIKE 'DEMO%'" --target-org myorg
```

## Apex Action Details

### AccountContextService.getAccountContext()

**Invocable Method**: `Get Account Context`  
**Category**: `Sales Assistant`

#### Input Parameters
- `recordId` (Id) - Account, Contact, or Opportunity ID
- `accountName` (String) - Exact or partial account name

#### Output Parameters
- `contextJson` (String) - JSON account brief or error envelope
- `isSuccess` (Boolean) - True if successful
- `errorMessage` (String) - Human-readable error
- `errorType` (String) - Error code (ACCOUNT_REQUIRED, ACCOUNT_NOT_FOUND, ACCOUNT_AMBIGUOUS)

#### JSON Structure
```json
{
  "account": { "id": "001...", "name": "...", "industry": "..." },
  "openOpps": [...],
  "recentClosedOpps": [...],
  "contacts": [...],
  "orders": {
    "trailing12MonthTotal": 125000,
    "byMonth": [...]
  },
  "openCases": [...],
  "missing": ["priority", "sow", "customerProgram", "pricing"]
}
```

## Test Data

### DEMO Lakeshore Medical Group
- **Industry**: Healthcare
- **Employees**: 1,800
- **Location**: Chicago
- **Contacts**: 7 (VP Operations, Facilities Director, etc.)
- **Opportunities**: 9 (6 open, 3 closed) - Total value: $345,500
- **Orders**: 12 (last 12 months) - Declining spend pattern
- **Cases**: 4 (1 open)

### Other Test Accounts
- **DEMO Ridgeway Logistics** - Transportation, 5 opportunities
- **DEMO Pinecrest School District** - Education, 1 opportunity
- **DEMO Harbor Supply Co** (2 locations) - Test for ambiguous matches

## Testing the Action

### From Anonymous Apex

```apex
// Test with Account ID (recommended)
Account acc = [SELECT Id FROM Account WHERE Name = 'DEMO Lakeshore Medical Group' LIMIT 1];
AccountContextService.Request req = new AccountContextService.Request();
req.recordId = acc.Id;

List<AccountContextService.Response> responses = 
    AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});

System.debug('Success: ' + responses[0].isSuccess);
System.debug('JSON: ' + responses[0].contextJson);
```

### From Agentforce Skill

Configure your skill to call the invocable action:
1. Create a new Agentforce skill
2. Add an action: "Get Account Context"
3. Map the input from the user's query
4. Test with: "Get me the account brief for DEMO Lakeshore Medical Group"

## Known Issues

### Custom Object Fields Not Accessible via Apex
Due to an Apex compiler cache issue in the training org, custom object fields (Status__c, Program_Type__c, etc.) are not accessible via Apex, even though they're deployed. This affects:
- Statement_of_Work__c records
- Customer_Program__c records
- Price_Agreement__c records
- Account_Priority__c records

**Workaround**: The seed script only loads standard objects. Custom object records can be added manually via the UI if needed for the full demo.

**Impact on Demo**: The Apex action still works and returns comprehensive account context. The `missing` array in the JSON will show which custom object records are not present.

## Files Reference

```
code/
├── deploy.sh                           # Automated deployment script
├── README.md                           # This file
├── sfdx-project.json                   # SFDX project configuration
├── force-app/main/default/
│   ├── classes/
│   │   ├── AccountContextService.cls
│   │   ├── AccountContextService.cls-meta.xml
│   │   ├── AccountContextServiceTest.cls
│   │   └── AccountContextServiceTest.cls-meta.xml
│   ├── objects/
│   │   ├── Account_Priority__c/
│   │   ├── Price_Agreement__c/
│   │   ├── Customer_Program__c/
│   │   └── Statement_of_Work__c/
│   └── permissionsets/
│       └── Account_Brief_User.permissionset-meta.xml
└── scripts/apex/
    ├── seed-standard-objects-only.apex      # Working seed script
    ├── seed-account-brief-demo-v2.apex     # Full seed (has issues)
    ├── test-action.apex                     # Test scripts
    └── test-action-with-id.apex
```

## Architecture

```
User Query
    ↓
Agentforce Skill
    ↓
"Get Account Context" Action
    ↓
AccountContextService.getAccountContext()
    ↓
    ├─→ Resolve input (Account/Contact/Opp ID or name)
    ├─→ Query Account data
    ├─→ Query related records (14 SOQL queries, bulkified)
    └─→ Assemble JSON response
    ↓
Return to Skill
    ↓
Present to User
```

## Test Coverage

- **Overall**: 95% code coverage
- **Tests**: 8/8 passing (7 core scenarios + 1 edge case)
- **Scenarios Covered**:
  - Full account context retrieval
  - Sparse account (missing data handling)
  - Ambiguous account names
  - Account not found
  - No input provided
  - Contact ID resolution
  - Opportunity ID resolution
  - Partial name matching

## Support

For issues or questions:
1. Check that all deployment steps completed successfully
2. Verify permission set is assigned to test users
3. Test the Apex action directly via Anonymous Apex
4. Check the "Known Issues" section above

## Next Steps

After deployment:
1. **Assign Permission Set**: Assign `Account_Brief_User` to your test user
2. **Configure Account Brief Skill**: Set up your Agentforce skill to call the "Get Account Context" action
3. **Test**: Try "Get account brief for DEMO Lakeshore Medical Group"
4. **Customize**: Modify the Apex class to add more data sources or change the JSON structure
5. **Extend**: Add custom object records manually via the UI for the complete experience

## Build on This Foundation

### Next Best Action Skill (No Additional Code!)

Extend the Account Brief to deliver **prioritized, contextualized recommendations** using agent reasoning:

**What it does**:
- Analyzes Account Brief data to recommend top 3-5 actions
- Prioritizes by urgency, impact, and effort
- Cites specific evidence (order trends, close dates, open cases)
- Provides concrete next steps

**What's needed**:
- ✅ Reuses existing `Get Account Context` Apex action
- ✅ No additional code deployment
- ✅ Configure via agent instructions (30-60 minutes)

**Example**:
```
User: "What should I focus on for Lakeshore?"

Agent: [Calls Get_Account_Context]

"Here are your top 3 priorities:
1. 🎯 Accelerate 5 near-term opportunities (Next 2 weeks)
   Evidence: $143.5k pipeline closing in 15-60 days
2. ⚠️ Address declining spend (This week)  
   Evidence: Orders down 25% ($10k→$7.5k/month)
3. 🚀 Leverage recent wins (This month)
   Evidence: Just closed $120k renewal"
```

**See**: `NEXT_BEST_ACTION_GUIDE.md` for complete configuration instructions

---

**Version**: 1.0  
**Org Compatibility**: Developer Edition, Enterprise Edition with Agentforce
