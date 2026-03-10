@IsTest
private class QuotePriceRecalculationControllerTest {

    @IsTest
    static void testControllerMethods() {

        // --------------------------
        // Setup Master Data
        // --------------------------
        Subsidiari_Master__c sub = new Subsidiari_Master__c(
            Name = 'SUB',
            Active__c = true,
            Permitted_Currency__c = 'USD',
            Permitted_Language__c = 'EN',
            Discount_Level_1__c = 5,
            Discount_Level_2__c = 10,
            Discount_Level_3__c = 15,
            Office__c = 'Thane'
        );
        insert sub;

        Fiscal_Year_Master__c fy = new Fiscal_Year_Master__c(
            Name = 'FY',
            Active__c = true,
            Fiscal_Year_Start_Date__c = Date.today().addDays(-5),
            Fiscal_Year_End_Date__c = Date.today().addDays(30)
        );
        insert fy;

        Global_Region__c gr = new Global_Region__c(
            Name = 'Region'
        );
        insert gr;

        Global_SubRegion__c sr = new Global_SubRegion__c(
            Name = 'SubRegion',
            Region__c = gr.Id
        );
        insert sr;

        Country_List__c country = new Country_List__c(
            Name = 'USA',
            Active__c = true,
            Country_Code__c = 'US',
            Region_Master__c = gr.Id,
            Sub_Region__c = sr.Id,
            Subsidiary__c = sub.Id
        );
        insert country;

        User_Setup__c us = new User_Setup__c(
            User__c = UserInfo.getUserId(),
            Subsidiari__c = sub.Id,
            Country__c = country.Id
        );
        insert us;

        Account acc = new Account(
            Name = 'Test Account',
            CurrencyIsoCode = 'USD',
            Billing_Country__c = country.Id,
            Shipping_Country__c = country.Id,
            Is_Converted__c = true
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            CurrencyIsoCode = 'USD'
        );
        insert opp;

        Id standardPricebookId = Test.getStandardPricebookId();

        Pricebook2 customPb = new Pricebook2(
            Name = 'Custom Pricebook',
            IsActive = true
        );
        insert customPb;

        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Pricebook2Id = standardPricebookId
        );
        insert qt;

        Product2 prod1 = new Product2(
            Name = 'Product 1',
            IsActive = true
        );
        insert prod1;

        Product2 prod2 = new Product2(
            Name = 'Product 2',
            IsActive = true
        );
        insert prod2;

        // --------------------------
        // Pricebook Entries
        // --------------------------
        insert new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = prod1.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = 'USD',
            D1__c = 1,
            D2__c = 2,
            D3__c = 3
        );

        insert new PricebookEntry(
            Pricebook2Id = customPb.Id,
            Product2Id = prod1.Id,
            UnitPrice = 120,
            IsActive = true,
            CurrencyIsoCode = 'USD',
            D1__c = 1,
            D2__c = 2,
            D3__c = 3
        );

        // --------------------------
        // Quote Line Items & Options
        // --------------------------
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c(
            Quote__c = qt.Id,
            Product__c = prod1.Id,
            Quantity__c = 1,
            Is_Manual__c = false
        );
        insert qli;

        insert new Quote_Line_Options__c(
            Quote__c = qt.Id,
            Product__c = prod2.Id,
            Select_Option__c = false,
            Quote_Line_Item_Custom__c = qli.Id
        );

        // --------------------------
        // Test Execution
        // --------------------------
        Test.startTest();

        // Cover your AuraEnabled method
        String result1 = QuotePriceRecalculationController.recalculateQuotePrice(qt.Id, customPb.Id);
        String result2 = QuotePriceRecalculationController.recalculateQuotePrice(qt.Id, standardPricebookId);

        // Optionally cover other controller methods (already in your snippet)
        QuotePriceRecalculationController.getPricebooks(qt.Id);
        QuotePriceRecalculationController.validateProductsInPricebook(qt.Id, customPb.Id);
        QuotePriceRecalculationController.validateProductsInPricebook(qt.Id, standardPricebookId);

        Test.stopTest();
    }
}