@isTest
public class QuoteCreationCMPController_test {

    public static testMethod void validateTestMethod1(){
        
        Fiscal_Year_Master__c f = new Fiscal_Year_Master__c();
        f.Active__c = true;
        f.Fiscal_Year_Start_Date__c = system.today() - 65;
        f.Fiscal_Year_End_Date__c = system.today() + 300;
        f.Name = 'NPL';
        insert f;
        
        // Using 'ASI' which is a valid picklist value (options: ASI, COM, EUR)
        Subsidiari_Master__c s = new Subsidiari_Master__c();
        s.Name = 'ASI'; // Valid picklist value
        s.Name__c = 'xyg'; // This field is required
        s.Active__c = true;
        s.Office__c = 'Airforce';
        s.Rounding_Off_Digits__c = '10000';
        s.Permitted_Currency__c = 'INR';
        s.Permitted_Language__c = 'EN';
        s.Discount_Level_1__c = 5;  // Must be less than Level 2
        s.Discount_Level_2__c = 10; // Must be greater than Level 1 and less than Level 3
        s.Discount_Level_3__c = 15; // Must be greater than Level 2
        s.Quote_Approval__c = 'Line Item level';
        s.Contract_Approval__c = 'Line Item level';
        s.Permitted_Language__c = 'HI';
        s.Price_Book__c = null; // Will be set after Pricebook2 creation
        insert s;
        
        // Create Pricebook2 for testing
        Pricebook2 testPricebook = new Pricebook2(
            Name = 'Test Price Book',
            IsActive = true,
            Subsidiary__c = s.Id
        );
        insert testPricebook;
        
        // Update Subsidiary with Pricebook
        s.Price_Book__c = testPricebook.Id;
        update s;
        
        // Create Unique_No__c for Quote numbering
        Unique_No__c uniqueNo = new Unique_No__c();
        uniqueNo.Object_Name__c = 'Quote';
        uniqueNo.Subsidiary__c = s.Id;
        uniqueNo.Fiscal_Year__c = f.Id;
        uniqueNo.Serial_No__c = 1;
        insert uniqueNo;
        
        Country_List__c c = new Country_List__c();
        c.Active__c = true;
        c.Name = 'India';	
        c.Subsidiary__c = s.Id;
        insert c;
        
        Region__c re = new Region__c();
        re.Active__c = true;
        re.Country__c = c.Id;
        re.Name = 'EAST';
        re.Name__c = 'EAST';
        insert re;
        
        User_Setup__c u = new User_Setup__c();
        u.Country__c = c.Id;
        u.User__c = UserInfo.getUserId();
        u.Subsidiari__c = s.Id;
        u.Region__c = re.Id;
        u.Default_Language__c = 'HI';
        insert u;
        
        Assign_Region__c ar = new Assign_Region__c();
        ar.User_Setup__c = u.Id;
        ar.Country__c = c.Id;
        ar.Region__c = re.Id;
        insert ar;
        
        Campaign camObject = new Campaign(Name = 'Cam1', CurrencyIsoCode = 'INR');
        insert camObject;
        
        Account accObject = new Account(CurrencyIsoCode = 'INR', Name = 'Test1', Region1__c = re.Id);
        insert accObject;
        
        Contact con = new Contact();
        con.LastName = 'lname';
        con.AccountId = accObject.Id;
        con.Title = 'dev';
        con.Email = 'vd@gmail.com';
        insert con;

        Opportunity oppObject = new Opportunity(
            AccountId = accObject.Id,  
            Name = 'Opp1',
            Contact__c = con.Id, 
            CurrencyIsoCode = 'INR', 
            StageName = 'New', 
            CloseDate = System.today(),
            Subsidiary__c = s.Id
        );
        insert oppObject;
        
        Product2 proObject = new Product2(
            CurrencyIsoCode = 'INR', 
            Name = 'Pro1', 
            IsActive = TRUE
        );
        insert proObject;
        
        Pricebook2 priObject = new Pricebook2(Name = 'Pri1');
        insert priObject;
        
        Product2 prod = new Product2(
            Name = 'Laptop X200', 
            Family = 'Options'
        );
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = proObject.Id,
            UnitPrice = 10000, 
            UseStandardPrice = false,
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
            Rounding_Off_Digits__c = '10'
        );
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(
            Name = 'Standard Price Book', 
            IsActive = true
        );
        insert customPB;
        
