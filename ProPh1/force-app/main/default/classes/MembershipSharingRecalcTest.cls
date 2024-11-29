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
private class MembershipSharingRecalcTest {
    @TestSetup
    static void MembershipData(){
        //test that sharing records are created when a user is created - create users with list of user Ids.
        //create the test data from the test data factory
        //Create organizations - three
        List<Account> myTestOrgs = SharingTestDataFactory.testOrganizations(2);
        
        //create a memberships for each organization - there will be 3
        List<Membership__c> myTestMemberships = SharingTestDataFactory.createMemberships(myTestOrgs);
        System.debug('myTestMemberships: '+ myTestMemberships.size() + ' | ' +myTestMemberships);
        
        //create person accounts users and non users; only the second paramter has primary affiliation persons and will have records shared with them. 3x2 = 6 shares for org memberships expected after recalculating.
        List<Account> myTestPersons = SharingTestDataFactory.testPersons(0, 3);
        List<User> myTestUsers = SharingTestDataFactory.createUser(myTestPersons);   
        System.debug('myTestUsers: '+ myTestUsers.size() + ' | ' + myTestUsers);
        //create one individual membership record // need to make sure this is a portal user.
        List<Account> oneTestPerson = new List<Account>();
        oneTestPerson.add(myTestPersons[0]);
        System.debug('oneTestPerson: ' + oneTestPerson.size() + ' | ' + oneTestPerson);
        List<Membership__c> indMemberships = SharingTestDataFactory.createMemberships(oneTestPerson);
        System.debug('indMemberships: '+indMemberships.size() + ' | ' + indMemberships);
        myTestMemberships.add(indMemberships[0]);
        System.debug('myTestMemberships: '+ myTestMemberships.size() + ' | ' +myTestMemberships);

        //create one membership share record
        Membership__Share share = new Membership__Share();
        share.ParentID = myTestMemberships[0].Id;
        share.RowCause = Schema.Transaction__Share.RowCause.Key_Contact__c;
        share.UserOrGroupId = myTestUsers[0].id;
        share.AccessLevel = 'Read';
        insert share;
        
    }

    @isTest
    static void MembershipSharingTest() {
    
        MembershipSharingRecalc mRecalc = new MembershipSharingRecalc();
        
        Test.startTest();
        //invoke the batch recalc class
        String jobId = Database.executeBatch(mRecalc);
        Test.stopTest();

        // Get the Apex job and verify there are no errors.
        AsyncApexJob aaj = [Select JobType, TotalJobItems, JobItemsProcessed, Status, 
                            CompletedDate, CreatedDate, NumberOfErrors 
                            from AsyncApexJob where Id = :jobId];
        System.assertEquals(0, aaj.NumberOfErrors);

//check the number of shares after recalculating
        List<Membership__Share> mshares = [SELECT Id FROM Membership__Share];
        System.assertEquals(7, mshares.size(), 'There should be seven shares after recalculation');
 
    }
}