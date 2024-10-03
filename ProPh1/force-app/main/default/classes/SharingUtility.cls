public without sharing class SharingUtility {
    
    
    // *******  method for handling Transaction Shares **********
    public static void processCreateTransactionShares(List<Transaction__c> Transactions, List<User> Users){
        
        //make a list to hold the shares to be created
        List <Transaction__Share> newTranShares = new List <Transaction__Share>();
        
        //create a map of transactions and their accounts. 
        Map<Id,Id> transactionToAccountMap = new Map<Id,Id>();
        for(Transaction__c t : Transactions){
            transactionToAccountMap.put(t.Id,t.Account__c);    
        }
        //System.Debug('transactionToAccountMap: ' +transactionToAccountMap );
        
        
        //create a map to list Account IDs and List of Users per account
        Map<Id,List<User>> accountIDtoUserListMap = new Map<ID,List<User>>();
        //to populate the map, iterate over the users, if you find the account key in either relationship, add the user to the list.
        for(User u : Users){
            if(accountIDtoUserListMap.containsKey(u.Account.Id)){
                accountIDtoUserListMap.get(u.Account.Id).add(u); //if the user's person account is in the map, add the user to that accounts list of users in the map
            }
            else{
                accountIDtoUserListMap.put(u.Account.Id, new List<User> {u});//else add both the person account and the list to the map
            }
            
            //then only if there is also a Primary Affiliation for the user
            if(u.Contact.Primary_Affiliation__c != null){
                if(accountIDtoUserListMap.containsKey((u.Contact.Primary_Affiliation__r.Id))){
                    accountIDtoUserListMap.get(u.Contact.Primary_Affiliation__r.Id).add(u);//if their affiliation is not blank and is in the list, add the user to that list of users in the map
                }
                else{
                    accountIDtoUserListMap.put(u.Contact.Primary_Affiliation__r.Id, new List<User> {u});//else add the account and the user to the map
                }
            }
        }
        //now we have a populated map of account ID key and user list. 
        //System.Debug('accountIDtoUserListMap: ' + accountIDtoUserListMap);
        
        //for each transaction, map a share record for each user.        
        for(Id tID : transactionToAccountMap.keySet()){
            String aID = transactionToAccountMap.get(tID);
            //System.Debug('aID: ' + aID);
            List<User> tUsers = new List<User>();
            tUsers = accountIDtoUserListMap.get(aID);
            //System.Debug('tUsers: ' + tUsers);
            
            if(tUsers != null ){
                for(User u : tUsers){
                    Transaction__Share ts = new Transaction__Share();
                    ts.ParentId = tID;
                    ts.RowCause = Schema.Transaction__Share.RowCause.Key_Contact__c;
                    ts.UserOrGroupId = u.id;
                    ts.AccessLevel = 'Read';
                    //System.debug('ts: ' + ts);
                    //add this to the list of shares to create
                    newTranShares.add(ts);
                    //System.debug('newTranShares: ' + newTranShares);
                    
                }
            }
        }
        
        //insert the transaction shares to the database
        try{
            Database.SaveResult[] lsr = Database.insert(newTranShares,false);
            
            //process save results for insert
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    //get the first save result error
                    Database.Error err = sr.getErrors()[0];
                    //check if error is trivial, if it is failure is ok because the sharing records are not required.
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))){
                        //this is a significant error and submitter should be notified
                        
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        ApexEmailRecipientUtility em = ApexEmailRecipientUtility.getInstance();
                        String [] toAddresses = em.emailList;
                        mail.setToAddresses(toAddresses);
                        mail.setSubject('Apex Transaction Sharing Calculation Exception');
                        mail.setPlainTextBody('The Apex Transaction Sharing Calculation threw the following exception: ' + err.getMessage());
                        if(toAddresses != null){// only send if there are recipients
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
                        }
                    }
                }
            }         
        }
        
        catch(DmlException e){
            //send email on failure
            
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            ApexEmailRecipientUtility em = ApexEmailRecipientUtility.getInstance();
            String [] toAddresses = em.emailList;
            mail.setToAddresses(toAddresses); 
            mail.setSubject('Apex Transaction Sharing Calculation Exception');
            mail.setPlainTextBody(
            'The Apex Transaction Sharing Calculation threw the following exception: ' + 
            e.getMessage());
            if(toAddresses != null){ // only send if there are recipients
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
            }
            
        }  
        
    }//end of method for TRANSACTION SHARES
    
    
    
    
    
    
    //*******************  method for handling Membership shares **************************
    
    public static void processCreateMembershipShares(List<Membership__c> Memberships, List<User> Users){
        
        //make a list to hold the shares to be created
        List<Membership__Share> newMembershipShares = new List <Membership__Share>();
        
        //create a map of memberships and their accounts. 
        Map<Id,Id> membershipToAccountMap = new Map<Id,Id>();
        for(Membership__c m : Memberships){
            membershipToAccountMap.put(m.Id,m.Member__c);    
        }
        
        //create a map to list Account IDs and List of Users per account
        Map<Id,List<User>> accountIDtoUserListMap = new Map<ID,List<User>>();
        
        //to populate the map, iterate over the users, if you find the account key in either relationship, add the user to the list.
        
        for(User u : Users){
            if(accountIDtoUserListMap.containsKey(u.Account.Id)){
                accountIDtoUserListMap.get(u.Account.Id).add(u); //if the user's person account is in the map, add the user to that accounts list of users in the map
            }
            else{
                accountIDtoUserListMap.put(u.Account.Id, new List<User> {u});//else add both the person account and the list to the map
            }
            
            //then only if there is also a Primary Affiliation for the user
            if(u.Contact.Primary_Affiliation__c != null){
                if(accountIDtoUserListMap.containsKey((u.Contact.Primary_Affiliation__r.Id))){
                    accountIDtoUserListMap.get(u.Contact.Primary_Affiliation__r.Id).add(u);//if their affiliation is not blank and is in the list, add the user to that list of users in the map
                }
                else{
                    accountIDtoUserListMap.put(u.Contact.Primary_Affiliation__r.Id, new List<User> {u});//else add the account and the user to the map
                }
            }
        } //now we have a populated map of account ID key and user list. 
        
        //for each membership record, iterate the list of users related to the account and map the share records
        
        for(Id mID : membershipToAccountMap.keySet()){
            String aID = membershipToAccountMap.get(mID);
            List<User> mUsers = new List<User>();
            mUsers = accountIDtoUserListMap.get(aID);
            if(mUsers != null){
                for(User u : mUsers){
                    
                    //map the share to be created
                    Membership__Share ms = new Membership__Share();
                    ms.ParentId = mID;
                    ms.RowCause = Schema.Membership__Share.RowCause.Key_Contact__c;
                    ms.UserOrGroupId = u.id;
                    ms.AccessLevel = 'Read';
                    //add to list of shares to create
                    newMembershipShares.add(ms);
                }
            } 
        }
        
        //insert the membership Shares to the database
        try{
            Database.SaveResult[] lsr = Database.insert(newMembershipShares,false);
            
            //process save results for insert
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    //get the first save result error
                    Database.Error err = sr.getErrors()[0];
                    //check if error is trivial, if it is failure is ok because the sharing records are not required.
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))){
                        //this is a significant error and submitter should be notified
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        ApexEmailRecipientUtility em = ApexEmailRecipientUtility.getInstance();
                        String [] toAddresses = em.emailList;
                        mail.setToAddresses(toAddresses);
                        mail.setSubject('Apex Membership Sharing Calculation Exception');
                        mail.setPlainTextBody('The Apex Membership sharing Calculation threw the following exception: ' + err.getMessage());
                        if(toAddresses != null){// only send if there are recipients
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
                        }
                        
                    }
                }
            }  
            
        }
        catch(DmlException e){
            //send email on failure
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            ApexEmailRecipientUtility em = ApexEmailRecipientUtility.getInstance();
            String [] toAddresses = em.emailList;
            mail.setToAddresses(toAddresses); 
            mail.setSubject('Apex Membership Sharing Calculation Exception');
            mail.setPlainTextBody(
            'The Apex Membership Sharing Calculation threw the following exception: ' + 
            e.getMessage());
            if(toAddresses != null){ // only send if there are recipients
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
            }
        }
    }   
    
}