/*
* Author: Kloudrac; 
* Desc: handiling the Quote CReation, Cloning LEX component functionalities.
* 
* 
----------------------------------------------------------------------

Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      7-14-2022   Amol Wagh      To generate QuoteNo and Auto assign Fy and Subsidiary
V1.2      8-03-2022   Amol Wagh      Add exchange Rate REGION__c
*/


public class QuoteCreationCMPController {
    
        
     /*@AuraEnabled
    public static Map<String, String> getSoldAndShipTo1(Id quoteId) {
        system.debug('getSoldAndShipTo-->'+quoteId);
        Quote q = [
            SELECT Id, Sold_To__c, Ship_To__c 
            FROM Quote 
            WHERE Id = :quoteId 
            LIMIT 1
        ];

        Map<String, String> result = new Map<String, String>();
        result.put('Sold_To__c', q.Sold_To__c !=null ?q.Sold_To__c : null);
        result.put('Ship_To__c', q.Ship_To__c !=null ?q.Ship_To__c : null);
        system.debug('result-->'+result);
        return result;
    }*/
    
    @AuraEnabled
    public static map<string,object> IntialDataFetch(String RecId){
        
        map<string,object> result =new map<string,object>();
        Boolean givePermission;
        System.debug('RecId--->'+RecId);
        Opportunity objoppty = new Opportunity();
        objoppty = [Select id, Subsidiary__c,Subsidiary__r.Additional_Margin__c,name,AccountId,Account.name,Account.CurrencyISOCode,CurrencyISOCode, Subsidiary__r.Allow_Exchange_Rate_Modification__c,
                    Contact__c,Subsidiary__r.Allow_Quote_Margin_Modification__c, Account.Region1__c,
                    Subsidiary__r.Display_Exchange_Rate_Modification__c,
                    Subsidiary__r.Display_Quote_Margin_Modification__c
                    from opportunity where id=:recid];
        
        if(string.isBlank(objoppty.Contact__c)){
            result.put('Error','Please Fill Contact');
            return result;
        }else{
            
        if(objoppty.Account.Region1__c == null){
            System.debug('Inside Blank Condition!!!!');
            givePermission = false;
        }else{        
            Region__c region = [Select Id,Name, Country__c,Active__c from Region__c 
                                where id=:objoppty.Account.Region1__c 
                                AND Active__c=true];
            
            List<User_Setup__c> usDetail = new List<User_Setup__c>();
            usDetail = [SELECT ID, Region__c, Country__c FROM User_Setup__c 
                        WHERE User__c=:userInfo.getUserId() AND Region__c=:region.Id 
                        //AND Country__c=:region.Country__c
                        ];
            if(usDetail.size()>0){
                givePermission = true;
            }else{
                List<Assign_Region__c> ar = [SELECT Country__c, Region__c, User_Setup__c 
                                             FROM Assign_Region__c WHERE User_Setup__r.User__r.Id=:userInfo.getUserId()
                                             AND Country__c=:region.Country__c AND Region__c=:region.Id];
                if(ar.size()>0){
                    givePermission = true;
                }else{
                    givePermission = false;
                }
            }
        }     
        
        CurrencyType ctype=[select Id, IsCorporate, IsoCode, ConversionRate, DecimalPlaces 
                            from CurrencyType where IsActive=true and IsoCode=:objoppty.CurrencyISOCode limit 1 ];
        
        List<Quote> lstQt = new List<Quote>();
      
        lstQt = [Select id,Name,region1__c,QuoteNumber,Additinal_Margin__c, QU_REVISION_NUMBER__c,AccountId, Account.Name ,Quote_Number__c
                 from quote where Subsidiary__c=:objoppty.Subsidiary__c AND 
                 (Status ='CLOSE - SC CREATED' OR Status='RELEASED' OR Status='DISCARD/VOID' OR Status='CLOSE - REVISED' OR   Status='CANCELLED' OR   Status='CANCELLED AFTER PM' OR
                  Status='CLOSE - LOST' ) and Quote_Number__c != null and QU_REVISION_NUMBER__c != null
                order by Quote_Number__c desc  ,QU_REVISION_NUMBER__c desc];
        Decimal AddionalMargin = objoppty.Subsidiary__r.Additional_Margin__c;
            system.debug('lstQt'+lstQt.size());
        DataWrapper objDataWrapper  = new DataWrapper(objoppty,lstQt,ctype.ConversionRate, AddionalMargin, givePermission);
            system.debug('objDataWrapper'+objDataWrapper);
           result.put('data',objDataWrapper);
            return result;
        }
        
    }
    
