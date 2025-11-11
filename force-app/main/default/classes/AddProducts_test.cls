@isTest
public class AddProducts_test {
    
    
    public static testMethod void validateTestMethod(){
        Fiscal_Year_Master__c f= new Fiscal_Year_Master__c();
        f.Active__c=true;
        f.Fiscal_Year_Start_Date__c=system.today()-65;
        f.Fiscal_Year_End_Date__c=system.today()+300;
        f.Name='NPL';
        insert f;

Pricebook2  priObject = new Pricebook2(Name = 'Pri1' );
        insert priObject;
        
        Subsidiari_Master__c s = new Subsidiari_Master__c();
        s.Name = 'IPL';
        s.Name__c = 'xyg';
        s.Active__c = true;
        s.Price_Book__c = priObject.Id;
        s.Office__c = 'Airforce';
        s.Rounding_Off_Digits__c = '10000';
        s.Permitted_Currency__c = 'INR';
        s.Permitted_Language__c = 'EN';
        s.Rounding_Off_Digits__c = '1';
        s.Discount_Level_1__c = 5;
        s.Discount_Level_2__c = 10;
        s.Discount_Level_3__c = 15;
        s.Quote_Approval__c ='Line Item level';
        s.Contract_Approval__c = 'Line Item level';
        s.Permitted_Language__c = 'HI';
        insert s;
        
        Country_List__c c=new Country_List__c();
        c.Active__c = true;
        c.Name = 'India';	
        c.Subsidiary__c=s.id;
        insert c;
        
        Region__c re = new Region__c();
        re.Active__c = true;
        re.Country__c = c.Id;
        re.Name = 'EAST';
        re.Name__c = 'EAST';
        insert re;
        
        User_Setup__c u=new User_Setup__c();
        u.Country__c=c.Id;
        u.User__c=Userinfo.getUserId();
        u.Subsidiari__c = s.Id;
        u.Region__c = re.Id;
        u.Default_Language__c = 'HI';
        insert u;
        
        Assign_Region__c ar = new Assign_Region__c();
        ar.User_Setup__c=u.Id;
        ar.Country__c = c.Id;
        ar.Region__c = re.Id;
        insert ar;
        
        Campaign camObject = new Campaign(Name = 'Cam1' , CurrencyIsoCode = 'INR');
        insert camObject;
        
        Account accObject = new Account( CurrencyIsoCode = 'INR' , Name = 'Test1', Region1__c = re.Id);
        insert accObject;
        
        Opportunity oppObject = new Opportunity(AccountId = accObject.Id  , Name = 'Opp1',Zero_Cooling__c='Yes' , CurrencyIsoCode = 'INR' , StageName = 'New' , CloseDate = System.today() );
        insert oppObject;
        
        Product2 proObject = new Product2(CurrencyIsoCode   = 'INR' ,ProductCode='123',Family = 'Items',Language__c='EN',Description='56789',
                                          Name = 'Pro1', isActive = TRUE,Product_Number__c='123',Subsidiari__c=s.Id);
        insert proObject;
        
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Options');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = proObject.Id,
            UnitPrice = 10000, 
            UseStandardPrice= false,
            IsActive = true,
            Base_Price__c = 123,
            Discount_Level_3__c = 12,
            Pricing_Type__c = 1,
            Quantity__c = 1,
            D1__c = 0.1,
            D3__c = 0.2,
            D2__c = 0.3,
            M1__c = 0.1,
            M2__c = 0.2,
            M3__c = 0.3,
            M4__c = 0.4,
            Rounding_Off_Digits__c = '10');
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        insert customPB;
        
        QuoteRecursionCheck.isfirsttime=false;
        Quote qObject = new Quote(Name = 'Q1', Exchange_Rate__c = 1, OpportunityId = oppObject.Id,Language__c='EN',Subsidiary__c=s.Id );
        insert qObject;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qObject.id;
        qli.Discount__c = 1;
        qli.Quantity__c = 1;
        qli.Cavity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Base_Price__c = 1;
        qli.Product__c = proObject.id;
        insert qli;
        
        List<Quote_Line_Item_Custom__c> lstQLI = new List<Quote_Line_Item_Custom__c>();
        lstQLI.add(qli);
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        List<Integer> lstquan = new List<Integer>();
        lstquan.add(10);
        lstquan.add(20);
        lstquan.add(30);
        lstPBE.add(standardPrice);
        String rec = String.valueOf(qObject.id);
        
        Test.StartTest();
        
        try{
           AddProducts.SelectedProd(lstPBE, 'asdfghjkl' , lstquan,'asdfghjkl');
        }catch(Exception e){
            System.debug('Error: ==> '+e.getMessage());
        } 
        
        AddProducts.checkDate(qObject.id);
        AddProducts.getProductList(qObject.id);
        AddProducts.enterManualProd(lstQLI, rec);
        AddProducts.getQuotationDetails(qObject.id);
        AddProducts.getListPrice(1,1,1,1,1,1,1,1);
        AddProducts.getPickListValuesIntoList();
        AddProducts.getPickListValuesIntoListv2();
        
         List<AddProducts.ProdListWrapper> wrapperList = new List<AddProducts.ProdListWrapper>();
        List<map<string,object>> jslist = new List<map<string,object>>();
        map<string,object> wrpMap = new map<string,object>();
        wrpMap.put('quantity',1);
        wrpMap.put('objprod',standardPrice);
        wrpMap.put('isChecked',true);
        wrpMap.put('serial_no',1);
        jslist.add(wrpMap);
        
        AddProducts.SelectedProd(lstPBE, qObject.id , lstquan,JSON.serialize(jslist));

              
        
        //AddProducts.ProdListWrapper pfd = new AddProducts.ProdListWrapper();
        
        
        Test.StopTest();
    }
}