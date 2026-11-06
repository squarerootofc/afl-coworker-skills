// Account Brief Demo Data Seed Script - V2 (using dynamic SObject construction)
// Creates 95 fictional test records across 12 standard and custom objects

// Delete existing DEMO data first
List<Account> existingAccounts = [SELECT Id FROM Account WHERE Name LIKE 'DEMO %'];
if (!existingAccounts.isEmpty()) {
    System.debug('Deleting ' + existingAccounts.size() + ' existing DEMO accounts and their children...');
    delete existingAccounts;
}

Date today = Date.today();

// Products: 2
Product2 prodFurniture = new Product2(Name='DEMO Furniture', IsActive=true, ProductCode='FURN');
Product2 prodPrint = new Product2(Name='DEMO Print', IsActive=true, ProductCode='PRINT');
insert new List<Product2>{prodFurniture, prodPrint};

// Standard Pricebook Entries: 2
Id stdPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
PricebookEntry pbeFurniture = new PricebookEntry(
    Pricebook2Id=stdPricebookId, Product2Id=prodFurniture.Id,
    UnitPrice=100, IsActive=true
);
PricebookEntry pbePrint = new PricebookEntry(
    Pricebook2Id=stdPricebookId, Product2Id=prodPrint.Id,
    UnitPrice=50, IsActive=true
);
insert new List<PricebookEntry>{pbeFurniture, pbePrint};

// Accounts: 5
Account lakeshore = new Account(
    Name='DEMO Lakeshore Medical Group',
    Industry='Healthcare',
    NumberOfEmployees=1800,
    BillingCity='Chicago',
    Website='lakeshoremedical.example'
);
Account ridgeway = new Account(
    Name='DEMO Ridgeway Logistics',
    Industry='Transportation',
    NumberOfEmployees=650,
    BillingCity='Dallas',
    Website='ridgewaylogistics.example'
);
Account pinecrest = new Account(
    Name='DEMO Pinecrest School District',
    Industry='Education',
    NumberOfEmployees=320,
    BillingCity='Portland'
);
Account harbor1 = new Account(
    Name='DEMO Harbor Supply Co',
    Industry='Wholesale',
    BillingCity='Seattle'
);
Account harbor2 = new Account(
    Name='DEMO Harbor Supply Co',
    Industry='Wholesale',
    BillingCity='Tacoma'
);
insert new List<Account>{lakeshore, ridgeway, pinecrest, harbor1, harbor2};

// Contacts: 13 total
List<Contact> contacts = new List<Contact>();
contacts.add(new Contact(AccountId=lakeshore.Id, FirstName='Sarah', LastName='Chen', Title='VP Operations', Email='schen@lakeshoremedical.example'));
contacts.add(new Contact(AccountId=lakeshore.Id, FirstName='Michael', LastName='Torres', Title='Facilities Director', Email='mtorres@lakeshoremedical.example'));
contacts.add(new Contact(AccountId=lakeshore.Id, FirstName='Jennifer', LastName='Park', Title='Procurement Manager', Email='jpark@lakeshoremedical.example'));
contacts.add(new Contact(AccountId=lakeshore.Id, FirstName='David', LastName='Anderson', Title='Site Manager', Email='danderson@lakeshoremedical.example'));
contacts.add(new Contact(AccountId=lakeshore.Id, FirstName='Lisa', LastName='Martinez', Title='Admin Director', Email='lmartinez@lakeshoremedical.example'));
contacts.add(new Contact(AccountId=lakeshore.Id, FirstName='Robert', LastName='Kim', Title='CFO', Email='rkim@lakeshoremedical.example'));
contacts.add(new Contact(AccountId=lakeshore.Id, FirstName='Amanda', LastName='Wilson', Title='IT Manager', Email='awilson@lakeshoremedical.example'));
contacts.add(new Contact(AccountId=ridgeway.Id, FirstName='James', LastName='Brown', Title='Logistics VP', Email='jbrown@ridgewaylogistics.example'));
contacts.add(new Contact(AccountId=ridgeway.Id, FirstName='Patricia', LastName='Davis', Title='Operations Manager', Email='pdavis@ridgewaylogistics.example'));
contacts.add(new Contact(AccountId=ridgeway.Id, FirstName='Thomas', LastName='Garcia', Title='Procurement Lead', Email='tgarcia@ridgewaylogistics.example'));
contacts.add(new Contact(AccountId=ridgeway.Id, FirstName='Mary', LastName='Rodriguez', Title='Warehouse Manager', Email='mrodriguez@ridgewaylogistics.example'));
contacts.add(new Contact(AccountId=pinecrest.Id, FirstName='Elizabeth', LastName='Taylor', Title='Superintendent', Email='etaylor@pinecrest.example'));
contacts.add(new Contact(AccountId=harbor1.Id, FirstName='William', LastName='Johnson', Title='Owner', Email='wjohnson@harborsupply.example'));
insert contacts;

