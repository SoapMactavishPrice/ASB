@IsTest
private class ContractExpirationScheduler_Test {

    @TestSetup
    static void setupData() {
        // Create only essential records needed for the triggers
        
        // Create Fiscal Year
        Fiscal_Year_Master__c fy = new Fiscal_Year_Master__c(
            Name = 'FY',
            Active__c = true,
            Fiscal_Year_Start_Date__c = Date.today().addDays(-10),
            Fiscal_Year_End_Date__c = Date.today().addDays(10)
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

        Global_Region__c greg = new Global_Region__c(Name='Asia');
        insert greg;

        Global_SubRegion__c reg = new Global_SubRegion__c(
            Name='Southern Asia',
            Region__c=greg.Id
        );
        insert reg;

        Country_List__c country = new Country_List__c(
            Name='India',
            Sub_Region__c=reg.Id,
            Region_Master__c=greg.Id
        );
        insert country;

        State_List__c state = new State_List__c(
            Name='Maharashtra',
            Country__c=country.Id
        );
        insert state;

        City_List__c city = new City_List__c(
            Name='Mumbai',
            State__c=state.Id
        );
        insert city;

        PIN_Code_Master__c pin = new PIN_Code_Master__c(
            Name='400001',
            City__c=city.Id
        );
        insert pin;

        User_Setup__c us = new User_Setup__c(
            User__c=UserInfo.getUserId(),
            Subsidiari__c=sub.Id,
            Country__c=country.Id,
            Signature_Image__c='test'
        );
        insert us;


        // Create Account with minimal fields
        Account acc = new Account(
            Name = 'Test Account',
            CurrencyIsoCode = 'USD',
            Subsidiary__c = sub.Id,
            ADDRESS_LINE_1__c = 'Test'
        );
        insert acc;

        // Create Contact
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id
        );
        insert con;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            CurrencyIsoCode = 'USD'
        );
        insert opp;

        // Create Quote with minimal fields
        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            ContactId = con.Id,
            Status = 'Released',
            CurrencyIsoCode = 'USD'
        );
        insert qt;

        // Create ONE Contract that expires in 3 days
        Contract c1 = new Contract(
            Name = 'Contract Expiring',
            AccountId = acc.Id,
            Opportunity__c = opp.Id,
            Quote__c = qt.Id,
            Status = 'Released',  // Use 'Released' as required by scheduler
            Expiration_Date__c = Date.today().addDays(3),
            CurrencyIsoCode = 'USD',
            Subsidiary__c = sub.Id,
            StartDate = Date.today(),
            ContractTerm = 12
        );
        insert c1;

        // Create ONE Contract that should NOT be processed (different status)
        Contract c2 = new Contract(
            Name = 'Contract Draft',
            AccountId = acc.Id,
            Opportunity__c = opp.Id,
            Quote__c = qt.Id,
            Status = 'Draft',
            Expiration_Date__c = Date.today().addDays(3),
            CurrencyIsoCode = 'USD',
            Subsidiary__c = sub.Id,
            StartDate = Date.today(),
            ContractTerm = 12
        );
        insert c2;
    }

    @IsTest
    static void testSchedulerExecution() {
        Test.startTest();

        System.schedule(
            'Test Contract Expiration Scheduler',
            '0 0 12 * * ?',
            new ContractExpirationScheduler()
        );

        Test.stopTest();
    }

    @IsTest
    static void testExecuteDirectly() {
        Test.startTest();

        new ContractExpirationScheduler().execute(null);

        Test.stopTest();
    }

    @IsTest
    static void testExecuteDirectlyWithNoMatchingContracts() {
        // Update the only matching contract to not match
        Contract c = [SELECT Id FROM Contract WHERE Name = 'Contract Expiring' LIMIT 1];
        c.Expiration_Date__c = Date.today().addDays(5);
        update c;

        Test.startTest();

        new ContractExpirationScheduler().execute(null);

        Test.stopTest();
    }
}