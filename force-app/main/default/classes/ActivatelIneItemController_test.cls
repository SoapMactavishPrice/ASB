@isTest
public class ActivatelIneItemController_test {
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
        
        
        
        Country_List__c cl = new Country_List__c();
        cl.Name = 'India';
        CL.Short_Name__c = 'IN';
        cl.Country_Code__c = '+91';
        cl.Subsidiary__c = sub.Id;
        insert cl;
        
        Region__c r = new Region__c();
        r.Name = 'SOUTH';
        r.Name__c = 'SOUTH';
        r.Active__c = true;
        r.Country__c = CL.id;
        Insert r;
        
        State_List__c SL = new State_List__c();
        SL.Country__c = CL.id;
        SL.Name = 'GOA';
        SL.Region__c = r.id;
        insert SL;
        
        City_List__c CiL = new City_List__c();
        CiL.State__c = SL.id;
        CiL.Name='Goa';
        cil.Subsidiary_Master__c = sub.Id;
        insert CiL;
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = cl.Id;
        insert us;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = '44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
        
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
        insert op;
        
        quote qt = new quote();
        qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        insert qt;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
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
        ApexPages.StandardController sc = new ApexPages.StandardController(conLI);
        ActivatelIneItemController test1 = new ActivatelIneItemController(sc);
        PageReference pageRef = Page.ActivateLineItem; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(conLI.Id));
        Test.setCurrentPage(pageRef);
        test1.LineItemCancel();
        Test.StopTest(); 
    }
    
  /*   public static testMethod void testMethod2(){
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ABC12';
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
        
        
        
        Country_List__c cl = new Country_List__c();
        cl.Name = 'India';
        CL.Short_Name__c = 'IN';
        cl.Country_Code__c = '+91';
        cl.Subsidiary__c = sub.Id;
        insert cl;
        
        Region__c r = new Region__c();
        r.Name = 'SOUTH';
        r.Name__c = 'SOUTH';
        r.Active__c = true;
        r.Country__c = CL.id;
        Insert r;
        
        State_List__c SL = new State_List__c();
        SL.Country__c = CL.id;
        SL.Name = 'GOA';
        SL.Region__c = r.id;
        insert SL;
        
        City_List__c CiL = new City_List__c();
        CiL.State__c = SL.id;
        CiL.Name='Goa';
        insert CiL;
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = cl.Id;
        insert us;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = '44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
        
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
        insert op;
        
        quote qt = new quote();
        qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        insert qt;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
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
        ApexPages.StandardController sc = new ApexPages.StandardController(conLO);
        ActivateOptionController test1 = new ActivateOptionController(sc);
        PageReference pageRef = Page.ActivateOption; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(conLO.Id));
        Test.setCurrentPage(pageRef);
        test1.ActivateOption();
        Test.StopTest(); 
    }
    
    public static testMethod void testMethod3(){
        
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ABC12';
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
        
        
        
        Country_List__c cl = new Country_List__c();
        cl.Name = 'India';
        CL.Short_Name__c = 'IN';
        cl.Country_Code__c = '+91';
        cl.Subsidiary__c = sub.Id;
        insert cl;
        
        Region__c r = new Region__c();
        r.Name = 'SOUTH';
        r.Name__c = 'SOUTH';
        r.Active__c = true;
        r.Country__c = CL.id;
        Insert r;
        
        State_List__c SL = new State_List__c();
        SL.Country__c = CL.id;
        SL.Name = 'GOA';
        SL.Region__c = r.id;
        insert SL;
        
        City_List__c CiL = new City_List__c();
        CiL.State__c = SL.id;
        CiL.Name='Goa';
        insert CiL;
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = cl.Id;
        insert us;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = '44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
        
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
        insert op;
        
        quote qt = new quote();
        qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        insert qt;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.Cancellation_Reason__c = 'sasdas';
        conLI.Level_Of_Ceiling__c = '1000';   
        insert conLI;
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        insert conLO;
        
         Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(conLI);
        CancelIneItemController test1 = new CancelIneItemController(sc);
        PageReference pageRef = Page.CancelLineItem; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(conLI.Id));
        Test.setCurrentPage(pageRef);
        test1.LineItemCancel();
        Test.StopTest(); 
    }
    
    public static testMethod void testMethod4(){
        
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ABC12';
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
        
        
        Country_List__c cl = new Country_List__c();
        cl.Name = 'India';
        CL.Short_Name__c = 'IN';
        cl.Country_Code__c = '+91';
        cl.Subsidiary__c = sub.Id;
        insert cl;
        
        Region__c r = new Region__c();
        r.Name = 'SOUTH';
        r.Name__c = 'SOUTH';
        r.Active__c = true;
        r.Country__c = CL.id;
        Insert r;
        
        State_List__c SL = new State_List__c();
        SL.Country__c = CL.id;
        SL.Name = 'GOA';
        SL.Region__c = r.id;
        insert SL;
        
        City_List__c CiL = new City_List__c();
        CiL.State__c = SL.id;
        CiL.Name='Goa';
        insert CiL;
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = cl.Id;
        insert us;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = '44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
        
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
        insert op;
        
        quote qt = new quote();
        qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        insert qt;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.Cancellation_Reason__c = 'sasdas';
        conLI.Level_Of_Ceiling__c = '1000';   
        insert conLI;
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        insert conLO;
        
         Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(conLO);
        CancelOptionController test1 = new CancelOptionController(sc);
        test1.ObjContract = cont;
        List<Contract_Line_Item__c> conLst = new List<Contract_Line_Item__c>();
        conLst.add(conLI);
        test1.LstcontLineItem = conLst;
        PageReference pageRef = Page.CancelContOption; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(conLO.Id));
        Test.setCurrentPage(pageRef);
        test1.CancelOption();
        Test.StopTest(); 
    } */
}