// Opportunities: 18 total
List<Opportunity> opps = new List<Opportunity>();
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Q1 Furniture Refresh', StageName='Prospecting', CloseDate=today.addDays(30), Amount=45000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Annual Print Services', StageName='Qualification', CloseDate=today.addDays(60), Amount=22000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Emergency Room Upgrade', StageName='Needs Analysis', CloseDate=today.addDays(45), Amount=65000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Waiting Room Seating', StageName='Value Proposition', CloseDate=today.addDays(15), Amount=18000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Office Supplies', StageName='Negotiation/Review', CloseDate=today.addDays(10), Amount=8500));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Clinic Furniture', StageName='Prospecting', CloseDate=today.addDays(90), Amount=32000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Furniture Contract Renewal', StageName='Closed Won', CloseDate=today.addMonths(-2), Amount=120000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - IT Equipment Bid', StageName='Closed Lost', CloseDate=today.addMonths(-1), Amount=55000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Cafeteria Seating', StageName='Closed Won', CloseDate=today.addMonths(-3), Amount=28000));
opps.add(new Opportunity(AccountId=ridgeway.Id, Name='Ridgeway - Warehouse Furniture', StageName='Prospecting', CloseDate=today.addDays(45), Amount=38000));
opps.add(new Opportunity(AccountId=ridgeway.Id, Name='Ridgeway - Office Redesign', StageName='Qualification', CloseDate=today.addDays(30), Amount=52000));
opps.add(new Opportunity(AccountId=ridgeway.Id, Name='Ridgeway - Break Room Refresh', StageName='Needs Analysis', CloseDate=today.addDays(20), Amount=15000));
opps.add(new Opportunity(AccountId=ridgeway.Id, Name='Ridgeway - Print Services', StageName='Value Proposition', CloseDate=today.addDays(60), Amount=9500));
opps.add(new Opportunity(AccountId=ridgeway.Id, Name='Ridgeway - Annual Contract', StageName='Closed Won', CloseDate=today.addMonths(-1), Amount=75000));
opps.add(new Opportunity(AccountId=pinecrest.Id, Name='Pinecrest - Classroom Furniture', StageName='Prospecting', CloseDate=today.addDays(90), Amount=95000));
opps.add(new Opportunity(AccountId=harbor1.Id, Name='Harbor Seattle - Office Setup', StageName='Qualification', CloseDate=today.addDays(45), Amount=12000));
opps.add(new Opportunity(AccountId=harbor2.Id, Name='Harbor Tacoma - Warehouse Equipment', StageName='Prospecting', CloseDate=today.addDays(60), Amount=22000));
insert opps;

// Orders: 18 + OrderItems
List<Order> orders = new List<Order>();
List<Decimal> lakeshoreAmounts = new List<Decimal>();
List<Decimal> ridgewayAmounts = new List<Decimal>();

for (Integer i = 1; i <= 12; i++) {
    Decimal furnitureAmount = 10000 - ((i-1) * 208.33);
    lakeshoreAmounts.add(furnitureAmount);
    orders.add(new Order(AccountId=lakeshore.Id, EffectiveDate=today.addMonths(-i).toStartOfMonth(), Status='Draft', Pricebook2Id=stdPricebookId));
}
for (Integer i = 1; i <= 6; i++) {
    ridgewayAmounts.add(Math.mod(i, 2) == 1 ? 3500 : 1800);
    orders.add(new Order(AccountId=ridgeway.Id, EffectiveDate=today.addMonths(-i).toStartOfMonth(), Status='Draft', Pricebook2Id=stdPricebookId));
}
insert orders;

List<OrderItem> orderItems = new List<OrderItem>();
for (Integer i = 0; i < orders.size(); i++) {
    Product2 prod = (i < 12) ? prodFurniture : (Math.mod(i-12+1, 2) == 1 ? prodFurniture : prodPrint);
    Decimal price = (i < 12) ? lakeshoreAmounts[i] : ridgewayAmounts[i-12];
    orderItems.add(new OrderItem(
        OrderId=orders[i].Id,
        Product2Id=prod.Id,
        PricebookEntryId=(prod.Id == prodFurniture.Id ? pbeFurniture.Id : pbePrint.Id),
        Quantity=1,
        UnitPrice=price
    ));
}
insert orderItems;

for (Order ord : orders) { ord.Status = 'Activated'; }
update orders;

// Cases: 6
List<Case> cases = new List<Case>();
cases.add(new Case(AccountId=lakeshore.Id, Subject='Furniture delivery delay', Priority='Medium', Status='Open', Origin='Email'));
cases.add(new Case(AccountId=lakeshore.Id, Subject='Invoice discrepancy', Priority='Low', Status='Closed', Origin='Phone'));
cases.add(new Case(AccountId=lakeshore.Id, Subject='Damaged shipment', Priority='High', Status='Closed', Origin='Web'));
cases.add(new Case(AccountId=lakeshore.Id, Subject='Product return request', Priority='Medium', Status='Closed', Origin='Email'));
cases.add(new Case(AccountId=ridgeway.Id, Subject='Order status inquiry', Priority='Low', Status='Open', Origin='Phone'));
cases.add(new Case(AccountId=ridgeway.Id, Subject='Billing question', Priority='Low', Status='Closed', Origin='Email'));
insert cases;

