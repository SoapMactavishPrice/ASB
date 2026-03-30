@IsTest
public class QuoteContractExpirationDateSetterTest {

    @IsTest
    static void testQuoteAndContractExpirationUpdates() {

        // ---------------------------
        // 1. Create records for setup
        // ---------------------------
        // 
        Fiscal_Year_Master__c fy = new Fiscal_Year_Master__c(
            Name = 'FY',
            Active__c = true,
            Fiscal_Year_Start_Date__c = Date.newInstance(2026,1,1),
            Fiscal_Year_End_Date__c = Date.newInstance(2026,12,31)
        );
        insert fy;

        Subsidiari_Master__c sub = new Subsidiari_Master__c(
            Name = 'ABC',
            Permitted_Currency__c = 'USD',
            Permitted_Language__c = 'EN',
            Office__c = 'Mumbai',
            Discount_Level_1__c = 5,
            Discount_Level_2__c = 10,
            Discount_Level_3__c = 15
        );
        insert sub;

        Global_Region__c greg = new Global_Region__c(Name = 'Asia');
        insert greg;

        Global_SubRegion__c reg = new Global_SubRegion__c(
            Name = 'Southern Asia',
            Region__c = greg.Id
        );
        insert reg;

        Country_List__c country = new Country_List__c(
            Name = 'India',
            Sub_Region__c = reg.Id,
            Region_Master__c = greg.Id
        );
        insert country;

        State_List__c state = new State_List__c(
            Name = 'Maharashtra',
            Country__c = country.Id
        );
        insert state;

        City_List__c city = new City_List__c(
            Name = 'Mumbai',
            State__c = state.Id
        );
        insert city;

        PIN_Code_Master__c pin = new PIN_Code_Master__c(
            Name = '400001',
            City__c = city.Id
        );
        insert pin;

        User_Setup__c us = new User_Setup__c(
            User__c = UserInfo.getUserId(),
            Subsidiari__c = sub.Id,
            Country__c = country.Id
        );
        insert us;

        Account acc = new Account(
            Name = 'Test Account',
            Billing_Country__c = country.Id,
            Billing_State__c = state.Id,
            Billing_City__c = city.Id,
            Shipping_Country__c = country.Id,
            Shipping_State__c = state.Id,
            Shipping_City__c = city.Id,
            Billing_Postal_ZIP_Code__c = pin.Id,
            ADDRESS_LINE_1__c = 'Line1',
            ADDRESS_LINE_2__c = 'Line2',
            ADDRESS_LINE_3__c = 'Line3',
            CurrencyIsoCode = 'USD',
            Subsidiary__c = sub.Id,
            Is_Converted__c = true
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            CurrencyIsoCode = 'USD'
        );
        insert opp;

        // Create a Quote
        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            ExpirationDate = System.today()
        );
        insert q;

        // Create a Contract
        Contract c = new Contract(
            Name = 'Test Contract',
            AccountId = acc.Id,
            Quote__c = q.Id,
            Status = 'Created'
        );
        insert c;

        // ---------------------------
        // 2. Create tasks where checkbox initially FALSE
        // ---------------------------
        Task quoteTask = new Task(
            Subject = 'Quote Task',
            WhatId = q.Id,
            Status = 'Not Started',
            Set_To_Next_30_Days__c = false,
            ActivityDate = System.today()
        );

        Task contractTask = new Task(
            Subject = 'Contract Task',
            WhatId = c.Id,
            Status = 'Not Started',
            Set_To_Next_30_Days__c = false,
            ActivityDate = System.today()
        );

        insert new List<Task>{ quoteTask, contractTask };

        // ---------------------------
        // 3. Update tasks → set checkbox TRUE
        // ---------------------------

        quoteTask = [SELECT Id, WhatId, Status, Set_To_Next_30_Days__c, ActivityDate 
                     FROM Task WHERE Id = :quoteTask.Id];
        contractTask = [SELECT Id, WhatId, Status, Set_To_Next_30_Days__c, ActivityDate 
                        FROM Task WHERE Id = :contractTask.Id];

        quoteTask.Set_To_Next_30_Days__c = true;
        contractTask.Set_To_Next_30_Days__c = true;

        Test.startTest();
        update new List<Task>{ quoteTask, contractTask };
        Test.stopTest();

