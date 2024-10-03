public with sharing class AccountService {
      
    public static void updatePersonAccountContactUserShares(List<Account> updatedAccounts,Map<Id,Account> oldAccountMap){

        //refactored to take in Person Accounts lists and map them to updated Contacts list.      
        //we only want to update shares for users related to the Person Accounts / contacts updated, and only if the primary affiliation changed. 

        // Create a set of Contact Ids from the List only for those person Accounts that have had a changed affiliation
        System.debug('updateContactUserShares method start');
        Set<String> updatedContactIds = new Set<String>();
        for(Account ua : updatedAccounts){
            Account olda = oldAccountMap.get(ua.id);
            if(ua.Primary_Affiliation__pc != olda.Primary_Affiliation__pc){
                updatedContactIds.add(ua.PersonContactId);
            }
        }
        system.debug('list of updated Contacts: ' + updatedContactIds);
        //only proceed if we have contacts whose Primary Affiliation has changed
        if(!updatedContactIds.isEmpty()){
            //create a list of the related users
            List<User> relatedPortalUsers = [SELECT Id, Account.Id, IsActive, IsPortalEnabled, ContactId, AccountId, Contact.Primary_Affiliation__c, Contact.Primary_Affiliation__r.Id, UserType FROM User WHERE IsActive = true AND ISPortalENabled = TRUE AND UserType = 'PowerCustomerSuccess' AND ContactId IN: updatedContactIds];
            System.debug('list of related portal users: ' + relatedPortalUsers);
            //only proceed if we found users
            if(!relatedPortalUsers.isEmpty()){                
                
                //Delete any existing Transaction Share records for the users
                delete [SELECT Id FROM Transaction__Share WHERE UserOrGroupID IN: relatedPortalUsers AND RowCause = :Schema.Transaction__Share.rowCause.Key_Contact__c];
                
                //Delete any existing Membership Share records for the users
                delete[SELECT ID FROM Membership__Share WHERE UserOrGroupID IN: relatedPortalUsers AND RowCause = :Schema.Membership__Share.rowCause.Key_Contact__c];
                
                //get a Set of the Person Account IDS and unique Primary Affiliation Account Ids for these users to filter out the records to be shared
                
                Set<String> acctIds = new Set<String>();
                for(User u : relatedPortalUsers){
                    acctIds.add(u.AccountId);
                    if(u.Contact.Primary_Affiliation__c != null){
                        acctIds.add(u.Contact.Primary_Affiliation__c);
                    }
                }    
                System.debug('List of account ids related to user');
                //find the Transactions that will need shares created
                List<Transaction__c> processTransactions = [SELECT ID, Account__r.Id FROM Transaction__c WHERE Account__r.Id In: acctIds];
                //if not null send for processing to the sharing utility
                if(!processTransactions.isEmpty()){
                    SharingUtility.processCreateTransactionShares(processTransactions, relatedPortalUsers);
                }
                System.debug('list of transactions: '+processTransactions);
                
                //find the Memberships that will need shares created
                List<Membership__c> processMemberships = [SELECT ID, Member__r.Id FROM Membership__c WHERE Member__r.Id IN: acctIds];
                //if not null send for processing to the sharing utility
                if(!processMemberships.isEmpty()){
                    SharingUtility.processCreateMembershipShares(processMemberships, relatedPortalUsers);
                    
                } 
                System.debug('list of memberships: '+processMemberships);
            }
        }
    }
}