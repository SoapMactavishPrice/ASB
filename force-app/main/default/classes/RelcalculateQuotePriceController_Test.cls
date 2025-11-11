@isTest
public class RelcalculateQuotePriceController_Test {
public static testMethod void unitTest1(){
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ABC';
        sub.Name__c = 'xyg';
        sub.Active__c = true;
        sub.Office__c = 'Airforce';
        sub.Rounding_Off_Digits__c = '10';
        sub.Permitted_Currency__c = 'INR';
        sub.Permitted_Language__c = 'EN';
        sub.Discount_Level_1__c = 5;
        sub.Discount_Level_2__c = 10;
        sub.Discount_Level_3__c = 15;
        sub.Quote_Approval__c ='Line Item level';
        sub.Contract_Approval__c = 'Line Item level';
        sub.Price_Book__c=Test.getStandardPricebookId();
        sub.Negative_Discount__c = 10;
        sub.Additional_Margin__c=1;
        sub.M1__c=1;
        sub.D1__c=1;
   		sub.D2__c=1;
        sub.D3__c=1;
        sub.M2__c=1;
        sub.M3__c=1;
        insert sub;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = 'IP';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
          
        Country_List__c c1=new Country_List__c();
        c1.Name='test';
        c1.Subsidiary__c = sub.id;
        insert c1;
        
        Region__c r = new Region__c();
        r.Name = 'test';
        r.Name__c = 'test';
        r.Country__c =c1.id;
        Insert r;
        
        State_List__c s1=new State_List__c();
        s1.Name='test1';
        s1.Country__c = c1.id;
        s1.Region__c = r.id;
        insert s1;
        
        City_List__c o=new City_List__c();
        o.Name='test';
        o.State__c = s1.id;
    	o.Subsidiary_Master__c = sub.Id;
        insert o;
        
        User_Setup__c us = new User_Setup__c();
        us.Subsidiari__c = sub.Id;
        us.User__c = userInfo.getUserId();
        us.Country__c = c1.id;
        insert us;
        
      /*  PIN_Code_Master__c pin = new PIN_Code_Master__c();
        pin.Active__c = true;
        //pin.City__c = o.Id;
    	pin.Name = '001';
        insert pin; */
        
     //   Account accObject = new Account( CurrencyIsoCode = 'INR' , Name = 'Test1');
      //  insert accObject;
        
        Account accObject=new Account(name='test', CurrencyIsoCode='INR', ERP_ID__c='Test ERP', Global_Customer_Name__c='MARS', Account_Type__c='LOCAL' /*Billing_Postal_ZIP_Code__c = pin.Id*/);
        insert accObject;
        
        accObject.Name = 'new update';
        accObject.Shipping_Postal_Code__c = 'qw234e';
        accObject.Pin_Code__c = '001';
        accObject.Billing_City__c=o.id;
        accObject.Billing_Country__c=c1.Id;
        accObject.Billing_State__c=s1.Id;
        accObject.Shipping_City__c=o.Id;
        accObject.Shipping_Country__c=c1.Id;
        accObject.ShippingState=s1.id;
        
        update accObject;
        
        Pricebook2	priObject = new Pricebook2(Name = 'Standard Price Book',IsActive = true);
        insert priObject;
    
        Opportunity op = new Opportunity(AccountId = accObject.Id  , Name = 'Opp1' , CurrencyIsoCode = 'INR' , StageName	= 'New' , CloseDate = System.today(),
                                        Pricebook2Id = priObject.id, Subsidiary__c = sub.id);
        insert op;
        Product2 proObject = new Product2(CurrencyIsoCode	= 'INR' , Name = 'Pro1');
        insert proObject;
        

        
        quote qt = new quote();
        qt.Status = 'CREATED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 0;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Additinal_Margin__c = 1;
        insert qt;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        pro.IsActive=true;
        insert pro;
        
        //Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = pro.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 100;
        pbe.UseStandardPrice= false;
        pbe.IsActive = true;
        pbe.D1__c = 0.1;
    pbe.D3__c = 0.2;
    pbe.D2__c = 0.3;
    
   pbe.M1__c = 0.1;
    pbe.M2__c = 0.2;
    pbe.M3__c = 0.3;
    pbe.M4__c = 0.4;
    pbe.Rounding_Off_Digits__c = '10';
        pbe.Base_Price__c = 100;
        pbe.Discount_Level_3__c = 12;
        pbe.Pricing_Type__c = 1;
        pbe.Quantity__c = 1;
        insert pbe;

        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 0;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 1200;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        qli.Base_Price__c=120;
        qli.Level_Of_Ceiling__c='10';
        insert qli;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Select_Option__c = true;
        qlo.Manula_Option_List_Price__c = 120;
        qlo.Product__c = pro.id;
        qlo.Select_Option__c=false;
        insert qlo;
    	
        qt.Status = 'RELEASED';
        Update qt;
    
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        RelcalculateQuotePriceController test1 = new RelcalculateQuotePriceController(sc);
        PageReference pageRef = Page.RecalculatePrice; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        test1.Recalculate();
        Test.StopTest(); 
}

/* public static testMethod void unitTest2(){
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ABC';
        sub.Name__c = 'xyg';
        sub.Active__c = true;
        sub.Office__c = 'Airforce';
        sub.Rounding_Off_Digits__c = '10000';
        sub.Permitted_Currency__c = 'INR';
        sub.Permitted_Language__c = 'EN';
        sub.Discount_Level_1__c = 5;
        sub.Discount_Level_2__c = 10;
        sub.Discount_Level_3__c = 15;
        sub.Quote_Approval__c ='Line Item level';
        sub.Additional_Margin__c = 10;
        sub.Price_Book__c = Test.getStandardPricebookId();
        sub.Quote_Approval__c ='Line Item level';
        sub.Contract_Approval__c = 'Line Item level';
        sub.D1__c = 10;
        sub.M1__c = 10;
        insert sub;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = '420';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
          
        Country_List__c c1=new Country_List__c();
        c1.Name='test';
        c1.Subsidiary__c = sub.id;
        insert c1;
        
        Region__c r = new Region__c();
        r.Name = 'test';
        r.Name__c = 'test';
        r.Country__c =c1.id;
        Insert r;
        
        State_List__c s1=new State_List__c();
        s1.Name='test1';
        s1.Country__c = c1.id;
        s1.Region__c = r.id;
        insert s1;
        
        City_List__c o=new City_List__c();
        o.Name='test';
        o.State__c = s1.id;
        insert o;
        
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = c1.Id;
        insert us;
    
        Account acc = new Account();
        acc.Name = 'acc anem';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '250001';
        acc.Type = 'Press';
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.IsActive = true;
        insert pb;
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.Pricebook2Id = pb.id;
        op.Subsidiary__c = sub.id;
        insert op;
        
    	pb.Financial_Year__c = fym.Id;
    	update pb;
    
        quote qt = new quote();
        qt.Status = 'CREATED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1.6;
        qt.Discount__c = 12;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Additinal_Margin__c = 10;
   		
        insert qt;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
    	pro.IsActive = true;
        insert pro;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where ID =:pb.Id limit 1];

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = pro.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 100;
        pbe.UseStandardPrice= false;
        pbe.IsActive = true;
        pbe.Base_Price__c = 123;
        pbe.Discount_Level_3__c = 12;
        pbe.Pricing_Type__c = 1;
        pbe.Quantity__c = 1;
        insert pbe;

        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 1;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 1200;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        insert qli;
          
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Select_Option__c = true;
        qlo.Manula_Option_List_Price__c = 12;
        qlo.Product__c = pro.id;
        insert qlo;
    
        qt.Status = 'RELEASED';
        Update qt;
    
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        RelcalculateQuotePriceController test1 = new RelcalculateQuotePriceController(sc);
        PageReference pageRef = Page.RecalculatePrice; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        test1.Recalculate();
        Test.StopTest(); 
}*/
}