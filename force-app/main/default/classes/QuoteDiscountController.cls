/*
* This 
* 
* 
* ----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      17-08-2022   Amol Wagh      Added exception handling for update discount
*********************************************/




public class QuoteDiscountController {
    public string recordID;    
    public String AttachmentName{get;set;}
    public integer Increment{get;set;}
    Public Quote ObjQuote{get;set;}
    Public Quote qt{get;set;}
    public Date TodayDate{get;set;}
    public Account ObjAccount{get;set;}
    public List<Quote_Line_Item_Custom__c> QlineItm {get;set;}
    public User ObjUser{get;set;}
    public  List<Attachment> allAttachmentParentContains{ get; set; }
    public boolean displayPopup {get;set;}
    public String no2words {get;set;}
    public boolean ShowpageBlockFlag {get; set;}
    public boolean ShowpageBlockFlag2 {get; set;}
    public String errorMessage {get; set;}
    //public String error{get;set;}
    public boolean isSuccess{ get ; set;}
    public String successMsg{get; set;}
    public string discuntLineId {get;set;}
    
    
    public QuoteDiscountController(ApexPages.StandardController standardPageController) {
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        System.debug('recordID'+recordID);
        CreateQuote();   
    }
    
    public PageReference UpdateDataOnDiscount(){
        ShowpageBlockFlag2 = false;
        Boolean Isdiscountless = false;
        List<Quote_Line_Options__c> lstOptionToUpdate = new List<Quote_Line_Options__c>();
        List<Quote_Line_Item_Custom__c> lstItemToUpdate = new List<Quote_Line_Item_Custom__c>();
        System.debug('QlineItm = == '+QlineItm);
        for(Quote_Line_Item_Custom__c lst:QlineItm){
            system.debug('lst.Discount_Type__c'+lst.Discount_in_Value__c);
                //if(lst.Discount_in_Value__c < 0 || lst.Discount__c <0){
                  //   Isdiscountless = true; 
                //}else{ if(lst.List_Price__c > 0.00 && lst.List_Price__c != null){
                    lst.Discount_in_Value__c = lst.Discount_in_Value__c;
                    lst.Discount__c = lst.Discount__c;
                    lstItemToUpdate.add(lst);
                //}  
                //}
            
            
            if(lst.Quote_Line_Options__r.size() > 0){
                for(Quote_Line_Options__c lstdata:lst.Quote_Line_Options__r){
                         //if(lstdata.Discount_in_Value__c < 0 || lstdata.Discount__c < 0){
                           //  Isdiscountless = true;
                         //}else{
                         //if(lstdata.Manula_Option_List_Price__c > 0.00 && lstdata.Manula_Option_List_Price__c != null)
                          lstdata.Discount_in_Value__c = lstdata.Discount_in_Value__c;
                          lstdata.Discount__c = lstdata.Discount__c;
                          lstOptionToUpdate.add(lstdata);
                         //}
                         //}
                  
            }
            
            }            
            //=======================================================================================================================================================
            
        }
        system.debug('Isdiscountless'+Isdiscountless);
        try{
            if(!Isdiscountless){
                if(lstOptionToUpdate.size()>0)
                    update lstOptionToUpdate;
                if(lstItemToUpdate.size()>0)
                    update lstItemToUpdate;
                system.debug('discount-->'+JSON.serialize(lstItemToUpdate));
                ShowpageBlockFlag2 = false;
                isSuccess=true;
                successMsg='Discount Has been Applied Successfully! Please Click on "Go Back" to return on Quote Page.';
                
            }else{
                isSuccess=false;
                errorMessage = 'Negetive Disocunt Should not Allowd';
                //errorMessage = e.getMessage();
                ShowpageBlockFlag2 = true;
                // return null;
            }
        }
        catch(exception e)
        {
            ShowpageBlockFlag2 = true;
            isSuccess=false;
            
            String err = e.getMessage();
            string str1= 'fill only one from Discount or Discount in Value';
            string str = 'Discount can'+'t add more than P-D3';
            
            if(err.contains('The Sales Price You Entered Is Less Then The Base Price'))
            {
                errorMessage='The Sales Price You Entered Is Less Then The Base Price.';
            }else if( err.contains(str)){
                errorMessage= str;
            }else{ //if( err.contains('fill only one from Discount or Discount in Value')){
                errorMessage= e.getMessage().substringAfter('EXCEPTION,');
            }
        }
         
    
        return null;
    }
    public PageReference gotoquote(){
        PageReference myVFPage = new PageReference('/'+recordID);
        myVFPage.setRedirect(true);
        return myVFPage;  
    }
    
    public PageReference onLineItemDiscountUpdate() {
        ShowpageBlockFlag2 = false;
        Boolean Isdiscountless = false;
        List<Quote_Line_Options__c> lstToUpdate = new List<Quote_Line_Options__c>();
        
        System.debug('RecordId ===> '+RecordId);
        System.debug('QlineItm ===> '+QlineItm);
        for(Integer lst = 0; lst < QlineItm.size(); lst++){
            system.debug('qLSTItem---->' + lst);
            for(Integer lstdata = 0; lstdata < QlineItm[lst].Quote_Line_Options__r.size(); lstdata++){
                system.debug('qLSTOption---->' + QlineItm[lst].Quote_Line_Options__r[lstdata]);
                QlineItm[lst].Quote_Line_Options__r[lstdata].Discount__c = QlineItm[lst].Discount__c;
                QlineItm[lst].Quote_Line_Options__r[lstdata].Discount_Type__c = QlineItm[lst].Discount_Type__c;
                QlineItm[lst].Quote_Line_Options__r[lstdata].Discount_in_Value__c = QlineItm[lst].Discount_in_Value__c;
                lstToUpdate.add(QlineItm[lst].Quote_Line_Options__r[lstdata]);
            }
        }
        
        update lstToUpdate;
        update QlineItm;
        
        return null;
    }
    
