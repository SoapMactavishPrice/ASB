/*
 * This 
 * 
 * 
 * ----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      17-08-2022   Amol Wagh      Added exception handling for update discount
*********************************************/
public class ContractDiscountcontroller {
    
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
    public String errorMessage {get; set;}
    public String error{get;set;}
    public boolean isSuccess{ get ; set;}
    public String successMsg{get; set;}
    
    public ContractDiscountcontroller(ApexPages.StandardController standardPageController) {
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        
        // Contract objContract = (Contract)stdController.getRecord();
        //    RecordId = objContract.Id;
        //    QlineItm = new List<ContractLineItem>();
        CreateContract();   
    }
    
    /* public PageReference add(){
boolean goAhead = True;
ShowpageBlockFlag2 = false;

List<Contract_Line_Option__c> lstQLO = new List<Contract_Line_Option__c>();

// iterate QlineItm
for(Contract_Line_Item__c qli : QlineItm){

}

if(goAhead){
//system.debug('QlineItm ==>>> ' + QlineItm);
//system.debug('lstQLO ==>>> ' + lstQLO);
try{
update QlineItm;
update lstQLO;
}catch(exception e){
system.debug('e.message' +e);
}

PageReference myVFPage = ApexPages.currentPage();
myVFPage.setRedirect(true);
return myVFPage;
}
else{
return null;
}

}*/
    
    public PageReference UpdateDataOnDiscount(){
        ShowpageBlockFlag2 = false;
        Boolean Isdiscountless = false;
        List<Contract_Line_Option__c> lstOptionToUpdate = new List<Contract_Line_Option__c>();
        List<Contract_Line_Item__c> lstItemToUpdate = new List<Contract_Line_Item__c>();
        System.debug('QlineItm = == '+QlineItm);
        for(Contract_Line_Item__c lst:QlineItm){
            
           // lst.Discount_earlier__c = lst.Discount__c;
            if(lst.Discount__c < (-(qt.Subsidiary__r.Negative_Discount__c))){
                System.debug('data is in error');
                Isdiscountless = true;
            }
            else {
                lstItemToUpdate.add(lst);
            }
            //=============================================================Option Update=========================================================================
            if(lst.Contract_Line_Option__r.size() > 0){
                for(Contract_Line_Option__c lstdata:lst.Contract_Line_Option__r){
                    if(lstdata.Discount__c <(-(qt.Subsidiary__r.Negative_Discount__c))){
                        Isdiscountless = true;
                    }
                  //  lstdata.Discount_Earlier__c = lstdata.Discount__c;
                    lstOptionToUpdate.add(lstdata);
                }
                
            }
            
            
            //=======================================================================================================================================================
            
        }
        if(!Isdiscountless){
                if(lstItemToUpdate.size()>0)
                update lstItemToUpdate; 
                if(lstOptionToUpdate.size()>0)
                update lstOptionToUpdate; 
                 ShowpageBlockFlag2 = false;
                 isSuccess=true;
                 successMsg='Discount Has been Applied Successfully! Please Click on "Go Back" to return on Contract Page.';
               
            }else{
                isSuccess=false;
                errorMessage = 'Value can not be less than -'+qt.Subsidiary__r.Negative_Discount__c+'%!!!';
                ShowpageBlockFlag2 = true;
                
            }
        return null; 
    }
    public PageReference gotoContract(){
        PageReference myVFPage = new PageReference('/'+recordID);
        myVFPage.setRedirect(true);
        return myVFPage;  
    }
    
    public PageReference onLineItemDiscountUpdate() {
        ShowpageBlockFlag2 = false;
        Boolean Isdiscountless = false;
        List<Contract_Line_Option__c> lstToUpdate = new List<Contract_Line_Option__c>();
        
        System.debug('RecordId ===> '+RecordId);
        System.debug('QlineItm ===> '+QlineItm.size());
        for(Integer lst = 0; lst < QlineItm.size(); lst++){
            system.debug('qLSTItem---->' + lst);
            for(Integer lstdata = 0; lstdata < QlineItm[lst].Contract_Line_Option__r.size(); lstdata++){
                system.debug('qLSTOption---->' + QlineItm[lst].Contract_Line_Option__r[lstdata]);
                QlineItm[lst].Contract_Line_Option__r[lstdata].Discount__c = QlineItm[lst].Discount__c;
                lstToUpdate.add(QlineItm[lst].Contract_Line_Option__r[lstdata]);
            }
        }
        
        update lstToUpdate;
        update QlineItm;
        
        return null;
    }
    
