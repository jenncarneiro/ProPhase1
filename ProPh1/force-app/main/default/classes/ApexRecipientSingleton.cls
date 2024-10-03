public class ApexRecipientSingleton {
    
    //create the private instance of the class
    private static ApexRecipientSingleton instance;
    
    //create the public variable to store the email recipient list
    public List<String> emailList {get; private set;}
    System.Debug('public list emailList: ' + emailList);
    
    //create the private constructor to prevent creation of an instance of the class
    private ApexRecipientSingleton(){
        // add all the apex email recipients to the recipient list reusable
        List<ApexEmailNotification> emailRecipients = [SELECT Email FROM ApexEmailNotification];
        if (!emailRecipients.isEmpty()) {
            Set<String> emailAddresses = new Set<String>(); //create a Set string to avoid duplicate email addresses 
            for(ApexEmailNotification er : emailRecipients){
                emailAddresses.add(er.Email); //add each items email address to the Set
            }
            
            //emailList.addAll(emailAddresses);
            
        }

    }
    
    
    //create the publicly available resource to get the instance of the class

    public static ApexRecipientSingleton getInstance(){
        if(instance == null){
            instance = new ApexRecipientSingleton();
        }
        return instance;
    }


    
    
}