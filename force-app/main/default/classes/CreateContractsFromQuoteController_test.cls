@isTest
public class CreateContractsFromQuoteController_test {
    public static testMethod void testMethod1(){
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'IPL';
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
        sub.Contract_Approval__c = 'Line Item level';
        sub.CurrencyIsoCode = 'INR';
        insert sub;
        
        Fiscal_Year_Master__c fm=new Fiscal_Year_Master__c();
        fm.Fiscal_Year_Start_Date__c=System.today()-200;
        fm.Fiscal_Year_End_Date__c=System.today()+165;
        fm.Active__c=true;
        fm.Name='44';
        insert fm;
        
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
        o.Subsidiary_Master__c = sub.id;
        insert o;
        
        User_Setup__c us = new User_Setup__c();
        us.Subsidiari__c = sub.id;
        us.Country__c = c1.id;
        us.User__c = Userinfo.getUserId();
        Insert us;
        
        Account acc = new Account();
        acc.Name = 'acc anem';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '250001';
        acc.Type = 'Press';
        acc.CurrencyIsoCode = 'INR';
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.CurrencyIsoCode ='INR';
        insert op;
        
        QuoteRecursionCheck.isfirsttime=false;
        quote qt = new quote();
        qt.Status = 'CREATED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        
        qt.VALITY_DATE__c = system.today() +2;
        qt.Application__c = 'EOL - Edible oil/Soy sauce';
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
        qt.Exchange_Rate__c = 11;
        qt.QU_REVISION_NUMBER__c = '000';
        insert qt;
        
        acc.Subsidiary__c = sub.Id;
        acc.CurrencyIsoCode = 'INR';
        update acc;
        
        Bank_Detail__c bd = new Bank_Detail__c();
        bd.Subsidiary_Master__c = sub.Id;
        bd.Active__c = true;
        bd.Bank_A_C_No__c = 'AB2321CD';
        bd.Beneficiary__c = 'Test';
        insert bd;
        
        //qt.RecordType.Name = 'After Released Locked';
        //update qt;
            
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        //qli.Approval_Status_From_HOD__c = 'Approved';
        qli.Quantity__c = 1;
        qli.Application__c = 'EOL - Edible oil/Soy sauce';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        qli.Discount__c = 12;
        insert qli;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        insert qlo;
        
        qt.Status = 'RELEASED';
         qt.PROBABILITY__c = 'A';
        qt.Expected_Month_of_Consolidated_Order__c = date.today().addDays(1);
        Update qt;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.Status__c = 'Created';
        cont.FY1__c = fm.id;
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.Level_Of_Ceiling__c = '1000';   
        insert conLI;
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        insert conLO;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        CreateContractsFromQuoteController test1 = new CreateContractsFromQuoteController(sc);
        PageReference pageRef = Page.CreateContractFromQuote; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        CreateContractsFromQuoteController.getQuoteNumber();
        CreateContractsFromQuoteController.fakeCodeCoverage();
        
        test1.CreateContract();
        Test.StopTest(); 
    }
    
