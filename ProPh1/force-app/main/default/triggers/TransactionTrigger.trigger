trigger TransactionTrigger on Transaction__c (after insert, after update) {
    
    //create shares for any new transactions after insert
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            TransactionService.createTransactionShares(trigger.new); 
        }
    }
    
    //replace shares for any transactions where the Account is changed.
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            //we only want to update sharing records if the Account field is changed. These are added to a list which is passed to the service class.
            List<Transaction__c> processTransactions = new List<Transaction__c>();
            
            for(Transaction__c t : trigger.new){
                Transaction__c oldT = Trigger.oldMap.get(t.Id);
                if(t.Account__c != oldT.Account__c){
                    processTransactions.add(t);
                }
            }
            
            // We want to delete the share records that are shared because of the user's affiliation with the Account which has changed. We will have this in the trigger for now as it is only one line of code it is currently more efficient.
            
            delete [SELECT Id FROM Transaction__Share WHERE ParentID In: processTransactions AND RowCause = :Schema.Transaction__Share.rowCause.Key_Contact__c];
            
            // Then we need to create the new share records for the users that are affiliated with the new Account.
            TransactionService.createTransactionShares(processTransactions);
        }
    }
    
    
}