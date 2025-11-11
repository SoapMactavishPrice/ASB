@isTest
public class Lwc_report_ProjectManagementContTest {
     public static testMethod void unitTest1(){
         
         
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = '44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
         
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
         us.Subsidiari__c = sub.Id;
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
         op.CurrencyIsoCode = 'INR';
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
        insert qt;
        
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
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Product_Name__c = 'prod namen'; 
        qli.Product__c = pro.id;
        qli.Is_Manual__c = true;
       
        insert qli;
		 //system.debug('unique no =>'+[select Id,Project_Unique_No__c,Product_Name__c from Quote_Line_Item_Custom__c where Id=:qli.Id limit 1]);
        //qt.Status = 'RELEASED';
    //    Update qt;
		
		Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        insert qlo;
		
		Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
        //cont.Expiration_Date__c = system.today();
        insert cont;
		
		
        //CheckRecursive.contractAfterUpdate=true;
        
		Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
         conLI.Quantity__c = 3.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
         
        conLI.Cancelled__c = False;
          conLI.Project_Unique_No__c = 'prod namen';
        conLI.Level_Of_Ceiling__c = '1000';   
        insert conLI;
		
        
        ProjectManagement__c pr = new ProjectManagement__c();
        pr.Account__c = acc.id;
        pr.Contract__c = cont.id;
        pr.Quote_Name__c = qt.id;
        pr.Contract_Line_Item__c = conLI.id;
        pr.Phase__c = 'Under Manufacturing';
        pr.Subsidiary__c = sub.Id;
        insert pr;
        pr.Hold__c = true;
        pr.Hold_Date__c = System.today() + 10;
        pr.Hold_Reason__c = 'Test';
        pr.Project_Unique_No__c = 'prod namen';
        
        update pr;
         
         ProjectManagement__c pr1 = new ProjectManagement__c();
        pr1.Account__c = acc.id;
        pr1.Contract__c = cont.id;
        pr1.Quote_Name__c = qt.id;
        pr1.Contract_Line_Item__c = conLI.id;
        pr1.Phase__c = 'Amendment';
        pr1.Subsidiary__c = sub.Id;
        insert pr1;
        //string js ='[{"salesPrice":null,"qty":1,"proNumber":null,"proName":"ASB-50MB v3 STD(00004090)","proLineId":null,"p_currency":null,"LineNumberIdClone":"'+conLI.Id+'","LineNumberId":"'+conLI.Id+'","LineNumber":"SLI - 000004089","key":"'+pr.Project_Unique_No__c+'","isSelect":true,"isDisabled":false}]';
         Lwc_report_ProjectManagementController.getProjectManagementDail(pr1.Id);
     }

}