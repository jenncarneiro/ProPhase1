public without sharing class MemberImportInvocable {
    
    //declare public variables to handle passing multiple variables in the invocable method
    public List<Member_Import__c> batchMemberImports = new List<Member_Import__c>();
    public String batchUploadType;
    public String batchOrgId;
    
    //constructor to set the variables needed passed from flow to batchable method
    public MemberImportInvocable(List<Member_Import__c> memberImports, String uploadType, String orgId) {
        this.batchMemberImports = memberImports;
        this.batchUploadType = uploadType;
        this.batchOrgId = orgId; 
    }
    //class to allow passing of three variables as one list in the invocable method
    public class inputVariables {
        
        @InvocableVariable
        public List<Member_Import__c> memberImports; //access the list of memberImport records to process
        
        @InvocableVariable
        public String uploadType; //access the flow users selected method of updating
        
        @InvocableVariable
        public String orgId;  // access the organization account id
        
    }
    
    
    //invocable method to call batch processing from flow, parsing the passed in variables
    @InvocableMethod(label='Process Member Imports V4' description='Upsert Person Accounts and Member Records from Member Import Staging Records')
    public static void processMemberImportBatch(List<inputVariables> inputs){
        
        //System.debug('called Invocable Method');
        
        //parse inputs and variables
        List<Member_Import__c> memberImports = inputs.get(0).memberImports;
        String uploadType = inputs.get(0).uploadType;
        Id orgId = inputs.get(0).orgId;
        
        // System.debug('memberImports to process: '+memberImports);
        // System.debug('uploadType: '+uploadType);
        // System.debug('orgId: '+orgId);
        
        //depending on whether a replacement list or a new list, call the appropriate batch
        
        if(uploadType == 'Replace List'){// if it is an upload we need to make all current members former. then call the imported member processing in the finish method of the MemberUpdateBatch class. 
            
            //System.debug('called MemberupdateBatch because was replace list');
            Id jobId = Database.executeBatch(new ProcessCurrentMembersBatch(memberImports, uploadType, orgId) , 1000);
        }
        
        else{ // if it is not a replacement list just call process member list functions. 
            
            //System.debug('called processMemberImportBatch because not replace list');
            
            Id jobId = Database.executeBatch(new processMemberImportBatch(memberImports, uploadType, orgId), 1000); 
        }
    }
    
    
}