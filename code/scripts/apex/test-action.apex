// Test AccountContextService with Lakeshore
AccountContextService.Request req = new AccountContextService.Request();
req.accountName = 'Lakeshore';

List<AccountContextService.Response> responses =
    AccountContextService.getAccountContext(new List<AccountContextService.Request>{req});

AccountContextService.Response resp = responses[0];

System.debug('=== TEST RESULT ===');
System.debug('Success: ' + resp.isSuccess);
System.debug('Error Type: ' + resp.errorType);
System.debug('Error Message: ' + resp.errorMessage);
System.debug('JSON Length: ' + (resp.contextJson != null ? resp.contextJson.length() : 0));

if (resp.isSuccess) {
    System.debug('JSON Preview (first 500 chars):');
    System.debug(resp.contextJson.substring(0, Math.min(500, resp.contextJson.length())));
} else {
    System.debug('Full Error JSON:');
    System.debug(resp.contextJson);
}