        QuoteRecursionCheck.isfirsttime = false;
        
        Quote qObject = new Quote(
            Name = 'Q1', 
            Exchange_Rate__c = 1, 
            OpportunityId = oppObject.Id
        );
        insert qObject;
        
        Quote_Template__c qt = new Quote_Template__c();
        qt.Label__c = 'test';
        qt.Subsidiary__c = s.Id;
        qt.Language__c = 'HI';
        qt.Active__c = true;
        insert qt;

        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c(
            Quote__c = qObject.Id, 
            Product__c = proObject.Id,
            Is_Manual__c = false, 
            UOM__c = 'Test UOM', 
            Product_Description__c = 'Test Data', 
            Model__c = 'Test Model', 
            Division__c = 'MACHINE', 
            Product_Type__c = 'MC',
            Scope_of_mould__c = 'Test Scope', 
            Cavity__c = 12.00, 
            List_Price__c = 10,
            Product_Name__c = 'ASB12M COMPLETE MOLD_2CAVITY',
            Level_Of_Ceiling__c = '10',
            Quantity__c = 4, 
            Base_Price__c = 1, 
            Discount__c = 20,
            Approved_Discount__c = 10,
            Discount_Approval_Note__c = 'Approval Test'
        );
        insert qli;
        
        Quote_Line_Item_Custom__c qli1 = new Quote_Line_Item_Custom__c(
            Quote__c = qObject.Id, 
            Product__c = proObject.Id,
            Is_Manual__c = true,  
            UOM__c = 'Test UOM', 
            Product_Description__c = 'Test Data',
            Model__c = 'Test Model', 
            Division__c = 'MACHINE', 
            Product_Type__c = 'MC',
            Scope_of_mould__c = 'Test Scope', 
            Cavity__c = 12.00, 
            List_Price__c = 10,
            Level_Of_Ceiling__c = '10',
            Product_Name__c = 'ASB12M COMPLETE MOLD_2CAVITY',
            Quantity__c = 4, 
            Base_Price__c = 1, 
            Discount__c = 20,
            Approved_Discount__c = 5,
            Discount_Approval_Note__c = 'Approval Test'
        );
        insert qli1;
        
        Quote_Line_Options__c Qlioptions = new Quote_Line_Options__c(
            Quote__c = qObject.Id, 
            Quote_Line_Item_Custom__c = qli1.Id,
            Manual_Product_Name__c = 'Manual testing', 
            Product__c = proObject.Id, 
            Select_Option__c = true,
            Discount__c = 3.00, 
            Description__c = 'Test Option', 
            Discount_Description__c = 'Another test',
            Quantity__c = 4, 
            Manula_Option_List_Price__c = 123456.98,
            Manual_Option_Base_Price__c = 5465767.87, 
            Manual_Option__c = 'False',
            Option_Number__c = 'Test-3',
            Mould_Cavity__c = 21, 
            Price_Type__c = 1, 
            Manual_Option_Function__c = 'Add',
            Other_Charges__c = 'NA', 
            Other_Charges_Base_Price__c = 123458.88,
            Other_Charges_Function__c = 'Add'
        );
        insert Qlioptions;
        
