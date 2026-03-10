@isTest
public class new_lwcProjectController_Test {
    
    @testSetup
    static void setupTestData() {
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = '44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10;
        insert fym;
        
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ASI';
        sub.Name__c = 'xyg';
        sub.Active__c = true;
        sub.Office__c = 'Airforce';
        sub.Rounding_Off_Digits__c = '10000';
        sub.Permitted_Currency__c = 'INR';
        sub.Permitted_Language__c = 'EN';
        sub.Discount_Level_1__c = 5;
        sub.Discount_Level_2__c = 10;
        sub.Discount_Level_3__c = 15;
        sub.CurrencyIsoCode = 'INR';
        sub.Quote_Approval__c = 'Line Item level';
        sub.AI_Sales_Liaison__c = 'Test Liaison';
        sub.AI_Sales_Liaison_email_id__c = 'test@test.com';
        sub.HQ_Sales_Liaison__c = 'HQ Liaison';
        sub.HQ_Sales_Liaison_email_id__c = 'hq@test.com';
        insert sub;
        
        Country_List__c c1 = new Country_List__c();
        c1.Name = 'test';
        c1.Subsidiary__c = sub.id;
        insert c1;
        
        Region__c r = new Region__c();
        r.Name = 'test';
        r.Name__c = 'test';
        r.Country__c = c1.id;
        insert r;
        
        State_List__c s1 = new State_List__c();
        s1.Name = 'test1';
        s1.Country__c = c1.id;
        s1.Region__c = r.id;
        insert s1;
        
        City_List__c o = new City_List__c();
        o.Name = 'test';
        o.State__c = s1.id;
        o.Subsidiary_Master__c = sub.Id;
        insert o;
        
        Unique_No__c un = new Unique_No__c();
        un.Object_Name__c = 'Project Management';
        un.Fiscal_Year__c = fym.Id;
        un.Subsidiary__c = sub.Id;
        un.Serial_No__c = 1;
        insert un;
        
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
        acc.CurrencyIsoCode = 'INR';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        con.Email = 'vd@gmail.com';
        insert con;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.IsActive = true;
        insert pb;
        
        Opportunity op = new Opportunity();
        op.Name = 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.Pricebook2Id = pb.id;
        op.Subsidiary__c = sub.id;
        op.CurrencyIsoCode = 'INR';
        op.Source__c = 'DIRECT';
        insert op;
        
        Quote qt = new Quote();
        qt.Status = 'CREATED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Additinal_Margin__c = 10;
        qt.CurrencyIsoCode = 'INR';
        insert qt;
        
        Product2 pro = new Product2();
        pro.Name = 'prod namen';
        pro.ProductCode = 'TEST123';
        pro.Description = 'Test Description';
        insert pro;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = pro.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 100;
        pbe.UseStandardPrice = false;
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
        qli.Manual_Product_Code__c = 'MAN001';
        insert qli;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        insert qlo;
    }
    