    @AuraEnabled
    public static Boolean CheckQuoteTemplate(){
        User_Setup__c u=[select id,name,User__c,Subsidiari__c,Subsidiari__r.name,Default_Language__c  from User_Setup__c where User__c =: Userinfo.getUserId()];
        Quote_Template__c qtemp = new Quote_Template__c();
        try{
            qtemp=[select id,name,Subsidiary__c from Quote_Template__c where Subsidiary__c=:u.Subsidiari__c and Language__c=:u.Default_Language__c AND Active__c = TRUE limit 1];
        }catch(Exception e){
            System.debug('Insie Check dCondition!!!');
            return true;
        }
        return false;
    }
    
    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.CurrencyISOCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('Values in Rating are: '+pickListValuesList);
        }     
        return pickListValuesList;
    }
   
    
    @AuraEnabled
    public static String createBlankQuoteController(String QuoteName, String recordId,String currencyName,String cRate, String QuoteAdditionalMargin) {
        
        try{
            
        system.debug('QuoteName--->' + QuoteName);
        system.debug('RecordId---->' + recordId);
        system.debug('cRate---->' + cRate);
        System.debug('addionalMargin---------> '+ QuoteAdditionalMargin);
        System.debug('addionalMargin---------> '+ currencyName);
               
        UserSetup us=getQuoteNumber(); 
            system.debug('us'+us);
        Quote_Template__c qtemp=[select id,name,Subsidiary__c from Quote_Template__c 
                                 where Subsidiary__c=:us.Subsidiari and Language__c=:us.lang AND Active__c = TRUE ORDER BY Name limit 1];
        
        string Quoteid; 
        if(QuoteName != null && QuoteName != ''){
            
           Opportunity opp = [SELECT Id, Account.Global_Region__c, Contact__c,Account.Global_SubRegion__c,Prepared_By__c,accountId FROM Opportunity WHERE Id = :recordId];
            system.debug('opp.ContactId'+opp.Contact__c);
            Contact con = [SELECT Id, Email,Name FROM Contact WHERE Id = :opp.Contact__c limit 1];
           //Contact con = [SELECT Id, Email,Name FROM Contact WHERE AccountId = :opp.AccountId ];
            
            Quote ObjQuote = new Quote();
            ObjQuote.name = QuoteName;
            ObjQuote.CurrencyIsoCode = currencyName;
            ObjQuote.OpportunityId = recordId;
            ObjQuote.Status = 'CREATED';
            ObjQuote.QUOTATION_CREATE__c = 'CREATE FROM BLANK';
            ObjQuote.Freight__c = 'By Buyer';
            ObjQuote.Insurance__c = 'By Buyer';
            ObjQuote.VALIDITY__c = 30;
           	ObjQuote.Global_Region__c = opp.Account.Global_Region__c;
           	ObjQuote.Global_SubRegion__c = opp.Account.Global_SubRegion__c;
            ObjQuote.Ship_To_Global_Region__c = opp.Account.Global_Region__c;
			ObjQuote.Ship_To_Global_SubRegion__c = opp.Account.Global_SubRegion__c;
            ObjQuote.Contact__c = con.Id;
            ObjQuote.PREPARED_BY__c = opp.Prepared_By__c;
            ObjQuote.SOLD_TO__c = opp.AccountId;
            ObjQuote.SHIP_TO__c = opp.AccountId;
            if(string.isNotBlank(con.Email)){
                ObjQuote.Email = con.Email;  
            }
            
            if(string.isNotBlank(con.Id)){

                ObjQuote.SHIP_To_Contact_Name__c = con.Id;
            } 
            
            //V1.1
            ObjQuote.Quote_Number1__c=us.QuoteNo;
            ObjQuote.Fiscal_Year_Master__c=us.FY;
            ObjQuote.Subsidiary__c=us.Subsidiari;
            ObjQuote.Language__c=us.lang;
            ObjQuote.Quote_Template__c=qtemp.Id;            
            ObjQuote.Exchange_Rate__c=decimal.valueOf(cRate);
            ObjQuote.Additinal_Margin__c=decimal.valueOf(QuoteAdditionalMargin);
            //V1.1 end
            system.debug('before currency'+ObjQuote.CurrencyIsoCode);
            insert ObjQuote;
            
            //Set the Revision Number 000 and Original Quote Number at time of New Quote Creation.
            if(ObjQuote.id!=null){
                system.debug('after currency'+ObjQuote.CurrencyIsoCode);
                Quote qt = new Quote();
                qt = [Select Id, QuoteNumber,Quote_Number1__c from Quote where Id =:ObjQuote.id];
                Quote qtToUpdate = new Quote(id=qt.id);
                qtToUpdate.QU_REVISION_NUMBER__c = '000'; //QU REVISION NUMBER
                qtToUpdate.Quote_Number__c = qt.Quote_Number1__c; //Original Quote Number
                update qtToUpdate;
                system.debug('after Update currency'+ObjQuote.CurrencyIsoCode);
            }
            
            Quoteid = ObjQuote.id;
            Opportunity Oppty = new Opportunity();
            Oppty = [select id,name,StageName,Contact__c from Opportunity where id=: recordId];
            Oppty.stageName = 'Under Quotation';
           
            //try
            //{
                update Oppty;
                
            //}
            //catch(Exception e)
            //{
              //  system.debug('exception--->' + e);
            //}
            
            System.debug('Quoteid--->'+Quoteid);
            
            
        }
            if(Quoteid != null){
                return Quoteid;
            }else{
                return  null;
            }
        
        }catch(exception e){
            system.debug('error is'+e.getMessage()+' line '+e.getLineNumber());
             throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static map<string,object> cloneExistingQuote(String quoteToClone, String clonedQuoteName, string currencyName, String recordId, String cRate, String QuoteAdditionalMargin,
                                                            string soldTo, string shipTo) {
        /* Param 1 'quoteToClone' - 18 Digit Id of the Quote which is being Cloned.
* Param 2 'clonedQuoteName' - Name of the New Cloned Quote from quote 'quoteToClone'.
* Param 3 'recordId' - Parent Opportunity ID. 

*/ 
        map<string,object> result = new map<string,object>();
                   
        
        
        System.debug('addionalMargin --- >'+ QuoteAdditionalMargin);
        System.debug('**quoteToClone** '+quoteToClone); //Output is 18 digit Id of Quote to be cloned
        System.debug('**clonedQuoteName** '+clonedQuoteName);//Output is Name of New Quote
        System.debug('**recordId** '+recordId); // Output is 18 digit Id Parent Opportunity
        UserSetup us=getQuoteNumber();
        String parentQuoteId = quoteToClone;
        String newlyClonedQuoteName = clonedQuoteName; 
        String oppId = recordId;
         try{

        //if(clonedQuoteName != null || clonedQuoteName !=''){
        if(!String.isBlank(newlyClonedQuoteName)){           
            
            //Get the Values from Parent Quote [The Quote which is being cloned.]
            Quote parentQuote = new Quote();
            parentQuote = [Select id,Quote_No__c,Advance_Percentage__c,Insurance_Amount__c, Insurance__c,Freight__c,Freight_Amount__c,AccountId,AdditionalAddress,AdditionalName,BillingAddress,BillingName,ContactId,Description,
                           Opportunity.Zero_Cooling__c,Zero_Cooling__c,Discount,Discount__c,Email,ExpirationDate,Fax,GrandTotal,LineItemCount,OpportunityId,Phone,CurrencyIsoCode,Name,Opportunity.APPLICATION__c,Class__c,
                           QuoteNumber,QuoteToAddress,QuoteToName,ShippingHandling,ShippingAddress,ShippingName,Status,Application__c,Opportunity.Class__c,Machine_Delivery__c,
                           Subtotal,IsSyncing,Tax,TotalPrice,ACCOUNT_BUSINESS__c,ACCOUNT_TYPE__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,Opportunity.MFG_AT__c,
                           ADVANCE_PAYMENT__c,CITY__c,CLOSE_LOST_REASON__c,Contact__c,COUNTRY__c,COUNTRY_CODE__c,DATE__c,Designation__c,END_CUSTOMER_NAME__c,Mould_Delivery__c,
                           FUNCTION__c,INCO_TERMS__c,MFG_AT__c,POSTAL_CODE__c,PREPARED_BY__c,PROBABILITY__c,QUOTATION_ADDRESSED_TO__c,QUOTATION_CREATE__c,QU_REVISION_NUMBER__c,
                           /*REGION__c,*/SHIP_TO__c,SOLD_TO__c,STATE__c,SUBSIDARY__c,Quote_Number1__c,TYPE__c,VALIDITY__c,VALITY_DATE__c,Quote_Number__c,Pricebook2Id,Account.Global_Region__c,Account.Global_SubRegion__c,Text_After_Total__c,
                           Q_PrintMachine__c,Q_PrintTiming__c,Q_PrintPayment__c,Q_PrintShipping__c,Q_PrintConclusion__c,Price_in_Word_Required__c,Expected_Month_of_Consolidated_Order__c
                           from Quote Where id =:parentQuoteId limit 1];
            
            String opportunityId = oppId;
            Opportunity Oppty = new Opportunity();
            Oppty =[select id, name,Zero_Cooling__c,Class__c,MFG_AT__c,APPLICATION__c from Opportunity where id = :oppId];  
            
            
            
            //ObjQ.Discount__c=0;
            
            //Make the Clone.
            //public SObject clone(Boolean preserveId, Boolean isDeepClone, Boolean preserveReadonlyTimestamps, Boolean preserveAutonumber) - Standard Method of sObject Class
            Quote QuoteClone  = parentQuote.clone(false, false, false, false);
            
            
            Quote_Template__c qtemp=[select id,name,Subsidiary__c from Quote_Template__c where Subsidiary__c=:us.Subsidiari and Active__c=true and Language__c=:us.lang limit 1];
            system.debug(qtemp.Name);
            
            //Set the Values of New Quote, from parent Quote            
            QuoteClone.Cloned_From__c = parentQuote.Quote_Number1__c +'-'+parentQuote.QU_REVISION_NUMBER__c; //Cloned From on UI
            QuoteClone.Cloned_From_Id__c =  parentQuote.Id;
            QuoteClone.Name = newlyClonedQuoteName;
            QuoteClone.CurrencyIsoCode = currencyName;
            //QuoteClone.RecordTypeId = Schema.SObjectType.quote.getRecordTypeInfosByName().get('Blank Quote').getRecordTypeId();
            QuoteClone.Status = 'CREATED'; 
            QuoteClone.Freight__c = 'By Buyer';
            QuoteClone.Insurance__c = 'By Buyer';
            QuoteClone.OpportunityId = oppId;
            QuoteClone.QUOTATION_CREATE__c = 'COPY FROM REFENCE QUOTATION';
            QuoteClone.Application__c = Oppty.APPLICATION__c;
            QuoteClone.MFG_AT__c = Oppty.MFG_AT__c;
            QuoteClone.Class__c = Oppty.Class__c;
            QuoteClone.Zero_Cooling__c = Oppty.Zero_Cooling__c;
            QuoteClone.Advance_Percentage__c = parentQuote.Advance_Percentage__c;
            QuoteClone.Insurance_Amount__c = parentQuote.Insurance_Amount__c;
            QuoteClone.Freight_Amount__c = parentQuote.Freight_Amount__c;
            QuoteClone.Insurance__c = parentQuote.Insurance__c;
            QuoteClone.Freight__c = parentQuote.Freight__c;
            QuoteClone.Machine_Delivery__c = parentQuote.Machine_Delivery__c;
            QuoteClone.Mould_Delivery__c = parentQuote.Mould_Delivery__c;
            QuoteClone.Discount__c =0.00;
            QuoteClone.Exchange_Rate__c=decimal.valueOf(cRate);
            QuoteClone.Fiscal_Year_Master__c=us.FY;
            QuoteClone.Subsidiary__c=us.Subsidiari;
            QuoteClone.Quote_Number1__c=us.QuoteNo;
            QuoteClone.Language__c=us.lang;
            QuoteClone.CLOSE_LOST_REASON__c = null;
            QuoteClone.Quote_Template__c=qtemp.id;
            QuoteClone.Additinal_Margin__c = decimal.valueOf(QuoteAdditionalMargin);
            
            QuoteClone.Global_Region__c = parentQuote.Account.Global_Region__c;
           	QuoteClone.Global_SubRegion__c = parentQuote.Account.Global_SubRegion__c;
            QuoteClone.Ship_To_Global_Region__c = parentQuote.Account.Global_Region__c;
            QuoteClone.Ship_To_Global_SubRegion__c = parentQuote.Account.Global_SubRegion__c;
            QuoteClone.Text_After_Total__c = parentQuote.Text_After_Total__c;
            QuoteClone.Q_PrintMachine__c = parentQuote.Q_PrintMachine__c;
            QuoteClone.Q_PrintTiming__c = parentQuote.Q_PrintTiming__c;
            QuoteClone.Q_PrintPayment__c = parentQuote.Q_PrintPayment__c;
            QuoteClone.Q_PrintShipping__c = parentQuote.Q_PrintShipping__c;
            QuoteClone.Q_PrintConclusion__c = parentQuote.Q_PrintConclusion__c;
            QuoteClone.Price_in_Word_Required__c = parentQuote.Price_in_Word_Required__c;
            QuoteClone.Expected_Month_of_Consolidated_Order__c = parentQuote.Expected_Month_of_Consolidated_Order__c;
            QuoteClone.SOLD_TO__c = soldTo;
            QuoteClone.SHIP_TO__c = shipTo;
            system.debug('QCOM46-00339'+parentQuote.INCO_TERMS__c);
            QuoteClone.INCO_TERMS__c = parentQuote.INCO_TERMS__c;
            system.debug('QCOM46-00339-->'+QuoteClone.INCO_TERMS__c);
            
            system.debug('QuoteClone.Status-->'+QuoteClone.Status);
            //QuoteClone.AccountId = AccountId;
            insert QuoteClone;
            system.debug('QuoteClone.Status-->'+QuoteClone.Status);
            //Set the Revision Number 000 and Original Quote Number at time of New Quote Creation.
            if(QuoteClone.id!=null){
                Quote qt = new Quote();
                qt = [Select Id, QuoteNumber,Quote_Number1__c from Quote where Id =:QuoteClone.id];
                Quote qtToUpdate = new Quote(id=qt.id);
                qtToUpdate.QU_REVISION_NUMBER__c = '000'; //QU REVISION NUMBER
                qtToUpdate.Quote_Number__c = qt.Quote_Number1__c; //Original Quote Number
                update qtToUpdate;
            }
            
            system.debug('Inserting New Quote ==> '+ QuoteClone);
            String CloneId =  QuoteClone.id; 
            String opptyId = parentQuote.OpportunityId;
            
            List<Quote_Line_Item_Custom__c> ObjQuoteLineItem = [Select id,Sr_No__c,Is_Tax__c,P_D1__c,P_D2__c,P_D3__c,P_M1__c,P_M2__c,P_M3__c,P_M4__c,Level_Of_Ceiling__c,Original_SQ_No__c,CurrencyIsoCode,Discount_Approval_Note__c,Discount_in_Value__c,Discount_Allowed_New__c,Discount_Type__c,Advance_Percentage__c, Approval_Status__c,Class__c,Division__c,Drawing_No__c,Expected_Customer_PO__c,Product__r.Model__c,
                                                                Expected_Delivery__c,Expected_Delivery_date__c,Expected_Drawing_Final__c,Product_Type__c,Scope_of_mould__c,Cavity__c,Product__r.Division__c,
                                                                Name,Mach_Mold_No__c,MFG__c,Quantity__c,Discount__c,Product_Name__c,MFG_AT__c,Class_2__c,Model__c,Is_Manual__c,Product__r.UOM__c,
                                                                List_Price__c,Product__c,Product__r.ProductCode,Quote__c,Base_Price__c,Zero_Cooling_2__c,UOM__c,Application__c,Product_Description__c,
                                                                (Select id,Discount__c,Final_Price__c,Manual_Option__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Discount_Description__c,
                                                                 Serial_Number__c,Other_Charges_Base_Price__c,Product_Type__c,Discount_in_Value__c,Discount_Type__c,Discount_Allowed_New__c,Other_Charges_Function__c,Product__c,Quote__c,Quote_Line_Item_Custom__c,Select_Option__c,Mould_Cavity__c,Price_Type__c
                                                                 from Quote_Line_Options__r order by Serial_Number__c asc)
                                                                from Quote_Line_Item_Custom__c Where Quote__c =: parentQuoteId order by sr_No__c asc];
            
            
            
            System.debug('ObjQuoteLineItem**** SIZE '+ObjQuoteLineItem.size());
            set<Id> IdOfOpQuoteItem = new Set<Id>();
            for(Quote_Line_Item_Custom__c QLN : ObjQuoteLineItem){
                IdOfOpQuoteItem.add(QLN.id);
            }
            
            List<Quote_Line_Options__c> lstQuoteOption = new List<Quote_Line_Options__c>();
            if(IdOfOpQuoteItem != null && IdOfOpQuoteItem.size() > 0){
                lstQuoteOption = [Select id,CurrencyIsoCode,Discount__c,Option_Number__c,Product_Type__c,P_D1__c,P_D2__c,P_D3__c,P_M1__c,P_M2__c,P_M3__c,P_M4__c,quantity__c,Manual_Product_Name__c, Final_Price__c,Manual_Option__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Product__r.UOM__c,Description__c,
                                  Other_Charges_Base_Price__c,Other_Charges_Function__c,Product__c,Quote__c,Discount_in_Value__c,Discount_Type__c,Discount_Allowed_New__c,Quote_Line_Item_Custom__c,Select_Option__c,Manula_Option_List_Price__c,Mould_Cavity__c,Price_Type__c,Discount_Description__c
                                  ,Serial_Number__c from Quote_Line_Options__c where Quote_Line_Item_Custom__c IN : IdOfOpQuoteItem order by Serial_Number__c asc];
            }
            
            
            List<Quote_Line_Item_Custom__c> Lst = new List<Quote_Line_Item_Custom__c>();
            List<Quote_Line_Options__c  > ListQLo = new  List<Quote_Line_Options__c >();
            List<Quote_Line_Item_Custom__c> lstContractItem = new List<Quote_Line_Item_Custom__c>();
            Map<Id,Quote_Line_Item_Custom__c> MapofQuoteContract = new Map<Id,Quote_Line_Item_Custom__c>();
            //PriceBookEntry pbe = new PriceBookEntry();
            
            User_Setup__c u=[Select id,name,Subsidiari__c,Subsidiari__r.Price_Book__c,Subsidiari__r.Additional_Margin__c,Subsidiari__r.M1__c,
                             Subsidiari__r.D1__c,Subsidiari__r.D2__c,Subsidiari__r.Rounding_Off_Digits__c from User_Setup__c 
                             where user__c=:userinfo.getUserId() limit 1];
            Quote quote=[select id,name,Language__c, Exchange_Rate__c from Quote where id=:parentQuoteId limit 1];
            String pb;
            if(u.Subsidiari__r.Price_Book__c!=null)
            {
                pb=u.Subsidiari__r.Price_Book__c;
            }
            else
                pb=[select id,name from pricebook2 where name='Standard Price Book'].id;
            
            List<Pricebookentry> titleList3 = new List<Pricebookentry>([SELECT Product2.Id, Product2.Name,UnitPrice,Product2.Product_Number__c,
                                                                        Product2.Product_Type__c,Product2.ProductCode,
                                                                        M1__c,M2__c,M3__c,D1__c,D2__c,D3__c,M4__c
                                                                        ,Rounding_Off_Digits__c,
                                                                        Base_Price__c,Quantity__c,Product2.Description
                                                                        FROM PriceBookEntry Where Product2.IsActive = TRUE 
                                                                        AND Pricebook2.id =: pb AND Product2.ProductCode != null 
                                                                        AND Product2.Family = 'Items' 
                                                                        AND M1__c != null and M2__c != null and M3__c != null and M4__c != null
                                                                        AND D1__c != null and D2__c != null and D3__c != null and Rounding_Off_Digits__c != null 
                                                                    	AND Product2.Language__c=:quote.Language__c  
                                                                        and (Product2.Subsidiari__c=:null OR Product2.Subsidiari__c=:u.Subsidiari__c) 
                                                                        ORDER BY Product2.Product_Number__c ASC]);
            
            
            
            
            Map<Id, PriceBookEntry> mapProductWisePriceEntry = new Map<Id, PricebookEntry>();
            for(PriceBookEntry eachPBE : titleList3 ){
                mapProductWisePriceEntry.put(eachPBE.Product2.Id,eachPBE);	                
            }
            System.debug('mapProductWisePriceEntry** '+mapProductWisePriceEntry.keyset().size());
            
            
            for(Quote_Line_Item_Custom__c pro1 : ObjQuoteLineItem){
                String QLIid = pro1.Id;
                Quote_Line_Item_Custom__c cli = new Quote_Line_Item_Custom__c();
                cli.CurrencyIsoCode=pro1.CurrencyIsoCode;
                if(pro1.Is_Manual__c == false){
                    cli.Sr_No__c = pro1.Sr_No__c;
                    cli.Application__c = Oppty.APPLICATION__c;
                    cli.MFG_AT__c = Oppty.MFG_AT__c;
                    cli.Class_2__c = Oppty.Class__c;
                    cli.Is_Tax__c = pro1.Is_Tax__c;
                    cli.Zero_Cooling_2__c = Oppty.Zero_Cooling__c;
                    cli.UOM__c = pro1.Product__r.UOM__c;
                    cli.Model__c = pro1.Product__r.Model__c;
                    cli.Division__c = pro1.Product__r.Division__c;
                    cli.Original_SQ_No__c = pro1.Original_SQ_No__c;
                    if( CloneId!=null && CloneId != ''){
                        cli.Quote__c = CloneId; 
                    }
                    
                    cli.P_D1__c = pro1.P_D1__c;
                    cli.P_D2__c = pro1.P_D2__c;
                    cli.P_D3__c = pro1.P_D3__c;
                    cli.P_M1__c = pro1.P_M1__c;
                    cli.P_M2__c = pro1.P_M2__c;
                    cli.P_M3__c = pro1.P_M3__c;
                    cli.P_M4__c = pro1.P_M4__c;
                    
                    
                    if(pro1.Product__c !=null){ 
                        cli.Product__c = pro1.Product__c; 
                    }
                    if(pro1.Product_Description__c !=null){ 
                       cli.Product_Description__c = pro1.Product_Description__c; 
                   }
                    if(pro1.Is_Manual__c !=null){ 
                        cli.Is_Manual__c = pro1.Is_Manual__c; 
                    }
                    
                    if(pro1.Product_Type__c !=null){ 
                        cli.Product_Type__c = pro1.Product_Type__c; 
                    }
                    if(pro1.Scope_of_mould__c !=null){ 
                        cli.Scope_of_mould__c = pro1.Scope_of_mould__c; 
                    }
                    if(pro1.Cavity__c !=null){ 
                        cli.Cavity__c = pro1.Cavity__c; 
                    }
                    //if(mapProductWisePriceEntry.containsKey(pro1.Product__c)){
                      //    decimal up=(mapProductWisePriceEntry.get(pro1.Product__c).UnitPrice);
                           //cli.List_Price__c=AddProducts.getListPrice(up, Decimal.valueOf(cRate), u.Subsidiari__r.D1__c, u.Subsidiari__r.D2__c, decimal.valueOf(QuoteAdditionalMargin),Integer.valueOf(u.Subsidiari__r.Rounding_Off_Digits__c));
                        //   cli.List_Price__c=AddProducts.getListPrice(up, Decimal.valueOf(cRate), mapProductWisePriceEntry.get(pro1.Product__c).M1__c, mapProductWisePriceEntry.get(pro1.Product__c).M2__c,mapProductWisePriceEntry.get(pro1.Product__c).M3__c,mapProductWisePriceEntry.get(pro1.Product__c).M4__c, decimal.valueOf(QuoteAdditionalMargin),Integer.valueOf(mapProductWisePriceEntry.get(pro1.Product__c).Rounding_Off_Digits__c));
                    //} else 
                    cli.List_Price__c=pro1.List_Price__c;
                    
                    if(pro1.Product_Name__c !=null){ 
                        cli.Product_Name__c = pro1.Product_Name__c; 
                    }
                    if(pro1.Quantity__c!=null){
                        cli.Quantity__c = pro1.Quantity__c; 
                    }
                    if(pro1.Advance_Percentage__c!=null){
                        cli.Advance_Percentage__c = pro1.Advance_Percentage__c; 
                    }
                       System.debug('Level of Ceiling' + pro1.Level_Of_Ceiling__c);

                    cli.Level_Of_Ceiling__c=pro1.Level_Of_Ceiling__c;
                    System.debug('Level of Ceiling' + cli.Level_Of_Ceiling__c);
                    
                   /* if(pro1.Base_Price__c != null){
                        cli.Base_Price__c = Integer.valueOf(pro1.Base_Price__c*quote.Exchange_Rate__c); //*(quantityList[i]
                        if(string.valueOf(mapProductWisePriceEntry.get(pro1.Product__c).Rounding_Off_Digits__c) !=null){
                            cli.Base_Price__c =Math.ceil(cli.Base_Price__c/Integer.valueOf(mapProductWisePriceEntry.get(pro1.Product__c).Rounding_Off_Digits__c))*Integer.valueOf(mapProductWisePriceEntry.get(pro1.Product__c).Rounding_Off_Digits__c);
                        }
                    }*/
                    
                    /*if(pro1.Base_Price__c !=null){
                        cli.Base_Price__c  = Math.ceil(pro1.Base_Price__c/Integer.valueOf(pro1.Level_Of_Ceiling__c))*Integer.valueOf(pro1.Level_Of_Ceiling__c);
                    }*/
                    
                    cli.Base_Price__c  = pro1.Base_Price__c;
                    
                    system.debug('dis'+pro1.Discount_Type__c+'  '+ pro1.Discount_in_Value__c+'  '+pro1.Discount__c+'  '+pro1.Discount_Allowed_New__c);
                    cli.Discount_Allowed_New__c = pro1.Discount_Allowed_New__c;
                     cli.Discount_Type__c = pro1.Discount_Type__c;
                    if(pro1.Discount_Type__c =='Percent'){
                       cli.Discount__c = pro1.Discount__c;
                    }else{
                        cli.Discount__c = null;
                    }
                    
                    if(pro1.Discount_Type__c =='Value'){
                       cli.Discount_in_Value__c = pro1.Discount_in_Value__c;
                    }else{
                        cli.Discount_in_Value__c = null;
                    }
                    system.debug('dis after'+cli.Discount_Type__c+'  '+ cli.Discount_in_Value__c+'  '+cli.Discount__c+''+cli.Discount_Allowed_New__c);
                    
                    
                    //cli.Discount_Description__c = pro1.Discount_Description__c;
                   
                    
                    if(pro1.Discount_Approval_Note__c != null){
                        cli.Discount_Approval_Note__c = pro1.Discount_Approval_Note__c;
                    }
                    else{ 
                        cli.Discount_Approval_Note__c = 'Null';
                    }
                    
                    
                }
                
                if(pro1.Is_Manual__c == true){
                    if(pro1.Advance_Percentage__c!=null){
                        cli.Advance_Percentage__c = pro1.Advance_Percentage__c; 
                    }
                    cli.Is_Tax__c = pro1.Is_Tax__c;
                    cli.Original_SQ_No__c = pro1.Original_SQ_No__c;
                    cli.Sr_No__c = pro1.Sr_No__c;
                    cli.Discount_Type__c = pro1.Discount_Type__c;
                    cli.Discount_in_Value__c = pro1.Discount_in_Value__c;
                    cli.Discount__c = pro1.Discount__c;
                    cli.Level_Of_Ceiling__c = pro1.Level_Of_Ceiling__c;
                     cli.Discount_Allowed_New__c = pro1.Discount_Allowed_New__c;
                    cli.Application__c = Oppty.APPLICATION__c;
                    cli.MFG_AT__c = Oppty.MFG_AT__c;
                    cli.Class_2__c = Oppty.Class__c;
                    
                    cli.P_D1__c = pro1.P_D1__c;
                    cli.P_D2__c = pro1.P_D2__c;
                    cli.P_D3__c = pro1.P_D3__c;
                    cli.P_M1__c = pro1.P_M1__c;
                    cli.P_M2__c = pro1.P_M2__c;
                    cli.P_M3__c = pro1.P_M3__c;
                    cli.P_M4__c = pro1.P_M4__c;
                    
                    
                    
                    cli.Zero_Cooling_2__c = Oppty.Zero_Cooling__c;
                    if( CloneId!=null && CloneId != ''){
                        cli.Quote__c = CloneId;
                    }
                    if(pro1.Product_Description__c !=null){ 
                       cli.Product_Description__c = pro1.Product_Description__c; 
                    }
                    
                    system.debug('dis'+pro1.Discount_Type__c+'  '+ pro1.Discount_in_Value__c+'  '+pro1.Discount__c+'  '+pro1.Discount_Allowed_New__c);
                    if(pro1.Discount_Allowed_New__c !=null) cli.Discount_Allowed_New__c = pro1.Discount_Allowed_New__c;
					//if(pro1.Discount_Type__c !=null)cli.Discount_Type__c = pro1.Discount_Type__c;
                    
                    cli.Discount_Type__c = pro1.Discount_Type__c;
                    if(pro1.Discount_Type__c =='Percent'){
                       cli.Discount__c = pro1.Discount__c;
                    }else
                        cli.Discount__c = null;

                    
                    if(pro1.Discount_Type__c =='Value'){
                       cli.Discount_in_Value__c = pro1.Discount_in_Value__c;
                    }else{
                        cli.Discount_in_Value__c = null;
                    }
                    //if(pro1.Discount_in_Value__c !=null)cli.Discount_in_Value__c = pro1.Discount_in_Value__c;
                    
                    //system.debug('dis after'+cli.Discount_Type__c+'  '+ cli.Discount_in_Value__c+'  '+cli.Discount__c+''+cli.Discount_Allowed_New__c);
                    
                    if(pro1.Product__c !=null){ 
                        cli.Product__c = pro1.Product__c; 
                    }
                    if(pro1.UOM__c !=null){ 
                        cli.UOM__c = pro1.UOM__c; 
                    }
                    
                    if(pro1.Is_Manual__c !=null){ 
                        cli.Is_Manual__c = pro1.Is_Manual__c; 
                    }
                    
                    if(pro1.Model__c !=null){ 
                        cli.Model__c = pro1.Model__c; 
                    }
                    
                    if(pro1.Division__c !=null){ 
                        cli.Division__c = pro1.Division__c; 
                    }
                    if(pro1.Product_Type__c !=null){ 
                        cli.Product_Type__c = pro1.Product_Type__c; 
                    }
                    if(pro1.Scope_of_mould__c !=null){ 
                        cli.Scope_of_mould__c = pro1.Scope_of_mould__c; 
                    }
                    if(pro1.Cavity__c !=null){ 
                        cli.Cavity__c = pro1.Cavity__c; 
                    }
                    if(pro1.List_Price__c !=null){ 
                        cli.List_Price__c = pro1.List_Price__c; 
                    }
                    if(pro1.Product_Name__c !=null){ 
                        cli.Product_Name__c = pro1.Product_Name__c; 
                    }
                    
                    if(pro1.Quantity__c!=null){
                        cli.Quantity__c = pro1.Quantity__c; 
                    }
                    if(pro1.Base_Price__c !=null)
                    {
                        cli.Base_Price__c = pro1.Base_Price__c;
                    }                    
                    //cli.Discount__c = 0.00;
                    
                    
                    if(pro1.Discount_Approval_Note__c != null){
                        cli.Discount_Approval_Note__c = pro1.Discount_Approval_Note__c;
                    }
                    else{
                        cli.Discount_Approval_Note__c = 'Null';
                    }
                }
                
                lstContractItem.add(cli);
                MapofQuoteContract.put(pro1.Id,cli);
            }  
            //try{
                insert MapofQuoteContract.values();
            //}
            //catch(Exception e){                
              //  System.debug('Error::::'+e.getMessage());
              //  result.put('error',e.getMessage());
            //}
            User UsedDeatil = new User();
            UsedDeatil = [select id,Name,Level__c,Region__c from User where id =: userInfo.getUserId()];
            String Level = UsedDeatil.Level__c;
            List<id> prodid=new List<id>();
            for(Quote_Line_Options__c pro2 :lstQuoteOption){
                prodid.add(pro2.Product__c);
            }
            
            Map<Id, PriceBookEntry> mapProductWisePriceOptionEntry = new Map<Id, PricebookEntry>();
            for(PriceBookEntry eachPBE : [SELECT Id, Product2.Id,unitprice,Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c
                                          FROM PriceBookEntry 
                                          WHERE Pricebook2Id =:u.Subsidiari__r.Price_Book__c
                                          AND IsActive=true
                                          And Product2.id in:prodid
                                          AND Product2.IsACTIVE = true AND Product2.Family = 'Options']){
                                              mapProductWisePriceOptionEntry.put(eachPBE.Product2.Id,eachPBE);	                
                                          }
            System.debug('mapProductWisePriceOptionEntry** '+mapProductWisePriceOptionEntry.keyset().size());
            
            
            for(Quote_Line_Options__c pro2 :lstQuoteOption){
                Quote_Line_Options__c ContLO =new Quote_Line_Options__c();              
                ContLO.Quote_Line_Item_Custom__c  = MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id; 
                ContLO.CurrencyIsoCode=pro2.CurrencyIsoCode;
                if( pro2.Select_Option__c == false){
                    //ContLO.Level_Of_Ceiling__c = ContLO.Level_Of_Ceiling__c;
                    ContLO.Serial_Number__c = pro2.Serial_Number__c;
                    ContLO.UOM__c = pro2.Product__r.UOM__c;
                    if(pro2.Product__c !=null){
                        ContLO.Product__c = pro2.Product__c;
                    } 
                    
                    if(pro2.Product_Type__c !=null){ 
                        ContLO.Product_Type__c = pro2.Product_Type__c; 
                    }
                    //ContLO.Discount__c = 0.00;
                    if(pro2.Description__c != null){
                        ContLO.Description__c = pro2.Description__c;
                    }
                    if(pro2.Discount_Description__c != null){
                        ContLO.Discount_Description__c = pro2.Discount_Description__c;
                    }
                    else{
                        ContLO.Discount_Description__c = 'Null';
                    }
                    if(pro2.quantity__c != null){
                        ContLO.quantity__c = pro2.quantity__c;
                    }
                    
                    ContLO.Discount_Type__c = pro2.Discount_Type__c;
                    ContLO.Discount_in_Value__c = pro2.Discount_in_Value__c;
                    ContLO.Discount__c = pro2.Discount__c;
                    
                    contLo.Discount_Description__c = pro2.Discount_Description__c;
                    contLo.Discount_Allowed_New__c = pro2.Discount_Allowed_New__c;
                    if(mapProductWisePriceOptionEntry.containsKey(pro2.Product__c)){  
                           Double up=mapProductWisePriceOptionEntry.get(pro2.Product__c).UnitPrice;
                           Double Temp=up/Decimal.valueOf(cRate); 
                           Double finalMargin=Temp*(1/(u.Subsidiari__r.Additional_Margin__c * decimal.valueOf(QuoteAdditionalMargin)));
                           Double Lprice= finalMargin * (u.Subsidiari__r.M1__c / u.Subsidiari__r.D1__c);
                           Double roundOfLprice = Math.ceil(Lprice/Integer.valueOf(u.Subsidiari__r.Rounding_Off_Digits__c))*Integer.valueOf(u.Subsidiari__r.Rounding_Off_Digits__c);
                           
                     //   ContLO.Manula_Option_List_Price__c = pro2.Manula_Option_List_Price__c; 
                    }  
                    
                    if(pro2.Manula_Option_List_Price__c != null){
                        ContLO.Manula_Option_List_Price__c = pro2.Manula_Option_List_Price__c; 
                    }
                    
                    /*if(wrp1.Base_Price__c != null){
                    //pro.Manual_Option_Base_Price__c = wrp1.Base_Price__c ;
                    pro.Manual_Option_Base_Price__c = (wrp1.Base_Price__c*objquote.Exchange_Rate__c);
                    //pro.Manual_Option_Base_Price__c = Math.ceil( pro.Manual_Option_Base_Price__c/Integer.valueOf(wrp1.Rounding_Off_Digits__c))*Integer.valueOf(wrp1.Rounding_Off_Digits__c);
                    
                    //pro.Manual_Option_Base_Price__c = Math.ceil( pro.Manual_Option_Base_Price__c/Integer.valueOf(objquote.Subsidiary__r.Rounding_Off_Digits__c))*Integer.valueOf(objquote.Subsidiary__r.Rounding_Off_Digits__c);
                }*/
                   
                    if(pro2.Manual_Option_Base_Price__c !=null){
                       ContLO.Manual_Option_Base_Price__c = pro2.Manual_Option_Base_Price__c;//*quote.Exchange_Rate__c); 
                    }
                    /*if(mapProductWisePriceOptionEntry.containsKey(pro2.Product__c))
                    {  
                        ContLO.Manual_Option_Base_Price__c = (pro2.Base_Price__c*objquote.Exchange_Rate__c);
                       // ContLO.Manual_Option_Base_Price__c = (mapProductWisePriceOptionEntry.get(pro2.Product__c).Base_Price__c/Decimal.valueOf(cRate));
                    	//ContLO.Manual_Option_Base_Price__c =math.ceil( ContLO.Manual_Option_Base_Price__c/Integer.valueOf(u.Subsidiari__r.Rounding_Off_Digits__c))*Integer.valueOf(u.Subsidiari__r.Rounding_Off_Digits__c);
                
                        //ContLO.Manual_Option_Base_Price__c = (mapProductWisePriceOptionEntry.get(pro2.Product__c).Base_Price__c)*Decimal.valueOf(cRate);
                    */
                    if(CloneId != null && CloneId !='' ){
                        ContLO.Quote__c = CloneId;
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
                    if(pro2.Mould_Cavity__c !=null){
                        ContLO.Mould_Cavity__c = pro2.Mould_Cavity__c;
                    }
                   /* if(pro2.Price_Type__c !=null){
                        ContLO.Price_Type__c = pro2.Price_Type__c;
                    }*/
                    
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
                    
                    
                    ContLO.P_D1__c = pro2.P_D1__c;
                    ContLO.P_D2__c = pro2.P_D2__c;
                    ContLO.P_D3__c = pro2.P_D3__c;
                    ContLO.P_M1__c = pro2.P_M1__c;
                    ContLO.P_M2__c = pro2.P_M2__c;
                    ContLO.P_M3__c = pro2.P_M3__c;
                    ContLO.P_M4__c = pro2.P_M4__c;
                    
                    
                }
                
                else if(pro2.Select_Option__c == true){
                    system.debug('in manual true');
                    
                    if(pro2.Product_Type__c !=null){ 
                        ContLO.Product_Type__c = pro2.Product_Type__c; 
                    }
                    //ContLO.Level_Of_Ceiling__c = ContLO.Level_Of_Ceiling__c;
                    ContLO.Serial_Number__c = pro2.Serial_Number__c;
                    contLo.Discount_Allowed_New__c = pro2.Discount_Allowed_New__c;
                    if(pro2.Description__c != null){
                        ContLO.Description__c = pro2.Description__c;
                    }
                    if(pro2.Product__c !=null){
                        ContLO.Product__c = pro2.Product__c;
                    } 
                    //ContLO.Discount__c=0.00;
                    if(pro2.Discount_Description__c != null){
                        ContLO.Discount_Description__c = pro2.Discount_Description__c;
                    }
                    else{
                        ContLO.Discount_Description__c = 'Null';
                    }
                    if(pro2.quantity__c != null){
                        ContLO.quantity__c = pro2.quantity__c;
                    }
                    if(pro2.Manula_Option_List_Price__c != null){
                        ContLO.Manula_Option_List_Price__c = pro2.Manula_Option_List_Price__c;
                    }
                    if(pro2.Manual_Option_Base_Price__c != null){
                        ContLO.Manual_Option_Base_Price__c = pro2.Manual_Option_Base_Price__c;
                    }
                    if(CloneId != null && CloneId !='' ){
                        ContLO.Quote__c = CloneId;
                    }
                    if(pro2.Manual_Option__c !=null){
                        ContLO.Manual_Option__c = pro2.Manual_Option__c;
                    }
                    if(pro2.description__c !=null){
                        ContLO.description__c = pro2.description__c;
                    }
                    /*if(pro2.Price_Type__c !=null){
                        ContLO.Price_Type__c = pro2.Price_Type__c;
                    }*/
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
                    
                    ContLO.Discount_Type__c = pro2.Discount_Type__c;
                    ContLO.Discount_in_Value__c = pro2.Discount_in_Value__c;
                    ContLO.Discount__c = pro2.Discount__c;
                    
                    contLo.Discount_Description__c = pro2.Discount_Description__c;
                    contLo.Discount_Allowed_New__c = pro2.Discount_Allowed_New__c;
                }
                ListQLo.add(ContLO);
            }  
            //System.debug('ListQLo==> '+ListQLo);
            //try
            //{
                insert ListQLo;
            //}
            //catch(Exception e)
            //{
              //  system.debug('Exception'+e.getMessage()+'====e.'+e.getLineNumber());
              //  result.put('error',e.getMessage());
            //} 
            
            //opportunityId = recordId; 
            Opportunity opptyToUpdate = new Opportunity(id=opportunityId);            
            opptyToUpdate.stageName = 'Under Quotation';
            update opptyToUpdate;
            
            System.debug('QuoteClone'+QuoteClone);
            System.debug('CloneId'+CloneId);
            
            List<Attachment> lstAtt = new List<Attachment>();
            lstAtt = [select id, name, body, LastModifiedDate, Createddate , createdby.name,ParentId from Attachment where ParentId=:CloneId ];
            
            lstAtt.clear();
            result.put('Id',CloneId);
            system.debug('result'+result);
            //return result;
        }
        
           /*}else{
            return result;
           } */ 
         }catch(exception e){                
                result.put('error',e.getMessage());
                System.debug('Error::::'+e.getMessage());
                //return result;
            }
        System.debug('Error::::'+result);
             if(result !=null){
                 return result;
                 
             }else{
                 return result;
             }
        
    }
    
    @AuraEnabled
    public static Boolean importQuoteFromCSV(String csvFileBody, String recordId) {
        try {
            UserSetup us=getQuoteNumber();
            Unique_No__c u=[select id,name,Serial_No__c,Object_Name__c,Subsidiary__c,Fiscal_Year__c from Unique_No__c where
                            Subsidiary__c=:us.Subsidiari and Fiscal_Year__c=:us.FY and Object_Name__c='Quote' For Update];
            String csvAsString = String.valueOf(csvFileBody);
            List<String> csvFileLines = csvAsString.split('\n'); 
            system.debug('csvFileBody--->' + csvFileBody);
            system.debug('csvAsString--->' + csvAsString);
            system.debug('csvFileLines-->' + csvFileLines);
            List<Quote> QuoteList = new List<Quote>();
            Opportunity objoppty = new Opportunity();
            objoppty = [Select id,name,AccountId,Account.name,Account.CurrencyISOCode from opportunity where id=:recordId];
            Quote_Template__c qtemp=[select id,name,Subsidiary__c from Quote_Template__c where Subsidiary__c=:us.Subsidiari and Language__c=:us.lang limit 1];
            
            CurrencyType ctype=[select Id, IsCorporate, IsoCode, ConversionRate, DecimalPlaces from CurrencyType where IsActive=true and IsoCode=:objoppty.Account.CurrencyISOCode limit 1 ];
            
            for(Integer i=1;i<csvFileLines.size();i++){
                string[] csvRecordData = csvFileLines[i].split(',');
                Quote accObj = new Quote() ;  
                accObj.name = csvRecordData[0] ;             
                accObj.OpportunityId = recordId;
                accObj.QUOTATION_CREATE__c = 'CREATE FROM TEMPLATE';
                accObj.Freight__c = 'By Buyer';
                accObj.Insurance__c = 'By Buyer';
                accObj.Fiscal_Year_Master__c=us.FY;
                accObj.Subsidiary__c=us.Subsidiari;
                accObj.Exchange_Rate__c=cType.ConversionRate;
                accObj.Language__c=us.lang;
                accObj.Quote_Template__c=qtemp.id;
                accObj.Quote_Number1__c=generateAutoNumber(i,us.QuoteNo);
                accObj.QU_REVISION_NUMBER__c='000';
                QuoteList.add(accObj);   
            }
            System.debug('u.Serial_No__c'+u.Serial_No__c);
            System.debug('csvFileLines.size()'+csvFileLines.size());
            u.Serial_No__c=u.Serial_No__c+csvFileLines.size()-2;
            update u;
            insert QuoteList;
            return true;
        }
        catch (Exception e)
        {
            System.debug('execp--->' + e);
            return false;
        }
    }   
    // This function is togenerate Auto number in case of bulk Quote upload
    public static String generateAutoNumber(Integer i,String QuoteNo)
    {
        String qNumber;
        if(i>1) 
        {
            String onlyNo=QuoteNo.substring(QuoteNo.length()-5,QuoteNo.length() );
            Integer n=Integer.valueOf(onlyNo)+i-1;
            String temp='';
            for(Integer j=5;j>String.valueof(n).length();j--)
            {
                temp=temp+'0';
                
            }
            temp=temp+String.valueof(n);
            qNumber=QuoteNo.substring(0,QuoteNo.length()-5)+temp;
        }
        else
        {
            qNumber=QuoteNo;
        }
        return  qNumber;
    }
    //V1.1 this logic is to creat Quote no for Single record Creation
    public static UserSetup getQuoteNumber()
    {
        //updated This logic to assign fy and Subsidiary
        UserSetup us=new UserSetup();
        Fiscal_Year_Master__c f=[select id,name from Fiscal_Year_Master__c where Active__c=true limit 1];
        Map<id,Unique_No__c> sMap=new Map<id,Unique_No__c>();
        // Get Last Count
        for(Unique_No__c u:[select id,name,Serial_No__c,Object_Name__c,Subsidiary__c,Fiscal_Year__c from Unique_No__c where Fiscal_Year__c=:f.id and
                            Object_Name__c='Quote' For Update])
        { 
            sMap.put(u.Subsidiary__c,u);
        }
        
        User_Setup__c u=[select id,name,User__c,Subsidiari__c,Subsidiari__r.name,Default_Language__c  from User_Setup__c where User__c =: Userinfo.getUserId()];
        if(sMap.containskey(u.Subsidiari__c)){
            Unique_No__c un=sMap.get(u.Subsidiari__c);
            String temp='';
            
            for(Integer i=5;i>String.valueof(un.Serial_No__c+1).length();i--)
            {
                temp=temp+'0';
                
            }
            temp=temp+String.valueof(un.Serial_No__c+1);
            us.QuoteNo='Q'+u.Subsidiari__r.name+f.Name+'-'+temp;
            un.Serial_No__c=un.Serial_No__c+1;
            sMap.put(u.Subsidiari__c,un);
        }
        else
        {
            us.QuoteNo='Q'+u.Subsidiari__r.name +f.Name+'-00001';
            Unique_No__c un=new Unique_No__c();
            un.Object_Name__c='Quote';
            un.Subsidiary__c=u.Subsidiari__c;
            un.Fiscal_Year__c=f.id;
            un.Serial_No__c=1;  
            sMap.put(u.Subsidiari__c,un);
        } 
        upsert sMap.values();
        us.FY=f.id;  
        us.Subsidiari=u.Subsidiari__c;
        us.lang=u.Default_Language__c;
        return us;
    }
    Public Class UserSetup {
        public String FY;
        Public String Subsidiari;
        Public String QuoteNo;
        public String lang;
    }
    //V1.1 end
    
    public class DataWrapper {
        @AuraEnabled public opportunity objopty;
        @AuraEnabled public  List<Quote> lstQt;
        @AuraEnabled public  Decimal cRate;
        @AuraEnabled public Decimal AddionalMargin;
        @AuraEnabled public Boolean checkPermission;
        public DataWrapper(opportunity objopty, List<Quote> lstQt,Decimal cRate, Decimal AddionalMargin, Boolean checkPermission){
            this.objopty = objopty;
            this.lstQt = lstQt;
            this.cRate = cRate;
            this.AddionalMargin = AddionalMargin;
            this.checkPermission = checkPermission;
        }
    } 
    
}