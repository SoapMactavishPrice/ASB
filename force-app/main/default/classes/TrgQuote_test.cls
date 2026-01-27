@isTest
public class TrgQuote_test {
    
    public static testMethod void TrgQuoteTestMethod1(){
        
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id, 
                         Level__c='L1'); 
        
        insert uu;
        
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'A12';
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
        insert sub;
        
        Country_List__c cl = new Country_List__c();
        cl.Name = 'India';
        cl.Country_Code__c = '+91';
        cl.Subsidiary__c = sub.Id;
        insert cl;
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = cl.Id;
        insert us;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = 'A44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
        
        Account acc = new Account();
        acc.CurrencyIsoCode = 'INR';
        acc.Name = 'VJ';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '2501';
        //acc.Subsidiary__c = sub.id;
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        lead ld= new lead(lastName='Test User', Status='New', Company='Test Company');
        insert ld;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.IsActive = true;
        insert pb;
        
        Opportunity op = new Opportunity();
        op.CurrencyIsoCode = 'INR';
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.Pricebook2Id = pb.id;
        op.Subsidiary__c = sub.id;
        insert op;
        
        QuoteRecursionCheck.isfirsttime=true;  
        
        quote qt = new quote();
        qt.CurrencyIsoCode = 'INR';
        qt.Status = 'Draft';
        qt.Name = 'qt test';
        qt.Exchange_Rate__c = 1;
        qt.OpportunityId = op.id;
        qt.Language__c = 'EN';
        qt.Discount__c = 3;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Sync_Quote__c = false;
        insert qt;
        
        
        String rec = String.valueOf(qt.id);
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        insert pro;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = pro.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 10000;
        pbe.UseStandardPrice= false;
        pbe.IsActive = true;
        pbe.Base_Price__c = 123;
        pbe.Discount_Level_3__c = 12;
        pbe.Pricing_Type__c = 1;
        pbe.D1__c = 0.1;
        pbe.D3__c = 0.2;
        pbe.D2__c = 0.3;
        