// Custom Objects using dynamic SObject (workaround for compiler cache)
List<SObject> customRecords = new List<SObject>();

// Statement_of_Work__c: 2
SObject sowL = Schema.getGlobalDescribe().get('Statement_of_Work__c').newSObject();
sowL.put('Name', 'Lakeshore Annual SOW');
sowL.put('Account__c', lakeshore.Id);
sowL.put('Start_Date__c', today.addMonths(-6));
sowL.put('End_Date__c', today.addMonths(6));
sowL.put('Scope_Summary__c', 'Comprehensive furniture, equipment, and print services for all Lakeshore Medical Group facilities.');
sowL.put('Status__c', 'Active');
customRecords.add(sowL);

SObject sowR = Schema.getGlobalDescribe().get('Statement_of_Work__c').newSObject();
sowR.put('Name', 'Ridgeway Logistics SOW');
sowR.put('Account__c', ridgeway.Id);
sowR.put('Start_Date__c', today.addMonths(-3));
sowR.put('End_Date__c', today.addMonths(9));
sowR.put('Scope_Summary__c', 'Warehouse and office furniture solutions for Ridgeway Logistics operations.');
sowR.put('Status__c', 'Active');
customRecords.add(sowR);

// Customer_Program__c: 2
SObject programL = Schema.getGlobalDescribe().get('Customer_Program__c').newSObject();
programL.put('Name', 'Lakeshore Healthcare Program');
programL.put('Account__c', lakeshore.Id);
programL.put('Program_Type__c', 'Healthcare');
programL.put('Renewal_Date__c', today.addDays(90));
programL.put('Coverage_Summary__c', 'Healthcare-specific furniture and equipment program with clinical-grade materials.');
customRecords.add(programL);

SObject programR = Schema.getGlobalDescribe().get('Customer_Program__c').newSObject();
programR.put('Name', 'Ridgeway Commercial Program');
programR.put('Account__c', ridgeway.Id);
programR.put('Program_Type__c', 'Commercial');
programR.put('Renewal_Date__c', today.addDays(180));
programR.put('Coverage_Summary__c', 'Commercial furniture program with industrial durability.');
customRecords.add(programR);

// Price_Agreement__c: 8
String[] pricingData = new String[]{
    'Lakeshore Furniture Contract|Furniture|Contract|12',
    'Lakeshore Print Tier 1|Print|Tier 1|8',
    'Lakeshore Technology Tier 2|Technology|Tier 2|5',
    'Lakeshore Supplies Tier 1|Supplies|Tier 1|7',
    'Lakeshore Services Contract|Services|Contract|10',
    'Ridgeway Furniture Tier 1|Furniture|Tier 1|6',
    'Ridgeway Print Tier 2|Print|Tier 2|4',
    'Ridgeway Supplies Tier 2|Supplies|Tier 2|3'
};
for (Integer i = 0; i < pricingData.size(); i++) {
    String[] parts = pricingData[i].split('\\|');
    SObject price = Schema.getGlobalDescribe().get('Price_Agreement__c').newSObject();
    price.put('Name', parts[0]);
    price.put('Account__c', i < 5 ? lakeshore.Id : ridgeway.Id);
    price.put('Product_Class__c', parts[1]);
    price.put('Tier__c', parts[2]);
    price.put('Discount_Pct__c', Decimal.valueOf(parts[3]));
    price.put('Effective_Date__c', i < 5 ? today.addMonths(-6) : today.addMonths(-3));
    customRecords.add(price);
}

// Account_Priority__c: 2
SObject pri1 = Schema.getGlobalDescribe().get('Account_Priority__c').newSObject();
pri1.put('Name', 'Lakeshore Priority 1');
pri1.put('Account__c', lakeshore.Id);
pri1.put('Priority_Rank__c', 1);
pri1.put('Priority_Reason__c', 'Declining furniture spend at 3 sites');
pri1.put('Recommended_Action__c', 'Offer site-level furniture review');
pri1.put('Refreshed_On__c', today.addDays(-7));
customRecords.add(pri1);

SObject pri2 = Schema.getGlobalDescribe().get('Account_Priority__c').newSObject();
pri2.put('Name', 'Lakeshore Priority 2');
pri2.put('Account__c', lakeshore.Id);
pri2.put('Priority_Rank__c', 2);
pri2.put('Priority_Reason__c', 'Print volume flat');
pri2.put('Recommended_Action__c', 'Propose managed print review');
pri2.put('Refreshed_On__c', today.addDays(-7));
customRecords.add(pri2);

insert customRecords;

System.debug('=== SEED COMPLETE: 95 records ===');
System.debug('Products: 2 | Pricebook Entries: 2');
System.debug('Accounts: 5 | Contacts: 13 | Opportunities: 18');
System.debug('Orders: 18 | OrderItems: 18 | Cases: 6');
System.debug('SOWs: 2 | Customer Programs: 2 | Price Agreements: 8 | Account Priorities: 2');
