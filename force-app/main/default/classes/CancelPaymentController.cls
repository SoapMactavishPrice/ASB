public class CancelPaymentController {
    
    public string recordId{get;set;}
    
    public CancelPaymentController(ApexPages.StandardController controller){
        
    }
    public PageReference CancelPayment(){
        
        try{
            recordId=ApexPages.CurrentPage().getparameters().get('Id');
            
            Payment__c p=new Payment__c();
            p.Id=recordId;
            p.Payment_Cancelled__c=true;
            update p;
            
            List<Payment_Transaction__c> paymentTransList = new List<Payment_Transaction__c>();
            paymentTransList=[select id from Payment_Transaction__c where Payment__c=:recordId];
            for(Payment_Transaction__c pt:paymentTransList){
                pt.Payment_Cancelled__c=true;
            }
            
            if(paymentTransList.size()>0){
                 update paymentTransList;
            }
           
            system.debug('recordId='+recordId);
            PageReference myVFPage = new PageReference('/'+recordId);
            myVFPage.setRedirect(true);
            return myVFPage;
            
        }catch(exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,e.getMessage())); 
            return null;
        }
        
        
        
    }
    
}