@isTest
public class Trg_ContractLineOption_Test {

     @isTest
    static void Trg_ContractLineOption() {
       
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
        
        Account acc1 = new Account();
        acc1.Name = 'acc vbnm anem';
        acc1.ADDRESS_LINE_1__c = 'add 1';
        acc1.ADDRESS_LINE_2__c = 'add 2';
        acc1.ADDRESS_LINE_3__c = 'add 3';
        acc1.Pin_Code__c = '250001';
        acc1.Type = 'Press';
        insert acc1; 
       
               
        Contact con1 = new Contact();
        con1.lastName = 'lname';
        con1.AccountId = acc1.id;
        con1.Title = 'dev';
        //con.Phone = 9837371155;
        con1.Email = 'vd@gmail.com';
        insert con1;
     
      
        Contract cont1 = new Contract();
        cont1.Opportunity__c = op.id;
        cont1.AccountId = acc.id;
        cont1.Quote__c = qt.id;
        cont1.Discount__c = 10 ;
        cont1.Subsidiary__c = sub.id;
        cont1.FY1__c = fym.id;
        cont1.Contract_Locked_for_Approval__c = true;
        cont1.SOLD_TO__c = acc1.Id;
        cont1.SHIP_TO__c = acc.Id;
        insert cont1;
       
       
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont1.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.List_Price__c = 100;
        conLI.Quantity__c = 10;
        conLI.Level_Of_Ceiling__c = '1000';   
        conLI.Grand_Total_before_TCS__c = 1000;
        insert conLI;
       
     
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont1.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        conLO.Total_Base_Price_Clone__c = 1000;
        insert conLO;
       
     ProjectManagement__c pm =  new ProjectManagement__c();
        pm.Contract__c = cont1.id;
        pm.Phase__c = 'Cancelled';
        //pm.Machinen_No__c = 'M1';
        pm.Contract_Line_Item__c = conLI.id;
        Insert pm;
       
       
     
        
}
}