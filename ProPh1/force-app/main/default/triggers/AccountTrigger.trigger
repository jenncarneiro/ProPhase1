trigger AccountTrigger on Account (after update) {
    // we only need after update for user shares as a Person Account / Contact must exist before a portal user.



if(trigger.isUpdate){
    if(trigger.isAfter){
        //update Share Records for Portal Users
        //System.debug('Account Trigger was triggered');
        AccountService.updatePersonAccountContactUserShares(trigger.new, Trigger.oldMap);
    }
}




}