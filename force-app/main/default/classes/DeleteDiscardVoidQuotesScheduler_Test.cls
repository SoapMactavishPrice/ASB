@isTest
public class DeleteDiscardVoidQuotesScheduler_Test {
    
    @isTest
    static void setupData() {
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
        qt.Status = 'DISCARD/VOID';
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
        
        Test.startTest();

        DeleteDiscardVoidQuotesScheduler scheduler = new DeleteDiscardVoidQuotesScheduler();
        String jobId = System.schedule('Test DeleteDiscardVoidQuotesScheduler', 
                                       '0 0 0 1 1 ? 2050', 
                                       scheduler);
        // Run the scheduled job
        
        Test.stopTest();

    }
    

   

}