public without sharing class ProcessMemberImportBatch implements Database.Batchable<sObject>{
    
    //declare public variables to handle passing multiple variables in the invocable method
    public List<Member_Import__c> memberImports = new List<Member_Import__c>();
    public String uploadType;
    public String orgId;
    
    
    
    
    public ProcessMemberImportBatch(List<Member_Import__c> memberImports, String uploadType, Id orgId) {
        this.memberImports = memberImports;
        this.uploadType = uploadType;
        this.orgId = orgId;
        
    }
    
    
    //batch start set query
    // ************************ PROCESSING NEW MEMBERS *******************************
    //batchable class START method to get the needed records for batch execution
    public Database.QueryLocator start(Database.BatchableContext BC){
        //sets the query to iterate on the MemberImport staging records
        
        String query = 'SELECT ID, Account__c, Email__c,First_Name__c, Last_Name__c, Member_Match_Import__c, Person_Upsert_Status__c, Title__c, Type__c,  Upsert_Date__c FROM Member_Import__c WHERE Id IN : memberImports';
        //System.debug('start method ProcessMemberImportBatch');       
        return Database.getQueryLocator(query);
    }
    
    //batch execute
    public void execute(Database.BatchableContext BC, List<SObject> scope){
        //call the utility here. 
        //System.debug('exe method ProcessMemberImportBatch');
        List<Member_Import__c> scopedMemberImports = scope;
        
        // call the processing for imported members
        MemberImportProcessUtility.processMemberImports(scopedMemberImports, uploadType, orgId);
    }
    
    
    //batch finish
    public void finish(Database.BatchableContext BC){
        
        
        //update the organization account every time a list is uploaded with the Last Full Member Upload Completed date
        
            Account orgToUpdate = new Account();      
            List<Account> accountsToUpdate = new List<Account>();
            orgToUpdate.Id = orgId;
            orgToUpdate.Last_Full_Member_Upload_Completed__c = date.today();
            accountsToUpdate.add(orgToupdate);
            //System.debug('orgToupdate: '+orgToupdate);
            //System.debug('accountsToupdate with org for replace' + accountsToUpdate);
            
            try{
                //System.debug('Try accountsToUpdate for Org in finish');
                update accountsToUpdate;         
            }
            catch(DmlException e){
                //System.debug('Catch update accountsToUpdate for Org in finish');
                String subject = 'Error on Update Org Account Record';
                String body = 'DML Exception at accountsToUpdate: \n'  + e.getMessage();
                String source = 'ProcessMemberImportBatch Finish DML Catch';
                Boolean apexRecip = TRUE;
                List<String> addresses = new List<String>();
                
                EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
                
            }
        
        
        


        //send member import process complete email
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, ExtendedStatus, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        
        //System.debug('Finish ProcessMemberImportBatch');
        
        String source = 'ProcessMemberImportBatch Finish';
        Boolean apexRecip = TRUE;
        List<String> addresses = new List<String>();
        
        
        String subject = 'Member Import Processing Complete for Organization with ID: ' + orgId;
        
        String body = 'The Member Import Processing for Org with Id' + orgId +  '\n' +a.JobItemsProcessed + ' out of ' + a.TotalJobItems + ' batches processed \n' + a.NumberOfErrors + ' failures :' + a.ExtendedStatus  ;
        
        EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
        //System.debug('sent process complete email');
        
        
        
    }
    
}

