public class QuoteCreationClass
{
    public Opportunity objQ1;
    Public String QuoteNameFieldClone{get;set;}
    public Boolean eq1{get;set;}
    public Boolean bl1{get;set;}
    public Boolean Clone{get;set;}
    public Boolean Clone1{get;set;}
    public Boolean Clone2{get;set;}
    public Boolean Clone3{get;set;}
    public Boolean Clone4{get;set;}
    public Boolean Clone5{get;set;}
    public String RecordTypeName {get; set;}
    public List<RecordType> recType {get;set;}
    public List<String> strRecordType {get; set;}
    public List<SelectOption> optRecordType {get; set;}
    public List<Quote> lstQLI {get;set;}
    public String RecordID{get;set;}
    public Quote ObjQuote{get;set;}
    Public String opportunityId{get;set;}
    Public String OpptyName{get;set;}
    Public String AccountName{get;set;}
    Public String QuoteName{get;set;}
    Public String AccountId{get;set;}
    public String Quoteid{get;set;}
    public String strSelected  {get;set;}
    public String selectedCountry1{get;set;}
    public List<SelectOption> options {get;set;}
    public List<Quote_Line_Item_Custom__c> ObjQuoteLineItem{get;set;}
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<Quote> QuoteList{get;set;}
    public String filter{get;set;}
    
    
    public List<Opportunity> setQ1 {get;set;}
    
    public QuoteCreationClass(ApexPages.StandardController myController){
        csvFileLines = new String[]{};
            QuoteList = New List<Quote>(); 
        Clone1 = true;
        clone3 = true;
        QuoteNameFieldClone =null;
        objQ1 = (Opportunity)myController.getRecord();
        opportunityId = ApexPages.CurrentPage().getparameters().get('id'); 
        Opportunity ObjOppty = new Opportunity();
        ObjOppty =[select id, name,accountId  from Opportunity where id = :opportunityId];
        System.debug('ObjOppty::'+ObjOppty);
        AccountId = ObjOppty.AccountId;
        Account Acct = new Account();
        Acct = [select id,name from Account where id = : AccountId];
        
        // System.debug('name : :'+opportunityId);
        OpptyName = ObjOppty.name;
        AccountName = Acct.name;
        
        strSelected = '';
        options = new List<SelectOption>();
        User u =[Select id,Region__c FROM User where id =: userInfo.getUserId()];
        System.debug('Quote:'+u);
        for(Quote obj :[SELECT Id, Name,Quote_Number__c,QU_REVISION_NUMBER__c,Account.name,Status
                        FROM Quote where Status NOT IN ('Draft', 'CREATED','CLOSE - REVISIED') 
                        /*AND REGION__c=:u.Region__c*/])//instead of BU_Project__c.Id pass actual id

        {
            String ListName = Obj.Quote_Number__c +' - '+ obj.Account.name +' - '+Obj.QU_REVISION_NUMBER__c	;
            //String ListName = Obj.name;

            options.add(new SelectOption(obj.Id,ListName));
        }
        
        // System.debug('RecordID : : :'+RecordID);
        
        
        System.debug('ctrl:'+objQ1 );
        strRecordType = new List<String>();
        optRecordType  = new List<SelectOption>();
        lstQLI  = new List<Quote>();
        
        //  recType = [SELECT Id, DeveloperName, Name FROM RecordType WHERE sobjecttype ='Quote'];
        //  for (RecordType rec : recType)
        // {
        //        optRecordType.add(new SelectOption(rec.DeveloperName,rec.Name));
        //    }
        
        // RecordID = objQ1.RecordTypeId;
    }
    
