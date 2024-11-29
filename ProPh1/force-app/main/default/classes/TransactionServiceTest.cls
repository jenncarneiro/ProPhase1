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
private class TransactionServiceTest {
    
    
    @TestSetup
    static void testTransactionData(){
        //create the test data from the test data factory
        //Create organizations - 
        List<Account> myTestOrgs = SharingTestDataFactory.testOrganizations(2);
        
        //create person accounts users and non users; only the second paramter has primary affiliation persons and will have records shared with them. This will be 1 non share users and 1 share users.
        List<Account> myTestPersonsa = SharingTestDataFactory.testPersons(1, 1);
        
        List<User> myTestUsers = SharingTestDataFactory.createUser(myTestPersonsa);
        //create a memberships for each organization
        List<Membership__c> myTestMembership = SharingTestDataFactory.createMemberships(myTestOrgs);  
        
    }
    @isTest
    static void testTransactionSharing() {
        List<Membership__c> testMemberships = [SELECT Id, Member__c FROM Membership__c];
        
        //create the test to insert the Transaction records
        test.startTest();
        //create a transactions for each membership
        List<Transaction__c> myTestTransactions = SharingTestDataFactory.createTransactions(testMemberships);
        test.stopTest();
        
        //assert that there is the right number of sharing record for transactions
        List<Transaction__Share> tShares = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM Transaction__Share WHERE ParentID = : myTestTransactions];
        System.assertEquals(2, tShares.size(), 'Expected one Transaction Share');
        System.assertEquals('Read', tShares[0].AccessLevel, 'Access Level should be Read');
        System.assertEquals(Schema.Membership__Share.RowCause.Key_Contact__c, tShares[0].RowCause, 'RowCause should be Key_Contact');
        
    }
    
    @isTest
    static void testTransactionChanged(){
        List<Membership__c> testMemberships = [SELECT Id, Member__c FROM Membership__c LIMIT 1];    
        List<Transaction__c> myTestTransactions = SharingTestDataFactory.createTransactions(testMemberships);
        
        //add a new organization and map the membership and transaction updates
        Account newMember = new Account();
        newMember.Name = 'NoUser Organization';
        insert newMember;
        testMemberships[0].member__c = newMember.Id;
        update testMemberships;        
        myTestTransactions[0].Account__c = newMember.Id;
        
        test.startTest();
        update myTestTransactions;
        test.stopTest();
        
        //assert no shares for transactions
        List<Transaction__Share> tshares = [SELECT Id FROM Transaction__Share WHERE ParentId = :myTestTransactions];

        
        System.assertEquals(0, tshares.size(), 'There should be no shares for transactions');

        
        
    }
    
}