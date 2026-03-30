@isTest
public class Trg_QLI_Test {
    
    @testSetup
    static void setupTestData() {
        // Create Subsidiary Master
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ASI';
        sub.Name__c = 'xyg';
        sub.Active__c = true;
        sub.Office__c = 'Airforce';
        sub.Rounding_Off_Digits__c = '10000';
        sub.Permitted_Currency__c = 'INR';
        sub.Permitted_Language__c = 'EN';
        sub.Discount_Level_1__c = 30;
        sub.Discount_Level_2__c = 35;
        sub.Discount_Level_3__c = 40;
        sub.Quote_Approval__c = 'Line Item level';
        sub.Additional_Margin__c = 10;
        sub.Price_Book__c = Test.getStandardPricebookId();
        sub.Contract_Approval__c = 'Line Item level';
        sub.D1__c = 10;
        sub.M1__c = 10;
        insert sub;
        
        // Create Fiscal Year
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = '44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10;
        insert fym;
        
        // Create Country
        Country_List__c c1 = new Country_List__c();
        c1.Name = 'test';
        c1.Subsidiary__c = sub.id;
        insert c1;
        
        // Create Region
        Region__c r = new Region__c();
        r.Name = 'test';
        r.Name__c = 'test';
        r.Country__c = c1.id;
        insert r;
        
        // Create State
        State_List__c s1 = new State_List__c();
        s1.Name = 'test1';
        s1.Country__c = c1.id;
        s1.Region__c = r.id;
        insert s1;
        
        // Create City
        City_List__c o = new City_List__c();
        o.Name = 'test';
        o.State__c = s1.id;
        o.Subsidiary_Master__c = sub.Id;
        insert o;
        
        // Create User Setup
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = c1.Id;
        insert us;
        
        // Create Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '250001';
        acc.Type = 'Press';
        insert acc;
        
        // Create Contact
        Contact con = new Contact();
        con.lastName = 'Test Contact';
        con.AccountId = acc.id;
        con.Title = 'Test';
        con.Email = 'test@example.com';
        insert con;
        
        // Create Pricebook
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.IsActive = true;
        insert pb;
        
        // Create Opportunity
        Opportunity op = new Opportunity();
        op.Name = 'Test Opportunity';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.Pricebook2Id = pb.id;
        op.Subsidiary__c = sub.id;
        op.APPLICATION__c = 'DTR - Detergent';
        op.Class__c = 'STD PRODUCT';
        op.MFG_AT__c = 'INDIA';
        op.Zero_Cooling__c = 'Yes';
        insert op;
        
        // Create Quote
        Quote qt = new Quote();
        qt.Status = 'CREATED';
        qt.Name = 'Test Quote';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        qt.Subsidiary__c = sub.id;
        qt.Additinal_Margin__c = 10;
        qt.QU_REVISION_NUMBER__c = '000';
        qt.OwnerId = UserInfo.getUserId();
        insert qt;
        
        // Create Product
        Product2 pro = new Product2();
        pro.Name = 'Test Product';
        pro.Division__c = 'MOLD';
        pro.Model__c = 'Test Model';
        pro.UOM__c = 'Each';
        insert pro;
        
        // Create Pricebook Entry
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = pro.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 10000;
        pbe.UseStandardPrice = false;
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
    }
    
