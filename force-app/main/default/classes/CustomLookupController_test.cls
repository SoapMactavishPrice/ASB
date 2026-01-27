@isTest
public class CustomLookupController_test {
    public static testMethod void testMethod1(){
        String objectName = 'Contract';
        String filterField = 'Name';
        String searchString = 'SI';
        String value = 'dummy';
        
        try{
        CustomLookupController.fetchRecords(objectName, filterField, searchString, value);
        }catch(exception e){
            
        }
        CustomLookupController.RecordsData wr = new CustomLookupController.RecordsData(value, searchString);
        
    }
    
    public static testMethod void testMethod2(){
        String objectName = 'Contract';
        String filterField = 'Name';
        String searchString = 'SI';
        String value = null;
        
        try{
        CustomLookupController.fetchRecords(objectName, filterField, searchString, value);
        }catch(exception e){
            
        }
    }
}