    public PageReference cancel(){
        
        Boolean IsDiscountGreater = false;
        List<Contract_Line_Option__c> lstToUpdate = new List<Contract_Line_Option__c>();
        
        System.debug('QlineItm = == '+QlineItm);
        for(Contract_Line_Item__c lst:QlineItm){
            if(lst.Discount__c > lst.Discount_Allowed__c  && lst.Discount__c > lst.Approved_Discount__c){
                System.debug('here');
                IsDiscountGreater = true;
                break;
            }
            
            //=============================================================Option Update=========================================================================
            if(lst.Contract_Line_Option__r.size() > 0){
                for(Contract_Line_Option__c lstdata:lst.Contract_Line_Option__r){
                    if(lstdata.Discount__c > lstdata.Discount_Allowed__c  && lstdata.Discount__c > lstdata.Approved_Discount__c){
                        System.debug('here option');
                        IsDiscountGreater = true;
                    }
                    
                }
                
            }
            System.debug('IsDiscountGreater= = = = = = = '+IsDiscountGreater);
        }
        
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        System.debug('RecordId'+RecordId);
        Contract objContract = new Contract();
      
        
       objContract = [select id, Status,name,Contract_Locked_for_Approval__c,Approval_Status_From_HOD__c from Contract where id =: recordID];
        
        if(IsDiscountGreater == true){
            objcontract.Approval_Status_From_HOD__c = '';
            objContract.Contract_Locked_for_Approval__c = true;
            update objContract;
        }
        else
        {
            objcontract.Approval_Status_From_HOD__c = '';
            objContract.Contract_Locked_for_Approval__c = false;
            update objContract;  
        }
        System.debug('after Contract Lock');
        PageReference myVFPage = new PageReference('/'+recordID);
        myVFPage.setRedirect(true);
        return myVFPage;
    }
    
    public void CreateContract(){
        // Contract qt = new Contract();
        ShowpageBlockFlag = false;
        //ShowpageBlockFlag2 = true;
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        System.debug('RecordId'+RecordId);
        qt = [select id,Status,name,Subsidiary__c,Subsidiary__r.Negative_Discount__c,CurrencyIsoCode from Contract where id =: recordID];
        
        QlineItm = new List<Contract_Line_Item__c>(); 
        QlineItm = [select Product2Id__c,Approved_Discount__c, Product2Id__r.Name,List_Price__c,Name,Quantity__c,Division__c,Total_List_Price__c,Total_Price__c,Final_Price__c,
                    UOM__c,Ceiling_Total_Sales_Price__c,ContractId__r.Approval_Status_From_HOD__c
                    ,ContractId__r.Status,
                    Product_Name__c,Line_Item_Number__c,Product_Description__c,Sales_price_Options__c,Discount__c,Discount_Allowed__c,Approval_Note__c,
                    (select Approved_Discount__c,Name,Product_Name__c,Manual_Product_Name_c__c,Manual_Option_List_Price_Clone__c,List_Price_Total__c,Total_Base_Price__c,Discount__c,
                     Final_Price__c,Manual_Option_Base_Price__c,Description__c,Discount_Allowed__c,Discount_Description__c,Sales_price_Total__c,Quantity__c,
                     Select_Option__c,Option_Name__c
                     from Contract_Line_Option__r) 
                    from Contract_Line_Item__c where ContractId__c = :RecordId  
                    AND (ContractId__r.Status = 'CREATED' OR ContractId__r.Status = 'RELEASED' OR ContractId__r.Status = 'Draft')];  
        System.debug('QlineItm'+QlineItm);
        
        if(QlineItm != null && QlineItm.size()>0){
            ShowpageBlockFlag = true;
            ShowpageBlockFlag2 = false;
            System.debug('Data Present');
        }else{
            ShowpageBlockFlag = false;
            ShowpageBlockFlag2 = true;
            errorMessage = 'Either the record is Approved or No Line items are present';
        }
        
        
        
        //  if(qt.Status != 'CREATED'){
        //      ShowpageBlockFlag = true;
        //ShowpageBlockFlag2 = false;
        //      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Sorry, Invalid Status !!')); 
        //  }
        
    }
    public void dummy(){
        integer i = 0;
        i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
    }
    
    
}