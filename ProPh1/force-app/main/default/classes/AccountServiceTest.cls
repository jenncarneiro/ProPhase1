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
private without sharing class AccountServiceTest {
    
    @isTest
    private static void testAccountSharing(){
        //testing sharing record updates when the primary affiliation changes for a person account that is a portal user
        
        //create the test data from the test data factory
        //Create organizations - two separarte ones so they are in separate lists
        List<Account> myTestOrgsa = SharingTestDataFactory.testOrganizations(1);
        List<Account> myTestOrgsb = SharingTestDataFactory.testOrganizations(1);
        String OrgAId;
        String OrgBId;
        //capture the ID of Org a and Org b to use in Queries
        System.debug('myTestOrgsa: ' + myTestOrgsa);
        System.debug('myTestOrgsb: ' + myTestOrgsb);
        System.debug('OrgAId: ' + OrgAId + ' | OrgBIad: ' + OrgBId);
        
        for(Account a : myTestOrgsa){
            OrgAId = a.Id;
        }
        for(Account b : myTestOrgsb){
            OrgBId = b.Id;
        }
        List<Account> myTestOrgs = new List<Account>();
        myTestOrgs.addAll(myTestOrgsa);
        myTestOrgs.addAll(myTestOrgsb);
        System.debug('MyTestOrgs: ' + MyTestOrgs);
        
        //create a memberships for each organization
        List<Membership__c> myTestMembership = SharingTestDataFactory.createMemberships(myTestOrgs);
        //get separate membership lists to test counts of shares created specifically
        List<Membership__c> orgAMemberships = [SELECT Id FROM Membership__c WHERE Member__c = :OrgAId];
        List<Membership__c> orgBMemberships = [SELECT Id FROM Membership__c WHERE Member__c = :OrgBId];
        
        //create a transactions for each membership, some to be shared
        List<Transaction__c> myTestTransaction = SharingTestDataFactory.createTransactions(myTestMembership);
        
        //create person accounts users and non users; only the second paramter has primary affiliation persons and will have records shared with them.
        List<Account> myTestPersonsa = SharingTestDataFactory.testPersons(1, 1);
        
        List<User> myTestUsers = SharingTestDataFactory.createUser(myTestPersonsa);
        
        //map the update to change primary affiliation so that people are only affiliated with Org B. 
        
        for(Account p : myTestPersonsa){
            if(p.Primary_Affiliation__pc != null){
                p.Primary_Affiliation__pc = OrgBId;
            }
        }
        
        //create the test, which is based on changing the primary affiliation 
        Test.startTest();
        
        update myTestPersonsA;
        Test.stopTest();
        
        //verify the test results
        //check membership shares specific
        List<Membership__Share> mShares = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM Membership__Share WHERE ParentID = : myTestMembership];
        List<Membership__Share> orgAMSharesAfter = [SELECT Id FROM Membership__Share WHERE ParentID = : orgAMemberships];
        List<Membership__Share> orgBMSharesAfter = [SELECT Id FROM Membership__Share WHERE ParentID = : orgBMemberships];
        
        //verify the after insert count for membership per each org
        System.assertEquals(0, orgAMsharesAfter.size(), 'There should be no shares for Org A after update');
        System.assertEquals(2, orgBMsharesAfter.size(), 'There should be two share for Org B after update');
        
        //verify overall counts
        System.assertEquals(2, mShares.size(), 'Expected 1 Membership Share');
        System.assertEquals('Read', mShares[0].AccessLevel, 'Access Level should be Read');
        System.assertEquals(Schema.Membership__Share.RowCause.Key_Contact__c, mShares[0].RowCause, 'RowCause should be Key_Contact'); 
        
        //check transaction shares
        List<Transaction__Share> tShares = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM Transaction__Share WHERE ParentID = : myTestTransaction];
        
        System.assertEquals(2, tShares.size(), 'Expected 1 Transaction Share');
        System.assertEquals('Read', tShares[0].AccessLevel, 'Access Level should be Read');
        System.assertEquals(Schema.Transaction__Share.RowCause.Key_Contact__c, tShares[0].RowCause, 'RowCause should be Key_Contact');
        
        //there should be two share record for three users
        System.assertEquals(3, myTestUsers.size(), 'There should be three portal users');
    }
    
    
}