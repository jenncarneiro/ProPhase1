global class MembershipSharingRecalc implements Database.Batchable<SObject> {  
    
    //start method to contain records to be recalculated
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator([SELECT Id, Name, Member__r.Id FROM Membership__c ]);
    }
    
    //execute method - execute the Batch for each chunk of Membership records returned from the above start method
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        // create a map and list for the chunk of memberships being processed
        Map <ID, Membership__c> membershipMap = new Map<ID, Membership__c>((List<Membership__c>)scope);
        List<Membership__c> membershipChunk = new List<Membership__c>((List<Membership__c>)scope);
        
        // create the empty share list to be inserted
        List<Membership__Share> newMembershipShares = new List<Membership__Share>();     

        //create an empty string SET to hold unique account IDs
        Set<String> acctIds = new Set<String>();
        
        //add each membership in batch's account ID to a List
        for (Membership__c m : membershipChunk){
            acctIds.add(m.Member__c);
        }
        List<Account> acctList = [SELECT ID, Name FROM Account WHERE Id IN: acctIds];
        
        // get the users to create new shares for the memberships
        List<User> userList = [SELECT ID, Name, Contact.AccountId, Contact.Primary_Affiliation__c FROM USER WHERE IsActive = TRUE AND UserType = 'PowerCustomerSuccess' AND (User.Contact.Primary_Affiliation__c IN: acctIds OR User.Contact.AccountId IN: acctIds)];
        
        //Locate all apex shared existing records for the transactions in the batch so we can delete these old shares
        Delete [SELECT Id FROM Membership__Share WHERE ParentId IN :membershipMap.keySet() AND RowCause = :Schema.Transaction__Share.rowCause.Key_Contact__c];
        
        //send the list of Transactions and Users to the Sharing Utility Class to map and create the needed shares
        SharingUtility.processCreateMembershipShares(membershipChunk, userList);        
        
    }
    
    global void finish(Database.BatchableContext BC){
        // finish method to send email confirming completion           
                        
        String subject = 'Apex Membership Sharing Recalculation Completed.';
        String body = 'The Apex Membership Sharing recalculation finished processing';
        String source = 'MembershipSharingRecalc.finish';
        List<String> addresses = new List<String>();
        Boolean apexRecip = TRUE;
        
        EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
          
    }    
}

