// Test AccountContextService with Account ID
Account acc = [SELECT Id FROM Account WHERE Name = 'DEMO Lakeshore Medical Group' LIMIT 1];

AccountContextService.Request req = new AccountContextService.Request();
req.recordId = acc.Id;

List<AccountContextService.Response> responses =
    AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});

AccountContextService.Response resp = responses[0];

System.debug('=== TEST WITH ACCOUNT ID ===');
System.debug('Account ID: ' + acc.Id);
System.debug('Success: ' + resp.isSuccess);
System.debug('Error Type: ' + resp.errorType);
System.debug('JSON Length: ' + (resp.contextJson != null ? resp.contextJson.length() : 0));

if (resp.isSuccess) {
    System.debug('JSON Preview (first 800 chars):');
    System.debug(resp.contextJson.substring(0, Math.min(800, resp.contextJson.length())));
}
