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
private class SharingUtilityTest {
    @TestSetup
    static void makeTestData(){
        SharingUtility.forceException = 'test data';
        SharingUtility.exceptionMessage = 'start test data';
        //create the test data from the test data factory
        //Create organizations - 
        List<Account> myTestOrgs = SharingTestDataFactory.testOrganizations(2);
        //create a memberships for each organization - 
        List<Membership__c> myTestMemberships = SharingTestDataFactory.createMemberships(myTestOrgs);        
        //create a transactions for each membership - 
        List<Transaction__c> myTestTransactions = SharingTestDataFactory.createTransactions(myTestMemberships);        
        
        //create person accounts users and non users; only the second paramter has primary affiliation persons and will have records shared with them. 
        List<Account> myTestPersons = SharingTestDataFactory.testPersons(0, 2);   
        //create external users for my person accounts 
        
        System.debug('Test Data: ');
        System.debug('Memberships: ' + myTestMemberships);
        System.debug('Transaction: ' + myTestTransactions);
        System.debug('Persons: ' + myTestPersons);
        
    }
    
    @isTest
    static void testMembershipErrorTrivial() {
        //get the data created in test setup
        List<Membership__c> memberships = [SELECT Id, Member__c FROM Membership__c];
        List<Account> testAccounts = [SELECT Id, IsPersonAccount FROM Account WHERE IsPersonAccount = TRUE];
               
        //create the users to test share creation with
        List<User> myTestUsers = SharingTestDataFactory.createUser(testAccounts);
        System.debug('myTestUsers users in Test: ' + myTestUsers);
        
        //start the test
        Test.startTest();
        //set the forceException variable to 'force trivial' so that we can force the exception handling of inserting an unnecessary share record
        SharingUtility.forceException = 'force trivial';   
        //get my Users with all the needed variables
        List<User> testUsers = [SELECT Id,Name, Account.Id, Contact.AccountId, Contact.Primary_Affiliation__c,Contact.Primary_Affiliation__r.Id, UserType FROM User WHERE Id In: myTestUsers];
        
        //pass memberships and users to the method being tested for exceptions  
        SharingUtility.processCreateMembershipShares(memberships, testUsers);
        Test.stopTest();
        
        // Assert the exception message caught was the trivial share message expected
        System.assert(SharingUtility.exceptionMessage.contains('trivial share level'),'Unexpected exception message: ' + SharingUtility.exceptionMessage);  
        //reset
        SharingUtility.forceException = 'none';
        SharingUtility.exceptionMessage = 'none';  
    }
    
    
    @isTest
    static void testMembershipDMLError() {
        //get the data created in test setup
        List<Membership__c> memberships = [SELECT Id, Member__c FROM Membership__c];
        List<Account> testAccounts = [SELECT Id, IsPersonAccount FROM Account WHERE IsPersonAccount = TRUE];
        //create the users to test share creation with
        List<User> myTestUsers = SharingTestDataFactory.createUser(testAccounts);
        //System.debug('myTestUsers users in Test: ' + myTestUsers);
        
        //start the test
        Test.startTest();
        //set the forceException variable to 'force dml in insert' so that we can force the exception handling of inserting a share record with a missing required field
        SharingUtility.forceException = 'force dml in insert';   
        //get my Users with all the needed variables
        List<User> testUsers = [SELECT Id,Name, Account.Id, Contact.AccountId, Contact.Primary_Affiliation__c,Contact.Primary_Affiliation__r.Id, UserType FROM User WHERE Id In: myTestUsers];
        //pass memberships and users to the method being tested for exceptions
        SharingUtility.processCreateMembershipShares(memberships, testUsers);
        Test.stopTest();
        
        //assert that the exception message caught in the method was the expected DML error.
        System.assert(SharingUtility.exceptionMessage.contains('Required fields are missing'),'Unexpected exception message: ' + SharingUtility.exceptionMessage);
        SharingUtility.forceException = 'none';
        SharingUtility.exceptionMessage = 'none';  
        
    }


    @isTest
    static void testTransactionErrorTrivial() {
        //get the data created in test setup
        List<Transaction__c> transactions = [SELECT Id, Account__c FROM Transaction__c];
        List<Account> testAccounts = [SELECT Id, IsPersonAccount FROM Account WHERE IsPersonAccount = TRUE];
        
        //create the users to test share creation with
        List<User> myTestUsers = SharingTestDataFactory.createUser(testAccounts);
        //System.debug('myTestUsers users in Test: ' + myTestUsers);
        
        //start the test
        Test.startTest();
        //set the forceException variable to 'force trivial' so that we can force the exception handling of inserting an unnecessary share record
        SharingUtility.forceException = 'force trivial';   
        //get my Users with all the needed variables
        List<User> testUsers = [SELECT Id,Name, Account.Id, Contact.AccountId, Contact.Primary_Affiliation__c,Contact.Primary_Affiliation__r.Id, UserType FROM User WHERE Id In: myTestUsers];
        
        //pass memberships and users to the method being tested for exceptions  
        SharingUtility.processCreateTransactionShares(transactions, testUsers);
        Test.stopTest();
        
        // Assert the exception message caught was the trivial share message expected
        System.assert(SharingUtility.exceptionMessage.contains('trivial share level'),'Unexpected exception message: ' + SharingUtility.exceptionMessage);   
        SharingUtility.forceException = 'none';
        SharingUtility.exceptionMessage = 'none';   
    }

    @isTest
    static void testTransactionDMLError() {
        //get the data created in test setup
        List<Transaction__c> transactions = [SELECT Id, Account__c FROM Transaction__c];
        List<Account> testAccounts = [SELECT Id, IsPersonAccount FROM Account WHERE IsPersonAccount = TRUE];
        
        //create the users to test share creation with
        List<User> myTestUsers = SharingTestDataFactory.createUser(testAccounts);
        //System.debug('myTestUsers users in Test: ' + myTestUsers);
        
        //start the test
        Test.startTest();
        //set the forceException variable to 'force dml in insert' so that we can force the exception handling of inserting a share record with a missing required field
        SharingUtility.forceException = 'force dml in insert';   
        //get my Users with all the needed variables
        List<User> testUsers = [SELECT Id,Name, Account.Id, Contact.AccountId, Contact.Primary_Affiliation__c,Contact.Primary_Affiliation__r.Id, UserType FROM User WHERE Id In: myTestUsers];
        
        //pass transactions and users to the method being tested for exceptions  
        SharingUtility.processCreateTransactionShares(transactions, testUsers);
        Test.stopTest();
        
        // Assert the exception message caught was the trivial share message expected
        System.assert(SharingUtility.exceptionMessage.contains('Required fields are missing'),'Unexpected exception message: ' + SharingUtility.exceptionMessage);  
        SharingUtility.forceException = 'none';
        SharingUtility.exceptionMessage = 'none';    
    }
        
}