    public PageReference cancel(){
        
        Boolean IsDiscountGreater = false;
        List<Quote_Line_Options__c> lstToUpdate = new List<Quote_Line_Options__c>();
        
        System.debug('QlineItm = == '+QlineItm);
        for(Quote_Line_Item_Custom__c lst:QlineItm){
            if(lst.Discount__c > lst.Discount_Allowed_New__c && lst.Discount__c > lst.Approved_Discount__c){
                System.debug('here');
                IsDiscountGreater = true;
                break;
            }
            
            //=============================================================Option Update=========================================================================
            if(lst.Quote_Line_Options__r.size() > 0){
                for(Quote_Line_Options__c lstdata:lst.Quote_Line_Options__r){
                    if(lstdata.Discount__c > lstdata.Discount_Allowed_New__c  && lst.Discount__c > lst.Approved_Discount__c){
                        System.debug('here option');
                        IsDiscountGreater = true;
                    }
                    
                }
                
            }
            System.debug('IsDiscountGreater= = = = = = = '+IsDiscountGreater);
        }
        
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        Id recTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Approval Quote').getRecordTypeId();
        Id recTypeId_blank = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Blank Quote').getRecordTypeId();
        
        
        System.debug('RecordId'+RecordId);
        quote objquote = new quote();
        objquote = [select id, Status,name,Quote_Locked_for_Approval__c,RecordTypeId,Approval_Status_From_HOD__c from Quote where id =: recordID];
        if(IsDiscountGreater == true){
            objquote.Approval_Status_From_HOD__c = '';
            objquote.RecordTypeId = recTypeId;
            objquote.Quote_Locked_for_Approval__c = true;
            update objquote;
        }
        else
        {
            objquote.Quote_Locked_for_Approval__c = false;
            objquote.RecordTypeId=recTypeId_blank;
            update objquote;  
        }
        
        PageReference myVFPage = new PageReference('/'+recordID);
        myVFPage.setRedirect(true);
        return myVFPage;
    }
    
    public void CreateQuote(){
        ShowpageBlockFlag = false;
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        
        System.debug('RecordId'+RecordId);
        qt = [select id,Status,name,Quote_No__c,Quote_Number1__c,Subsidiary__c,Subsidiary__r.Negative_Discount__c,CurrencyIsoCode from Quote where id =: recordID];
        
        QlineItm = new List<Quote_Line_Item_Custom__c>(); 
        QlineItm = [select Product__c, Discount_Value__c,Product__r.Name,List_Price__c,Name,Quantity__c,Division__c,Total_List_Price__c,Sales_Price__c,Total_Sales_Price__c,Average_Sales_Price__c,
                    UOM__c,Ceiling_Total_Sales_Price__c,Quote__r.Approval_Status_From_HOD__c,Quote__r.Status, Is_Manual__c,Approved_Discount__c,Average_Discount_Value__c,
                    Product_Name__c,Line_Item_Id__c,Sales_price_Options__c,Discount__c,Discount_Allowed__c,Discount_Allowed_New__c,Discount_Approval_Note__c,Product_Description__c,
                    Discount_Type__c, Discount_in_Value__c,Disable_Discoint_Percent__c,Disable_Discoint_Value__c,Sr_No__c,Base_Price__c,
                    (select Name,Product_Name__c,Serial_Number__c,Discount_Value__c,Manual_Product_Name__c,Manula_Option_List_Price__c,List_Price_Quantity__c,Sales_Price__c,Discount__c,Average_Sales_Price__c,
                     Final_Price__c,Manual_Option_Base_Price__c,Description__c,Discount_Allowed__c,Discount_Allowed_New__c,Discount_Description__c,Sales_price_Total__c,Quantity__c,
                     Select_Option__c,Approved_Discount__c ,Discount_Type__c,Discount_in_Value__c,Dis_Disocunt_Percent__c,Disable_Discoint_Value__c,Average_Discount_Value__c
                     from Quote_Line_Options__r order by Serial_Number__c) 
                    from Quote_Line_Item_Custom__c where Quote__c = :RecordId and Quantity__c >: 0 order by Sr_No__c
                   ];  //AND Quote__r.Quote_Locked_for_Approval__c !=TRUE AND Quote__r.Status = 'CREATED'
        System.debug('QlineItm'+QlineItm.size());
        
        if(QlineItm != null && QlineItm.size()>0){
            ShowpageBlockFlag = true;
            ShowpageBlockFlag2 = false;
            System.debug('Data Present');
        }else{
            ShowpageBlockFlag = false;
            ShowpageBlockFlag2 = true;
            errorMessage = 'Either the record is Approved or No Line items are present';
        }
    }
    
   /* public void disableDisocunt (){
        system.debug('call Id');
        for(integer i  = 0 ; i < QlineItm.size(); i++ ){
            
        }
    }
    */
}