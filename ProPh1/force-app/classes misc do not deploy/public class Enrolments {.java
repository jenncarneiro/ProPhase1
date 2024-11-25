public class Enrolments {
    
    @InvocableMethod(label='Get Enrolments' description='Iterate over students, classes and payments and create junction records')
    public static List<EnrolmentsResult> createEnrolments(List<EnrolmentsRequest> request){
        
        //parse inputs and variables
        List<Account> students = request.get(0).students;
        List<Class__c> classes = request.get(0).classes;
        List<Payment__c> payments = request.get(0).payments;
        List<Enrolment__c> enrolments = new List<Enrolment__c>();
        List<String> unenroledStudents = new List<String>();
        
        //start of logic

        //end of logic
        
        //parse outputs
        EnrolmentsResult result = new EnrolmentsResult();
        result.enrolments = enrolments;
        result.unenroledStudents = unenroledStudents;
        List<EnrolmentsResult> resultList = new List<EnrolmentsResult>();
        resultList.add(result);
        return resultList;
    }
    
    
    public class EnrolmentsRequest{
        
        @InvocableVariable
        public List<Account> students;

        @InvocableVariable
        public List<Class__c> classes;
        
        @InvocableVariable
        public List<Payment__c> payments;
    }
    
    public class EnrolmentsResult{
        @InvocableVariable
        public List<Enrolment__c> enrolments; //list from line 19
        
        @InvocableVariable
        public List<String> unenroledStudents; // string from line 20
    }

}