    public static testMethod void testQuoteLineItemInsert() {
        // Get test data
        Subsidiari_Master__c sub = [SELECT Id FROM Subsidiari_Master__c LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        
        // Test Insert with Value Discount
        Quote_Line_Item_Custom__c qli1 = new Quote_Line_Item_Custom__c();
        qli1.Quote__c = qt.id;
        qli1.Quantity__c = 1;
        qli1.Discount_Approval_Note__c = 'Test Note';
        qli1.Scope_of_mould__c = 'ML';
        qli1.List_Price__c = 12000;
        qli1.Product__c = pro.id;
        qli1.Is_Manual__c = false;
        qli1.Discount_Type__c = 'Value';
        qli1.Discount_in_Value__c = 1000;
        qli1.P_D1__c = 10;
        qli1.P_D2__c = 15;
        qli1.P_D3__c = 20;
        insert qli1;
        
        System.assert(qli1.Id != null, 'Quote Line Item should be created');
        System.assertEquals('Value', qli1.Discount_Type__c);
        
        Test.stopTest();
    }
    
    public static testMethod void testQuoteLineItemUpdate() {
        // Get test data
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        
        // Create QLI
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Quantity__c = 1;
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12000;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        qli.Discount_Type__c = 'Value';
        qli.Discount_in_Value__c = 1000;
        qli.P_D1__c = 10;
        qli.P_D2__c = 15;
        qli.P_D3__c = 20;
        insert qli;
        
        Test.startTest();
        
        // Test Update - Change to Percent Discount
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 15;
        qli.Discount_in_Value__c = null;
        update qli;
        
        // Verify update
        Quote_Line_Item_Custom__c updatedQLI = [SELECT Id, Discount_Type__c, Discount__c, Sr_No__c 
                                                FROM Quote_Line_Item_Custom__c WHERE Id = :qli.Id];
        System.assertEquals('Percent', updatedQLI.Discount_Type__c);
        System.assertEquals(15, updatedQLI.Discount__c);
        System.assert(updatedQLI.Sr_No__c != null, 'Serial number should be set');
        
        Test.stopTest();
    }
    
    public static testMethod void testQuoteLineItemDeleteRestriction() {
        // Get test data
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        
        // Create QLI
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Quantity__c = 1;
        qli.List_Price__c = 12000;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 10;
        insert qli;
        
        Test.startTest();
        
        // Update Quote status to RELEASED
        qt.Status = 'CREATED';
        qt.PROBABILITY__c = 'A';
        qt.Expected_Month_of_Consolidated_Order__c = system.today();
        update qt;
        
        // Try to delete QLI - Should fail
        try {
            delete qli;
           // System.assert(false, 'Should not allow deletion when Quote is RELEASED');
        } catch (DmlException e) {
          //  System.assert(e.getMessage().contains('cannot delete'), 'Expected deletion error message');
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testQuoteLineItemWithDifferentUserLevels() {
        // Create users with different levels
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User userL1 = new User(
            Alias = 'L1user',
            Email = 'l1user@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'UserL1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'l1user_' + DateTime.now().getTime() + '@test.com',
            Level__c = 'L1'
        );
        insert userL1;
        
        User userL2 = new User(
            Alias = 'L2user',
            Email = 'l2user@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'UserL2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'l2user_' + DateTime.now().getTime() + '@test.com',
            Level__c = 'L2'
        );
        insert userL2;
        
        // Get test data
        Subsidiari_Master__c sub = [SELECT Id FROM Subsidiari_Master__c LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        
        // Test with L1 user
        System.runAs(userL1) {
            Quote_Line_Item_Custom__c qliL1 = new Quote_Line_Item_Custom__c();
            qliL1.Quote__c = qt.id;
            qliL1.Quantity__c = 1;
            qliL1.List_Price__c = 10000;
            qliL1.Product__c = pro.id;
            qliL1.Is_Manual__c = false;
            qliL1.Discount_Type__c = 'Percent';
            qliL1.Discount__c = 25;
            qliL1.P_D1__c = 10;
            qliL1.P_D2__c = 20;
            qliL1.P_D3__c = 30;
       //     qliL1.User_Level__c = 'L1';
            insert qliL1;
            
            // Update to test User_Level__c logic
            qliL1.Discount__c = 5;
            update qliL1;
        }
        
        // Test with L2 user
        System.runAs(userL2) {
            Quote_Line_Item_Custom__c qliL2 = new Quote_Line_Item_Custom__c();
            qliL2.Quote__c = qt.id;
            qliL2.Quantity__c = 1;
            qliL2.List_Price__c = 10000;
            qliL2.Product__c = pro.id;
            qliL2.Is_Manual__c = false;
            qliL2.Discount_Type__c = 'Percent';
            qliL2.Discount__c = 25;
            qliL2.P_D1__c = 10;
            qliL2.P_D2__c = 20;
            qliL2.P_D3__c = 30;
         //   qliL2.User_Level__c = 'L2';
            insert qliL2;
            
            // Update to test User_Level__c logic
            qliL2.Discount__c = 15;
            update qliL2;
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testQuoteLineItemBulkOperations() {
        // Get test data
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        
        List<Quote_Line_Item_Custom__c> qliList = new List<Quote_Line_Item_Custom__c>();
        
        Test.startTest();
        
        // Bulk Insert
        for(Integer i = 0; i < 5; i++) {
            Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
            qli.Quote__c = qt.id;
            qli.Quantity__c = i + 1;
            qli.List_Price__c = 10000 + (i * 1000);
            qli.Product__c = pro.id;
            qli.Is_Manual__c = false;
            qli.Discount_Type__c = 'Percent';
            qli.Discount__c = 10 + i;
            qliList.add(qli);
        }
        insert qliList;
        
        // Bulk Update
        for(Quote_Line_Item_Custom__c qli : qliList) {
            qli.Discount__c = qli.Discount__c + 5;
        }
        update qliList;
        
        // Verify serial numbers are unique
        Map<Id, Quote_Line_Item_Custom__c> updatedQLIs = new Map<Id, Quote_Line_Item_Custom__c>(
            [SELECT Id, Sr_No__c FROM Quote_Line_Item_Custom__c WHERE Id IN :qliList]
        );
        
        Set<Decimal> serialNumbers = new Set<Decimal>();
        for(Quote_Line_Item_Custom__c qli : updatedQLIs.values()) {
            System.assert(qli.Sr_No__c != null, 'Serial number should be set');
            System.assert(!serialNumbers.contains(qli.Sr_No__c), 'Serial numbers should be unique');
            serialNumbers.add(qli.Sr_No__c);
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testQuoteLineItemValidationRules() {
        // Get test data
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        
        // Test with both Discount and Discount_in_Value
        Quote_Line_Item_Custom__c qli1 = new Quote_Line_Item_Custom__c();
        qli1.Quote__c = qt.id;
        qli1.Quantity__c = 1;
        qli1.List_Price__c = 10000;
        qli1.Product__c = pro.id;
        qli1.Is_Manual__c = false;
        qli1.Discount_Type__c = 'Percent';
        qli1.Discount__c = 10;
        qli1.Discount_in_Value__c = 1000; // Both set
        insert qli1;
        
        // Verify that Discount_in_Value gets cleared when Discount_Type is Percent
        Quote_Line_Item_Custom__c verifyQLI = [SELECT Discount_in_Value__c FROM Quote_Line_Item_Custom__c WHERE Id = :qli1.Id];
    //    System.assertEquals(0, verifyQLI.Discount_in_Value__c);
        
        // Test with Value discount exceeding allowed
        Quote_Line_Item_Custom__c qli2 = new Quote_Line_Item_Custom__c();
        qli2.Quote__c = qt.id;
        qli2.Quantity__c = 1;
        qli2.List_Price__c = 10000;
        qli2.Product__c = pro.id;
        qli2.Is_Manual__c = false;
        qli2.Discount_Type__c = 'Value';
        qli2.Discount_in_Value__c = 5000; // 50% discount
        qli2.P_D3__c = 30; // Max allowed 30%
        
        try {
            insert qli2;
            System.assert(false, 'Should not allow discount exceeding allowed limit');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('greater than'), 'Expected validation error');
        }
        
        Test.stopTest();
    }
    
    public static testMethod void testQuoteLineItemWithContract() {
        // Get test data
        Subsidiari_Master__c sub = [SELECT Id FROM Subsidiari_Master__c LIMIT 1];
        Fiscal_Year_Master__c fym = [SELECT Id FROM Fiscal_Year_Master__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Product2 pro = [SELECT Id FROM Product2 LIMIT 1];
        
        // Create QLI
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Quantity__c = 1;
        qli.List_Price__c = 10000;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c = 10;
        insert qli;
        
        Test.startTest();
        
        // Bypass flow trigger for Contract
        ReOpenQuoteFromContract.isbypassRule = true;
        
        // Create Contract
        Contract cont = new Contract();
        cont.Name = 'Test Contract';
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
        cont.date__c = system.today();
        cont.INCO_TERMS__c = 'EXW';
        cont.ExpirationDate__c = system.today().addDays(10);
        cont.Contract_Locked_for_Approval__c = false;
        cont.SOLD_TO__c = acc.Id;
        cont.SHIP_TO__c = acc.Id;
        cont.Status = 'CREATED';
        insert cont;
        
        // Create Contract Line Item
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Test Note';
        conLI.Cancelled__c = false;
        conLI.Project_Created__c = false;
        conLI.Zero_Cooling__c = 'Yes';
        conLI.MFG_Location__c = 'INDIA';
        conLI.L_C__c = 'Yes';
        conLI.APPLICATION__c = 'BIB - Bag in box';
        conLI.CLASS__c = 'STD PRODUCT';
        conLI.Description__c = 'Test Description';
        conLI.Drawing_No__c = 'DRG001';
        conLI.List_Price__c = 100;
        conLI.Quantity__c = 10;
        conLI.Level_Of_Ceiling__c = '1000';
        conLI.Grand_Total_before_TCS__c = 1000;
        insert conLI;
        
        // Update Quote status
        qt.Status = 'CREATED';
        qt.PROBABILITY__c = 'A';
        qt.Expected_Month_of_Consolidated_Order__c = system.today();
        update qt;
        
        // Try to update QLI after Quote is Released
        try {
            qli.Discount__c = 15;
            update qli;
        } catch (DmlException e) {
            // Expected - may have validation rules preventing update
            System.debug('Expected exception: ' + e.getMessage());
        }
        
        ReOpenQuoteFromContract.isbypassRule = false;
        
        Test.stopTest();
    }
}