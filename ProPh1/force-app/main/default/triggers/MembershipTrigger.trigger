trigger MembershipTrigger on Membership__c (after insert, after update) {
    
    
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            //create new shares for the new membership records
            MembershipService.createMembershipShares(trigger.new);
        }
    }
    
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            //We only want to update sharing records if the Member Account has changed on the membership. 
            
            List<Membership__c> processMemberships = new List<Membership__c>();
            
            for(Membership__c m : trigger.new){
                Membership__c oldM = Trigger.oldMap.get(m.Id);
                if(m.Member__c != oldM.Member__c){
                    processMemberships.add(m); 
                }
            }
            
            //we want to delete the membership share records that are shared because of the user's affiliation with the Account which has changed.
            delete [SELECT Id FROM Membership__Share WHERE ParentID In: processMemberships AND RowCause = :Schema.Membership__Share.rowCause.Key_Contact__c];
            
            //then we need to create the new share records for the users that are affiliated with the new Account
            MembershipService.createMembershipShares(processMemberships);        
        }
    }
}