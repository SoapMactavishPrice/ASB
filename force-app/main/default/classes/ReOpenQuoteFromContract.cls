/*
Created Rishikesh Korade.
Desc: Used in VF Page to Revise the Quote.



----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      26-08-2024   Rishikesh Korade      Re-OpenQuote
*********************************************/
public class ReOpenQuoteFromContract {
    public static boolean isbypassRule = false;
    public static boolean isPassValidationRule = false;
    @AuraEnabled
    public static  string getProjectDetail(string CurrentId){
        Map<Id,Id> lmcMap = new Map<Id,Id>();
        
        Contract contLst = [Select id,Original_Contract__c,Master_Contract__c,Expiration_Date__c, ExpirationDate__c,PO_Number__c,PO_Date__c,
                            Total_Payment_Received_Roll_Up__c,Total_Advance_Required_In_Amount__c,Quote__r.Project_Management_Quote_Id__c,Quote__c,Opportunity__c
                            from Contract where id =: CurrentId];
        
        set<Id> conId = new set<Id>();
        conId.add(contLst.Id);
        
        List<String> quoteIds = new List<String> ();
        if(string.isNotBlank(contLst.Quote__r.Project_Management_Quote_Id__c)){
            quoteIds= contLst.Quote__r.Project_Management_Quote_Id__c.split(',');
            
        }else{
            quoteIds.add(contLst.Quote__c);
        }
        
        Map<string,List<ProjectManageMent__c>> exiProjectMap = new Map<string,List<ProjectManageMent__c>>();
        Map<string,List<ProjectManageMent__c>> exiProjectMap1 = new Map<string,List<ProjectManageMent__c>>();
        Map<string,ProjectManageMent__c> masterProjectMap1 = new Map<string,ProjectManageMent__c>();
        
        system.debug('conId'+conId.size());
        system.debug('quoteIds-->'+quoteIds);
        List<ProjectManageMent__c> pmList = [Select Id,Name, Contract__c,Sq_No__c,Contract_Line_Item__c,Contract_Line_Item__r.Product2Id__c,Project_Number__c,Phase__c,
                                             Contract_Line_Item__r.Product2Id__r.ProductCode,PRODUCT__c,Total_Sales_Price__c,Project_Unique_No__c,
                                             PO_No_to_HQ_3rd_Party__c,PO_issued_date_to_HQ_3rd_Party__c,Expected_Sales_Month__c,
                                             Contract_Line_Item__r.Original_SQ_No__c,Contract__r.Original_Contract__c,HQ_Sales_Liaison_email_id__c,AI_Sales_Liaison_email_id__c,Owner.Email
                                             from ProjectManageMent__c 
                                             where
                                             
                                             Opportunity_Name__c =:contLst.Opportunity__c
                                             //Quote_Name__c IN : quoteIds 
                                             and Phase__c !='Cancelled' 
                                             order by Contract_Line_Item__r.Original_SQ_No__c asc
                                             /*or Contract__c =:contLst.Master_Contract__c*/]; 
        system.debug('pmList-00->'+pmList.size());
        for(ProjectManageMent__c pm : pmList){
            string  key = pm.Project_Unique_No__c;//+'_'+pm.Contract_Line_Item__r.Original_SQ_No__c;
            if(exiProjectMap1.containsKey(key)){
                exiProjectMap1.get(key).add(pm);
            }
            else{
                exiProjectMap1.put(key,new List<ProjectManageMent__c>{pm});
            }
        }
        
        
        
        List<Contract_Line_Item__c> linelist = [SELECT Id, Name,Ceiling_Unit_Sales_Price_incl_Options__c,Product_Name__c,Project_Unique_No__c,ContractId__c,Project_Created__c,Product_Name_2__c,Product2Id__r.Name ,LineNumber__c,Quantity__c,CurrencyIsoCode,
                                                Product2Id__r.ProductCode,Product2Id__c,Sr_No__c,Original_SQ_No__c
                                                FROM Contract_Line_Item__c WHERE Quantity__c >: 0 and ContractId__c =:contLst.Id];
        
        List<wrapProject> wrapList = new List<wrapProject>();
        system.debug('exiProjectMap1 size-->'+exiProjectMap1);
        system.debug('linelist size--> linelist'+linelist.size());
        for(Contract_Line_Item__c cm :linelist ){
            string  key = cm.Project_Unique_No__c;//+'_';//+cm.Original_SQ_No__c;
            Integer Qty = 0;
            system.debug('key'+key);
                Qty  =  Integer.valueOf(cm.Quantity__c);  
                system.debug('Qty'+Qty);
                if(exiProjectMap1.containskey(key)){
                    for(ProjectManagement__c pm : exiProjectMap1.get(key) ){
                        Qty = Qty-1;
                        wrapProject wrp = new wrapProject();
                        wrp.p_currency = cm.CurrencyIsoCode;
                        wrp.key = key;
                        wrp.p_pmId = pm.Id;
                        wrp.p_OpenConfirm = false;
                        wrp.p_SrNO = Integer.valueOf(cm.Original_SQ_No__c);
                        wrp.p_ProjectName = pm.PRODUCT__c;
                        wrp.p_projNum = pm.Project_Number__c;
                        wrp.HQEmail = pm.HQ_Sales_Liaison_email_id__c;
                        wrp.AIEmail = pm.AI_Sales_Liaison_email_id__c;
                        wrp.OwnerEmail = pm.Owner.Email;
                        
                        wrp.ExpectedSalesMonth = pm.Expected_Sales_Month__c;
                        wrp.YourPONumber =pm.PO_No_to_HQ_3rd_Party__c;
                        wrp.YourPOIssueDate=pm.PO_issued_date_to_HQ_3rd_Party__c;
                        
                        wrp.p_CancelType = null;
                        wrp.p_Phase = pm.Phase__c;
                        wrp.isShowCancel = true;
                        wrp.p_SalesPrice = cm.Ceiling_Unit_Sales_Price_incl_Options__c;// pm.Total_Sales_Price__c;
                        wrapList.add(wrp);
                    } 
                    
                    system.debug('qty'+Qty+' sr no +'+cm.sr_No__c+' pm size '+cm.Project_Management__r.size()+' qty '+cm.Quantity__c+' Id '+cm.Id);
                    for(integer i = 0; i< Qty; i++){
                        wrapProject wrp = new wrapProject();
                        wrp.p_pmId = null;
                        wrp.p_currency = cm.CurrencyIsoCode;
                        wrp.p_OpenConfirm = false;
                        wrp.p_SrNO = Integer.valueOf(cm.sr_No__c);
                        if(cm.Product2Id__r.Name !=null){
                            wrp.p_ProjectName = cm.Product2Id__r.Name;
                        }else{
                            wrp.p_ProjectName = cm.Product_Name_2__c;
                        }
                        
                        wrp.isShowCancel = false;
                        
                        wrp.p_projNum = null;
                        wrp.p_CancelType = null;
                        wrp.p_SalesPrice = null;
                        wrp.AIEmail = null;
                        wrp.ExpectedSalesMonth = null;
                        wrp.YourPONumber =null;
                        wrp.YourPOIssueDate=null;
                        wrp.HQEmail = null;
                        wrp.OwnerEmail = null;
                        wrapList.add(wrp);
                        
                    }
                    //   } 
                    
                    
                }
                else{
                    wrapProject wrp = new wrapProject();
                    wrp.p_pmId = null;
                    wrp.p_currency = cm.CurrencyIsoCode;
                    wrp.p_OpenConfirm = false;
                    wrp.p_SrNO = Integer.valueOf(cm.sr_No__c);
                    if(cm.Product2Id__r.Name !=null){
                        wrp.p_ProjectName = cm.Product2Id__r.Name;
                    }else{
                        wrp.p_ProjectName = cm.Product_Name_2__c;
                    }
                    
                    wrp.isShowCancel = false;
                    
                    wrp.p_projNum = null;
                    wrp.ExpectedSalesMonth = null;
                        wrp.YourPONumber =null;
                        wrp.YourPOIssueDate=null;
                        
                    wrp.p_CancelType = null;
                    wrp.p_SalesPrice = null;
                    wrp.AIEmail = null;
                    wrp.HQEmail = null;
                    wrp.OwnerEmail = null;
                    wrapList.add(wrp);
                }
            //}
        }
        system.debug('wrapList'+wrapList.size());
        return JSON.serialize(wrapList);
        
    }
    
