public without sharing class ApexEmailRecipientUtility {
   

    
        //create the private instance of the class
        private static ApexEmailRecipientUtility instance;
        
        //create the public variable to store the email recipient list
        public List<String> emailList {get; private set; }
        
        //create the private constructor to prevent creation of an instance of the class
        private ApexEmailRecipientUtility(){
            // add all the apex email recipient emails and user emails to the reusable list
            List<ApexEmailNotification> emailRecipients = [SELECT Email, User.Email FROM ApexEmailNotification WHERE Email != null OR UserId != null];

                Set<String> emailAddresses = new Set<String>(); //create a Set string to avoid duplicate email addresses 
                for(ApexEmailNotification er : emailRecipients){
                    if(er.Email != null){
                    emailAddresses.add(er.Email); //add each recipient email to the Set
                    }
                    if(er.User.Email != null){ //add each users email to the Set
                        emailAddresses.add(er.User.Email);  
                    }
                }

            List<String> myemailList = new List<String>(emailAddresses); //create a list as that is the format needed for sending
            //System.debug('emailRecipients: ' + emailRecipients);
            //System.debug('emailAddresses: ' + emailAddresses);
            //System.debug('myemailList: ' + myemailList);
            this.emailList = myemailList;                        
            }
        
        
        //create the publicly available resource to get the instance of the class
        public static ApexEmailRecipientUtility getInstance(){
            if(instance == null){
                instance = new ApexEmailRecipientUtility();
            }
            //System.debug('instance: ' + instance);
            return instance;
        }     
    }