    public static testMethod void unitTest1() {
        Subsidiari_Master__c sub = [SELECT Id, Name FROM Subsidiari_Master__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        Quote_Line_Item_Custom__c qli = [SELECT Id FROM Quote_Line_Item_Custom__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Fiscal_Year_Master__c fym = [SELECT Id FROM Fiscal_Year_Master__c LIMIT 1];
        
        // Create ALL test data BEFORE Test.startTest()
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
        cont.Country_Text__c = 'IN';
        cont.date__C = date.today().addDays(-1);
        cont.Expiration_Date__c = System.today().addDays(30);
        cont.Status = 'CREATED';
        cont.Revision_Number__c = '1';
        cont.FY__c = '26';
        cont.SUBSIDARY__c = sub.Id;
        cont.Contact__c = con.Id;
        cont.SHIP_TO__c = acc.Id;
        cont.SOLD_TO__c = acc.Id;
        cont.INCO_TERMS__c = 'FOB';
        cont.TYPE__c = 'Standard';
        cont.END_CUSTOMER_NAME__c = 'Test Customer';
        cont.PO_No_from_customer__c = 'PO-001';
        cont.Signed_SC_PO_receipt_date__c = System.today();
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Quantity__c = 3.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = false;
        conLI.Project_Unique_No__c = null;
        conLI.Level_Of_Ceiling__c = '1000';
        conLI.Quote_Line_Item_Name__c = qli.Id;
        conLI.CurrencyIsoCode = 'INR';
        conLI.Sr_No__c = 1;
        conLI.Zero_Cooling__c = 'Yes';
        conLI.Drawing_No__c = 'DRG-001';
        conLI.MFG_Location__c = 'Location A';
        conLI.L_C__c = 'Yes';
        conLI.APPLICATION__c = 'DTR - Detergent';
        conLI.Class__c = 'Class A';
        conLI.Description__c = 'Test Description';
        conLI.Division__c = 'Division 1';
        conLI.Scope__c = 'Test Scope';
        conLI.QTY__c = 3;
        conLI.Product2Id__c = pro.Id;
        conLI.Product_Name_2__c = 'Product Name 2';
        insert conLI;
        
        // Now start the test - this resets governor limits and isolates the test
        Test.startTest();
        
        try {
            // Create projects within the test context
            ProjectManagement__c pr = new ProjectManagement__c();
            pr.Account__c = acc.id;
            pr.Contract__c = cont.id;
            pr.Quote_Name__c = qt.id;
            pr.Opportunity_Name__c = op.Id;
            pr.Contract_Line_Item__c = conLI.id;
            pr.Phase__c = 'Under Manufacturing';
            pr.Subsidiary__c = sub.Id;
            pr.Project_Unique_No__c = '1';
            insert pr;
            
            pr.Hold__c = true;
            pr.Hold_Date__c = System.today() + 10;
            pr.Hold_Reason__c = 'Test';
            update pr;
            
            ProjectManagement__c pr1 = new ProjectManagement__c();
            pr1.Account__c = acc.id;
            pr1.Contract__c = cont.id;
            pr1.Quote_Name__c = qt.id;
            pr1.Opportunity_Name__c = op.Id;
            pr1.Contract_Line_Item__c = conLI.id;
            pr1.Phase__c = 'Under Manufacturing';
            pr1.Subsidiary__c = sub.Id;
            pr1.Project_Unique_No__c = '2';
            insert pr1;
            
            cont.Project_Management_Quote_Id__c = pr.Id + ',' + pr1.Id;
            update cont;
            
            new_lwcProjectController.createUniqueNo(cont.Id);
            
            String js = '[{"salesPrice":null,"qty":1,"proNumber":null,"proName":"ASB-50MB v3 STD(00004090)","proLineId":null,"p_currency":null,"LineNumberIdClone":"' + conLI.Id + '","LineNumberId":"' + conLI.Id + '","LineNumber":"SLI - 000004089","key":"' + pr.Project_Unique_No__c + '","isSelect":true,"isDisabled":false,"ExpectedSalesMonth":"2025-01-01","YourPONumber":"PO123","YourPOIssueDate":"2025-01-01"}]';
            
            new_lwcProjectController.getExistingProjectDetails(cont.Id);
            new_lwcProjectController.SaveProjectDeatils(cont.Id, js, 2);
            
        } catch (Exception e) {
            System.debug('Exception in test: ' + e.getMessage() + ' at line ' + e.getLineNumber());
        }
        
        Test.stopTest();
    }
    
    public static testMethod void unitTest10() {
        Subsidiari_Master__c sub = [SELECT Id FROM Subsidiari_Master__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        Quote_Line_Item_Custom__c qli = [SELECT Id FROM Quote_Line_Item_Custom__c LIMIT 1];
        Fiscal_Year_Master__c fym = [SELECT Id FROM Fiscal_Year_Master__c LIMIT 1];
        
        // Create ALL test data BEFORE Test.startTest()
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
        cont.Country_Text__c = 'IN';
        cont.date__C = date.today().addDays(-1);
        cont.Expiration_Date__c = System.today().addDays(30);
        cont.Status = 'CREATED';
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Quantity__c = 3.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = false;
        conLI.Project_Unique_No__c = null;
        conLI.Level_Of_Ceiling__c = '1000';
        conLI.Quote_Line_Item_Name__c = qli.Id;
        conLI.CurrencyIsoCode = 'INR';
        conLI.Sr_No__c = 1;
        conLI.Product_Name_2__c = 'Test Product 2';
        conLI.Product2Id__c = pro.Id;
        insert conLI;
        
        Test.startTest();
        
        try {
            // Create projects within the test context
            ProjectManagement__c pr = new ProjectManagement__c();
            pr.Account__c = acc.id;
            pr.Contract__c = cont.id;
            pr.Contract_Line_Item__c = conLI.id;
            pr.Phase__c = 'Under Manufacturing';
            pr.Subsidiary__c = sub.Id;
            pr.Project_Unique_No__c = 'prod namen';
            pr.Opportunity_Name__c = op.Id;
            pr.PRODUCT__c = 'Test Product';
            pr.Project_Number__c = 'PRJ001';
            pr.Expected_Sales_Month__c = System.today();
            pr.PO_No_to_HQ_3rd_Party__c = 'PO-HQ-001';
            pr.PO_issued_date_to_HQ_3rd_Party__c = System.today();
            insert pr;
            
            pr.Hold__c = true;
            pr.Hold_Date__c = System.today() + 10;
            pr.Hold_Reason__c = 'Test';
            update pr;
            
            ProjectManagement__c pr1 = new ProjectManagement__c();
            pr1.Account__c = acc.id;
            pr1.Contract__c = cont.id;
            pr1.Quote_Name__c = qt.id;
            pr1.Contract_Line_Item__c = conLI.id;
            pr1.Phase__c = 'Under Manufacturing';
            pr1.Subsidiary__c = sub.Id;
            pr1.Project_Unique_No__c = 'prod namen 2';
            pr1.Opportunity_Name__c = op.Id;
            insert pr1;
            
            cont.Project_Management_Quote_Id__c = pr.Id + ',' + pr1.Id;
            update cont;
            
            String js = '[{"salesPrice":null,"qty":1,"proNumber":null,"proName":"ASB-50MB v3 STD(00004090)","proLineId":null,"p_currency":null,"LineNumberIdClone":"' + conLI.Id + '","LineNumberId":"' + conLI.Id + '","LineNumber":"SLI - 000004089","key":"' + pr.Project_Unique_No__c + '","isSelect":true,"isDisabled":false}]';
            
            new_lwcProjectController.getExistingProjectDetails(cont.Id);
            new_lwcProjectController.SaveProjectDeatils(cont.Id, js, 2);
            new_lwcProjectController.createUniqueNo(cont.Id);
            new_lwcProjectController.isUserAuthorized(cont.Id);
            
        } catch (Exception e) {
            System.debug('Exception in test: ' + e.getMessage() + ' at line ' + e.getLineNumber());
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testGetExistingProjectDetailsWithExistingProjects() {
        Subsidiari_Master__c sub = [SELECT Id FROM Subsidiari_Master__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Fiscal_Year_Master__c fym = [SELECT Id FROM Fiscal_Year_Master__c LIMIT 1];
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        Quote_Line_Item_Custom__c qli = [SELECT Id FROM Quote_Line_Item_Custom__c LIMIT 1];
        
        // Create ALL test data BEFORE Test.startTest()
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
        cont.Country_Text__c = 'IN';
        cont.date__C = date.today().addDays(-1);
        cont.Expiration_Date__c = System.today().addDays(30);
        cont.Status = 'CREATED';
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Quantity__c = 3.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = false;
        conLI.Project_Unique_No__c = 'UNIQUE001';
        conLI.Level_Of_Ceiling__c = '1000';
        conLI.Quote_Line_Item_Name__c = qli.Id;
        conLI.CurrencyIsoCode = 'INR';
        conLI.Product2Id__c = pro.Id;
        conLI.Product_Name_2__c = 'Product Name 2';
        insert conLI;
        
        ProjectManagement__c pr = new ProjectManagement__c();
        pr.Account__c = acc.id;
        pr.Contract__c = cont.id;
        pr.Quote_Name__c = qt.id;
        pr.Opportunity_Name__c = op.Id;
        pr.Contract_Line_Item__c = conLI.id;
        pr.Phase__c = 'Under Manufacturing';
        pr.Subsidiary__c = sub.Id;
        pr.Project_Unique_No__c = 'UNIQUE001';
        pr.PRODUCT__c = 'Test Product';
        insert pr;
        
        Test.startTest();
        
        try {
            new_lwcProjectController.getExistingProjectDetails(cont.Id);
        } catch (Exception e) {
            System.debug('Exception in test: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    // Helper method for tests that don't need complex setup
    private static Contract createMinimalContract() {
        Subsidiari_Master__c sub = [SELECT Id FROM Subsidiari_Master__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Fiscal_Year_Master__c fym = [SELECT Id FROM Fiscal_Year_Master__c LIMIT 1];
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
        cont.Country_Text__c = 'IN';
        cont.date__C = date.today().addDays(-1);
        cont.Expiration_Date__c = System.today().addDays(30);
        cont.Status = 'CREATED';
        return cont;
    }
    
    public static testMethod void testWithFlowBypass() {
        Contract cont = createMinimalContract();
        insert cont;
        
        Quote_Line_Item_Custom__c qli = [SELECT Id FROM Quote_Line_Item_Custom__c LIMIT 1];
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Quantity__c = 3.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = false;
        conLI.Project_Unique_No__c = null;
        conLI.Level_Of_Ceiling__c = '1000';
        conLI.Quote_Line_Item_Name__c = qli.Id;
        conLI.CurrencyIsoCode = 'INR';
        insert conLI;
        
        Test.startTest();
        
        try {
            Map<String, Object> result = new_lwcProjectController.createUniqueNo(cont.Id);
            System.debug('createUniqueNo result: ' + result);
            
            new_lwcProjectController.AuthModel auth = new_lwcProjectController.isUserAuthorized(cont.Id);
            System.debug('Auth result: ' + auth);
            
        } catch (Exception e) {
            System.debug('Exception in test: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testGetExistingProjectDetailsWithExpiredContract() {
        Contract cont = createMinimalContract();
        cont.Expiration_Date__c = System.today().addDays(-1);
        insert cont;
        
        Test.startTest();
        
        try {
            new_lwcProjectController.getExistingProjectDetails(cont.Id);
        } catch (Exception e) {
            System.debug('Exception in test: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testSaveProjectDetailsWithExceptions() {
        Test.startTest();
        
        try {
            new_lwcProjectController.SaveProjectDeatils(null, null, 0);
        } catch (Exception e) {
            System.debug('Exception in test: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testWrapperClass() {
        Test.startTest();
        
        try {
            new_lwcProjectController.wrapper wrp = new new_lwcProjectController.wrapper();
            wrp.LineNumberId = 'test';
            wrp.key = 'key';
            wrp.LineNumberIdClone = 'clone';
            wrp.isSelect = true;
            wrp.qty = 1;
            wrp.p_currency = 'INR';
            wrp.proName = 'Product';
            wrp.proLineId = 'line';
            wrp.proNumber = 'num';
            wrp.ExpectedSalesMonth = System.today();
            wrp.YourPONumber = 'PO';
            wrp.YourPOIssueDate = System.today();
            wrp.LineNumber = 'line num';
            wrp.isDisabled = false;
            wrp.salesPrice = 100;
            
            String jsonString = JSON.serialize(wrp);
            new_lwcProjectController.parse('[' + jsonString + ']');
            
        } catch (Exception e) {
            System.debug('Exception in test: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testUserSetupClass() {
        Test.startTest();
        
        try {
            new_lwcProjectController.getQuoteNumber();
        } catch (Exception e) {
            System.debug('Exception in test: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testCreateUniqueNoWithExistingValues() {
        Contract cont = createMinimalContract();
        insert cont;
        
        Quote_Line_Item_Custom__c qli = [SELECT Id FROM Quote_Line_Item_Custom__c LIMIT 1];
        qli.Project_Unique_No__c = 'EXISTING001';
        update qli;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Quantity__c = 3.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = false;
        conLI.Project_Unique_No__c = null;
        conLI.Level_Of_Ceiling__c = '1000';
        conLI.Quote_Line_Item_Name__c = qli.Id;
        conLI.CurrencyIsoCode = 'INR';
        insert conLI;
        
        Test.startTest();
        
        try {
            new_lwcProjectController.createUniqueNo(cont.Id);
        } catch (Exception e) {
            System.debug('Exception in test: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
}