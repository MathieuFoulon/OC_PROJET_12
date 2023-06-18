/**
 * @description       : Test Class for ContractREST
 * @author            : Mathieu Foulon
 * @group             : 
 * @last modified on  : 18-06-2023
 * @last modified by  : Mathieu Foulon
**/
@isTest
public with sharing class ContractRESTTest {
    static final String REQUEST_URI = '/services/apexrest/Contract/';

    @TestSetup
    static void makeData(){

        Account account = new Account(
            Name = 'AccountName'
        );

        insert account;

        Contract contract = new Contract( 
            AccountId = account.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 2
        );

        insert contract;
    }

    @isTest 
    static void createContractTest(){
        
        Account newAccount = new Account(
            Name = 'AccountName2'
        );

        insert newAccount;

        Contract newContract = new Contract(
            AccountId = newAccount.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 2
        );

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(newContract));

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ContractREST.createContract(newContract.AccountId, newContract.Status, newContract.StartDate, newContract.ContractTerm);
        Test.stopTest();
        
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        Assert.areNotEqual(null, (String)responseBody.get('Id'));
        Assert.areEqual(201, res.statusCode);
    }

    @isTest 
    static void createContractFailTest(){
        
        Account newAccount = new Account(
            Name = 'AccountName3'
        );

        insert newAccount;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty('lololol'));

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ContractREST.createContract(newAccount.Id, 'lololol', Date.today(), 122);
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
    }

    @isTest 
    static void updateContractTest(){
        Account Account = [SELECT Id, Name FROM Account WHERE Name = 'AccountName'];
        Contract existingContract = [SELECT Id, ContractTerm FROM Contract WHERE AccountId = :Account.Id];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI + existingContract.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"ContractTerm": 20}');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ContractREST.updateContract();
        Test.stopTest();
        
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        Assert.areNotEqual(null, (String)responseBody.get('Id'));
        Assert.AreEqual(200, res.statusCode);
    }

    @isTest 
    static void updateContractFailTest(){
        Account Account = [SELECT Id, Name FROM Account WHERE Name = 'AccountName'];
        Contract existingContract = [SELECT Id, ContractTerm FROM Contract WHERE AccountId = :Account.Id];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI + existingContract.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"ContractTerm": "ptdrrrrr}');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ContractREST.updateContract();
        Test.stopTest();
        
        Assert.AreEqual(400, res.statusCode);
    }

}