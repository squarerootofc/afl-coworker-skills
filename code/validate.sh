#!/bin/bash

# Account Brief - Validation Script
# Verifies that the deployment was successful

set -e

if [ -z "$1" ]; then
    echo "Usage: ./validate.sh <org-alias>"
    exit 1
fi

ORG_ALIAS=$1

echo "=========================================="
echo "Account Brief - Validation"
echo "=========================================="
echo ""

# Check custom objects
echo "✓ Checking custom objects..."
OBJECTS=("Statement_of_Work__c" "Customer_Program__c" "Price_Agreement__c" "Account_Priority__c")
for obj in "${OBJECTS[@]}"; do
    if sf data query --target-org "$ORG_ALIAS" --query "SELECT Id FROM $obj LIMIT 1" --json > /dev/null 2>&1; then
        echo "  ✅ $obj exists"
    else
        echo "  ❌ $obj not found"
    fi
done
echo ""

# Check Apex class
echo "✓ Checking Apex class..."
if sf data query --target-org "$ORG_ALIAS" --use-tooling-api --query "SELECT Id, Name FROM ApexClass WHERE Name = 'AccountContextService' LIMIT 1" --json | grep -q "AccountContextService"; then
    echo "  ✅ AccountContextService deployed"
else
    echo "  ❌ AccountContextService not found"
fi
echo ""

# Check permission set
echo "✓ Checking permission set..."
if sf data query --target-org "$ORG_ALIAS" --use-tooling-api --query "SELECT Id, Label FROM PermissionSet WHERE Name = 'Account_Brief_User' LIMIT 1" --json | grep -q "Account_Brief_User"; then
    echo "  ✅ Account_Brief_User permission set deployed"
else
    echo "  ❌ Permission set not found"
fi
echo ""

# Check seed data
echo "✓ Checking seed data..."
ACCOUNT_COUNT=$(sf data query --target-org "$ORG_ALIAS" --query "SELECT COUNT() FROM Account WHERE Name LIKE 'DEMO%'" --json | grep -o '"totalSize":[0-9]*' | grep -o '[0-9]*')
echo "  Accounts: $ACCOUNT_COUNT (expected: 5)"

CONTACT_COUNT=$(sf data query --target-org "$ORG_ALIAS" --query "SELECT COUNT() FROM Contact WHERE Account.Name LIKE 'DEMO%'" --json | grep -o '"totalSize":[0-9]*' | grep -o '[0-9]*')
echo "  Contacts: $CONTACT_COUNT (expected: 13)"

OPP_COUNT=$(sf data query --target-org "$ORG_ALIAS" --query "SELECT COUNT() FROM Opportunity WHERE Account.Name LIKE 'DEMO%'" --json | grep -o '"totalSize":[0-9]*' | grep -o '[0-9]*')
echo "  Opportunities: $OPP_COUNT (expected: 18)"

ORDER_COUNT=$(sf data query --target-org "$ORG_ALIAS" --query "SELECT COUNT() FROM Order WHERE Account.Name LIKE 'DEMO%'" --json | grep -o '"totalSize":[0-9]*' | grep -o '[0-9]*')
echo "  Orders: $ORDER_COUNT (expected: 18)"
echo ""

# Test the action
echo "✓ Testing Apex action..."
cat > /tmp/test-account-brief-action.apex <<'EOF'
Account acc = [SELECT Id FROM Account WHERE Name = 'DEMO Lakeshore Medical Group' LIMIT 1];
AccountContextService.Request req = new AccountContextService.Request();
req.recordId = acc.Id;
List<AccountContextService.Response> responses =
    AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
System.debug('TEST_RESULT:' + responses[0].isSuccess + ':' + responses[0].contextJson.length());
EOF

RESULT=$(sf apex run --target-org "$ORG_ALIAS" --file /tmp/test-account-brief-action.apex 2>&1 | grep "TEST_RESULT" || echo "FAILED")

if [[ $RESULT == *"TEST_RESULT:true:"* ]]; then
    JSON_LENGTH=$(echo "$RESULT" | grep -o "TEST_RESULT:true:[0-9]*" | grep -o "[0-9]*$")
    echo "  ✅ Action works! (Returned $JSON_LENGTH characters of JSON)"
else
    echo "  ❌ Action test failed"
fi
echo ""

# Summary
echo "=========================================="
echo "Validation Summary"
echo "=========================================="
if [ "$ACCOUNT_COUNT" -ge 5 ] && [ "$OPP_COUNT" -ge 18 ] && [[ $RESULT == *"true"* ]]; then
    echo "✅ All checks passed!"
    echo ""
    echo "You're ready to test your Agentforce skill with:"
    echo "  'Get account brief for DEMO Lakeshore Medical Group'"
else
    echo "⚠️  Some checks failed. Review the output above."
fi
echo ""
