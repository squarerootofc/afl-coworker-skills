/**
 * AccountContextServiceTest
 * Test class for AccountContextService with 90%+ coverage
 */
@isTest
private class AccountContextServiceTest {

    @TestSetup
    static void setup() {
        // Products and Pricebook
        Product2 prod = new Product2(Name='Test Product', IsActive=true);
        insert prod;

        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id=stdPricebookId,
            Product2Id=prod.Id,
            UnitPrice=100,
            IsActive=true
        );
        insert pbe;

        // Accounts
        Account fullAccount = new Account(
            Name='QCSSTest Full Account',
            Industry='Technology'
        );
        Account sparseAccount = new Account(
            Name='QCSSTest Sparse Account',
            Industry='Retail'
        );
        Account ambiguous1 = new Account(Name='QCSSTest Ambiguous Dupe');
        Account ambiguous2 = new Account(Name='QCSSTest Ambiguous Dupe');
        insert new List<Account>{fullAccount, sparseAccount, ambiguous1, ambiguous2};

        // Contacts
        insert new List<Contact>{
            new Contact(AccountId=fullAccount.Id, FirstName='John', LastName='Doe', Email='jdoe@test.com'),
            new Contact(AccountId=fullAccount.Id, FirstName='Jane', LastName='Smith', Email='jsmith@test.com')
        };

        // Opportunities
        List<Opportunity> opps = new List<Opportunity>();
        Date today = Date.today();
        // Open opportunities for Full Account
        for (Integer i = 0; i < 3; i++) {
            opps.add(new Opportunity(
                AccountId=fullAccount.Id,
                Name='Full Open Opp ' + i,
                StageName='Prospecting',
                CloseDate=today.addDays(30),
                Amount=10000
            ));
        }
        // Closed opportunities for Full Account
        for (Integer i = 0; i < 3; i++) {
            opps.add(new Opportunity(
                AccountId=fullAccount.Id,
                Name='Full Closed Opp ' + i,
                StageName='Closed Won',
                CloseDate=today.addMonths(-1),
                Amount=5000
            ));
        }
        // One open opp for Sparse Account
        opps.add(new Opportunity(
            AccountId=sparseAccount.Id,
            Name='Sparse Opp',
            StageName='Prospecting',
            CloseDate=today.addDays(30),
            Amount=1000
        ));
        insert opps;

        // Orders
        List<Order> orders = new List<Order>();
        for (Integer i = 1; i <= 12; i++) {
            orders.add(new Order(
                AccountId=fullAccount.Id,
                EffectiveDate=today.addMonths(-i).toStartOfMonth(),
                Status='Draft',
                Pricebook2Id=stdPricebookId
            ));
        }
        insert orders;

