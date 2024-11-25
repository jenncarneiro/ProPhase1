public without sharing class ProcessCurrentMembersBatch implements Database.Batchable<sObject>{
    
    //declare public variables to handle passing multiple variables in the invocable method
    // see if we need this!  
    public List<Member_Import__c> memberImports = new List<Member_Import__c>();
    public String uploadType;
    public String orgId;
    
    //constructor to set variables passed from invocable method
    public ProcessCurrentMembersBatch(List<Member_Import__c> memberImports, String uploadType, Id orgId) {
        this.memberImports = memberImports;
        this.uploadType = uploadType;
        this.orgId = orgId;
    }
    //batch class inputs will be:
    //list of member imports, org id, upload type, 
    
    //batchable class START method to get the needed records for batch execution
    public Database.QueryLocator start(Database.BatchableContext BC){
        // set the query for the current member records to iterate over and potentially update to former if not in the member import list
        String query = 'SELECT ID, Status__c, Member_Organization__c, Member_Match_Member__c FROM Member__c WHERE Status__c = \'Current\' AND Member_Organization__c =: orgId';
        //System.debug('start method processCurrentMembersBatch');       
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BCM, List<Member__c> scope){
        //call the utility here. 
        
        
        //System.debug('exe method processCurrentMembersBatch');   
        List <Member__c> existingCurrentMembers = scope;//call the existing member records passed in
        
        //System.debug('member imports: '+ memberImports);
        //System.debug('orgId: '+ orgId);
        //System.debug('upload Type: '+ uploadType);
        
        //Call the utility to process the current members
        MemberImportProcessUtility.processCurrentMembers(existingCurrentMembers, memberImports, uploadType, orgId);  
        
    }
    
    //add finish method; finish method needs to call processmemberimport batch
    public void finish(Database.BatchableContext BCM){
        
        //System.debug('finish method processCurrentMembersBatch');  
        
        //call next batch process to process imported members 
        Id jobId = Database.executeBatch(new processMemberImportBatch(memberImports, uploadType, orgId), 1000); 
        
        
    }
    
    
}