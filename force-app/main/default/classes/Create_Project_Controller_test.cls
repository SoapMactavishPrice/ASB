@isTest
public class Create_Project_Controller_test {
    public static testMethod void testMethod1(){
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
        us.Subsidiari__c = sub.Id;
        us.User__c = userInfo.getUserId();
        us.Country__c = c1.id;
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
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.CurrencyIsoCode = 'INR';
        insert op;
        
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
        qt.Exchange_Rate__c = 1;
        insert qt;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
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
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.FY__c = 's';
        cont.SUBSIDARY__c = 'AI';
        cont.date__C = system.today();
        cont.INCO_TERMS__c = 'EXW';
        cont.ExpirationDate__c = system.today() - 30;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = f.id;
        cont.Contract_Locked_for_Approval__c = true;
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.Project_Created__c =false;
        conLI.Zero_Cooling__c = 'Yes';
        conLI.MFG_Location__c = 'INDIA';
        conLI.L_C__c = 'Yes';
        conLI.APPLICATION__c = 'EOL - Edible oil/Soy sauce';
        conLI.CLASS__c = 'STD PRODUCT';
        conLI.Description__c = 'dasdk';
        conLI.Drawing_No__c = 'qweqwe';
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.List_Price__c = 100;
        conLI.Quantity__c = 10;
        conLI.Level_Of_Ceiling__c = '1000';   
        conLI.Grand_Total_before_TCS__c = 1000;
        insert conLI;
        
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        insert conLO;
        
        ProjectManagement__c pm =  new ProjectManagement__c();
        pm.Contract__c = cont.id;
        pm.Phase__c = 'Under Manufacturing';
        //pm.Machinen_No__c = 'M1';
        pm.Contract_Line_Item__c = conLI.id;
        Insert pm;
        
        Test.StartTest(); 
        ApexPages.CurrentPage().getparameters().put('id',cont.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(cont);
        Create_Project_Controller test1 = new Create_Project_Controller(sc);
        test1.show = true;
        PageReference pageRef = Page.CreateProject; // Add your VF page Name here
       // pageRef.getParameters().put('id', String.valueOf(cont.Id));
        Test.setCurrentPage(pageRef);
        test1.strSelected = conLI.id;
        test1.ProjectCreation();
        Test.StopTest(); 
    }
     public static testMethod void testMethod2(){
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
        us.Subsidiari__c = sub.Id;
        us.User__c = userInfo.getUserId();
        us.Country__c = c1.id;
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
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.CurrencyIsoCode = 'INR';
        insert op;
        
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
        qt.Exchange_Rate__c = 1;
        insert qt;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
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
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.FY__c = 's';
        cont.SUBSIDARY__c = 'AI';
        cont.date__C = system.today();
        cont.INCO_TERMS__c = 'EXW';
        cont.ExpirationDate__c = system.today() + 30;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = f.id;
        cont.Contract_Locked_for_Approval__c = true;
        cont.PO_Number__c = '123';
        cont.PO_Date__c = system.today();
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.Project_Created__c =false;
        conLI.Zero_Cooling__c = 'Yes';
        conLI.MFG_Location__c = 'INDIA';
        conLI.L_C__c = 'Yes';
        conLI.APPLICATION__c = 'EOL - Edible oil/Soy sauce';
        conLI.CLASS__c = 'STD PRODUCT';
        conLI.Description__c = 'dasdk';
        conLI.Drawing_No__c = 'qweqwe';
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.List_Price__c = 100;
        conLI.Quantity__c = 10;
        conLI.Level_Of_Ceiling__c = '1000';   
        conLI.Grand_Total_before_TCS__c = 1000;
        insert conLI;
        
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        insert conLO;
        
        ProjectManagement__c pm =  new ProjectManagement__c();
        pm.Contract__c = cont.id;
        pm.Phase__c = 'Under Manufacturing';
        //pm.Machinen_No__c = 'M1';
        pm.Contract_Line_Item__c = conLI.id;
        Insert pm;
         
        
        Test.StartTest(); 
        ApexPages.CurrentPage().getparameters().put('id',cont.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(cont);
        Create_Project_Controller test1 = new Create_Project_Controller(sc);
        test1.show = true;
        PageReference pageRef = Page.CreateProject; // Add your VF page Name here
        //pageRef.getParameters().put('id', String.valueOf(cont.Id));
        Test.setCurrentPage(pageRef);
        test1.strSelected = conLI.id;
        test1.ProjectCreation();
        Test.StopTest(); 
         
        
    }
}