
@isTest
private class MemberImportTest {
    
    
    @isTest
    static void testReplaceFileImport() {
        // testing scenario is there are all the existing members in the file, so none to mark as former
        String uploadType = 'Replace List';
        //create an organization
        String orgId = memberImportDataFactory.CreateOrganization();
        
        
        Integer existingNonMemberPersonsToCreate = 10;
        Integer existingCurrentMemberPersonsToCreate = 10;
        Integer existingFormerMemberPersonsToCreate = 10;
        Integer newMemberPersonsToCreate = 10;
        
        /*  Assertions if setup numbers wrong
        if(!testExistingMembers.size() = existingMembersToCreate){
        Assert.fail('test condition error; cannot create more existing members than persons');
        }
        if(formerMembersToCreate>existingMembersToCreate){
        Assert.fail('test condition error; cannot create more former members than total members');
        }
        */
        //create existing accounts that are nonMembers, Current Members, and Former Members
        List<Account> testExistingPersons = memberImportDataFactory.CreateExistingPersons(existingNonMemberPersonsToCreate, 'nonMember');
        List<Account> testCurrentMemberPersons = memberImportDataFactory.CreateExistingPersons(existingCurrentMemberPersonsToCreate, 'Current');
        List<Account> testFormerMemberPersons = memberImportDataFactory.CreateExistingPersons(existingFormerMemberPersonsToCreate,'Former');
        
        //create Member records for the different types (former, current)
        List<Member__c> currentMembers = memberImportDataFactory.CreateExistingMembers(testCurrentMemberPersons,existingCurrentMemberPersonsToCreate,'Current',orgId);
        List<Member__c> formerMembers = memberImportDataFactory.CreateExistingMembers(testFormerMemberPersons,existingCurrentMemberPersonsToCreate,'Former',orgId);
        
        //combine all existing persons together
        List<Account> allExistingPersons = new List<Account>();
        allExistingPersons.addAll(testExistingPersons);
        allExistingPersons.addAll(testCurrentMemberPersons);
        allExistingPersons.addAll(testFormerMemberPersons);
        
        //create staging records for x new persons (not existing), and for the existing non, current, and former members.
        
        List<Member_Import__c> testStagingRecords = memberImportDataFactory.CreateMemberImports(allExistingPersons,newMemberPersonsToCreate);
        
        //run the test to pass the variables to the invocable class
        Test.startTest();
        MemberImportInvocable.inputVariables invar= new MemberImportInvocable.inputVariables();
        List<MemberImportInvocable.inputVariables> invars = new List<MemberImportInvocable.inputVariables>();
        invar.memberImports =  testStagingRecords;
        invar.uploadType = uploadType;
        invar.orgId = orgId;
        invars.add(invar);
        
        MemberImportInvocable.processMemberImportBatch(invars);
        Test.stopTest();
        
        List<Member__c> updatedCurrentMembers = [SELECT ID, Status__c, Member_Organization__c FROM Member__c WHERE Member_Organization__c = :orgId AND Status__c = 'Current'];
        List<Member__c> updatedFormerMembers = [SELECT ID, Status__c, Member_Organization__c FROM Member__c WHERE Member_Organization__c = :orgId AND Status__c = 'Former'];
        
        System.assertEquals(40, updatedCurrentMembers.size(), 'Expected 40 Current Members, actual was ' + updatedCurrentMembers.size());
        System.assertEquals(0, updatedFormerMembers.size(), 'Expected 0 Current Members, actual was ' + updatedFormerMembers.size());
        
        
    }
    
    
    
    
    
    @isTest
    static void testAddFileImport() {
        // testing scenario is there are all the existing members in the file, so none to mark as former
        String uploadType = 'Add Members';
        //create an organization
        String orgId = memberImportDataFactory.CreateOrganization();
        
        
        Integer existingNonMemberPersonsToCreate = 100;
        Integer existingCurrentMemberPersonsToCreate = 10;
        Integer existingFormerMemberPersonsToCreate = 10;
        Integer newMemberPersonsToCreate = 10;
        Integer totalCurrentMemberCount = existingNonMemberPersonsToCreate + existingCurrentMemberPersonsToCreate + existingFormerMemberPersonsToCreate + newMemberPersonsToCreate;
        
        /*  Assertions if setup numbers wrong
        if(!testExistingMembers.size() = existingMembersToCreate){
        Assert.fail('test condition error; cannot create more existing members than persons');
        }
        if(formerMembersToCreate>existingMembersToCreate){
        Assert.fail('test condition error; cannot create more former members than total members');
        }
        */
        //create existing accounts that are nonMembers, Current Members, and Former Members
        List<Account> testExistingPersons = memberImportDataFactory.CreateExistingPersons(existingNonMemberPersonsToCreate, 'nonMember');
        List<Account> testCurrentMemberPersons = memberImportDataFactory.CreateExistingPersons(existingCurrentMemberPersonsToCreate, 'Current');
        List<Account> testFormerMemberPersons = memberImportDataFactory.CreateExistingPersons(existingFormerMemberPersonsToCreate,'Former');
        
        //create Member records for the different types (former, current)
        List<Member__c> currentMembers = memberImportDataFactory.CreateExistingMembers(testCurrentMemberPersons,existingCurrentMemberPersonsToCreate,'Current',orgId);
        List<Member__c> formerMembers = memberImportDataFactory.CreateExistingMembers(testFormerMemberPersons,existingCurrentMemberPersonsToCreate,'Former',orgId);
        
        //combine all existing persons together
        List<Account> allExistingPersons = new List<Account>();
        allExistingPersons.addAll(testExistingPersons);
        allExistingPersons.addAll(testCurrentMemberPersons);
        allExistingPersons.addAll(testFormerMemberPersons);
        
        //create staging records for x new persons (not existing), and for the existing non, current, and former members.
        
        List<Member_Import__c> testStagingRecords = memberImportDataFactory.CreateMemberImports(allExistingPersons,newMemberPersonsToCreate);
        
        //run the test to pass the variables to the invocable class
        Test.startTest();
        MemberImportInvocable.inputVariables invar= new MemberImportInvocable.inputVariables();
        List<MemberImportInvocable.inputVariables> invars = new List<MemberImportInvocable.inputVariables>();
        invar.memberImports =  testStagingRecords;
        invar.uploadType = uploadType;
        invar.orgId = orgId;
        invars.add(invar);
        
        MemberImportInvocable.processMemberImportBatch(invars);
        Test.stopTest();
        
        List<Member__c> updatedCurrentMembers = [SELECT ID, Status__c, Member_Organization__c FROM Member__c WHERE Member_Organization__c = :orgId AND Status__c = 'Current'];
        List<Member__c> updatedFormerMembers = [SELECT ID, Status__c, Member_Organization__c FROM Member__c WHERE Member_Organization__c = :orgId AND Status__c = 'Former'];
        
        System.assertEquals(totalCurrentMemberCount, updatedCurrentMembers.size(), 'Expected 40 Current Members, actual was ' + updatedCurrentMembers.size());
        System.assertEquals(0, updatedFormerMembers.size(), 'Expected 0 Current Members, actual was ' + updatedFormerMembers.size());
        
    }

