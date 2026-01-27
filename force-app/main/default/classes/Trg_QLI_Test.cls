@isTest
public class Trg_QLI_Test {
    public static testMethod void unitTest1(){
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ABC';
        sub.Name__c = 'xyg';
        sub.Active__c = true;
        sub.Office__c = 'Airforce';
        sub.Rounding_Off_Digits__c = '10000';
        sub.Permitted_Currency__c = 'INR';
        sub.Permitted_Language__c = 'EN';
        sub.Discount_Level_1__c = 30;
        sub.Discount_Level_2__c = 35;
        sub.Discount_Level_3__c = 40;
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
        
		lead ld= new lead(lastName='Test User', Status='New', Company='Test Company');
        insert ld;
		
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
        
        quote qt = new quote();
        qt.Status = 'CREATED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Additinal_Margin__c = 10;
        qt.QU_REVISION_NUMBER__c = '000';
        insert qt;
        
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
        pbe.Quantity__c = 1;
        pbe.D1__c = 0.1;
    pbe.D3__c = 0.2;
    pbe.D2__c = 0.3;
   pbe.M1__c = 0.1;
    pbe.M2__c = 0.2;
    pbe.M3__c = 0.3;
    pbe.M4__c = 0.4;
    pbe.Rounding_Off_Digits__c = '10';
        insert pbe;

        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        //qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12000;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        qli.Discount_Type__c = 'Value';
        qli.P_D3__c = 23; 
        qli.P_D1__c = 10; 
        qli.P_D2__c = 15; 
        qli.Discount_in_Value__c = 1;
        insert qli;
        
        qli.Sr_No__c = null;
        //qli.Discount_in_Value__c = 200;
        update qli;
        
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 17;
        qli.Discount_in_Value__c = null;
        update qli;
        
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 12;
        update qli;
        
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 16;
        update qli;
        
        Quote_Line_Item_Custom__c qli2 = new Quote_Line_Item_Custom__c();
        qli2.Quote__c = qt.id;
        //qli.Discount__c = 12;
        qli2.Quantity__c = 1;
        qli2.Discount_Approval_Note__c = 'sfasf';
        qli2.Scope_of_mould__c = 'ML';
        qli2.List_Price__c = 12;
        qli2.Product__c = pro.id;
        qli2.Is_Manual__c = false;
        //qli2.Discount_Type__c = 'Percent';
        qli2.P_D3__c = 23; 
        qli2.P_D1__c = 10; 
        qli2.P_D2__c = 15; 
        qli2.Discount_Approval_Note__c = 'null';
        qli2.Discount__c = 1;
        insert qli2;
        
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
        cont.FY1__c = fym.id;
        cont.Contract_Locked_for_Approval__c = true;
        cont.SOLD_TO__c = acc.Id;
        cont.SHIP_TO__c = acc.Id;
        insert cont;
        
        //cont.SOLD_TO__c = acc.Id;
        //cont.SHIP_TO__c = acc1.Id;
        //update cont;
        
        
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
        conLI.APPLICATION__c = 'BIB - Bag in box';
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
        
        ProjectManagement__c pr1 = new ProjectManagement__c();
        pr1.Account__c = acc.id;
        pr1.Contract__c = cont.id;
        pr1.Contract_Line_Item__c = conLI.id;
        pr1.Phase__c = 'Under Manufacturing';
        pr1.Subsidiary__c = sub.Id;
        pr1.Hold__c =false;
        pr1.Quote_Name__c = qt.Id;
        try{
        insert pr1;
        }Catch(Exception e){}  
        
        
        
        
   /*     update qli2;
        
        
        update qli2;
        update qli;	*/
        
		 qt.Status = 'RELEASED';
    }
    
    public static testMethod void unitTest2(){
        String uniqueUserName = 'SystemAdministrator' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Level__c='L1',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);

