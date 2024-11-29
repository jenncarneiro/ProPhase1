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
private class UserServiceTest {
    
    @isTest
    static void testSharing() {
        
        //test that sharing records are created when a user is created - create users with list of user Ids.
        //create the test data from the test data factory
        //Create organizations - three
        List<Account> myTestOrgs = SharingTestDataFactory.testOrganizations(3);
        
        //create a memberships for each organization - there will be 3
        List<Membership__c> myTestMemberships = SharingTestDataFactory.createMemberships(myTestOrgs);
        
        //create a transactions for each membership - there will be 3
        List<Transaction__c> myTestTransactions = SharingTestDataFactory.createTransactions(myTestMemberships);
        
        //create person accounts users and non users; only the second paramter has primary affiliation persons and will have records shared with them.
        List<Account> myTestPersons = SharingTestDataFactory.testPersons(3, 3);

        

        
        
        //create the test, which is based on inserting the users
        Test.startTest();
        List<User> myTestUsers = SharingTestDataFactory.createUser(myTestPersons);
        Test.stopTest();
        
        //verify test results
        //check membership shares - 3 orgs with three users each = 9 / 12 users
        List<Membership__Share> mShares = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM Membership__Share WHERE ParentID = : myTestMemberships];
        Integer totalUsers = myTestUsers.size();// can't query all users as tests see users in org.
        System.debug('totalUsers: ' + totalUsers);
        System.assertEquals(9, mShares.size(), 'Expected 9 Membership Shares');
        System.assertEquals('Read', mShares[0].AccessLevel, 'Access Level should be Read');
        System.assertEquals(Schema.Membership__Share.RowCause.Key_Contact__c, mShares[0].RowCause, 'RowCause should be Key_Contact'); 
        
        //check transaction shares
        List<Transaction__Share> tShares = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM Transaction__Share WHERE ParentID = : myTestTransactions];
        
        System.assertEquals(9, tShares.size(), 'Expected 9 Transaction Shares');
        System.assertEquals('Read', tShares[0].AccessLevel, 'Access Level should be Read');
        System.assertEquals(Schema.Transaction__Share.RowCause.Key_Contact__c, tShares[0].RowCause, 'RowCause should be Key_Contact');
        
        //there should be nine share record for twelve users
        System.assertEquals(12, myTestUsers.size(), 'There should be twelve portal users');
        
        
    }
}