/**
 * AccountContextService
 * Invocable action for Agentforce skills to retrieve comprehensive account context
 */
public with sharing class AccountContextService {

    // Constants
    private static final Integer MAX_OPPS = 5;
    private static final Integer MAX_CONTACTS = 5;
    private static final Date TWELVE_MONTHS_AGO = Date.today().addMonths(-12).toStartOfMonth();

    // Inner classes for Invocable
    public class Request {
        @InvocableVariable(label='Record ID' description='Account, Contact, or Opportunity ID')
        public Id recordId;

        @InvocableVariable(label='Account Name' description='Exact or partial account name')
        public String accountName;
    }

    public class Response {
        @InvocableVariable(label='Context JSON' description='JSON account brief or error envelope')
        public String contextJson;

        @InvocableVariable(label='Success' description='True if successful, false if error')
        public Boolean isSuccess;

        @InvocableVariable(label='Error Message' description='Human-readable error message')
        public String errorMessage;

        @InvocableVariable(label='Error Type' description='Error code: ACCOUNT_REQUIRED, ACCOUNT_NOT_FOUND, ACCOUNT_AMBIGUOUS')
        public String errorType;
    }

    @InvocableMethod(label='Get Account Context' description='Retrieves comprehensive account context for Account Brief' category='Sales Assistant')
    public static List<Response> getAccountContext(List<Request> requests) {
        List<Response> responses = new List<Response>();

        // Bulkified collections
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Map<Integer, Request> requestIndexMap = new Map<Integer, Request>();

        // Step 1: Resolve inputs to Account IDs
        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests[i];
            requestIndexMap.put(i, req);

            if (req.recordId == null && String.isBlank(req.accountName)) {
                // No input provided
                responses.add(createErrorResponse('ACCOUNT_REQUIRED', 'Either recordId or accountName must be provided'));
                continue;
            }

            if (req.recordId != null) {
                String sObjType = req.recordId.getSObjectType().getDescribe().getName();
                if (sObjType == 'Account') {
                    accountIds.add(req.recordId);
                } else if (sObjType == 'Contact') {
                    contactIds.add(req.recordId);
                } else if (sObjType == 'Opportunity') {
                    opportunityIds.add(req.recordId);
                }
            }
        }

        // Resolve Contact and Opportunity IDs to Account IDs
        Map<Id, Id> contactToAccount = new Map<Id, Id>();
        if (!contactIds.isEmpty()) {
            for (Contact c : [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds]) {
                contactToAccount.put(c.Id, c.AccountId);
                accountIds.add(c.AccountId);
            }
        }

        Map<Id, Id> oppToAccount = new Map<Id, Id>();
        if (!opportunityIds.isEmpty()) {
            for (Opportunity o : [SELECT Id, AccountId FROM Opportunity WHERE Id IN :opportunityIds]) {
                oppToAccount.put(o.Id, o.AccountId);
                accountIds.add(o.AccountId);
            }
        }

        // Handle name-based lookups
        Map<String, List<Account>> nameToAccounts = new Map<String, List<Account>>();
        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests[i];
            if (req.recordId == null && !String.isBlank(req.accountName)) {
                if (!nameToAccounts.containsKey(req.accountName)) {
                    nameToAccounts.put(req.accountName, new List<Account>());
                }
            }
        }

        if (!nameToAccounts.isEmpty()) {
            for (String searchName : nameToAccounts.keySet()) {
                String likePattern = '%' + searchName + '%';
                List<Account> matches = [SELECT Id, Name FROM Account WHERE Name LIKE :likePattern];
                nameToAccounts.put(searchName, matches);
            }
        }

        // Step 2: Query all account data
        Map<Id, Account> accountsMap = new Map<Id, Account>();
        if (!accountIds.isEmpty()) {
            for (Account acc : [
                SELECT Id, Name, Industry, Website, NumberOfEmployees,
                       BillingCity, BillingState
                FROM Account
                WHERE Id IN :accountIds
                           ]) {
                accountsMap.put(acc.Id, acc);
            }
        }

        // Query all related data
        Map<Id, List<SObject>> prioritiesMap = queryRelatedRecords('Account_Priority__c', accountIds, 'Priority_Rank__c ASC');
        Map<Id, List<Opportunity>> openOppsMap = queryOpenOpportunities(accountIds);
        Map<Id, List<Opportunity>> closedOppsMap = queryClosedOpportunities(accountIds);
        Map<Id, SObject> lastQuoteMap = queryLastQuote(accountIds);
        Map<Id, OrderData> ordersMap = queryOrders(accountIds);
        Map<Id, List<Case>> openCasesMap = queryOpenCases(accountIds);
        Map<Id, SObject> sowMap = queryActiveSOW(accountIds);
        Map<Id, SObject> customerProgramMap = queryCustomerProgram(accountIds);
        Map<Id, List<SObject>> pricingMap = queryRelatedRecords('Price_Agreement__c', accountIds, 'Name ASC');
        Map<Id, List<Contact>> contactsMap = queryContacts(accountIds);

        // Step 3: Build responses
        for (Integer i = 0; i < requests.size(); i++) {
            if (i < responses.size()) {
                continue; // Already handled as error
            }

            Request req = requests[i];
            Id resolvedAccountId = null;

            // Resolve account ID for this request
            if (req.recordId != null) {
                String sObjType = req.recordId.getSObjectType().getDescribe().getName();
                if (sObjType == 'Account') {
                    resolvedAccountId = req.recordId;
                } else if (sObjType == 'Contact') {
                    resolvedAccountId = contactToAccount.get(req.recordId);
                } else if (sObjType == 'Opportunity') {
                    resolvedAccountId = oppToAccount.get(req.recordId);
                }
            } else if (!String.isBlank(req.accountName)) {
                List<Account> matches = nameToAccounts.get(req.accountName);
                if (matches == null || matches.isEmpty()) {
                    responses.add(createErrorResponse('ACCOUNT_NOT_FOUND', 'No account found matching: ' + req.accountName));
                    continue;
                } else if (matches.size() > 1) {
                    responses.add(createAmbiguousResponse(matches));
                    continue;
                } else {
                    resolvedAccountId = matches[0].Id;
                }
            }

            if (resolvedAccountId == null || !accountsMap.containsKey(resolvedAccountId)) {
                responses.add(createErrorResponse('ACCOUNT_NOT_FOUND', 'Account not found'));
                continue;
            }

            // Build JSON
            responses.add(buildSuccessResponse(
                resolvedAccountId,
                accountsMap.get(resolvedAccountId),
                prioritiesMap.get(resolvedAccountId),
                openOppsMap.get(resolvedAccountId),
                closedOppsMap.get(resolvedAccountId),
                lastQuoteMap.get(resolvedAccountId),
                ordersMap.get(resolvedAccountId),
                openCasesMap.get(resolvedAccountId),
                sowMap.get(resolvedAccountId),
                customerProgramMap.get(resolvedAccountId),
                pricingMap.get(resolvedAccountId),
                contactsMap.get(resolvedAccountId)
            ));
        }

        return responses;
    }

    // Helper methods
    private static Map<Id, List<SObject>> queryRelatedRecords(String objectName, Set<Id> accountIds, String orderBy) {
        Map<Id, List<SObject>> resultMap = new Map<Id, List<SObject>>();
        if (accountIds.isEmpty()) return resultMap;

        String query = 'SELECT Id, Name, Account__c FROM ' + objectName +
                       ' WHERE Account__c IN :accountIds ORDER BY ' + orderBy;

        try {
            for (SObject record : Database.query(query)) {
                Id accountId = (Id)record.get('Account__c');
                if (!resultMap.containsKey(accountId)) {
                    resultMap.put(accountId, new List<SObject>());
                }
                resultMap.get(accountId).add(record);
            }
        } catch (Exception e) {
            // Object may not be accessible yet
        }

        return resultMap;
    }

    private static Map<Id, List<Opportunity>> queryOpenOpportunities(Set<Id> accountIds) {
        Map<Id, List<Opportunity>> resultMap = new Map<Id, List<Opportunity>>();
        if (accountIds.isEmpty()) return resultMap;

        List<Opportunity> opps = [
            SELECT Id, Name, StageName, Amount, CloseDate, AccountId
            FROM Opportunity
            WHERE AccountId IN :accountIds AND IsClosed = false
            ORDER BY CloseDate ASC
        ];

        for (Opportunity opp : opps) {
            if (!resultMap.containsKey(opp.AccountId)) {
                resultMap.put(opp.AccountId, new List<Opportunity>());
            }
            if (resultMap.get(opp.AccountId).size() < MAX_OPPS) {
                resultMap.get(opp.AccountId).add(opp);
            }
        }

        return resultMap;
    }

    private static Map<Id, List<Opportunity>> queryClosedOpportunities(Set<Id> accountIds) {
        Map<Id, List<Opportunity>> resultMap = new Map<Id, List<Opportunity>>();
        if (accountIds.isEmpty()) return resultMap;

        Date oneYearAgo = Date.today().addYears(-1);
        List<Opportunity> opps = [
            SELECT Id, Name, StageName, Amount, CloseDate, AccountId
            FROM Opportunity
            WHERE AccountId IN :accountIds AND IsClosed = true AND CloseDate >= :oneYearAgo
            ORDER BY CloseDate DESC
        ];

        for (Opportunity opp : opps) {
            if (!resultMap.containsKey(opp.AccountId)) {
                resultMap.put(opp.AccountId, new List<Opportunity>());
            }
            if (resultMap.get(opp.AccountId).size() < MAX_OPPS) {
                resultMap.get(opp.AccountId).add(opp);
            }
        }

        return resultMap;
    }

    private static Map<Id, SObject> queryLastQuote(Set<Id> accountIds) {
        Map<Id, SObject> resultMap = new Map<Id, SObject>();
        // Quote object may not be enabled - skip if not available
        return resultMap;
    }

    private static Map<Id, OrderData> queryOrders(Set<Id> accountIds) {
        Map<Id, OrderData> resultMap = new Map<Id, OrderData>();
        if (accountIds.isEmpty()) return resultMap;

        List<Order> orders = [
            SELECT Id, AccountId, EffectiveDate, TotalAmount,
                   (SELECT Id, Product2.Name FROM OrderItems LIMIT 1)
            FROM Order
            WHERE AccountId IN :accountIds AND EffectiveDate >= :TWELVE_MONTHS_AGO
            ORDER BY EffectiveDate DESC
        ];

        for (Order ord : orders) {
            if (!resultMap.containsKey(ord.AccountId)) {
                resultMap.put(ord.AccountId, new OrderData());
            }
            OrderData data = resultMap.get(ord.AccountId);
            data.orders.add(ord);
            data.trailing12MonthTotal += (ord.TotalAmount != null ? ord.TotalAmount : 0);
        }

        return resultMap;
    }

    private static Map<Id, List<Case>> queryOpenCases(Set<Id> accountIds) {
        Map<Id, List<Case>> resultMap = new Map<Id, List<Case>>();
        if (accountIds.isEmpty()) return resultMap;

        for (Case c : [
            SELECT Id, Subject, Priority, Status, AccountId
            FROM Case
            WHERE AccountId IN :accountIds AND IsClosed = false
                   ]) {
            if (!resultMap.containsKey(c.AccountId)) {
                resultMap.put(c.AccountId, new List<Case>());
            }
            resultMap.get(c.AccountId).add(c);
        }

        return resultMap;
    }

    private static Map<Id, SObject> queryActiveSOW(Set<Id> accountIds) {
        Map<Id, SObject> resultMap = new Map<Id, SObject>();
        if (accountIds.isEmpty()) return resultMap;

        String query = 'SELECT Id, Name, Account__c FROM Statement_of_Work__c ' +
                       'WHERE Account__c IN :accountIds LIMIT 1';

        try {
            for (SObject sow : Database.query(query)) {
                resultMap.put((Id)sow.get('Account__c'), sow);
            }
        } catch (Exception e) {
            // Object may not be accessible yet
        }

        return resultMap;
    }

    private static Map<Id, SObject> queryCustomerProgram(Set<Id> accountIds) {
        Map<Id, SObject> resultMap = new Map<Id, SObject>();
        if (accountIds.isEmpty()) return resultMap;

        String query = 'SELECT Id, Name, Account__c FROM Customer_Program__c ' +
                       'WHERE Account__c IN :accountIds ORDER BY Name ASC LIMIT 1';

        try {
            for (SObject program : Database.query(query)) {
                resultMap.put((Id)program.get('Account__c'), program);
            }
        } catch (Exception e) {
            // Object may not be accessible yet
        }

        return resultMap;
    }

    private static Map<Id, List<Contact>> queryContacts(Set<Id> accountIds) {
        Map<Id, List<Contact>> resultMap = new Map<Id, List<Contact>>();
        if (accountIds.isEmpty()) return resultMap;

        List<Contact> contacts = [
            SELECT Id, Name, Title, Email, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
            ORDER BY Name ASC
        ];

        for (Contact c : contacts) {
            if (!resultMap.containsKey(c.AccountId)) {
                resultMap.put(c.AccountId, new List<Contact>());
            }
            if (resultMap.get(c.AccountId).size() < MAX_CONTACTS) {
                resultMap.get(c.AccountId).add(c);
            }
        }

        return resultMap;
    }

    private static Response createErrorResponse(String errorType, String errorMessage) {
        Response resp = new Response();
        resp.isSuccess = false;
        resp.errorType = errorType;
        resp.errorMessage = errorMessage;
        resp.contextJson = '{"error":"' + errorType + '"}';
        return resp;
    }

    private static Response createAmbiguousResponse(List<Account> candidates) {
        Response resp = new Response();
        resp.isSuccess = false;
        resp.errorType = 'ACCOUNT_AMBIGUOUS';
        resp.errorMessage = 'Multiple accounts match. Please be more specific.';

        List<String> candidateJson = new List<String>();
        for (Account acc : candidates) {
            candidateJson.add('{"id":"' + acc.Id + '","name":"' + acc.Name + '"}');
        }
        resp.contextJson = '{"error":"ACCOUNT_AMBIGUOUS","candidates":[' + String.join(candidateJson, ',') + ']}';
        return resp;
    }

    private static Response buildSuccessResponse(
        Id accountId,
        Account acc,
        List<SObject> priorities,
        List<Opportunity> openOpps,
        List<Opportunity> closedOpps,
        SObject lastQuote,
        OrderData orderData,
        List<Case> openCases,
        SObject sow,
        SObject customerProgram,
        List<SObject> pricing,
        List<Contact> contacts
    ) {
        Response resp = new Response();
        resp.isSuccess = true;
        resp.errorType = null;
        resp.errorMessage = null;

        Map<String, Object> context = new Map<String, Object>();
        List<String> missing = new List<String>();

        // Account
        context.put('account', new Map<String, Object>{
            'id' => acc.Id,
            'name' => acc.Name,
            'industry' => acc.Industry,
            'website' => acc.Website,
            'numberOfEmployees' => acc.NumberOfEmployees,
            'billingCity' => acc.BillingCity,
            'billingState' => acc.BillingState
        });

        // Priority
        if (priorities != null && !priorities.isEmpty()) {
            context.put('priority', priorities);
        } else {
            missing.add('priority');
        }

        // Open Opportunities
        if (openOpps != null && !openOpps.isEmpty()) {
            context.put('openOpps', openOpps);
        } else {
            missing.add('openOpps');
        }

        // Recent Closed Opportunities
        if (closedOpps != null && !closedOpps.isEmpty()) {
            context.put('recentClosedOpps', closedOpps);
        } else {
            missing.add('recentClosedOpps');
        }

        // Last Quote
        if (lastQuote != null) {
            context.put('lastQuote', lastQuote);
        } else {
            missing.add('lastQuote');
        }

        // Orders
        if (orderData != null && !orderData.orders.isEmpty()) {
            context.put('orders', new Map<String, Object>{
                'trailing12MonthTotal' => orderData.trailing12MonthTotal,
                'byMonth' => orderData.orders
            });
        } else {
            missing.add('orders');
        }

        // Open Cases
        if (openCases != null && !openCases.isEmpty()) {
            context.put('openCases', openCases);
        } else {
            missing.add('openCases');
        }

        // SOW
        if (sow != null) {
            context.put('sow', sow);
        } else {
            missing.add('sow');
        }

        // Customer Program
        if (customerProgram != null) {
            context.put('customerProgram', customerProgram);
        } else {
            missing.add('customerProgram');
        }

        // Pricing
        if (pricing != null && !pricing.isEmpty()) {
            context.put('pricing', pricing);
        } else {
            missing.add('pricing');
        }

        // Contacts
        if (contacts != null && !contacts.isEmpty()) {
            context.put('contacts', contacts);
        } else {
            missing.add('contacts');
        }

        context.put('missing', missing);

        resp.contextJson = JSON.serialize(context);
        return resp;
    }

    // Helper class for order data
    private class OrderData {
        public Decimal trailing12MonthTotal = 0;
        public List<Order> orders = new List<Order>();
    }
}
