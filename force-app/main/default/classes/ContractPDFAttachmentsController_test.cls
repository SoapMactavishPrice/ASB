@isTest
public class ContractPDFAttachmentsController_test {
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
        insert qt;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        insert pro;
        
        /*PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = pro.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 10000;
        pbe.UseStandardPrice= false;
        pbe.IsActive = true;
        pbe.Base_Price__c = 123;
        pbe.Discount_Level_3__c = 12;
        pbe.Pricing_Type__c = 1;
        pbe.Quantity__c = 1;

        insert pbe;
*/

PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id,
            UnitPrice = 10000, 
            UseStandardPrice= false,
            IsActive = true,
            Base_Price__c = 123,
            Discount_Level_3__c = 12,
            Pricing_Type__c = 1,
            Quantity__c = 1,
            D1__c = 0.1,
            D3__c = 0.2,
            D2__c = 0.3,
            M1__c = 0.1,
            M2__c = 0.2,
            M3__c = 0.3,
            M4__c = 0.4,
            Rounding_Off_Digits__c = '10');
        insert pbe;        
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = true;
        insert qli;
        
        qt.Status = 'RELEASED';
        Update qt;
        
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
        cont.FY1__c = fym.id;
        cont.Contract_Locked_for_Approval__c = true;
        cont.Expected_Month_of_Consolidated_Order__c = system.today();
        cont.Signed_SC_PO_receipt_date__c = system.today();
        cont.Original_Contracts_No__c='1234';
        
        
        
        //cont.SOLD_TO__c = acc1.Id;
        //cont.SHIP_TO__c = acc.Id;
        insert cont;
        
        CheckRecursive.contractAfterUpdate=true;
        
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
        insert pr1;
        
        
        Attachment at = new Attachment();
        at.Name = 'test';
        at.Body=Blob.valueOf('Test Body');
        at.ParentId=cont.Id;
        insert at;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(cont);
        ApexPages.currentPage().getParameters().put('id', cont.Id);
        ContractPDFAttachmentsController ec = new ContractPDFAttachmentsController(sc);
        ec.lstAttachment = new List<Attachment>();
        test.stopTest();
    }
}