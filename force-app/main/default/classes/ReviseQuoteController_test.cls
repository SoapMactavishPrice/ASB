@isTest
public class ReviseQuoteController_test {
    public static testMethod void unitTest1(){
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
        sub.Price_Book__c = Test.getStandardPricebookId();
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
        o.Subsidiary_Master__c = sub.Id;
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
        op.Pricebook2Id = Test.getStandardPricebookId();
        insert op;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        pro.IsActive = true;
        pro.Description = 'sfas';
        pro.Family = 'Options';
        insert pro;
        
        
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

        
        quote qt = new quote();
        qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.Subsidiary__c = sub.Id;
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        //qt.Application__c = 'EDIBLE OIL';
        qt.Zero_Cooling__c = 'Yes';
        qt.Fax = '1234562';
        qt.Ship_To_City__c = 'mrt';
        qt.Ship_To_State__c = 'up';
        qt.Ship_To_Country__c = 'india';
        qt.Description = 'asd';
        qt.ShippingHandling = 123;
        qt.Phone = '7898562485';
        qt.ACCOUNT_TYPE__c = 'GLOBAL';
        qt.Tax = 12;
        qt.MFG_AT__c = 'INDIA';
        qt.Shipping_And_Handling__c  =32;
        qt.QU_REVISION_NUMBER__c = '001';
        qt.Exchange_Rate__c = 2;
        qt.Additinal_Margin__c = 0.22;
        qt.Discount__c = 12;
        qt.SOLD_TO__c = acc.Id;
        qt.SHIP_TO__c = acc.Id;
        insert qt;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        //qli.Application__c = 'EDIBLE OIL';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        qli.Level_Of_Ceiling__c = '1000';
        qli.MFG_AT__c = 'INDIA';
        qli.Mach_Mold_No__c = 'wqwet';
        qli.Zero_Cooling_2__c = 'Yes';
        qli.Cavity__c = 2;
        qli.Product_Name__c = 'awef';
        qli.Product_Type__c = 'MC';
        qli.Advance_Percentage__c = 30;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        //qli.Product_Description__c = 'adasds';
        
        qli.UOM__c = 'm';
        qli.Product__c =pro.id;
        qli.Class_2__c = 'DEVELOPMENT';
        qli.Base_Price__c = 899;
        insert qli;
        
        
        qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Base_Price__c = 990;
        qli.Class_2__c = 'STD PRODUCT';
        qli.Quantity__c = 1;
        //qli.Application__c = 'EDIBLE OIL';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = false;
        qli.Level_Of_Ceiling__c = '1000';
        qli.MFG_AT__c = 'INDIA';
        qli.Mach_Mold_No__c = 'wqwet';
        qli.Zero_Cooling_2__c = 'Yes';
        qli.Cavity__c = 2;
        qli.Product_Type__c = 'MC';
        qli.Advance_Percentage__c = 30;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        //qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
        qli.Product__c =pro.id;
        insert qli;
        
        
        Product2 pro2 = new Product2();
        //pro2.Product__c = pro.Id;
        pro2.name = 'prod namen';
        pro2.IsActive = true;
        pro2.Description = 'sfas';
        pro2.Family = 'Options';
        insert pro2;
        
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Product2Id = pro2.Id;
        pbe2.Pricebook2Id = Test.getStandardPricebookId();
        pbe2.UnitPrice = 100;
        pbe2.UseStandardPrice= false;
        pbe2.IsActive = true;
        pbe2.D1__c = 0.1;
    pbe2.D3__c = 0.2;
    pbe2.D2__c = 0.3;
    
   pbe2.M1__c = 0.1;
    pbe2.M2__c = 0.2;
    pbe2.M3__c = 0.3;
    pbe2.M4__c = 0.4;
    pbe2.Rounding_Off_Digits__c = '10';
        pbe2.Base_Price__c = 100;
        pbe2.Discount_Level_3__c = 12;
        pbe2.Pricing_Type__c = 1;
        pbe2.Quantity__c = 1;
        insert pbe2;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Product__c = pro2.id;
        qlo.Description__c = 'sfsd';
        qlo.Discount__c = 1;
        qlo.quantity__c = 2;
        qlo.Discount_Description__c = 'adas';
        qlo.Mould_Cavity__c = 2;
        //qlo.description__c = 'sfsdfds';
        qlo.Manual_Product_Name__c = 'name dummy';
        qlo.Discount_Type__c = 'Value';
        qlo.Select_Option__c = true;
       //qlo.Discount_in_Value__c = 123;
        qlo.Manual_Option_Base_Price__c = 12003;
        qlo.Manula_Option_List_Price__c  = 12300;
        insert qlo;
        
        qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Product__c = pro2.id;
       // qlo.Description__c = 'sfsd';
        //qlo.Discount__c = 1;
        qlo.quantity__c = 2;
        qlo.Discount_Description__c = 'adas';
        qlo.Mould_Cavity__c = 2;
        //qlo.description__c = 'sfsdfds';
        qlo.Manual_Product_Name__c = 'name dummy';
        qlo.Discount_Type__c = 'Value';
        qlo.Select_Option__c = false;
        qlo.Manual_Option_Base_Price__c = 12003;
        qlo.Manula_Option_List_Price__c  = 12300;
        
        
        insert qlo;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(qt);
        ReviseQuoteController ctrl = new ReviseQuoteController(sc);
        PageReference pageRef = Page.ReviseQuote; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        
        
        List<Opportunity> opLst = new List<Opportunity>();
        opLst.add(op);
        ctrl.ReviseQuotation();
        ctrl.CloseModal();
        test.stopTest();
    }
    
