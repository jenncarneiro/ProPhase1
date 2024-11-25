public without sharing class MemberImportProcessUtility {
    
    //utility class with two methods to sent replace members to former and logic to match and upsert Person Accounts, Members, and update MemberImport records
    public MemberImportProcessUtility() {
        
    }
    
    //************* REPLACEMENT LIST PROCESSING OF EXISTING MEMBERS *****************
    
    public static void processCurrentMembers(List <Member__c> existingCurrentMembers, List<Member_Import__c> memberImports, String uploadType, Id orgId ){
        
        
        //create a map of the Member Import Records from the input list of records in the flow. This is so we have them in map format
        Map<Id, Member_Import__c> memberImportMap = new Map<ID,Member_Import__c>([SELECT ID, Account__c, Email__c,First_Name__c, Last_Name__c, Person_Upsert_Status__c, Title__c, Type__c, Member_Match_Import__c, Upsert_Date__c FROM Member_Import__c WHERE Id IN : memberImports]);
        //System.Debug('Replacement List Processing - setting members as former if not on upload list');
        
        //each object we need to compare (Member_Import, Member, Account) has a formula field to concatenate our matching criteria. We create a map for each object where this field is the key with the corresponding ID as a value so that we can check for existing records based on our matching criteria and access the matched record
        //Member_Import__c.Member_Match_Import__c, Member__c.Member_Match_Member__c, Account.Member_Match_Account__c are the fields
        
        //get a map of MemberImport match and id keys and populate the map 
        Map<String,Id> memberImportMatchMap = new Map<String,Id>();
        for(Member_Import__c mi : memberImports){
            memberImportMatchMap.put(mi.Member_Match_Import__c,mi.Id);
        }
        //create the list to store members to be marked as former
        List<Member__c> membersToUpdate = new List<Member__c>();
        
        //if they are replacing the whole list, we need to compare existing current members against the memberimport records and deactivate (set member record status to former) the ones that are not on the new list. We compare existing members matching criteria against the memberimport records.
        
        Map<Id, Member__c> existingCurrentMemberMap = new Map<ID, Member__c>(existingCurrentMembers);
        
        
        //for each member record we are processing, compare with member import replacement map.
        //if not on the replacement map, they need to be updated as former Status 
        for (Member__c m : existingCurrentMembers){
            if(!memberImportMatchMap.containsKey(m.Member_Match_Member__c)){
                //what do do if the existing member is not in the import file
                //set Status as former and add them to the list of member records to upsert. Same list that will be used to update existing members later to minimize DML.
                m.Status__c = 'Former';
                membersToUpdate.add(m);     
            }
        }
        
        // ** UPDATING EXISTING MEMBERS DML **
        
        
        try{
            //System.debug('updating member records');
            update membersToUpdate;
            
        }
        catch(DmlException e){
            //String errorType = 'Error Updating Former Members';
            // batchresult.add('\n DML Exception at Updating Member to Former Status: \n'  + e.getMessage());
            //rewrite for email utility use
            
            String subject = 'Error Updating Former Members';
            String body = '\n DML Exception at Updating Member to Former Status: \n'  + e.getMessage();
            String source = 'MemberImportProcessUtility ProcessCurrent Members DML Catch';
            Boolean apexRecip = TRUE;
            List<String> addresses = new List<String>();
            
            EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
        }    
    }//end of method processing existing members and updating to former if appropriate
    
    
    //***************** UPLOADED LIST PROCESSING OF MEMBER IMPORT STAGING RECORDS ************
    public static void processMemberImports(List<Member_Import__c> memberImportsFromFlow, String uploadType, Id orgId){
        //process uploaded member list logic here. 
        //Regardless of upload type, we process the Member Import list to add members, with matching logic for existing persons and member records
        //System.debug('processing members uploaded list');
        
        //Adding or updating Existing members
        //initialize the collection for accounts to update if a member's job title has changed.
        Set<Account> accountsToUpdate = new Set<Account>();
        //create a Set of Member records to be upserted
        Set<Member__c> membersToUpsert = new Set<Member__c>();
        //instantiate Set to update Member Import records with processing status
        Set<Member_Import__c> memberImportsToUpdate = new Set<Member_Import__c>();
        //instantiate Set for Person Accounts to be created
        Set<Account> personsToCreate = new Set<Account>();
        
        //get PersonAccount RecordType ID so that we can map it when we need to create person accounts
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        ID personAccountRecTypeId = rtMapByName.get('Person Account').getRecordTypeId();
        
        
        //create a map of the Member Import Records from the input list of records in the flow. This is so we have them in map format; they need to be requeried as the flow does not pass the formula field
        
        Map<Id, Member_Import__c> memberImportMap = new Map<ID,Member_Import__c>([SELECT ID, Account__c, Email__c,First_Name__c, Last_Name__c, Person_Upsert_Status__c, Title__c, Type__c, Member_Match_Import__c, Upsert_Date__c FROM Member_Import__c WHERE Id IN : memberImportsFromFlow]);
        //System.Debug('memberImportMap: '+ memberImportMap);
        
        List<Member_Import__c> memberImports = new List<Member_Import__c>(memberImportMap.values());
        
        //each object we need to compare (Member_Import, Member, Account) has a formula field to concatenate our matching criteria. We create a map for each object where this field is the key with the corresponding ID as a value so that we can check for existing records based on our matching criteria and access the matched record
        //Member_Import__c.Member_Match_Import__c, Member__c.Member_Match_Member__c, Account.Member_Match_Account__c are the fields
        
        //get a map of MemberImport match and id keys and populate the map 
        Map<String,Id> memberImportMatchMap = new Map<String,Id>();
        for(Member_Import__c mi : memberImportMap.values()){
            memberImportMatchMap.put(mi.Member_Match_Import__c,mi.Id);
        }
        //System.Debug('memberImportMatchMap: '+memberImportMatchMap);
        
        //we process the Member Import list to add members, with matching logic for existing persons and member records
        //instantiate lists for person updating and inserting and for memberimport updating
        
        //create a Map of the existing persons 
        Map<Id, Account> existingPersonMap = new Map<ID,Account>([SELECT Id,Member_Match_Account__c, PersonEmail, LastName, PersonTitle 
        FROM Account WHERE Member_Match_Account__c IN :memberImportMatchMap.keySet() AND IsPersonAccount = TRUE]);
        //System.debug('existingPersonMap Size' + existingPersonMap.size());
        //create an Account Match Map for comparison between member import records and person account records
        Map<String,Id> personMatchMap = new Map<String,Id>();
        //add the existing persons to the map
        for(Account a : existingPersonMap.values()){
            personMatchMap.put(a.Member_Match_Account__c,a.id);
        }
        //System.Debug('personMatchMap: '+personMatchMap);
        
        //get a list of all the existing member records for these people and for this organization.
        Map<Id, Member__c> existingMemberMap = new Map<Id, Member__c>([SELECT Id, Member__c, Member_Match_Member__c, Member_Organization__c, Status__c FROM Member__c 
        WHERE Member_Organization__c = :orgId AND Member__c IN :existingPersonMap.keySet()]);
        //System.debug('existingMemberMap: ' + existingMemberMap );
        
        //create a MemberMatch Map to compare the member imports to the existing members
        Map<String,ID> memberMatchMap = new Map<String,Id>();
        //add the existing members to the map
        for(Member__c m: existingMemberMap.values()){
            memberMatchMap.put(m.Member_Match_Member__c,m.id);
        }
        //System.Debug('memberMatchMap: ' + memberMatchMap);
        
        //iterate over the import members list to check for a matching person. If we find a matching person we don't need to create one.
        for(Member_Import__c mip :memberImports ){
            //System.Debug('mip name:'+ mip.Last_Name__c+' '+ mip.Member_Match_Import__c);
            //System.Debug('mip.Member_Match_Import: '+mip.Member_Match_Import__c);
            if(personMatchMap.containsKey(mip.Member_Match_Import__c)){
                // if there is a matching person check if their title needs to be updated
                //  System.Debug('Found key:'+ mip.Member_Match_Import__c);
                //get the person Title
                String personId = personMatchMap.get(mip.Member_Match_Import__c);
                Account existingPerson = existingPersonMap.get(personId);
                String personTitle = existingPerson.PersonTitle;
                if(mip.Title__c != personTitle){
                    Account a = new Account();
                    a.id = personId;
                    a.PersonTitle = mip.Title__c;
                    
                    accountsToUpdate.add(a); 
                }//add any persons needing to be updated to the accounts to be upserted list so we can update their title.
                
                //AND if there is a matching person account, check if there is a matching member record as well.
                if(memberMatchMap.containsKey(mip.Member_Match_Import__c)){
                    //if there is a matching member record check if it needs to be updated (if it is not current, set it to current) 
                    String memberId = memberMatchMap.get(mip.Member_Match_Import__c);
                    Member__c existingMember = existingMemberMap.get(memberId);
                    String memberStatus = existingMember.Status__c;
                    //System.debug('found matching member');
                    if(memberStatus == 'Former'){
                        Member__c mb = new Member__c();
                        mb.id = memberId;
                        mb.Status__c = 'Current';
                        membersToUpsert.add(mb);
                        
                    }
                    //if there is a matching member record we also want to set the member import record as upsert
                    Member_Import__c miu = new Member_Import__c();
                    miu.Id = mip.Id;
                    miu.Type__c = 'Upsert';
                    miu.Upsert_Date__c = Date.today();
                    miu.Person_Upsert_Status__c = 'Succeeded';
                    miu.Account__c = orgId;
                    memberImportsToUpdate.add(miu);
                    //System.debug('Member Imports to Update Loop on matching member ' + miu.Id);
                    //System.debug('Member Imports Size' + memberImportsToUpdate.size());
                }
                else{
                    //System.debug('did not find matching member');
                    //if there is no matching member, map the member values and add to a collection to upsert the member
                    Member__c mb = new Member__c();
                    mb.Member__c = personId;
                    mb.Member_Organization__c = orgId;
                    mb.Role__c = 'Organization Member';
                    mb.Status__c = 'Current';
                    //System.debug('member mb: ' + mb);
                    membersToUpsert.add(mb);
                    //System.debug('membersToUpsert'+membersToUpsert);
                    //if no matching member set member import type as Insert
                    Member_Import__c miu = new Member_Import__c();
                    miu.Id = mip.Id;
                    miu.Type__c = 'Insert';
                    miu.Upsert_Date__c = Date.today();
                    miu.Person_Upsert_Status__c = 'Succeeded';
                    miu.Account__c = orgId;
                    memberImportsToUpdate.add(miu);
                    //System.debug('Member Imports to Update Loop on no matching member' + miu.Id);
                    //System.debug('Member Imports Size' + memberImportsToUpdate.size());
                }
            }
            else{
                //if there is no matching person, map values to create a person account and a member record
                //System.debug('Did Not find matching person');
                Account a = new Account();
                a.FirstName = mip.First_Name__c;
                a.LastName = mip.Last_Name__c;
                a.PersonEmail = mip.Email__c;
                a.PersonTitle = mip.Title__c; 
                a.RecordTypeId = personAccountRecTypeId;
                personsToCreate.add(a);
                //since new person and member, set member import type as Insert
                Member_Import__c miu = new Member_Import__c();
                miu.Id = mip.Id;
                miu.Type__c= 'Insert';
                miu.Upsert_Date__c = Date.today();
                miu.Person_Upsert_Status__c = 'Succeeded';
                miu.Account__c = orgId;
                memberImportsToUpdate.add(miu);
                //System.debug('Member Imports to Update Loop on no matching person' + miu.Id);
                ////System.debug('Member Imports Size' + memberImportsToUpdate.size());
            }
        }
        
        //************* DML for Processing Imported Members *************
        
        
        List<String> batchresult = new List<String>();
        
        List<Account> personsForCreate = new List<Account>(personsToCreate);
        //System.debug('Persons For Create: '+ personsForCreate.size());
        try{
            System.debug('Try Insert personsForCreate');
            insert personsForCreate;
            batchresult.add('\n Person Account records create completed successfully');
        }
        catch(DmlException e){
            //add something here email helper
            System.debug('Catch Insert personsForCreate: ' + e.getMessage());
            for(Member_Import__c mie :memberImports ){
                mie.Person_Upsert_Status__c = 'Failed';
                memberImportsToUpdate.add(mie);
            }
            batchresult.add('\n Error on Create Person Account Records');
            String subject = 'Error on Create Person Account Records';
            String body = ('\n DML Exception at Creating Person Accounts for Org: ' + orgId + ' \n' + e.getMessage());
            String source = 'MemberImportProcessUtility processMemberImports';
            Boolean ApexRecip = TRUE;
            List<String> addresses = new List<String>();
            
            EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
        }
        
        
        
        //iterate over the created person accounts, and map the members to be created for them, and add to existing collection to create member records
        for(Account pa : personsToCreate){
            Member__c mb = new Member__c();
            mb.Member__c = pa.Id;
            mb.Member_Organization__c = orgId;
            mb.Role__c = 'Organization Member';
            mb.Status__c = 'Current';
            membersToUpsert.add(mb);           
        }
        
        //update existing accounts using accountsToUpdate - this will be persons with their title changes
        List<Account> accountsForUpdate = new List<Account>(accountsToUpdate);
        //System.debug('Accounts For Update: '+ accountsForUpdate.size());
        try{
            //System.Debug('Try accountsForUpdate');
            update accountsForUpdate;
            batchresult.add('\n Account records update completed successfully');
            
        }
        catch(DmlException e){
            
            //System.Debug('Catch accountsForUpdate: '  + e.getMessage());
            for(Member_Import__c mie :memberImports ){
                mie.Person_Upsert_Status__c = 'Failed';
                memberImportsToUpdate.add(mie);
            }
            // String errorType = 'Error on Updating Person Account Records';
            //batchresult.add('\n DML Exception at Updating Person Accounts: \n'  + e.getMessage());
            //emailHelper(errorType, orgId, batchresult);
            
            batchresult.add('\n Error on Updating Person Account Records');
            String subject = 'Error on Updating Person Account Records';
            String body = ('\n DML Exception at Updating Person Accounts for Org: ' + orgId + ' \n' + e.getMessage());
            String source = 'MemberImportProcessUtility processMemberImports';
            Boolean ApexRecip = TRUE;
            List<String> addresses = new List<String>();
            
            EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
        }
        
        
        //upsert new and existing member records - membersToUpsert
        //this will include: member records updated to current, and new member records
        List<Member__c> membersForUpsert = new List<Member__c>(membersToUpsert);
        //System.debug('Members for Upsert: '+ membersForUpsert.size());
        try{
            //System.Debug('Try membersForUpsert');
            upsert membersForUpsert;
            batchresult.add('\n Member records upsert completed successfully');
            
            
        }
        catch(DmlException e){
            //System.Debug('Catch membersForUpsert: ' + e.getMessage());
            for(Member_Import__c mie :memberImports ){
                mie.Person_Upsert_Status__c = 'Failed';
                memberImportsToUpdate.add(mie);
            }
            //String errorType = 'Error on Upsert Member Records';
            //batchresult.add('\n DML Exception at Upserting Member Records: \n'  + e.getMessage());
            //emailHelper(errorType, orgId, batchresult);
            
            
            batchresult.add('\n Error on Upsert Member Records');
            String subject = 'Error on Upsert Member Records';
            String body = ('\n DML Exception at Upsert Member Records for Org: ' + orgId + ' \n' + e.getMessage());
            String source = 'MemberImportProcessUtility processMemberImports';
            Boolean ApexRecip = TRUE;
            List<String> addresses = new List<String>();
            
            EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
        }
        
        
        //update the member import records as processed with their type (insert or upsert) and date processed.
        //we also want to update the Person_Upsert_Status__c with Succeeded or Failed - how can we do this? 
        List<Member_Import__c> memberImportsForUpdate = new List<Member_Import__c>(memberImportsToUpdate);
        //System.debug('Member Imports TO Update Set: '+ memberImportsToUpdate.size());
        
        //System.debug('Member Imports For Update: '+ memberImportsForUpdate.size());
        try{
            //System.Debug('Try memberimportsForUpdate');
            update memberImportsForUpdate;
            batchresult.add('\n Member Import records update completed successfully');
            
        }
        catch(DmlException e){
            //System.Debug('Catch memberimportsForUpdate: ' + e.getMessage());
            //String errorType = 'Error on Update Member Import Records';
            //batchresult.add('\n DML Exception at Updating Member Import Records: \n'  + e.getMessage());
            //emailHelper(errorType, orgId, batchresult);
            
            
            
            batchresult.add('\n Error on Update Member Import Records');
            String subject = 'Error on Update Member Import Records';
            String body = ('\n DML Exception at Update Member Import Records for Org: ' + orgId + ' \n' + e.getMessage());
            String source = 'MemberImportProcessUtility processMemberImports';
            Boolean ApexRecip = TRUE;
            List<String> addresses = new List<String>();
            
            EmailUtility.emailHelper(subject, body, source, addresses, apexRecip);
        }
        
        
        //*************** end of processing imported members ************** *        
    } //end of method to process member imports
    
    
    
}