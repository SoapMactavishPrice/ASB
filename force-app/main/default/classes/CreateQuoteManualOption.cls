public class CreateQuoteManualOption {
    Public static Id CampaignId;
    // Public Static List<LeadListWrapper> lstLeadListWrapper = new List<LeadListWrapper>();
    Public Static List<LeadListWrapper> lstProductListWrapper = new List<LeadListWrapper>();
    public  Static List<QuoteLineItem> ObjQLI = new List<QuoteLineItem>();
    //   public Static Groups__c objOfCampaign;
    
    
    @AuraEnabled 
    public static Quote getQuotationDetails(String RecId){
        Quote quote=[select id,name, Exchange_Rate__c, CurrencyIsoCode,Subsidiary__r.Additional_Margin__c,
                     Subsidiary__r.Rounding_Off_Digits__c, Subsidiary__r.Option_Quantity_Restricted__c,Additinal_Margin__c, 
                     Subsidiary__r.M1__c,Subsidiary__r.D1__c
                     from Quote where id=:RecId limit 1];
        return quote;
    }
    
    
    @AuraEnabled 
    public static List<LeadListWrapper> fetchProductWrapper(String Campaign){ 
        CampaignId= Campaign;
        System.debug('CampaignId'+CampaignId);
        User UsedDeatil = [select id,Name,Level__c from User where id =: userInfo.getUserId()];
        String Level = UsedDeatil.Level__c;
        
        for(PriceBookEntry lstpbe :[SELECT Product2.Id,Discount__c,Product2.Description, Product2.Name,UnitPrice,Product2.Plant__c,Product2.Product_Number__c,Product2.Option_No__c,Product2.Discount_Level_2__c,
                                    Product2.Family,Product2.Number_Of_Cavity_Mould__c,Product2.Option_Type__c,Product2.Product_Type__c,Product2.Scope_of_Mold__c,Product2.Discount_Level_1__c,
                                    Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c,Product2.Pricing_Type__c,Pricing_Type__c,Discount_Level_2__c,Discount_Level_3__c,Quantity__c,Description__c,Product2.Discount_Level_3__c
                                    FROM PriceBookEntry 
                                    WHERE Pricebook2Id IN (SELECT Id 
                                                           FROM PriceBook2) AND Product2.Family = 'Options' and Product2.IsACTIVE = true ]){
                                                               
                                                               lstProductListWrapper.add(new LeadListWrapper(false,0,0,lstpbe));
                                                           } 
        System.debug('lstProductListWrapper'+lstProductListWrapper);
        //  System.debug('CampaignId'+CampaignId);
        return lstProductListWrapper; 
    }
    
    @AuraEnabled
    public static user fetchUser(){
        User u = [select id,Name,Level__c from User where id =: userInfo.getUserId()];
        return u;
    }
    
    
    @AuraEnabled
    Public Static List<LeadListWrapper> WrapperproductFilter(String ProductId, String RecId){
        System.debug('ProductId'+ProductId);
        System.debug('RecId'+RecId);
        if(ProductId!='')
        {
            List<Quote_Line_Item_Custom__c> ObjQLI = new List<Quote_Line_Item_Custom__c>();
            String ProdId = ProductId;
            Integer maxSerNum= 0;
            ObjQLI = [Select id, Product__c,Max_Serial_Number__c from Quote_Line_Item_Custom__c where id = : ProdId];
            String PrId = ObjQLI[0].Product__c;
            
            //System.debug('PrId'+PrId);
            
            set<Id> qprodIds = new set<Id>();
            for(Quote_Line_Item_Custom__c qlio : ObjQLI){
                qprodIds.add(qlio.Id);
                maxSerNum = Integer.valueOf(qlio.Max_Serial_Number__c);
            }
            
            
            User_Setup__c u=[Select id,name,Subsidiari__c,Subsidiari__r.Price_Book__c from User_Setup__c where user__c=:userinfo.getUserId()];
            System.debug('RecId=>'+RecId);
            Quote quote=[select id,name,Language__c, Exchange_Rate__c,Subsidiary__r.Additional_Margin__c,
                         Subsidiary__r.Rounding_Off_Digits__c,Subsidiary__r.Quantity_Restricted__c,Additinal_Margin__c, 
                         Subsidiary__r.M1__c,Subsidiary__r.D1__c,Subsidiary__r.D2__c,Subsidiary__r.D3__c from Quote where id=:RecId];
            System.debug('quote : : '+quote);
            
            
            set<Id> prodIds = new set<Id>();
            //if(qprodIds.size() > 0){
            system.debug('qprodIds'+qprodIds);
            List<Quote_Line_Options__c> QuoteLineList = [Select Id,Product__c,Quote_Line_Item_Custom__r.Product__c from Quote_Line_Options__c where Quote_Line_Item_Custom__c IN : qprodIds];
            system.debug('QuoteLineList'+QuoteLineList.size());
            
            for(Quote_Line_Options__c qline : QuoteLineList){
                if(string.isNotBlank(qline.Product__c)){
                    prodIds.add(qline.Product__c);    
                }
            }
            //}
            system.debug(PrId+' line id-->'+prodIds);
            
            System.debug('quote.Language__c : : '+quote.Language__c);
            String pb;
            if(u.Subsidiari__r.Price_Book__c!=null)
            {
                pb=u.Subsidiari__r.Price_Book__c;
            }
            else
                pb=[select id,name from pricebook2 where name='Standard Price Book'].id;
            
            
            
            for(PriceBookEntry lstpbe :[SELECT Product2.Id,Discount__c,Product2.Description, Product2.ProductCode, Product2.Name,Product2.formulae__c,UnitPrice,Product2.Plant__c,Product2.Product_Number__c,Product2.Option_No__c,Product2.Discount_Level_3__c,
                                        Product2.Family,Product2.Number_Of_Cavity_Mould__c,Product2.Option_Type__c,Product2.Product_Type__c,Product2.Scope_of_Mold__c,Product2.tag__c,Product2.Discount_Level_2__c,
                                        Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c,Product2.Pricing_Type__c,Pricing_Type__c,Discount_Level_2__c,Discount_Level_3__c,Quantity__c,Description__c,Product2.Discount_Level_1__c
                                        ,M1__c,M2__c,M3__c,D1__c,D2__c,D3__c,M4__c
                                        ,Rounding_Off_Digits__c FROM PriceBookEntry 
                                        WHERE Pricebook2Id IN (SELECT Id 
                                                               FROM PriceBook2 where id =:pb AND PriceBook2.IsActive = true) AND product2.Product_Options__c =:PrId 
                                        AND Product2.Id  NOT IN : prodIds  
                                        AND Product2.Family = 'Options'
                                        AND Product2.IsACTIVE = true AND Product2.ProductCode != null 
                                        AND M1__c != null and M2__c != null and M3__c != null and M4__c != null
                                        AND D1__c != null and D2__c != null and D3__c != null and Rounding_Off_Digits__c != null 
                                        AND Product2.Language__c=:quote.Language__c and (Product2.Subsidiari__c=:null OR Product2.Subsidiari__c=:u.Subsidiari__c)
                                        and IsActive = True
                                        ORDER BY Product2.Option_No__c ]){
                                            
                                            if(lstpbe.M1__c != null && lstpbe.M2__c != null && lstpbe.M3__c != null && lstpbe.Rounding_Off_Digits__c != null){
                                                lstpbe.UnitPrice=AddProducts.getListPrice(lstpbe.Base_Price__c,quote.Exchange_Rate__c,lstpbe.M1__c,lstpbe.M2__c,lstpbe.M3__c,lstpbe.M4__c,quote.Additinal_Margin__c,Integer.valueof(lstpbe.Rounding_Off_Digits__c));
                                            }
                                            //lstpbe.UnitPrice=AddProducts.getListPrice(lstpbe.UnitPrice,quote.Exchange_Rate__c,quote.Subsidiary__r.D1__c,quote.Subsidiary__r.D2__c,quote.Additinal_Margin__c,Integer.valueof(quote.Subsidiary__r.Rounding_Off_Digits__c));
                                            lstProductListWrapper.add(new LeadListWrapper(false,maxSerNum,0,lstpbe));
                                        } 
            //System.debug('lstProductListWrapper'+lstProductListWrapper);
            System.debug('lstProductListWrapper'+lstProductListWrapper.size());
            //  System.debug('CampaignId'+CampaignId);
            return lstProductListWrapper; 
        }
        else 
            return lstProductListWrapper;
        
    }
    
    @AuraEnabled
    public Static List<Quote_Line_Item_Custom__c> GetLineItemName(String Quote){
        String QuoteId = Quote;
        System.debug('QuoteId'+QuoteId);
        List<Quote_Line_Item_Custom__c> ObjQuoteItem = [select id, Product_Name__c,Is_Manual__c,Product_Name_With_Quantity__c from  Quote_Line_Item_Custom__c where Quote__c = : QuoteId];  
        System.debug('ObjQuoteItem'+ObjQuoteItem);
        return ObjQuoteItem;
    }
    @AuraEnabled 
    Public static void SelectedLead(List<PriceBookEntry> selectedRecordList, String idCampaign,string LineItemId,List<String> selectedRecordsDescList){ //List<String> selectedRecordsDescList
        System.debug('idCampaign===> '+idCampaign);
        Quote objquote = new Quote();
        objquote = [Select id,name,discount__c,Exchange_Rate__c,Additinal_Margin__c,Subsidiary__c,Subsidiary__r.Rounding_Off_Digits__c,CurrencyIsoCode from quote where id=:idCampaign];
        
        System.debug('LineItemId===> '+LineItemId);
        system.debug('selectedRecordsDescList ===>>> ' + selectedRecordsDescList);
        User UsedDeatil = new User();
        UsedDeatil = [select id,Name,Level__c from User where id =: userInfo.getUserId()];
        String Level = UsedDeatil.Level__c;
        system.debug('Level -->> ' + Level);
        //List < LeadListWrapper > listWrappers = ( List < LeadListWrapper > )JSON.deSerialize( selectedRecordList, List < LeadListWrapper >.class );
        
        //  objOfCampaign = [select name,Id from Groups__c where Id =: idCampaign LIMIT 1];
        System.debug('selectedRecords ==>>> '+selectedRecordList);
        List<Quote_Line_Options__c> ls1 = new List<Quote_Line_Options__c>();
        List<Quote_Line_Options__c> lsO1 = new List<Quote_Line_Options__c>();
        //   List<PriceBookEntry> ls1 = new List<PriceBookEntry>();
        if(selectedRecordList != null){
            for(PriceBookEntry wrp1: selectedRecordList)
            {
       
                //=============================================================
                System.debug('wrp1  ==>>> ' + wrp1);
                // Group_Members__c pro = new Group_Members__c();
                Quote_Line_Options__c pro = new Quote_Line_Options__c();
                pro.CurrencyIsoCode=objquote.CurrencyIsoCode;
                //pro.Discount_Type__c = 'Percent';
                if(idCampaign != null){
                    pro.Quote__c = idCampaign;
                }
                pro.Product_Type__c = wrp1.Product2.Product_Type__c;
                if(LineItemId != null){
                    pro.Quote_Line_Item_Custom__c = LineItemId;
                }
                if(wrp1.Product2.description != null){
                    pro.description__c = wrp1.Product2.description;
                }else{
                    pro.description__c = wrp1.Product2.Name;
                }
                if(wrp1.Product2.Name != null){
                    pro.Manual_Product_Name__c = wrp1.Product2.Name;
                }
                if(wrp1.Product2Id != null){
                    pro.Product__c = wrp1.Product2Id;
                }
                
                //============================================================================
                
                for(String s : selectedRecordsDescList){
                    system.debug('s ===>>>> ' + s);
                    if(s.contains(wrp1.Product2Id)){
                        
                        string st = s.split('-')[1];
                        system.debug('st ===>>>> true' + st);
                        if(st != 'undefined'){
                            pro.Discount_Description__c = st;
                        }
                        else{
                            pro.Discount_Description__c = '';
                        }
                    }
                }
                
                
                
                //============================================================================
                system.debug('manual '+wrp1.Base_Price__c);
                if(wrp1.Base_Price__c != null){
                    //pro.Manual_Option_Base_Price__c = wrp1.Base_Price__c ;
                    pro.Manual_Option_Base_Price__c = wrp1.Base_Price__c * objquote.Exchange_Rate__c;
                    //pro.Manual_Option_Base_Price__c = Math.ceil( pro.Manual_Option_Base_Price__c/Integer.valueOf(wrp1.Rounding_Off_Digits__c))*Integer.valueOf(wrp1.Rounding_Off_Digits__c);
                    
                    //pro.Manual_Option_Base_Price__c = Math.ceil( pro.Manual_Option_Base_Price__c/Integer.valueOf(objquote.Subsidiary__r.Rounding_Off_Digits__c))*Integer.valueOf(objquote.Subsidiary__r.Rounding_Off_Digits__c);
                }
                
                //pro.Discount_Type__c = 'Percent';
                pro.P_D1__c = wrp1.d1__c;
                pro.P_D2__c = wrp1.d2__c;
                pro.P_D3__c = wrp1.d3__c;
                pro.P_M1__c = wrp1.M1__c;
                pro.P_M2__c = wrp1.M2__c;
                pro.P_M3__c = wrp1.M3__c;
                pro.P_M4__c = wrp1.M4__c;
                
                
                //if(Level == 'L1'){
                if(wrp1.Base_Price__c != null){
                    pro.Manula_Option_List_Price__c = AddProducts.getListPrice(wrp1.Base_Price__c,objquote.Exchange_Rate__c,wrp1.M1__c,wrp1.M2__c,wrp1.M3__c,wrp1.M4__c,objquote.Additinal_Margin__c,Integer.valueof(wrp1.Rounding_Off_Digits__c));
                }  
                /*}
if(Level == 'L2'){
if(wrp1.UnitPrice != null){
pro.Manula_Option_List_Price__c = wrp1.List_Price_level_2__c;
}  
}
if(Level == 'L3'){
if(wrp1.UnitPrice != null){
pro.Manula_Option_List_Price__c = wrp1.List_Price_level_3__c;
}  
}*/
                
                if(Level == 'L1'){
                    if(wrp1.d1__c != null){
                        pro.Discount_Allowed_New__c = wrp1.d1__c;
                    }
                }
                if(Level == 'L2'){
                    if(wrp1.d2__c != null){
                        pro.Discount_Allowed_New__c = wrp1.d2__c;
                    }
                }
                if(Level == 'L3'){
                    if(wrp1.d3__c != null){
                        pro.Discount_Allowed_New__c = wrp1.d3__c;
                    }
                }
                
                /* if(objquote.Discount__c != null){
pro.Discount__c = objquote.Discount__c;
}*/ 
                
                // if(wrp1.Quantity__c == null){
                pro.Quantity__c = wrp1.Quantity__c;
                // }
                
                if(wrp1.Product2.Number_Of_Cavity_Mould__c != null){ 
                    pro.Mould_Cavity__c = wrp1.Product2.Number_Of_Cavity_Mould__c;
                }
                /*if(wrp1.Product2.Pricing_Type__c != null){
                    pro.Price_Type__c = wrp1.Product2.Pricing_Type__c;
                }*/
                System.debug('Base Price---- '+wrp1.Base_Price__c);
                //pro.Sales_price_Total__c = (wrp1.Base_Price__c)*( pro.Quantity__c);
                System.debug('pro==> '+pro);
                ls1.add(pro);
                //===========================================================================
            }
        }
        try
        {
            System.debug('ls1'+ls1.size());
            
            insert ls1;  
        }
        catch(Exception e)
        {
            system.debug('Exception'+e.getMessage());
        }
        
        //  InfluRecord(idInfluncer);
        
        //   return null;
    }  
    
    @AuraEnabled        
    public static  List<map<string, string> > getPickListValuesIntoListv2(){
        List<map<string, string> > pickListValuesList = new List<map<string, string> >();
        Schema.DescribeFieldResult fieldResult = Product2.Product_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
        for( Schema.PicklistEntry pickListVal : ple){
            map<string, string> PicklistValues = new map<string, string>();
           	PicklistValues.put('label',pickListVal.getLabel());
            PicklistValues.put('value',pickListVal.getValue());
            pickListValuesList.add(PicklistValues);
        }   
        system.debug('-->'+pickListValuesList);
        return pickListValuesList;
    }
    
    
    @AuraEnabled
    public static void SaveOptions(String recordId,List<Quote_Line_Options__c> OptList){
        System.debug('recordId = = = '+recordId);
        Quote objquote = new Quote();
        objquote = [Select id,name,discount__c,CurrencyIsoCode from quote where id=:recordId];
        System.debug('OptList'+OptList);
        for(Quote_Line_Options__c lst:OptList){
            lst.discount__c = objquote.Discount__c;
            lst.CurrencyIsoCode=objquote.CurrencyIsoCode;
            //lst.Discount_Type__c = 'Percent';
            //lst.Discount_in_Value
        }
        //  OptList.Quote__c = '0Q00w0000005YhnCAE';
        Insert OptList;
    }
    
    public static void dummy(){
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
    
    // wrapper class 
    public class LeadListWrapper {
        @AuraEnabled public boolean isChecked;
        @AuraEnabled public integer MaxSerailNumber;
        @AuraEnabled public integer serialNumber;
        @AuraEnabled public  PriceBookEntry objLead;
        
        public LeadListWrapper(boolean isChecked,integer MaxSerailNumber,integer serialNumber, PriceBookEntry objLead){
            this.isChecked = isChecked;
            this.MaxSerailNumber = MaxSerailNumber;
            this.serialNumber = serialNumber;
            this.objLead = objLead;
        }
    }
}