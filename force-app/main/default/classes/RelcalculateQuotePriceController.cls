public class RelcalculateQuotePriceController {
    public String recID{get;set;}
    
    public RelcalculateQuotePriceController(ApexPages.StandardController controller){
        
    }
    
    public PageReference Recalculate(){
        recID=ApexPages.CurrentPage().getparameters().get('Id');
        Quote ObjQuote=[select id,name,Subsidiary__r.Price_Book__c,Opportunity.CurrencyISOCode,Exchange_Rate__c,Additinal_Margin__c from Quote where id=:recID];
        ObjQuote.Exchange_Rate__c = CommonData.getExchangeRate(ObjQuote.Opportunity.CurrencyISOCode);
        List<Quote_Line_Item_Custom__c> ObjQLI = new List<Quote_Line_Item_Custom__c>();
        List<Quote_Line_Options__c> ObjQLIO = new List<Quote_Line_Options__c>();
        List<id> prod = new List<id>();
        List<id> prodqlio = new List<id>();
        List<PricebookEntry> pricebookentryList = new List<PricebookEntry>();
        List<Quote_Line_Item_Custom__c> qliList = new List<Quote_Line_Item_Custom__c>();
        List<Quote_Line_Options__c> qlioList = new List<Quote_Line_Options__c>();
        
        ObjQLI = [select id,Quote__c,Sales_Price__c ,Is_Tax__c,List_Price__c,Base_Price__c,Quantity__c,Quote__r.Subsidiary__c,Quote__r.Subsidiary__r.Price_Book__c,Quote__r.Exchange_Rate__c, 
                  Product__c,Quote__r.Subsidiary__r.Additional_Margin__c,Quote__r.Additinal_Margin__c,Level_Of_Ceiling__c,
                  Quote__r.Subsidiary__r.Rounding_Off_Digits__c,Discount_Allowed_New__c, Quote__r.Subsidiary__r.M1__c,Quote__r.Subsidiary__r.D1__c,Quote__r.Subsidiary__r.D2__c
                  from Quote_Line_Item_Custom__c where Quote__c = : recID and Quantity__c >: 0 and Is_Manual__c=false];
        
        ObjQLIO = [select id,Quote__c,Manual_Option_Base_Price__c,Quote__r.Subsidiary__c,Manula_Option_List_Price__c,Quote__r.Subsidiary__r.Price_Book__c,Quote__r.Exchange_Rate__c, 
                   Product__c,Quote__r.Subsidiary__r.Additional_Margin__c,Quote__r.Additinal_Margin__c,
                   Quote__r.Subsidiary__r.Rounding_Off_Digits__c, Discount_Allowed_New__c,Quote__r.Subsidiary__r.M1__c,Quote__r.Subsidiary__r.D1__c,Quote__r.Subsidiary__r.D2__c,Quote_Line_Item_Custom__c,Select_Option__c
                   from Quote_Line_Options__c where Quote__c = : recID and Select_Option__c=false]; //
        
        for(Quote_Line_Item_Custom__c qlis:ObjQLI){
            prod.add(qlis.Product__c);
        }
        
        for(Quote_Line_Options__c qlios:ObjQLIO){
            prodqlio.add(qlios.Product__c);
        }
        System.debug(prodqlio);
        List<PricebookEntry> pbe = [Select Product2Id,UnitPrice,Pricebook2Id,M1__c,M2__c,M3__c,D1__c,D2__c,D3__c,M4__c,Base_Price__c
                                    ,Rounding_Off_Digits__c from PricebookEntry WHERE Product2Id IN: prod 
                                    AND Pricebook2Id =: ObjQuote.Subsidiary__r.Price_Book__c];
        
        List<PricebookEntry> pbeqlio = [Select Product2Id,UnitPrice,Pricebook2Id, M1__c,M2__c,M3__c,D1__c,D2__c,D3__c,M4__c,Base_Price__c
                                        ,Rounding_Off_Digits__c from PricebookEntry WHERE Product2Id IN: prodqlio 
                                        AND Pricebook2Id =: ObjQuote.Subsidiary__r.Price_Book__c];
        
        map<ID,PricebookEntry> pmap= new map<ID,PricebookEntry>();
        map<ID,PricebookEntry> pmapqlio= new map<ID,PricebookEntry>();
        for(PricebookEntry pbel:pbe){
            pmap.put(pbel.Product2Id, pbel);
        }
        
        for(PricebookEntry pbel:pbeqlio){
            pmapqlio.put(pbel.Product2Id, pbel);
        }
        try{
            For(Quote_Line_Item_Custom__c qli:ObjQLI){
                
                //String PriceBoodId;
                if(pmap.containskey(qli.Product__c)){
                    qli.P_D1__c = pmap.get(qli.Product__c).d1__c;
                    qli.P_D2__c = pmap.get(qli.Product__c).d2__c;
                    qli.P_D3__c = pmap.get(qli.Product__c).d3__c;
                    qli.P_M1__c = pmap.get(qli.Product__c).M1__c;
                    qli.P_M2__c = pmap.get(qli.Product__c).M2__c;
                    qli.P_M3__c = pmap.get(qli.Product__c).M3__c;
                    qli.P_M4__c = pmap.get(qli.Product__c).M4__c;
                    qli.Discount_Allowed_New__c = qli.Discount_Allowed_New__c;
                    if(qli.Is_Tax__c!=null)
                    qli.Is_Tax__c = qli.Is_Tax__c;
                    //qli.List_Price__c=AddProducts.getListPrice(pmap.get(qli.Product__c).UnitPrice, qli.Quote__r.Exchange_Rate__c, pmap.get(qli.Product__c).M1__c, pmap.get(qli.Product__c).M2__c,pmap.get(qli.Product__c).M3__c,pmap.get(qli.Product__c).M4__c, qli.Quote__r.Additinal_Margin__c, Integer.valueof(pmap.get(qli.Product__c).Rounding_Off_Digits__c));
                    
                    qli.Base_Price__c  = ((pmap.get(qli.Product__c).Base_Price__c*qli.Quote__r.Exchange_Rate__c)); 
                    qli.List_Price__c=AddProducts.getListPrice(pmap.get(qli.Product__c).Base_Price__c, qli.Quote__r.Exchange_Rate__c, pmap.get(qli.Product__c).M1__c, pmap.get(qli.Product__c).M2__c,pmap.get(qli.Product__c).M3__c,pmap.get(qli.Product__c).M4__c, qli.Quote__r.Additinal_Margin__c, Integer.valueof(pmap.get(qli.Product__c).Rounding_Off_Digits__c));
                    
                    //qli.List_Price__c=qli.List_Price__c;
                        
                    
                    //qli.List_Price__c =getListPrice(pmap.get(qli.Product__c).UnitPrice,ObjQuote.Exchange_Rate__c,qli.P_M1__c,qli.P_M2__c,qli.P_M3__c,qli.P_M4__c,ObjQuote.Additinal_Margin__c,Integer.valueof(qli.Level_Of_Ceiling__c));
                    
                    //qli.Base_Price__c=Math.ceil(qli.Base_Price__c/Integer.valueOf(pmap.get(qli.Product__c).Rounding_Off_Digits__c))*Integer.valueOf(pmap.get(qli.Product__c).Rounding_Off_Digits__c);

                }else{
                    qli.Base_Price__c  = qli.Base_Price__c;
                }
                //qli.Base_Price__c=pmap.get(qli.Product__c).UnitPrice/qli.Quote__r.Exchange_Rate__c;
                //qli.Base_Price__c=Math.ceil(price/Integer.valueOf(qli.Quote__r.Subsidiary__r.Rounding_Off_Digits__c))*Integer.valueOf(qli.Quote__r.Subsidiary__r.Rounding_Off_Digits__c);
                
                system.debug('qli.Base_Price__c'+qli.Base_Price__c);  
                system.debug('qli.Sales_Price__c '+qli.Sales_Price__c );  
                qliList.add(qli);
            }
            
            Update qliList;
        }
        catch(exception e)
        {
            System.debug('e.getMessage() at 75'+e.getMessage());
            e.setMessage('Something went wrong Please contact System Admin.');
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,e.getMessage())); 
            return null;
        }
        try{
            for(Quote_Line_Options__c qlio:ObjQLIO){
                String PriceBoodId;
                
                if(pmapqlio.containskey(qlio.Product__c)){
                    
                    
                    qlio.P_D1__c = pmapqlio.get(qlio.Product__c).d1__c;
                    qlio.P_D2__c = pmapqlio.get(qlio.Product__c).d2__c;
                    qlio.P_D3__c = pmapqlio.get(qlio.Product__c).d3__c;
                    qlio.P_M1__c = pmapqlio.get(qlio.Product__c).M1__c;
                    qlio.P_M2__c = pmapqlio.get(qlio.Product__c).M2__c;
                    qlio.P_M3__c = pmapqlio.get(qlio.Product__c).M3__c;
                    qlio.P_M4__c = pmapqlio.get(qlio.Product__c).M4__c;
                    qlio.Discount_Allowed_New__c = qlio.Discount_Allowed_New__c;
                    //qlio.Manula_Option_List_Price__c = AddProducts.getListPrice(pmapqlio.get(qlio.Product__c).UnitPrice,ObjQuote.Exchange_Rate__c,qlio.P_M1__c,qlio.P_M2__c,qlio.P_M3__c,qlio.P_M4__c,ObjQuote.Additinal_Margin__c,Integer.valueof(pmapqlio.get(qlio.Product__c).Rounding_Off_Digits__c));// pmapqlio.get(qlio.Product__c).UnitPrice;
                    //qlio.Manual_Option_Base_Price__c = pmapqlio.get(qlio.Product__c).Base_Price__c;
                    
                     //qlio.Manula_Option_List_Price__c = qlio.Manula_Option_List_Price__c;
                    //qlio.Manual_Option_Base_Price__c = qlio.Manual_Option_Base_Price__c;
                    
                    
                    qlio.Manula_Option_List_Price__c = AddProducts.getListPrice(pmapqlio.get(qlio.Product__c).Base_Price__c,ObjQuote.Exchange_Rate__c,qlio.P_M1__c,qlio.P_M2__c,qlio.P_M3__c,qlio.P_M4__c,ObjQuote.Additinal_Margin__c,Integer.valueof(pmapqlio.get(qlio.Product__c).Rounding_Off_Digits__c));// pmapqlio.get(qlio.Product__c).UnitPrice;
                    //qlio.Manula_Option_List_Price__c=AddProducts.getListPrice(pmapqlio.get(qlio.Product__c).UnitPrice, qlio.Quote__r.Exchange_Rate__c, pmapqlio.get(qlio.Product__c).M1__c, pmapqlio.get(qlio.Product__c).M2__c, pmapqlio.get(qlio.Product__c).M3__c,pmapqlio.get(qlio.Product__c).M4__c,qlio.Quote__r.Additinal_Margin__c, Integer.valueof(pmapqlio.get(qlio.Product__c).Rounding_Off_Digits__c));
                    qlio.Manual_Option_Base_Price__c = pmapqlio.get(qlio.Product__c).Base_Price__c * qlio.Quote__r.Exchange_Rate__c;
                /*    //Decimal price = pmapqlio.get(qlio.Product__c).UnitPrice *qlio.Quote__r.Exchange_Rate__c;
                    //qlio.Manual_Option_Base_Price__c=Math.ceil((price / Integer.valueof(qlio.Quote__r.Subsidiary__r.Rounding_Off_Digits__c)) * Integer.valueof(qlio.Quote__r.Subsidiary__r.Rounding_Off_Digits__c));
                */
                }else{
                    //qlio.Manual_Option_Base_Price__c = qlio.Manual_Option_Base_Price__c; 
                    //qlio.Manula_Option_List_Price__c = qlio.Manula_Option_List_Price__c;
                    
                }
                qlioList.add(qlio);
            }
            
            Update qlioList;
        }
        catch(exception e)
        {
            System.debug('e.getMessage() at 101'+e.getMessage());
            e.setMessage('Something went wrong Please contact System Admin.');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,e.getMessage())); 
            
            return null;
        }
        PageReference myVFPage = new PageReference('/'+ObjQuote.Id);
        myVFPage.setRedirect(true);
        return myVFPage;
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
}