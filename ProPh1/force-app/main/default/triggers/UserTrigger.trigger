trigger UserTrigger on User (after insert) {
    
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            //create Share Records for Portal Users
            //create a Set of User Record IDs to pass to a future method.
            //Future method needed to avoid mixed DML
            Set<Id> newUsersIds = trigger.newMap.keySet();

            UserService.createPortalUserShares(newUsersIds);
        }
    }
        
}