        Quote_Line_Options__c Qlioptions2 = new Quote_Line_Options__c(
            Quote__c = qObject.Id, 
            Quote_Line_Item_Custom__c = qli.Id,
            Manual_Product_Name__c = 'Manual testing', 
            Product__c = proObject.Id, 
            Select_Option__c = false,
            Discount__c = 3.00, 
            Description__c = 'Test Option', 
            Discount_Description__c = 'Another test',
            Quantity__c = 4, 
            Manula_Option_List_Price__c = 123456.98,
            Manual_Option_Base_Price__c = 5465767.87, 
            Manual_Option__c = 'False',
            Option_Number__c = 'Test-3',
            Mould_Cavity__c = 21, 
            Price_Type__c = 1, 
            Manual_Option_Function__c = 'Add',
            Other_Charges__c = 'NA', 
            Other_Charges_Base_Price__c = 123458.88,
            Other_Charges_Function__c = 'Add'
        );
        insert Qlioptions2;
        
        Quote qObject2 = new Quote(
            Name = 'New Quo1', 
            Exchange_Rate__c = 1, 
            OpportunityId = oppObject.Id
        );
        insert qObject2;
        
        Quote_Line_Item_Custom__c qli2 = new Quote_Line_Item_Custom__c(
            Quote__c = qObject2.Id, 
            Product__c = proObject.Id,
            Is_Manual__c = True,  
            UOM__c = 'Test', 
            Product_Description__c = 'Test Data',
            Model__c = 'Test Model', 
            Division__c = 'MACHINE', 
            Product_Type__c = 'MC',
            Scope_of_mould__c = 'Test Scope', 
            Cavity__c = 12.00, 
            List_Price__c = 10,
            Product_Name__c = 'ASB12M COMPLETE MOLD_2CAVITY',
            Quantity__c = 4, 
            Base_Price__c = 1, 
            Discount__c = 20,
            Approved_Discount__c = 5,
            Discount_Approval_Note__c = 'Approval Test'
        );
        insert qli2;
        
        String rec = String.valueOf(oppObject.Id);
        String cRate = String.valueOf(qObject2.Exchange_Rate__c);
        String aMargin = '10.654';
        Quote QuoteClone = qObject.clone(false, false, false, false);
        
        Test.startTest();
        
        // Test IntialDataFetch
        QuoteCreationCMPController.IntialDataFetch(oppObject.Id);
        
        // Test CheckQuoteTemplate
        QuoteCreationCMPController.CheckQuoteTemplate();
        
        ApexPages.currentPage().getParameters().put('Id', qObject2.Id);
        
        // Test createBlankQuoteController
        String quoteId = QuoteCreationCMPController.createBlankQuoteController(
            qObject.Name, 
            oppObject.Id, 
            'INR', 
            cRate, 
            aMargin, 
            String.valueOf(pricebookId)
        );
        System.assertNotEquals(null, quoteId, 'Quote creation failed');
        
        // Test cloneExistingQuote (without blankDiscountValues parameter)
        Map<String, Object> cloneResult = QuoteCreationCMPController.cloneExistingQuote(
            qObject.Id, 
            qObject2.Name, 
            'INR', 
            rec, 
            cRate, 
            aMargin, 
            accObject.Id, 
            accObject.Id, 
            String.valueOf(pricebookId)
        );
        System.assertNotEquals(null, cloneResult, 'Quote cloning failed');
        
        // Test getPickListValuesIntoList
        List<String> picklistValues = QuoteCreationCMPController.getPickListValuesIntoList();
        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null');
        
        // Test getSubsidaryDefaultPriceBook
        String defaultPriceBook = QuoteCreationCMPController.getSubsidaryDefaultPriceBook(oppObject.Id);
        System.assertEquals(testPricebook.Id, defaultPriceBook, 'Default price book should match');
        
        // Test getPricebooks
        List<Map<String, String>> pricebooks = QuoteCreationCMPController.getPricebooks(oppObject.Id);
        System.assertNotEquals(null, pricebooks, 'Pricebooks list should not be null');
        System.assert(pricebooks.size() > 0, 'Should have at least one pricebook');
        