    @AuraEnabled
    public static Map<string,object> saveCanceledProject(string contractId,  string js, boolean isCancel){
        RecursiveTriggerHandler.isNewQuoteCode  = true;
        
        isPassValidationRule = true;
        isbypassRule = true;
        Map<string,object> result = new Map<string,object>();
        List<Messaging.Email> allMails = new List<Messaging.Email>();
        
        
        User us = [Select Id,Name from User where Id=:UserInfo.getUserId()];
        Contract conData = [Select Id,Contract_No_Rev_No__c,Quote__c,Status from Contract where Id=:contractId];
        
        
        
        List<wrapProject>   wrapList = ReOpenQuoteFromContract.parse(js);
        List<ProjectManagement__c> pmList = new List<ProjectManagement__c>();
        map<string,Integer> projSizeMap = new map<string,Integer>(); 
        for(wrapProject pm :wrapList ){
            if(pm.p_pmId != null){
                if(pm.p_CancelType == 'Cancelled'){
                    
                    if(projSizeMap.containsKey(pm.key)){
                        projSizeMap.put(pm.key, projSizeMap.get(pm.key) + 1);
                    }else{
                        projSizeMap.put(pm.key,1);
                    }
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    ProjectManagement__c wrp = new ProjectManagement__c();
                    wrp.Id  = pm.p_pmId;
                    wrp.Hold__c = false;
                    wrp.Cancelled_Date__c = date.today();
                    string body = pm.p_projNum+' Cancelled by '+us.Name+' on date '+Date.today().format()+' from Contract no '+ conData.Contract_No_Rev_No__c.substringBetween('>','</a>');
                    wrp.Cancelled_Reason__c = body;
                    wrp.Phase__c = pm.p_CancelType;
                   
                    
                    string emailbody ='Dear Sir/Madam, <br/><br/>';
                    emailbody += body;
                    emailbody +='<br/><br/> Thank you';
                    mail.setUseSignature(false);
                    
                    List<String> emailList = new List<String>();
                    List<String> emailCCList = new List<String>();
                    if(test.isRunningTest()){
                       emailList.add('abc@finessedirect.com');
                       emailCCList.add('abbc@finessedirect.com');
                        
                    }
                    
                    if(string.isNotBlank(pm.AIEmail)){
                        emailCCList.add(pm.AIEmail);
                    }
                    if(string.isNotBlank(pm.HQEmail)){
                        emailCCList.add(pm.HQEmail);
                    }
                    
                    
                    if(string.isNotBlank(pm.OwnerEmail)){
                        emailList.add(pm.OwnerEmail);
                    }else{
                        emailList = emailCCList;
                        emailCCList.clear();
                    }
                    mail.setToAddresses(emailList);
                    if(emailCCList.size() > 0){
                        mail.setCCAddresses(emailCCList);
                    }
                    
                    mail.htmlbody = emailbody;
                    mail.subject='Project Management Cancelled '+pm.p_projNum;
                    allMails.add(mail);
                    pmList.add(wrp);
                }else if(pm.p_CancelType =='Amendment'){
                    ProjectManagement__c wrp = new ProjectManagement__c();
                    wrp.Id  = pm.p_pmId;
                    wrp.Hold__c = false;
                    wrp.Phase__c = pm.p_CancelType;
                    pmList.add(wrp);
                }
                
            }
            
        }
        
        Boolean isCancelFlag = true;
        if(pmList.size() > 0){
            update pmList;  
        }
        
        
        
        
        try{
            if(isCancelFlag){
                string newQuote = '';
                string oldQuote = '';
                string pricebook = '';
                try{
                    
                    if(string.isNotBlank(conData.Quote__c)){
                        
                        conData.Status ='Close – Revised';
                        
                        if(isCancel){
                            conData.Status ='Cancelled After PM	';
                            Quote objQuote = new Quote();
                            objQuote.Id = conData.Quote__c;
                            objQuote.Status = 'CANCELLED AFTER PM';
                            //update objQuote;
                            Database.update(objQuote, false); 
                            update conData;
                        }else{
                            
                            oldQuote = conData.Quote__c;
                            
                            Quote  objQuote = [Select id,Discount__c,Opportunity.CurrencyISOCode,Machine_Mold__c,Q_PrintMachine__c ,Quote_No__c,Q_PrintTiming__c,Q_PrintPayment__c	,Quote_Template__c,Language__c,Subsidiary__c,Additinal_Margin__c,Subsidiary__r.Additional_Margin__c,Subsidiary__r.Rounding_Off_Digits__c,Subsidiary__r.Price_Book__c,Exchange_Rate__c,Quote_Number1__c,Cloned_From__c,Advance_Percentage__c,Insurance__c,Insurance_Amount__c,Freight_Amount__c,Freight__c,AccountId,AdditionalAddress,AdditionalName,BillingAddress,BillingName,ContactId,Description,Class__c,Zero_Cooling__c,
                                               Discount,Email,ExpirationDate,Fax,GrandTotal,LineItemCount,OpportunityId,Phone,CurrencyIsoCode,Name,Application__c,Mould_Delivery__c,
                                               QuoteNumber,QuoteToAddress,QuoteToName,ShippingHandling,ShippingAddress,ShippingName,Status,Shipping_And_Handling__c,Machine_Delivery__c,
                                               Subtotal,IsSyncing,Tax,TotalPrice,ACCOUNT_BUSINESS__c,ACCOUNT_TYPE__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,
                                               ADVANCE_PAYMENT__c,CITY__c,CLOSE_LOST_REASON__c,Contact__c,COUNTRY__c,COUNTRY_CODE__c,DATE__c,Designation__c,END_CUSTOMER_NAME__c,
                                               Text_After_Total__c,SHIP_To_Contact_Name__c,Project_Management_Quote_Id__c,Contract_Quote_Id__c,
                                               FUNCTION__c,INCO_TERMS__c,MFG_AT__c,POSTAL_CODE__c,PREPARED_BY__c,PROBABILITY__c,QUOTATION_ADDRESSED_TO__c,QUOTATION_CREATE__c,QU_REVISION_NUMBER__c,
                                               /*REGION__c,*/SHIP_TO__c,SOLD_TO__c,STATE__c,SUBSIDARY__c,TYPE__c,VALIDITY__c,VALITY_DATE__c,Quote_Number__c,Pricebook2Id,Use_Current_Price__c,Global_Region__c,Global_SubRegion__c,Ship_To_Global_Region__c,Ship_To_Global_SubRegion__c,Expected_Month_of_Consolidated_Order__c
                                               from Quote Where id =:conData.Quote__c limit 1];
                            
                            decimal exeRate = CommonData.getExchangeRate(objQuote.Opportunity.CurrencyISOCode);
                            //Id stQuote = Schema.SObjectType.quote.getRecordTypeInfosByName().get('Blank Quote').getRecordTypeId();
                            pricebook = objQuote.Subsidiary__r.Price_Book__c;
                            Quote QuoteClone  = objQuote.clone(false, false, false, false);
                            QuoteClone.SHIP_To_Contact_Name__c = objQuote.SHIP_To_Contact_Name__c;  
                            //QuoteClone.RecordTypeId = stQuote; 
                            QuoteClone.Status = 'CREATED';  
                            QuoteClone.Exchange_Rate__c = exeRate;  
                            QuoteClone.Project_Management_Quote_Id__c = objQuote.Project_Management_Quote_Id__c;
                            QuoteClone.Contract_Quote_Id__c = objQuote.Contract_Quote_Id__c;
                            insert QuoteClone;
                          
                            //Set the Revision Number + 1 and Original Quote Number at time of Revision Quote.
                            if(QuoteClone.id!=null){
                                system.debug(' inside quoteClone '+QuoteClone.id);
                                newQuote = QuoteClone.id;
                                Quote qt = new Quote();
                                qt = [Select Id,QU_REVISION_NUMBER__c from Quote where Id =:QuoteClone.id];
                                Quote qtToUpdate = new Quote(id=qt.id);
                                if(!string.isBlank(qt.QU_REVISION_NUMBER__c))
                                    if(Integer.valueOf(qt.QU_REVISION_NUMBER__c)+1 <10)
                                    qtToUpdate.QU_REVISION_NUMBER__c = '00'+String.valueOf(Integer.valueOf(qt.QU_REVISION_NUMBER__c)+1);
                                else
                                    qtToUpdate.QU_REVISION_NUMBER__c = '0'+String.valueOf(Integer.valueOf(qt.QU_REVISION_NUMBER__c)+1);
                                qtToUpdate.Quote_Number__c = objQuote.Quote_Number__c; //'Original Quote Number' on UI, carry from previous revised quote
                                system.debug(' inside quoteClone QU_REVISION_NUMBER__c'+qtToUpdate.QU_REVISION_NUMBER__c);
                                system.debug(' inside quoteClone Quote_Number__c '+qtToUpdate.Quote_Number__c);
                                qt.Cloned_From__c = objQuote.Quote_No__c;
                                qtToUpdate.Parent_Quote__c	 = objQuote.Id;
                                update qtToUpdate;
                            }
                            
                            update objQuote;
                            
                            objQuote.Status = 'CLOSE - REVISED';
                            update objQuote;
                        }
                    }
                    
                }
                catch(Exception e){
                    system.debug('error '+ e.getLineNumber()+' '+e.getMessage());
                }
                
                if(!isCancel){
                    //System.debug('QuoteClone.Id: : :Kb'+oldQuote);
                    //String QuoteCloneId = QuoteClone.Id;
                    
                    List<Quote_Line_Item_Custom__c> ObjQuoteLineItem = [Select id,Product_Description__c,Approval_Status__c,Class__c,Division__c,Discount_Allowed_New__c,Drawing_No__c,Expected_Customer_PO__c,Base_Price__c,BP_Ratio_Line_Item__c,Cavity__c,Total_Sales_Price__c,Level_Of_Ceiling__c,
                                                                        Expected_Delivery__c,Expected_Delivery_date__c,Expected_Drawing_Final__c,Advance_Percentage__c,Ceiling_Total_Sales_Price__c,CurrencyIsoCode,Product_Type__c,
                                                                        Mach_Mold_No__c,Product__c,Quantity__c,Quote__c,Discount_Allowed__c,Discount_Approval_Note__c,Is_Manual__c,Payment_Terms__c,Scope_of_mould__c,Product_Name__c,
                                                                        Total_Base_Price_Options__c, List_Price__c,Discount__c,Sr_No__c,Is_Tax__c,Discount_Type__c,Discount_in_Value__c,
                                                                        Product__r.id,Quote__r.Exchange_Rate__c,P_D1__c,P_D2__c,P_D3__c,P_M1__c,P_M2__c,P_M3__c,P_M4__c,Manual_Product_Code__c,
                                                                        Quote__r.Additinal_Margin__c,Product__r.ProductCode,Project_Unique_No__c,
                                                                        (Select id,Discount__c,Final_Price__c,Discount_in_Value__c,Discount_Allowed_New__c,Manual_Option__c,
                                                                         Quote__r.Additinal_Margin__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Product_Type__c,
                                                                         P_D1__c,P_D2__c,P_D3__c,P_M1__c,P_M2__c,P_M3__c,P_M4__c,Quote__r.Exchange_Rate__c,Manual_Product_Code__c,
                                                                         Other_Charges_Base_Price__c,Other_Charges_Function__c,Product__c,Quote__c,Select_Option__c,Mould_Cavity__c,Price_Type__c,Discount_Description__c
                                                                         ,Product__r.id,Serial_Number__c,Discount_Type__c from Quote_Line_Options__r order by Serial_Number__c asc)
                                                                        from Quote_Line_Item_Custom__c Where Quote__c = : oldQuote order by Sr_No__c asc];
                    Set<id>IdOfOpQuoteItem=new Set<id>();
                    Set<id>proIds=new Set<id>();
                    for(Quote_Line_Item_Custom__c QLN : ObjQuoteLineItem){
                        IdOfOpQuoteItem.add(QLN.id);
                        proIds.add(QLN.Product__r.id);
                        for(Quote_Line_Options__c QO:QLN.Quote_Line_Options__r)
                        {
                            proIds.add(QO.Product__r.id);  
                        }
                    }
                    
                    
                    
                    
                    System.debug('ObjQuoteLineItem'+ObjQuoteLineItem);
                    for(Quote_Line_Item_Custom__c QLN : ObjQuoteLineItem){
                        IdOfOpQuoteItem.add(QLN.id);
                    }
                    List<Quote_Line_Options__c> lstQuoteOption = new List<Quote_Line_Options__c>();
                    if(IdOfOpQuoteItem != null && IdOfOpQuoteItem.size() > 0){
                        lstQuoteOption = [Select id,Discount_in_Value__c,Discount_Allowed_New__c,Discount_Type__c,Quote__r.Exchange_Rate__c,Product_Type__c,CurrencyIsoCode,Discount__c,Option_Number__c,quantity__c,description__c,Manual_Product_Name__c, Final_Price__c,Manual_Option__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,
                                          P_D1__c,P_D2__c,P_D3__c,P_M1__c,P_M2__c,P_M3__c,P_M4__c,Serial_Number__c, Other_Charges_Base_Price__c,Manual_Product_Code__c,Quote__r.Additinal_Margin__c,Other_Charges_Function__c,Product__c,Quote__c,Select_Option__c,Manula_Option_List_Price__c,Mould_Cavity__c,Price_Type__c,Quote_Line_Item_Custom__c,Discount_Description__c
                                          from Quote_Line_Options__c where Quote_Line_Item_Custom__c IN : IdOfOpQuoteItem];
                    }
                    
                    List<Quote_Line_Item_Custom__c> Lst = new List<Quote_Line_Item_Custom__c>();
                    List<Quote_Line_Options__c  > ListQLo = new  List<Quote_Line_Options__c >();
                    List<Quote_Line_Item_Custom__c> lstContractItem = new List<Quote_Line_Item_Custom__c>();
                    Map<Id,Quote_Line_Item_Custom__c> MapofQuoteContract = new Map<Id,Quote_Line_Item_Custom__c>();
                    
                    Map<Id, PriceBookEntry> mapProductWisePriceEntry = new Map<Id, PricebookEntry>();
                    for(PriceBookEntry eachPBE : [SELECT Id, Product2.Id, UnitPrice,List_Price_Level_2__c,List_Price_Level_3__c, Base_Price__c,M1__c,M2__c,M3__c,D1__c,D2__c,D3__c,M4__c
                                                  ,Rounding_Off_Digits__c FROM PriceBookEntry Where Product2.IsActive = TRUE AND 
                                                  Pricebook2.id =:pricebook and IsActive=true AND Product2.id in:proIds]){
                                                      mapProductWisePriceEntry.put(eachPBE.Product2.Id,eachPBE);	                
                                                  }
                    
                    for(Quote_Line_Item_Custom__c pro1 : ObjQuoteLineItem){
                        string  key =pro1.Project_Unique_No__c;// pro1.Product__c+'_'+pro1.Product__r.ProductCode;//+'_'+pro1.Sr_No__c;
                        system.debug('key'+key);
                        Quote_Line_Item_Custom__c cli = new Quote_Line_Item_Custom__c(); 
                        cli.CurrencyIsoCode=pro1.CurrencyIsoCode;
                        cli.Project_Unique_No__c = pro1.Project_Unique_No__c;
                        if(pro1.Discount_Allowed_New__c!=null)
                            cli.Discount_Allowed_New__c = pro1.Discount_Allowed_New__c;
                        
                        if(pro1.Is_Tax__c!=null)
                            cli.Is_Tax__c = pro1.Is_Tax__c;
                        if(pro1.Sr_No__c!=null)
                            cli.Sr_No__c = pro1.Sr_No__c;
                        
                        
                        
                        if(pro1.Discount_Type__c!=null)
                            cli.Discount_Type__c = pro1.Discount_Type__c;
                        
                        if(pro1.Discount__c!=null)
                            cli.Discount__c = pro1.Discount__c;
                        
                        if( newQuote!=null){
                            system.debug('newQuote'+newQuote);
                            cli.Quote__c = newQuote; 
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
                        
                        /*    if(pro1.Is_Manual__c != null){
cli.Manual_Product_Code__c = pro1.Manual_Product_Code__c;
}	*/
                        
                        if(mapProductWisePriceEntry.containsKey(pro1.Product__c))
                        { 
                            cli.P_D1__c = mapProductWisePriceEntry.get(pro1.Product__c).d1__c;cli.P_D2__c = mapProductWisePriceEntry.get(pro1.Product__c).d2__c;
                            cli.P_D3__c = mapProductWisePriceEntry.get(pro1.Product__c).d3__c;cli.P_M1__c = mapProductWisePriceEntry.get(pro1.Product__c).M1__c;
                            cli.P_M2__c = mapProductWisePriceEntry.get(pro1.Product__c).M2__c;cli.P_M3__c = mapProductWisePriceEntry.get(pro1.Product__c).M3__c;
                            cli.P_M4__c = mapProductWisePriceEntry.get(pro1.Product__c).M4__c;cli.Discount_Allowed_New__c = cli.Discount_Allowed_New__c;
                            decimal up;
                            up=mapProductWisePriceEntry.get(pro1.Product__c).UnitPrice;
                            cli.Base_Price__c = (mapProductWisePriceEntry.get(pro1.Product__c).Base_Price__c*pro1.Quote__r.Exchange_Rate__c);
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
                            cli.List_Price__c= pro1.List_Price__c;
                            cli.Base_Price__c = pro1.Base_Price__c;
                            if(pro1.P_D1__c!=null)
                                cli.P_D1__c = pro1.P_D1__c;
                            if(pro1.P_D2__c!=null)
                                cli.P_D2__c = pro1.P_D2__c;
                            if(pro1.P_D3__c!=null)cli.P_D3__c = pro1.P_D3__c;
                            if(pro1.P_M1__c!=null)
                                cli.P_M1__c = pro1.P_M1__c;
                            if(pro1.P_M2__c!=null)
                                cli.P_M2__c = pro1.P_M2__c;
                            if(pro1.P_M3__c!=null)
                                cli.P_M3__c = pro1.P_M3__c;
                            if(pro1.P_M4__c!=null)
                                cli.P_M4__c = pro1.P_M4__c;
                            
                        }
                        
                        
                        if(pro1.Product_Description__c != null && pro1.Product_Description__c != ''){cli.Product_Description__c = pro1.Product_Description__c;
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
                        
                        if(pro1.Advance_Percentage__c!=null){cli.Advance_Percentage__c = pro1.Advance_Percentage__c; 
                        }
                        
                        system.debug('pro1.Discount_in_Value__c'+pro1.Discount_in_Value__c);
                        if(pro1.Discount_in_Value__c!=null)
                            cli.Discount_in_Value__c = pro1.Discount_in_Value__c;
                        
                        if(pro1.Quantity__c!=null){
                            system.debug('key-->'+key);
                            if(projSizeMap.containsKey(key)){
                                Integer i = Integer.valueOf(pro1.Quantity__c) - projSizeMap.get(key); cli.Quantity__c = i; 
                                
                                if(i == 0 ){cli.Discount_in_Value__c =0;cli.Discount_Type__c = null; cli.Discount__c = 0;
                                    
                                }
                               
                            }else{
                                cli.Quantity__c = pro1.Quantity__c;
                            }
                        }
                        
                        lstContractItem.add(cli);
                        MapofQuoteContract.put(pro1.Id,cli);
                    }
                    try{
                        
                        insert MapofQuoteContract.values();
                    }
                    catch(Exception e){
                        System.debug('Error*** '+e.getMessage());result.put('Error',e.getMessage());
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is issue in Re-Open Quote, Please contact to your System Administrator.'));   return null;
                    }
                    
                    Map<Id, PriceBookEntry> mapProductWisePriceOptionEntry = new Map<Id, PricebookEntry>();
                    for(PriceBookEntry eachPBE : [SELECT Id, Product2.Id,unitprice,Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c,M1__c,M2__c,M3__c,D1__c,D2__c,D3__c,M4__c
                                                  ,Rounding_Off_Digits__c
                                                  FROM PriceBookEntry 
                                                  WHERE Pricebook2Id IN (SELECT Id FROM PriceBook2  where  Pricebook2.id =:pricebook AND 
                                                                         PriceBook2.IsActive = true)
                                                  AND Product2.IsACTIVE = true AND Product2.Family = 'Options' and Product2.id in:proIds]){mapProductWisePriceOptionEntry.put(eachPBE.Product2.Id,eachPBE);	                
                                                  }             
                    
                    for(Quote_Line_Options__c pro2 :lstQuoteOption){
                        
                       
                        Quote_Line_Options__c ContLO =new Quote_Line_Options__c();
                        ContLO.CurrencyIsoCode=pro2.CurrencyIsoCode;
                        System.debug('Record id :::::'+pro2.id+'    Map:::::'+MapofQuoteContract);
                        ContLO.Quote_Line_Item_Custom__c  = MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id;  //.Id
                        System.debug('MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id'+MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id); 
                        String prodId = pro2.Product__c;
                        
                        
                        if(mapProductWisePriceOptionEntry.containsKey(pro2.Product__c)){
                            ContLO.P_D1__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).d1__c;ContLO.P_D2__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).d2__c;
                            ContLO.P_D3__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).d3__c;ContLO.P_M1__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).M1__c;
                            ContLO.P_M2__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).M2__c;ContLO.P_M3__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).M3__c;
                            ContLO.P_M4__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).M4__c;
                            Double up;
                            up=mapProductWisePriceOptionEntry.get(pro2.Product__c).Base_Price__c;
                            ContLO.Manula_Option_List_Price__c=AddProducts.getListPrice(up, pro2.Quote__r.Exchange_Rate__c, mapProductWisePriceOptionEntry.get(pro2.Product__c).M1__c,
                                                                                        mapProductWisePriceOptionEntry.get(pro2.Product__c).M2__c,mapProductWisePriceOptionEntry.get(pro2.Product__c).M3__c, mapProductWisePriceOptionEntry.get(pro2.Product__c).M4__c,
                                                                                        1, Integer.valueof(mapProductWisePriceOptionEntry.get(pro2.Product__c).Rounding_Off_Digits__c));
                            ContLO.Manual_Option_Base_Price__c = mapProductWisePriceOptionEntry.get(pro2.Product__c).Base_Price__c * pro2.Quote__r.Exchange_Rate__c;
                            
                        }else{
                            if(pro2.P_D1__c!=null)
                                ContLO.P_D1__c = pro2.P_D1__c;
                            if(pro2.P_D2__c!=null)
                                ContLO.P_D2__c = pro2.P_D2__c;
                            if(pro2.P_D3__c!=null)
                                ContLO.P_D3__c = pro2.P_D3__c;
                            if(pro2.P_M1__c!=null)
                                ContLO.P_M1__c = pro2.P_M1__c;
                            if(pro2.P_M2__c!=null)
                                ContLO.P_M2__c = pro2.P_M2__c;
                            if(pro2.P_M3__c!=null)
                                ContLO.P_M3__c = pro2.P_M3__c;
                            if(pro2.P_M4__c!=null)
                                ContLO.P_M4__c = pro2.P_M4__c;
                            
                            if(pro2.Manual_Option_Base_Price__c != null){
                                ContLO.Manual_Option_Base_Price__c = pro2.Manual_Option_Base_Price__c;
                            }
                            
                            if(pro2.Manula_Option_List_Price__c != null){
                                ContLO.Manula_Option_List_Price__c = pro2.Manula_Option_List_Price__c;
                            }
                            
                        }
                        
