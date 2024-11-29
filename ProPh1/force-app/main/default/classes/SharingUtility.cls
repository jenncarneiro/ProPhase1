public without sharing class SharingUtility {
    
    //testing only variables to test exception handling
    @TestVisible private static String forceException = 'no exception';
    @TestVisible private static String exceptionMessage = 'none';
    
    // *******  method for handling Transaction Shares **********
    public static void processCreateTransactionShares(List<Transaction__c> Transactions, List<User> Users){
        
        //make a list to hold the shares to be created
        List <Transaction__Share> newTranShares = new List <Transaction__Share>();
        
        //create a map of transactions and their accounts. 
        Map<Id,Id> transactionToAccountMap = new Map<Id,Id>();
        for(Transaction__c t : Transactions){
            transactionToAccountMap.put(t.Id,t.Account__c);    
        }
        
        //create a map to list Account IDs and List of Users per account
        Map<Id,List<User>> accountIDtoUserListMap = new Map<ID,List<User>>();
        //to populate the map, iterate over the users, if you find the account key in either relationship, add the user to the list.
        for(User u : Users){
            if(!accountIDtoUserListMap.containsKey(u.Account.Id)){
                // add both the person account and the list to the map
                accountIDtoUserListMap.put(u.Account.Id, new List<User> {u});
            }     
            //then only continue if there is also a Primary Affiliation for that user
            if(u.Contact.Primary_Affiliation__c != null){
                if(accountIDtoUserListMap.containsKey((u.Contact.Primary_Affiliation__r.Id))){
                    //if their affiliation is not blank and is in the list already, add just the user to that list of users in the map
                    accountIDtoUserListMap.get(u.Contact.Primary_Affiliation__r.Id).add(u);
                }
                else{
                    //else add both the account and the user to the map
                    accountIDtoUserListMap.put(u.Contact.Primary_Affiliation__r.Id, new List<User> {u});
                }
            }
        } //now we have a populated map of account ID key and user list. 
        
        //for each transaction, iterate the list of users related to the account and map a share record for each user.        
        for(Id tID : transactionToAccountMap.keySet()){
            String aID = transactionToAccountMap.get(tID);
            List<User> tUsers = new List<User>();
            tUsers = accountIDtoUserListMap.get(aID);
            if(tusers != null){
                
                for(User u : tUsers){
                    //map the share to be created for each user, for each transaction
                    Transaction__Share ts = new Transaction__Share();
                    ts.ParentId = tID;
                    ts.RowCause = Schema.Transaction__Share.RowCause.Key_Contact__c;
                    ts.UserOrGroupId = u.id;
                    ts.AccessLevel = 'Read';
                    //add this to the list of shares to create
                    newTranShares.add(ts);                  
                }
            }
        }
        
        //insert the transaction shares to the database
        try{
            //if it is a test update one of the items to be an internal user share which is not needed          
            if(Test.isRunningTest() == true && forceException == 'force trivial'){
                //map a transaction share to an internal user who doesn't need one
                User internalUser = [SELECT Id, Name, UserType, IsActive FROM User WHERE IsActive = TRUE AND UserType = 'Standard' LIMIT 1];
                System.debug('execute test trivial transaction share' );
                Transaction__Share ts3 = newTranShares.get(0);
                ts3.UserOrGroupId = internalUser.Id;
                insert ts3;
                
            }
            //if it is a test update one of the items to remove a required field 'AccessLevel'
            if(Test.isRunningTest() == true && forceException == 'force dml in insert'){
                System.debug('execute test dml error transaction share' );

                //map a transaction share and remove the access level which is a required field
                Transaction__Share ts4 = newTranShares.get(0);
                ts4.AccessLevel = ''; 
                insert ts4;
            }
            
            // insert the shares, allowing for partial processing.
            Database.SaveResult[] lsr = Database.insert(newTranShares,false);
            
            //process save results for insert so if there are significant errors we can send notifications; These errors shouldn't happen but future proofing in case code is changed.
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    //get the first save result error
                    Database.Error err = sr.getErrors()[0];
                    //check if error is trivial: trivial if its failure is ok, because the sharing records are simply not required.
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))){
                        
                        //if not trivial, this is a significant error and submitter should be notified - map email values:
                        String subject = 'Apex Transaction Sharing Calculation Exception';
                        String body = 'The Apex Transaction Sharing Calculation threw the following exception: \n \n' + err.getMessage();
                        String source = 'SharingUtility.processCreateTransactionShares try';
                        List<String> addresses = new List<String>();
                        Boolean apexRecip = TRUE;
                        //use the email helper to send the email
                        EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
                        
                    }
                }
            }  
        }       
        
        
        catch(Exception e){
            
            if(Test.isRunningTest()){
                //if test is running set the exception message to the caught error message
                exceptionMessage = e.getMessage();
            }
            
            //send email on failure
            
            String subject = 'Apex Transaction Sharing Calculation Exception';
            String body = 'The Apex Transaction Sharing Calculation threw the following exception: \n \n' + e.getMessage();
            String source = 'SharingUtility.processCreateTransactionShares catch';
            List<String> addresses = new List<String>();
            Boolean apexRecip = TRUE;
            
            EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
            
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
            if(!accountIDtoUserListMap.containsKey(u.Account.Id)){
                //add both the person account and the list to the map 
                accountIDtoUserListMap.put(u.Account.Id, new List<User> {u});
            }            
            
            //then only continue if there is also a Primary Affiliation for that user
            if(u.Contact.Primary_Affiliation__c != null){
                if(accountIDtoUserListMap.containsKey((u.Contact.Primary_Affiliation__r.Id))){
                    //if their affiliation is not blank and is in the list already, add just the user to that list of users in the map
                    accountIDtoUserListMap.get(u.Contact.Primary_Affiliation__r.Id).add(u);
                }
                else{
                    //else add both the account and the user to the map
                    accountIDtoUserListMap.put(u.Contact.Primary_Affiliation__r.Id, new List<User> {u});
                }
            }
        } //now we have a populated map of account ID key and user list. 
        
        //for each membership record, iterate the list of users related to the account and map the share records
        Integer c = 0;
        for(Id mID : membershipToAccountMap.keySet()){
            String aID = membershipToAccountMap.get(mID);
            List<User> mUsers = new List<User>();
            mUsers = accountIDtoUserListMap.get(aID);
            if(mUsers != null){
                for(User u : mUsers){
                    //map the share to be created for each user, for each membership
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
            //if it is a test update one of the items to be an internal user share which is not needed          
            if(Test.isRunningTest() == true && forceException == 'force trivial'){
                //map a membership share to an internal user who doesn't need one
                User internalUser = [SELECT Id, Name, UserType, IsActive FROM User WHERE IsActive = TRUE AND UserType = 'Standard' LIMIT 1];
                System.debug('execute test trivial membership share' );
                Membership__Share ms3 = newMembershipShares.get(0);
                ms3.UserOrGroupId = internalUser.Id;
                insert ms3;
                
            }
            if(Test.isRunningTest() == true && forceException == 'force dml in insert'){
                //map a membership share and remove the access level which is a required field
                System.debug('execute test dml error on membership share' );
                Membership__Share ms4 = newMembershipShares.get(0);
                ms4.AccessLevel = ''; 
                insert ms4;
            }
            
            
            Database.SaveResult[] lsr = Database.insert(newMembershipShares,false); // allows partial processing.
            
            //process save results for insert so if there are significant errors we can send notifications; These errors shouldn't happen but future proofing in case code is changed.
            for(Database.SaveResult sr : lsr){

                if(!sr.isSuccess()){
                    //get the first save result error
                    Database.Error err = sr.getErrors()[0];
                    //check if error is trivial: trivial if its failure is ok, because the sharing records are simply not required.
                    System.debug('getStatusCode: ' + err.getStatusCode());
                    System.debug('getMessage: ' + err.getMessage());
                    if(!(err.getMessage().contains('field integrity exception') && err.getMessage().contains('trivial share') && err.getMessage().contains('AccessLevel')) ){
                        
                        //if not trivial, this is a significant error and submitter should be notified - map email values:
                        String subject = 'Apex Membership Sharing Calculation Exception';
                        String body = 'The Apex Membership Sharing Calculation threw the following exception: \n \n' + err.getMessage();
                        String source = 'SharingUtility.processCreateMembershipShares try';
                        List<String> addresses = new List<String>();
                        Boolean apexRecip = TRUE;
                        //use the email helper to send the email
                        EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
                    }
                }
            }            
        }
        
        
        catch(Exception e){
            System.debug('hit catch block');
            if(Test.isRunningTest()){
                //if test is running set the exception message to the caught error message
                exceptionMessage = e.getMessage();
            }
            System.debug('forceException: ' + forceException);
            System.debug('exceptionMessage: ' + exceptionMessage);
            
            //send email on failure         
            
            String subject = 'Apex Membership Sharing Calculation Exception';
            String body = 'The Apex Membership Sharing Calculation threw the following exception: \n \n' + e.getMessage();
            String source = 'SharingUtility.processCreateMembershipShares catch';
            List<String> addresses = new List<String>();
            Boolean apexRecip = TRUE;
            
            EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
            
        } 
        
    }   //end of method for MEMBERSHIP SHARES
    
}