        // Test importQuoteFromCSV
        Boolean importResult = QuoteCreationCMPController.importQuoteFromCSV('str', oppObject.Id);
        
        Test.stopTest();
    }
    
    // Test method for the overloaded cloneExistingQuote with blankDiscountValues
    public static testMethod void testCloneWithBlankDiscountValues() {
        // Setup code
        Fiscal_Year_Master__c f = new Fiscal_Year_Master__c();
        f.Active__c = true;
        f.Fiscal_Year_Start_Date__c = system.today() - 65;
        f.Fiscal_Year_End_Date__c = system.today() + 300;
        f.Name = 'NPL';
        insert f;
        
        // Using 'ASI' (valid picklist value)
        Subsidiari_Master__c s = new Subsidiari_Master__c();
        s.Name = 'ASI'; // Valid value from picklist
        s.Name__c = 'xyg'; // Required field
        s.Active__c = true;
        s.Office__c = 'Airforce';
        s.Rounding_Off_Digits__c = '10000';
        s.Permitted_Currency__c = 'INR';
        s.Permitted_Language__c = 'EN';
        s.Discount_Level_1__c = 5;  // Level 1
        s.Discount_Level_2__c = 10; // Level 2 > Level 1
        s.Discount_Level_3__c = 15; // Level 3 > Level 2
        s.Quote_Approval__c = 'Line Item level';
        s.Contract_Approval__c = 'Line Item level';
        s.Price_Book__c = null;
        insert s;
        
        // Create Pricebook2 for testing
        Pricebook2 testPricebook = new Pricebook2(
            Name = 'Test Price Book',
            IsActive = true,
            Subsidiary__c = s.Id
        );
        insert testPricebook;
        
        Unique_No__c uniqueNo = new Unique_No__c();
        uniqueNo.Object_Name__c = 'Quote';
        uniqueNo.Subsidiary__c = s.Id;
        uniqueNo.Fiscal_Year__c = f.Id;
        uniqueNo.Serial_No__c = 1;
        insert uniqueNo;
        
        Country_List__c c = new Country_List__c();
        c.Active__c = true;
        c.Name = 'India';	
        c.Subsidiary__c = s.Id;
        insert c;
        
        Region__c re = new Region__c();
        re.Active__c = true;
        re.Country__c = c.Id;
        re.Name = 'EAST';
        re.Name__c = 'EAST';
        insert re;
        
        User_Setup__c u = new User_Setup__c();
        u.Country__c = c.Id;
        u.User__c = UserInfo.getUserId();
        u.Subsidiari__c = s.Id;
        u.Region__c = re.Id;
        u.Default_Language__c = 'HI';
        insert u;
        
        Quote_Template__c qt = new Quote_Template__c();
        qt.Label__c = 'test';
        qt.Subsidiary__c = s.Id;
        qt.Language__c = 'HI';
        qt.Active__c = true;
        insert qt;
        
        Account accObject = new Account(CurrencyIsoCode = 'INR', Name = 'Test1', Region1__c = re.Id);
        insert accObject;
        
        Contact con = new Contact();
        con.LastName = 'lname';
        con.AccountId = accObject.Id;
        con.Email = 'vd@gmail.com';
        insert con;
        
        Opportunity oppObject = new Opportunity(
            AccountId = accObject.Id,  
            Name = 'Opp1',
            Contact__c = con.Id, 
            CurrencyIsoCode = 'INR', 
            StageName = 'New', 
            CloseDate = System.today(),
            Subsidiary__c = s.Id
        );
        insert oppObject;
        
        // Create a source quote with line items that have discount values
        Quote sourceQuote = new Quote(
            Name = 'Source Quote with Discounts',
            OpportunityId = oppObject.Id,
            CurrencyIsoCode = 'INR',
            Status = 'CREATED',
            Exchange_Rate__c = 1,
            Fiscal_Year_Master__c = f.Id,
            Subsidiary__c = s.Id,
            Quote_Number1__c = 'QASI2024-00001',
            Language__c = 'HI',
            Quote_Template__c = qt.Id
        );
        insert sourceQuote;
        
        // Create a product for line items
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            CurrencyIsoCode = 'INR',
            IsActive = true,
            Family = 'Items'
        );
        insert testProduct;
        
        // Create PricebookEntry with required D1__c, D2__c, D3__c fields (must be > 0)
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 1000,
            IsActive = true,
            CurrencyIsoCode = 'INR',
            Base_Price__c = 800,
            List_Price__c = 1000,
            D1__c = 0.1, 
            D2__c = 0.2,  
            D3__c = 0.3 
        );
        insert pbe;
        
        // Create Quote Line Items with discount values to test blankDiscountValues
        Quote_Line_Item_Custom__c sourceQLI1 = new Quote_Line_Item_Custom__c(
            Quote__c = sourceQuote.Id,
            Product__c = testProduct.Id,
            Is_Manual__c = false,
            Quantity__c = 2,
            Base_Price__c = 800,
            List_Price__c = 1000,
            Discount__c = 10, // 10% discount
            Discount_Allowed_New__c = 15,
            Sr_No__c = 1
        );
        insert sourceQLI1;
        
        Quote_Line_Item_Custom__c sourceQLI2 = new Quote_Line_Item_Custom__c(
            Quote__c = sourceQuote.Id,
            Product__c = testProduct.Id,
            Is_Manual__c = true,
            Quantity__c = 3,
            Base_Price__c = 800,
            List_Price__c = 1000,
            Discount_in_Value__c = 500, // $500 discount
            Discount_Allowed_New__c = 10,
            Sr_No__c = 2
        );
        insert sourceQLI2;
        
        // Create Quote Options
        Quote_Line_Options__c sourceOption = new Quote_Line_Options__c(
            Quote__c = sourceQuote.Id,
            Quote_Line_Item_Custom__c = sourceQLI1.Id,
            Product__c = testProduct.Id,
            Select_Option__c = false,
            quantity__c = 1,
            Discount__c = 5,
            Manual_Option__c = 'False'
        );
        insert sourceOption;
        
        Test.startTest();
        
        // Test cloneExistingQuote with blankDiscountValues = true
        Map<String, Object> cloneResult = QuoteCreationCMPController.cloneExistingQuote(
            sourceQuote.Id, 
            'Cloned Quote with Blank Discounts', 
            'INR', 
            oppObject.Id, 
            '1.0', 
            '10.0', 
            accObject.Id, 
            accObject.Id, 
            String.valueOf(pricebookId),
            true // blankDiscountValues = true
        );
        
        System.assertNotEquals(null, cloneResult, 'Quote cloning with blank discount values failed');
        System.assert(cloneResult.containsKey('Id'), 'Result should contain the new Quote ID');
        
        // Verify the cloned quote was created
        String clonedQuoteId = (String)cloneResult.get('Id');
        Quote clonedQuote = [SELECT Id, Name FROM Quote WHERE Id = :clonedQuoteId];
        System.assertEquals('Cloned Quote with Blank Discounts', clonedQuote.Name);
        
        // Verify that line items have null discount values
        List<Quote_Line_Item_Custom__c> clonedLineItems = [
            SELECT Id, Discount__c, Discount_in_Value__c 
            FROM Quote_Line_Item_Custom__c 
            WHERE Quote__c = :clonedQuoteId
        ];
        
        for(Quote_Line_Item_Custom__c qli : clonedLineItems) {
            System.assertEquals(null, qli.Discount__c, 'Discount should be null');
            System.assertEquals(null, qli.Discount_in_Value__c, 'Discount in Value should be null');
        }
        
        // Test cloneExistingQuote with blankDiscountValues = false
        Map<String, Object> cloneResult2 = QuoteCreationCMPController.cloneExistingQuote(
            sourceQuote.Id, 
            'Cloned Quote with Discounts Preserved', 
            'INR', 
            oppObject.Id, 
            '1.0', 
            '10.0', 
            accObject.Id, 
            accObject.Id, 
            String.valueOf(pricebookId),
            false // blankDiscountValues = false
        );
        
        System.assertNotEquals(null, cloneResult2, 'Quote cloning with preserved discount values failed');
        
        String clonedQuoteId2 = (String)cloneResult2.get('Id');
        List<Quote_Line_Item_Custom__c> clonedLineItems2 = [
            SELECT Id, Discount__c, Discount_in_Value__c 
            FROM Quote_Line_Item_Custom__c 
            WHERE Quote__c = :clonedQuoteId2
        ];
        
        // Verify discounts were preserved (not null)
        Boolean foundNonZeroDiscount = false;
        for(Quote_Line_Item_Custom__c qli : clonedLineItems2) {
            if(qli.Discount__c != null || qli.Discount_in_Value__c != null) {
                foundNonZeroDiscount = true;
                break;
            }
        }
        System.assert(foundNonZeroDiscount, 'At least one line item should have a discount value');
        
        Test.stopTest();
    }
    
    // Separate test method for currency conversion
    public static testMethod void testCurrencyConversion() {
        Test.startTest();
        
        // Test valid currency conversion
        Decimal convertedAmount = QuoteCreationCMPController.convert(100, 'USD', 'EUR');
        System.assertNotEquals(null, convertedAmount);
        
        // Test with same currency
        Decimal sameCurrencyAmount = QuoteCreationCMPController.convert(100, 'USD', 'USD');
        System.assertEquals(100, sameCurrencyAmount);
        
        // Test with invalid currency - should throw exception
        try {
            QuoteCreationCMPController.convert(100, 'INVALID', 'USD');
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            System.assert(e instanceof IllegalArgumentException, 'Should throw IllegalArgumentException');
        }
        
        Test.stopTest();
    }
    
    // Test method for generateAutoNumber
    public static testMethod void testGenerateAutoNumber() {
        Test.startTest();
        
        // Test with i=1 (should return same QuoteNo)
        String quoteNo1 = 'QASI2024-00001';
        String result1 = QuoteCreationCMPController.generateAutoNumber(1, quoteNo1);
        System.assertEquals(quoteNo1, result1, 'When i=1, should return same QuoteNo');
        
        // Test with i=2 (should increment)
        String result2 = QuoteCreationCMPController.generateAutoNumber(2, quoteNo1);
        String expected2 = 'QASI2024-00002';
        System.assertEquals(expected2, result2, 'When i=2, should increment to 00002');
        
        // Test with i=3
        String result3 = QuoteCreationCMPController.generateAutoNumber(3, quoteNo1);
        String expected3 = 'QASI2024-00003';
        System.assertEquals(expected3, result3, 'When i=3, should increment to 00003');
        
        // Test with i=10
        String result10 = QuoteCreationCMPController.generateAutoNumber(10, quoteNo1);
        String expected10 = 'QASI2024-00010';
        System.assertEquals(expected10, result10, 'When i=10, should increment to 00010');
        
        // Test with i=100
        String result100 = QuoteCreationCMPController.generateAutoNumber(100, quoteNo1);
        String expected100 = 'QASI2024-00100';
        System.assertEquals(expected100, result100, 'When i=100, should increment to 00100');
        
        // Test with i=1000
        String result1000 = QuoteCreationCMPController.generateAutoNumber(1000, quoteNo1);
        String expected1000 = 'QASI2024-01000';
        System.assertEquals(expected1000, result1000, 'When i=1000, should increment to 01000');
        
        // Test with i=10000 (should handle 5 digits)
        String result10000 = QuoteCreationCMPController.generateAutoNumber(10000, quoteNo1);
        String expected10000 = 'QASI2024-10000';
        System.assertEquals(expected10000, result10000, 'When i=10000, should increment to 10000');
        
        // Test with different base QuoteNo format
        String quoteNo2 = 'QCOM2025-00123';
        String resultWithBase2 = QuoteCreationCMPController.generateAutoNumber(5, quoteNo2);
        String expectedWithBase2 = 'QCOM2025-00127'; // 123 + (5-1) = 127
        System.assertEquals(expectedWithBase2, resultWithBase2, 'Should increment from 00123 to 00127');
        
        // Test with i causing rollover to next digit length
        String quoteNo3 = 'QEUR2026-00999';
        String resultRollover = QuoteCreationCMPController.generateAutoNumber(2, quoteNo3);
        String expectedRollover = 'QEUR2026-01000'; // 999 + 1 = 1000 -> 01000
        System.assertEquals(expectedRollover, resultRollover, 'Should handle rollover from 00999 to 01000');
        
        Test.stopTest();
    }
    
    // Test method for edge cases
    public static testMethod void testEdgeCases() {
        // Setup minimal required data
        Fiscal_Year_Master__c f = new Fiscal_Year_Master__c();
        f.Active__c = true;
        f.Fiscal_Year_Start_Date__c = system.today() - 65;
        f.Fiscal_Year_End_Date__c = system.today() + 300;
        f.Name = 'NPL';
        insert f;
        
        Subsidiari_Master__c s = new Subsidiari_Master__c();
        s.Name = 'ASI';
        s.Name__c = 'xyg'; // Required field
        s.Active__c = true;
        s.Office__c = 'Airforce';
        s.Rounding_Off_Digits__c = '10000';
        s.Permitted_Currency__c = 'INR';
        s.Permitted_Language__c = 'EN';
        // Proper discount levels that satisfy validation
        s.Discount_Level_1__c = 5;  // Level 1
        s.Discount_Level_2__c = 10; // Level 2 > Level 1
        s.Discount_Level_3__c = 15; // Level 3 > Level 2
        s.Quote_Approval__c = 'Line Item level';
        s.Contract_Approval__c = 'Line Item level';
        insert s;
        
        Country_List__c c = new Country_List__c();
        c.Active__c = true;
        c.Name = 'India';	
        c.Subsidiary__c = s.Id;
        insert c;
        
        Region__c re = new Region__c();
        re.Active__c = true;
        re.Country__c = c.Id;
        re.Name = 'EAST';
        re.Name__c = 'EAST';
        insert re;
        
        User_Setup__c u = new User_Setup__c();
        u.Country__c = c.Id;
        u.User__c = UserInfo.getUserId();
        u.Subsidiari__c = s.Id;
        u.Region__c = re.Id;
        u.Default_Language__c = 'HI';
        insert u;
        
        Account accObject = new Account(CurrencyIsoCode = 'INR', Name = 'Test1');
        insert accObject;
        
        Contact con = new Contact();
        con.LastName = 'lname';
        con.AccountId = accObject.Id;
        con.Email = 'vd@gmail.com';
        insert con;
        
        Opportunity oppObject = new Opportunity(
            AccountId = accObject.Id,  
            Name = 'Opp1',
            Contact__c = con.Id, 
            CurrencyIsoCode = 'INR', 
            StageName = 'New', 
            CloseDate = System.today(),
            Subsidiary__c = s.Id
        );
        insert oppObject;
        
        Test.startTest();
        
        // Test getSubsidaryDefaultPriceBook when no pricebook exists
        String defaultPriceBook = QuoteCreationCMPController.getSubsidaryDefaultPriceBook(oppObject.Id);
        System.assertEquals(null, defaultPriceBook, 'Should return null when no pricebook');
        
        // Test getPricebooks
        List<Map<String, String>> pricebooks = QuoteCreationCMPController.getPricebooks(oppObject.Id);
        System.assertNotEquals(null, pricebooks);
        
        Test.stopTest();
    }
}
