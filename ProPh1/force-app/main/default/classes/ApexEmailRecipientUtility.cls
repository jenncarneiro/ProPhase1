public class ApexEmailRecipientUtility {
   

    
        //create the private instance of the class
        private static ApexEmailRecipientUtility instance;
        
        //create the public variable to store the email recipient list
        public List<String> emailList {get; private set; }
        
        //create the private constructor to prevent creation of an instance of the class
        private ApexEmailRecipientUtility(){
            // add all the apex email recipients to the recipient list reusable
            List<ApexEmailNotification> emailRecipients = [SELECT Email FROM ApexEmailNotification WHERE Email != null];
            List<ApexEmailNotification> emailUsers = [SELECT User.Email FROM ApexEmailNotification WHERE UserId != null];
           // if (!emailRecipients.isEmpty()) {
                Set<String> emailAddresses = new Set<String>(); //create a Set string to avoid duplicate email addresses 
                for(ApexEmailNotification er : emailRecipients){
                    emailAddresses.add(er.Email); //add each items email address to the Set
                }
                for(ApexEmailNotification eru : emailUsers){
                    emailAddresses.add(eru.User.Email);
                }
            List<String> myemailList = new List<String>(emailAddresses);
            System.debug('emailRecipients: ' + emailRecipients);
            System.debug('emailAddresses: ' + emailAddresses);
            System.debug('myemailList: ' + myemailList);
            this.emailList = myemailList;
            
                                           
            }
        
        
        //create the publicly available resource to get the instance of the class
        public static ApexEmailRecipientUtility getInstance(){
            if(instance == null){
                instance = new ApexEmailRecipientUtility();
            }
            System.debug('instance: ' + instance);
            return instance;
        }     
    }
