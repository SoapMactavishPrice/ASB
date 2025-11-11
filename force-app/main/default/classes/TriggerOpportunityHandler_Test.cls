@isTest
public class TriggerOpportunityHandler_Test {
    

    public Static testMethod void unitTest1(){
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
        fym.Name = '44';
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
        o.Subsidiary_Master__c= sub.id;
        insert o;
        
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = c1.Id;
        insert us;
    
        lead ld= new lead(lastName='Test User', Status='New', Company='Test Company');
        insert ld;
        
        Account acc = new Account();
        acc.Name = 'acc anem';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '250001';
        acc.Type = 'Press';
        acc.ERP_ID__c = '007';
        //acc.ParentId = ld.Id;
        //acc.Global_Customer_ID__c = '003 COCA COLA';
        acc.Global_Customer_Name__c =  'Test';
        acc.Account_Type__c = 'GLOBAL';
       // acc.Global_Customer_ID__c = '003 COCA COLA';
        acc.Customer_Category__c = 'Medium';
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
        
        op.MFG_AT__c = 'INDIA';
        update op;
        op.AccountId = acc.id;
        update op;
        op.StageName = 'Converted';
        update op;
        //op.StageName = 'Visit Planned';
        //update op;
        op.AccountId = acc.id;
        update op;
        
        
        TriggerOpportunityHandler toh = new TriggerOpportunityHandler() ;
        toh.OnUpdateOpportunity(op.ID);
        toh.OpptyRecUpdate(op.Id);
        
        /*Period prd = new Period();
        //prd.FiscalYearSettings.Name='Oct-Sept';
        prd.StartDate = system.today();
        prd.EndDate = system.today() + 5;
        insert prd;*/
        
        //TriggerOpportunityHandler.TriggerOpportunityHandler();
    }
}