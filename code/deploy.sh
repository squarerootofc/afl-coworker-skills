#!/bin/bash

# Account Brief - Complete Deployment Script
# This script deploys all metadata and loads seed data for the Account Brief demo

set -e  # Exit on error

echo "=========================================="
echo "Account Brief - Deployment Script"
echo "=========================================="
echo ""

# Check if org alias is provided
if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh <org-alias-or-username>"
    echo "Example: ./deploy.sh myorg"
    exit 1
fi

ORG_ALIAS=$1

echo "Target Org: $ORG_ALIAS"
echo ""

# Verify org connection
echo "Step 1: Verifying org connection..."
if ! sf org display --target-org "$ORG_ALIAS" > /dev/null 2>&1; then
    echo "❌ Error: Cannot connect to org '$ORG_ALIAS'"
    echo "Please run: sf org login web --alias $ORG_ALIAS"
    exit 1
fi
echo "✅ Connected to org"
echo ""

# Deploy custom objects
echo "Step 2: Deploying custom objects..."
sf project deploy start \
    --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/objects
echo "✅ Custom objects deployed"
echo ""

# Deploy Apex classes
echo "Step 3: Deploying Apex classes..."
sf project deploy start \
    --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/classes
echo "✅ Apex classes deployed"
echo ""

# Run tests
echo "Step 4: Running Apex tests..."
sf apex run test \
    --target-org "$ORG_ALIAS" \
    --class-names AccountContextServiceTest \
    --result-format human \
    --code-coverage \
    --wait 10
echo "✅ Tests completed"
echo ""

# Deploy permission set
echo "Step 5: Deploying permission set..."
sf project deploy start \
    --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/permissionsets
echo "✅ Permission set deployed"
echo ""

# Load seed data
echo "Step 6: Loading seed data..."
sf apex run \
    --target-org "$ORG_ALIAS" \
    --file scripts/apex/seed-standard-objects-only.apex
echo "✅ Seed data loaded"
echo ""

# Verify data
echo "Step 7: Verifying deployment..."
ACCOUNT_COUNT=$(sf data query \
    --target-org "$ORG_ALIAS" \
    --query "SELECT COUNT() FROM Account WHERE Name LIKE 'DEMO%'" \
    --json | grep -o '"totalSize":[0-9]*' | grep -o '[0-9]*')

echo "Found $ACCOUNT_COUNT DEMO accounts"

if [ "$ACCOUNT_COUNT" -ge 5 ]; then
    echo "✅ Verification passed"
else
    echo "⚠️  Warning: Expected 5 accounts, found $ACCOUNT_COUNT"
fi
echo ""

# Summary
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "What was deployed:"
echo "  • 4 custom objects (Statement_of_Work__c, Customer_Program__c, Price_Agreement__c, Account_Priority__c)"
echo "  • 19 custom fields across all objects"
echo "  • 2 Apex classes (AccountContextService + Test)"
echo "  • 1 permission set (Account_Brief_User)"
echo "  • 81 seed records (Accounts, Contacts, Opportunities, Orders, Cases)"
echo ""
echo "Next steps:"
echo "  1. Assign the 'Account_Brief_User' permission set to test users"
echo "  2. Test the Apex action: AccountContextService.getAccountContext()"
echo "  3. Configure your Agentforce skill to call the 'Get Account Context' action"
echo "  4. Test with: 'Get account brief for DEMO Lakeshore Medical Group'"
echo ""
echo "Test account: DEMO Lakeshore Medical Group"
echo "  - 7 contacts"
echo "  - 9 opportunities (6 open, 3 closed)"
echo "  - 12 orders"
echo "  - 4 cases"
echo ""
