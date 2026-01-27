@isTest
public class Treg_Contract_Test {
    public Static testMethod void unitTest(){
        
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
        sub.Quote_Approval__c ='Quote Level';
        sub.Contract_Approval__c = 'Contract Level';
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
        
        User u = new User();
        u.Username = 'vj@gmal.com';
        u.LastName = 'Tt';
        u.Email = 'vj@gmal.com';
        u.Alias = 'Mr';
        u.TimeZoneSidKey = 'Asia/Kolkata';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey  = 'ISO-8859-1';
        u.ProfileId  = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        u.LanguageLocaleKey = 'en_US';
        u.IsActive = true;
        u.Level__c = 'L2';
        insert u;
        
        
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
        acc.Name = 'acc v2 anem';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '250001';
        acc.Type = 'Press';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'acc anem';
        acc1.ADDRESS_LINE_1__c = 'add 1';
        acc1.ADDRESS_LINE_2__c = 'add 2';
        acc1.ADDRESS_LINE_3__c = 'add 3';
        acc1.Pin_Code__c = '250001';
        acc1.Type = 'Press';
        insert acc1;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
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
        cont.Contract_Locked_for_Approval__c = true;
        cont.SOLD_TO__c = acc1.Id;
        cont.SHIP_TO__c = acc.Id;
        insert cont;
        
        cont.Discount__c = 12;
        update cont;
        
        cont.SOLD_TO__c = acc.Id;
        cont.SHIP_TO__c = acc1.Id;
        update cont;
        
        u.Level__c = 'L2';
        update u;
        
        u.Level__c = 'L3';
        update u;
        
        sub.Contract_Approval__c = 'Line Item level';
        update sub;
        
        Test.startTest();
        Contract cont1 = new Contract();
        cont1.Opportunity__c = op.id;
        cont1.AccountId = acc.id;
        cont1.Quote__c = qt.id;
        cont1.Discount__c = 10 ;
        cont1.Subsidiary__c = sub.id;
        cont1.FY1__c = fym.id;
        cont1.Contract_Locked_for_Approval__c = true;
        //cont1.Status = 'RELEASED';
        insert cont1;
        
        CheckRecursive.contractAfterUpdate=true;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont1.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 10.0;
        conLI.Approved_Discount__c = 10.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.List_Price__c = 100;
        conLI.Quantity__c = 10;
        conLI.Level_Of_Ceiling__c = '1000';   
        conLI.Grand_Total_before_TCS__c = 1000;
        insert conLI;
       
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.Discount__c = 16.0;
        conLO.Approved_Discount__c = 10.0;
        conLO.ContractId__c = cont1.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        conLO.Total_Base_Price_Clone__c = 1000;
        insert conLO;
        
        conLI.Cancelled__c = true;
        conLI.Cancellation_Reason__c = '';
        update conLI;
        
        CheckRecursive.contractAfterUpdate=false;
        
        cont1.Status = 'RELEASED';
        
        update cont1;
        test.stopTest();
           
        
    } 
}