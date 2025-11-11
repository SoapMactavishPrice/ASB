@isTest
public class Trg_ContractNew_Test {


    public static testMethod void Trg_ContractNew(){
        
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ASI';
        sub.Name__c = 'ASI';
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
        qt.Status = 'Draft';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Additinal_Margin__c = 10;
        qt.Application__c='BIB - Bag in box';
        qt.Status = 'CLOSE - LOST';
        qt.CLOSE_LOST_REASON__c ='OTHER'; 
        insert qt;
        
        qt.Status = 'CLOSE - LOST';
        update qt;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
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

        
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 1;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = true;
        insert qli;
        
        //qt.Status = 'RELEASED';
        //Update qt;
        
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
        cont.Expiration_Date__c =system.today() + 3; 
        cont.Subsidiary__c = sub.id;
        cont.PO_No_from_customer__c = 'dsfghjkl';
        cont.FY1__c = fym.id;
        cont.Contract_Locked_for_Approval__c = true;
        cont.Expected_Month_of_Consolidated_Order__c = system.today();
        cont.Signed_SC_PO_receipt_date__c = system.today();
        cont.Original_Contracts_No__c='1234';
        
        
        
        //cont.SOLD_TO__c = acc1.Id;
        //cont.SHIP_TO__c = acc.Id;
        insert cont;
        
        cont.Contact_Id__c = con.Id;
        update cont;
        
        
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
        
        cont.Status='Waiting for DP/LC';
        update cont;
        
        ProjectManagement__c pr1 = new ProjectManagement__c();
        pr1.Account__c = acc.id;
        pr1.Contract__c = cont.id;
        pr1.Contract_Line_Item__c = conLI.id;
        pr1.Phase__c = 'Under Manufacturing';
        pr1.Subsidiary__c = sub.Id;
        insert pr1;
        
        
   //     cont.Status='Converted to PM – Partial';  
   //     update cont;
        
        cont.Expiration_Date__c =system.today().addDays(5); 
        update cont;
        
        /*
        Contract_Line_Item__c conLI2 = new Contract_Line_Item__c();
        conLI2.ContractId__c = cont.Id;
        conLI2.Discount__c = 16.0;
        conLI2.Discount_Allowed__c = 20.0;
        conLI2.Approval_Note__c = 'Null';
        conLI2.Cancelled__c = False;
        conLI2.Project_Created__c =false;
        conLI2.Zero_Cooling__c = 'Yes';
        conLI2.MFG_Location__c = 'INDIA';
        conLI2.L_C__c = 'Yes';
        conLI2.APPLICATION__c = 'BIB - Bag in box';
        conLI2.CLASS__c = 'STD PRODUCT';
        conLI2.Description__c = 'dasdk';
        conLI2.Drawing_No__c = 'qweqwe';
        conLI2.Discount__c = 16.0;
        conLI2.Discount_Allowed__c = 20.0;
        conLI2.List_Price__c = 100;
        conLI2.Quantity__c = 10;
        conLI2.Level_Of_Ceiling__c = '1000';   
        conLI2.Grand_Total_before_TCS__c = 1000;
        insert conLI2;
        
        */
        
        
        
        
        
        //cont.Status='CLOSE - LOST';
        //cont.Closed_Date__c = system.today()+10;
        //update cont;
        
        
        

    }
    
    
    public static testMethod void Trg_ContractNew2(){
        
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'COM';
        sub.Name__c = 'COM';
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
        qt.Status = 'Draft';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Additinal_Margin__c = 10;
        qt.Application__c='BIB - Bag in box';
        qt.Status = 'CLOSE - LOST';
        qt.CLOSE_LOST_REASON__c ='OTHER'; 
        insert qt;
        
        qt.Status = 'CLOSE - LOST';
        update qt;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
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

        
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 1;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = true;
        insert qli;
        
        //qt.Status = 'RELEASED';
        //Update qt;
        
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
        cont.Expiration_Date__c =system.today() + 3; 
        cont.Subsidiary__c = sub.id;
        cont.PO_No_from_customer__c = 'dsfghjkl';
        cont.FY1__c = fym.id;
        cont.Contract_Locked_for_Approval__c = true;
        cont.Expected_Month_of_Consolidated_Order__c = system.today();
        cont.Signed_SC_PO_receipt_date__c = system.today();
        cont.Original_Contracts_No__c='1234';
        
        
        
        //cont.SOLD_TO__c = acc1.Id;
        //cont.SHIP_TO__c = acc.Id;
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
        
        cont.Status='Waiting for DP/LC';
        update cont;
        
        ProjectManagement__c pr1 = new ProjectManagement__c();
        pr1.Account__c = acc.id;
        pr1.Contract__c = cont.id;
        pr1.Contract_Line_Item__c = conLI.id;
        pr1.Phase__c = 'Under Manufacturing';
        pr1.Subsidiary__c = sub.Id;
        insert pr1;
        
        
     //   cont.Status='Converted to PM – Partial';
     //   update cont;
        
        cont.Expiration_Date__c =system.today().addDays(5); 
        update cont;
        
        /*
        Contract_Line_Item__c conLI2 = new Contract_Line_Item__c();
        conLI2.ContractId__c = cont.Id;
        conLI2.Discount__c = 16.0;
        conLI2.Discount_Allowed__c = 20.0;
        conLI2.Approval_Note__c = 'Null';
        conLI2.Cancelled__c = False;
        conLI2.Project_Created__c =false;
        conLI2.Zero_Cooling__c = 'Yes';
        conLI2.MFG_Location__c = 'INDIA';
        conLI2.L_C__c = 'Yes';
        conLI2.APPLICATION__c = 'BIB - Bag in box';
        conLI2.CLASS__c = 'STD PRODUCT';
        conLI2.Description__c = 'dasdk';
        conLI2.Drawing_No__c = 'qweqwe';
        conLI2.Discount__c = 16.0;
        conLI2.Discount_Allowed__c = 20.0;
        conLI2.List_Price__c = 100;
        conLI2.Quantity__c = 10;
        conLI2.Level_Of_Ceiling__c = '1000';   
        conLI2.Grand_Total_before_TCS__c = 1000;
        insert conLI2;
        
        */
        
        
        
        
        
        //cont.Status='CLOSE - LOST';
        //cont.Closed_Date__c = system.today()+10;
        //update cont;
        
        
        

    }

}