                        if(pro2.Discount_Allowed_New__c!=null)
                            ContLO.Discount_Allowed_New__c = pro2.Discount_Allowed_New__c;
                        if(pro2.Description__c != null && pro2.Description__c != ''){
                            ContLO.Description__c = pro2.Description__c;
                        }
                        if(pro2.Discount_in_Value__c!=null)
                            ContLO.Discount_in_Value__c = pro2.Discount_in_Value__c;
                        
                        if(pro2.Discount__c!=null)
                            ContLO.Discount__c = pro2.Discount__c;
                        
                        if(pro2.Discount_Type__c != null && pro2.Discount_Type__c != ''){ ContLO.Discount_Type__c = pro2.Discount_Type__c;
                        }
                        
                        if(pro2.Product_Type__c !=null){ ContLO.Product_Type__c = pro2.Product_Type__c; 
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
                        /*if(pro2.Manula_Option_List_Price__c != null){
ContLO.Manula_Option_List_Price__c = pro2.Manula_Option_List_Price__c;
}*/
                        /*if(pro2.Price_Type__c !=null){
ContLO.Price_Type__c = pro2.Price_Type__c;
}*/
                        if(pro2.Discount_Description__c != null){
                            ContLO.Discount_Description__c = pro2.Discount_Description__c;
                        }
                        else{ContLO.Discount_Description__c = 'Null';
                        }
                        /*if(pro2.Manual_Option_Base_Price__c != null){
ContLO.Manual_Option_Base_Price__c = pro2.Manual_Option_Base_Price__c;
}*/
                        if(newQuote != null && newQuote !='' ){
                            ContLO.Quote__c = newQuote;
                        }
                        if(pro2.Manual_Option__c !=null){ContLO.Manual_Option__c = pro2.Manual_Option__c;
                        }
                        if(pro2.Description__c !=null){
                            ContLO.Description__c = pro2.description__c;
                        }
                        if(pro2.Select_Option__c !=null){
                            ContLO.Select_Option__c = pro2.Select_Option__c;
                        }
                        
                        if(pro2.Mould_Cavity__c !=null){ContLO.Mould_Cavity__c = pro2.Mould_Cavity__c;
                        }
                        if(pro2.Option_Number__c !=null){ContLO.Option_Number__c = pro2.Option_Number__c;
                        }
                        if(pro2.Manual_Product_Name__c !=null){ContLO.Manual_Product_Name__c = pro2.Manual_Product_Name__c;
                        }
                        if(pro2.Manual_Option_Function__c !=null){ContLO.Manual_Option_Function__c = pro2.Manual_Option_Function__c;
                        }
                        if(pro2.Other_Charges__c !=null){ContLO.Other_Charges__c = pro2.Other_Charges__c;
                        }
                        if(pro2.Other_Charges_Base_Price__c !=null){ContLO.Other_Charges_Base_Price__c = pro2.Other_Charges_Base_Price__c;
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
                        
                        /*     if(pro2.Select_Option__c != null){
ContLO.Manual_Product_Code__c = pro2.Manual_Product_Code__c;
}	*/
                        
                        
                        ListQLo.add(ContLO);
                        system.debug('ContLO'+ContLO);
                    }
                    
                    
                    try
                    {
                        
                       insert ListQLo;
                    }
                    catch(Exception e) { 
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'There is issue in Re-Open, Please contact to your System Administrator.'));
                        result.put('Error',e.getMessage());
                        //return null; 
                    }
                    
                    List<Attachment> lstAtt = new List<Attachment>();
                    lstAtt = [select id, name, body, LastModifiedDate, Createddate , createdby.name,ParentId from Attachment where ParentId=:oldQuote ];
                    
                    lstAtt.clear();
                    
                    update conData; 
                    result.put('Id',newQuote);
                    isCancelFlag = false;
                    if(!test.isRunningTest()){List<Messaging.sendEmailResult> results = Messaging.sendEmail(allMails);}
                    
                    
                } else{ 
                    result.put('Id',conData.Quote__c);
                }
                
            }
        }catch(exception e){system.debug('Error '+e.getLineNumber() + ' msg ' +e.getMessage() );result.put('Error',e.getMessage());
           // return result;
        }
        return result;
        
    }
    
    
    
    
    public static List<wrapProject> parse(string js){
        return ((List<wrapProject>)system.JSON.deserialize(js,List<wrapProject>.class));
    }
    
    public class wrapProject{
        public Id p_pmId{get;set;}
        public string key{get;set;}
        public boolean p_OpenConfirm{get;set;}
        public Integer p_SrNO{get;set;}
        public string p_currency{get;set;}
         public string Phase{get;set;}
        public string p_ProjectName{get;set;}
        public string p_projNum{get;set;}
        public string p_CancelType{get;set;}
        public string p_Phase{get;set;}
        public string HQEmail{get;set;}
        public string AIEmail{get;set;}
        public Double p_SalesPrice{get;set;}
        public boolean isShowCancel{get;set;}
        public string OwnerEmail{get;set;}
          public Date ExpectedSalesMonth {get;set;}
            public string YourPONumber {get;set;}
            public date YourPOIssueDate {get;set;}
    } 
    
}