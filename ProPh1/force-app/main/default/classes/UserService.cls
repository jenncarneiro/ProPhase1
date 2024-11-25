public without sharing class UserService {
  
    @future
    public static void createPortalUserShares(Set<Id> newUserIds){
        //we only want to create shares for portal users, for their own person account records and for any records for their primary affiliation account organizations.
        
        List<User> processUsers = [SELECT Id, Name, Contact.AccountId, Account.Id, Contact.Primary_Affiliation__c, Contact.Primary_Affiliation__r.Id, UserType FROM User WHERE IsActive = true AND IsPortalEnabled = TRUE AND UserType = 'PowerCustomerSuccess'AND Id IN :newUserIds];
        
        //only proceed if there are users to review
        if(!processUsers.isEmpty()){
            //get a Set of the Account IDs and Primary Affiliation IDs for these users to filter out the records to be shared and minimize the processing
            Set<String> acctIds = new Set<String>();
            for(User u : processUsers){
                acctIds.add(u.AccountId);
                if(u.Contact.Primary_Affiliation__c != null){
                    acctIds.add(u.Contact.Primary_Affiliation__c);
                }
            }
            
            //find the transactions that will need shares created
            List<Transaction__c> processTransactions = [SELECT Id, Account__r.Id FROM Transaction__c WHERE Account__r.Id IN : acctIds ];
            
            //if the list has records, send the list of users and transactions to the sharing utility to create the shares
            if(!processTransactions.isEmpty()){
                SharingUtility.processCreateTransactionShares(processTransactions, processUsers);
            }
            //find the memberships that will need shares created
            List<Membership__c> processMemberships = [SELECT ID, Member__r.Id FROM Membership__c WHERE Member__r.Id In : acctIds];
            //if the list has records, send the list of users and memberships to the sharing utility to create the sahres
            if(!processMemberships.isEmpty()){
                SharingUtility.processCreateMembershipShares(processMemberships, processUsers);
            }
        }
    }
}