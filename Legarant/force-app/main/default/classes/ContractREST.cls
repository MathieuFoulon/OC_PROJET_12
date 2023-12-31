/**
 * @description       : REST class for Contract control methods
 * @author            : Mathieu Foulon
 * @group             : 
 * @last modified on  : 18-06-2023
 * @last modified by  : Mathieu Foulon
**/
@RestResource(urlMapping='/Contracts/*')
global with sharing class ContractREST {

    /**
    * @description Triggered by POST request, create contract 
    * @author Mathieu Foulon | 18-06-2023 
    * @param Id contractAccountId 
    * @param String contractStatus 
    * @param Date contractStartDate 
    * @param Integer contractNumberOfMonth 
    **/
    @HttpPost
    global static void createContract(String contractAccountId, String contractStatus, Date contractStartDate, Integer contractNumberOfMonth) {

        RestResponse res = RestContext.response;
            if (res == null) {
                res = new RestResponse();
                RestContext.response = res;
            }
        // We will send a JSON response, optimised for API job
        res.addHeader('Content-Type', 'application/json');

        try {
            Contract contract = New Contract(
            AccountId = contractAccountId,
            Status = contractStatus,
            StartDate = contractStartDate,
            ContractTerm = contractNumberOfMonth
            );

            insert contract;
            
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Id' => contract.Id,
                'Message' => 'Contract succesfully created'
            };

            res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            res.statusCode = 201;

        } catch (Exception e) {
            System.debug('ERROR ON CREATE: ' + e.getMessage());
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Message' => 'Contract not created, bad request'
            };
            res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            res.statusCode = 400;
        }
    }

    /**
    * @description Triggered by PATCH request, modifies contract by its parameters in body. 
    * Params must be strictly named Salesforce style
    * @author Mathieu Foulon | 18-06-2023 
    **/
    @HttpPatch
    global static void updateContract() {

        RestResponse res = RestContext.response;
            if (res == null) {
                res = new RestResponse();
                RestContext.response = res;
            }
        // We will send a JSON response, optimised for API job
        res.addHeader('Content-Type', 'application/json');

        try {
            RestRequest request = RestContext.request;
            String contractId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);

            Contract contract = [SELECT Id FROM Contract WHERE Id = :contractId];

            Map<String, Object> JsonReqBodyToMap = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.toString());

            for(String field : JsonReqBodyToMap.keySet()) {
                contract.put(field, JsonReqBodyToMap.get(field));
            }

            update contract;
            
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Id' => contract.Id,
                'Message' => 'Contract succesfully updated'
            };

            res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            res.statusCode = 200;

        } catch (Exception e) {
            System.debug('ERROR ON UPDATE: ' + e.getMessage());
            Map<String, String> responseValuesMap = new Map<String, String>{
                'Message' => 'Contact not updated, bad request'
            };
            res.responseBody = Blob.valueOf(JSON.serialize(responseValuesMap));
            res.statusCode = 400;
        }
    }
}