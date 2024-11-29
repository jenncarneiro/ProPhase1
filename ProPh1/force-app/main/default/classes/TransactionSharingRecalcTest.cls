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
private class TransactionSharingRecalcTest {
    
    @TestSetup
    static void TransactionData(){
        //test that sharing records are created when a user is created - create users with list of user Ids.
        //create the test data from the test data factory
        //Create organizations - three
        List<Account> myTestOrgs = SharingTestDataFactory.testOrganizations(3);
        
        //create a memberships for each organization - there will be 3
        List<Membership__c> myTestMemberships = SharingTestDataFactory.createMemberships(myTestOrgs);
        
        //create a transactions for each membership - there will be 3
        List<Transaction__c> myTestTransactions = SharingTestDataFactory.createTransactions(myTestMemberships);
        
        //create person accounts users and non users; only the second paramter has primary affiliation persons and will have records shared with them. 3x3 = 9 shares expected after recalculating.
        List<Account> myTestPersons = SharingTestDataFactory.testPersons(3, 3);
        List<User> myTestUsers = SharingTestDataFactory.createUser(myTestPersons);   
        
        
        //create one transaction share record
        Transaction__Share share = new Transaction__Share();
        share.ParentID = myTestTransactions[0].Id;
        share.RowCause = Schema.Transaction__Share.RowCause.Key_Contact__c;
        share.UserOrGroupId = myTestUsers[0].id;
        share.AccessLevel = 'Read';
        insert share;
        
    }
    
    @isTest
    static void TransactionSharingTest() {
    
        TransactionSharingRecalc tRecalc = new TransactionSharingRecalc();
        
        Test.startTest();
        //invoke the batch recalc class
        String jobId = Database.executeBatch(tRecalc);
        Test.stopTest();

        // Get the Apex job and verify there are no errors.
        AsyncApexJob aaj = [Select JobType, TotalJobItems, JobItemsProcessed, Status, 
                            CompletedDate, CreatedDate, NumberOfErrors 
                            from AsyncApexJob where Id = :jobId];
        System.assertEquals(0, aaj.NumberOfErrors);

//check the number of shares after recalculating
        List<Transaction__Share> tshares = [SELECT Id FROM Transaction__Share];
        System.assertEquals(9, tshares.size(), 'There should be nine shares after recalculation');
 
    }
}