        // OrderItems
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order ord : orders) {
            orderItems.add(new OrderItem(
                OrderId=ord.Id,
                Product2Id=prod.Id,
                PricebookEntryId=pbe.Id,
                Quantity=1,
                UnitPrice=1000
            ));
        }
        insert orderItems;

        // Activate orders
        for (Order ord : orders) {
            ord.Status = 'Activated';
        }
        update orders;

        // Cases
        insert new Case(
            AccountId=fullAccount.Id,
            Subject='Test Case',
            Status='Open'
        );
    }

    @isTest
    static void shouldReturnFullContext_WhenFullAccountIdProvided() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'QCSSTest Full Account' LIMIT 1];

        AccountContextService.Request req = new AccountContextService.Request();
        req.recordId = acc.Id;

        Test.startTest();
        List<AccountContextService.Response> responses =
            AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        AccountContextService.Response resp = responses[0];

        Assert.isTrue(resp.isSuccess, 'Should be successful');
        Assert.isNull(resp.errorType, 'Error type should be null');
        Assert.isNotNull(resp.contextJson, 'Context JSON should not be null');

        // Parse JSON to verify structure
        Map<String, Object> context = (Map<String, Object>)JSON.deserializeUntyped(resp.contextJson);

        Assert.isTrue(context.containsKey('account'), 'Should have account');
        Assert.isTrue(context.containsKey('openOpps'), 'Should have open opportunities');
        Assert.isTrue(context.containsKey('recentClosedOpps'), 'Should have closed opportunities');
        Assert.isTrue(context.containsKey('contacts'), 'Should have contacts');
        Assert.isTrue(context.containsKey('orders'), 'Should have orders');

        // Verify open opps count
        List<Object> openOpps = (List<Object>)context.get('openOpps');
        Assert.areEqual(3, openOpps.size(), 'Should have 3 open opportunities');

        // Verify contacts count
        List<Object> contacts = (List<Object>)context.get('contacts');
        Assert.areEqual(2, contacts.size(), 'Should have 2 contacts');

        // Verify orders
        Map<String, Object> ordersData = (Map<String, Object>)context.get('orders');
        Assert.isNotNull(ordersData, 'Orders data should not be null');
        Assert.isTrue(ordersData.containsKey('trailing12MonthTotal'), 'Should have trailing12MonthTotal');
        Decimal total = (Decimal)ordersData.get('trailing12MonthTotal');
        Assert.isTrue(total > 0, 'Trailing 12 month total should be greater than 0');
    }

    @isTest
    static void shouldReturnSparseContext_WhenSparseAccountIdProvided() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'QCSSTest Sparse Account' LIMIT 1];

        AccountContextService.Request req = new AccountContextService.Request();
        req.recordId = acc.Id;

        Test.startTest();
        List<AccountContextService.Response> responses =
            AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        AccountContextService.Response resp = responses[0];

        Assert.isTrue(resp.isSuccess, 'Should be successful');
        Assert.isNotNull(resp.contextJson, 'Context JSON should not be null');

        Map<String, Object> context = (Map<String, Object>)JSON.deserializeUntyped(resp.contextJson);

        // Verify missing array contains expected items
        List<Object> missing = (List<Object>)context.get('missing');
        Assert.isTrue(missing.size() > 0, 'Missing array should have items');
    }

    @isTest
    static void shouldReturnAmbiguous_WhenDuplicateAccountNameProvided() {
        AccountContextService.Request req = new AccountContextService.Request();
        req.accountName = 'QCSSTest Ambiguous Dupe';

        Test.startTest();
        List<AccountContextService.Response> responses =
            AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        AccountContextService.Response resp = responses[0];

        Assert.isFalse(resp.isSuccess, 'Should not be successful');
        Assert.areEqual('ACCOUNT_AMBIGUOUS', resp.errorType, 'Error type should be ACCOUNT_AMBIGUOUS');
        Assert.isTrue(resp.contextJson.contains('candidates'), 'Should contain candidates');

        Map<String, Object> context = (Map<String, Object>)JSON.deserializeUntyped(resp.contextJson);
        List<Object> candidates = (List<Object>)context.get('candidates');
        Assert.areEqual(2, candidates.size(), 'Should have 2 candidates');
    }

    @isTest
    static void shouldReturnNotFound_WhenAccountNameNotFound() {
        AccountContextService.Request req = new AccountContextService.Request();
        req.accountName = 'QCSS_DOES_NOT_EXIST_XYZ_99999';

        Test.startTest();
        List<AccountContextService.Response> responses =
            AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        AccountContextService.Response resp = responses[0];

        Assert.isFalse(resp.isSuccess, 'Should not be successful');
        Assert.areEqual('ACCOUNT_NOT_FOUND', resp.errorType, 'Error type should be ACCOUNT_NOT_FOUND');
    }

    @isTest
    static void shouldReturnAccountRequired_WhenNoInputProvided() {
        AccountContextService.Request req = new AccountContextService.Request();
        // No recordId, no accountName

        Test.startTest();
        List<AccountContextService.Response> responses =
            AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        AccountContextService.Response resp = responses[0];

        Assert.isFalse(resp.isSuccess, 'Should not be successful');
        Assert.areEqual('ACCOUNT_REQUIRED', resp.errorType, 'Error type should be ACCOUNT_REQUIRED');
    }

    @isTest
    static void shouldResolveToAccount_WhenContactIdProvided() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE LastName = 'Doe' LIMIT 1];

        AccountContextService.Request req = new AccountContextService.Request();
        req.recordId = con.Id;

        Test.startTest();
        List<AccountContextService.Response> responses =
            AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        AccountContextService.Response resp = responses[0];

        Assert.isTrue(resp.isSuccess, 'Should be successful');

        Map<String, Object> context = (Map<String, Object>)JSON.deserializeUntyped(resp.contextJson);
        Map<String, Object> account = (Map<String, Object>)context.get('account');
        Assert.areEqual(con.AccountId, (String)account.get('id'), 'Should resolve to correct account');
    }

    @isTest
    static void shouldResolveToAccount_WhenOpportunityIdProvided() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Name LIKE 'Full Open Opp%' LIMIT 1];

        AccountContextService.Request req = new AccountContextService.Request();
        req.recordId = opp.Id;

        Test.startTest();
        List<AccountContextService.Response> responses =
            AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        AccountContextService.Response resp = responses[0];

        Assert.isTrue(resp.isSuccess, 'Should be successful');

        Map<String, Object> context = (Map<String, Object>)JSON.deserializeUntyped(resp.contextJson);
        Map<String, Object> account = (Map<String, Object>)context.get('account');
        Assert.areEqual(opp.AccountId, (String)account.get('id'), 'Should resolve to correct account');
    }

    @isTest
    static void shouldMatchPartialName_WhenPartialAccountNameProvided() {
        AccountContextService.Request req = new AccountContextService.Request();
        req.accountName = 'Full Account'; // Partial, no "QCSSTest" prefix

        Test.startTest();
        List<AccountContextService.Response> responses =
            AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Should return one response');
        AccountContextService.Response resp = responses[0];

        Assert.isTrue(resp.isSuccess, 'Should be successful');

        Map<String, Object> context = (Map<String, Object>)JSON.deserializeUntyped(resp.contextJson);
        Map<String, Object> account = (Map<String, Object>)context.get('account');
        Assert.isTrue(((String)account.get('name')).contains('Full Account'), 'Should match Full Account');
    }
}
