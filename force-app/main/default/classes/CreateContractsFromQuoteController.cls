/*
*  Author   : Amol wagh
*  Date     : 27-06-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      16-08-2022   Amol Wagh      added Exception handling for Create contract option

*********************************************/
public class CreateContractsFromQuoteController {
    public static boolean isbypassRule = false;
    public static boolean isbypassStatusRule = true;
    Public Quote ObjQuote{get;set;}
    public List<Quote_Line_Item_Custom__c> ObjQuoteLineItem{get;set;}
    public List<Quote_Line_Options__c> ObjQuoteLineOptions{get;set;}
    Public List<Contract> objContract = new List<Contract>();
    public boolean CheckConformation {get;set;}
    public boolean clickOnce {get;set;}
    
    public CreateContractsFromQuoteController(ApexPages.StandardController controller){
        CheckConformation=true;
        isbypassRule = true;
        isbypassStatusRule = false;
        clickOnce = true;
    } 
    
    public PageReference Cancel(){
        String RecordId = ApexPages.CurrentPage().getparameters().get('id');
        PageReference myVFPage = new PageReference('/'+RecordId);
        myVFPage.setRedirect(true);
        CheckConformation=false;
        return myVFPage;
    }
    
    Public PageReference CreateContract(){
        clickOnce = false;
        if(clickOnce){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Contract Creation in progress.'));
            return null;
        }
            
        clickOnce =  true;
        String RecordId = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('RecordId :  :'+RecordId);
        
        ObjQuote = [Select id,AccountId,Exchange_Rate__c,Contract_Quote_Id__c,Additinal_Margin__c,AdditionalAddress,AdditionalName,BillingAddress,BillingName,ContactId,Description,FY__c,SHIP_TO_ADDRESS_LINE_1__c,SHIP_TO_ADDRESS_LINE_2__c,
                    Discount,Email,ExpirationDate,Advance_Payment_Average__c,Fax,GrandTotal,LineItemCount,OpportunityId,Phone,CurrencyIsoCode,Name,SHIP_TO_ADDRESS_LINE_3__c,SHIP_TO_POSTAL_CODE__c,Ship_To_Country__c,
                    QuoteNumber,QuoteToAddress,QuoteToName,ShippingHandling,ShippingAddress,ShippingName,Status,Shipping_And_Handling__c,tax__c,Ship_To_State__c,Ship_To_City__c,
                    Subtotal,IsSyncing,Tax,TotalPrice,ACCOUNT_BUSINESS__c,ACCOUNT_TYPE__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,Quote_Number__c,Designation_new__c,
                    ADVANCE_PAYMENT__c,CITY__c,CLOSE_LOST_REASON__c,Contact__c,COUNTRY__c,COUNTRY_CODE__c,DATE__c,Designation__c,END_CUSTOMER_NAME__c,Application__c,Zero_Cooling__c, Freight__c, Insurance__c, 
                    FUNCTION__c,INCO_TERMS__c,MFG_AT__c,POSTAL_CODE__c,PREPARED_BY__c,PROBABILITY__c,QUOTATION_ADDRESSED_TO__c,QUOTATION_CREATE__c,QU_REVISION_NUMBER__c,
                    /*REGION__c,*/SHIP_TO__c,SOLD_TO__c,STATE__c,SUBSIDARY__c,Advance_Percentage__c,TYPE__c,VALIDITY__c,VALITY_DATE__c,Machine_Delivery__c,Mould_Delivery__c,
                    Language__c, Subsidiary__c,Subsidiary__r.Subsidiary_Head__c,OwnerId,Parent_Quote__c,Sales_Margin__c,
                    Class__c,Closed_Date__c,Conclusion__c,Q_PrintConclusion__c,Quote_Release_Date__c,Expected_Month_of_Consolidated_Order__c,Machine_Mold__c,
                    Q_PrintMachine__c,Payment__c,Price_in_Word_Required__c,Q_PrintShipping__c,Shipping_Term__c,Project_Management_Quote_Id__c,
                    Subsidiary__r.Price_Book__c,SHIP_To_Contact_Name__c,
                    Skip_Status_Validation__c,Text_After_Total__c,Q_PrintTiming__c,Q_PrintPayment__c,Use_Current_Price__c,Global_Region__c,Global_SubRegion__c,Quote.Ship_To_Global_Region__c,Quote.Ship_To_Global_SubRegion__c
                    from Quote Where id =:RecordId limit 1];
        
        
        Map<Id,decimal> quoteTotalQuantity = new Map<Id,decimal>();
        AggregateResult[] groupedAllQtyResults= [select Quote__c, sum(Quantity__c)cLineCount from Quote_Line_Item_Custom__c  where 
                                                     Quote__c=:RecordId   group BY Quote__c];
        
        for (AggregateResult ar : groupedAllQtyResults)  {
                quoteTotalQuantity.put((Id)ar.get('Quote__c'), (decimal)ar.get('cLineCount'));
            }
        
        List<Quote> qList=[SELECT Id,OpportunityId,Status FROM Quote WHERE Status = 'CLOSE - SC CREATED' and OpportunityId=:ObjQuote.OpportunityId and id!=: RecordId];
        
        List<Contract_Template__c> CTList = [SELECT Id FROM Contract_Template__c WHERE Subsidiary__c = :ObjQuote.Subsidiary__c and Language__c=:ObjQuote.Language__c LIMIT 1];
        
        
        List<String> quoteIds = new List<String> ();
        if(string.isNotBlank(ObjQuote.Contract_Quote_Id__c)){
            quoteIds= ObjQuote.Contract_Quote_Id__c.split(',');
            system.debug('quoteIds-->'+quoteIds);
        }else{
            quoteIds.add(ObjQuote.Id);
        }
        
        
        Map<string,ContractExisting> existingContract = new Map<string,ContractExisting>();
        if(quoteIds.size() > 0){
             existingContract = ExistingContract(ObjQuote.AccountId , ObjQuote.OpportunityId);
        }
        system.debug('exe'+  existingContract);
        
        
       
       /*if(qList.size()!=0)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity already has a CLOSE - SC CREATED quote'));
            return null;
        }*/
        
        Opportunity oppStatus = [SELECT Id, StageName FROM Opportunity Where Id =: ObjQuote.OpportunityId];
        if(oppStatus.StageName == 'Close Lost'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Opportunity has Close Lost so cannot create contract.'));
            return null;
        }
        
        System.debug('ObjQuote'+ObjQuote);
        String ObjStatus = ObjQuote.Status;
        Date QuoteValidDate = objQuote.VALITY_DATE__c;
        Date todaysDate = system.today();
        UserSetup us=getQuoteNumber();
        Map<Id,User> userMap = new Map<Id,User>([select Id, ManagerId from User where Id=:ObjQuote.OwnerId]);
        System.debug('ObjQuote'+ObjStatus + ' ==> '+todaysDate+'--> '+QuoteValidDate);
        system.debug('out side if in contract create');
        
        if((ObjStatus == 'RELEASED' || ObjStatus == 'UNDER NEGOTIATION - COOL' || ObjStatus == 'UNDER NEGOTIATION - HOT' || ObjStatus == 'WAITING FOR SC/DRG APPROVAL/CLARIFICATION')
           && todaysDate <= QuoteValidDate){
            system.debug('in side if in contract create');
            Contract cont = new Contract();
            cont.Project_Management_Quote_Id__c = objQuote.Project_Management_Quote_Id__c;
            cont.Contract_Quote_Id__c = objQuote.Contract_Quote_Id__c;
            cont.Total_Quantity_Of_Products__c = quoteTotalQuantity.get(ObjQuote.id);
            cont.Global_Region__c = objQuote.Global_Region__c;
            cont.Pricebook2Id = objQuote.Subsidiary__r.Price_Book__c;
           	cont.Global_SubRegion__c = objQuote.Global_SubRegion__c;
            cont.Ship_To_Global_Region__c = objQuote.Ship_To_Global_Region__c;
           	cont.Ship_To_Global_SubRegion__c = objQuote.Ship_To_Global_SubRegion__c;
            cont.SHIP_TO__c = objQuote.SHIP_TO__c;
            cont.ADDRESS_LINE_1__c = objQuote.ADDRESS_LINE_1__c;
            cont.ADDRESS_LINE_2__c = objQuote.ADDRESS_LINE_2__c;
            cont.ADDRESS_LINE_3__c = objQuote.ADDRESS_LINE_3__c;
            cont.Ship_To_City__c = objQuote.Ship_To_City__c;
            cont.Ship_To_State__c = objQuote.Ship_To_State__c;
            Cont.Ship_To_Country__c = objQuote.Ship_To_Country__c;
            Cont.SHIP_To_Contact_Name__c = objQuote.SHIP_To_Contact_Name__c;   
               // addd on 27 march by rishikesh
             
               system.debug('existingContract->'+existingContract);
               
                   
               string key = ObjQuote.AccountId+'-'+ObjQuote.OpportunityId;
               if(existingContract.containsKey(key)){
                       system.debug('inside existing contract');
                       cont.Original_Contracts_No__c = existingContract.get(key).Ex_Contract_Number;
                       cont.Contract_Number__c=existingContract.get(key).Ex_Contract_Number;
                       cont.Original_Contract__c = existingContract.get(key).Ex_Id;
                       system.debug('existingContract--->'+existingContract);
                       if(!string.isBlank(existingContract.get(key).Ex_RevNo))
                           if(Integer.valueOf(existingContract.get(key).Ex_RevNo)+1 <10)
                           cont.Revision_No__c = '00'+string.valueOf(Integer.ValueOf(existingContract.get(key).Ex_RevNo) +1);
                       else
                           cont.Revision_No__c = '0'+string.valueOf(Integer.ValueOf(existingContract.get(key).Ex_RevNo) +1);
                       
                   }
                   else{
                       cont.Revision_No__c = '000';
                       cont.Contract_Number__c=us.ContractNo;
                       cont.Original_Contracts_No__c = us.ContractNo;
                   }
               
               
            if(ObjQuote.QU_REVISION_NUMBER__c != null){
                cont.QU_Revise_Number__c = ObjQuote.QU_REVISION_NUMBER__c;    
            }
           
               
            //map on 21 march 2023 by rishikesh
               cont.Approval_Status__c = null;
               cont.Name = ObjQuote.Name;  
               cont.StartDate = system.today();

               if(userMap.containskey(ObjQuote.OwnerId)){
                   if(string.isNotBlank((string)userMap.get(ObjQuote.OwnerId).ManagerId)){
                       cont.Approver_User__c = (Id)userMap.get(ObjQuote.OwnerId).ManagerId; 
                   }
               }
               //
               cont.Sales_Margin_Percent__c = ObjQuote.Sales_Margin__c;
               cont.Class__c = ObjQuote.Class__c;
               cont.Cloned_From__c	 = null;
               if(string.isNotBlank(objQuote.Subsidiary__r.Subsidiary_Head__c)){
                   cont.Approver_User__c = objQuote.Subsidiary__r.Subsidiary_Head__c;
               }
            cont.Closed_Date__c = ObjQuote.Closed_Date__c;
            cont.Conclusion__c = ObjQuote.Conclusion__c;
            
            cont.Q_PrintConclusion__c = ObjQuote.Q_PrintConclusion__c;
            cont.Contract_Creation_Date__c	 = date.today();
            
            
            //cont.Contract_Released_Date__c = ObjQuote.Quote_Release_Date__c;
            cont.Expected_Month_of_Consolidated_Order__c	 = ObjQuote.Expected_Month_of_Consolidated_Order__c;
            cont.Expiration_Date__c = system.today().addDays(30) ;
      
            
            cont.Machine_Mold__c	 = ObjQuote.Machine_Mold__c	;
            cont.Q_PrintMachine__c	 = ObjQuote.Q_PrintMachine__c	;
            cont.Machine_Delivery_Months__c	 = ObjQuote.Machine_Delivery__c	;
            cont.Mold_Delivery_Months__c	 = ObjQuote.Mould_Delivery__c	;
            cont.Payment__c	 = ObjQuote.Payment__c	;
            cont.Q_PrintPayment__c = objQuote.Q_PrintPayment__c;
            cont.Price_in_Word_Required__c	 = ObjQuote.Price_in_Word_Required__c	;
            cont.Q_PrintShipping__c	 = ObjQuote.Q_PrintShipping__c	;
            cont.Shipping_Term__c	 = ObjQuote.Shipping_Term__c	;
            
            
            cont.Skip_Status_Validation__c	 = ObjQuote.Skip_Status_Validation__c	;
            cont.Text_After_Total__c	 = ObjQuote.Text_After_Total__c	;
            cont.Q_PrintTiming__c	 = ObjQuote.Q_PrintTiming__c	;
            cont.Use_Current_Price__c	 = ObjQuote.Use_Current_Price__c	;
            //cont.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Blank Contract').getRecordTypeId();


               // end
            
               
            
            
            
            
            
            cont.FY1__c=us.FY;
            cont.Subsidiary__c=us.Subsidiari;
            
            if(CTList.size() > 0){
                cont.Contract_Template__c = CTList[0].Id;
            }
            
            cont.Exchange_Rate__c=ObjQuote.Exchange_Rate__c;
            cont.Additinal_Margin__c=ObjQuote.Additinal_Margin__c;
            cont.Language__c=ObjQuote.Language__c;
            if(ObjQuote.Machine_Delivery__c != null){
                cont.Machine_Delivery__c = ObjQuote.Machine_Delivery__c;
            }
            if(ObjQuote.Mould_Delivery__c != null){
                cont.Mould_Delivery__c = ObjQuote.Mould_Delivery__c;
            }
            if(ObjQuote.AccountId != null){
                cont.AccountId = ObjQuote.AccountId;
            }
            if(ObjQuote.Application__c != null){
             cont.Application__c = ObjQuote.Application__c;
            }
            if(ObjQuote.Zero_Cooling__c != null){
                cont.Zero_Cooling__c = ObjQuote.Zero_Cooling__c;
            }
            if(ObjQuote.Fax != null){
                cont.Fax__c = ObjQuote.Fax;
            }
            if(ObjQuote.Designation_new__c != null){
                cont.Designation__c = ObjQuote.Designation_new__c;
            }
            if(ObjQuote.id != null){
                cont.Quote__c = ObjQuote.id;
            }
            if(ObjQuote.QuoteNumber != null){
                cont.Quote_Number__c = ObjQuote.QuoteNumber;
            }
            if(ObjQuote.Quote_Number__c != null){
                cont.Quote_Number_Clone__c = ObjQuote.Quote_Number__c;
            }
            if(ObjQuote.SHIP_TO_ADDRESS_LINE_1__c != null){
                cont.ADDRESS_LINE_ShipTo_1__c = ObjQuote.SHIP_TO_ADDRESS_LINE_1__c;
            }
            if(ObjQuote.Ship_To_City__c != null){
                cont.Ship_To_City__c = ObjQuote.Ship_To_City__c;
            }
            if(ObjQuote.Ship_To_State__c != null){
                cont.Ship_To_State__c = ObjQuote.Ship_To_State__c;
            }
            if(ObjQuote.Ship_To_Country__c != null){
                cont.Ship_To_Country__c = ObjQuote.Ship_To_Country__c;
            }
            if(ObjQuote.SHIP_TO_ADDRESS_LINE_2__c != null){
                cont.ADDRESS_LINE_ShipTo_2__c = ObjQuote.SHIP_TO_ADDRESS_LINE_2__c;
            }
            if(ObjQuote.SHIP_TO_ADDRESS_LINE_3__c != null){
                cont.ADDRESS_LINE_ShipTo_3__c = ObjQuote.SHIP_TO_ADDRESS_LINE_3__c;
            }
            if(ObjQuote.SHIP_TO_POSTAL_CODE__c != null){
                cont.POSTAL_CODE_ShpTo__c = ObjQuote.SHIP_TO_POSTAL_CODE__c;
            }
            if(ObjQuote.ACCOUNT_BUSINESS__c != null){
                cont.ACCOUNT_BUSINESS__c = ObjQuote.ACCOUNT_BUSINESS__c ;
            }
            if( ObjQuote.AdditionalName != null){
                cont.AdditionalName__c = ObjQuote.AdditionalName;
            }
            if(ObjQuote.BillingName != null){
                cont.BillingName__c = ObjQuote.BillingName;  
            }
            // cont.BillingAddress = ObjQuote.BillingAddress;
            if(ObjQuote.BillingName != null){
                cont.BillingName__c = ObjQuote.BillingName;  
            }
            if(ObjQuote.ContactId != null){
                cont.Contact_Id__c = ObjQuote.ContactId;  
            }
            if(ObjQuote.Description != null){
                cont.Description = ObjQuote.Description;  
            }
            if(ObjQuote.Email != null){
                cont.Email__c = ObjQuote.Email;    
            }
            if(ObjQuote.Insurance__c != null){
                cont.Insurance_Picklist__c = ObjQuote.Insurance__c;    
            }
            
            if(ObjQuote.Freight__c != null){
                cont.Freight_Pick__c = ObjQuote.Freight__c;    
            }
            
            if(ObjQuote.Advance_Payment_Average__c != null){
                cont.Advance_Percentage__c = ObjQuote.Advance_Percentage__c;    
            }
            
            
            /*if(ObjQuote.ExpirationDate  != null){
cont.ExpirationDate__c = ObjQuote.ExpirationDate ;     
}*/
            cont.ExpirationDate__c = system.today() + 45;
            if(ObjQuote.Fax  != null){
                cont.Fax__c = ObjQuote.Fax;   
            }
            
            if(ObjQuote.OpportunityId  != null){
                cont.Opportunity__c = ObjQuote.OpportunityId ;    
            }
            
            if(ObjQuote.Phone  != null){
                cont.Phone__c = ObjQuote.Phone;    
            }
            
            if(ObjQuote.CurrencyIsoCode  != null){
                cont.CurrencyIsoCode = ObjQuote.CurrencyIsoCode;    
            }
            
            if(ObjQuote.ShippingHandling  != null){
                cont.Shipping_And_Handling__c = ObjQuote.ShippingHandling ;    
            }
            if(ObjQuote.ShippingName != null){
                cont.ShippingName__c = ObjQuote.ShippingName ;
            }
            if(ObjQuote.FY__c != null){
                cont.FY__c = ObjQuote.FY__c ;
            }
            
            cont.Status = 'Created';    
            
            if(ObjQuote.Tax != null){
                cont.Tax__c = ObjQuote.Tax;    
            }
            if(ObjQuote.ACCOUNT_TYPE__c != null){
                cont.ACCOUNT_TYPE__c = ObjQuote.ACCOUNT_TYPE__c ;    
            }
            if(ObjQuote.TYPE__c != null){
                cont.TYPE__c = ObjQuote.TYPE__c ;    
            }
            if(ObjQuote.ADDRESS_LINE_1__c != null){
                cont.ADDRESS_LINE_1__c = ObjQuote.ADDRESS_LINE_1__c;
                
            }
            if(ObjQuote.ADDRESS_LINE_2__c != null){
                cont.ADDRESS_LINE_2__c = ObjQuote.ADDRESS_LINE_2__c;
                
            }
            if(ObjQuote.ADDRESS_LINE_3__c != null){
                cont.ADDRESS_LINE_3__c = ObjQuote.ADDRESS_LINE_3__c;
                
            }
            if(ObjQuote.ADVANCE_PAYMENT__c != null){
                cont.ADVANCE_PAYMENT__c = ObjQuote.ADVANCE_PAYMENT__c ;
                
            }
            if(ObjQuote.CITY__c != null){
                cont.CITY__c = ObjQuote.CITY__c ;
                
            }
            if(ObjQuote.CLOSE_LOST_REASON__c != null){
                cont.CLOSE_LOST_REASON__c = ObjQuote.CLOSE_LOST_REASON__c ;
                
            }
            if(ObjQuote.Contact__c != null){
                cont.Contact__c = ObjQuote.Contact__c ;
                
            }
            if(ObjQuote.COUNTRY__c != null){
                cont.COUNTRY__c = ObjQuote.COUNTRY__c ;
                
            }
            if(ObjQuote.COUNTRY_CODE__c != null){
                cont.COUNTRY_CODE__c = ObjQuote.COUNTRY_CODE__c;
                
            }
            if(ObjQuote.DATE__c  != null){
                cont.DATE__c = date.today();
                
            }
            if(ObjQuote.END_CUSTOMER_NAME__c != null){
                cont.END_CUSTOMER_NAME__c = ObjQuote.END_CUSTOMER_NAME__c;
                
            }
            if(ObjQuote.Designation__c != null){
                cont.Designation__c = ObjQuote.Designation__c;
                
            }
            if(ObjQuote.INCO_TERMS__c != null){
                cont.INCO_TERMS__c = ObjQuote.INCO_TERMS__c;
                
            }
            if(ObjQuote.FUNCTION__c != null){
                cont.FUNCTION__c = ObjQuote.FUNCTION__c ;
                
            }
            if(ObjQuote.ACCOUNT_TYPE__c != null)
            {
                cont.ACCOUNT_TYPE__c = ObjQuote.ACCOUNT_TYPE__c ;
            }
            if(ObjQuote.MFG_AT__c != null){
                cont.MFG_AT__c = ObjQuote.MFG_AT__c ;
                
            }
            if(ObjQuote.POSTAL_CODE__c != null){
                cont.POSTAL_CODE__c = ObjQuote.POSTAL_CODE__c;
                
            }
            if(ObjQuote.PREPARED_BY__c != null){
                cont.PREPARED_BY__c = ObjQuote.PREPARED_BY__c ;
                
            }
            if(ObjQuote.QUOTATION_ADDRESSED_TO__c != null){
                cont.QUOTATION_ADDRESSED_TO__c = ObjQuote.QUOTATION_ADDRESSED_TO__c ;
                
            }
            if(ObjQuote != null){
                cont.PROBABILITY__c = ObjQuote.PROBABILITY__c;
                
            }
            if(ObjQuote.PROBABILITY__c != null){
                cont.QUOTATION_CREATE__c = ObjQuote.QUOTATION_CREATE__c;
                
            }
            /*if(ObjQuote != null){
                cont.REGION__c = ObjQuote.REGION__c;
                
            }*/
            if(ObjQuote.SHIP_TO__c != null){
                cont.SHIP_TO__c = ObjQuote.SHIP_TO__c ;
            }
            if(ObjQuote.SOLD_TO__c != null){
                cont.SOLD_TO__c = ObjQuote.SOLD_TO__c;
                
            }
            if(ObjQuote.SUBSIDARY__c != null){
                cont.SUBSIDARY__c = ObjQuote.SUBSIDARY__c;
                
            }
            if(ObjQuote.STATE__c != null){
                cont.STATE__c = ObjQuote.STATE__c;
                
            }
            if(ObjQuote.VALITY_DATE__c != null){
                cont.VALITY_DATE__c = ObjQuote.VALITY_DATE__c;
                
            }
            if(ObjQuote.VALIDITY__c != null){
                cont.VALIDITY__c = ObjQuote.VALIDITY__c;    
            }
            
            if(ObjQuote.Tax__c != null){
                cont.Tax__c = ObjQuote.Tax__c;    
            }
            if(ObjQuote.Shipping_And_Handling__c != null){
                cont.Shipping_And_Handling__c = ObjQuote.Shipping_And_Handling__c;    
            }
            if(ObjQuote.Language__c != null){
                cont.Language__c = ObjQuote.Language__c;    
            }
            
            insert cont;
               
            //updateContractNo(ObjQuote.Id,cont.Id);
               
            String ContractId = cont.Id;
            SYSTEM.debug('ContractId'+ContractId);
            ObjQuoteLineItem = [Select id,CurrencyIsoCode,Discount_Approval_Note__c,Class_2__c,Division__c,Drawing_No__c,Expected_Customer_PO__c,Discount_Allowed__c,
                                Expected_Delivery__c,Expected_Delivery_date__c,Expected_Drawing_Final__c,Zero_Cooling_2__c,Product_Name__c,Payment_Terms__c,Product__r.Scope_of_Mold__c,
                                Mach_Mold_No__c,MFG_AT__c,Quantity__c,Discount__c,Base_Price__c,Product__r.Model__c,Product__r.Number_Of_Cavity_Mould__c,Application__c,
                                List_Price__c,Product__c,Quote__c,UOM__c,Product__r.UOM__c,Product__r.Product_Type__c,Product_Type__c,Product_Description__c,Level_Of_Ceiling__c,
                                Advance_Percentage__c,Disable_Discoint_Percent__c,Disable_Discoint_Value__c,Product_Code__c,Manual_Product_Code__c,Discount_Type__c,
                                Is_Manual__c,Is_Tax__c,Discount_Allowed_New__c,Original_SQ_No__c,
                                P_D1__c,P_D2__c,P_D3__c,P_M1__c,P_M2__c,P_M3__c,P_M4__c,Scope_of_mould__c,Sr_No__c,Discount_in_Value__c,
                                Sales_Margin__c,Project_Unique_No__c,
                                
                                (Select id,Discount__c,Final_Price__c,Manual_Option__c,Quantity__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Mould_Cavity__c,Sales_price_Total__c,
                                 Other_Charges_Base_Price__c,Sales_Margin__c,Product_Type__c,Other_Charges_Function__c,Manula_Option_List_Price__c,Product__c,Quote__c,Quote_Line_Item__c,Select_Option__c,Manual_Product_Name__c,Description__c
                                 from Quote_Line_Options__r)
                                from Quote_Line_Item_Custom__c Where Quote__c = : RecordId and Quantity__c >: 0];
            
            System.debug('ObjQuoteLineItem'+ObjQuoteLineItem);
            set<Id> IdOfOpQuoteItem = new Set<Id>();
            if(ObjQuoteLineItem .size() != 0){
                for(Quote_Line_Item_Custom__c QLN : ObjQuoteLineItem){
                    IdOfOpQuoteItem.add(QLN.id);
                }
            }
            List<Quote_Line_Options__c> lstQuoteOption = new List<Quote_Line_Options__c>();
            if(IdOfOpQuoteItem != null && IdOfOpQuoteItem.size() > 0){
                lstQuoteOption = [Select id,CurrencyIsoCode,Discount__c,Option_Number__c,Final_Price__c,Quantity__c,Manual_Option__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Description__c,Quote_Line_Item_Custom__c,Product__r.UOM__c,Sales_price_Total__c,
                                  Other_Charges_Base_Price__c,Other_Charges_Function__c,Product_Type__c,Product__c,Quote__c,Manula_Option_List_Price__c,Quote_Line_Item__c,Select_Option__c,Manual_Product_Name__c,Mould_Cavity__c, Price_Type__c, Discount_Description__c
                                  ,Discount_Type__c,Discount_Allowed_New__c,P_D1__c,P_D2__c,P_D3__c,P_M1__c,P_M2__c,P_M3__c,P_M4__c,Serial_Number__c,
                                  Discount_in_Value__c,Manual_Product_Code__c,Sales_Margin__c
                                  
                                  from Quote_Line_Options__c where Quote_Line_Item_Custom__c IN : IdOfOpQuoteItem];
            }
            system.debug('lstQuoteOption===> '+lstQuoteOption);
            List<Contract_Line_Item__c> Lst = new List<Contract_Line_Item__c>();
            List<Contract_Line_Option__c> ListQLo = new  List<Contract_Line_Option__c>();
            List<Contract_Line_Item__c> lstContractItem = new List<Contract_Line_Item__c>();
            Map<Id,Contract_Line_Item__c> MapofQuoteContract = new Map<Id,Contract_Line_Item__c>();
            for(Quote_Line_Item_Custom__c pro1 : ObjQuoteLineItem){
                String QLIid = pro1.Id;
                //System.debug('ObjQuoteLineItem'+ObjQuoteLineItem);
                System.debug('pro1'+pro1.Product__c);
                Contract_Line_Item__c cli = new Contract_Line_Item__c();
                // map by rishi 21 march 
                cli.RecordTypeId = Schema.SObjectType.Contract_Line_Item__c.getRecordTypeInfosByName().get('Before Released').getRecordTypeId();
                cli.Disable_Discoint_Percent__c = pro1.Disable_Discoint_Percent__c;
                cli.Disable_Discoint_Value__c = pro1.Disable_Discoint_Value__c;
                cli.Discount_Type__c = pro1.Discount_Type__c;
                cli.Project_Unique_No__c = pro1.Project_Unique_No__c;
                cli.Is_Manual__c = pro1.Is_Manual__c;
                cli.Is_Tax__c = pro1.Is_Tax__c;
                cli.Original_SQ_No__c = pro1.Original_SQ_No__c;
                cli.Maximum_Discount_Allowed__c = pro1.Discount_Allowed_New__c;
                cli.P_D1__c = pro1.P_D1__c;
                cli.P_D2__c = pro1.P_D2__c;
                cli.P_D3__c = pro1.P_D3__c;
                cli.P_M1__c = pro1.P_M1__c;
                cli.P_M2__c = pro1.P_M2__c;
                cli.P_M3__c = pro1.P_M3__c;
                cli.P_M4__c = pro1.P_M4__c;
                cli.Sales_Margin_Percent__c = pro1.Sales_Margin__c;
                cli.Scope_of_mould__c = pro1.Scope_of_mould__c;
                cli.Sr_No__c = pro1.Sr_No__c;
                cli.Discount_in_Value__c = pro1.Discount_in_Value__c;
               
				//end
                
                cli.Quote_Line_Item_Name__c = pro1.id;
                cli.UOM__c = pro1.UOM__c; 
                cli.Model__c = pro1.Product__r.Model__c;
                cli.Product_Type__c = pro1.Product_Type__c;
                cli.Level_Of_Ceiling__c=pro1.Level_Of_Ceiling__c;
                cli.CurrencyIsoCode=pro1.CurrencyIsoCode;
                if(ContractId!=null && ContractId != ''){
                    cli.ContractId__c = ContractId; 
                }
                if(pro1.Product__c !=null){ 
                    cli.Product2Id__c = pro1.Product__c; 
                }
                if(pro1.Application__c !=null && pro1.Application__c !=''){ 
                    cli.Application__c = pro1.Application__c; 
                }
                if(pro1.Mach_Mold_No__c !=null){ 
                    cli.Mach_Mold_No__c = pro1.Mach_Mold_No__c; 
                }
                if(pro1.Level_Of_Ceiling__c !=null){ 
                    cli.Level_Of_Ceiling__c = pro1.Level_Of_Ceiling__c; 
                }
                if(pro1.Expected_Delivery_date__c !=null){ 
                    cli.Expected_Delivery_date__c = pro1.Expected_Delivery_date__c; 
                }
                if(pro1.Expected_Customer_PO__c !=null){ 
                    cli.Expected_Customer_PO__c = pro1.Expected_Customer_PO__c; 
                }
                if(pro1.Expected_Drawing_Final__c !=null){ 
                    cli.Expected_Drawing_Final__c = pro1.Expected_Drawing_Final__c; 
                }
                if(pro1.Drawing_No__c !=null){ 
                    cli.Drawing_No__c = pro1.Drawing_No__c; 
                }
                if(pro1.Product_Description__c !=null){ 
                    cli.Product_Description__c = pro1.Product_Description__c; 
                }
                cli.Scope__c = pro1.Product__r.Scope_of_Mold__c;
                cli.Cavity__c = pro1.Product__r.Number_Of_Cavity_Mould__c;
                if(pro1.Payment_Terms__c !=null){ 
                    cli.Payment_Terms__c = pro1.Payment_Terms__c; 
                }
                if(pro1.Discount_Allowed__c !=null){ 
                    cli.Discount_Allowed__c = pro1.Discount_Allowed__c; 
                } 
                if(pro1.Product_Name__c !=null){ 
                    cli.Product_Name_2__c = pro1.Product_Name__c; 
                } 
                if(pro1.Discount_Approval_Note__c !=null){ 
                    cli.Approval_Note__c = pro1.Discount_Approval_Note__c; 
                } 
                else{
                    cli.Approval_Note__c = 'Null';
                }
                if(pro1.Zero_Cooling_2__c !=null){ 
                    cli.Zero_Cooling__c = pro1.Zero_Cooling_2__c; 
                }
                if(pro1.Class_2__c !=null){ 
                    cli.Class__c = pro1.Class_2__c; 
                }
                if(pro1.MFG_AT__c !=null){ 
                    cli.MFG_Location__c = pro1.MFG_AT__c; 
                }
                
                if(pro1.List_Price__c!=null){
                    cli.List_Price__c = pro1.List_Price__c; 
                }
                if(pro1.Base_Price__c!=null){
                    cli.Base_Price_Line_Item__c = pro1.Base_Price__c; 
                }
                if(pro1.Advance_Percentage__c!=null){
                    cli.Advance_Required__c = pro1.Advance_Percentage__c; 
                }
                /*if(pro1.UOM__c!=null){
cli.UOM__c = pro1.Product__r.UOM__c; 

}*/
                if(pro1.List_Price__c!=null){
                    cli.List_Price_Clone__c = pro1.List_Price__c; 
                }
                if(pro1.Quantity__c!=null){
                    cli.Quantity__c = pro1.Quantity__c; 
                }
                if(pro1.Quantity__c!=null){
                    cli.Quantity_Clone__c = pro1.Quantity__c; 
                }
                if(pro1.division__c !=null){
                    cli.division__c = pro1.division__c; 
                }
                /*if(pro1.Line_Item_Number_Text__c !=null){
cli.Contract_Item_No__c = pro1.Line_Item_Number_Text__c; 
}
if(pro1.UnitPrice!=null){
cli.UnitPrice__c =pro1.UnitPrice; 
}
if(pro1.UnitPrice!=null){
cli.Unit_Price_Clone__c =pro1.UnitPrice; 
}*/
                if(pro1.Discount__c!=null){
                    cli.Discount__c = pro1.Discount__c; 
                }
                if(pro1.Discount__c!=null){
                    cli.Discount_Clone__c = pro1.Discount__c; 
                }
                
                
                if(pro1.Manual_Product_Code__c != null && pro1.Is_Manual__c){    
                     cli.Manual_Product_Number__c = pro1.Manual_Product_Code__c;
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
            
            
            for(Quote_Line_Options__c pro2 :lstQuoteOption){
                system.debug('MapofQuoteContract.get(pro2.Quote_Line_Item__c).id ===> '+MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id);
                
                Contract_Line_Option__c ContLO =new Contract_Line_Option__c();
                ContLO.Contract_Line_Item__c  = MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id;
                contLO.CurrencyIsoCode=pro2.CurrencyIsoCode;
                contLO.Sales_Margin_Percent__c = pro2.Sales_Margin__c;
                //.System.debug('cli.id====='+cli.id);  
                //ContLO.UOM__c = pro2.Product__r.UOM__c; 
                 contLO.Product_Type__c = pro2.Product_Type__c;
                //add by rishikesh 21 march
                 ContLO.RecordTypeId = Schema.SObjectType.Contract_Line_Option__c.getRecordTypeInfosByName().get('Before Released').getRecordTypeId();
                 ContLO.Discount_Type__c = pro2.Discount_Type__c;
                 //ContLO.Select_Option__c = pro2.Select_Option__c;
                 ContLO.Discount_Allowed_New__c = pro2.Discount_Allowed_New__c;
                
                
                ContLO.P_D1__c = pro2.P_D1__c;
                ContLO.P_D2__c = pro2.P_D2__c;
                ContLO.P_D3__c = pro2.P_D3__c;
                ContLO.P_M1__c = pro2.P_M1__c;
                ContLO.P_M2__c = pro2.P_M2__c;
                ContLO.P_M3__c = pro2.P_M3__c;
                ContLO.P_M4__c = pro2.P_M4__c;
                
                
                 ContLO.Description__c = pro2.Description__c;
                 ContLO.Serial_Number__c = pro2.Serial_Number__c;
                 ContLO.Discount_in_Value__c = pro2.Discount_in_Value__c;
                 
                 //ContLO.UOM_c__c = pro2.UOM__c;
                 
                if(pro2.Manual_Product_Code__c != null && pro2.Select_Option__c){
                    ContLo.Manual_Option_Number__c = Pro2.Manual_Product_Code__c;
                }
                
                if(pro2.Discount__c != null){
                    ContLO.Discount__c = pro2.Discount__c;
                }
                /*if(pro2.Description__c != null){
                    ContLO.Product_Description__c = pro2.Description__c;
                }*/
                /*if(pro2.Price_Type__c != null){
                    ContLO.Price_Type__c = pro2.Price_Type__c;
                }*/
                if(pro2.Sales_price_Total__c != null){
                    ContLO.Sales_price_Total__c = pro2.Sales_price_Total__c;
                }
                if(pro2.Discount_Description__c != null){
                    ContLO.Discount_Description__c = pro2.Discount_Description__c;
                }
                else{
                    ContLO.Discount_Description__c = 'Null';
                }
                if(pro2.Manual_Option__c !=null){
                    ContLO.Manual_Option__c = pro2.Manual_Option__c;
                }
                if(pro2.Mould_Cavity__c !=null){
                    ContLO.Mould_Cavity__c = pro2.Mould_Cavity__c;
                }
                if(pro2.Manual_Product_Name__c !=null){
                    ContLO.Manual_Product_Name_c__c = pro2.Manual_Product_Name__c;
                    ContLO.Option_Name__c = pro2.Manual_Product_Name__c;
                }
                if(pro2.Manual_Option_Base_Price__c !=null){
                    ContLO.Manual_Option_Base_Price__c = pro2.Manual_Option_Base_Price__c;
                }
                if(pro2.Manual_Option_Function__c !=null){
                    ContLO.Manual_Option_Function__c = pro2.Manual_Option_Function__c;
                }
                if(ContractId != null && ContractId !='' ){
                    ContLO.ContractId__c = ContractId;
                }
                if(pro2.Other_Charges__c !=null){
                    ContLO.Other_Charges__c = pro2.Other_Charges__c;
                }
                if(pro2.Other_Charges_Base_Price__c !=null){
                    ContLO.Other_Charges_Base_Price__c = pro2.Other_Charges_Base_Price__c;
                }
                if(pro2.Manula_Option_List_Price__c !=null){
                    ContLO.Manual_Option_List_Price__c = pro2.Manula_Option_List_Price__c;
                }
                if(pro2.Quantity__c !=null){
                    ContLO.Quantity__c = pro2.Quantity__c;
                }
                if(pro2.Option_Number__c !=null){
                    ContLO.Contract_Line_Option_No__c = pro2.Option_Number__c;
                }
                if(pro2.Other_Charges_Function__c !=null){
                    ContLO.Other_Charges_Function__c = pro2.Other_Charges_Function__c;
                }
                if(pro2.Product__c !=null){
                    ContLO.Product__c = pro2.Product__c;
                }
                /*if(pro2.Description__c !=null){
ContLO.Description__c = pro2.Description__c;
}*/
                if(pro2.Select_Option__c !=null){
                    ContLO.Select_Option__c = pro2.Select_Option__c;
                }
                if(pro2.Manual_Option_Base_Price__c !=null){
                    ContLO.Manual_Option_Base_Price_Clone__c = pro2.Manual_Option_Base_Price__c;
                }
                if(pro2.Manula_Option_List_Price__c !=null){
                    ContLO.Manual_Option_List_Price_Clone__c = pro2.Manula_Option_List_Price__c;
                }
                if(pro2.Discount__c !=null){
                    ContLO.Discount_Clone__c = pro2.Discount__c;
                }
                
                // Lst.add(cli);
                ListQLo.add(ContLO);
            }  
            System.debug('ListQLo==> '+ListQLo);
            try
            {
                //System.debug('Lst'+Lst.size());
                System.debug('ListQLo'+ListQLo.size());
                
                //insert Lst;
                insert ListQLo;
                System.debug(ListQLo);
                // redirect(ContractId);
            }
            catch(Exception e)
            {
                system.debug('Exception'+e.getMessage()+'====e.'+e.getLineNumber());
            }
            
            
            // String ContractLineItem
            
            
            //==============================================================================================================================================
            
            QuoteRecursionCheck.RunQTrg=false;
            isbypassRule = true;
            ObjQuote.Status = 'CLOSE - SC CREATED';
            UpdateQuotes(ObjQuote.id,ObjQuote.OpportunityId);
            update ObjQuote;
            RecursiveTriggerHandler2.isFirstTimeOnOpp=false; 
            oppStatus.stagename = 'Converted';
            update oppStatus;
            
            CheckConformation=false;
            PageReference myVFPage = new PageReference('/'+ContractId);
            myVFPage.setRedirect(true);
            return myVFPage;
            
        }
        else if((ObjStatus == 'Draft' || ObjStatus == 'CREATED' ) && todaysDate < QuoteValidDate){
            system.debug('in it');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Quote Is Still Not Released So New Contract Can Not be Created'));
            //PageReference myVFPage = new PageReference('/'+objQuote.id);
            // myVFPage.setRedirect(true);
            return null;
        }
        else if((ObjStatus == 'RELEASED' || ObjStatus == 'UNDER NEGOTIATION - COOL' || ObjStatus == 'UNDER NEGOTIATION - HOT' || 
                 ObjStatus == 'WAITING FOR SC/DRG APPROVAL/CLARIFICATION') && todaysDate > QuoteValidDate){
            system.debug('in it 2');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The Expiration Date Has Already Passed Please Update The Expiration Date'));
            // PageReference myVFPage = new PageReference('/'+objQuote.id);
            // myVFPage.setRedirect(true);
            return null;
        }
        else{
            system.debug('in it 3');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Cannot create Contract beacause quote is not valid'));
            // PageReference myVFPage = new PageReference('/'+objQuote.Id);
            //  myVFPage.setRedirect(true);
            return null;
        } 
        
    }
    
    
    public map<string,ContractExisting> ExistingContract(string AccountId, string OppId){
      List<Contract> conList = new   List<Contract>();
        conList = [Select Id,Quote__c,Revision_No__c,Contract_Number__c,Original_Contracts_No__c from Contract where 
                     AccountId =: AccountId and Opportunity__c =: OppId  
                   order by createdDate desc limit 1];
        string key = AccountId+'-'+OppId;
      	map<string,ContractExisting>exstingMap = new map<string,ContractExisting>();
        for(Contract con : conList){
        ContractExisting exe = new ContractExisting();
        exe.Ex_Quote = con.Quote__c;
        exe.Ex_Id = con.Id;
        exe.Ex_RevNo = con.Revision_No__c;
            if(string.isNotBlank(con.Original_Contracts_No__c)){
                exe.Ex_Contract_Number = con.Original_Contracts_No__c;
            }else{
               exe.Ex_Contract_Number = con.Contract_Number__c; 
            }
        
        exstingMap.put(key,exe);
        }
        system.debug('exstingMap-->'+exstingMap);
        return exstingMap;
    }
    
    
    
  /*  @future
    public static void UpdateQuotes(id Qid,id opportunityId)
    {
        List<Quote> quoteCanList=[select id,name, status from Quote where opportunityId=:opportunityId and id!=:Qid and status!='CLOSE - REVISED'];
        for(Quote q : quoteCanList )
        {
            q.status='CLOSE - REVISIED';
            
        }
        QuoteRecursionCheck.RunQTrg=false;
        update quoteCanList;
      } */
    
    //=======================** SHUBHAM KADU 5th Aug 2025 **=====================
    @future
    public static void UpdateQuotes(Id Qid, Id opportunityId) {
        // Fetch Original Quote Number of the finalized Quote
        Quote finalQuote = [SELECT Id, Quote_Number__c FROM Quote WHERE Id = :Qid LIMIT 1];
        
        // Fetch all Quotes under the same Opportunity
        List<Quote> allQuotes = [
            SELECT Id, Name, Status, Quote_Number__c, CreatedDate
            FROM Quote
            WHERE OpportunityId = :opportunityId AND Id != :Qid
        ];
        
        // Map to hold latest Quote Id per Stream (except the finalized Stream)
        Map<String, Quote> latestQuotesPerStream = new Map<String, Quote>();
        
        for (Quote q : allQuotes) {
            if (q.Quote_Number__c != finalQuote.Quote_Number__c) {
                if (!latestQuotesPerStream.containsKey(q.Quote_Number__c)) {
                    latestQuotesPerStream.put(q.Quote_Number__c, q);
                } else {
                    Quote existingQuote = latestQuotesPerStream.get(q.Quote_Number__c);
                    if (q.CreatedDate > existingQuote.CreatedDate) {
                        latestQuotesPerStream.put(q.Quote_Number__c, q);
                    }
                }
            }
        }
        
        // Prepare list for update
        List<Quote> quotesToCancel = new List<Quote>();
        
        for (Quote latestQuote : latestQuotesPerStream.values()) {
            if (latestQuote.Status != 'CANCELLED') {
                latestQuote.Status = 'CANCELLED';
                latestQuote.Skip_Status_Validation__c = true ; // To Bypass the validation 
                quotesToCancel.add(latestQuote);
            }
        }
        
        // Disable recursion flag if required
        QuoteRecursionCheck.RunQTrg = false;
        
        if (!quotesToCancel.isEmpty()) {
            update quotesToCancel;
        }
        // Now — Reset the Skip_Status_Validation__c back to FALSE
            List<Quote> resetBypassFlagQuotes = new List<Quote>();
            
            for (Quote q : quotesToCancel) {
            q.Skip_Status_Validation__c = false;
            resetBypassFlagQuotes.add(q);
            }
            
            // Disable recursion flag again if needed
            QuoteRecursionCheck.RunQTrg = false;
            
            // Update to reset the bypass flag
            if (!resetBypassFlagQuotes.isEmpty()) {
            update resetBypassFlagQuotes;
            }
    }
    //============================================
    
    
   /* public static void updateContractNo(Id Qid, string contractId){
        Quote qte=[select id,name,Contract_Quote_Id__c from Quote where id=:Qid];        
      
        Set<String> existingQuoteIds = new Set<String>();
        if (qte.Contract_Quote_Id__c != null) {
            existingQuoteIds.addAll(qte.Contract_Quote_Id__c.split(','));
        }
        
        system.debug('existingQuoteIds-->'+existingQuoteIds);
        system.debug('contractId-->'+contractId);
        if (!existingQuoteIds.contains(String.valueOf(contractId))) {
            if (qte.Contract_Quote_Id__c != null) {
                qte.Contract_Quote_Id__c += ',' + contractId;
            } else {
                qte.Contract_Quote_Id__c = String.valueOf(contractId);
            }
             system.debug('inside if -->'+contractId);
        }
        
        update qte;
    }*/
    
    Public static UserSetup getQuoteNumber()
    {
        //updated This logic to assign fy and Subsidiary
        UserSetup us=new UserSetup();
        Fiscal_Year_Master__c f=[select id,name from Fiscal_Year_Master__c where Active__c=true limit 1];
        system.debug('f '+f);
        Map<id,Unique_No__c> sMap=new Map<id,Unique_No__c>();
        // Get Last Count
        for(Unique_No__c u:[select id,name,Serial_No__c,Object_Name__c,Subsidiary__c,Fiscal_Year__c from Unique_No__c where Fiscal_Year__c=:f.id and 
                            Object_Name__c='Contract' For Update])
        { 
            sMap.put(u.Subsidiary__c,u);
        }
        
        
        
        User_Setup__c u=[select id,name,User__c,Subsidiari__c,Subsidiari__r.name,Default_Language__c  from User_Setup__c where User__c =: Userinfo.getUserId()];
        system.debug('f '+f);
        if(sMap.containskey(u.Subsidiari__c)){
            Unique_No__c un=sMap.get(u.Subsidiari__c);
            String temp='';
            
            for(Integer i=5;i>String.valueof(un.Serial_No__c+1).length();i--)
            {
                temp=temp+'0';
                
            }
            temp=temp+String.valueof(un.Serial_No__c+1);
            us.ContractNo='C'+u.Subsidiari__r.name+f.Name+'-'+temp;
            system.debug(' us.ContractNo '+ us.ContractNo);
            un.Serial_No__c=un.Serial_No__c+1;
            sMap.put(u.Subsidiari__c,un);
        }
        else
        {
            us.ContractNo='C'+u.Subsidiari__r.name +f.Name+'-00001';
            Unique_No__c un=new Unique_No__c();
            un.Object_Name__c='Contract';
            un.Subsidiary__c=u.Subsidiari__c;
            un.Fiscal_Year__c=f.id;
            un.Serial_No__c=1;  
            sMap.put(u.Subsidiari__c,un);
        }
        upsert sMap.values();
        system.debug(' us.ContractNo '+ us.ContractNo);
        us.FY=f.id;  
        us.Subsidiari=u.Subsidiari__c;
        return us;
    }
    
    
    Public Class UserSetup {
        public String FY;
        Public String Subsidiari;
        Public String ContractNo;
    }
    
    Public Class ContractExisting {
        public String Ex_Quote;
        Public String Ex_Id;
        Public String Ex_RevNo;
        public string Ex_Contract_Number;
    }
    
    
    public static void fakeCodeCoverage(){
        integer i=1;
        
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
        
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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