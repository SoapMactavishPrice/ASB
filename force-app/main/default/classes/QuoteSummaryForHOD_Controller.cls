public class QuoteSummaryForHOD_Controller {
    public string recordID;    
    public String AttachmentName{get;set;}
    //public integer Increment{get;set;}
    //Public Quote ObjQuote{get;set;}
    Public List<Quote> qt{get;set;}
    public Date TodayDate{get;set;}
    //public Account ObjAccount{get;set;}
    public List<Quote_Line_Item_Custom__c> QlineItm {get;set;}
    //public User ObjUser{get;set;}
    //public  List<Attachment> allAttachmentParentContains{ get; set; }
    //public boolean displayPopup {get;set;}
    //public String no2words {get;set;}
    public boolean ShowpageBlockFlag {get; set;}
    //public boolean ShowpageBlockFlag2 {get; set;}
    //public String errorMessage {get; set;}
    //public String error{get;set;}
    public user objUserdata{get;set;}
    
    public QuoteSummaryForHOD_Controller(ApexPages.StandardController standardPageController) {
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        ShowpageBlockFlag = false;
        String UserId =UserInfo.getUserId();
        objUserdata = [Select id,name,is_hod__c from user where id=:UserId]; 
        if(objUserdata.IS_HOD__c == true){
            System.debug('herererererere');
            ShowpageBlockFlag = true;
        }
        
        CreateQuote();     
    }
    
    
    public PageReference Approved(){
        
        PageReference myVFPage = new PageReference('/'+recordID);
        myVFPage.setRedirect(true);
        return myVFPage;
    }
    
    public PageReference Rejected(){
        
        List<Quote_Line_Options__c> lstToUpdate = new List<Quote_Line_Options__c>();
        
        System.debug('QlineItm = == '+QlineItm);
        for(Quote_Line_Item_Custom__c lst:QlineItm){
            System.debug('lst.discount_earlier__c = = = '+lst.discount_earlier__c);
            if(lst.discount_earlier__c != null){
                lst.Discount__c = lst.discount_earlier__c;   
            }
            
            //=============================================================Option Update=========================================================================
            if(lst.Quote_Line_Options__r.size() > 0){
                for(Quote_Line_Options__c lstdata:lst.Quote_Line_Options__r){
                    if(lstdata.Discount_Earlier__c != null){
                        lstdata.Discount__c = lstdata.Discount_Earlier__c;  
                    }
                    
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
    
    
    
    
    public void CreateQuote(){
        // Quote qt = new Quote();
        //ShowpageBlockFlag = false;
        //ShowpageBlockFlag2 = true;
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        System.debug('RecordId'+RecordId);
        qt = [select id, Status,name from Quote where id =: recordID ];
        system.debug('Quote Name ====> ' + qt);
        
        QlineItm = new List<Quote_Line_Item_Custom__c>(); 
        QlineItm = [select Product__c, Product__r.Name,List_Price__c,Name,Quantity__c,Division__c,Total_List_Price__c,Sales_Price__c,Total_Sales_Price__c,
                    UOM__c,Ceiling_Total_Sales_Price__c,Quote__r.Approval_Status_From_HOD__c,Discount_Earlier__c,Product_Description__c,
                    Product_Name__c,Line_Item_Id__c,Sales_price_Options__c,Discount__c,Discount_Allowed__c,Discount_Allowed_New__c,Discount_Approval_Note__c,
                    (select Name,Product_Name__c,Manual_Product_Name__c,Manula_Option_List_Price__c,List_Price_Quantity__c,Sales_Price__c,Discount__c,Quantity__c,
                     Final_Price__c,Manual_Option_Base_Price__c,Description__c,Discount_Allowed__c,Discount_Allowed_New__c,Discount_Description__c,Sales_price_Total__c,
                     Discount_Earlier__c,Select_Option__c
                     from Quote_Line_Options__r) 
                    from Quote_Line_Item_Custom__c where Quote__c = :RecordId ];  
        System.debug('QlineItm'+QlineItm);
        
        
        
        
        // if(qt.Status != 'CREATED'){
        //ShowpageBlockFlag = true;
        //ShowpageBlockFlag2 = false;
        //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Sorry, Invalid Status !!')); 
        //  }
        
    }
    
    
    
}