    public static testMethod void unitTest2(){
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
        sub.Price_Book__c = Test.getStandardPricebookId();
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
        o.Subsidiary_Master__c = sub.Id;
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
        op.Pricebook2Id = Test.getStandardPricebookId();
        insert op;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        pro.IsActive = true;
        pro.Description = 'sfas';
        pro.Family = 'Options';
        insert pro;
        
        
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

        
        quote qt = new quote();
        qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.Subsidiary__c = sub.Id;
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        //qt.Application__c = 'EDIBLE OIL';
        qt.Zero_Cooling__c = 'Yes';
        qt.Fax = '1234562';
        qt.Ship_To_City__c = 'mrt';
        qt.Ship_To_State__c = 'up';
        qt.Ship_To_Country__c = 'india';
        qt.Description = 'asd';
        qt.ShippingHandling = 123;
        qt.Phone = '7898562485';
        qt.ACCOUNT_TYPE__c = 'GLOBAL';
        qt.Tax = 12;
        qt.MFG_AT__c = 'INDIA';
        qt.Shipping_And_Handling__c  =32;
        qt.QU_REVISION_NUMBER__c = '001';
        qt.Exchange_Rate__c = 2;
        qt.Additinal_Margin__c = 0.22;
        qt.Discount__c = 12;
        qt.Use_Current_Price__c = true;
        insert qt;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Product_Description__c = '345678';
        //qli.Application__c = 'EDIBLE OIL';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        qli.Level_Of_Ceiling__c = '1000';
        qli.MFG_AT__c = 'INDIA';
        qli.Mach_Mold_No__c = 'wqwet';
        qli.Zero_Cooling_2__c = 'Yes';
        qli.Cavity__c = 2;
        qli.Product_Type__c = 'MC';
        qli.Advance_Percentage__c = 30;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        //qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
        qli.Product__c =pro.id;
        qli.Class_2__c = 'DEVELOPMENT';
        qli.Base_Price__c = 899;
        insert qli;
        
        
        qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Base_Price__c = 990;
        qli.Class_2__c = 'STD PRODUCT';
        qli.Quantity__c = 1;
        //qli.Application__c = 'EDIBLE OIL';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = false;
        qli.Level_Of_Ceiling__c = '1000';
        qli.MFG_AT__c = 'INDIA';
        qli.Mach_Mold_No__c = 'wqwet';
        qli.Zero_Cooling_2__c = 'Yes';
        qli.Cavity__c = 2;
        qli.Product_Type__c = 'MC';
        qli.Advance_Percentage__c = 30;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        //qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
        qli.Product__c =pro.id;
        insert qli;
        
        
        Product2 pro2 = new Product2();
        //pro2.Product__c = pro.Id;
        pro2.name = 'prod namen';
        pro2.IsActive = true;
        pro2.Description = 'sfas';
        pro2.Family = 'Options';
        insert pro2;
        
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Product2Id = pro2.Id;
        pbe2.Pricebook2Id = Test.getStandardPricebookId();
        pbe2.UnitPrice = 100;
        pbe2.UseStandardPrice= false;
        pbe2.IsActive = true;
        pbe2.D1__c = 0.1;
    pbe2.D3__c = 0.2;
    pbe2.D2__c = 0.3;
    
   pbe2.M1__c = 0.1;
    pbe2.M2__c = 0.2;
    pbe2.M3__c = 0.3;
    pbe2.M4__c = 0.4;
    pbe2.Rounding_Off_Digits__c = '10';
        pbe2.Base_Price__c = 100;
        pbe2.Discount_Level_3__c = 12;
        pbe2.Pricing_Type__c = 1;
        pbe2.Quantity__c = 1;
        insert pbe2;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Product__c = pro2.id;
        //qlo.Description__c = 'sfsd';
        qlo.Discount__c = 1;
        qlo.quantity__c = 2;
        qlo.Discount_Description__c = 'adas';
        qlo.Mould_Cavity__c = 2;
        qlo.description__c = 'sfsdfds';
        qlo.Manual_Product_Name__c = 'name dummy';
        qlo.Discount_Type__c = 'Value';
        qlo.Select_Option__c = true;
        qlo.Manual_Option_Base_Price__c = 12003;
        qlo.Manula_Option_List_Price__c  = 12300;
        
        insert qlo;
        
        qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Product__c = pro2.id;
        qlo.Description__c = 'sfsd';
        qlo.Discount_in_Value__c = 1;
        qlo.quantity__c = 2;
        qlo.Discount_Description__c = 'adas';
        qlo.Mould_Cavity__c = 2;
        //qlo.description__c = 'sfsdfds';
        qlo.Manual_Product_Name__c = 'name dummy';
        qlo.Discount_Type__c = 'Value';
        qlo.Select_Option__c = false;
        qlo.Manual_Option_Base_Price__c = 12003;
        qlo.Manula_Option_List_Price__c  = 12300;
        
        
        insert qlo;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(qt);
        ReviseQuoteController ctrl = new ReviseQuoteController(sc);
        PageReference pageRef = Page.ReviseQuote; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        
        
        List<Opportunity> opLst = new List<Opportunity>();
        opLst.add(op);
        ctrl.ReviseQuotation();
        ctrl.CloseModal();
        test.stopTest();
    }
    
