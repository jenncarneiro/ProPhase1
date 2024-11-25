public with sharing class BatchClassDemo implements Database.Batchable<sObject>{
//this example uses a batch class but that isn't needed



    //use the class constructor to set the variables that were passed from flow
    public BatchClassDemo() {
        this.batch_myList = myList;
        this.batch_myStringA = myStringA;
        this.batch_myStringB = myStringB;

    }


    // use an inner class to pass your variables, this example has two strings and a list
    public class inputVariables {

        //use invocable variables

        @InvocableVariable
        public List<sObject> myList;

        @InvocableVariable
        public String myStringA;

        @InvocableVariable
        public String myStringB;

    }

    // set your invocable method to parse the passed in details and then pass them to the batch class
    // this will take as an input a List of the inner class defined which contains the invocable variables
    @InvocableMethod(label='my action label' description = 'my demo action ')
    public static void myInvocableMethod(List<inputVariables> inputs){

        //parse the inputs
        List <sObject> myList = inputs.get(0).myList;
        String myStringA = inputs.get(0).myStringA;
        String myStringB = inputs.get(0).myStringB;

        // now you have te variables passed in from the flow and can do what you want with them!




    }


}