    @isTest

    static void testReplaceWithLessimport(){

                // testing scenario is there are all the existing members in the file, so none to mark as former
                String uploadType = 'Replace List';
                //create an organization
                String orgId = memberImportDataFactory.CreateOrganization();
                
                
                Integer existingNonMemberPersonsToCreate = 10;
                Integer existingCurrentMemberPersonsToCreate = 150;
                Integer existingFormerMemberPersonsToCreate = 10;
                Integer newMemberPersonsToCreate = 10;
                Integer expectedCurrentMembers = existingNonMemberPersonsToCreate + existingFormerMemberPersonsToCreate + newMemberPersonsToCreate;
                Integer expectedFormerMembers = existingCurrentMemberPersonsToCreate;
                
                /*  Assertions if setup numbers wrong
                if(!testExistingMembers.size() = existingMembersToCreate){
                Assert.fail('test condition error; cannot create more existing members than persons');
                }
                if(formerMembersToCreate>existingMembersToCreate){
                Assert.fail('test condition error; cannot create more former members than total members');
                }
                */
                //create existing accounts that are nonMembers, Current Members, and Former Members
                List<Account> testExistingPersons = memberImportDataFactory.CreateExistingPersons(existingNonMemberPersonsToCreate, 'nonMember');
                List<Account> testCurrentMemberPersons = memberImportDataFactory.CreateExistingPersons(existingCurrentMemberPersonsToCreate, 'Current');
                List<Account> testFormerMemberPersons = memberImportDataFactory.CreateExistingPersons(existingFormerMemberPersonsToCreate,'Former');
                
                //create Member records for the different types (former, current)
                List<Member__c> currentMembers = memberImportDataFactory.CreateExistingMembers(testCurrentMemberPersons,existingCurrentMemberPersonsToCreate,'Current',orgId);
                List<Member__c> formerMembers = memberImportDataFactory.CreateExistingMembers(testFormerMemberPersons,existingCurrentMemberPersonsToCreate,'Former',orgId);
                
                //combine all existing persons together
                List<Account> allExistingPersons = new List<Account>();
                allExistingPersons.addAll(testExistingPersons);
                //do not add current members, so they will be marked as former.
                allExistingPersons.addAll(testFormerMemberPersons);
                
                //create staging records for x new persons (not existing), and for the existing non, current, and former members.
                
                List<Member_Import__c> testStagingRecords = memberImportDataFactory.CreateMemberImports(allExistingPersons,newMemberPersonsToCreate);
                
                //run the test to pass the variables to the invocable class
                Test.startTest();
                MemberImportInvocable.inputVariables invar= new MemberImportInvocable.inputVariables();
                List<MemberImportInvocable.inputVariables> invars = new List<MemberImportInvocable.inputVariables>();
                invar.memberImports =  testStagingRecords;
                invar.uploadType = uploadType;
                invar.orgId = orgId;
                invars.add(invar);
                
                MemberImportInvocable.processMemberImportBatch(invars);
                Test.stopTest();
                
                List<Member__c> updatedCurrentMembers = [SELECT ID, Status__c, Member_Organization__c FROM Member__c WHERE Member_Organization__c = :orgId AND Status__c = 'Current'];
                List<Member__c> updatedFormerMembers = [SELECT ID, Status__c, Member_Organization__c FROM Member__c WHERE Member_Organization__c = :orgId AND Status__c = 'Former'];
                
                System.assertEquals(expectedCurrentMembers, updatedCurrentMembers.size(), 'Expected 40 Current Members, actual was ' + updatedCurrentMembers.size());
                System.assertEquals(expectedFormerMembers, updatedFormerMembers.size(), 'Expected 0 Current Members, actual was ' + updatedFormerMembers.size());
                
    }
}