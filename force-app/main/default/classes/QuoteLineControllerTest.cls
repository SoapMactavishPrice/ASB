@isTest
public class QuoteLineControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create Fiscal Year
        Fiscal_Year_Master__c fiscalYear = new Fiscal_Year_Master__c(
            Name = 'F25',
            Active__c = true,
            Fiscal_Year_Start_Date__c = Date.today().addMonths(-6),
            Fiscal_Year_End_Date__c = Date.today().addMonths(6)
        );
        insert fiscalYear;
        
        // Create Subsidiary with valid picklist value (ASI, COM, EUR)
        Subsidiari_Master__c subsidiary = new Subsidiari_Master__c(
            Name = 'ASI',
            Name__c = 'Test Subsidiary',
            Active__c = true,
            Office__c = 'Test Office',
            Rounding_Off_Digits__c = '100',
            Permitted_Currency__c = 'INR',
            Permitted_Language__c = 'EN',
            Discount_Level_1__c = 5,
            Discount_Level_2__c = 10,
            Discount_Level_3__c = 15,
            Quote_Approval__c = 'Line Item level',
            Contract_Approval__c = 'Line Item level'
        );
        insert subsidiary;
        
        // Create Unique Number for Quote
        Unique_No__c uniqueNo = new Unique_No__c(
            Object_Name__c = 'Quote',
            Subsidiary__c = subsidiary.Id,
            Fiscal_Year__c = fiscalYear.Id,
            Serial_No__c = 1
        );
        insert uniqueNo;
        
        // Create Country
        Country_List__c country = new Country_List__c(
            Name = 'Test Country',
            Active__c = true,
            Subsidiary__c = subsidiary.Id
        );
        insert country;
        
        // Create Region
        Region__c region = new Region__c(
            Name = 'Test Region',
            Name__c = 'Test Region',
            Active__c = true,
            Country__c = country.Id
        );
        insert region;
        
        // Create User Setup
        User_Setup__c userSetup = new User_Setup__c(
            User__c = UserInfo.getUserId(),
            Subsidiari__c = subsidiary.Id,
            Country__c = country.Id,
            Region__c = region.Id,
            Default_Language__c = 'EN'
        );
        insert userSetup;
        
        // Create Account
        Account account = new Account(
            Name = 'Test Account',
            CurrencyIsoCode = 'INR',
            Region1__c = region.Id
        );
        insert account;
        
        // Create Contact
        Contact contact = new Contact(
            LastName = 'Test Contact',
            AccountId = account.Id,
            Email = 'test@example.com'
        );
        insert contact;
        
        // Create Opportunity
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = account.Id,
            Contact__c = contact.Id,
            CurrencyIsoCode = 'INR',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            Subsidiary__c = subsidiary.Id
        );
        insert opportunity;
        
        // Create Quote Template
        Quote_Template__c quoteTemplate = new Quote_Template__c(
            Label__c = 'Test Template',
            Subsidiary__c = subsidiary.Id,
            Language__c = 'EN',
            Active__c = true
        );
        insert quoteTemplate;
        
        // Create Quote
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opportunity.Id,
            CurrencyIsoCode = 'INR',
            Status = 'CREATED',
            Fiscal_Year_Master__c = fiscalYear.Id,
            Subsidiary__c = subsidiary.Id,
            Quote_Number1__c = 'QASI2025-00001',
            Language__c = 'EN',
            Quote_Template__c = quoteTemplate.Id,
            Exchange_Rate__c = 1,
            Additinal_Margin__c = 10,
            Quote_Number__c = 'QASI2025-00001',
            QU_REVISION_NUMBER__c = '000'
        );
        insert quote;
        
        // Update Quote with revision
        quote.QU_REVISION_NUMBER__c = '000';
        quote.Quote_Number__c = quote.Quote_Number1__c;
        update quote;
        
        // Create Products
        Product2 product1 = new Product2(
            Name = 'Test Product 1',
            CurrencyIsoCode = 'INR',
            IsActive = true,
            Family = 'Items'
        );
        insert product1;
        
        Product2 product2 = new Product2(
            Name = 'Test Product 2',
            CurrencyIsoCode = 'INR',
            IsActive = true,
            Family = 'Items'
        );
        insert product2;
        
        Product2 optionProduct = new Product2(
            Name = 'Test Option Product',
            CurrencyIsoCode = 'INR',
            IsActive = true,
            Family = 'Options'
        );
        insert optionProduct;
        
        // Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create Pricebook Entries with required fields
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product1.Id,
            UnitPrice = 1000,
            IsActive = true,
            CurrencyIsoCode = 'INR',
            Base_Price__c = 800,
            List_Price__c = 1000,
            D1__c = 0.1,
            D2__c = 0.2,
            D3__c = 0.3
        );
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product2.Id,
            UnitPrice = 2000,
            IsActive = true,
            CurrencyIsoCode = 'INR',
            Base_Price__c = 1600,
            List_Price__c = 2000,
            D1__c = 0.1,
            D2__c = 0.2,
            D3__c = 0.3
        );
        insert pbe2;
        
        PricebookEntry pbeOption = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = optionProduct.Id,
            UnitPrice = 500,
            IsActive = true,
            CurrencyIsoCode = 'INR',
            Base_Price__c = 400,
            List_Price__c = 500,
            D1__c = 0.1,
            D2__c = 0.2,
            D3__c = 0.3
        );
        insert pbeOption;
        
        // Create Quote Line Items
        Quote_Line_Item_Custom__c lineItem1 = new Quote_Line_Item_Custom__c(
            Quote__c = quote.Id,
            Product__c = product1.Id,
            Sr_No__c = 1,
            Product_Name__c = 'Test Product 1',
            Is_Manual__c = false,
            Quantity__c = 2,
            Base_Price__c = 800,
            List_Price__c = 1000,
            Discount_Allowed_New__c = 15,
            Discount__c = 10,
            CurrencyIsoCode = 'INR'
        );
        insert lineItem1;
        
        Quote_Line_Item_Custom__c lineItem2 = new Quote_Line_Item_Custom__c(
            Quote__c = quote.Id,
            Product__c = product2.Id,
            Sr_No__c = 2,
            Product_Name__c = 'Test Product 2',
            Is_Manual__c = false,
            Quantity__c = 1,
            Base_Price__c = 1600,
            List_Price__c = 2000,
            Discount_Allowed_New__c = 20,
            Discount_in_Value__c = 300,
            CurrencyIsoCode = 'INR'
        );
        insert lineItem2;
        
        // Create Quote Options
        Quote_Line_Options__c option1 = new Quote_Line_Options__c(
            Quote__c = quote.Id,
            Quote_Line_Item_Custom__c = lineItem1.Id,
            Product__c = optionProduct.Id,
            Option_No__c = 001,
            Serial_Number__c = 1,
            Manual_Product_Name__c = 'Test Option',
            Quantity__c = 2,
            Manual_Option_Base_Price__c = 400,
            Manula_Option_List_Price__c = 500,
            Discount__c = 5,
            Discount_Allowed_New__c = 10,
            CurrencyIsoCode = 'INR'
        );
        insert option1;
        
        Quote_Line_Options__c option2 = new Quote_Line_Options__c(
            Quote__c = quote.Id,
            Quote_Line_Item_Custom__c = lineItem1.Id,
            Product__c = optionProduct.Id,
            Option_No__c = 002,
            Serial_Number__c = 2,
            Manual_Product_Name__c = 'Test Option 2',
            Quantity__c = 1,
            Manual_Option_Base_Price__c = 400,
            Manula_Option_List_Price__c = 500,
            Discount_in_Value__c = 50,
            Discount_Allowed_New__c = 10,
            CurrencyIsoCode = 'INR'
        );
        insert option2;
    }
    
    @isTest
    static void testAllQuoteLineControllerMethods() {
        // Get test data
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        Fiscal_Year_Master__c fiscalYear = [SELECT Id FROM Fiscal_Year_Master__c LIMIT 1];
        Subsidiari_Master__c subsidiary = [SELECT Id FROM Subsidiari_Master__c LIMIT 1];
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Quote_Template__c quoteTemplate = [SELECT Id FROM Quote_Template__c LIMIT 1];
        
        Test.startTest();
        
        // 1. Test getQuoteLineData with valid quote
        Map<String, Object> result1 = QuoteLineController.getQuoteLineData(testQuote.Id);
        
        // 2. Test getQuoteLineData with quote having no line items
        Quote emptyQuote = new Quote(
            Name = 'Empty Quote',
            OpportunityId = opportunity.Id,
            CurrencyIsoCode = 'INR',
            Status = 'CREATED',
            Fiscal_Year_Master__c = fiscalYear.Id,
            Subsidiary__c = subsidiary.Id,
            Quote_Number1__c = 'QASI2025-99999',
            Language__c = 'EN',
            Quote_Template__c = quoteTemplate.Id,
            Exchange_Rate__c = 1
        );
        insert emptyQuote;
        
        Map<String, Object> result2 = QuoteLineController.getQuoteLineData(emptyQuote.Id);
        
        // 3. Test saveQuoteLineData with valid updates
        List<Quote_Line_Item_Custom__c> lineItems = [
            SELECT Id, Sr_No__c, Product_Name__c, Base_Price__c, Quantity__c, 
                   Total_Global_Price_Item__c, List_Price__c, Total_List_Price2__c,
                   Discount_Allowed_New__c, Discount__c, Discount_in_Value__c,
                   Desired_Price__c, Desired_Price_Subtotal__c, Discount_Value__c,
                   Average_Sales_Price__c, Sales_Price__c, Sales_Margin__c, 
                   Quote__r.Sales_Margin__c, Quote__r.Quote_Total_Base_Price__c, 
                   Quote__r.Quote_Total_List_Price__c, Quote__r.Quote_Total_Discount_Value__c, 
                   Quote__r.Quote_Totoal__c, Quote__r.Quote_Number__c, Quote__r.CurrencyIsoCode,
                   Total_List_Price__c, Total_Base_Price_including_Options__c,
                   Total_Discount_Value_including_options__c, 
                   Total_Sales_Price_including_Options__c,
                   Sales_Margin_including_Options__c
            FROM Quote_Line_Item_Custom__c
            WHERE Quote__c = :testQuote.Id
        ];
        
        List<Quote_Line_Options__c> options = [
            SELECT Id, Option_No__c, Serial_Number__c, Manual_Product_Name__c, Quantity__c,
                   Base_price_Total__c, Manula_Option_List_Price__c, Manual_Option_Base_Price__c,
                   List_Price_Total2__c, Discount__c, Discount_in_Value__c,
                   Desired_Price__c, Discount_Allowed_New__c, Discount_Value__c,
                   Average_Sales_Price__c, Sales_Price__c, Sales_Margin__c,
                   Total_List_Price__c, Discount_Amount__c, Total_Quantity__c, 
                   Unit_Sales_Price__c, Total_Sales_Price__c, Total_Transfer_Price__c
            FROM Quote_Line_Options__c
            WHERE Quote__c = :testQuote.Id
        ];
        
        // Update values
        for(Quote_Line_Item_Custom__c item : lineItems) {
            item.Discount__c = 15;
            item.Desired_Price__c = 900;
        }
        
        for(Quote_Line_Options__c opt : options) {
            opt.Discount__c = 8;
            opt.Desired_Price__c = 480;
        }
        
        String lineItemsJson = JSON.serialize(lineItems);
        String optionsJson = JSON.serialize(options);
        
        Map<String, Object> result3 = QuoteLineController.saveQuoteLineData(lineItemsJson, optionsJson);
        
        // 4. Test saveQuoteLineData with invalid JSON (exception scenario)
        Map<String, Object> result4 = QuoteLineController.saveQuoteLineData('invalid json', 'invalid json');
        
        // 5. Test saveQuoteLineData with empty lists
        List<Quote_Line_Item_Custom__c> emptyLineItems = new List<Quote_Line_Item_Custom__c>();
        List<Quote_Line_Options__c> emptyOptions = new List<Quote_Line_Options__c>();
        
        String emptyLineItemsJson = JSON.serialize(emptyLineItems);
        String emptyOptionsJson = JSON.serialize(emptyOptions);
        
        Map<String, Object> result5 = QuoteLineController.saveQuoteLineData(emptyLineItemsJson, emptyOptionsJson);
        
        // 6. Test getQuoteLineData with invalid ID (exception scenario)
        try {
            Map<String, Object> result6 = QuoteLineController.getQuoteLineData(null);
        } catch (Exception e) {
            // Exception expected
        }
        
        Test.stopTest();
    }
}
