/**
 * @description       : REST class for Contact control methods
 * @author            : Mathieu Foulon
 * @group             : 
 * @last modified on  : 17-06-2023
 * @last modified by  : Mathieu Foulon
**/
@RestResource(urlMapping='/Contacts/*')
global with sharing class ContactREST {

    /**
    * @description Triggered by POST request, create contact if email not already used
    * @author Mathieu Foulon | 16-06-2023 
    * @param String contactLastName 
    * @param String contactFirstName 
    * @param String contactEmail 
    * @param String contactPhone
    **/

    @HttpPost
    global static void createContact(String contactLastName, String contactFirstName, String contactEmail, String contactPhone) {

        RestResponse res = RestContext.response;
            if (res == null) {
                res = new RestResponse();
                RestContext.response = res;
            }
        // We will send a JSON response, optimised for API job
        res.addHeader('Content-Type', 'application/json');

        try {
            // Checking if email or phone already in DB
            List<Contact> contactList = [SELECT Id FROM Contact WHERE Email = :contactEmail OR Phone =: contactPhone LIMIT 1];

            // We found one, just sending Id
            if (contactList.size() > 0){
                Contact contact = contactList[0];

                Map<String, String> responseValuesMap = new Map<String, String>{
                    'Id' => contact.Id,
                    'Message' => 'Contact already exists, phone and email must be unique'
                };

                res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
                res.statusCode = 200;

            // Doesn't found mail or phone : creating the contact and sending his Id
            }else{
                Contact contact = new Contact (
                    LastName = contactLastName,
                    FirstName = contactFirstName,
                    Email = contactEmail,
                    Phone = contactPhone
                );


                insert contact;

                
                Map<String, String> responseValuesMap = new Map<String, String>{
                    'Id' => contact.Id,
                    'Message' => 'Contact succesfully created'
                };

                res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
                res.statusCode = 201;
            }

     	} catch(Exception e) {
            System.debug('ERROR ON CREATE: ' + e.getMessage());
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Message' => 'Contact not created, bad request'
            };
            res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            res.statusCode = 400;
        }
    }   

    /**
    * @description Triggered by PATCH request, modifies contact by its parameters in body. 
    * Params must be strictly named Salesforce style
    * @author Mathieu Foulon | 16-06-2023 
    * @return ID 
    **/
    @HttpPatch
    global static void updateContact() {

        RestResponse res = RestContext.response;
            if (res == null) {
                res = new RestResponse();
                RestContext.response = res;
            }
        // We will send a JSON response, optimised for API job
        res.addHeader('Content-Type', 'application/json');
        
        try {
            // Due to the fact that we don't know what the user want to modify, we have to access Id and params by URL and request body manualy
            RestRequest request = RestContext.request;
            // Retrieve id : last part of the url
            String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            Contact contact = [SELECT Id, Email FROM Contact WHERE Id = :contactId];
            
            // So, we deserialize in a Map the stringified version of the body, then loop through it to modify contact via put(String, Object) method
            Map<String, Object> JsonReqBodyToMap = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.toString());
            
            for(String fieldName : JsonReqBodyToMap.keySet()) {
                contact.put(fieldName, JsonReqBodyToMap.get(fieldName));
            }

            update contact;

            Map<String, String> responseValuesMap = new Map<String, String>{
                'Id' => contact.Id,
                'Message' => 'Contact succesfully updated'
            };

            res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            res.statusCode = 200;
            
        } catch(Exception e) {
            System.debug('ERROR ON UPDATE: ' + e.getMessage());
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Message' => 'Contact not updated, bad request'
            };
            res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            res.statusCode = 400;
        }
    } 

    /**
    * @description Triggered by DELETE request, deactivate a contact, not deleting him.
    * @author Mathieu Foulon | 17-06-2023 
    **/
    @HttpDelete
    global static void deleteContact(){

        RestResponse res = RestContext.response;
            if (res == null) {
                res = new RestResponse();
                RestContext.response = res;
            }
        // We will send a JSON response, optimised for API job
        res.addHeader('Content-Type', 'application/json');

        try {
            RestRequest request = RestContext.request;
            // Retrieve id : last part of the url
            String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);

            
            Contact contact = [SELECT Id, Active__c FROM Contact WHERE Id = :contactId];
            // Active__c is a checkbox type (boolean) created on purpose
            contact.Active__c = false;

            // Update, not delete ! we just want to "deactivate" and keeping him in DB
            update contact;

            Map<String, String> responseValuesMap = new Map<String, String>{
                'Message' => 'Contact '+ contact.Id +' deactivated'
            };
            res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            res.statusCode = 200;

        } catch(Exception e) {
            System.debug('ERROR ON DELETE: ' + e.getMessage());

            Map<String, String> responseValuesMap = new Map<String, String>{
                'Message' => 'Contact not deactivated, bad request'
            };
            res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            res.statusCode = 400;
        }
    }
}