        pbe.M1__c = 0.1;
        pbe.M2__c = 0.2;
        pbe.M3__c = 0.3;
        pbe.M4__c = 0.4;
        pbe.Rounding_Off_Digits__c = '10';
        pbe.Quantity__c = 1;
        insert pbe;
        QuoteRecursionCheck.isfirsttime=true;
        System.runas(uu) {
            Test.startTest();
            
            Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
            qli.Quote__c = qt.id;
            qli.Discount__c = 2;
            qli.Product__c = pro.Id;
            qli.Quantity__c = 1;
            qli.Discount_Approval_Note__c = 'sfasf';
            qli.Scope_of_mould__c = 'ML';
            qli.List_Price__c = 12;
            qli.Discount_Allowed_New__c = 10;
            qli.Discount__c = 11;
            qli.Discount_Type__c = 'Percent';
            qli.Discount_Allowed_New__c = 10;
            qli.Discount__c = 11;
            qli.P_D1__c = 10;
            qli.P_D2__c = 20;
            qli.P_D3__c = 30;
            insert qli;
            qt.Discount__c = 2;
            update qt;
            
            qt.Discount__c = 20;
            update qt;
            
            update qli;
            
            update qt;
            
            Quote_Line_Options__c qlo = new Quote_Line_Options__c();
            qlo.Quote__c = qt.id;
            qlo.Quote_Line_Item_Custom__c = qli.id;
            qlo.Price_Type__c = 1;
            qlo.Quantity__c = 1;
            qlo.Manula_Option_List_Price__c=12;
            qlo.Discount__c = 2;
            qlo.Discount_Type__c = 'Percent';
            insert qlo;
            
            qt.Approval_Status__c = 'Approved';
            update qt;
            
            qt.Skip_Status_Validation__c = true;
            qt.Approval_Status_From_HOD__c = 'Submitted For Approval';
            update qt;
            qt.Approval_Status_From_HOD__c = 'Approved';
            update qt;
            System.debug('Discount_Allowed__c==>'+qlo.Discount_Allowed__c);
            QuoteRecursionCheck.isfirsttime=true;
            System.debug('Test 001');
            qt.Status = 'RELEASED';
            
            qt.Sync_Quote__c = false;
            try{
                update qt;
            }Catch(Exception e){}
            System.debug('Discount_Allowed__c==>'+qlo.Discount_Allowed__c);
            
            System.debug('Discount_Allowed__c==>'+qlo.Discount_Allowed__c);
            QuoteRecursionCheck.isfirsttime=true;
             
           
            
           // qt.Status = 'CLOSE - SC CREATED';
           // update qt;
            
            Contract cObject = new Contract(AccountId = acc.Id   ,Status__c = 'CREATED', Quote__c = qt.Id,
                                       Country_Text__c = 'Test1',State_Text__c = 'abc',City_Text__c = 'efg',COUNTRY_CODE__c = 'AD',Revision__c = 'Test',
            Numeric_Revision__c = 10,Insurance_Amount__c = 24,Freight_Amount1__c = 12, Subsidiary__c = sub.id, FY1__c = fym.id );
            
            insert cObject;
            
            
        //insert cObject;
            Test.stopTest(); 
        }
    }
    
    
    public static testMethod void TrgQuoteTestMethod2(){
        
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id, 
                         Level__c='L2');
        
        insert uu;
        
        
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'A12';
        sub.Name__c = 'xyg';
        sub.Active__c = true;
        sub.Office__c = 'Airforce';
        sub.Rounding_Off_Digits__c = '10000';
        sub.Permitted_Currency__c = 'INR';
        sub.Permitted_Language__c = 'EN';
        sub.Discount_Level_1__c = 5;
        sub.Discount_Level_2__c = 10;
        sub.Discount_Level_3__c = 15;
        sub.Quote_Approval__c ='Quote Level';
        insert sub;
        
        Country_List__c cl = new Country_List__c();
        cl.Name = 'India';
        cl.Country_Code__c = '+91';
        cl.Subsidiary__c = sub.Id;
        insert cl;
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = cl.Id;
        insert us;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = 'A44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
        
        Account acc = new Account();
        acc.CurrencyIsoCode = 'INR';
        acc.Name = 'VJ';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '2501';
        //acc.Subsidiary__c = sub.id;
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        lead ld= new lead(lastName='Test User', Status='New', Company='Test Company');
        insert ld;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.IsActive = true;
        insert pb;
        
        Opportunity op = new Opportunity();
        op.CurrencyIsoCode = 'INR';
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.Pricebook2Id = pb.id;
        op.Subsidiary__c = sub.id;
        insert op;
        
        QuoteRecursionCheck.isfirsttime=true;  
        
        quote qt = new quote();
        qt.CurrencyIsoCode = 'INR';
        qt.Status = 'Draft';
        qt.Name = 'qt test';
        qt.Exchange_Rate__c = 1;
        qt.OpportunityId = op.id;
        qt.Language__c = 'EN';
        qt.Discount__c = 3;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Sync_Quote__c = false;
        insert qt;
        
        
        String rec = String.valueOf(qt.id);
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        insert pro;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = pro.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 10000;
        pbe.UseStandardPrice= false;
        pbe.IsActive = true;
        pbe.Base_Price__c = 123;
        pbe.Discount_Level_3__c = 12;
        pbe.Pricing_Type__c = 1;
        pbe.D1__c = 0.1;
        pbe.D3__c = 0.2;
        pbe.D2__c = 0.3;
        
        pbe.M1__c = 0.1;
        pbe.M2__c = 0.2;
        pbe.M3__c = 0.3;
        pbe.M4__c = 0.4;
        pbe.Rounding_Off_Digits__c = '10';
        pbe.Quantity__c = 1;
        insert pbe;
        QuoteRecursionCheck.isfirsttime=true;
        System.runas(uu) {
            Test.startTest();
            
            Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
            qli.Quote__c = qt.id;
            qli.Discount__c = 2;
            qli.Product__c = pro.Id;
            qli.Quantity__c = 1;
            qli.Discount_Approval_Note__c = 'sfasf';
            qli.Scope_of_mould__c = 'ML';
            qli.List_Price__c = 12;
            qli.Discount_Allowed_New__c = 10;
            qli.Approved_Discount__c = 21;
            qli.Discount__c = 11;
            qli.P_D1__c = 10;
            qli.P_D2__c = 20;
            qli.P_D3__c = 30;
            qli.Discount_Type__c = 'Percent';
            insert qli;
            qt.Discount__c = 2;
            update qt;
            
            
            qli.Discount__c = 23;
            qli.Discount_Type__c = 'Percent';
            update qli;
            
            qt.Discount__c = 13;
            update qt;
            
            Quote_Line_Options__c qlo = new Quote_Line_Options__c();
            qlo.Quote__c = qt.id;
            qlo.Quote_Line_Item_Custom__c = qli.id;
            qlo.Price_Type__c = 1;
            qlo.Quantity__c = 1;
            qlo.Manula_Option_List_Price__c=12;
            qlo.Discount__c = 12;
            qlo.Discount_Type__c = 'Percent';
            insert qlo;
            System.debug('Discount_Allowed__c==>'+qlo.Discount_Allowed__c);
            QuoteRecursionCheck.isfirsttime=true;
            System.debug('Test 001');
            qt.Status = 'RELEASED';
            qt.Sync_Quote__c = false;
            try{
                update qt;
            }Catch(Exception e){}
            System.debug('Discount_Allowed__c==>'+qlo.Discount_Allowed__c);
            
            
            System.debug('Discount_Allowed__c==>'+qlo.Discount_Allowed__c);
            QuoteRecursionCheck.isfirsttime=true;
           
            Test.stopTest(); 
        }
    }
    
    public static testMethod void TrgQuoteTestMethod3(){
        
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu1=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id, 
                         Level__c='L1');
        
        
        
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'A12';
        sub.Name__c = 'xyg';
        sub.Active__c = true;
        sub.Office__c = 'Airforce';
        sub.Rounding_Off_Digits__c = '10000';
        sub.Permitted_Currency__c = 'INR';
        sub.Permitted_Language__c = 'EN';
        sub.Discount_Level_1__c = 5;
        sub.Discount_Level_2__c = 10;
        sub.Discount_Level_3__c = 15;
        sub.Quote_Approval__c ='Quote Level';
        insert sub;
        
        Country_List__c cl = new Country_List__c();
        cl.Name = 'India';
        cl.Country_Code__c = '+91';
        cl.Subsidiary__c = sub.Id;
        insert cl;
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = cl.Id;
        insert us;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = 'A44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
        
        Account acc = new Account();
        acc.CurrencyIsoCode = 'INR';
        acc.Name = 'VJ';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '2501';
        //acc.Subsidiary__c = sub.id;
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        lead ld= new lead(lastName='Test User', Status='New', Company='Test Company');
        insert ld;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.IsActive = true;
        insert pb;
        
        Opportunity op = new Opportunity();
        op.CurrencyIsoCode = 'INR';
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.Pricebook2Id = pb.id;
        op.Subsidiary__c = sub.id;
        insert op;
        
        QuoteRecursionCheck.isfirsttime=true;  
        
        quote qt = new quote();
        qt.CurrencyIsoCode = 'INR';
        qt.Status = 'Draft';
        qt.Name = 'qt test';
        qt.Exchange_Rate__c = 1;
        qt.OpportunityId = op.id;
        qt.Language__c = 'EN';
        qt.Discount__c = 3;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Sync_Quote__c = false;
        insert qt;
        
        
        String rec = String.valueOf(qt.id);
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        insert pro;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = pro.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 10000;
        pbe.UseStandardPrice= false;
        pbe.IsActive = true;
        pbe.Base_Price__c = 123;
        pbe.Discount_Level_3__c = 12;
        pbe.Pricing_Type__c = 1;
        pbe.D1__c = 0.1;
        pbe.D3__c = 0.2;
        pbe.D2__c = 0.3;
        
        pbe.M1__c = 0.1;
        pbe.M2__c = 0.2;
        pbe.M3__c = 0.3;
        pbe.M4__c = 0.4;
        pbe.Rounding_Off_Digits__c = '10';
        pbe.Quantity__c = 1;
        insert pbe;
        QuoteRecursionCheck.isfirsttime=true;
        System.runas(uu1) {
            Test.startTest();
            
            Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
            qli.Quote__c = qt.id;
            qli.Discount__c = 2;
            qli.Product__c = pro.Id;
            qli.Quantity__c = 1;
            qli.Discount_Approval_Note__c = 'sfasf';
            qli.Scope_of_mould__c = 'ML';
            qli.List_Price__c = 12;
            qli.Discount_Allowed_New__c = 10;
            qli.Discount__c = 11;
            qli.P_D1__c = 10;
            qli.P_D2__c = 20;
            qli.P_D3__c = 30;
            qli.Discount_Type__c = 'Percent';
            insert qli;
            qt.Discount__c = 2;
            update qt;
            
            
            qli.Discount__c = 23;
            qli.Discount_Type__c = 'Percent';
            update qli;
            
            qt.Discount__c = 13;
            update qt;
            
            Quote_Line_Options__c qlo = new Quote_Line_Options__c();
            qlo.Quote__c = qt.id;
            qlo.Quote_Line_Item_Custom__c = qli.id;
            qlo.Price_Type__c = 1;
            qlo.Quantity__c = 1;
            qlo.Manula_Option_List_Price__c=12;
            qlo.Discount__c = 12;
            qlo.Discount_Type__c = 'Percent';
            insert qlo;
            System.debug('Discount_Allowed__c==>'+qlo.Discount_Allowed__c);
            QuoteRecursionCheck.isfirsttime=true;
            System.debug('Test 001');
            qt.Status = 'RELEASED';
            qt.Sync_Quote__c = false;
            try{
                update qt;
            }Catch(Exception e){}
            System.debug('Discount_Allowed__c==>'+qlo.Discount_Allowed__c);
            
            
            
            System.debug('Discount_Allowed__c==>'+qlo.Discount_Allowed__c);
            QuoteRecursionCheck.isfirsttime=true;
           
            Test.stopTest(); 
        }
    }
    
}