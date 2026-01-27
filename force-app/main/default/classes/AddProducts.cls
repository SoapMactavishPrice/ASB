public class AddProducts {
	
    Public Static List<ProdListWrapper> lstProductListWrapper = new List<ProdListWrapper>();
    
    @AuraEnabled 
    public static Boolean checkDate(String RecId){
        Quote quote=[select id, Opportunity.CloseDate
                     from Quote where id=:RecId limit 1];
        if(quote.Opportunity.CloseDate<System.today()){
            return false;
        }else{
            return true;
        }
    }
    
    @AuraEnabled 
    public static Quote getQuotationDetails(String RecId){
        Quote quote=[select id,name, Exchange_Rate__c, CurrencyIsoCode,Subsidiary__r.Additional_Margin__c,
                     Subsidiary__r.Rounding_Off_Digits__c,Subsidiary__r.Quantity_Restricted__c,Additinal_Margin__c, 
                     Subsidiary__r.M1__c,Subsidiary__r.D1__c, Opportunity.CloseDate,Max_Serial_Number__c,Is_Taxable__c
                     
                     from Quote where id=:RecId limit 1];
        return quote;
    }
    
    @AuraEnabled 
    public static List<ProdListWrapper> getProductList(String RecId){
        
        User_Setup__c u=[Select id,name,Subsidiari__c,Subsidiari__r.Price_Book__c from User_Setup__c where user__c=:userinfo.getUserId() limit 1];
        System.debug('RecId=>'+RecId);
        System.debug('RecId=>'+u.Subsidiari__c);
        Quote quote=[select id,name,Language__c, Exchange_Rate__c,Subsidiary__r.Additional_Margin__c,
                     Subsidiary__r.Rounding_Off_Digits__c,Subsidiary__r.Quantity_Restricted__c,Additinal_Margin__c, 
                     Subsidiary__r.M1__c,Subsidiary__r.D1__c,Subsidiary__r.D2__c,Subsidiary__r.D3__c from Quote where id=:RecId limit 1];
        
        List<Quote_Line_Item_Custom__c> QuoteLineList = [Select Id,Product__c from Quote_Line_Item_Custom__c where Quote__c =: quote.Id];
        
        set<Id> prodId = new set<Id>();
        for(Quote_Line_Item_Custom__c qline : QuoteLineList){
            if(string.isNotBlank(qline.Product__c)){
               prodId.add(qline.Product__c);    
            }
        }
        
        String pb;
        if(u.Subsidiari__r.Price_Book__c!=null)
        {
            pb=u.Subsidiari__r.Price_Book__c;
        }
        else{
            pb=[select id,name from pricebook2 where name='Standard Price Book'].id; //,Description__c,Pricing_Type__c,Discount_Level_2__c,Discount_Level_3__c,List_Price_Level_2__c,List_Price_level_3__c,Product2.Scope_of_Mold__c,Product2.Option_Type__c,Product2.Number_Of_Cavity_Mould__c,Discount__c,Product2.UOM__c,Product2.Plant__c,Product2.Option_No__c,Product2.Family,
        }
            // 
        system.debug('pb'+pb);
        system.debug('size'+prodId.size()+'Id'+prodId);
        List<Pricebookentry> titleList3 = new List<Pricebookentry>([SELECT Product2.Id, Product2.Name,UnitPrice,Product2.Product_Number__c,
                                                                    Product2.Product_Type__c,Product2.ProductCode,
                                                                    Base_Price__c,Quantity__c,Product2.Description
                                                                    ,M1__c,M2__c,M3__c,D1__c,D2__c,D3__c,M4__c
                                                                    ,Rounding_Off_Digits__c
                                                                   
                                                                    FROM PriceBookEntry Where 
                                                                    //Product2Id NOT IN :prodId AND
                                                                    Product2.IsActive = TRUE 
                                                                    //AND Id='01uBg0000009XXpIAM'
                                                                    AND Pricebook2.id =: pb 
                                                                    AND Product2.ProductCode != null 
                                                                    AND Product2.Family = 'Items' 
                                                                    AND Product2.Language__c=:quote.Language__c  
                                                                    AND M1__c != null and M2__c != null and M3__c != null and M4__c != null
                                                                    AND D1__c != null and D2__c != null and D3__c != null and Rounding_Off_Digits__c != null 
                                                                
                                                                    and (Product2.Subsidiari__c=:null OR Product2.Subsidiari__c=:u.Subsidiari__c)
                                                                    and IsActive = True
                                                                    ORDER BY Product2.Product_Number__c ASC]);
        
        User UsedDeatil = [select id,Name,Level__c 
                           from User 
                           where id =: userInfo.getUserId()];
        
        String Level = UsedDeatil.Level__c;
        //public Decimal getListPrice(double basePrice, double excRate, double D1, double D2, double D3, Integer roundOffDigits)
        for(PriceBookEntry lstpbe : titleList3){
            system.debug('Product2.Product_Type__c'+lstpbe.Product2.Product_Type__c);
           if(lstpbe.M1__c != null && lstpbe.M2__c != null && lstpbe.M3__c != null && lstpbe.Rounding_Off_Digits__c != null && lstpbe.M4__c !=null && quote.Exchange_Rate__c !=null){
                lstpbe.UnitPrice=getListPrice(lstpbe.Base_Price__c,quote.Exchange_Rate__c,lstpbe.M1__c,lstpbe.M2__c,lstpbe.M3__c,lstpbe.M4__c,quote.Additinal_Margin__c,
                                              Integer.valueof(lstpbe.Rounding_Off_Digits__c));
            }
            lstProductListWrapper.add(new ProdListWrapper(false,0, lstpbe, 1));
        }
        system.debug('lstProductListWrapper'+lstProductListWrapper.size());
        return lstProductListWrapper;
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
    public static  List<map<string, string> > getPickListValuesIntoList(){
        List<map<string, string> > pickListValuesList = new List<map<string, string> >();
        Schema.DescribeFieldResult fieldResult = Product2.Product_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
        for( Schema.PicklistEntry pickListVal : ple){
            map<string, string> PicklistValues = new map<string, string>();
            if(pickListVal.getLabel() !='PARTS' && pickListVal.getLabel() !='SERVICE' && pickListVal.getLabel() !='OTHERS'){
                PicklistValues.put('label',pickListVal.getLabel());
                PicklistValues.put('value',pickListVal.getValue());
                pickListValuesList.add(PicklistValues);
            }
           	
        }   
        system.debug('-->'+pickListValuesList);
        return pickListValuesList;
    }
   
    // existing Method
    @AuraEnabled 
    public static void SelectedProd(List<PriceBookEntry>selectedRecordList, String RecId, List<Integer> quantityList, string js){
        system.debug('selectedRecordList ===>>>' + selectedRecordList);
        system.debug('RecId ===>>>' + RecId);
        system.debug('quantityList ===>>>' + quantityList);
        
        system.debug('js is'+js);
        List<ProdListWrapper> accWr = ProdListWrapper.parse(js);
		system.debug('accWr'+accWr.size());
        List<Quote_Line_Item_Custom__c> lstQLI = new List<Quote_Line_Item_Custom__c>();
        List<Quote_Line_Item_Custom__c> lstQLI1 = new List<Quote_Line_Item_Custom__c>();
        
        List<Quote> lstQuote = [Select id, Opportunity.Class__c,Exchange_Rate__c, Opportunity.MFG_AT__c ,CurrencyIsoCode,Additinal_Margin__c,
                                Opportunity.Zero_Cooling__c ,Discount__c,Subsidiary__c,Subsidiary__r.Rounding_Off_Digits__c,
                                (SELECT Id, Product__c, Quantity__c FROM Quote_Line_Items__r)
                                from Quote 
                                where id =: RecId LIMIT 1];
        
        
        
        Map<Id, Quote_Line_Item_Custom__c> prodIdQLIObjMap = new Map<Id, Quote_Line_Item_Custom__c> ();
        for(Quote_Line_Item_Custom__c qliObj : lstQuote[0].Quote_Line_Items__r) {
            prodIdQLIObjMap.put(qliObj.Product__c, qliObj);
        }
        
        system.debug('lstQuote ===>>>' + lstQuote[0].Opportunity.MFG_AT__c);
        User UsedDeatil = [select id,Name,Level__c 
                           from User 
                           where id =: userInfo.getUserId()];
        
        String Level = UsedDeatil.Level__c;
        Integer i=0;
       for(ProdListWrapper pw :accWr){
           PriceBookEntry pbe = pw.objprod;
                Quote_Line_Item_Custom__c objQli = new Quote_Line_Item_Custom__c();
                //Quote_Line_Item_Custom__c objQli1 = new Quote_Line_Item_Custom__c();
                //===========================================For Update In Product===============================================================
          
                objQli.CurrencyIsoCode = lstQuote[0].CurrencyIsoCode;
                if(pbe.Product2Id != null){
                    objQLI.Product__c = pbe.Product2Id;
                }
                if(RecId != null && RecId != ''){
                    objQLI.Quote__c = RecId;
                }
                objQLI.Quantity__c = pw.quantity;
                //objQLI.Sr_No__c = pw.serial_no;
           //objQLI.Discount__c = lstQuote[0].discount__c;
           //objQLI.Discount_Type__c = 'Percent';
           objQLI.P_D1__c = pbe.d1__c;
           objQLI.P_D2__c = pbe.d2__c;
           objQLI.P_D3__c = pbe.d3__c;
           objQLI.P_M1__c = pbe.M1__c;
           objQLI.P_M2__c = pbe.M2__c;
           objQLI.P_M3__c = pbe.M3__c;
           objQLI.P_M4__c = pbe.M4__c;
      
           
                //objQLI.Level_Of_Ceiling__c=lstQuote[0].Subsidiary__r.Rounding_Off_Digits__c;
                //objQLI.Level_Of_Ceiling__c = pbe.Rounding_Off_Digits__c;
                objQLI.Level_Of_Ceiling__c = '1';
                System.debug(' pbe.Quantity__c= = = = = = = = == '+ pbe.Quantity__c);
                System.debug(' pbe.Base_Price__c= = = = = = = = == '+ pbe.Base_Price__c);
                if(pbe.Base_Price__c != null){
                    

                    /*objQLI.Base_Price__c = (pbe.Base_Price__c*lstQuote[0].Exchange_Rate__c); //*(quantityList[i]
                    if(pbe.Rounding_Off_Digits__c !=null){
                      objQLI.Base_Price__c =Math.ceil(objQLI.Base_Price__c/Integer.valueOf(pbe.Rounding_Off_Digits__c))*Integer.valueOf(pbe.Rounding_Off_Digits__c);
                    }*/
                }
           
           if(pbe.Base_Price__c != null){
               objQLI.Base_Price__c = (pbe.Base_Price__c*lstQuote[0].Exchange_Rate__c); //*(quantityList[i]
               system.debug('Exchange_Rate__c ='+ lstQuote[0].Exchange_Rate__c);
               system.debug('Base Price is ='+ objQLI.Base_Price__c);
               system.debug('Base Price is After calculation ='+ pbe.Base_Price__c*lstQuote[0].Exchange_Rate__c);
               
               system.debug('go for list price m1  ='+pbe.M1__c);
               system.debug('go for list price m2 ='+pbe.M2__c);
               system.debug('go for list price m3 ='+pbe.M3__c);
               system.debug('go for list price m4 ='+pbe.M4__c);
               system.debug('go for list price Additional Margin ='+lstQuote[0].Additinal_Margin__c);
               system.debug('go for list price round of  =' + pbe.Rounding_Off_Digits__c);
               
               system.debug('go for list price');
               objQLI.List_Price__c = getListPrice(pbe.Base_Price__c,lstQuote[0].Exchange_Rate__c,pbe.M1__c,pbe.M2__c,pbe.M3__c,pbe.M4__c,lstQuote[0].Additinal_Margin__c,
                                              Integer.valueof(pbe.Rounding_Off_Digits__c));
               
               system.debug('go for list price'+objQLI.List_Price__c);
           }
                if(lstQuote[0].Opportunity.Class__c != null && lstQuote[0].Opportunity.Class__c != ''){
                    objQLI.Class_2__c = lstQuote[0].Opportunity.Class__c;
                }
                if(lstQuote[0].Opportunity.MFG_AT__c != null && lstQuote[0].Opportunity.MFG_AT__c != ''){

                }
                if(lstQuote[0].Opportunity.Zero_Cooling__c != null && lstQuote[0].Opportunity.Zero_Cooling__c != ''){
                    objQLI.Zero_Cooling_2__c = lstQuote[0].Opportunity.Zero_Cooling__c;
                }
                
                if(pbe.Product2.Name != null && pbe.Product2.Name != ''){
                    objQLI.Product_Name__c = pbe.Product2.Name;
                }
                if(pbe.Product2.Description != null && pbe.Product2.Description != ''){
                    objQLI.Product_Description__c = pbe.Product2.Description;
                }else{
                    objQLI.Product_Description__c = pbe.Product2.Name;
                }
                
                objQLI.Discount_Approval_Note__c = 'Null';
               if(Level == 'L1'){
                    if(pbe.d1__c != null){
                        objQLI.Discount_Allowed_New__c = pbe.d1__c;
                    }
                }
                if(Level == 'L2'){
                    if(pbe.d2__c != null){
                        objQLI.Discount_Allowed_New__c = pbe.d2__c;
                    }
                }
                if(Level == 'L3'){
                    if(pbe.d3__c != null){
                        objQLI.Discount_Allowed_New__c = pbe.d3__c;
                    }
                }
                
           if(pbe.Product2.Product_Type__c != null && pbe.Product2.Product_Type__c != ''){
                    objQLI.Product_Type__c = pbe.Product2.Product_Type__c;
                }
                objQLI.Advance_Percentage__c =30;
                if(pbe.Product2.UOM__c != null && pbe.Product2.UOM__c != ''){
                    objQLI.UOM__c = pbe.Product2.UOM__c;
                }
                lstQLI.add(objQLI);
                i++;  
            } 
        
        
        
        //======================================================Added By Kartik======================================================================
      /*  List<Quote_Line_Item_Custom__c> lstQLI = new List<Quote_Line_Item_Custom__c>();
        List<Quote_Line_Item_Custom__c> lstQLI1 = new List<Quote_Line_Item_Custom__c>();*/
        //if(selectedRecordList.size() > 0 && selectedRecordList!= null){
            
            /*for(PriceBookEntry pbe : selectedRecordList) { 
                Quote_Line_Item_Custom__c objQli = new Quote_Line_Item_Custom__c();
                Quote_Line_Item_Custom__c objQli1 = new Quote_Line_Item_Custom__c();
                //===========================================For Update In Product===============================================================
          
                objQli.CurrencyIsoCode = lstQuote[0].CurrencyIsoCode;
                if(pbe.Product2Id != null){
                    objQLI.Product__c = pbe.Product2Id;
                }
                if(RecId != null && RecId != ''){
                    objQLI.Quote__c = RecId;
                }
                objQLI.Quantity__c = quantityList[i];
                objQLI.Discount__c = lstQuote[0].discount__c;
                objQLI.Level_Of_Ceiling__c=lstQuote[0].Subsidiary__r.Rounding_Off_Digits__c;
                System.debug(' pbe.Quantity__c= = = = = = = = == '+ pbe.Quantity__c);
                System.debug(' pbe.Base_Price__c= = = = = = = = == '+ pbe.Base_Price__c);
                if(pbe.Base_Price__c != null){
                    objQLI.Base_Price__c = (pbe.Base_Price__c*lstQuote[0].Exchange_Rate__c); //*(quantityList[i]
                    objQLI.Base_Price__c = Math.ceil(objQLI.Base_Price__c/Integer.valueOf(lstQuote[0].Subsidiary__r.Rounding_Off_Digits__c))*Integer.valueOf(lstQuote[0].Subsidiary__r.Rounding_Off_Digits__c);
                }
                System.debug(' objQLI.Quantity__c= = = = = = = = == '+ objQLI.Quantity__c);
                System.debug(' objQLI.Base_Price__c= = = = = = = = == '+ objQLI.Base_Price__c);
                if(lstQuote[0].Opportunity.Class__c != null && lstQuote[0].Opportunity.Class__c != ''){
                    objQLI.Class_2__c = lstQuote[0].Opportunity.Class__c;
                }
                if(lstQuote[0].Opportunity.MFG_AT__c != null && lstQuote[0].Opportunity.MFG_AT__c != ''){
                    objQLI.MFG_AT__c = lstQuote[0].Opportunity.MFG_AT__c;
                }
                if(lstQuote[0].Opportunity.Zero_Cooling__c != null && lstQuote[0].Opportunity.Zero_Cooling__c != ''){
                    objQLI.Zero_Cooling_2__c = lstQuote[0].Opportunity.Zero_Cooling__c;
                }
                if(pbe.UnitPrice != null){
                    objQLI.List_Price__c = pbe.UnitPrice;
                }
                if(pbe.Product2.Name != null && pbe.Product2.Name != ''){
                    objQLI.Product_Name__c = pbe.Product2.Name;
                }
                if(pbe.Product2.Description != null && pbe.Product2.Description != ''){
                    objQLI.Product_Description__c = pbe.Product2.Description;
                }else{
                    objQLI.Product_Description__c = pbe.Product2.Name;
                }
                
                objQLI.Discount_Approval_Note__c = 'Null';
                if(Level == 'L1'){
                    if(pbe.Discount__c != null){
                        objQLI.Discount__c = pbe.Discount__c;
                    }
                }
                if(Level == 'L2'){
                    if(pbe.Discount__c != null){
                        objQLI.Discount__c = pbe.Discount_Level_2__c;
                    }
                }
                if(Level == 'L3'){
                    if(pbe.Discount__c != null){
                        objQLI.Discount__c = pbe.Discount_Level_3__c;
                    }
                }
                if(pbe.Product2.Product_Type__c != null && pbe.Product2.Product_Type__c != ''){
                    objQLI.Product_Type__c = pbe.Product2.Product_Type__c;
                }
                objQLI.Advance_Percentage__c =30;
                if(pbe.Product2.UOM__c != null && pbe.Product2.UOM__c != ''){
                    objQLI.UOM__c = pbe.Product2.UOM__c;
                }
                lstQLI.add(objQLI);
                i++;  
            } 
*/            try{
                insert LstQLI;
                update lstQLI1;
            }catch(Exception e){
                String err = e.getMessage(); 
                system.debug('message'+e.getLineNumber()+'   msg'+e.getMessage());
                if(err.contains('The Sales Price You Entered Is Less Then The Base Price')){
                    throw new AurahandledException('Price Error');
                }else if(err.contains('You are not allowed to change Closed Lost Opportunity')){
                    throw new AurahandledException('Closed Lost Error');
                }else{
                    throw new AurahandledException(e.getMessage());
                }
            }
        //}
         
    }
    
    
    @AuraEnabled 
    public static void enterManualProd(List<Quote_Line_Item_Custom__c>selectedRecordList, String RecId){
        system.debug('RecId ===>>>' + RecId);
        Quote objQuote = new Quote();
        objQuote = [Select id,name,discount__c, Subsidiary__r.Rounding_Off_Digits__c,CurrencyIsoCode from quote where id=:recid];
        System.debug('objQuote = == '+objQuote);
        //Id newId = Id.valueOf(RecId);
        system.debug('selectedRecordList ===>>>' + selectedRecordList);
        system.debug('selectedRecordList.size() ===>>>' + selectedRecordList.size());
        User UsedDeatil = [select id,Name,Level__c 
                           from User 
                           where id =: userInfo.getUserId()];
        
        String Level = UsedDeatil.Level__c;
        List<Quote_Line_Item_Custom__c> lstQLI = new List<Quote_Line_Item_Custom__c>();
        List<Integer> checkValue = new List<Integer>();
        try{
            if(selectedRecordList.size() > 0){
                for(Quote_Line_Item_Custom__c qli : selectedRecordList){
                    system.debug('qli ===>>>' + qli);
                    Quote_Line_Item_Custom__c objQLI = new Quote_Line_Item_Custom__c();
                    ObjQLI.CurrencyIsoCode=objQuote.CurrencyIsoCode;
                    ObjQLI.Discount_Type__c = 'Percent';
                    ObjQLI.Is_Tax__c = qli.Is_Tax__c;
                    ObjQLI.Product_Type__c = qli.Product_Type__c;
                    if(RecId != null && RecId != ''){
                        objQLI.Quote__c = RecId;
                    }
                    /*if(objQuote.Discount__c != null){
                        objQLI.Discount__c = objQuote.Discount__c;
                    }*/
                    /*if(objQuote.Subsidiary__r.Rounding_Off_Digits__c != null){
                        objQLI.Level_Of_Ceiling__c = objQuote.Subsidiary__r.Rounding_Off_Digits__c;
                    }*/
                    objQLI.Level_Of_Ceiling__c = '1';
                    if(qli.Quantity__c != null){
                        objQLI.Quantity__c = qli.Quantity__c;
                    }
                    if(qli.List_Price__c != null){
                        objQLI.List_Price__c = qli.List_Price__c;
                    }
                    /* if(qli.Scope_of_mould__c != null && qli.Scope_of_mould__c != ''){
objQLI.Scope_of_mould__c = qli.Scope_of_mould__c;
}
if(qli.Cavity__c != null){
objQLI.Cavity__c = qli.Cavity__c;
}
if(qli.Product_Type__c != null && qli.Product_Type__c != ''){
objQLI.Product_Type__c = qli.Product_Type__c;
}*/
                    if(qli.Base_Price__c != null){
                        objQLI.Base_Price__c =  qli.Base_Price__c ;
                    }
                    objQLI.Is_Manual__c = TRUE;
                    if(qli.Product_Name__c != null && qli.Product_Name__c != ''){
                        objQLI.Product_Name__c = qli.Product_Name__c;
                    }
                    objQLI.UOM__c = '';
                    objQLI.Advance_Percentage__c = 30;
                    
                    lstQLI.add(objQLI);
                }
                system.debug('lstQLI ===>>>' + lstQLI);
                insert lstQLI;
            }
        }catch(exception e){
            String err = e.getMessage();                             
                if(err.contains('The Sales Price You Entered Is Less Then The Base Price')){
                    throw new AurahandledException('Price Error');
                }else if(err.contains('You are not allowed to change Closed Lost Opportunity')){
                    throw new AurahandledException('Closed Lost Error');
                }else{
                    throw new AurahandledException(e.getMessage());
                }
        }
        
    }
    
    public static Decimal getListPrice(Decimal basePrice, Decimal excRate, Decimal M1, Decimal M2, Decimal M3,Decimal M4, Decimal quoteMargin, Integer roundOffDigits)
    {
        Decimal listPrice=0;
        system.debug('listPrice p '+ basePrice+'excRate '+excRate+' M1 '+ M1+' M2 '+ M2+'m3'+M3+' quoteMargin '+ quoteMargin +' roundOffDigits '+roundOffDigits);
        //listPrice=math.ceil(((basePrice*excRate)/M1/M2/M3/M4/quoteMargin) /roundOffDigits)*roundOffDigits;
        //listPrice=math.ceil((((basePrice*excRate)/M1/M2/M3/M4/quoteMargin) /roundOffDigits)*roundOffDigits);
        listPrice=math.ceil(((basePrice*excRate)/M1/M2/M3/M4)/roundOffDigits)*roundOffDigits;
        system.debug('listPrice'+listPrice);
        return listPrice;
    }
    
    
    public class ProdListWrapper {
        @AuraEnabled public boolean isChecked;
        @AuraEnabled public integer serial_no;
        @AuraEnabled public PriceBookEntry objprod;
        @AuraEnabled public Integer quantity;
        
        public ProdListWrapper(boolean isChecked, integer serial_no, PriceBookEntry objprod, Integer quantity){
            this.isChecked = isChecked;
            this.serial_no = serial_no;
            this.objprod = objprod;
            this.quantity = quantity;
        }
        
    }

public static List<ProdListWrapper> parse(String json){
         return (List<ProdListWrapper>) System.JSON.deserialize(json, List<ProdListWrapper>.class);
    }
    
    

}