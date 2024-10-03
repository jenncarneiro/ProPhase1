/**
 * Class called by Transaction Trigger
 * without sharing to see all records regardless of running user
 * System.debug lines can be uncommented for testing */

public without sharing class TransactionService {

    public static void createTransactionShares(List<Transaction__c> NewTransactions){

        //add each transactions account ID to a List
        Set<String> acctIds = new Set<String>(); 
        for(Transaction__c t : NewTransactions){
            acctIds.add(t.Account__c);               
        }
        //System.debug('acctIds = ' + acctIds);
        
        List<Account> acctList = [SELECT ID, Name FROM Account WHERE Id IN : acctIds];
        //System.debug('acctList =' + acctList);
        
        //create a list of the active portal users whose Primary Affiliation is in the list of accounts or whose account id is in the list of accounts. These are the users that should have shares created
        List<User> userList = [SELECT ID, Name, Account.Id, Contact.Primary_Affiliation__c, Contact.Primary_Affiliation__r.Id, UserType  FROM USER WHERE IsActive = TRUE AND UserType = 'PowerCustomerSuccess' AND (User.Contact.Primary_Affiliation__c IN: acctIds OR User.Account.Id IN: acctIds)];
        //System.debug('userList: ' + userList);

        //send the list of Transactions and Users to the Sharing Utility Class to map and create the needed shares.  
        SharingUtility.processCreateTransactionShares(NewTransactions, userList);      
    }
}