        System.runAs(u) {
              // The following code runs as user 'u'
              System.debug('Current User: ' + UserInfo.getUserName());
              System.debug('Current Profile: ' + UserInfo.getProfileId());
        
        
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
        
		lead ld= new lead(lastName='Test User', Status='New', Company='Test Company');
        insert ld;
		
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
        
        quote qt = new quote();
        qt.Status = 'CREATED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Additinal_Margin__c = 10;
        qt.QU_REVISION_NUMBER__c = '000';
        insert qt;
        
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
        pbe.Quantity__c = 1;
        pbe.D1__c = 0.1;
    pbe.D3__c = 0.2;
    pbe.D2__c = 0.3;
   pbe.M1__c = 0.1;
    pbe.M2__c = 0.2;
    pbe.M3__c = 0.3;
    pbe.M4__c = 0.4;
    pbe.Rounding_Off_Digits__c = '10';
        insert pbe;

        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        //qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        qli.Discount_Type__c = 'Value';
        qli.P_D3__c = 23; 
        qli.P_D1__c = 10; 
        qli.P_D2__c = 15; 
        qli.Discount_in_Value__c = 1;
        insert qli;
        
        qli.Sr_No__c = null;
        update qli;
        
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 17;
        qli.Discount_in_Value__c = null;
        update qli;
        
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 12;
        update qli;
        
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 16;
        update qli;
      /*  
        
        qli.Discount_Type__c = 'Value';
        qli.discount_in_Value__c = 2;
        qli.Discount__c = null;
        update qli;
        
        qli.Discount_Type__c = 'Value';
        qli.discount_in_Value__c = null;
        qli.Discount__c = null;
        update qli;
        
      qli.List_Price__c  = null;
        qli.discount_in_Value__c = null;
        qli.Discount__c = null;
        update qli;
       
           
        */
     /* Quote_Line_Item_Custom__c  qli2 = new Quote_Line_Item_Custom__c();
        qli2.Quote__c = qt.id;
        qli2.Discount__c = 12;
        qli2.Quantity__c = 1;
        qli2.Discount_Approval_Note__c = 'sfasf';
        qli2.Scope_of_mould__c = 'ML';
        qli2.List_Price__c = 12;
        qli2.Product__c = pro.id;
        qli2.Is_Manual__c = false;
        qli2.Discount_Type__c = 'Value';
        qli2.P_D3__c = 23; 
        qli2.Discount__c = null;
        qli2.Discount_Approval_Note__c = 'Null';
      
        qli2.Discount_in_Value__c = 1;
        
        insert qli2;*/
//        qli.Sr_No__c = 10;
        
        update qli;
//update qli2;
		
        qt.Status = 'RELEASED';
//        Update qt;
		
		delete qli;
        undelete qli;
        
        //delete qli2;
        //undelete qli2;
        
      /*  quote qt1 = new quote();
        qt1.Status = 'CREATED';
        qt1.Name = 'qt test';
        qt1.OpportunityId = op.id;
        qt1.Exchange_Rate__c = 1;
        qt1.Discount__c = 12;
        qt1.SUBSIDARY__c = sub.id;
        qt1.Subsidiary__c = sub.id;
        qt1.Additinal_Margin__c = 10;
        qt1.QU_REVISION_NUMBER__c = '000';
        insert qt1;
        
        Quote_Line_Item_Custom__c qli1 = new Quote_Line_Item_Custom__c();
        qli1.Quote__c = qt1.id;
        qli1.Discount__c = 12;
        qli1.Quantity__c = 1;
        qli1.Discount_Approval_Note__c = 'sfasf';
        qli1.Scope_of_mould__c = 'ML';
        qli1.List_Price__c = 12;
        qli1.Product__c = pro.id;
        qli1.Is_Manual__c = true;
        insert qli1;
        
        Quote_Line_Options__c qlo1 = new Quote_Line_Options__c();
        qlo1.Quote__c = qt1.id;
        qlo1.Quote_Line_Item_Custom__c = qli1.id;
        insert qlo1;
        
        delete qli1;
        */
        }
    }
    
    public static testMethod void unitTest3(){
        String uniqueUserName = 'SystemAdministrator1' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Level__c='L3',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);

        System.runAs(u) {
              // The following code runs as user 'u'
              System.debug('Current User: ' + UserInfo.getUserName());
              System.debug('Current Profile: ' + UserInfo.getProfileId());
        
        
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
        
		lead ld= new lead(lastName='Test User', Status='New', Company='Test Company');
        insert ld;
		
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
        
        quote qt = new quote();
        qt.Status = 'CREATED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Additinal_Margin__c = 10;
        qt.QU_REVISION_NUMBER__c = '000';
        insert qt;
        
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
        pbe.Quantity__c = 1;
        pbe.D1__c = 0.1;
    pbe.D3__c = 0.2;
    pbe.D2__c = 0.3;
   pbe.M1__c = 0.1;
    pbe.M2__c = 0.2;
    pbe.M3__c = 0.3;
    pbe.M4__c = 0.4;
    pbe.Rounding_Off_Digits__c = '10';
        insert pbe;

        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        //qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        qli.Discount_Type__c = 'Value';
        qli.P_D3__c = 23; 
        qli.P_D1__c = 10; 
        qli.P_D2__c = 15; 
        qli.Discount_in_Value__c = 1;
        insert qli;
        
        qli.Sr_No__c = null;
        update qli;
        
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 17;
        qli.Discount_in_Value__c = null;
        update qli;
        
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 12;
        update qli;
        
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 16;
        update qli;
      /*  
        
        qli.Discount_Type__c = 'Value';
        qli.discount_in_Value__c = 2;
        qli.Discount__c = null;
        update qli;
        
        qli.Discount_Type__c = 'Value';
        qli.discount_in_Value__c = null;
        qli.Discount__c = null;
        update qli;
        
      qli.List_Price__c  = null;
        qli.discount_in_Value__c = null;
        qli.Discount__c = null;
        update qli;
       
           
        */
     /* Quote_Line_Item_Custom__c  qli2 = new Quote_Line_Item_Custom__c();
        qli2.Quote__c = qt.id;
        qli2.Discount__c = 12;
        qli2.Quantity__c = 1;
        qli2.Discount_Approval_Note__c = 'sfasf';
        qli2.Scope_of_mould__c = 'ML';
        qli2.List_Price__c = 12;
        qli2.Product__c = pro.id;
        qli2.Is_Manual__c = false;
        qli2.Discount_Type__c = 'Value';
        qli2.P_D3__c = 23; 
        qli2.Discount__c = null;
        qli2.Discount_Approval_Note__c = 'Null';
      
        qli2.Discount_in_Value__c = 1;
        
        insert qli2;*/
//        qli.Sr_No__c = 10;
        
        update qli;
//update qli2;
		
        qt.Status = 'RELEASED';
//        Update qt;
		
		delete qli;
        undelete qli;
        
        //delete qli2;
        //undelete qli2;
        
      /*  quote qt1 = new quote();
        qt1.Status = 'CREATED';
        qt1.Name = 'qt test';
        qt1.OpportunityId = op.id;
        qt1.Exchange_Rate__c = 1;
        qt1.Discount__c = 12;
        qt1.SUBSIDARY__c = sub.id;
        qt1.Subsidiary__c = sub.id;
        qt1.Additinal_Margin__c = 10;
        qt1.QU_REVISION_NUMBER__c = '000';
        insert qt1;
        
        Quote_Line_Item_Custom__c qli1 = new Quote_Line_Item_Custom__c();
        qli1.Quote__c = qt1.id;
        qli1.Discount__c = 12;
        qli1.Quantity__c = 1;
        qli1.Discount_Approval_Note__c = 'sfasf';
        qli1.Scope_of_mould__c = 'ML';
        qli1.List_Price__c = 12;
        qli1.Product__c = pro.id;
        qli1.Is_Manual__c = true;
        insert qli1;
        
        Quote_Line_Options__c qlo1 = new Quote_Line_Options__c();
        qlo1.Quote__c = qt1.id;
        qlo1.Quote_Line_Item_Custom__c = qli1.id;
        insert qlo1;
        
        delete qli1;
        */
            
           // CreateContractsFromQuoteController.fakeCodeCoverage();
        }
    }
}