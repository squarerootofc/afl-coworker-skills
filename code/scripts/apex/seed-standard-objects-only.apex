// Account Brief Demo Data - Standard Objects Only (bypassing custom object field issues)

// Delete existing DEMO data
List<Account> existingAccounts = [SELECT Id FROM Account WHERE Name LIKE 'DEMO %'];
if (!existingAccounts.isEmpty()) {
    System.debug('Deleting ' + existingAccounts.size() + ' existing DEMO accounts...');
    delete existingAccounts;
}

Date today = Date.today();

// Products: 2
Product2 prodFurniture = new Product2(Name='DEMO Furniture', IsActive=true, ProductCode='FURN');
Product2 prodPrint = new Product2(Name='DEMO Print', IsActive=true, ProductCode='PRINT');
insert new List<Product2>{prodFurniture, prodPrint};

// Standard Pricebook
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

// Contacts: 13
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

// Opportunities: 18
List<Opportunity> opps = new List<Opportunity>();
// Lakeshore: 9 (6 open, 3 closed)
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Q1 Furniture Refresh', StageName='Prospecting', CloseDate=today.addDays(30), Amount=45000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Annual Print Services', StageName='Qualification', CloseDate=today.addDays(60), Amount=22000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Emergency Room Upgrade', StageName='Needs Analysis', CloseDate=today.addDays(45), Amount=65000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Waiting Room Seating', StageName='Value Proposition', CloseDate=today.addDays(15), Amount=18000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Office Supplies', StageName='Negotiation/Review', CloseDate=today.addDays(10), Amount=8500));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Clinic Furniture', StageName='Prospecting', CloseDate=today.addDays(90), Amount=32000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Furniture Contract Renewal', StageName='Closed Won', CloseDate=today.addMonths(-2), Amount=120000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - IT Equipment Bid', StageName='Closed Lost', CloseDate=today.addMonths(-1), Amount=55000));
opps.add(new Opportunity(AccountId=lakeshore.Id, Name='Lakeshore - Cafeteria Seating', StageName='Closed Won', CloseDate=today.addMonths(-3), Amount=28000));
// Ridgeway: 5 (4 open, 1 closed)
opps.add(new Opportunity(AccountId=ridgeway.Id, Name='Ridgeway - Warehouse Furniture', StageName='Prospecting', CloseDate=today.addDays(45), Amount=38000));
opps.add(new Opportunity(AccountId=ridgeway.Id, Name='Ridgeway - Office Redesign', StageName='Qualification', CloseDate=today.addDays(30), Amount=52000));
opps.add(new Opportunity(AccountId=ridgeway.Id, Name='Ridgeway - Break Room Refresh', StageName='Needs Analysis', CloseDate=today.addDays(20), Amount=15000));
opps.add(new Opportunity(AccountId=ridgeway.Id, Name='Ridgeway - Print Services', StageName='Value Proposition', CloseDate=today.addDays(60), Amount=9500));
opps.add(new Opportunity(AccountId=ridgeway.Id, Name='Ridgeway - Annual Contract', StageName='Closed Won', CloseDate=today.addMonths(-1), Amount=75000));
// Others
opps.add(new Opportunity(AccountId=pinecrest.Id, Name='Pinecrest - Classroom Furniture', StageName='Prospecting', CloseDate=today.addDays(90), Amount=95000));
opps.add(new Opportunity(AccountId=harbor1.Id, Name='Harbor Seattle - Office Setup', StageName='Qualification', CloseDate=today.addDays(45), Amount=12000));
opps.add(new Opportunity(AccountId=harbor2.Id, Name='Harbor Tacoma - Warehouse Equipment', StageName='Prospecting', CloseDate=today.addDays(60), Amount=22000));
insert opps;

// Orders: 18
List<Order> orders = new List<Order>();
for (Integer i = 1; i <= 12; i++) {
    orders.add(new Order(AccountId=lakeshore.Id, EffectiveDate=today.addMonths(-i).toStartOfMonth(), Status='Draft', Pricebook2Id=stdPricebookId));
}
for (Integer i = 1; i <= 6; i++) {
    orders.add(new Order(AccountId=ridgeway.Id, EffectiveDate=today.addMonths(-i).toStartOfMonth(), Status='Draft', Pricebook2Id=stdPricebookId));
}
insert orders;

// OrderItems
List<OrderItem> orderItems = new List<OrderItem>();
for (Integer i = 0; i < orders.size(); i++) {
    Decimal price = (i < 12) ? (10000 - ((i) * 208.33)) : (Math.mod(i-12+1, 2) == 1 ? 3500 : 1800);
    Product2 prod = (i < 12 || Math.mod(i-12+1, 2) == 1) ? prodFurniture : prodPrint;
    orderItems.add(new OrderItem(
        OrderId=orders[i].Id,
        Product2Id=prod.Id,
        PricebookEntryId=(prod.Id == prodFurniture.Id ? pbeFurniture.Id : pbePrint.Id),
        Quantity=1,
        UnitPrice=price
    ));
}
insert orderItems;

// Activate orders
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

System.debug('=== SEED COMPLETE: 81 standard object records ===');
System.debug('Products: 2 | Pricebook Entries: 2');
System.debug('Accounts: 5 (including DEMO Lakeshore Medical Group)');
System.debug('Contacts: 13 | Opportunities: 18 | Orders: 18 | OrderItems: 18 | Cases: 6');
System.debug('NOTE: Custom objects (SOW, Customer Program, Price Agreements, Account Priorities) not loaded due to field access issues');
System.debug('You can add those records manually via the UI if needed for the full demo');
