//without sharing to see all records regardless of running user
//called by MembershipTrigger

public without sharing class MembershipService {
    
    public static void createMembershipShares(List<Membership__c> NewMemberships){
        //add each membership account ID to a set
        Set<String> acctIds = new Set<String>();
        for(Membership__c m : NewMemberships){
            acctIds.add(m.Member__c);
        }
        
        //create a list of accounts that are the members of the memberships. 
        List<Account> acctList = [SELECT ID, Name FROM Account WHERE Id IN : acctIds];
        
        //create a list of the users whose primary affiliation account id is in the list of accounts, or whose person account id is in the list of accounts. These are the users that should have shares created.
        List<User> userList = [SELECT ID, Name, Contact.AccountId, Account.Id, Contact.Primary_Affiliation__c, Contact.Primary_Affiliation__r.Id, UserType FROM USER WHERE IsActive = TRUE AND UserType = 'PowerCustomerSuccess' AND (User.Contact.Primary_Affiliation__c IN: acctIds OR User.Contact.AccountId IN: acctIds)];
        
        //send the list of users and memberships to the sharing utility class to map and create the needed shares.
        SharingUtility.processCreateMembershipShares(NewMemberships, userList);
    }
}