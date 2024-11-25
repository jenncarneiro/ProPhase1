//Test factory to create data for Apex Sharing classes

@isTest

public without sharing class SharingTestDataFactory {
    public SharingTestDataFactory() {
        
    }
   /*    
    public static List<Account> testOrganizations(Integer numOrgs){
        //create and return a list of organization accounts
        
        List<Account> myOrgs = new List<Account>();
        
        for (integer i=0; i<numOrgs; i++){
            Account org = new Account();
            org.Name = 'Organization' + i; // no spaces as using this for email
          //  org.RecordTypeId = ;
            myOrgs.add(org);
            
        }
        insert myOrgs;
        return myOrgs;
    }
    
    //create test person accounts for each Org Account
    
    public static List<Account> testPersons(Integer numPersons, Integer numPersonUsers){
        //create test person accounts for each Org Account
        
        List<Account> myOrgs = [SELECT Id, Account_Contact__c FROM Account];
        List<Account> myPersons = new List<Account>();
        
        //create regular person accounts with no primary affiliation
        
        for(integer i=0; i<numPersons; i++){
            Account person = new Account();
            person.FirstName = 'Person';
            person.LastName = o.Name + i;
            person.email = 'person'+o.Name+i+'@fake.com';
           // person.RecordTypeId = ;
            myPersons.add(person);
            
        }
        
        //create person accounts with a primary affiliation
        for(org o  : myOrgs){
            for(integer i=0; i<numPersons; i++){
                Account person = new Account();
                person.FirstName = 'Person';
                person.LastName = o.Name + i;
                person.email = 'person'+o.Name+i+'@fake.com';
               // person.RecordTypeId = ;
                person.Primary_Affiliation__pc = o.Id;
                myPersons.add(person);
                
            }
        }
        
        insert myPersons;
        return myPersons;
    }
    
    */
    
    
}