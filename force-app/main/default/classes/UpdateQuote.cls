public class UpdateQuote {
    
    @AuraEnabled
    public static string getAccountAddress(string Id){
        Account acc =  [Select Id,Shipping_Sub_Region__r.Name,Shipping_State__r.Name,Shipping_Region_Master__c,Shipping_Postal_ZIP_Code__r.Name,Shipping_Country__r.Name,Shipping_City__r.Name,
                        Shipping_Address_Line_3__c,Shipping_Address_Line_2__c,Shipping_Address_Line_1__c,
                        ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,Billing_City__r.Name,Billing_Country__r.Name,Billing_Postal_ZIP_Code__r.Name,Billing_State__r.Name,
                        Global_Region__c,Global_SubRegion__c
                        from Account where Id =:Id Limit 1];
        
        AccountWrapper accWrp= new AccountWrapper();
        
        accWrp.shippingSubRegionName = acc.Shipping_Sub_Region__c;
        accWrp.shippingStateName = acc.Shipping_State__r != null ? acc.Shipping_State__r.Name : null;
        accWrp.shippingRegionMaster = acc.Shipping_Region_Master__c;
        accWrp.shippingPostalZipCode = acc.Shipping_Postal_ZIP_Code__r != null ? acc.Shipping_Postal_ZIP_Code__r.Name : null;
        accWrp.shippingCountryName = acc.Shipping_Country__r != null ? acc.Shipping_Country__r.Name : null;
        accWrp.shippingCityName = acc.Shipping_City__r != null ? acc.Shipping_City__r.Name : null;
        accWrp.shippingAddressLine3 = acc.Shipping_Address_Line_3__c;
        accWrp.shippingAddressLine2 = acc.Shipping_Address_Line_2__c;
        accWrp.shippingAddressLine1 = acc.Shipping_Address_Line_1__c;
        
        accWrp.addressLine1 = acc.ADDRESS_LINE_1__c;
        accWrp.addressLine2 = acc.ADDRESS_LINE_2__c;
        accWrp.addressLine3 = acc.ADDRESS_LINE_3__c;
        accWrp.billingCityName = acc.Billing_City__r != null ? acc.Billing_City__r.Name : null;
        accWrp.billingCountryName = acc.Billing_Country__r != null ? acc.Billing_Country__r.Name : null;
        accWrp.billingPostalZipCode = acc.Billing_Postal_ZIP_Code__r != null ? acc.Billing_Postal_ZIP_Code__r.Name : null;
        accWrp.billingStateName = acc.Billing_State__r != null ? acc.Billing_State__r.Name : null;
        accWrp.globalRegion = acc.Global_Region__c;
        accWrp.globalSubRegion = acc.Global_SubRegion__c;
        
        return JSON.serialize(accWrp);
        
        
    }  
    
    
    @AuraEnabled
    public static String updateQuoteAddress(Id accountId, string JS) {
        system.debug(JS);
        List<Map<string,object>> resultList = new List<Map<string,object>>();
        try {
            List<Quote> quotes = [SELECT Id, ADDRESS_LINE_1__c ,ADDRESS_LINE_2__c ,ADDRESS_LINE_3__c ,CityCustom__c ,CountryCustom__c ,POSTAL_CODE__c ,StateCustom__c,Global_SubRegion__c,Global_Region__c 
                                  ,SHIP_TO_ADDRESS_LINE_1__c,SHIP_TO_ADDRESS_LINE_2__c,SHIP_TO_ADDRESS_LINE_3__c,Ship_To_City__c,Ship_To_Country__c,SHIP_TO_POSTAL_CODE__c,
                                  Ship_To_State__c,Ship_To_Global_Region__c,Ship_To_Global_SubRegion__c
                                  FROM Quote WHERE AccountId = :accountId and (Status=:'Created' or Status=:'Released' or Status=:'CLOSE - SC CREATED')] ;
            
            Map<string,object> objMap =(Map<string,object>)JSON.deserializeUntyped(JS);
            List<Quote> quotesUpdate = new List<Quote>();

            System.debug('addressLine >> ' +(string)objMap.get('addressLine1'));
            System.debug('quote Size >> '+quotes.size());

            if (quotes.size() > 0) {
                for(Quote qt: quotes){
                    System.debug('qt.ADDRESS_LINE_1__c >> '+qt.ADDRESS_LINE_1__c);
                    qt.ADDRESS_LINE_1__c = (string)objMap.get('addressLine1');
                    qt.ADDRESS_LINE_2__c = (string)objMap.get('addressLine2');
                    qt.ADDRESS_LINE_3__c = (string)objMap.get('addressLine3');
                    
                    qt.CityCustom__c = (string)objMap.get('billingCityName');
                    qt.CountryCustom__c = (string)objMap.get('billingCountryName');
                    qt.POSTAL_CODE__c = (string)objMap.get('billingPostalZipCode');
                    qt.StateCustom__c = (string)objMap.get('billingStateName');
                  //  qt.Global_Region__c = (Id)objMap.get('globalRegion');
                  //  qt.Global_SubRegion__c = (Id)objMap.get('globalSubRegion');
                    
                    
                    qt.SHIP_TO_ADDRESS_LINE_1__c = (string)objMap.get('shippingAddressLine1');
                    qt.SHIP_TO_ADDRESS_LINE_2__c = (string)objMap.get('shippingAddressLine2');
                    qt.SHIP_TO_ADDRESS_LINE_3__c = (string)objMap.get('shippingAddressLine3');
                    
                    qt.Ship_To_City__c = (string)objMap.get('shippingCityName');
                    qt.Ship_To_Country__c = (string)objMap.get('shippingCountryName');
                    qt.SHIP_TO_POSTAL_CODE__c = (string)objMap.get('shippingPostalZipCode');
                    qt.Ship_To_State__c = (string)objMap.get('shippingStateName');
                    //qt.Ship_To_Global_Region__c = (Id)objMap.get('shippingRegionMaster');
                    //qt.Ship_To_Global_SubRegion__c = (Id)objMap.get('shippingSubRegionName');
                    
                    quotesUpdate.add(qt);
                }
                
                if(quotesUpdate.size() > 0){
                    update quotesUpdate;
                }
                Map<string,object> result =  new Map<string,object>();
                result.put('status',true);
                result.put('Variant','success');
                result.put('message','Quote Updated Succesfully !!!!');
                resultList.add(result);
            } else {
                Map<string,object> result =  new Map<string,object>();
                result.put('status',true);
                result.put('Variant','Info');
                result.put('message','Quote Not Found.We Moving forward to Contract');
                resultList.add(result);
            }
        } catch (Exception e) {
            Map<string,object> result =  new Map<string,object>();
            result.put('status',false);
            result.put('Variant','info');
            result.put('message',e.getMessage());
            resultList.add(result);
        }
        
        return JSON.serialize(resultList);
    }
    
    @AuraEnabled
    public static String updateContractAddress(Id accountId, string JS) {
        List<Map<string,object>> resultList = new List<Map<string,object>>();
        try {
            Map<string,object> objMap =(Map<string,object>)JSON.deserializeUntyped(JS);
            List<Contract> quotes = [SELECT Id, ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,City_Text__c,Country_Text__c,POSTAL_CODE__c,State_Text__c,Global_SubRegion__c,Global_Region__c, 
                                     
                                     ADDRESS_LINE_ShipTo_1__c,ADDRESS_LINE_ShipTo_2__c,ADDRESS_LINE_ShipTo_3__c,Ship_To_City__c,Ship_To_Country__c,POSTAL_CODE_ShpTo__c,Ship_To_State__c,
                                     Ship_To_Global_Region__c,
                                     Ship_To_Global_SubRegion__c FROM Contract WHERE AccountId = :accountId and (Status=:'Created' or Status=:'Released') limit 1] ;
            List<Contract> quotesUpdate = new List<Contract>();
            if (quotes.size() > 0) {
                
              
                    for(Contract qt: quotes){
                        qt.ADDRESS_LINE_1__c = (string)objMap.get('addressLine1');
                        qt.ADDRESS_LINE_2__c = (string)objMap.get('addressLine2');
                        qt.ADDRESS_LINE_3__c = (string)objMap.get('addressLine3');
                        
                        qt.City_Text__c = (string)objMap.get('billingCityName');
                        qt.Country_Text__c = (string)objMap.get('billingCountryName');
                        qt.POSTAL_CODE__c = (string)objMap.get('billingPostalZipCode');
                        qt.State_Text__c = (string)objMap.get('billingStateName');
                        //qt.Global_Region__c = (Id)objMap.get('globalRegion');
                        //qt.Global_SubRegion__c = (Id)objMap.get('globalSubRegion');
                        
                        qt.ADDRESS_LINE_ShipTo_1__c = (string)objMap.get('shippingAddressLine1');
                        qt.ADDRESS_LINE_ShipTo_2__c = (string)objMap.get('shippingAddressLine2');
                        qt.ADDRESS_LINE_ShipTo_3__c = (string)objMap.get('shippingAddressLine3');
                        
                        qt.Ship_To_City__c = (string)objMap.get('shippingCityName');
                        qt.Ship_To_Country__c = (string)objMap.get('shippingCountryName');
                        qt.POSTAL_CODE_ShpTo__c = (string)objMap.get('shippingPostalZipCode');
                        qt.Ship_To_State__c = (string)objMap.get('shippingStateName');
                        //qt.Ship_To_Global_Region__c = (Id)objMap.get('shippingRegionMaster');
                        //qt.Ship_To_Global_SubRegion__c = (Id)objMap.get('shippingSubRegionName');
                        
                        quotesUpdate.add(qt);
                    }
                    
                    if(quotesUpdate.size() > 0){
                        update quotesUpdate;
                    }
                    Map<string,object> result =  new Map<string,object>();
                    result.put('status',true);
                    result.put('Variant','success');
                    result.put('message','Contract Updated Succesfully !!!!');
                    resultList.add(result);
                
            } else {
                Map<string,object> result =  new Map<string,object>();
                result.put('status',true);
                result.put('Variant','info');
                //result.put('message','Contract Not Found.We Moving forward to Project Management');
                result.put('message','Contract Not Found');
                resultList.add(result);
            }
        } catch (Exception e) {
            Map<string,object> result =  new Map<string,object>();
            result.put('status',false);
            result.put('Variant','error');
            result.put('message',e.getMessage());
            resultList.add(result);
        }
        
        return JSON.serialize(resultList);
    }
    
    
    public class AccountWrapper {
        public String shippingSubRegionName { get; set; }
        public String shippingStateName { get; set; }
        public String shippingRegionMaster { get; set; }
        public String shippingPostalZipCode { get; set; }
        public String shippingCountryName { get; set; }
        public String shippingCityName { get; set; }
        public String shippingAddressLine3 { get; set; }
        public String shippingAddressLine2 { get; set; }
        public String shippingAddressLine1 { get; set; }
        public String addressLine1 { get; set; }
        public String addressLine2 { get; set; }
        public String addressLine3 { get; set; }
        public String billingCityName { get; set; }
        public String billingCountryName { get; set; }
        public String billingPostalZipCode { get; set; }
        public String billingStateName { get; set; }
        public String globalRegion { get; set; }
        public String globalSubRegion { get; set; }
    }
    
    
    
}