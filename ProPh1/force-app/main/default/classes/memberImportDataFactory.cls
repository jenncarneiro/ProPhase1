@isTest


public without sharing class memberImportDataFactory {
    //Test data factory to create data for member import testing
    
    public static String CreateOrganization(){
        //create one organization
        Account a = new Account();
        a.Name = 'Member Organization';
        a.Last_Full_Member_Upload_Completed__c = null;
        insert a;
        String OrgId = a.Id;
        return OrgId;
        
    }
    
    
    //create some pre-existing people
    
    public static List<Account> CreateExistingPersons(Integer numPersons, String type){
        //create a number of existing Persons based on the test case
        
        List<Account> existingPersons = new List<Account>();
        
        //get PersonAccount RecordType ID so that we can map it when we need to create person accounts
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        ID personAccountRecTypeId = rtMapByName.get('Person Account').getRecordTypeId();
        
        
        for(integer i=0; i<numPersons; i++){
            
            Account a = new Account();
            a.FirstName = 'Existing';
            a.LastName =  'Person' + type + i;
            a.PersonTitle = 'Engineer';
            a.PersonEmail = 'email@test'+i+'.com';
            a.RecordTypeId = personAccountRecTypeId;
            existingPersons.add(a);
        }
        insert existingPersons;
        return existingPersons;
        
    }
    
    
    //create some existing members for those people
    
    public static List<Member__c> CreateExistingMembers(List<Account> memberPersons, Integer numMembers, String status, String orgId){
        
        List<Member__c> existingMembers = new List<Member__c>();
        for(Account a : memberPersons){
            //map a list of members
            Member__c m = new Member__c();
            m.Member__c = a.Id;
            m.Member_Organization__c = orgId;
            m.Role__c = 'Organization Member';
            m.Status__c = status;
            existingMembers.add(m);
        }

        insert existingMembers;
        return existingMembers;
    }
    
    public static List<Member_Import__c> CreateMemberImports(List<Account> allExistingPersons,Integer numImports){
        List<Member_Import__c> memberImports = new List<Member_Import__c>();
        //create member imports. 
        //create member imports for non existing persons/members
        for(Integer i=0; i<numImports; i++){
            Member_Import__c mi = new Member_Import__c();
            mi.First_Name__c = 'MemberList';
            mi.Last_Name__c = 'NewPerson' + i;
            mi.Title__c = 'Software Engineer';
            mi.Email__c = 'newemail@test'+i+'.com';
            memberImports.add(mi);
        }

        for(Account a : allExistingPersons){
            Member_Import__c mi = new Member_Import__c();
            mi.First_Name__c = a.FirstName;
            mi.Last_Name__c = a.LastName;
            mi.Title__c = 'Software Engineer'; //represents a change in title
            mi.Email__c = a.PersonEmail;
            memberImports.add(mi);
        }


        insert memberImports;
        return memberImports;
    }
}





