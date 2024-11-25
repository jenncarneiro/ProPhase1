public without sharing class EmailUtility {

    
    public static void emailHelper(String subject, String body, String source, List<String> addresses, Boolean apexRecip){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();       
        
        //if this is for apex recipients email type
        if(apexRecip == TRUE){
            
            ApexEmailRecipientUtility em = ApexEmailRecipientUtility.getInstance();
            String [] toAddresses = em.emailList;
            mail.setToAddresses(toAddresses); }
            
            else if(addresses == null){ //if not for apex receipients but the email address list is null also send to apex recipients with note
                body = 'Sent to Apex Email recipients because email address list was null \n ' + source + ' \n \n' + body;
                
                ApexEmailRecipientUtility em = ApexEmailRecipientUtility.getInstance();
                String [] toAddresses = em.emailList;
                mail.setToAddresses(toAddresses); 
            }

            else{ //otherwise send to the to addresses passed in 
                mail.setToAddresses(addresses);
            }
            
            //set the body and subject
            mail.setPlainTextBody(body);
            mail.setSubject(subject);
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'pro@prontario.org'];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
            catch(Exception e){
                System.debug('sendEmail Exception: ' + e.getMessage());
                
            }
            
        }  
    }