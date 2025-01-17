global class TransactionSharingRecalc implements Database.Batchable<SObject> {  
    
    //start method to contain records to be recalculated
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator([SELECT Id, Name, Account__r.Id FROM Transaction__c ]);
    }
    
    //execute method - execute the Batch for each chunk of Transaction records returned from the above start method
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        // create a map and list for the chunk of transactions being processed
        Map <ID, Transaction__c> transactionMap = new Map<ID, Transaction__c>((List<Transaction__c>)scope);
        List<Transaction__c> transactionChunk = new List<Transaction__c>((List<Transaction__c>)scope);
        
        // create the empty share list to be inserted
        List<Transaction__Share> newTransactionShares = new List<Transaction__Share>();     

        //create an empty string SET to hold unique account IDs
        Set<String> acctIds = new Set<String>();
        
        //add each transaction in batch's account ID to a List
        for (Transaction__c t : transactionChunk){
            acctIds.add(t.Account__c);
        }
        List<Account> acctList = [SELECT ID, Name FROM Account WHERE Id IN: acctIds];
        
        // get the users to create new shares for
        List<User> userList = [SELECT ID, Name, Account.Id, Contact.AccountId, Contact.Primary_Affiliation__c, Contact.Primary_Affiliation__r.Id, UserType FROM USER WHERE IsActive = TRUE AND UserType = 'PowerCustomerSuccess' AND (User.Contact.Primary_Affiliation__c IN: acctIds OR User.Contact.AccountId IN: acctIds)];
        
        //Locate all apex shared existing records for the transactions in the batch so we can delete these old shares
        Delete [SELECT Id FROM Transaction__Share WHERE ParentId IN :transactionMap.keySet() AND RowCause = :Schema.Transaction__Share.rowCause.Key_Contact__c];
        
        //send the list of Transactions and Users to the Sharing Utility Class to map and create the needed shares
        SharingUtility.processCreateTransactionShares(transactionChunk, userList);        
        
    }
    
    global void finish(Database.BatchableContext BC){
        // finish method to send email confirming completion

        String subject = 'Apex Transaction Sharing Recalculation Completed.';
        String body = 'The Apex Transaction Sharing recalculation finished processing';
        String source = 'TransactionSharingRecalc.finish';
        List<String> addresses = new List<String>();
        Boolean apexRecip = TRUE;
        
        EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
    }
    
    
}