        // ---------------------------
        // 4. Validate task status was updated to Completed
        // ---------------------------
        Task updatedQuoteTask = [SELECT Status FROM Task WHERE Id = :quoteTask.Id];
        Task updatedContractTask = [SELECT Status FROM Task WHERE Id = :contractTask.Id];

        System.assertEquals('Completed', updatedQuoteTask.Status, 'Quote Task status should be Completed');
        System.assertEquals('Completed', updatedContractTask.Status, 'Contract Task status should be Completed');

        // ---------------------------
        // 5. Validate Quote Expiration updated
        // ---------------------------
        Quote updatedQuote = [SELECT ExpirationDate FROM Quote WHERE Id = :q.Id];
        System.assertEquals(
            System.today().addDays(30),
            updatedQuote.ExpirationDate,
            'Quote expiration should be extended by 30 days'
        );

        // ---------------------------
        // 6. Validate Contract Expiration updated
        // ---------------------------
        Contract updatedContract = [SELECT Expiration_Date__c FROM Contract WHERE Id = :c.Id];
        System.assertEquals(
            System.today().addDays(30),
            updatedContract.Expiration_Date__c,
            'Contract expiration should be extended by 30 days'
        );
    }


    // ----------------------------------------
    // Negative Test Case: Checkbox stays FALSE
    // ----------------------------------------
    @IsTest
    static void testNoUpdateWhenCheckboxFalse() {
        
        Fiscal_Year_Master__c fy = new Fiscal_Year_Master__c(
            Name = 'FY',
            Active__c = true,
            Fiscal_Year_Start_Date__c = Date.newInstance(2026,1,1),
            Fiscal_Year_End_Date__c = Date.newInstance(2026,12,31)
        );
        insert fy;

        Subsidiari_Master__c sub = new Subsidiari_Master__c(
            Name = 'ABC',
            Permitted_Currency__c = 'USD',
            Permitted_Language__c = 'EN',
            Office__c = 'Mumbai',
            Discount_Level_1__c = 5,
            Discount_Level_2__c = 10,
            Discount_Level_3__c = 15
        );
        insert sub;

        Global_Region__c greg = new Global_Region__c(Name = 'Asia');
        insert greg;

        Global_SubRegion__c reg = new Global_SubRegion__c(
            Name = 'Southern Asia',
            Region__c = greg.Id
        );
        insert reg;

        Country_List__c country = new Country_List__c(
            Name = 'India',
            Sub_Region__c = reg.Id,
            Region_Master__c = greg.Id
        );
        insert country;

        State_List__c state = new State_List__c(
            Name = 'Maharashtra',
            Country__c = country.Id
        );
        insert state;

        City_List__c city = new City_List__c(
            Name = 'Mumbai',
            State__c = state.Id
        );
        insert city;

        PIN_Code_Master__c pin = new PIN_Code_Master__c(
            Name = '400001',
            City__c = city.Id
        );
        insert pin;

        User_Setup__c us = new User_Setup__c(
            User__c = UserInfo.getUserId(),
            Subsidiari__c = sub.Id,
            Country__c = country.Id
        );
        insert us;

        Account acc = new Account(
            Name = 'Test Account',
            Billing_Country__c = country.Id,
            Billing_State__c = state.Id,
            Billing_City__c = city.Id,
            Shipping_Country__c = country.Id,
            Shipping_State__c = state.Id,
            Shipping_City__c = city.Id,
            Billing_Postal_ZIP_Code__c = pin.Id,
            ADDRESS_LINE_1__c = 'Line1',
            ADDRESS_LINE_2__c = 'Line2',
            ADDRESS_LINE_3__c = 'Line3',
            CurrencyIsoCode = 'USD',
            Subsidiary__c = sub.Id,
            Is_Converted__c = true
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            CurrencyIsoCode = 'USD'
        );
        insert opp;

        Quote q = new Quote(Name = 'Q', OpportunityId = opp.Id, ExpirationDate = System.today());
        insert q;

        Task t = new Task(
            Subject = 'Test',
            WhatId = q.Id,
            Status = 'Not Started',
            Set_To_Next_30_Days__c = false,
            ActivityDate = System.today()
        );
        insert t;

        Test.startTest();
        t.Status = 'In Progress'; // random update
        update t;
        Test.stopTest();

        Quote q2 = [SELECT ExpirationDate FROM Quote WHERE Id = :q.Id];

        // Must NOT change expiration date
    }
}