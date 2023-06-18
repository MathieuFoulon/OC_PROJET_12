/**
 * @description       : Test Class for ContactREST
 * @author            : Mathieu Foulon
 * @group             : 
 * @last modified on  : 18-06-2023
 * @last modified by  : Mathieu Foulon
**/
@isTest
public with sharing class ContactRESTTest {

    static final String REQUEST_URI = '/services/apexrest/Contact/';

    @TestSetup
    static void makeData(){
        Contact contactTest = new Contact( 
            FirstName = 'ContactFirstName',
            LastName = 'ContactLastName',
            Email = 'contactemail@contactemail.com',
            Phone = '0101010101'
        );
        insert contactTest;
    }

    @isTest
    public static void createNewContactTest() {
        
        Contact newContact = new Contact(
            FirstName = 'Marcel',
            LastName = 'Etsonorchestre',
            Email = 'marcel@etsonorchestre.com',
            Phone = '0202020202'
        );

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(newContact));

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ContactREST.createContact(newContact.FirstName, newContact.LastName, newContact.Email, newContact.Phone);
        Test.stopTest();
        
    
        
        System.debug(res.responseBody.toString());
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());

        System.debug((String)responseBody.get('Id'));
        
        Assert.areEqual(201, res.statusCode);
        Assert.areNotEqual(null, (String)responseBody.get('Id'));

    }

    @isTest
    public static void createExistingContactTest() {
        
        Contact existingContact = new Contact(
            FirstName = 'ContactFirstName',
            LastName = 'ContactLastName',
            Email = 'contactemail@contactemail.com',
            Phone = '0101010101'
        );

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(existingContact));

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ContactREST.createContact(existingContact.FirstName, existingContact.LastName, existingContact.Email, existingContact.Phone);
        Test.stopTest();
        
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());

        Assert.areNotEqual(null, (String)responseBody.get('Id'));
        Assert.areEqual(200, res.statusCode);

    }

    @isTest
    public static void createContactFailTest() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty('lololol'));

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        ContactREST.createContact('lololol', 'lololol', 'lololol','lololo');
        Test.stopTest();
        
        Assert.areEqual(400, res.statusCode);

    }

    @isTest 
    static void contactUpdateTest() {

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Contact contact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE LastName = 'ContactLastName' LIMIT 1];

        req.requestURI = REQUEST_URI + contact.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Email": "sacrebleu@megalol.com"}');
     
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ContactREST.updateContact();
        Test.stopTest();
        
        Contact updatedContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = 'sacrebleu@megalol.com' LIMIT 1];
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());

        Assert.areEqual(updatedContact.Id, (String)responseBody.get('Id'));
        Assert.AreEqual(200, res.statusCode);
        Assert.areNotEqual('contactemail@contactemail.com', updatedContact.Email);
        
    } 

    @isTest 
    static void contactUpdateFailTest() {

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Contact contact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE LastName = 'ContactLastName' LIMIT 1];

        req.requestURI = REQUEST_URI + contact.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"Email": "azeazeaze"}');
     
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ContactREST.updateContact();
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
        
    }

    @isTest 
    static void deleteContactTest() {
        
        Contact contact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE LastName = 'ContactLastName' LIMIT 1];
    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = REQUEST_URI + contact.Id;
        req.requestBody = Blob.valueOf('');
        req.httpMethod = 'DELETE';
     
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ContactREST.deleteContact();
        Test.stopTest();
    
        Contact deactivatedContact = [SELECT Id, FirstName, LastName, Email, Active__c FROM Contact WHERE Id = :contact.Id];
        
        Assert.areEqual(false, deactivatedContact.Active__c);
        Assert.areEqual(200, res.statusCode);
    }

    @isTest 
    static void deleteContactFailTest() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = REQUEST_URI + 'Wr0NgID';
        req.requestBody = Blob.valueOf('');
        req.httpMethod = 'DELETE';
     
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ContactRest.deleteContact();
        Test.stopTest();

        Assert.areEqual(400, res.statusCode);
      }

}