P2 Backup Code


Trigger


trigger Plative_AccountTrigger on Account (before update) {

    if(Trigger.isBefore && Trigger.isUpdate){
        for(Account acct : Trigger.New){
            if(String.isNotBlank(acct.QB_Customer_Id__c) && acct.QB_Customer_Id__c != Trigger.oldMap.get(acct.id).QB_Customer_Id__c){
            	String grpName = acct.Name;
                
                if(acct.Name.contains(' '))
                    grpName = acct.name.split(' ')[0];
                
                if(String.isNotBlank(acct.BillingState))
                    grpName += acct.BillingState;
                
                grpName += acct.QB_Customer_Id__c + '@group.posproject.org';  
                acct.Google_Group_Name__c = grpName;
            }    
        }
        AccountService.updateContactUsers(Trigger.new, (Map<Id, Account>)Trigger.oldMap);
    }
}



Class


public class AccountService {
    
    public static void updateContactUsers(List<Account> accounts, Map<Id, Account> oldMap) {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<String, Id> googleGroupNameToAccountId = new Map<String, Id>();
        String accountIds = '';
        for (Account account : accounts) {
            if (account.Update_Contact_Users__c && !oldMap.get(account.Id).Update_Contact_Users__c) {
                accountMap.put(account.Id, account);
                googleGroupNameToAccountId.put(account.Google_Group_Name__c, account.Id);
                accountIds += ' ' + account.Id;
            }
        }
        
        Map<Id, Google_User__c> googleUserMap = new Map<Id, Google_User__c>([SELECT Id, Email__c, First_Name__c, Last_Name__c, Google_Group__c, Email_Opt_In__c
                                                                             FROM Google_User__c 
                                                                             WHERE Google_Group__c IN :googleGroupNameToAccountId.keySet() AND Contact_Upsert_Status__c = 'Not Started' AND (Upload_Type__c = 'Google User Google Apps' OR Upload_Type__c = 'Google User Non Apps' OR Upload_Type__c = 'Google User Unsure')]);
        if (googleUserMap.isEmpty()) return;
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Email, AccountId, Google_User_22_23__c FROM Contact WHERE AccountId IN :accountMap.keySet()]);
        Map<String, Id> emailToContactId = new Map<String, Id>();
        for (Contact contact : contactMap.values()) {
            if (String.isNotBlank(contact.Email)) {
                emailToContactId.put(contact.Email, contact.Id);
            }
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contactsToCreate = new List<Contact>();
        List<Google_User__c> googleUsersToUpdate = new List<Google_User__c>();
        Map<Id, Id> googleUserIdToContactId = new Map<Id, Id>();
        System.debug('gu size: ' + googleUserMap.values().size());
        for (Google_User__c gu : googleUserMap.values()) {
            Contact contact = new Contact();
            contact.FirstName = gu.First_Name__c;
            contact.LastName = gu.Last_Name__c;
            contact.Analytics_Contact_Status__c = 'Active';
            contact.Google_User_22_23__c = true;
            contact.Last_IB_Import_Date__c = Date.today();
            contact.Weekly_Program_Emails__c = gu.Email_Opt_In__c;
            gu.Contact_Upsert_Status__c = 'Succeeded';
            gu.Upsert_Date__c = Date.today();
            if (emailToContactId.get(gu.Email__c) != null) {
                contact.Id = emailToContactId.get(gu.Email__c);
                gu.Type__c = 'Upsert (Update Contact)';
                contactsToUpdate.add(contact);
                googleUserIdToContactId.put(gu.Id, emailToContactId.get(gu.Email__c));
            }
            else {
                contact.AccountId = googleGroupNameToAccountId.get(gu.Google_Group__c);
                contact.Email = gu.Email__c;
                gu.Type__c = 'Insert (New Contact)';
                contactsToCreate.add(contact);
            }
            googleUsersToUpdate.add(gu);
        }
        
        for (Contact contact : contactMap.values()) {
            if ((!googleUserIdToContactId.values().contains(contact.Id)) && (!accountMap.get(contact.AccountId).Do_Not_Mark_Contacts_Inactive__c) && !contact.Google_User_22_23__c) {
                contact.Analytics_Contact_Status__c = 'Inactive';
                contactsToUpdate.add(contact);
            }
        }
        
        for (Account account : accountMap.values()) {
            // account.Google_Group_Created__c = true;
            account.Update_Contact_Users__c = false;
            account.Do_Not_Mark_Contacts_Inactive__c = true;
        }
        
        if (!contactsToCreate.isEmpty()) {
            try {
                insert contactsToCreate;
            }
            catch (DmlException e) {
                emailHelper('create Contacts', accountIds);
            }
        }
        
        System.debug('contacts to update size: ' + contactsToUpdate.size());
        if (!contactsToUpdate.isEmpty()) {
            try {
                update contactsToUpdate;
            }
            catch (DmlException e) {
                emailHelper('update Contacts', accountIds);
            }
        }
        
        if (!googleUsersToUpdate.isEmpty()) {
            try {
                update googleUsersToUpdate;
            }
            catch (DmlException e) {
                emailHelper('create Google Users', accountIds);
            }
        }
    }
    
    public static void emailHelper(String messageType, String accountIds) {
        List<ApexEmailNotification> emailRecipients = [SELECT Email FROM ApexEmailNotification];
        if (emailRecipients.isEmpty()) return;
        Set<String> emailAddresses = new Set<String>();
        for (ApexEmailNotification emailRecipient : emailRecipients) {
            emailAddresses.add(emailRecipient.Email);
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Error on ' + messageType);
        String body = 'An error has occurred on Account with Id(s) ' + accountIds + ' when trying to ' + messageType + '.';
        email.setPlainTextBody(body);
        email.setToAddresses(new List<String>(emailAddresses));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
    }

}