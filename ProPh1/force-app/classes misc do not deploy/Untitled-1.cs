
String OrgId = '001D700001SyusMIAR';

List<Member__c> membersToMakeCurrent = new List<Member__c>([SELECT Id, Status__c,Member_Organization__c 
                                                            FROM Member__c 
                                                            WHERE Member_Organization__c = :orgId AND Status__c = 'Former' LIMIT 10000]);
for (Member__c m: membersToMakeCurrent){
    m.Status__c = 'Current';
    
}
update membersToMakeCurrent;





IF(
{!MemberLimit} != null,
     IF(
     AND({!UploadType} = 'Replace List',{!ParsedCount} > {!MemberLimit}), 
     TRUE,
        IF(
        AND({!UploadType}  = 'Add Member',({!ParsedCount} + {!OrgCurrentMemberCount}) > {!MemberLimit}),
        TRUE,
        FALSE
        )
     ),FALSE
)
