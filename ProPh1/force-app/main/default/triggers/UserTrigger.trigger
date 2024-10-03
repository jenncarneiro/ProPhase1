trigger UserTrigger on User (after insert) {
    
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            //create Share Records for Portal Users
            UserService.createPortalUserShares(trigger.new);
        }
    }
}