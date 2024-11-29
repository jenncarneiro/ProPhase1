/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an org are executed whenever Apex code is deployed
* to a production org to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production org. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the org size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class MembershipServiceTest {

    @TestSetup
    static void testMembershipData(){
           //create the test data from the test data factory
        //Create organizations - 
        List<Account> myTestOrgs = SharingTestDataFactory.testOrganizations(5);
        
        //create person accounts users and non users; only the second paramter has primary affiliation persons and will have records shared with them. This will be 5 non share users and 25 share users.
        List<Account> myTestPersonsa = SharingTestDataFactory.testPersons(5, 5);
        
        List<User> myTestUsers = SharingTestDataFactory.createUser(myTestPersonsa);     


    }
    
    @isTest
    static void testMembershipSharing() {
        
        //query the test setup organization accounts
        List<Account> myTestOrgs = [SELECT Id, IsPersonAccount FROM Account WHERE IsPersonAccount = FALSE];

        //start the test
        Test.startTest();
        //create a memberships for each organization (5) which should create 25 share records for 30 users
        List<Membership__c> myTestMemberships = SharingTestDataFactory.createMemberships(myTestOrgs);
        Test.stopTest();
        
        //assert test results
        List<Membership__Share> mShares = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM Membership__Share WHERE ParentID = : myTestMemberships];
        System.assertEquals(25, mShares.size(), 'Expected 25 Membership Shares');
        System.assertEquals('Read', mShares[0].AccessLevel, 'Access Level should be Read');
        System.assertEquals(Schema.Membership__Share.RowCause.Key_Contact__c, mShares[0].RowCause, 'RowCause should be Key_Contact');

    }

    @isTest
    static void testMembershipChange(){
        //create a membership for one organization
        List<Account> myTestOrgs = [SELECT Id, IsPersonAccount FROM Account WHERE IsPersonAccount = FALSE];
        Account firstMember = myTestOrgs.get(0);       
        //create an organization with no users and update a membership to be this organization. 
        Account newMember = new Account();
        newMember.Name = 'NoUser Organization';
        insert newMember;
        myTestOrgs.add(newMember);

        Test.startTest();
        //create memberships for the 6 orgs
        List<Membership__c> myTestMemberships = SharingTestDataFactory.createMemberships(myTestOrgs);

        //count the member shares before for the prior and new member
        Membership__c firstMembership = [SELECT Id, Member__c from Membership__c WHERE Member__c = :firstMember.Id LIMIT 1];
        Membership__c newsMembership = [SELECT Id, Member__c from Membership__c WHERE Member__c = :newMember.Id LIMIT 1];
        List<Membership__Share> firstSharesBefore = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM Membership__Share WHERE ParentID = : firstMembership.Id];
        List<Membership__Share> newSharesBefore = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM Membership__Share WHERE ParentID = : newsMembership.Id];
            
        //change the first memberships member to the new member 
        firstMembership.Member__c = newMember.Id;
        update firstMembership;

        Test.stopTest();


        //count the member shares after for the prior and new member

        List<Membership__Share> firstSharesAfter = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM Membership__Share WHERE ParentID = : firstMembership.Id];
        List<Membership__Share> mnewsSharesAfter = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM Membership__Share WHERE ParentID = : newsMembership.Id];
        //assert the before and after counts
        System.assertEquals(5, firstSharesBefore.size(), 'First account should have had 5 shares before update'); // prior before
        System.assertEquals(0, firstSharesAfter.size(), 'First account should have had 0 shares after update'); // prior after
        System.assertEquals(0, newSharesBefore.size(), 'New account should have had 0 shares before update'); // new before
        System.assertEquals(0, mnewsSharesAfter.size(), 'New account should have had 0 shares after update'); // new after



    }

   
}