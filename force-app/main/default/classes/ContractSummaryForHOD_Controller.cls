public class ContractSummaryForHOD_Controller {
    public string recordID;    
    //public String AttachmentName{get;set;}
    //public integer Increment{get;set;}
    //Public Contract ObjContract{get;set;}
    Public Contract qt{get;set;}
    //public Date TodayDate{get;set;}
    //public Account ObjAccount{get;set;}
    public List<Contract_Line_Item__c> QlineItm {get;set;}
    //public User ObjUser{get;set;}
    //public  List<Attachment> allAttachmentParentContains{ get; set; }
    //public boolean displayPopup {get;set;}
    //public String no2words {get;set;}
    public boolean ShowpageBlockFlag {get; set;}
    public boolean ShowpageBlockFlag2 {get; set;}
    //public String errorMessage {get; set;}
    //public String error{get;set;}
    public user objUserdata{get;set;}
    
    public ContractSummaryForHOD_Controller(ApexPages.StandardController standardPageController) {
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        ShowpageBlockFlag = false;
        String UserId =UserInfo.getUserId();
        objUserdata = [Select id,name,is_hod__c from user where id=:UserId]; 
        if(objUserdata.IS_HOD__c == true){
            System.debug('herererererere');
            ShowpageBlockFlag = true;
        }
        
        CreateContract();     
    }
    
    public PageReference Approved(){
        
        PageReference myVFPage = new PageReference('/'+recordID);
        myVFPage.setRedirect(true);
        return myVFPage;
    }
    
    public PageReference Rejected(){
        
        List<Contract_Line_Option__c> lstToUpdate = new List<Contract_Line_Option__c>();
        
        System.debug('QlineItm = == '+QlineItm);
        for(Contract_Line_Item__c lst:QlineItm){
            
            lst.Discount__c = lst.Discount_Earlier__c;
            //=============================================================Option Update=========================================================================
            if(lst.Contract_Line_Option__r.size() > 0){
                for(Contract_Line_Option__c lstdata:lst.Contract_Line_Option__r){
                    lstdata.Discount__c = lstdata.Discount_Earlier__c;
                    lstToUpdate.add(lstdata);
                }
                
            }
            
            //=======================================================================================================================================================
            
            update QlineItm; 
            update lstToUpdate;
            
            
        }
        
        
        PageReference myVFPage = new PageReference('/'+recordID);
        myVFPage.setRedirect(true);
        return myVFPage;
    }    
    
    
    
    
    public void CreateContract(){
        // Contract qt = new Contract();
        //ShowpageBlockFlag = false;
        //ShowpageBlockFlag2 = true;
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        System.debug('RecordId'+RecordId);
        qt = [select id, Status,name from Contract where id =: recordID];
        system.debug('Quote ====> ' + qt);
        
        QlineItm = new List<Contract_Line_Item__c>(); 
        QlineItm = [select Product2Id__c,Discount_Earlier__c, Discount__c,Product2Id__r.Name,List_Price__c,Name,Quantity__c,Division__c,Total_List_Price__c,Total_Price__c,Final_Price__c,
                    UOM__c,Ceiling_Total_Sales_Price__c,ContractId__r.Approval_Status_From_HOD__c
                    ,ContractId__r.Status,
                    Product_Name__c,Line_Item_Number__c,Product_Description__c,Sales_price_Options__c,Discount_Allowed__c,Approval_Note__c,
                    (select Name,Discount_Earlier__c,Product_Name__c,Manual_Product_Name_c__c,Manual_Option_List_Price_Clone__c,List_Price_Total__c,Total_Base_Price__c,Discount__c,
                     Final_Price__c,Manual_Option_Base_Price__c,Description__c,Discount_Allowed__c,Discount_Description__c,Sales_price_Total__c,Quantity__c,
                     Select_Option__c,Option_Name__c
                     from Contract_Line_Option__r) 
                 from Contract_Line_Item__c where ContractId__c = :RecordId ];  
        System.debug('QlineItm'+QlineItm);
        
         // List<Contract_Line_Option__c> lstToUpdate1 = new List<Contract_Line_Option__c>();
        
       for(Contract_Line_Item__c a:QlineItm){
          system.debug('hyyyyy'+a.Discount_Earlier__c );
       }
            
        //   a.Discount_Earlier__c = a.Discount__c ;}
            
           /*  if(a.Contract_Line_Option__r.size() > 0){
                for(Contract_Line_Option__c lstdata:a.Contract_Line_Option__r){
                    lstdata.Discount_Earlier__c = lstdata.Discount__c  ;
                    lstToUpdate1.add(lstdata);
                }
                
            }
           
           // update QlineItm; 
           // update lstToUpdate1;*/
       
        //update QlineItm;    
        
        
        // system.debug('hyyyyyy');
        
       // if(qt.Status != 'CREATED'){
            //ShowpageBlockFlag = true;
            //ShowpageBlockFlag2 = false;
          //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Sorry, Invalid Status !!')); 
      //  }
        
    }
    
    
    
}