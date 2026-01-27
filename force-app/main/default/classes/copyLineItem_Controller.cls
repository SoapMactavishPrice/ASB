public class copyLineItem_Controller {
    public string quoteId{get; set;}
    public List<SelectOption> options {get;set;}
    public String strSelected  {get;set;}
    public Integer inputValue  {get;set;}
    
    public copyLineItem_Controller(ApexPages.StandardController controller){
        quoteId = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('quoteId : : :'+quoteId);
        String strSelected = '';
        options = new List<SelectOption>();
        List<Quote_Line_Item_Custom__c> lstQLI = new List<Quote_Line_Item_Custom__c>();
        lstQLI = [Select id, Quote__c, Product__r.Name,Product_Name__c from Quote_Line_Item_Custom__c where Quote__c =: quoteId and Quantity__c >: 0];
        system.debug('lstQLI==>>>' + lstQLI.size());
        if(lstQLI.size() > 0){
            for(Quote_Line_Item_Custom__c qli : lstQLI){
                system.debug(qli.Id+' , '+ qli.Product_Name__c);
                options.add(new SelectOption(qli.Id,qli.Product_Name__c));
            }
        }
        system.debug('options ===>>> ' + options);
    }
    
    public PageReference copyItems(){
        if(!Test.isRunningTest()){
            Quote quoteDetails = [SELECT ID, Opportunity.StageName FROM Quote Where ID =: quoteId]; 
            if(quoteDetails.Opportunity.StageName == 'Close Lost'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,'You are not allowed to change Closed Lost Opportunity.')); 
                return null;
            }
        }
        
        
        String ValSelected = strSelected;
        System.debug('ValSelected'+ValSelected);
        List<Quote_Line_Item_Custom__c> lstQLI = new List<Quote_Line_Item_Custom__c>();
        lstQLi = [Select id,CurrencyIsoCode,Quote__c, Model__c, Product__c, Name, Quantity__c,Discount_Allowed_New__c,P_D1__c,P_D2__c,P_M4__c,P_M3__c,P_M2__c,P_D3__c,P_M1__c,Discount_Type__c,Discount_in_Value__c, Approved_Discount__c,Division__c,UOM__c, Product_Type__c, Discount__c,Scope_of_mould__c,Product_Name__c,Base_Price__c,Product_Description__c,
                  Advance_Percentage__c, Cavity__c ,Drawing_No__c, List_Price__c, Mach_Mold_No__c, Expected_Delivery__c,Expected_Delivery_date__c,Total_List_Price_options__c,MFG_AT__c,Level_Of_Ceiling__c,
                  Expected_Customer_PO__c, Expected_Drawing_Final__c, MFG__c,Approval_Status__c, Class__c, Discount_Approval_Note__c, Zero_Cooling__c,Is_Manual__c,Class_2__c,Zero_Cooling_2__c,
                  (Select Quote__c, Quote_Line_Item__c, Name, Manual_Option_Base_Price__c,Product_Type__c, Manula_Option_List_Price__c,Manual_Product_Name__c, Option_Product_Code__c ,Discount_Description__c,P_D1__c,P_D2__c,P_M4__c,P_M3__c,P_M2__c,P_D3__c,P_M1__c,Discount_Type__c,Discount_in_Value__c, Approved_Discount__c,
                   Discount_Allowed_New__c,Final_Price__c,Quantity__c, Price_Type__c, Mould_Cavity__c, Discount__c, Select_Option__c, Product__c, Description__c from Quote_Line_Options__r)
                  from Quote_Line_Item_Custom__c where id =: ValSelected];
        
        List<Quote_Line_Options__c> lstQLO = new List<Quote_Line_Options__c>();
        List<Quote_Line_Item_Custom__c> lstItem = new List<Quote_Line_Item_Custom__c>();
        Integer iter = inputValue;
        
        boolean showError = true;
        if(iter > 5){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Total Copy of records  less than or equal to   5'));
            showError = false;
            return null;
        }
        system.debug('iter====>> '+ iter +' showError --> '+showError);
        PriceBookEntry pbe = new PriceBookEntry();
       ///if(showError){
        if(lstQLi.size() > 0 && showError){
            for(integer num = 0 ; num<iter ; num++){
                lstItem.clear();
                for(Quote_Line_Item_Custom__c QLI : lstQLi){
                    //PriceBookEntry pbe = [SELECT id FROM PricebookEntry WHERE Product2Id =: QLI.Product__c LIMIT 1];
                    //system.debug('pbe==>>>' + pbe);
                    system.debug('QLI===>>>' + QLI.Is_Manual__c);
                    if(QLI.Is_Manual__c){
                        system.debug('manual QLI');
                        Quote_Line_Item_Custom__c objQLI = new Quote_Line_Item_Custom__c();
                        objQLI.CurrencyIsoCode=QLI.CurrencyIsoCode;
                        
                        objQLI.Discount_Type__c = QLI.Discount_Type__c;
                        if(QLI.Discount_Type__c =='Percent'){
                            objQLI.Discount__c = QLI.Discount__c;
                        }else{
                            objQLI.Discount__c = null;
                        }
                        
                        if(QLI.Discount_Type__c =='Value'){
                            objQLI.Discount_in_Value__c = QLI.Discount_in_Value__c;
                        }else{
                            objQLI.Discount_in_Value__c = null;
                        }
                        
                        
                        
                        //objQLI.Discount__c = QLI.Discount__c;
                        //objQLI.Discount_in_Value__c =  QLI.Discount_in_Value__c;
                        //objQLI.Discount_Type__c = QLI.Discount_Type__c;
                        objQLI.P_D1__c = QLI.P_D1__c;
                        objQLI.P_D2__c = QLI.P_D2__c;
                        objQLI.P_D3__c = QLI.P_D3__c;
                        objQLI.P_M1__c = QLI.P_M1__c;
                        objQLI.P_M2__c = QLI.P_M2__c;
                        objQLI.P_M3__c = QLI.P_M3__c;
                        objQLI.P_M4__c = QLI.P_M4__c;
                        objQLI.Discount_Allowed_New__c = QLI.Discount_Allowed_New__c; 
                        
                        
                        objQLI.Quote__c = QLI.Quote__c;
                        objQLI.Base_Price__c = QLI.Base_Price__c;
                        objQLI.Model__c = QLI.Model__c;
                        objQLI.MFG_AT__c = QLI.MFG_AT__c;
                        objQLI.Zero_Cooling_2__c = QLI.Zero_Cooling_2__c;
                        objQLI.Class_2__c = QLI.Class_2__c;
                        objQLI.Product__c = QLI.Product__c;
                        objQLI.Product_Name__c = QLI.Product_Name__c;
                        objQLI.Is_Manual__c = QLI.Is_Manual__c;
                        
                        objQLI.Level_Of_Ceiling__c = QLI.Level_Of_Ceiling__c;
                        //objQLI.PricebookEntryId = pbe.Id;
                        //objQLI.Description = QLI.Description;
                        objQLI.Quantity__c = QLI.Quantity__c;
                        objQLI.Product_Description__c = QLI.Product_Description__c;
                        objQLI.Division__c = QLI.Division__c;
                        objQLI.UOM__c = QLI.UOM__c;
                        objQLI.Product_Type__c = QLI.Product_Type__c;
                        //objQLI.Discount__c = QLI.Discount__c;
                        objQLI.Scope_of_mould__c = QLI.Scope_of_mould__c;
                        objQLI.Advance_Percentage__c = QLI.Advance_Percentage__c;
                        objQLI.Cavity__c = QLI.Cavity__c;
                        objQLI.Drawing_No__c = QLI.Drawing_No__c;
                        objQLI.List_Price__c = QLI.List_Price__c;
                        objQLI.Mach_Mold_No__c = QLI.Mach_Mold_No__c;
                        objQLI.Expected_Delivery__c = QLI.Expected_Delivery__c;
                        objQLI.Expected_Delivery_date__c = QLI.Expected_Delivery_date__c;
                        objQLI.Expected_Customer_PO__c = QLI.Expected_Customer_PO__c;
                        objQLI.Expected_Drawing_Final__c = QLI.Expected_Drawing_Final__c;
                        objQLI.Approval_Status__c = QLI.Approval_Status__c;
                        objQLI.Approved_Discount__c = QLI.Approved_Discount__c;
                        if(QLI.Discount_Approval_Note__c != null){
                            objQLI.Discount_Approval_Note__c = QLI.Discount_Approval_Note__c;
                        }
                        else{
                            objQLI.Discount_Approval_Note__c = 'Null';
                        }
                        lstItem.add(objQLI);
                    }
                    
                    
                    if(!QLI.Is_Manual__c){
                        system.debug('not manual QLI');
                        /*pbe = [SELECT Product2.Id,Discount__c,Product2.Description, Product2.Name,UnitPrice,Product2.Plant__c,Product2.Product_Number__c,Product2.Option_No__c,
Product2.Family,Product2.Number_Of_Cavity_Mould__c,Product2.Option_Type__c,Product2.Product_Type__c,Product2.Scope_of_Mold__c,Product2.ProductCode,
Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c,Pricing_Type__c,Discount_Level_2__c,Discount_Level_3__c,Quantity__c,Description__c
FROM PriceBookEntry Where Product2.IsActive = TRUE AND Pricebook2.Name =: 'Standard Price Book' AND Product2.Id =: QLI.Product__c Limit 1];
system.debug('pbe ===>>> ' + pbe); */
                        Quote_Line_Item_Custom__c objQLI = new Quote_Line_Item_Custom__c();
                        objQLI.CurrencyIsoCode=QLI.CurrencyIsoCode;
                        objQLI.Quote__c = QLI.Quote__c;
                        objQLI.Base_Price__c = QLI.Base_Price__c;
                        objQLI.Model__c = QLI.Model__c;
                        objQLI.MFG_AT__c = QLI.MFG_AT__c;
                        objQLI.Zero_Cooling_2__c = QLI.Zero_Cooling_2__c;
                        objQLI.Class_2__c = QLI.Class_2__c;
                        objQLI.Product__c = QLI.Product__c;
                        objQLI.Product_Name__c = QLI.Product_Name__c;
                        objQLI.Is_Manual__c = QLI.Is_Manual__c;
                        //objQLI.PricebookEntryId = pbe.Id;
                        //objQLI.Description = QLI.Description;
                        objQLI.Quantity__c = QLI.Quantity__c;
                        objQLI.Product_Description__c = QLI.Product_Description__c;
                        objQLI.Division__c = QLI.Division__c;
                        objQLI.Level_Of_Ceiling__c = QLI.Level_Of_Ceiling__c;
                        objQLI.UOM__c = QLI.UOM__c;
                        objQLI.Product_Type__c = QLI.Product_Type__c;
                        //objQLI.Discount__c = QLI.Discount__c;
                        objQLI.Scope_of_mould__c = QLI.Scope_of_mould__c;
                        objQLI.Advance_Percentage__c = QLI.Advance_Percentage__c;
                        objQLI.Cavity__c = QLI.Cavity__c;
                        objQLI.Drawing_No__c = QLI.Drawing_No__c;
                        objQLI.List_Price__c = QLI.List_Price__c;
                        objQLI.Mach_Mold_No__c = QLI.Mach_Mold_No__c;
                        objQLI.Expected_Delivery__c = QLI.Expected_Delivery__c;
                        objQLI.Expected_Delivery_date__c = QLI.Expected_Delivery_date__c;
                        objQLI.Expected_Customer_PO__c = QLI.Expected_Customer_PO__c;
                        objQLI.Expected_Drawing_Final__c = QLI.Expected_Drawing_Final__c;
                        objQLI.Approval_Status__c = QLI.Approval_Status__c;
                        objQLI.Approved_Discount__c = QLI.Approved_Discount__c;
                        objQLI.Discount_Type__c = QLI.Discount_Type__c;
                        if(QLI.Discount_Type__c =='Percent'){
                            objQLI.Discount__c = QLI.Discount__c;
                        }else{
                            //objQLI.Discount__c = null;
                        }
                        
                        if(QLI.Discount_Type__c =='Value'){
                            objQLI.Discount_in_Value__c = QLI.Discount_in_Value__c;
                        }else{
                            ///objQLI.Discount_in_Value__c = null;
                        }
                        system.debug('Discount_Type__c' + QLI.Discount_Type__c + ' Discount_in_Value__c  '+ QLI.Discount_in_Value__c +' Discount__c '+ QLI.Discount__c);
                        objQLI.P_D1__c = QLI.P_D1__c;
                        objQLI.P_D2__c = QLI.P_D2__c;
                        objQLI.P_D3__c = QLI.P_D3__c;
                        objQLI.P_M1__c = QLI.P_M1__c;
                        objQLI.P_M2__c = QLI.P_M2__c;
                        objQLI.P_M3__c = QLI.P_M3__c;
                        objQLI.P_M4__c = QLI.P_M4__c;
                        
                        objQLI.Discount_Allowed_New__c = QLI.Discount_Allowed_New__c; 
                        if(QLI.Discount_Approval_Note__c != null){
                            objQLI.Discount_Approval_Note__c = QLI.Discount_Approval_Note__c;
                        }
                        else{
                            objQLI.Discount_Approval_Note__c = 'Null';
                        }
                        lstItem.add(objQLI);
                        
                        system.debug('lstItem --->>> ' + lstItem);
                    }
                    system.debug('lstItem --->>> ' + lstItem);
                    try
                    {
                        insert lstItem; 
                    }
                    catch(exception e)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,e.getMessage())); 
                        return null;
                    }
                    
                    system.debug('lstItem afetr --->>> ' + lstItem);
                    
                    for(Quote_Line_Options__c QLO : QLI.Quote_Line_Options__r){
                        system.debug('QLO===>>>>' + QLO);
                        if(QLO.Select_Option__c){
                            system.debug('manual QLO ' + lstItem[0].Id);
                            Quote_Line_Options__c objQLO = new Quote_Line_Options__c();
                            objQLO.CurrencyIsoCode=QLI.CurrencyIsoCode;
                            objQLO.Quote__c = QLO.Quote__c;
                            objQLO.Product_Type__c = QLO.Product_Type__c;
                            objQLO.Quote_Line_Item_Custom__c = lstItem[0].Id;
                            objQLO.Product__c = QLO.Product__c;
                            objQLO.Manual_Product_Name__c = QLO.Manual_Product_Name__c; 
                            objQLO.Manual_Option_Base_Price__c = QLO.Manual_Option_Base_Price__c;
                            objQLO.Manula_Option_List_Price__c = QLO.Manula_Option_List_Price__c;
                            objQLO.Quantity__c = QLO.Quantity__c;
                            //objQLO.Price_Type__c = QLO.Price_Type__c;
                            objQLO.Mould_Cavity__c = QLO.Mould_Cavity__c;
                            //objQLO.Discount__c = QLO.Discount__c;
                            objQLO.Description__c = QLO.Description__c;
                            
                            objQLO.Select_Option__c = QLO.Select_Option__c;
                            //objQLO.Discount__c = QLI.Discount__c;
                            //objQLO.Discount_in_Value__c =  QLO.Discount_in_Value__c;
                            //objQLO.Discount_Type__c = QLO.Discount_Type__c;
                            
                            objQLO.Discount_Type__c =QLO.Discount_Type__c;
                            if(QLO.Discount_Type__c =='Percent'){
                                objQLO.Discount__c = QLO.Discount__c;
                            }else{
                                objQLO.Discount__c = null;
                            }
                            
                            if(QLO.Discount_Type__c =='Value'){
                                objQLO.Discount_in_Value__c = QLO.Discount_in_Value__c;
                            }else{
                                objQLO.Discount_in_Value__c = null;
                            }
                            
                            objQLO.P_D1__c = QLO.P_D1__c;
                            objQLO.P_D2__c = QLO.P_D2__c;
                            objQLO.P_D3__c = QLO.P_D3__c;
                            objQLO.P_M1__c = QLO.P_M1__c;
                            objQLO.P_M2__c = QLO.P_M2__c;
                            objQLO.P_M3__c = QLO.P_M3__c;
                            objQLO.P_M4__c = QLO.P_M4__c;
                            objQLO.Discount_Allowed_New__c = QLO.Discount_Allowed_New__c; 
                            
                            if(QLO.Discount_Description__c != null){
                                objQLO.Discount_Description__c = QLO.Discount_Description__c;
                            }
                            else{
                                objQLO.Discount_Description__c = 'Null';
                            }
                            objQLO.Final_Price__c = QLO.Final_Price__c;
                            lstQLO.add(objQLO);
                        }
                        
                        if(!QLO.Select_Option__c){
                            system.debug('not manual QLO ' + lstItem[0].Id);
                            PriceBookEntry pbeEntry = new PriceBookEntry();
                            
                            /* pbeEntry = [SELECT id,Product2.Id,Discount__c,Product2.Description, Product2.Name,unitprice,Product2.Plant__c,Product2.Product_Number__c,Product2.Option_No__c,
Product2.Family,Product2.Number_Of_Cavity_Mould__c,Product2.Option_Type__c,Product2.Product_Type__c,Product2.Scope_of_Mold__c,
Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c,Pricing_Type__c,Discount_Level_2__c,Discount_Level_3__c,Quantity__c
FROM PriceBookEntry 
WHERE Pricebook2Id IN (SELECT Id FROM PriceBook2  where Name = 'Option Price Book' AND PriceBook2.IsActive = true)
AND Product2.IsACTIVE = true AND Product2.Family = 'Options' AND Product2.Id =:  QLO.Product__c Limit 1];
System.debug('pbeEntry'+pbeEntry); */
                            Quote_Line_Options__c objQLO = new Quote_Line_Options__c();
                            objQLO.CurrencyIsoCode=QLI.CurrencyIsoCode;
                            objQLO.Discount_Type__c =QLO.Discount_Type__c;
                            objQLO.Product_Type__c = QLO.Product_Type__c;
                            objQLO.Quote__c = QLO.Quote__c;
                            objQLO.Quote_Line_Item_Custom__c = lstItem[0].Id;
                            objQLO.Product__c = QLO.Product__c;
                            objQLO.Manual_Product_Name__c = QLO.Manual_Product_Name__c; 
                            objQLO.Manual_Option_Base_Price__c = QLO.Manual_Option_Base_Price__c;
                            objQLO.Manula_Option_List_Price__c = QLO.Manula_Option_List_Price__c;
                            objQLO.Quantity__c = QLO.Quantity__c;
                            //objQLO.Price_Type__c = QLO.Price_Type__c;
                            objQLO.Mould_Cavity__c = QLO.Mould_Cavity__c;
                            //objQLO.Discount__c = QLO.Discount__c;
                            objQLO.Description__c = QLO.Description__c;
                            objQLO.Select_Option__c = QLO.Select_Option__c;
                            if(QLO.Discount_Description__c != null){
                                objQLO.Discount_Description__c = QLO.Discount_Description__c;
                            }
                            else{
                                objQLO.Discount_Description__c = 'Null';
                            }
                            objQLO.Select_Option__c = QLO.Select_Option__c;
                            
                            if(QLO.Discount_Type__c =='Percent'){
                                objQLO.Discount__c = QLO.Discount__c;
                            }else{
                                objQLO.Discount__c = null;
                            }
                            
                            if(QLO.Discount_Type__c =='Value'){
                                objQLO.Discount_in_Value__c = QLO.Discount_in_Value__c;
                            }else{
                                objQLO.Discount_in_Value__c = null;
                            }
                            
                            objQLO.P_D1__c = QLO.P_D1__c;
                            objQLO.P_D2__c = QLO.P_D2__c;
                            objQLO.P_D3__c = QLO.P_D3__c;
                            objQLO.P_M1__c = QLO.P_M1__c;
                            objQLO.P_M2__c = QLO.P_M2__c;
                            objQLO.P_M3__c = QLO.P_M3__c;
                            objQLO.P_M4__c = QLO.P_M4__c;
                            objQLO.Discount_Allowed_New__c = QLO.Discount_Allowed_New__c; 
                            objQLO.Final_Price__c = QLO.Final_Price__c;
                            lstQLO.add(objQLO);
                        }
                    }
                }
            }
            try
            {
                insert lstQLO;
            }
            catch(exception e)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,e.getMessage())); 
                return null;
            }
            
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Selected Record is copied !!')); 
            PageReference myVFPage = new PageReference('/'+ quoteId);
            myVFPage.setRedirect(true);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Selected Record is copied !!')); 
            return myVFPage;
            //return null;
        }
        else{
            system.debug('size is null');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No record in system to make copy.'));
            return null;
        //}
       }
    }
}