 /*   public static testMethod void unitTest2(){
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
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        pro.IsActive = true;
        pro.Description = 'sfas';
        pro.Family = 'Options';
        insert pro;
        
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

        
        quote qt = new quote();
        qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        qt.Application__c = 'EDIBLE OIL';
        qt.Zero_Cooling__c = 'Yes';
        qt.Fax = '1234562';
        qt.Ship_To_City__c = 'mrt';
        qt.Ship_To_State__c = 'up';
        qt.Ship_To_Country__c = 'india';
        qt.Description = 'asd';
        qt.ShippingHandling = 123;
        qt.Phone = '7898562485';
        qt.ACCOUNT_TYPE__c = 'GLOBAL';
        qt.Tax = 12;
        qt.MFG_AT__c = 'INDIA';
        qt.Shipping_And_Handling__c  =32;
        qt.QU_REVISION_NUMBER__c = '001';
        qt.Use_Current_Price__c =true;
        qt.Exchange_Rate__c = 2;
        qt.Discount__c = 12;
        insert qt;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Application__c = 'EDIBLE OIL';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        qli.Level_Of_Ceiling__c = '1000';
        qli.MFG_AT__c = 'INDIA';
        qli.Mach_Mold_No__c = 'wqwet';
        qli.Zero_Cooling_2__c = 'Yes';
        qli.Cavity__c = 2;
        qli.Product_Type__c = 'MC';
        qli.Advance_Percentage__c = 30;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
        qli.Product__c =pro.id;
        insert qli;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Product__c = pro.id;
        qlo.Description__c = 'sfsd';
        qlo.Discount__c = 1;
        qlo.quantity__c = 2;
        qlo.Discount_Description__c = 'adas';
        qlo.Mould_Cavity__c = 2;
        qlo.description__c = 'sfsdfds';
        qlo.Manual_Product_Name__c = 'name dummy';
        insert qlo;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(qt);
        ReviseQuoteController ctrl = new ReviseQuoteController(sc);
        PageReference pageRef = Page.ReviseQuote; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        
        
        List<Opportunity> opLst = new List<Opportunity>();
        opLst.add(op);
        ctrl.ReviseQuotation();
        test.stopTest();
        
    }
    
    public static testMethod void unitTest3(){
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
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        pro.IsActive = true;
        pro.Description = 'sfas';
        pro.Family = 'Options';
        insert pro;
        
        
        quote qt = new quote();
        qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        qt.Application__c = 'EDIBLE OIL';
        qt.Zero_Cooling__c = 'Yes';
        qt.Fax = '1234562';
        qt.Ship_To_City__c = 'mrt';
        qt.Ship_To_State__c = 'up';
        qt.Ship_To_Country__c = 'india';
        qt.Description = 'asd';
        qt.ShippingHandling = 123;
        qt.Phone = '7898562485';
        qt.ACCOUNT_TYPE__c = 'GLOBAL';
        qt.Tax = 12;
        qt.MFG_AT__c = 'INDIA';
        qt.Shipping_And_Handling__c  =32;
        qt.QU_REVISION_NUMBER__c = '001';
        qt.Exchange_Rate__c = 2;
        qt.Discount__c = 12;
        insert qt;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Application__c = 'EDIBLE OIL';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = false;
        qli.Level_Of_Ceiling__c = '1000';
        qli.MFG_AT__c = 'INDIA';
        qli.Mach_Mold_No__c = 'wqwet';
        qli.Zero_Cooling_2__c = 'Yes';
        qli.Cavity__c = 2;
        qli.Product_Type__c = 'MC';
        qli.Advance_Percentage__c = 30;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
        qli.Product__c =pro.id;
        insert qli;
        
         Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Product__c = pro.id;
        qlo.Description__c = 'sfsd';
        qlo.Discount__c = 1;
        qlo.quantity__c = 2;
        qlo.Discount_Description__c = 'adas';
        qlo.Mould_Cavity__c = 2;
        qlo.description__c = 'sfsdfds';
        qlo.Manual_Product_Name__c = 'name dummy';
        qlo.Select_Option__c = true;
        qlo.Manula_Option_List_Price__c=20;
        qlo.Price_Type__c=1;
        qlo.Manual_Option_Base_Price__c=20;
        qlo.Manual_Option__c='Test';
        
        insert qlo;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(qt);
        ReviseQuoteController ctrl = new ReviseQuoteController(sc);
        PageReference pageRef = Page.ReviseQuote; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        
        
        List<Opportunity> opLst = new List<Opportunity>();
        opLst.add(op);
        ctrl.ReviseQuotation();
        test.stopTest();
    }
   */ 
    
}