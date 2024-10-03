public without sharing class MemberImportUtility {
    
    @InvocableMethod(label='Process Member Imports' description='Upsert Person Accounts and Member Records from Member Import Staging Records')
    
    public static List<importResults> processMemberImports(List<inputVariables> inputs){
        
        
        //parse inputs and variables
        List<Member_Import__c> memberImports = inputs.get(0).memberImports;
        String uploadType = inputs.get(0).uploadType;
        Id orgId = inputs.get(0).orgId;
        
        System.debug('memberImports to process: '+memberImports);
        System.debug('uploadType: '+uploadType);
        System.debug('orgId: '+orgId);

        List<String> successResult = new List<String>(); // holds returned info
        //start of processing logic ********************************************
        
        //get PersonAccount RecordType ID
        ID personAccountRecTypeId = [SELECT Id FROM RecordType WHERE SobjectType= 'Account' AND Name = 'Person Account'].Id;
        
        //create a map of the Member Import Records from the input list of records in the flow
        Map<Id, Member_Import__c> memberImportMap = new Map<ID,Member_Import__c>(memberImports);
        //if there are no records end?????********
        
        //get a map of MemberImport match and id keys
        Map<String,Id> memberImportMatchMap = new Map<String,Id>();
        for(Member_Import__c mi : memberImports){
            memberImportMatchMap.put(mi.Member_Match_Import__c,mi.Id);
        }
        
        //create a List of Member records to be upserted
        List<Member__c> membersToUpsert = new List<Member__c>();
        
        //initialize the triggering organization account
        Account orgToUpdate = new Account();      
        List<Account> accountsToUpdate = new List<Account>();

        //if they are replacing the whole list, we need to compare existing and old members and deactivate the ones that are not on the new list. compare existing members
        if(uploadType == 'Replace List'){            
            Map<Id, Member__c> existingCurrentMemberMap = new Map<Id, Member__c>([SELECT Id, Member__c, Member_Organization__c, Status__c, Member_Match_Member__c FROM Member__c WHERE Member_Organization__c = :orgId AND Status__c = 'Current']);
            List<Member__c> existingCurrentMembers = new List<Member__c>();
            existingCurrentMembers.addall(existingCurrentMemberMap.values());           
            
            //map updating the organization account values if they are replacing their whole list.
            
            orgToUpdate.Id = orgId;
            orgToUpdate.Last_Full_Member_Upload_Completed__c = date.today();
            accountsToUpdate.add(orgToupdate);
            System.debug('orgToupdate: '+orgToupdate);
            System.debug('accountsToupdate with org for replace' + accountsToUpdate);
            
            
            //only proceed if there are current members.            
            If(!existingCurrentMemberMap.isEmpty()){                
                //for each member record we are processing, compare with member import replacement map.
                //if not on the replacement map, they need to be updated as former Status 
                for (Member__c m : existingCurrentMembers){
                    if(memberImportMatchMap.containsKey(m.Member_Match_Member__c)){
                        //what to do if the existing member is in the import file
                        //nothing
                    }
                    else{
                        //what do do if the existing member is not in the import file
                        //set Status as former and add them to the list of members to upsert. Same list that will be used to update existing members later.
                        m.Status__c = 'Former';
                        membersToUpsert.add(m); // add them to the upsert collection so they are updated for former in that step
                        // remove them from the collection? we can't while we are iterating...                        
                    }
                }
            }
        }
        //*************************************** */
        //Next, regardless of upload type, we process the Member Import list to add users, with matching existing persons and member records
        //instantiate lists for person updating and inserting
        List<Account> personsToCreate = new List<Account>();
         
        List<Member_Import__c> memberImportsToUpdate = new List<Member_Import__c>();
        
        
        //get a list of all the persons that have a match in with the member imports.
        List<Account> existingPersons = ([SELECT Id,Member_Match_Account__c, PersonEmail, LastName, PersonTitle 
        FROM Account
        WHERE Member_Match_Account__c IN :memberImportMatchMap.keySet() AND IsPersonAccount = TRUE]);
        //add these to a Map
        
        //maybe only if ther existing persons is not empty? to update... 
        Map<Id, Account> existingPersonMap = new Map<ID,Account>(existingPersons);
        
        //create an Account Match Map
        Map<String,Id> personMatchMap = new Map<String,Id>();
        //add the existing persons to the map
        for(Account a : existingPersons){
            personMatchMap.put(a.Member_Match_Account__c,a.id);
        }
        
        //get a list of all the existing member records for these people and for this organization.
        Map<Id, Member__c> existingMemberMap = new Map<Id, Member__c>([SELECT Id, Member__c, Member_Organization__c, Status__c 
        FROM Member__c 
        WHERE Member_Organization__c = :orgId AND Member__c IN :existingPersonMap.keySet()]);
        List<Member__c> existingMembers = new List<Member__c>();//do we need this list? evaluate.
        existingMembers.addall(existingMemberMap.values()); 
        //create a MemberMatch Map
        Map<String,ID> memberMatchMap = new Map<String,Id>();
        //add the existing members to the map
        for(Member__c m: existingMembers){
            memberMatchMap.put(m.Member_Match_Member__c,m.id);
        }
        
        //iterate over the import members list to check for a matching person
        for(Member_Import__c mip :memberImports ){
            
            if(personMatchMap.containsKey(mip.Member_Match_Import__c)){
                // if there is a matching person check if their title needs to be updated
                //get the person Title
                String personId = personMatchMap.get(mip.Member_Match_Import__c);
                Account existingPerson = existingPersonMap.get(personId);
                String personTitle = existingPerson.PersonTitle;
                if(mip.Title__c != personTitle){
                    Account a = new Account();
                    a.id = personId;
                    a.PersonTitle = mip.Title__c;
                    
                    accountsToUpdate.add(a); 
                }//add any persons needing to be updated to the accounts to be upserted list
                
                //AND if there is a matching person check if there is a matching member record
                if(memberMatchMap.containsKey(mip.Member_Match_Import__c)){
                    //if there is a matching member record check if it needs to be updated (if it is not current) 
                    String memberId = memberMatchMap.get(mip.Member_Match_Import__c);
                    Member__c existingMember = existingMemberMap.get(memberId);
                    String memberStatus = existingMember.Status__c;
                    
                    if(memberStatus == 'Former'){
                        Member__c mb = new Member__c();
                        mb.id = memberId;
                        mb.Status__c = 'Current';
                        membersToUpsert.add(mb);
                        //if there is a matching member record we also want to set the member import as upsert
                        Member_Import__c miu = new Member_Import__c();
                        miu.Id = mip.Id;
                        miu.Type__c = 'Upsert';
                        miu.Upsert_Date__c = Date.today();
                        memberImportsToUpdate.add(miu);
                    }
                }
                else{
                    
                    //if there is no matching member map the member values and add to a colleciton
                    Member__c mb = new Member__c();
                    mb.Member__c = personId;
                    mb.Member_Organization__c = orgId;
                    mb.Role__c = 'Organization Member';
                    mb.Status__c = 'Current';
                    System.debug('member mb: ' + mb);
                    membersToUpsert.add(mb);
                    System.debug('membersToUpsert'+membersToUpsert);
                    //if no matchin member set type as Insert
                    Member_Import__c miu = new Member_Import__c();
                    miu.Id = mip.Id;
                    miu.Type__c = 'Insert';
                    miu.Upsert_Date__c = Date.today();
                    memberImportsToUpdate.add(miu);
                }
            }
            else{
                //if there is no matching person map to create a person and a member 
                Account a = new Account();
                a.FirstName = mip.First_Name__c;
                a.LastName = mip.Last_Name__c;
                a.PersonEmail = mip.Email__c;
                a.PersonTitle = mip.Title__c; 
                a.RecordTypeId = personAccountRecTypeId;
                personsToCreate.add(a);
                //since new person and member set type as Insert
                Member_Import__c miu = new Member_Import__c();
                miu.Id = mip.Id;
                miu.Type__c= 'Insert';
                miu.Upsert_Date__c = Date.today();
                memberImportsToUpdate.add(miu);
            }
        }
        
        System.debug('personsToCreate: '+personsToCreate);
        System.debug('accountsToUpdate: '+accountsToUpdate);
        System.debug('membersToUpsert: '+membersToUpsert);
        System.debug('memberImportsToUpdate: '+memberImportsToUpdate);
        System.debug('Start of DML');
        
        
        
        //************* Done comparing and mapping time for DML */
        
        //create the people personsToCreate

        if(personsToCreate != null){
            try{
                insert personsToCreate;
                successResult.add('created Persons success');
            }
            catch(DmlException e){
                //add something here email helper
                successResult.add('created Persons failure');
            }
        
        
        
        //iterate over the created people and map the members to be created and add to existing collection
        for(Account pa : personsToCreate){
            Member__c mb = new Member__c();
            mb.Member__c = pa.Id;
            mb.Member_Organization__c = orgId;
            mb.Role__c = 'Organization Member';
            mb.Status__c = 'Current';
            membersToUpsert.add(mb);           
        }
    }
        
   
        
        //update existing accounts using accountsToUpdate
        
        if(accountsToUpdate != null){
            try{
                update accountsToUpdate;
                successResult.add('updated accounts success');
                
            }
            catch(DmlException e){
                //emailHelper('updating Accounts');
                successResult.add('updated accounts failure');
                
            }
        }
        
        //upsert new and existing members membersToUpsert
        if(membersToUpsert != null){
            try{
                upsert membersToUpsert;
                successResult.add('upsert members success');
            }
            catch(DmlException e){
                // emailHelper('upserting Members');
                successResult.add('upsert members failure');
            }
        }
        
        //update the member import records as processed. 
        if(memberImportsToUpdate != null){
            try{
                update memberImportsToUpdate;
                successResult.add('update member imports success');
            }
            catch(DmlException e){
                // emailHelper('updating import records');
                successResult.add('update member imports failure');
            }
        }
        System.debug('successResult: '+successResult);
        
        
        
        
        
        
        
        //***************************** */
        //end of processing logic

        //parse output variables
        importResults result = new importResults();
        result.importDebugResult = successResult;

        List<importResults> resultList = new List<importResults>();
        resultList.add(result);

        return resultList;

        
    }    
    
    
    
    
    // create a public class for the input and output variables. This is needed because an invocable method can only take one parameter
    
    public class inputVariables{
        
        @InvocableVariable
        public List<Member_Import__c> memberImports; //access the list of memberImport records to process
        
        @InvocableVariable
        public String uploadType; //access the flow users selected method of updating
        
        @InvocableVariable
        public String orgId;  // access the organization account id
        
    }
       
    
    public class importResults{
    
    @InvocableVariable
    public List<String> importDebugResult; //store job info? Maybe... tbd.
    
    }
  
    
    
    
}