//Test factory to create data for Apex Sharing classes

@isTest

public without sharing class SharingTestDataFactory {
    
    //setup test organizations and persons for sharing record testing.
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
        
        List<Account> myOrgs = [SELECT Id, Name FROM Account];
        List<Account> myPersons = new List<Account>();
        //get PersonAccount RecordType ID so that we can map it when we need to create person accounts
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        ID personAccountRecTypeId = rtMapByName.get('Person Account').getRecordTypeId();
        //create regular person accounts with no primary affiliation
        
        for(integer i=0; i<numPersons; i++){
            Account person = new Account();
            person.FirstName = 'Person';
            person.LastName = 'Last ' + i;
            person.PersonEmail = 'person'+i+'@fakeprorec.com';
            person.RecordTypeId = personAccountRecTypeId;
            myPersons.add(person);
            
        }
        
        //create person accounts with a primary affiliation
        for(Account o  : myOrgs){
            for(integer i=0; i<numPersonUsers; i++){
                Account person = new Account();
                person.FirstName = 'PersonUser';
                person.LastName = o.Name + i;
                person.PersonEmail = 'person'+o.Name+i+'@fakeuserprorec.com';
                person.RecordTypeId = personAccountRecTypeId;
                person.Primary_Affiliation__pc = o.Id;
                myPersons.add(person);
                
            }
        }
        //System.debug('myPersons: ' + myPersons);
        insert myPersons;
        return myPersons;
    }
    
    public static List<User> createUser(List<Account> userAccountList){
        //take in a list of person accounts and create users for that list
        List<Account> userAccounts = [SELECT Id, FirstName, LastName, PersonEmail, PersonContactId, IsPersonAccount FROM Account Where ID IN :userAccountList];
        //System.debug('userAccounts: '+ userAccounts);
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Pro CCP Login User' LIMIT 1];
        List<User> newUsers = new List<User>();
        Integer num = 1;
        for (Account a : userAccounts){
            User u = new User();
            u.FirstName = a.FirstName;
            u.LastName = a.LastName;
            u.UserName = a.FirstName + a.PersonEmail+num;
            u.Email = a.PersonEmail;
            u.Alias = 'user'+num;
            u.TimeZoneSidKey = 'America/New_York';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            u.ProfileId = profile.Id;
            u.ContactId = a.PersonContactId;
            num = num+1;
            newUsers.add(u);
            //System.debug('setup create user in data factory: ' + u);
            
        }
        //System.debug('newUsers: '+ newusers);
        insert newUsers;
        return newUsers;
        
    }
    
    //create memberships for the organizations / persons
    public static List<Membership__c> createMemberships(List<Account> memberAccountList){
        List<Membership__c> newMemberships = new List<Membership__c>();
        for (Account a : memberAccountList){
            Membership__c m = new Membership__c();
            m.Member__c = a.Id;
            m.Program__c = 'PRO';
            m.Status__c = 'Registered';
            if(a.IsPersonAccount == TRUE){
                m.Type__c = 'Individual';
                m.Plan__c = 'Individual';
            }
            else{
                m.Type__c = 'Organization';
                m.Plan__c = 'Municipal';
            }
            m.Do_Not_Send_Welcome_Email__c = TRUE;
            newMemberships.add(m);
        }
        insert newMemberships;
        return newMemberships;
    }
    
    //create transactions for the memberships
    public static List<Transaction__c> createTransactions(List<Membership__c> memberships){
        List<Transaction__c> newTransactions = new List<Transaction__c>();
        for(Membership__c m : memberships){
            Transaction__c t = new Transaction__c();
            t.Type__C = 'Invoice';
            t.Status__c = 'Open';
            t.Account__c = m.Member__c;
            t.Billing_Email__c = 'fakeemail@fake.com';
            t.Do_Not_Create_Invoice__c = TRUE;
            t.Subtotal__c = 100.00;
            t.Tax_Type__c = 'HST (ON)';
            t.Tax_Amount__c = 13.00;
            t.Total__c = 113.00;
            t.GL_Code__c = '4160';
            t.GL_Class__c = 'PRO Membership';
            t.Membership__c = m.Id;
            t.Transaction_Date__c = date.today();
            newTransactions.add (t);
        }
        insert newTransactions;
        return newTransactions;
        
        
        
    }
    
    
    
    
    
    
    
    
    // test changing someone's title for member importing
    
    
    
    
}