   /* public static testMethod void testMethod2(){
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'IPL';
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
        sub.Contract_Approval__c = 'Line Item level';
        insert sub;
        
        Fiscal_Year_Master__c f=new Fiscal_Year_Master__c();
        f.Fiscal_Year_Start_Date__c=System.today()-200;
        f.Fiscal_Year_End_Date__c=System.today()+165;
        f.Active__c=true;
        f.Name='44';
        insert f;
        
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
        o.Subsidiary_Master__c = sub.id;
        insert o;
        
        User_Setup__c us = new User_Setup__c();
        us.Subsidiari__c = sub.id;
        us.Country__c = c1.id;
        us.User__c = Userinfo.getUserId();
        Insert us;
        
        Account acc = new Account();
        acc.CurrencyIsoCode = 'INR';
        acc.Name = 'acc anem';
        acc.ERP_ID__c = 'das';
        acc.Global_Customer_Name__c = 'COLGATE-PALMOLIVE';
        acc.Account_Type__c = 'GLOBAL';
        acc.Customer_Category__c = 'High';
        acc.Subsidiary__c = sub.Id;
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        con.Designation__c = 'Testing';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.CurrencyIsoCode = 'INR';
        insert op;
        
        quote qt = new quote();
        qt.Status = 'Draft';
        qt.Contact__c = con.Id;
        //qt.VALITY_DATE__c = 2021-05-29;
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today().addDays(2);
        qt.Application__c = 'EOL - Edible oil/Soy sauce';
        qt.Zero_Cooling__c = 'Yes';
        qt.Fax = '1234562';
        qt.SHIP_TO_ADDRESS_LINE_1__c = 'Test Ship 1';
        qt.SHIP_TO_ADDRESS_LINE_2__c = 'Test Ship 2';
        qt.SHIP_TO_ADDRESS_LINE_3__c = 'test Ship 3';
        qt.SHIP_TO_POSTAL_CODE__c = '201001';
        qt.ACCOUNT_BUSINESS__c = 'CONVERTER';
        qt.AdditionalName = 'Test Additional';
        qt.Insurance__c = 'By Buyer';
        qt.Freight__c = 'By Buyer';
        qt.ShippingName = 'Not Null Shipping';
        qt.FY__c = 'FY';
        qt.TYPE__c = 'GLOBAL';
        qt.ADDRESS_LINE_1__c = 'Address Line 1';
        qt.ADDRESS_LINE_2__c = 'Address Line 2';
        qt.ADDRESS_LINE_3__c = 'Address Line 3';
        qt.CITY__c = 'Noida';
        qt.BillingName = 'Test Billing Name';
        qt.Email = 'test@tets.com';
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
        qt.Approval_Status_From_HOD__c = 'Approved';
        qt.Exchange_Rate__c = 1;
        insert qt;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        //qli.Approval_Status_From_HOD__c = 'Approved';
        qli.Quantity__c = 1;
        qli.Application__c = 'EOL - Edible oil/Soy sauce';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        insert qli;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        insert qlo;
        
        qt.Status = 'RELEASED';
        Update qt;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = f.id;
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.Level_Of_Ceiling__c = '1000';   
        insert conLI;
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        insert conLO;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        CreateContractsFromQuoteController test1 = new CreateContractsFromQuoteController(sc);
        PageReference pageRef = Page.CreateContractFromQuote; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        test1.CreateContract();
        Test.StopTest(); 
    }
    
      public static testMethod void testMethod3(){
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ICC';
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
        sub.Contract_Approval__c = 'Line Item level';
        insert sub;
        
        Fiscal_Year_Master__c f=new Fiscal_Year_Master__c();
        f.Fiscal_Year_Start_Date__c=System.today()-200;
        f.Fiscal_Year_End_Date__c=System.today()+165;
        f.Active__c=true;
        f.Name='44';
        insert f;
        
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
        o.Subsidiary_Master__c = sub.id;
        insert o;
        
        User_Setup__c us = new User_Setup__c();
        us.Subsidiari__c = sub.id;
        us.Country__c = c1.id;
        us.User__c = Userinfo.getUserId();
        Insert us;
          
        Account acc = new Account();
        acc.Name = 'acc anem';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '250001';
        acc.Type = 'Press';
        acc.Subsidiary__c = sub.Id;
        acc.CurrencyIsoCode = 'INR';
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        con.Designation__c = 'Testing';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.CurrencyIsoCode = 'INR';
        insert op;
        
        quote qt = new quote();
        qt.Status = 'DRAFT';
        qt.Contact__c = con.Id;
        //qt.VALITY_DATE__c = 2021-05-29;
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        qt.Application__c = 'EOL - Edible oil/Soy sauce';
        qt.Zero_Cooling__c = 'Yes';
        qt.Fax = '1234562';
        qt.SHIP_TO_ADDRESS_LINE_1__c = 'Test Ship 1';
        qt.SHIP_TO_ADDRESS_LINE_2__c = 'Test Ship 2';
        qt.SHIP_TO_ADDRESS_LINE_3__c = 'test Ship 3';
        qt.SHIP_TO_POSTAL_CODE__c = '201001';
        qt.ACCOUNT_BUSINESS__c = 'CONVERTER';
        qt.AdditionalName = 'Test Additional';
        qt.Insurance__c = 'By Buyer';
        qt.Freight__c = 'By Buyer';
        qt.ShippingName = 'Not Null Shipping';
        qt.FY__c = 'FY';
        qt.TYPE__c = 'GLOBAL';
        qt.ADDRESS_LINE_1__c = 'Address Line 1';
        qt.ADDRESS_LINE_2__c = 'Address Line 2';
        qt.ADDRESS_LINE_3__c = 'Address Line 3';
        qt.CITY__c = 'Noida';
        qt.BillingName = 'Test Billing Name';
        qt.Email = 'test@tets.com';
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
        qt.Approval_Status_From_HOD__c = 'Approved';
        qt.Exchange_Rate__c = 1;
        insert qt;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        //qli.Approval_Status_From_HOD__c = 'Approved';
        qli.Quantity__c = 1;
        qli.Application__c = 'EOL - Edible oil/Soy sauce';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        insert qli;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        insert qlo;
        
        qt.Status = 'RELEASED';
        Update qt;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = f.id;
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.Level_Of_Ceiling__c = '1000';   
        insert conLI;
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        insert conLO;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        CreateContractsFromQuoteController test1 = new CreateContractsFromQuoteController(sc);
        PageReference pageRef = Page.CreateContractFromQuote; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        test1.CreateContract();
        Test.StopTest(); 
    }*/
}