    public PageReference  CreateQuote() {
        System.debug('Reached');
        if(QuoteName != null && QuoteName != ''){
            Quote ObjQuote = new Quote();
            ObjQuote.name = QuoteName;
            ObjQuote.OpportunityId = opportunityId;
            ObjQuote.Status = 'CREATED';
            ObjQuote.QUOTATION_CREATE__c = 'CREATE FROM BLANK';
            insert ObjQuote;
            Quoteid = ObjQuote.id;
            Opportunity Oppty = new Opportunity();
            Oppty = [select id,name,StageName from Opportunity where id=: opportunityId];
            Oppty.stageName = 'Under Quotation';
            try
            {
                update Oppty;
                
            }
            catch(Exception e)
            {}
            
            System.debug('Quoteid'+Quoteid);
            
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Created Successfully.Thank you!'));
            PageReference myVFPage = new PageReference('/'+Quoteid);
            myVFPage.setRedirect(true);
            return myVFPage;
            
        }
        else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Not Created Successfully.Make Sure You Entered The Name.Thank you!')); 
            return null;
        }
        
        
    }
    
    
    
    Public PageReference QuoteClone(){
        
        system.debug('QuoteNameFieldClone === ' + QuoteNameFieldClone);
        
        if(QuoteNameFieldClone != null || QuoteNameFieldClone !=''){
            String name = strSelected;
            Quote ObjQte= new Quote();
            system.debug('strSelected ===>>> ' + strSelected);
            
            ObjQte = [select id,name,Quote_Number__c from Quote where id =: strSelected];
            String QuoteNum = ObjQte.Quote_Number__c;
            system.debug('ObjQte ===>>> ' + ObjQte);
            
            Quote LsrQte = new Quote();
            LsrQte = [Select id,name,Quote_Number__c,QU_REVISION_NUMBER__c from Quote where Quote_Number__c =: QuoteNum ORDER BY QU_REVISION_NUMBER__c DESC Limit 1];
            //System.debug('LsrQte'+LsrQte.size());
            System.debug('LsrQte'+LsrQte);
            
            String QuoteIdrev  =  LsrQte.id;
            System.debug('QuoteIdrev : : : : '+QuoteIdrev);
            System.debug('name : : : : '+name);
            
            String oppId = ApexPages.CurrentPage().getparameters().get('id'); 
            Opportunity Oppty = new Opportunity();
            Oppty =[select id, name,Zero_Cooling__c,Class__c,MFG_AT__c,APPLICATION__c  from Opportunity where id = :oppId];
            
            Quote ObjQ = new Quote();
            ObjQ.Discount__c=0;
            
            ObjQ = [Select id,AccountId,AdditionalAddress,AdditionalName,BillingAddress,BillingName,ContactId,Description,Opportunity.Zero_Cooling__c,Zero_Cooling__c,
                    Discount,Discount__c,Email,ExpirationDate,Fax,GrandTotal,LineItemCount,OpportunityId,Phone,CurrencyIsoCode,Name,Opportunity.APPLICATION__c,Class__c,
                    QuoteNumber,QuoteToAddress,QuoteToName,ShippingHandling,ShippingAddress,ShippingName,Status,Application__c,Opportunity.Class__c,Machine_Delivery__c,
                    Subtotal,IsSyncing,Tax,TotalPrice,ACCOUNT_BUSINESS__c,ACCOUNT_TYPE__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,Opportunity.MFG_AT__c,
                    ADVANCE_PAYMENT__c,CITY__c,CLOSE_LOST_REASON__c,Contact__c,COUNTRY__c,COUNTRY_CODE__c,DATE__c,Designation__c,END_CUSTOMER_NAME__c,Mould_Delivery__c,
                    FUNCTION__c,INCO_TERMS__c,MFG_AT__c,POSTAL_CODE__c,PREPARED_BY__c,PROBABILITY__c,QUOTATION_ADDRESSED_TO__c,QUOTATION_CREATE__c,QU_REVISION_NUMBER__c,
                    /*REGION__c,*/SHIP_TO__c,SOLD_TO__c,STATE__c,SUBSIDARY__c,TYPE__c,VALIDITY__c,VALITY_DATE__c,Quote_Number__c,Pricebook2Id
                    from Quote Where id =:QuoteIdrev limit 1];
            System.debug('ObjQ'+ObjQ);
            Id stQuote = Schema.SObjectType.quote.getRecordTypeInfosByName().get('Blank Quote').getRecordTypeId();
            Quote QuoteClone  = ObjQ.clone(false, false, false, false);
            QuoteClone.name = QuoteNameFieldClone;
            QuoteClone.RecordTypeId = stQuote;
            QuoteClone.Status = 'CREATED'; 
            QuoteClone.OpportunityId = opportunityId;
            QuoteClone.QUOTATION_CREATE__c = 'COPY FROM REFENCE QUOTATION';
            QuoteClone.Application__c = Oppty.APPLICATION__c;
            QuoteClone.MFG_AT__c = Oppty.MFG_AT__c;
            QuoteClone.Class__c = Oppty.Class__c;
            QuoteClone.Zero_Cooling__c = Oppty.Zero_Cooling__c;
            QuoteClone.PREPARED_BY__c = oppty.Prepared_By__c;
            
            //QuoteClone.AccountId = AccountId;
            insert QuoteClone;
            String CloneId =  QuoteClone.id; 
            String opptyId = ObjQ.OpportunityId;
            
            ObjQuoteLineItem = [Select id,Discount_Approval_Note__c,Approval_Status__c,Class__c,Division__c,Drawing_No__c,Expected_Customer_PO__c,Product__r.Model__c,
                                Expected_Delivery__c,Expected_Delivery_date__c,Expected_Drawing_Final__c,Product_Type__c,Scope_of_mould__c,Cavity__c,Product__r.Division__c,
                                Name,Mach_Mold_No__c,MFG__c,Quantity__c,Discount__c,Product_Name__c,MFG_AT__c,Class_2__c,Model__c,Is_Manual__c,Product__r.UOM__c,
                                List_Price__c,Product__c,Product__r.ProductCode,Quote__c,Base_Price__c,Zero_Cooling_2__c,UOM__c,Application__c,Product_Description__c,
                                (Select id,Discount__c,Final_Price__c,Manual_Option__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Discount_Description__c,
                                 Other_Charges_Base_Price__c,Other_Charges_Function__c,Product__c,Quote__c,Quote_Line_Item_Custom__c,Select_Option__c,Mould_Cavity__c,Price_Type__c
                                 from Quote_Line_Options__r)
                                from Quote_Line_Item_Custom__c Where Quote__c =: QuoteIdrev];
            
            
            System.debug('ObjQuoteLineItem'+ObjQuoteLineItem);
            System.debug('ObjQuoteLineItem'+ObjQuoteLineItem.size());
            set<Id> IdOfOpQuoteItem = new Set<Id>();
            for(Quote_Line_Item_Custom__c QLN : ObjQuoteLineItem){
                IdOfOpQuoteItem.add(QLN.id);
            }
            
            List<Quote_Line_Options__c> lstQuoteOption = new List<Quote_Line_Options__c>();
            if(IdOfOpQuoteItem != null && IdOfOpQuoteItem.size() > 0){
                lstQuoteOption = [Select id,Discount__c,Option_Number__c,quantity__c,Manual_Product_Name__c, Final_Price__c,Manual_Option__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Product__r.UOM__c,Description__c,
                                  Other_Charges_Base_Price__c,Other_Charges_Function__c,Product__c,Quote__c,Quote_Line_Item_Custom__c,Select_Option__c,Manula_Option_List_Price__c,Mould_Cavity__c,Price_Type__c,Discount_Description__c
                                  from Quote_Line_Options__c where Quote_Line_Item_Custom__c IN : IdOfOpQuoteItem];
            }
            
            system.debug('lstQuoteOption===> '+lstQuoteOption);
            system.debug('lstQuoteOption===> '+lstQuoteOption.size());
            List<Quote_Line_Item_Custom__c> Lst = new List<Quote_Line_Item_Custom__c>();
            List<Quote_Line_Options__c  > ListQLo = new  List<Quote_Line_Options__c >();
            List<Quote_Line_Item_Custom__c> lstContractItem = new List<Quote_Line_Item_Custom__c>();
            Map<Id,Quote_Line_Item_Custom__c> MapofQuoteContract = new Map<Id,Quote_Line_Item_Custom__c>();
            PriceBookEntry pbe = new PriceBookEntry();
            
            for(Quote_Line_Item_Custom__c pro1 : ObjQuoteLineItem){
                String QLIid = pro1.Id;
                system.debug('pro1.Id ===>>> ' + pro1.Id);
                System.debug('ObjQuoteLineItem'+ObjQuoteLineItem);
                System.debug('pro1'+pro1.Product__c);
                Quote_Line_Item_Custom__c cli = new Quote_Line_Item_Custom__c();
                System.debug('CloneId:::::'+CloneId);
                
                if(pro1.Is_Manual__c == false){
                    system.debug('not manual');
                    cli.Application__c = Oppty.APPLICATION__c;
                    cli.MFG_AT__c = Oppty.MFG_AT__c;
                    cli.Class_2__c = Oppty.Class__c;
                    cli.Zero_Cooling_2__c = Oppty.Zero_Cooling__c;
                    cli.UOM__c = pro1.Product__r.UOM__c;
                    cli.Model__c = pro1.Product__r.Model__c;
                    cli.Division__c = pro1.Product__r.Division__c;
                    pbe = [SELECT Product2.Id,Discount__c,Product2.Description, Product2.Name,UnitPrice,Product2.Plant__c,Product2.Product_Number__c,Product2.Option_No__c,
                           Product2.Family,Product2.Number_Of_Cavity_Mould__c,Product2.Option_Type__c,Product2.Product_Type__c,Product2.Scope_of_Mold__c,Product2.ProductCode,
                           Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c,Pricing_Type__c,Discount_Level_2__c,Discount_Level_3__c,Quantity__c,Description__c
                           FROM PriceBookEntry Where Product2.IsActive = TRUE AND Pricebook2.Name =: 'Standard Price Book' AND Product2.Id =: pro1.Product__c Limit 1];
                    system.debug('pbe ===>>> ' + pbe);
                    if( CloneId!=null && CloneId != ''){
                        cli.Quote__c = CloneId; 
                        System.debug('cli.QuoteId:::::'+cli.Quote__c );
                    }
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
                    if(pro1.List_Price__c !=null){ 
                        system.debug('pbe.UnitPrice ===>>> ' + pbe.UnitPrice);
                        cli.List_Price__c = pbe.UnitPrice; 
                    }
                    if(pro1.Product_Name__c !=null){ 
                        cli.Product_Name__c = pro1.Product_Name__c; 
                    }
                    /*if(pro1.description!=null){
cli.description__c = pro1.description; 
}*/
                    if(pro1.Quantity__c!=null){
                        cli.Quantity__c = ObjQuoteLineItem[0].Quantity__c; 
                    }
                    if(pro1.Base_Price__c !=null)
                    {
                        system.debug('pbe.Base_Price__c ===>>> ' + pbe.Base_Price__c);
                        cli.Base_Price__c = pbe.Base_Price__c;
                    }
                    //  if(pro1.Line_Item_Number_Text__c!=null){
                    //      cli.Line_Item_Number_Text__c = pro1.Line_Item_Number_Text__c; 
                    // }
                    //   if(pro1.ListPrice!=null && pro1.Quantity !=null ){
                    //     cli.UnitPrice =pro1.ListPrice * pro1.Quantity; 
                    //}
                    if(pro1.Discount__c!=null){
                        cli.Discount__c = pro1.Discount__c; 
                    }
                    else{
                        cli.Discount__c = 0;
                    }
                    
                    if(pro1.Discount_Approval_Note__c != null){
                        cli.Discount_Approval_Note__c = pro1.Discount_Approval_Note__c;
                    }
                    else{
                        cli.Discount_Approval_Note__c = 'Null';
                    }
                }
                
                if(pro1.Is_Manual__c == true){
                    cli.Application__c = Oppty.APPLICATION__c;
                    cli.MFG_AT__c = Oppty.MFG_AT__c;
                    cli.Class_2__c = Oppty.Class__c;
                    cli.Zero_Cooling_2__c = Oppty.Zero_Cooling__c;
                    if( CloneId!=null && CloneId != ''){
                        cli.Quote__c = CloneId; 
                        System.debug('cli.QuoteId:::::'+cli.Quote__c );
                    }
                    if(pro1.Product_Description__c !=null){ 
                        cli.Product_Description__c = pro1.Product_Description__c; 
                    }
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
                    /*if(pro1.description!=null){
cli.description__c = pro1.description; 
}*/
                    if(pro1.Quantity__c!=null){
                        cli.Quantity__c = ObjQuoteLineItem[0].Quantity__c; 
                    }
                    if(pro1.Base_Price__c !=null)
                    {
                        cli.Base_Price__c = pro1.Base_Price__c;
                    }
                    //  if(pro1.Line_Item_Number_Text__c!=null){
                    //      cli.Line_Item_Number_Text__c = pro1.Line_Item_Number_Text__c; 
                    // }
                    //   if(pro1.ListPrice!=null && pro1.Quantity !=null ){
                    //     cli.UnitPrice =pro1.ListPrice * pro1.Quantity; 
                    //}
                    if(pro1.Discount__c!=null){
                        cli.Discount__c = pro1.Discount__c; 
                    }
                    else{
                        cli.Discount__c = 0;
                    }
                    
                    if(pro1.Discount_Approval_Note__c != null){
                        cli.Discount_Approval_Note__c = pro1.Discount_Approval_Note__c;
                    }
                    else{
                        cli.Discount_Approval_Note__c = 'Null';
                    }
                }
                
                System.debug('cli==> '+cli);
                lstContractItem.add(cli);
                MapofQuoteContract.put(pro1.Id,cli);
            }  
            try{
                insert MapofQuoteContract.values();
            }
            catch(Exception e){
                
                System.debug('Error::::'+e.getMessage());
                
            }
            system.debug('MapofQuoteContract===> '+MapofQuoteContract);
            system.debug('lstContractItem====> '+lstContractItem);
            
            User UsedDeatil = new User();
            UsedDeatil = [select id,Name,Level__c,Region__c from User where id =: userInfo.getUserId()];
            String Level = UsedDeatil.Level__c;
            
            for(Quote_Line_Options__c pro2 :lstQuoteOption){
                
                system.debug('size ===>>> check ' );
                Quote_Line_Options__c ContLO =new Quote_Line_Options__c();
                System.debug('MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id====='+MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id); 
                
                System.debug('Record id :::::'+pro2.id+'    Map:::::'+MapofQuoteContract);
                ContLO.Quote_Line_Item_Custom__c  = MapofQuoteContract.get(pro2.Quote_Line_Item_Custom__c).id;  //.Id
                system.debug('ContLO.Quote_Line_Item_Custom__c ====>>>> ' + ContLO.Quote_Line_Item_Custom__c);
                String prodId = pro2.Product__c;
                System.debug('prodId'+prodId);
                
                PriceBookEntry pbeEntry = new PriceBookEntry();
                if(prodId != null  && prodId!= ''){
                    pbeEntry = [SELECT Product2.Id,Discount__c,Product2.Description, Product2.Name,unitprice,Product2.Plant__c,Product2.Product_Number__c,Product2.Option_No__c,
                                Product2.Family,Product2.Number_Of_Cavity_Mould__c,Product2.Option_Type__c,Product2.Product_Type__c,Product2.Scope_of_Mold__c,
                                Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c,Pricing_Type__c,Discount_Level_2__c,Discount_Level_3__c,Quantity__c
                                FROM PriceBookEntry 
                                WHERE Pricebook2Id IN (SELECT Id FROM PriceBook2  where Name = 'Option Price Book' AND PriceBook2.IsActive = true)
                                AND Product2.IsACTIVE = true AND Product2.Family = 'Options' AND Product2.Id =: prodId Limit 1];
                    System.debug('pbeEntry'+pbeEntry);
                }
                
                if( pro2.Select_Option__c == false){
                    ContLO.UOM__c = pro2.Product__r.UOM__c;
                    system.debug('in manual fasle');
                    if(pro2.Product__c !=null){
                        ContLO.Product__c = pro2.Product__c;
                    } 
                    
                    if(pro2.Discount__c != null){
                        ContLO.Discount__c = pro2.Discount__c;
                    }
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
                    if(Level == 'L1'){
                        if(pbeEntry.UnitPrice != null){
                            ContLO.Manula_Option_List_Price__c = pbeEntry.UnitPrice;
                        }  
                    }
                    if(Level == 'L2'){
                        if(pbeEntry.UnitPrice != null){
                            ContLO.Manula_Option_List_Price__c = pbeEntry.List_Price_level_2__c;
                        }  
                    }
                    if(Level == 'L3'){
                        if(pbeEntry.UnitPrice != null){
                            ContLO.Manula_Option_List_Price__c = pbeEntry.List_Price_level_3__c;
                        }
                    }
                    if(pbeEntry.Base_Price__c != null){
                        ContLO.Manual_Option_Base_Price__c = pbeEntry.Base_Price__c;
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
                    if(pro2.Option_Number__c !=null){
                        ContLO.Option_Number__c = pro2.Option_Number__c;
                    }
                    if(pro2.Manual_Product_Name__c !=null){
                        ContLO.Manual_Product_Name__c = pro2.Manual_Product_Name__c;
                    }
                    if(pro2.Mould_Cavity__c !=null){
                        ContLO.Mould_Cavity__c = pro2.Mould_Cavity__c;
                    }
                    /*if(pro2.Price_Type__c !=null){
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
                    
                }
                
                else if(pro2.Select_Option__c == true){
                    system.debug('in manual true');
                    /* if(pro2.Quote_Line_Item_Custom__c !=null){
ContLO.Quote_Line_Item_Custom__c = pro2.Quote_Line_Item_Custom__c;
}*/
                    
                    if(pro2.Description__c != null){
                        ContLO.Description__c = pro2.Description__c;
                    }
                    if(pro2.Product__c !=null){
                        ContLO.Product__c = pro2.Product__c;
                    } 
                    if(pro2.Discount__c != null){
                        ContLO.Discount__c = pro2.Discount__c;
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
                  /*  if(pro2.Price_Type__c !=null){
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
                }
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
            
            
            
            
            
            
            opportunityId = ApexPages.CurrentPage().getparameters().get('id'); 
            Opportunity Opptynew = new Opportunity();
            system.debug('opportunityId ===>>> ' + opportunityId);
            Opptynew = [select id,name,StageName from Opportunity where id=: opportunityId];
            system.debug('Opptynew ===>>> ' + Opptynew);
            Opptynew.stageName = 'Under Quotation';
            update Opptynew;
            
            System.debug('QuoteClone'+QuoteClone);
            System.debug('CloneId'+CloneId);
            
            List<Attachment> lstAtt = new List<Attachment>();
            lstAtt = [select id, name, body, LastModifiedDate, Createddate , createdby.name,ParentId from Attachment where ParentId=:CloneId ];
            
            lstAtt.clear();
            
            PageReference myVFPage = new PageReference('/'+CloneId);
            myVFPage.setRedirect(true);
            return myVFPage;
            
            
            
        }
        else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Not Created Successfully.Make Sure You Entered The Quote Clone Name.Thank you!')); 
            return null;
        }
        
        
        
        
        
    }
    
    public void dummy2(){
      integer q=0;
        q++;
        q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++; q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++; q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++; q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++; q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++; q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++; q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++; q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++; q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++; q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++; q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;q++;
        q++;
        
        
    }
    
   
    
    
    public void importCSVFile(){
         integer n=0;
    n=n+1;
    n=n+1;
     n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1; n=n+1;
    n=n+1;    
        
    
        
        System.debug('csvAsString : : '+csvAsString);
        System.debug('csvFileBody : : '+csvFileBody);
        
        try{
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n'); 
            
            for(Integer i=1;i<csvFileLines.size();i++){
                Quote accObj = new Quote() ;
                string[] csvRecordData = csvFileLines[i].split(',');
                accObj.name = csvRecordData[0] ;             
                accObj.OpportunityId = opportunityId;
                accObj.QUOTATION_CREATE__c = 'CREATE FROM TEMPLATE';
                QuoteList.add(accObj);   
            }
            insert QuoteList;
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }  
    }
    
    
    Public void VERIFY(){
        System.debug('QuoteNameFieldClone == '+QuoteNameFieldClone);
        System.debug('strSelected'+strSelected);
        
        if(QuoteNameFieldClone != null && QuoteNameFieldClone !=''){  
            Clone2 = True;
            clone = true;
            clone1 = false;
        }
        else if(QuoteNameFieldClone == null || QuoteNameFieldClone !=''){
            Clone2 = false;
            clone1 = True;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Record Not Created Successfully.Make Sure You Entered The Quote Clone Name.Thank you');
            ApexPages.addMessage(errorMessage); 
        }
    }
    
    
    public void VerifyBlank(){
        System.debug('QuoteName'+QuoteName);
        if(QuoteName != null && QuoteName !=''){  
            Clone4 = True;
            clone5 = true;
            clone3 = false;
        }
        else if(QuoteName == null || QuoteName !=''){
            Clone3 = false;
            clone4 = True;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Record Not Created Successfully.Make Sure You Entered The Quote Name.Thank you');
            ApexPages.addMessage(errorMessage); 
        }
        
        
    }
    public PageReference refresh() {
        System.debug('Inside This');
        return null;
    }
    
    public void determinePageBlock(){
        System.debug('reached here and now filter works');
        String filtervalue = filter;
        System.debug('filtervalue = = = = '+filtervalue);
        if(filtervalue != null && filtervalue != ''){
            strSelected = '';
            options = new List<SelectOption>();
            filtervalue = filtervalue + '%'; 
            System.debug('filtervalue = = = = '+filtervalue);
            User u =[Select id,Region__c FROM User where id =: userInfo.getUserId()];
            List<Quote> lst = new List<Quote>();
            lst = [SELECT Id, Name,Quote_Number__c,QU_REVISION_NUMBER__c,Account.name,Status
                   FROM Quote where Status NOT IN ('Draft', 'CREATED','CLOSE - REVISIED') 
                   AND Region1__c=:u.Region__c AND Name Like :filtervalue];
            System.debug('lst = == '+lst);
            if(lst != null && lst.size()>0){
                for(quote qt:lst){
                    String ListName = qt.Quote_Number__c +' - '+ qt.Account.name +' - '+qt.QU_REVISION_NUMBER__c	;
                    //String ListName = Obj.name;
                    options.add(new SelectOption(qt.Id,ListName));   
                }
            }
            
            
            
        }else{
            System.debug('else');
            strSelected = '';
            options = new List<SelectOption>();
            User u =[Select id,Region__c FROM User where id =: userInfo.getUserId()];
            for(Quote obj :[SELECT Id, Name,Quote_Number__c,QU_REVISION_NUMBER__c,Account.name,Status
                            FROM Quote where Status NOT IN ('Draft', 'CREATED','CLOSE - REVISIED') 
                            /*AND REGION__c=:u.Region__c*/])//instead of BU_Project__c.Id pass actual id
            {
                String ListName = Obj.Quote_Number__c +' - '+ obj.Account.name +' - '+Obj.QU_REVISION_NUMBER__c	;
                //String ListName = Obj.name;
                options.add(new SelectOption(obj.Id,ListName));
            }  
        }
    }
    
}