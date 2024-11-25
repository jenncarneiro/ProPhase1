//old code for comparing existing to list


//if they are replacing the whole list, we need to compare existing current members against the memberimport records and deactivate (set member record status to former) the ones that are not on the new list. We compare existing members matching criteria against the memberimport records.   
       
//we no longer need to to this. We have to update them all to former first, so then they can be processed in the batch class properly. By chunking them into batches this logic doesn't work.     
  
        if(uploadType == 'Replace List'){            
        Map<Id, Member__c> existingCurrentMemberMap = new Map<Id, Member__c>([SELECT Id, Member__c, Member_Organization__c, Status__c, Member_Match_Member__c FROM Member__c WHERE Member_Organization__c = :orgId AND Status__c = 'Current']);
        List<Member__c> existingCurrentMembers = new List<Member__c>();
        existingCurrentMembers.addall(existingCurrentMemberMap.values());           
        
        //map updating the organization account values if they are replacing their whole list. This is so we can stamp the date they completed a list replacement.
        orgToUpdate.Id = orgId;
        orgToUpdate.Last_Full_Member_Upload_Completed__c = date.today();
        accountsToUpdate.add(orgToupdate);
        System.debug('orgToupdate: '+orgToupdate);
        System.debug('accountsToupdate with org for replace' + accountsToUpdate);
        
        
        //only proceed if there are current members. We don't need to do any comparison if there are no existing current member records            
        If(!existingCurrentMemberMap.isEmpty()){                
        //for each member record we are processing, compare with member import replacement map.
        //if not on the replacement map, they need to be updated as former Status 
        for (Member__c m : existingCurrentMembers){
        if(memberImportMatchMap.containsKey(m.Member_Match_Member__c)){
        //if the existing member is in the import file we do not need to do anything here
        }
        else{
        //what do do if the existing member is not in the import file
        //set Status as former and add them to the list of member records to upsert. Same list that will be used to update existing members later to minimize DML.
        m.Status__c = 'Former';
        membersToUpsert.add(m);                         
        }
        }
        }
        }
