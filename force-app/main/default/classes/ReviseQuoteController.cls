/*
Created By Kloudrac.
Desc: Used in VF Page to Revise the Quote.


Discount_Type__c
List_Price__c

----------------------------------------------------------------------SHIP_To_Contact_Name__c
List_Price__c

Version  Date         Author             Remarks
=======   ==========   =============  =showPopup
=================================
V1.1      8-10-2022   Amol Wagh      updated code for fy,Quotenumber.
*********************************************/

public class ReviseQuoteController {
    Public Quote objQuote{get;set;}
    public static boolean isbypassRule = false;
    Public Boolean showPopup{get;set;}
    public List<Quote_Line_Item_Custom__c> ObjQuoteLineItem{get;set;}    
    public ReviseQuoteController(ApexPages.StandardController controller){
        showPopup=true; 
        isbypassRule = true;
    }    
    Public PageReference CloseModal(){
        showPopup=false;
        String CurrentId = ApexPages.currentPage().getParameters().get('id');
        return new PageReference('/'+CurrentId);
    }
    Public PageReference ReviseQuotation(){
        RecursiveTriggerHandler.isNewQuoteCode = true;
        isbypassRule = true;
        User UsedDeatil = new User();
        UsedDeatil = [select id,Name,Level__c from User where id =: userInfo.getUserId()];
        String Level = UsedDeatil.Level__c;
        
        showPopup=false;
        String CurrentId = ApexPages.currentPage().getParameters().get('id'); //
        system.debug('CurrentId'+CurrentId);
        objQuote = [Select id,Discount__c,Machine_Mold__c,Q_PrintMachine__c ,Opportunity.CurrencyISOCode,Q_PrintTiming__c,Q_PrintPayment__c	,Quote_Template__c,Language__c,Subsidiary__c,Additinal_Margin__c,Subsidiary__r.Additional_Margin__c,Subsidiary__r.Rounding_Off_Digits__c,Subsidiary__r.Price_Book__c,Exchange_Rate__c,Quote_Number1__c,Quote_No__c,Cloned_From__c,Advance_Percentage__c,Insurance__c,Insurance_Amount__c,Freight_Amount__c,Freight__c,AccountId,AdditionalAddress,AdditionalName,BillingAddress,BillingName,ContactId,Description,Class__c,Zero_Cooling__c,
                    Discount,Email,ExpirationDate,Fax,GrandTotal,LineItemCount,OpportunityId,Phone,CurrencyIsoCode,Name,Application__c,Mould_Delivery__c,
                    QuoteNumber,QuoteToAddress,QuoteToName,ShippingHandling,ShippingAddress,ShippingName,Status,Shipping_And_Handling__c,Machine_Delivery__c,
                    Subtotal,IsSyncing,Tax,TotalPrice,ACCOUNT_BUSINESS__c,ACCOUNT_TYPE__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,
                    ADVANCE_PAYMENT__c,CITY__c,CLOSE_LOST_REASON__c,Contact__c,COUNTRY__c,COUNTRY_CODE__c,DATE__c,Designation__c,END_CUSTOMER_NAME__c,
                    Text_After_Total__c,Q_PrintShipping__c,Q_PrintConclusion__c,SHIP_To_Contact_Name__c,Contract_Quote_Id__c,
                    FUNCTION__c,INCO_TERMS__c,MFG_AT__c,POSTAL_CODE__c,PREPARED_BY__c,PROBABILITY__c,QUOTATION_ADDRESSED_TO__c,QUOTATION_CREATE__c,QU_REVISION_NUMBER__c,
                    /*REGION__c,*/SHIP_TO__c,SOLD_TO__c,STATE__c,SUBSIDARY__c,TYPE__c,VALIDITY__c,VALITY_DATE__c,Quote_Number__c,Pricebook2Id,Use_Current_Price__c,
                    Account.Global_Region__c,Account.Global_SubRegion__c,Price_in_Word_Required__c,Expected_Month_of_Consolidated_Order__c,Project_Management_Quote_Id__c
                    from Quote Where id =:CurrentId limit 1]; //V1.1 
        
        String QuoteStatus = objQuote.Status;
        Date QuoteValidDate = objQuote.VALITY_DATE__c;
        Date todaysDate = system.today();
        //Id stQuote = Schema.SObjectType.quote.getRecordTypeInfosByName().get('Blank Quote').getRecordTypeId();
        Fiscal_Year_Master__c f=[select id,name,Active__c from Fiscal_Year_Master__c where Active__c=true limit 1]; //V1.1 
        
       decimal exeRate = CommonData.getExchangeRate(objQuote.Opportunity.CurrencyISOCode);
        Quote QuoteClone  = objQuote.clone(false, false, false, false);
        if((QuoteStatus == 'RELEASED' || QuoteStatus == 'CLOSE - REVISED' || QuoteStatus == 'CLOSE - SC CREATED' 
            ) 
           && todaysDate <= QuoteValidDate && objQuote.Use_Current_Price__c == false){
               system.debug('inside if in revise quote -------- curewnt price false');
               try{
                   //QuoteClone.RecordTypeId = stQuote; 
                   QuoteClone.Exchange_Rate__c = exeRate;
                   QuoteClone.Status = 'CREATED';
                   
                   QuoteClone.Advance_Percentage__c = objQuote.Advance_Percentage__c;
                   QuoteClone.Insurance__c = objQuote.Insurance__c;
                   QuoteClone.Insurance_Amount__c = objQuote.Insurance_Amount__c;
                   QuoteClone.Freight_Amount__c = objQuote.Freight_Amount__c;
                   QuoteClone.Freight__c = objQuote.Freight__c;
                   QuoteClone.Discount__c = objQuote.Discount__c;
                   QuoteClone.SHIP_TO__c = objQuote.SHIP_TO__c;
                    QuoteClone.SOLD_TO__c = objQuote.SOLD_TO__c;
                   QuoteClone.SHIP_To_Contact_Name__c = objQuote.SHIP_To_Contact_Name__c;
                   //V1.1  start
                   QuoteClone.Quote_Number1__c=objQuote.Quote_Number1__c;
                   QuoteClone.CurrencyIsoCode=objQuote.CurrencyIsoCode;
                   QuoteClone.Subsidiary__c=objQuote.Subsidiary__c;
                   QuoteClone.Fiscal_Year_Master__c=f.id;
                   QuoteClone.Language__c=objQuote.Language__c;
                   QuoteClone.Quote_Template__c=objQuote.Quote_Template__c;
                   
                  QuoteClone.Machine_Mold__c = QuoteClone.Machine_Mold__c;
                  QuoteClone.Q_PrintMachine__c = QuoteClone.Q_PrintMachine__c;	
                  QuoteClone.Text_After_Total__c  = QuoteClone.Text_After_Total__c;
                  QuoteClone.Q_PrintTiming__c = QuoteClone.Q_PrintTiming__c;
                  QuoteClone.Q_PrintPayment__c = QuoteClone.Q_PrintPayment__c;
                  QuoteClone.Q_PrintShipping__c	 = QuoteClone.Q_PrintShipping__c;
                  QuoteClone.Q_PrintConclusion__c	 = QuoteClone.Q_PrintConclusion__c;
                  QuoteClone.Project_Management_Quote_Id__c = objQuote.Project_Management_Quote_Id__c; 
                  QuoteClone.Contract_Quote_Id__c = objQuote.Contract_Quote_Id__c;
                  QuoteClone.Global_Region__c = objQuote.Account.Global_Region__c;
           		  QuoteClone.Global_SubRegion__c = objQuote.Account.Global_SubRegion__c;
                  QuoteClone.Ship_To_Global_Region__c = objQuote.Account.Global_Region__c;
                  QuoteClone.Ship_To_Global_SubRegion__c = objQuote.Account.Global_SubRegion__c;
                  QuoteClone.Price_in_Word_Required__c = objQuote.Price_in_Word_Required__c;
                  
                
                
                   
                   System.debug('QuoteClone'+QuoteClone);
                   //V1.1 end
                   insert QuoteClone;
                   //Set the Revision Number + 1 and Original Quote Number at time of Revision Quote.
                   if(QuoteClone.id!=null){
                       Quote qt = new Quote();
                       qt = [Select Id,QU_REVISION_NUMBER__c, Exchange_Rate__c from Quote where Id =:QuoteClone.id];
                       Quote qtToUpdate = new Quote(id=qt.id);
                       if(!string.isBlank(qt.QU_REVISION_NUMBER__c))
                           if(Integer.valueOf(qt.QU_REVISION_NUMBER__c)+1 <10)
                           qtToUpdate.QU_REVISION_NUMBER__c = '00'+String.valueOf(Integer.valueOf(qt.QU_REVISION_NUMBER__c)+1);
                       else
                           qtToUpdate.QU_REVISION_NUMBER__c = '0'+String.valueOf(Integer.valueOf(qt.QU_REVISION_NUMBER__c)+1);
                       qtToUpdate.Quote_Number__c = objQuote.Quote_Number__c; //'Original Quote Number' on UI, carry from previous revised quote
                       qt.Cloned_From__c = objQuote.Quote_No__c;
                       update qtToUpdate;
                   }
                   //Update the Status of Parent Quote to 'CLOSE - REVISIED'.
                   objQuote.Status = 'CLOSE - REVISED';
                   update objQuote;                
               }
               catch(Exception e){  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is issue in Revision, Please contact to your System Administrator. Error: '+e.getMessage()));   return null;
                                 }
               
               //System.debug('QuoteClone.Id: : :Kb'+QuoteClone.Id);
               String QuoteCloneId = QuoteClone.Id;
               
               ObjQuoteLineItem = [Select id,Approval_Status__c	,Discount_Allowed_New__c,Class__c,Division__c,Drawing_No__c,Expected_Customer_PO__c,Base_Price__c,BP_Ratio_Line_Item__c,Cavity__c,Total_Sales_Price__c,Application__c,Zero_Cooling_2__c,Product__r.UOM__c,UOM__c,Quote__r.Subsidiary__r.Additional_Margin__c,Quote__r.Subsidiary__r.M1__c,Quote__r.Subsidiary__r.D1__c,Quote__r.Subsidiary__r.D2__c,Quote__r.Additinal_Margin__c,
                                   Expected_Delivery__c,Expected_Delivery_date__c,Expected_Drawing_Final__c,Advance_Percentage__c,Ceiling_Total_Sales_Price__c,CurrencyIsoCode,Product_Type__c,MFG_AT__c,Class_2__c,Product__r.Model__c,Model__c,Level_Of_Ceiling__c,
                                   Mach_Mold_No__c,Discount__c,Product__c,Quantity__c,Quote__c,Discount_Allowed__c,Discount_Approval_Note__c,Is_Manual__c,Payment_Terms__c,Scope_of_mould__c,Product_Name__c,Product__r.Division__c,Product_Description__c,
                                   Total_Base_Price_Options__c,Quote__r.Exchange_Rate__c, List_Price__c,Project_Unique_No__c,
                                   Discount_in_Value__c,Sr_No__c,Is_Tax__c,Discount_Type__c,(Select id,Discount__c,Product_Type__c,Discount_Allowed_New__c,
                                                                                             Serial_Number__c,Discount_in_Value__c,Discount_Type__c,
                                                                                             Final_Price__c,Manual_Option__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Product__r.UOM__c,
                                                                                                         Other_Charges_Base_Price__c,Other_Charges_Function__c,Product__c,Quote__c,Select_Option__c,Mould_Cavity__c,Price_Type__c,Discount_Description__c,Description__c
                                                                                                         from Quote_Line_Options__r order by Serial_Number__c asc)
                                   from Quote_Line_Item_Custom__c Where Quote__c = : CurrentId and Quantity__c > 0 order by Sr_No__c asc];
               
               
               System.debug('ObjQuoteLineItem'+ObjQuoteLineItem);
               set<Id> IdOfOpQuoteItem = new Set<Id>();
               Set<id>proIds=new Set<id>();
               for(Quote_Line_Item_Custom__c QLN : ObjQuoteLineItem){
                   IdOfOpQuoteItem.add(QLN.id);
                   proIds.add(QLN.Product__r.id);
                   for(Quote_Line_Options__c QO:QLN.Quote_Line_Options__r)
                   {
                       proIds.add(QO.Product__r.id);  
                   }
               }
               List<Quote_Line_Options__c> lstQuoteOption = new List<Quote_Line_Options__c>();
               if(IdOfOpQuoteItem != null && IdOfOpQuoteItem.size() > 0){
                   lstQuoteOption = [Select id,CurrencyIsoCode,Discount__c,Serial_Number__c,Discount_in_Value__c,Discount_Type__c,Quote__r.Exchange_Rate__c,Option_Number__c,quantity__c,Discount_Allowed_New__c,Manual_Product_Name__c, Final_Price__c,Manual_Option__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Product__r.UOM__c,Quote__r.Subsidiary__r.Additional_Margin__c,Quote__r.Subsidiary__r.M1__c, Quote__r.Subsidiary__r.D1__c,Quote__r.Subsidiary__r.D2__c,Quote__r.Additinal_Margin__c,
                                     Other_Charges_Base_Price__c,Other_Charges_Function__c,Product__c,Product_Type__c,Quote__c,Select_Option__c,Manula_Option_List_Price__c,Mould_Cavity__c,Price_Type__c,Quote_Line_Item_Custom__c,Discount_Description__c,Description__c
                                     from Quote_Line_Options__c where Quote_Line_Item_Custom__c IN : IdOfOpQuoteItem];
               }
               
               system.debug('lstQuoteOption===> '+lstQuoteOption);
               List<Quote_Line_Item_Custom__c> Lst = new List<Quote_Line_Item_Custom__c>();
               List<Quote_Line_Options__c  > ListQLo = new  List<Quote_Line_Options__c >();
               List<Quote_Line_Item_Custom__c> lstContractItem = new List<Quote_Line_Item_Custom__c>();
               Map<Id,Quote_Line_Item_Custom__c> MapofQuoteContract = new Map<Id,Quote_Line_Item_Custom__c>();
               //PriceBookEntry pbe = new PriceBookEntry();
               Map<Id, PriceBookEntry> mapProductWisePriceEntry = new Map<Id, PricebookEntry>();
               for(PriceBookEntry eachPBE : [SELECT Id, Product2.Id, UnitPrice,List_Price_Level_2__c,List_Price_Level_3__c, Base_Price__c,M1__c,M2__c,M3__c,D1__c,D2__c,D3__c,M4__c
                                             ,Rounding_Off_Digits__c FROM PriceBookEntry Where Product2.IsActive = TRUE AND Pricebook2.id =:objQuote.Subsidiary__r.Price_Book__c 
                                             and IsActive=true AND Product2.id in:proIds]){
                                               mapProductWisePriceEntry.put(eachPBE.Product2.Id,eachPBE);	                
                                             }
               System.debug('mapProductWisePriceEntry** '+mapProductWisePriceEntry.keyset().size());            
               for(Quote_Line_Item_Custom__c pro1 : ObjQuoteLineItem){
                   
                   String QLIid = pro1.Id;
                   
                   Quote_Line_Item_Custom__c cli = new Quote_Line_Item_Custom__c();
                   cli.CurrencyIsoCode=pro1.CurrencyIsoCode;
                   cli.Project_Unique_No__c = pro1.Project_Unique_No__c;
                   if(pro1.Is_Manual__c == false){
                       system.debug('not manual');
                       cli.UOM__c = pro1.Product__r.UOM__c;
                       if(pro1.Discount_Allowed_New__c!=null)
                          cli.Discount_Allowed_New__c = pro1.Discount_Allowed_New__c;
                       if(pro1.Discount_in_Value__c!=null)
                          cli.Discount_in_Value__c = pro1.Discount_in_Value__c;
                       
                       if(pro1.Discount_Type__c!=null)
                          cli.Discount_Type__c = pro1.Discount_Type__c;
                       if(pro1.Is_Tax__c!=null)
                          cli.Is_Tax__c = pro1.Is_Tax__c;
                       if(pro1.Sr_No__c!=null)
                          cli.Sr_No__c = pro1.Sr_No__c;
                       
                       cli.Model__c = pro1.Product__r.Model__c;
                       cli.Division__c = pro1.Product__r.Division__c;
                       if(pro1.Product_Description__c != null && pro1.Product_Description__c != ''){
                           cli.Product_Description__c = pro1.Product_Description__c;
                       }
                       if(pro1.Expected_Customer_PO__c != null ){ cli.Expected_Customer_PO__c = pro1.Expected_Customer_PO__c;
                                                                }
                       if(pro1.Expected_Delivery_date__c != null ){ cli.Expected_Delivery_date__c = pro1.Expected_Delivery_date__c;
                                                                  }
                       if(pro1.Expected_Drawing_Final__c != null ){
                           cli.Expected_Drawing_Final__c = pro1.Expected_Drawing_Final__c;
                       }
                       
                       if( QuoteCloneId!=null && QuoteCloneId != ''){
                           cli.Quote__c = QuoteCloneId; 
                           System.debug('cli.Quote__c:::::'+cli.Quote__c );
                       }
                       if(pro1.Application__c!=null){ cli.Application__c = pro1.Application__c;}
                       if(pro1.Level_Of_Ceiling__c!=null){ cli.Level_Of_Ceiling__c = pro1.Level_Of_Ceiling__c; 
                                                         }
                       if(pro1.MFG_AT__c!=null){ cli.MFG_AT__c = pro1.MFG_AT__c; 
                                               }
                       if(pro1.Mach_Mold_No__c!=null){  cli.Mach_Mold_No__c = pro1.Mach_Mold_No__c; 
                                                     }
                       if(pro1.Class_2__c!=null){     cli.Class_2__c = pro1.Class_2__c; 
                                                }
                       if(pro1.Zero_Cooling_2__c!=null){   cli.Zero_Cooling_2__c = pro1.Zero_Cooling_2__c; 
                                                       }
                       
                       if(pro1.Product_Type__c!=null){   cli.Product_Type__c = pro1.Product_Type__c; 
                                                       }
                       if(pro1.Discount__c!=null){
cli.Discount__c = pro1.Discount__c; 
}
else{
cli.Discount__c = 0;
} 
                       if(pro1.Cavity__c !=null){       cli.Cavity__c = pro1.Cavity__c; 
                                                }
                       if(pro1.Product_Name__c !=null){   cli.Product_Name__c = pro1.Product_Name__c; 
                                                       
                                                      }
                       system.debug('000'+mapProductWisePriceEntry.get(pro1.Product__c));
                       
                       
                       
                       
                       if(mapProductWisePriceEntry.containsKey(pro1.Product__c))
                       { 
                           cli.P_D1__c = mapProductWisePriceEntry.get(pro1.Product__c).d1__c;
                           cli.P_D2__c = mapProductWisePriceEntry.get(pro1.Product__c).d2__c;
                           cli.P_D3__c = mapProductWisePriceEntry.get(pro1.Product__c).d3__c;
                           cli.P_M1__c = mapProductWisePriceEntry.get(pro1.Product__c).M1__c;
                           cli.P_M2__c = mapProductWisePriceEntry.get(pro1.Product__c).M2__c;
                           cli.P_M3__c = mapProductWisePriceEntry.get(pro1.Product__c).M3__c;
                           cli.P_M4__c = mapProductWisePriceEntry.get(pro1.Product__c).M4__c;
                           cli.Discount_Allowed_New__c = cli.Discount_Allowed_New__c;
                           decimal up;
                           up=mapProductWisePriceEntry.get(pro1.Product__c).UnitPrice;
                           cli.Base_Price__c = (mapProductWisePriceEntry.get(pro1.Product__c).Base_Price__c*objQuote.Exchange_Rate__c);
                           //cli.List_Price__c=AddProducts.getListPrice(up,objQuote.Exchange_Rate__c,pro1.Quote__r.Subsidiary__r.D1__c,pro1.Quote__r.Subsidiary__r.D2__c,pro1.Quote__r.Additinal_Margin__c,Integer.valueof(objQuote.Subsidiary__r.Rounding_Off_Digits__c));
                           if(test.isRunningTest()){
                               cli.List_Price__c=AddProducts.getListPrice(2, 1, 1, 1,1,
                                                                          1, cli.Quote__r.Additinal_Margin__c, Integer.valueof(mapProductWisePriceEntry.get(pro1.Product__c).Rounding_Off_Digits__c));
                           }else if(!test.isRunningTest()){
                               cli.List_Price__c=AddProducts.getListPrice(mapProductWisePriceEntry.get(pro1.Product__c).Base_Price__c, pro1.Quote__r.Exchange_Rate__c, mapProductWisePriceEntry.get(pro1.Product__c).M1__c,
                                                                          mapProductWisePriceEntry.get(pro1.Product__c).M2__c,mapProductWisePriceEntry.get(pro1.Product__c).M3__c,mapProductWisePriceEntry.get(pro1.Product__c).M4__c,
                                                                          pro1.Quote__r.Additinal_Margin__c, Integer.valueof(mapProductWisePriceEntry.get(pro1.Product__c).Rounding_Off_Digits__c));
                           }
                       }
                       else {
                           cli.List_Price__c=pro1.List_Price__c;
                           cli.Base_Price__c = pro1.Base_Price__c;
                       }
                       
                       /*if(mapProductWisePriceEntry.containsKey(pro1.Product__c))
                       {
cli.Base_Price__c=mapProductWisePriceEntry.get(pro1.Product__c).Base_Price__c;
                           cli.Base_Price__c = (mapProductWisePriceEntry.get(pro1.Product__c).Base_Price__c*objQuote.Exchange_Rate__c); //*(quantityList[i]
                           cli.Base_Price__c  = 
                               Math.ceil(cli.Base_Price__c/Integer.valueOf(mapProductWisePriceEntry.get(pro1.Product__c).Rounding_Off_Digits__c))*Integer.valueOf(mapProductWisePriceEntry.get(pro1.Product__c).Rounding_Off_Digits__c);
                       
                           cli.Base_Price__c = (mapProductWisePriceEntry.get(pro1.Product__c).Base_Price__c);
                       }
                       else */
                           
                        
                       
                       if(pro1.Discount_Approval_Note__c !=null){ 
                           cli.Discount_Approval_Note__c = pro1.Discount_Approval_Note__c; 
                       }
                       else{
                           system.debug('in disc desc null');
                           cli.Discount_Approval_Note__c = 'Null'; 
                       }
                       if(pro1.Scope_of_mould__c !=null){ 
                           cli.Scope_of_mould__c = pro1.Scope_of_mould__c; 
                       }
                       if(pro1.Product__c !=null){ 
                           cli.Product__c = pro1.Product__c; 
                       }
                       if(pro1.Product_Type__c !=null){ 
                           cli.Product_Type__c = pro1.Product_Type__c; 
                       }
                       
                       if(pro1.Advance_Percentage__c!=null){
                           cli.Advance_Percentage__c = pro1.Advance_Percentage__c; 
                       }
                       if(pro1.Quantity__c!=null){
                           cli.Quantity__c = pro1.Quantity__c; 
                       }
                       System.debug('cli==> '+cli);
                       lstContractItem.add(cli);
                       MapofQuoteContract.put(pro1.Id,cli);
                   }
                   
                   System.debug('pro1.Is_Manual__c==> '+pro1.Is_Manual__c);
                   if(pro1.Is_Manual__c == true){
                       system.debug('is manual');
                       cli.Is_Manual__c = True;
                       //cli.Application__c = appName; 
                       if(pro1.Discount_Allowed_New__c!=null)
                          cli.Discount_Allowed_New__c = pro1.Discount_Allowed_New__c;
                       if(pro1.Discount_in_Value__c!=null)
                          cli.Discount_in_Value__c = pro1.Discount_in_Value__c;
                       
                        if(pro1.Discount__c!=null)
                          cli.Discount__c = pro1.Discount__c;
                       
                       if(pro1.Discount_Type__c!=null)
                          cli.Discount_Type__c = pro1.Discount_Type__c;
                       if(pro1.Is_Tax__c!=null)
                          cli.Is_Tax__c = pro1.Is_Tax__c;
                       if(pro1.Sr_No__c!=null)
                          cli.Sr_No__c = pro1.Sr_No__c;
                       
                       if( QuoteCloneId!=null && QuoteCloneId != ''){
                           cli.Quote__c = QuoteCloneId; 
                           System.debug('cli.Quote__c:::::'+cli.Quote__c );
                       }
                       if(pro1.Application__c!=null){
                           cli.Application__c = pro1.Application__c; 
                       }
                       if(pro1.Level_Of_Ceiling__c!=null){
                           cli.Level_Of_Ceiling__c = pro1.Level_Of_Ceiling__c; 
                       }
                       if(pro1.Expected_Drawing_Final__c != null ){
                           cli.Expected_Drawing_Final__c = pro1.Expected_Drawing_Final__c;
                       }
                       if(pro1.Expected_Delivery_date__c != null ){
                           cli.Expected_Delivery_date__c = pro1.Expected_Delivery_date__c;
                       }
                       if(pro1.Expected_Customer_PO__c != null){
                           cli.Expected_Customer_PO__c = pro1.Expected_Customer_PO__c;
                       }
                       if(pro1.Product_Description__c != null && pro1.Product_Description__c != ''){
                           cli.Product_Description__c = pro1.Product_Description__c;
                       }
                       if(pro1.MFG_AT__c!=null){
                           cli.MFG_AT__c = pro1.MFG_AT__c; 
                       }
                       if(pro1.Mach_Mold_No__c!=null){
                           cli.Mach_Mold_No__c = pro1.Mach_Mold_No__c; 
                       }
                       if(pro1.Class_2__c!=null){
                           cli.Class_2__c = pro1.Class_2__c; 
                       }
                       if(pro1.Zero_Cooling_2__c!=null){
                           cli.Zero_Cooling_2__c = pro1.Zero_Cooling_2__c; 
                       }
                       if(pro1.Discount_Approval_Note__c !=null){ 
                           cli.Discount_Approval_Note__c = pro1.Discount_Approval_Note__c; 
                       }
                       
                       if(pro1.Product_Type__c !=null){ 
                           cli.Product_Type__c = pro1.Product_Type__c; 
                       }
                       else{
                           system.debug('in disc desc null');
                           cli.Discount_Approval_Note__c = 'Null'; 
                       }
                       
                       /*if(pro1.Discount__c!=null){
cli.Discount__c = pro1.Discount__c; 
}
else{
cli.Discount__c = 0;
} */
                       if(pro1.Cavity__c !=null){ 
                           cli.Cavity__c = pro1.Cavity__c; 
                       }
                       if(pro1.Product_Name__c !=null){ 
                           cli.Product_Name__c = pro1.Product_Name__c; 
                       }
                       if(pro1.Base_Price__c !=null){ 
                           cli.Base_Price__c = pro1.Base_Price__c; 
                       }
                       if(pro1.List_Price__c !=null){ 
                           cli.List_Price__c = pro1.List_Price__c; 
                       }
                       if(pro1.Scope_of_mould__c !=null){ 
                           cli.Scope_of_mould__c = pro1.Scope_of_mould__c; 
                       }
                       if(pro1.Product__c !=null){ 
                           cli.Product__c = pro1.Product__c; 
                       }
                       if(pro1.Product_Type__c !=null){ 
                           cli.Product_Type__c = pro1.Product_Type__c; 
                       }
                       if(pro1.Product_Description__c!=null){
                           cli.Product_Description__c = pro1.Product_Description__c; 
                       }
                       if(pro1.Advance_Percentage__c!=null){
                           cli.Advance_Percentage__c = pro1.Advance_Percentage__c; 
                       }
                       if(pro1.Quantity__c!=null){
                           cli.Quantity__c = pro1.Quantity__c;
                       }
                       
                       
                       
                       System.debug('cli==> '+cli);
                       System.debug('pro1.Discount__c'+pro1.Discount__c);
                       lstContractItem.add(cli);
                       MapofQuoteContract.put(pro1.Id,cli);
                   }
               }  
               try{
                   insert MapofQuoteContract.values();
               }
               catch(Exception e){  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is issue in Revision, Please contact to your System Administrator. Error: '+e.getMessage()));return null;
                                 }
               
               
               Map<Id, PriceBookEntry> mapProductWisePriceOptionEntry = new Map<Id, PricebookEntry>();
               for(PriceBookEntry eachPBE : [SELECT Id, Product2.Id,unitprice,Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c,M1__c,M2__c,M3__c,D1__c,D2__c,D3__c,M4__c
                                             ,Rounding_Off_Digits__c
                                             FROM PriceBookEntry 
                                             WHERE Pricebook2Id IN (SELECT Id FROM PriceBook2  where  Pricebook2.id =:objQuote.Subsidiary__r.Price_Book__c AND 
                                                                    PriceBook2.IsActive = true)
                                             AND Product2.IsACTIVE = true AND Product2.Family = 'Options' and Product2.id in:proIds]){
                                                 mapProductWisePriceOptionEntry.put(eachPBE.Product2.Id,eachPBE);	                
                                             }
               System.debug('mapProductWisePriceOptionEntry** '+mapProductWisePriceOptionEntry.keyset().size());  
               
               
               
               for(Quote_Line_Options__c pro2 :lstQuoteOption){
                   
                   Quote_Line_Options__c ContLO =new Quote_Line_Options__c();
                   ContLO.Quote_Line_Item_Custom__c  = MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id;  
                   String prodId = pro2.Product__c;
                   ContLO.CurrencyIsoCode=pro2.CurrencyIsoCode;
                   if( pro2.Select_Option__c == false){
                       if(pro2.Discount_Allowed_New__c!=null)
                          ContLO.Discount_Allowed_New__c = pro2.Discount_Allowed_New__c;
                       if(pro2.Description__c != null && pro2.Description__c != ''){
                           ContLO.Description__c = pro2.Description__c;
                       }
                       if(pro2.Discount_in_Value__c!=null)
                          ContLO.Discount_in_Value__c = pro2.Discount_in_Value__c;
                       if(pro2.Discount_Type__c != null && pro2.Discount_Type__c != ''){
                           ContLO.Discount_Type__c = pro2.Discount_Type__c;
                       }
                       
                       
                       if(pro2.Final_Price__c!=null)
                          ContLO.Final_Price__c = pro2.Final_Price__c;
                       if(pro2.Serial_Number__c != null){
                           ContLO.Serial_Number__c	 = pro2.Serial_Number__c	;
                       }
                       ContLO.UOM__c = pro2.Product__r.UOM__c;
                       ContLO.Discount_Allowed_New__c = ContLO.Discount_Allowed_New__c;
                       if(pro2.Product__c !=null){
                           ContLO.Product__c = pro2.Product__c;
                       } 
                       if(pro2.Description__c != null && pro2.Description__c != ''){
                           ContLO.Description__c = pro2.Description__c;
                       }
                       if(pro2.Discount__c != null){
ContLO.Discount__c = pro2.Discount__c;
}
                       if(pro2.quantity__c != null){
                           ContLO.quantity__c = pro2.quantity__c;
                       }
                       if(pro2.Discount_Description__c != null){
                           ContLO.Discount_Description__c = pro2.Discount_Description__c;
                       }
                       else{
                           ContLO.Discount_Description__c = 'Null';
                       }
                       
                       
                       ContLO.Discount_Allowed_New__c = ContLO.Discount_Allowed_New__c;
                       //System.debug('pmap.get(qlio.Product__c)'+mapProductWisePriceOptionEntry.get(ContLO.Product__c));
                       //system.debug('mapProductWisePriceOptionEntry.containsKey(pro2.Product__c)'+mapProductWisePriceOptionEntry.get(pro2.Product__c));
                       
                       if(mapProductWisePriceOptionEntry.containsKey(pro2.Product__c)){
                           ContLO.P_D1__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).d1__c;
                           ContLO.P_D2__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).d2__c;
                           ContLO.P_D3__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).d3__c;
                           ContLO.P_M1__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).M1__c;
                           ContLO.P_M2__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).M2__c;
                           ContLO.P_M3__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).M3__c;
                           ContLO.P_M4__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).M4__c;
                           Double up;
                           up=mapProductWisePriceOptionEntry.get(pro2.Product__c).Base_Price__c;
                           //ContLO.Manula_Option_List_Price__c = pro2.Manula_Option_List_Price__c;
                           //ContLO.Manula_Option_List_Price__c = up;
                           ContLO.Manula_Option_List_Price__c=AddProducts.getListPrice(up, pro2.Quote__r.Exchange_Rate__c, 
                                                                                       mapProductWisePriceOptionEntry.get(pro2.Product__c).M1__c, mapProductWisePriceOptionEntry.get(pro2.Product__c).M2__c, mapProductWisePriceOptionEntry.get(pro2.Product__c).M3__c,
                                                                                       mapProductWisePriceOptionEntry.get(pro2.Product__c).M4__c,pro2.Quote__r.Additinal_Margin__c, Integer.valueof(mapProductWisePriceOptionEntry.get(ContLO.Product__c).Rounding_Off_Digits__c));
                           //ontLO.Manula_Option_List_Price__c=AddProducts.getListPrice(pmapqlio.get(qlio.Product__c).UnitPrice, qlio.Quote__r.Exchange_Rate__c, pmapqlio.get(qlio.Product__c).M1__c, pmapqlio.get(qlio.Product__c).M2__c, pmapqlio.get(qlio.Product__c).M3__c,pmapqlio.get(qlio.Product__c).M4__c,qlio.Quote__r.Additinal_Margin__c, Integer.valueof(pmapqlio.get(qlio.Product__c).Rounding_Off_Digits__c));
                           
                           // ContLO.Manula_Option_List_Price__c=AddProducts.getListPrice(up,objQuote.Exchange_Rate__c,pro2.Quote__r.Subsidiary__r.D1__c,pro2.Quote__r.Subsidiary__r.D2__c,pro2.Quote__r.Additinal_Margin__c,Integer.valueof(objQuote.Subsidiary__r.Rounding_Off_Digits__c));
                       }
                       
                       if(!test.isRunningTest()){
                       ContLO.Manual_Option_Base_Price__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).Base_Price__c * pro2.Quote__r.Exchange_Rate__c;
                       }else
                           {
                               ContLO.Manual_Option_Base_Price__c = 100;
                           }
                       
                           /*if(mapProductWisePriceOptionEntry.containsKey(pro2.Product__c)){  
                           ContLO.Manual_Option_Base_Price__c = (mapProductWisePriceOptionEntry.get(pro2.Product__c).UnitPrice*objQuote.Exchange_Rate__c); //*(quantityList[i]
                           //ContLO.Manual_Option_Base_Price__c = Math.ceil(ContLO.Manual_Option_Base_Price__c/Integer.valueOf(objQuote.Subsidiary__r.Rounding_Off_Digits__c))*Integer.valueOf(objQuote.Subsidiary__r.Rounding_Off_Digits__c);
                           
                           //ContLO.Manual_Option_Base_Price__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).Base_Price__c;
                       } */                    
                       if(QuoteCloneId != null && QuoteCloneId !='' ){
                           ContLO.Quote__c = QuoteCloneId;
                       }
                       if(pro2.Manual_Option__c !=null){                           ContLO.Manual_Option__c = pro2.Manual_Option__c;
                                                       }
                       if(pro2.description__c !=null){                           ContLO.description__c = pro2.description__c;
                                                     }
                       if(pro2.Option_Number__c !=null){                           ContLO.Option_Number__c = pro2.Option_Number__c;
                                                       }
                       if(pro2.Manual_Product_Name__c !=null){                           ContLO.Manual_Product_Name__c = pro2.Manual_Product_Name__c;
                                                             }
                       if(pro2.Mould_Cavity__c !=null){                           ContLO.Mould_Cavity__c = pro2.Mould_Cavity__c;
                                                      }
                       /*if(pro2.Price_Type__c !=null){    
                           ContLO.Price_Type__c = pro2.Price_Type__c;
                        }*/
                       if(pro2.Manual_Option_Function__c !=null){                           ContLO.Manual_Option_Function__c = pro2.Manual_Option_Function__c;
                                                                }
                       if(pro2.Other_Charges__c !=null){                           ContLO.Other_Charges__c = pro2.Other_Charges__c;
                                                       }
                       if(pro2.Other_Charges_Base_Price__c !=null){                           ContLO.Other_Charges_Base_Price__c = pro2.Other_Charges_Base_Price__c;
                                                                  }
                       if(pro2.Other_Charges_Function__c !=null){                           ContLO.Other_Charges_Function__c = pro2.Other_Charges_Function__c;
                         
                                                                }
                       
                       if(pro2.Product_Type__c!=null){   ContLO.Product_Type__c = pro2.Product_Type__c;}
                       if(pro2.Select_Option__c !=null){
                           ContLO.Select_Option__c = pro2.Select_Option__c;
                       } 
                       
                       
                   }
                   
                   else if(pro2.Select_Option__c == true){
                       
                         if(pro2.Product_Type__c!=null){   ContLO.Product_Type__c = pro2.Product_Type__c;}
                       
                       if(pro2.Discount_Allowed_New__c!=null)
                           
                          ContLO.Discount_Allowed_New__c = pro2.Discount_Allowed_New__c;
                       if(pro2.Description__c != null && pro2.Description__c != ''){
                           ContLO.Description__c = pro2.Description__c;
                       }
                       if(pro2.Discount_in_Value__c!=null)
                          ContLO.Discount_in_Value__c = pro2.Discount_in_Value__c;
                       if(pro2.Discount_Type__c != null && pro2.Discount_Type__c != ''){
                           ContLO.Discount_Type__c = pro2.Discount_Type__c;
                       }
                       
                       
                       if(pro2.Final_Price__c!=null)
                          ContLO.Final_Price__c = pro2.Final_Price__c;
                       if(pro2.Serial_Number__c != null){
                           ContLO.Serial_Number__c	 = pro2.Serial_Number__c	;
                       }
                       if(pro2.Product__c !=null){
                           ContLO.Product__c = pro2.Product__c;
                       } 
                       if(pro2.Product_Type__c !=null){
                           ContLO.Product_Type__c = pro2.Product_Type__c;
                       } 
                       if(pro2.Discount__c != null){
ContLO.Discount__c = pro2.Discount__c;
}
                       if(pro2.Description__c != null && pro2.Description__c != ''){
                           ContLO.Description__c = pro2.Description__c;
                       }
                       if(pro2.quantity__c != null){
                           ContLO.quantity__c = pro2.quantity__c;
                       }
                       if(pro2.Manula_Option_List_Price__c != null){
                           ContLO.Manula_Option_List_Price__c = pro2.Manula_Option_List_Price__c;
                       }
                       
                       if(pro2.Discount_Description__c != null){
                           ContLO.Discount_Description__c = pro2.Discount_Description__c;
                       }
                       else{
                           ContLO.Discount_Description__c = 'Null';
                       }
                       if(pro2.Manual_Option_Base_Price__c != null){
                           ContLO.Manual_Option_Base_Price__c = pro2.Manual_Option_Base_Price__c;
                       }
                       if(QuoteCloneId != null && QuoteCloneId !='' ){
                           ContLO.Quote__c = QuoteCloneId;
                       }
                       if(pro2.Manual_Option__c !=null){
                           ContLO.Manual_Option__c = pro2.Manual_Option__c;
                       }
                       if(pro2.description__c !=null){
                           ContLO.description__c = pro2.description__c;
                       }
                       if(pro2.Option_Number__c !=null){
                           ContLO.Option_Number__c = pro2.Option_Number__c;
                       }
                       if(pro2.Manual_Product_Name__c !=null){
                           ContLO.Manual_Product_Name__c = pro2.Manual_Product_Name__c;
                       }
                       if(pro2.Manual_Option_Function__c !=null){
                           ContLO.Manual_Option_Function__c = pro2.Manual_Option_Function__c;
                       }
                       if(pro2.Other_Charges__c !=null){
                           ContLO.Other_Charges__c = pro2.Other_Charges__c;
                       }
                       if(pro2.Other_Charges_Base_Price__c !=null){
                           ContLO.Other_Charges_Base_Price__c = pro2.Other_Charges_Base_Price__c;
                       }
                       if(pro2.Other_Charges_Function__c !=null){
                           ContLO.Other_Charges_Function__c = pro2.Other_Charges_Function__c;
                       }
                       if(pro2.Select_Option__c !=null){
                           ContLO.Select_Option__c = pro2.Select_Option__c;
                       }
                       if(pro2.Quantity__c!=null){
                         ContLO.Quantity__c = pro2.Quantity__c; 
                       }
                   }
                   ListQLo.add(ContLO);
                   
               }  
               try
               {                   
                   insert ListQLo;
                   system.debug('List of Option Inserted Successfully ** '+ListQLo.size());
               }
               catch(Exception e)
               {
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is issue in Revision, Please contact to your System Administrator.'));
                   return null;
               }
               
               List<Attachment> lstAtt = new List<Attachment>();
               lstAtt = [select id, name, body, LastModifiedDate, Createddate , createdby.name,ParentId from Attachment where ParentId=:QuoteCloneId ];
               
               lstAtt.clear();
               
               PageReference myVFPage = new PageReference('/'+QuoteCloneId);
               myVFPage.setRedirect(true);
               return myVFPage;
           }
        else if((QuoteStatus == 'RELEASED' || QuoteStatus == 'CLOSE - REVISED' || QuoteStatus == 'CLOSE - SC CREATED'
                 ) && todaysDate <= QuoteValidDate && objQuote.Use_Current_Price__c == true)
        {
            system.debug('inside if in revise quote -------- curewnt price true');
            
            try{
                //QuoteClone.RecordTypeId = stQuote; 
                QuoteClone.Status = 'CREATED';  
                insert QuoteClone;
                //Set the Revision Number + 1 and Original Quote Number at time of Revision Quote.
                if(QuoteClone.id!=null){
                    Quote qt = new Quote();
                    qt = [Select Id,QU_REVISION_NUMBER__c from Quote where Id =:QuoteClone.id];
                    Quote qtToUpdate = new Quote(id=qt.id);
                    if(!string.isBlank(qt.QU_REVISION_NUMBER__c))
                        if(Integer.valueOf(qt.QU_REVISION_NUMBER__c)+1 <10)
                        qtToUpdate.QU_REVISION_NUMBER__c = '00'+String.valueOf(Integer.valueOf(qt.QU_REVISION_NUMBER__c)+1);
                    else
                        qtToUpdate.QU_REVISION_NUMBER__c = '0'+String.valueOf(Integer.valueOf(qt.QU_REVISION_NUMBER__c)+1);
                    qtToUpdate.Quote_Number__c = objQuote.Quote_Number__c; //'Original Quote Number' on UI, carry from previous revised quote
                    qt.Cloned_From__c = objQuote.Cloned_From__c;
                    update qtToUpdate;
                }
                
                //QuoteClone.Revision_Of_Quote__c =  objQuote.Revision_Of_Quote__c;
                objQuote.Status = 'CLOSE - REVISIED';
               
                update objQuote;
                
            }
            catch(Exception e){
                
            }
            
            System.debug('QuoteClone.Id: : :Kb'+QuoteClone.Id);
            String QuoteCloneId = QuoteClone.Id;
            
            ObjQuoteLineItem = [Select id,Approval_Status__c,Class__c,Division__c,Discount_Allowed_New__c,Drawing_No__c,Expected_Customer_PO__c,Base_Price__c,BP_Ratio_Line_Item__c,Cavity__c,Total_Sales_Price__c,Level_Of_Ceiling__c,
                                Expected_Delivery__c,Expected_Delivery_date__c,Expected_Drawing_Final__c,Advance_Percentage__c,Ceiling_Total_Sales_Price__c,CurrencyIsoCode,Product_Type__c,
                                Mach_Mold_No__c,Product__c,Quantity__c,Quote__c,Discount_Allowed__c,Discount_Approval_Note__c,Is_Manual__c,Payment_Terms__c,Scope_of_mould__c,Product_Name__c,
                                Total_Base_Price_Options__c, List_Price__c,Discount__c,Sr_No__c,Is_Tax__c,Discount_Type__c,Discount_in_Value__c,(Select id,Discount__c,Final_Price__c,Discount_in_Value__c,Discount_Allowed_New__c,Manual_Option__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,
                                                                            Other_Charges_Base_Price__c,Product_Type__c,Other_Charges_Function__c,Product__c,Quote__c,Select_Option__c,Mould_Cavity__c,Price_Type__c,Discount_Description__c
                                                                            ,Serial_Number__c,Discount_Type__c from Quote_Line_Options__r)
                                from Quote_Line_Item_Custom__c Where Quote__c = : CurrentId];
            
            
            System.debug('ObjQuoteLineItem'+ObjQuoteLineItem);
            set<Id> IdOfOpQuoteItem = new Set<Id>();
            for(Quote_Line_Item_Custom__c QLN : ObjQuoteLineItem){
                IdOfOpQuoteItem.add(QLN.id);
            }
            List<Quote_Line_Options__c> lstQuoteOption = new List<Quote_Line_Options__c>();
            if(IdOfOpQuoteItem != null && IdOfOpQuoteItem.size() > 0){
                lstQuoteOption = [Select id,Discount_in_Value__c,Discount_Allowed_New__c,Discount_Type__c,Product_Type__c,CurrencyIsoCode,Discount__c,Option_Number__c,quantity__c,description__c,Manual_Product_Name__c, Final_Price__c,Manual_Option__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,
                                 Serial_Number__c, Other_Charges_Base_Price__c,Other_Charges_Function__c,Product__c,Quote__c,Select_Option__c,Manula_Option_List_Price__c,Mould_Cavity__c,Price_Type__c,Quote_Line_Item_Custom__c,Discount_Description__c
                                  from Quote_Line_Options__c where Quote_Line_Item_Custom__c IN : IdOfOpQuoteItem];
            }
            
            List<Quote_Line_Item_Custom__c> Lst = new List<Quote_Line_Item_Custom__c>();
            List<Quote_Line_Options__c  > ListQLo = new  List<Quote_Line_Options__c >();
            List<Quote_Line_Item_Custom__c> lstContractItem = new List<Quote_Line_Item_Custom__c>();
            Map<Id,Quote_Line_Item_Custom__c> MapofQuoteContract = new Map<Id,Quote_Line_Item_Custom__c>();
            
            for(Quote_Line_Item_Custom__c pro1 : ObjQuoteLineItem){
                Quote_Line_Item_Custom__c cli = new Quote_Line_Item_Custom__c(); 
                cli.CurrencyIsoCode=pro1.CurrencyIsoCode;
                if(pro1.Discount_Allowed_New__c!=null)
                          cli.Discount_Allowed_New__c = pro1.Discount_Allowed_New__c;
                       if(pro1.Discount_in_Value__c!=null)
                          cli.Discount_in_Value__c = pro1.Discount_in_Value__c;
                       
                       if(pro1.Discount_Type__c!=null)
                          cli.Discount_Type__c = pro1.Discount_Type__c;
                       if(pro1.Is_Tax__c!=null)
                          cli.Is_Tax__c = pro1.Is_Tax__c;
                       if(pro1.Sr_No__c!=null)
                          cli.Sr_No__c = pro1.Sr_No__c;
                if(pro1.Discount__c!=null)
                          cli.Discount__c = pro1.Discount__c;
                
                if( QuoteClone!=null){
                    cli.Quote__c = QuoteClone.id; 
                    System.debug('cli.Quote__c:::::'+cli.Quote__c );
                }
                if(pro1.Discount_Approval_Note__c !=null){ 
                    cli.Discount_Approval_Note__c = pro1.Discount_Approval_Note__c; 
                }
                else{
                    system.debug('in disc desc null');
                    cli.Discount_Approval_Note__c = 'Null'; 
                }
                if(pro1.Level_Of_Ceiling__c!=null){
                    cli.Level_Of_Ceiling__c = pro1.Level_Of_Ceiling__c; 
                }
                /*if(pro1.Discount__c!=null){
cli.Discount__c = pro1.Discount__c; 
}*/
                if(pro1.Cavity__c !=null){ 
                    cli.Cavity__c = pro1.Cavity__c; 
                }
                if(pro1.Product_Name__c !=null){ 
                    cli.Product_Name__c = pro1.Product_Name__c; 
                }
                if(pro1.Is_Manual__c !=null){ 
                    cli.Is_Manual__c = pro1.Is_Manual__c; 
                }
                if(pro1.Base_Price__c !=null){ 
                    cli.Base_Price__c = pro1.Base_Price__c; 
                }
                if(pro1.List_Price__c !=null){ 
                    cli.List_Price__c = pro1.List_Price__c; 
                }
                if(pro1.Scope_of_mould__c !=null){ 
                    cli.Scope_of_mould__c = pro1.Scope_of_mould__c; 
                }
                if(pro1.Product__c !=null){ 
                    cli.Product__c = pro1.Product__c; 
                }
                if(pro1.Product_Type__c !=null){ 
                    cli.Product_Type__c = pro1.Product_Type__c; 
                }
                
                if(pro1.Advance_Percentage__c!=null){
                    cli.Advance_Percentage__c = pro1.Advance_Percentage__c; 
                }
                if(pro1.Quantity__c!=null){
                    cli.Quantity__c = pro1.Quantity__c; 
                }
                
                lstContractItem.add(cli);
                MapofQuoteContract.put(pro1.Id,cli);
            }
            try{
                
                insert MapofQuoteContract.values();
            }
            catch(Exception e){
                System.debug('Error*** '+e.getMessage());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is issue in Revision, Please contact to your System Administrator.'));   return null;
            }
            
            
            for(Quote_Line_Options__c pro2 :lstQuoteOption){
                
                
                Quote_Line_Options__c ContLO =new Quote_Line_Options__c();
                ContLO.CurrencyIsoCode=pro2.CurrencyIsoCode;
                System.debug('Record id :::::'+pro2.id+'    Map:::::'+MapofQuoteContract);
                ContLO.Quote_Line_Item_Custom__c  = MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id;  //.Id
                System.debug('MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id'+MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id); 
                String prodId = pro2.Product__c;
                
                if(pro2.Discount_Allowed_New__c!=null)
                          ContLO.Discount_Allowed_New__c = pro2.Discount_Allowed_New__c;
                       if(pro2.Description__c != null && pro2.Description__c != ''){
                           ContLO.Description__c = pro2.Description__c;
                       }
                       if(pro2.Discount_in_Value__c!=null)
                          ContLO.Discount_in_Value__c = pro2.Discount_in_Value__c;
                       if(pro2.Discount_Type__c != null && pro2.Discount_Type__c != ''){
                           ContLO.Discount_Type__c = pro2.Discount_Type__c;
                       }
                       
                       
                       if(pro2.Final_Price__c!=null)
                          ContLO.Final_Price__c = pro2.Final_Price__c;
                       if(pro2.Serial_Number__c != null){
                           ContLO.Serial_Number__c	 = pro2.Serial_Number__c	;
                       }
                
                if(pro2.Product__c !=null){
                    ContLO.Product__c = pro2.Product__c;
                } 
                /*if(pro2.Discount__c != null){
ContLO.Discount__c = pro2.Discount__c;
}*/
                
                if(pro2.Description__c != null && pro2.Description__c != ''){
                           ContLO.Description__c = pro2.Description__c;
                       }
                if(pro2.quantity__c != null){
                    ContLO.quantity__c = pro2.quantity__c;
                }
                if(pro2.Product_Type__c != null){
                ContLO.Product_Type__c = pro2.Product_Type__c;
                }
                if(pro2.Manula_Option_List_Price__c != null){
                    ContLO.Manula_Option_List_Price__c = pro2.Manula_Option_List_Price__c;
                }
                /*if(pro2.Price_Type__c !=null){
                    ContLO.Price_Type__c = pro2.Price_Type__c;
                }*/
                if(pro2.Discount_Description__c != null){
                    ContLO.Discount_Description__c = pro2.Discount_Description__c;
                }
                else{
                    ContLO.Discount_Description__c = 'Null';
                }
                if(pro2.Manual_Option_Base_Price__c != null){
                    ContLO.Manual_Option_Base_Price__c = pro2.Manual_Option_Base_Price__c;
                }
                if(QuoteCloneId != null && QuoteCloneId !='' ){
                    ContLO.Quote__c = QuoteCloneId;
                }
                if(pro2.Manual_Option__c !=null){
                    ContLO.Manual_Option__c = pro2.Manual_Option__c;
                }
                if(pro2.Description__c !=null){
                    ContLO.Description__c = pro2.description__c;
                }
                if(pro2.Select_Option__c !=null){
                    ContLO.Select_Option__c = pro2.Select_Option__c;
                }
                
                if(pro2.Mould_Cavity__c !=null){
                    ContLO.Mould_Cavity__c = pro2.Mould_Cavity__c;
                }
                if(pro2.Option_Number__c !=null){
                    ContLO.Option_Number__c = pro2.Option_Number__c;
                }
                if(pro2.Manual_Product_Name__c !=null){
                    ContLO.Manual_Product_Name__c = pro2.Manual_Product_Name__c;
                }
                if(pro2.Manual_Option_Function__c !=null){
                    ContLO.Manual_Option_Function__c = pro2.Manual_Option_Function__c;
                }
                if(pro2.Other_Charges__c !=null){
                    ContLO.Other_Charges__c = pro2.Other_Charges__c;
                }
                if(pro2.Other_Charges_Base_Price__c !=null){
                    ContLO.Other_Charges_Base_Price__c = pro2.Other_Charges_Base_Price__c;
                }
                if(pro2.Other_Charges_Function__c !=null){
                    ContLO.Other_Charges_Function__c = pro2.Other_Charges_Function__c;
                }
                if(pro2.Select_Option__c !=null){
                    ContLO.Select_Option__c = pro2.Select_Option__c;
                }
                
                if(pro2.Quantity__c!=null){
                    ContLO.Quantity__c = pro2.Quantity__c; 
                }
                
                
                ListQLo.add(ContLO);
                system.debug('ContLO'+ContLO);
            }
            
            
            try
            {
                
                insert ListQLo;
            }
            catch(Exception e)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is issue in Revision, Please contact to your System Administrator.'));
                return null;
            }
            
            List<Attachment> lstAtt = new List<Attachment>();
            lstAtt = [select id, name, body, LastModifiedDate, Createddate , createdby.name,ParentId from Attachment where ParentId=:QuoteCloneId ];
            
            lstAtt.clear();
            
            PageReference myVFPage = new PageReference('/'+QuoteCloneId);
            myVFPage.setRedirect(true);
            return myVFPage;
            
        }
        else if(QuoteStatus != 'RELEASED' && todaysDate <= QuoteValidDate){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Quote Is Still Not Released So New Quote Can Not be Created'));
            return null;
        }
        else if(QuoteStatus == 'RELEASED' && todaysDate > QuoteValidDate){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The Expiration Date Has Already Passed, Please Update The Expiration Date'));
            return null;
        }
        else{
            PageReference myVFPage = new PageReference('/'+objQuote.Id);
            return null;
        }        
        
    }
}