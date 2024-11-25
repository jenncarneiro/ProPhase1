//parse outputs
        importResults result = new importResults();
        result.importDebugResult = successResult;
        List<importResults> resultList = new List<importResults>();
        resultList.add(result);
        return resultList;
    }


      
    public class importResults{
        
        @InvocableVariable
        public List<String> importDebugResult;
    }
