public class CancelOptionController {
    
    Public Contract ObjContract{get;set;}
    Public List<Contract_Line_Item__c> LstcontLineItem{get;set;}
    Public Boolean ShowpageBlockFlag{get;set;}
    Public String inputValue{get; set;}
    
    public CancelOptionController(ApexPages.StandardController controller){
        
    }
    
    public PageReference CancelOption(){
        String OptionId = ApexPages.currentPage().getParameters().get('id'); 
        ShowpageBlockFlag = false;
        Contract_Line_Option__c ObjOption = new Contract_Line_Option__c();
        ObjOption = [select id,cancelled__c,contractid__C,Cancelled_Date__c,Cancellation_Reason__c,Manual_Option_Base_Price_Clone__c,Manual_Option_List_Price__c,
                     Manual_Option_Base_Price__c, Final_Price_clone_2__c, List_Price_Total_clone__c, Base_Price_Total_clone__c from Contract_Line_Option__c where id = : OptionId];
        ObjOption.cancelled__c = true;
        ObjOption.Cancelled_Date__c = System.today();
        ObjOption.Base_Price_Total_clone__c = ObjOption.Manual_Option_Base_Price_Clone__c;
        ObjOption.List_Price_Total_clone__c = ObjOption.Manual_Option_List_Price__c;
        ObjOption.Final_Price_clone_2__c = ObjOption.Manual_Option_Base_Price__c;
        ObjOption.Manual_Option_Base_Price_Clone__c = 0;
        ObjOption.Manual_Option_List_Price__c = 0;
        ObjOption.Manual_Option_Base_Price__c = 0;
        string inVal = inputValue;
        system.debug('inVal ===>>>> ' + inVal);
        if(inVal != null && inVal != ''){
            ObjOption.Cancellation_Reason__c = inVal;
        }
        if(ObjOption.Cancellation_Reason__c != Null && ObjOption.Cancellation_Reason__c != ''){
            update objoption;
        }
        else{
            system.debug('in else');
            ShowpageBlockFlag = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill cancellation reason for option '));
            return null;
        }
        
        String RecordId = ObjOption.ContractId__c;
        
        System.debug('RecordId = = = = = = = =  '+RecordId);
        
        PageReference myVFPage = new PageReference('/'+ObjOption.id);
        myVFPage.setRedirect(true);
        return myVFPage;
        
        /*    ObjContract = [select AccountId,ACCOUNT_BUSINESS__c,ACCOUNT_TYPE__c,ActivatedById,ActivatedDate,AdditionalAddress__c,AdditionalName__c,ADDRESS_LINE_1__c,
ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,ADVANCE_PAYMENT__c,BillingAddress,BillingCity,BillingCountry,BillingCountryCode,BillingGeocodeAccuracy,
BillingLatitude,BillingLongitude,BillingName__c,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Cancelled_Reason__c,CITY__c,
CLOSE_LOST_REASON__c,CompanySignedDate,CompanySignedId,Contact_Id__c,Contact__c,ContractId__c,ContractNumber,ContractTerm,Contract_Number__c,
COUNTRY_CODE__c,COUNTRY__c,CreatedById,CreatedDate,CurrencyIsoCode,CustomerSignedDate,CustomerSignedId,CustomerSignedTitle,DATE__c,Description,
Designation__c,Discount1__c,Discount_RollUp__c,Email__c,EndDate,END_CUSTOMER_NAME__c,ExpirationDate__c,Fax__c,FUNCTION__c,FY__c,Grand_Total__c,
Id,INCO_TERMS__c,IsDeleted,IsSyncing__c,LastActivityDate,LastApprovedDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,
LineItemCount__c,MFG_AT__c,Opportunity__c,OwnerExpirationNotice,OwnerId,OwnerId__c,Phone__c,POSTAL_CODE__c,PREPARED_BY__c,Pricebook2Id,
PROBABILITY__c,QUOTATION_ADDRESSED_TO__c,QUOTATION_CREATE__c,Quote__c,QU_REVISION_NUMBER__c,REGION__c,Revision_Number__c,ShippingAddress,
ShippingCity,ShippingCountry,ShippingCountryCode,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingName__c,
ShippingPostalCode,ShippingState,ShippingStateCode,ShippingStreet,Shipping_And_Handling__c,SHIP_TO__c,SOLD_TO__c,SpecialTerms,
StartDate,STATE__c,Status,StatusCode,Status__c,SUBSIDARY__c,Subtotal__c,SystemModstamp,Tax__c,Total_price__c,TYPE__c,VALIDITY__c,QU_Revise_Number__c,
VALITY_DATE__c FROM Contract where id=: RecordId];
System.debug('ObjContract'+ObjContract);
String ContractStatus = ObjContract.Status;

Contract ContractClone  = ObjContract.clone(false, false, false, false);
try{
ContractClone.Contract_Number__c = ObjContract.Contract_Number__c;
ContractClone.Status = 'Draft'; 
insert ContractClone;   
}catch(exception ex){
System.debug('ex'+ex);
}

String ContractCloneId = ContractClone.id;

LstcontLineItem = [SELECT Approval_Note__c,Approval_Status__c,List_Price_Clone__c,Discount_Clone__c,Cancelled__c,Class__c,ContractId__c,Contract_Item_No__c,CreatedById,CreatedDate,CurrencyIsoCode,
Description__c,Discount__c,Division__c,Drawing_No__c,Expected_Advance__c,Expected_Customer_PO__c,Expected_Delivery_date__c,Expected_Delivery__c
,Expected_Drawing_Final__c,Extra_Discount__c,Final_Price_Roll_Up__c,Quantity_Clone__c,Id,IsDeleted,Item_Addition_Function__c,LastModifiedById,LastModifiedDate,Advance_Required__c,
LineNumber__c,Line_Item_Description__c,Line_Item_Number__c,List_Price__c,Mach_Mold_No__c,MFG_Location__c,Name,Product2Id__c,Product_Name__c,Unit_Price_Clone__c,
Project_Created__c,Quantity__c,ServiceDate__c,Sub_Total__c,SystemModstamp,Total_Discount_Value__c,Total_Price__c,UnitPrice__c,Base_Price_Line_Item__c,
(SELECT Cancelled__c,ContractId__c,Contract_Line_Item__c,Contract_Line_Option_No__c,CreatedById,CreatedDate,CurrencyIsoCode,
Description__c,Discount__c,Final_Price__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,Manual_Option_Base_Price__c,
Manual_Option_Function__c,Manual_Option__c,Manual_Product_Name_c__c,Name,Other_Charges_Base_Price__c,Other_Charges_Function__c
,Other_Charges__c,Product_Name__c,Line_Item_Cancelled__c,Product__c,Quantity__c,Select_Option__c,Final_Price_Clone__c,Manual_Option_Base_Price_Clone__c
,Manual_Option_List_Price_Clone__c,Discount_Clone__c FROM Contract_Line_Option__r)
FROM Contract_Line_Item__c where ContractId__c=: RecordId];
System.debug('LstcontLineItem'+LstcontLineItem);

set<Id> SetIfOfContLineItem = new Set<Id>();
for(Contract_Line_Item__c CLI : LstcontLineItem){
SetIfOfContLineItem.add(CLI.id);
}

List<Contract_Line_Option__c> lSTCliO =   new List<Contract_Line_Option__c>();
if(SetIfOfContLineItem != null && SetIfOfContLineItem.size() > 0){
lSTCliO = [SELECT Cancelled__c,ContractId__c,Line_Item_Cancelled__c,Contract_Line_Item__c,Contract_Line_Option_No__c,CreatedById,CreatedDate,CurrencyIsoCode,Description__c,Discount__c
,Final_Price__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,Manual_Option_Base_Price__c,Manual_Option_Function__c,Manual_Option__c,Manual_Product_Name_c__c
,Name,Other_Charges_Base_Price__c,Other_Charges_Function__c,Other_Charges__c,Product_Name__c,Product__c,Quantity__c,Select_Option__c,
Final_Price_Clone__c,Manual_Option_Base_Price_Clone__c,Manual_Option_List_Price_Clone__c,Discount_Clone__c
FROM Contract_Line_Option__c where Contract_Line_Item__c IN: SetIfOfContLineItem];
}

system.debug('lSTCliO===> '+lSTCliO);
List<Contract_Line_Item__c> Lst = new List<Contract_Line_Item__c>();
List<Contract_Line_Option__c    > ListQLo = new  List<Contract_Line_Option__c   >();
List<Contract_Line_Item__c> lstContractItem = new List<Contract_Line_Item__c>();
Map<Id,Contract_Line_Item__c> MapofQuoteContract = new Map<Id,Contract_Line_Item__c>();
//========================================================================================================================================================== 
for(Contract_Line_Item__c pro1 : LstcontLineItem){
String QLIid = pro1.Id;
System.debug('LstcontLineItem'+LstcontLineItem);
System.debug('pro1'+pro1.Product2Id__c);
Contract_Line_Item__c cli = new Contract_Line_Item__c();
if( ContractCloneId!=null && ContractCloneId != ''){
cli.ContractId__c = ContractCloneId; 
}
if(pro1.Cancelled__c !=null){ 
cli.Cancelled__c = pro1.Cancelled__c; 
}
if(pro1.Product2Id__c !=null){ 
cli.Product2Id__c = pro1.Product2Id__c; 
}
if(pro1.Description__c!=null){
cli.Description__c = pro1.Description__c; 
}
if(pro1.Discount_Clone__c!=null){
cli.Discount_Clone__c = pro1.Discount_Clone__c; 
}
if(pro1.List_Price_Clone__c!=null){
cli.List_Price_Clone__c = pro1.List_Price_Clone__c; 
}
if(pro1.Base_Price_Line_Item__c!=null){
cli.Base_Price_Line_Item__c = pro1.Base_Price_Line_Item__c; 
}
if(pro1.Advance_Required__c!=null){
cli.Advance_Required__c = pro1.Advance_Required__c; 
}
if(pro1.Quantity_Clone__c!=null){
cli.Quantity_Clone__c = pro1.Quantity_Clone__c; 
}
if(pro1.Unit_Price_Clone__c!=null){
cli.Unit_Price_Clone__c = pro1.Unit_Price_Clone__c; 
}
if(pro1.Quantity__c!=null){
cli.Quantity__c = LstcontLineItem[0].Quantity__c; 
}
if(pro1.Division__C!=null){
cli.Division__C = pro1.Division__C; 
}
if(pro1.UnitPrice__c!=null){
cli.UnitPrice__c = pro1.UnitPrice__c; 
}
if(pro1.List_Price__c!=null  ){
cli.List_Price__c =pro1.List_Price__c; 
}
if(pro1.Discount__c!=null){
cli.Discount__c = pro1.Discount__c; 
}
if(pro1.Contract_Item_No__c!=null){
cli.Contract_Item_No__c = pro1.Contract_Item_No__c; 
}

System.debug('cli==> '+cli);
lstContractItem.add(cli);
MapofQuoteContract.put(pro1.Id,cli);
}  
try{
insert MapofQuoteContract.values();
}
catch(Exception e){

}
system.debug('MapofQuoteContract===> '+MapofQuoteContract);
system.debug('lstContractItem====> '+lstContractItem);
system.debug('MapofQuoteContract===> '+MapofQuoteContract);
User UsedDeatil = new User();

for(Contract_Line_Option__c pro2 :lSTCliO){
Contract_Line_Option__c ContLO =new Contract_Line_Option__c();
ContLO.Contract_Line_Item__c  = MapofQuoteContract.get(pro2.Contract_Line_Item__c).id;
//.System.debug('cli.id====='+cli.id); 
if(pro2.Discount__c != null){
ContLO.Discount__c = pro2.Discount__c;
}

if(pro2.Manual_Option__c !=null){
ContLO.Manual_Option__c = pro2.Manual_Product_Name_c__c;
}
if(pro2.Manual_Product_Name_c__c !=null){
ContLO.Manual_Product_Name_c__c = pro2.Manual_Product_Name_c__c;
}
if(pro2.Cancelled__c !=null){
ContLO.Cancelled__c = pro2.Cancelled__c;
}
if(pro2.Line_Item_Cancelled__c !=null){
ContLO.Line_Item_Cancelled__c = pro2.Line_Item_Cancelled__c;
}
if(pro2.Manual_Option_Base_Price__c !=null){
ContLO.Manual_Option_Base_Price__c = pro2.Manual_Option_Base_Price__c;
}
if(pro2.Manual_Option_Function__c !=null){
ContLO.Manual_Option_Function__c = pro2.Manual_Option_Function__c;
}
if(ContractCloneId != null && ContractCloneId !='' ){
ContLO.ContractId__c = ContractCloneId;
}
if(pro2.Quantity__c !=null){
ContLO.Quantity__c = pro2.Quantity__c;
}
if(pro2.Other_Charges__c !=null){
ContLO.Other_Charges__c = pro2.Other_Charges__c;
}
if(pro2.Other_Charges_Base_Price__c !=null){
ContLO.Other_Charges_Base_Price__c = pro2.Other_Charges_Base_Price__c;
}
if(pro2.Contract_Line_Option_No__c !=null){
ContLO.Contract_Line_Option_No__c = pro2.Contract_Line_Option_No__c;
}
if(pro2.Other_Charges_Function__c !=null){
ContLO.Other_Charges_Function__c = pro2.Other_Charges_Function__c;
}
if(pro2.Product__c !=null){
ContLO.Product__c = pro2.Product__c;
}
if(pro2.Description__c !=null){
ContLO.Description__c = pro2.Description__c;
}
if(pro2.Select_Option__c !=null){
ContLO.Select_Option__c = pro2.Select_Option__c;
}
/*if(pro2.Final_Price_Clone__c !=null){
ContLO.Final_Price_Clone__c = pro2.Final_Price_Clone__c;
}
if(pro2.Manual_Option_Base_Price_Clone__c !=null){
ContLO.Manual_Option_Base_Price_Clone__c = pro2.Manual_Option_Base_Price_Clone__c;
}
if(pro2.Manual_Option_List_Price_Clone__c !=null){
ContLO.Manual_Option_List_Price_Clone__c = pro2.Manual_Option_List_Price_Clone__c;
}
if(pro2.Discount_Clone__c !=null){
ContLO.Discount_Clone__c = pro2.Discount_Clone__c;
}

// Lst.add(cli);
ListQLo.add(ContLO);
}

System.debug('ListQLo==> '+ListQLo);
insert ListQLo;
try
{
//System.debug('Lst'+Lst.size());
System.debug('ListQLo'+ListQLo.size());

//insert Lst;
//    insert ListQLo;
System.debug(ListQLo);
// redirect(ContractId);
}
catch(Exception e)
{
system.debug('Exception'+e.getMessage()+'====e.'+e.getLineNumber());
}
*/
        
        
    }
    
}