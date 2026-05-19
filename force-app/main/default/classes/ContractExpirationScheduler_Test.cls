@IsTest
private class ContractExpirationScheduler_Test {

    @TestSetup
    static void setupData() {
        // Create Fiscal Year first
        Fiscal_Year_Master__c fy = new Fiscal_Year_Master__c(
            Name = 'FY',
            Active__c = true,
            Fiscal_Year_Start_Date__c = Date.newInstance(2025, 1, 1),
            Fiscal_Year_End_Date__c = Date.newInstance(2025, 12, 31)
        );
        insert fy;

        // Create Subsidiary Master
        Subsidiari_Master__c sub = new Subsidiari_Master__c(
            Name = 'TST',
            Permitted_Currency__c = 'USD;EUR',
            Permitted_Language__c = 'EN',
            Office__c = 'Test Office',
            Discount_Level_1__c = 5,
            Discount_Level_2__c = 10,
            Discount_Level_3__c = 15
        );
        insert sub;

        // Create Global Region
        Global_Region__c greg = new Global_Region__c(Name = 'Asia');
        insert greg;

        // Create Global SubRegion
        Global_SubRegion__c reg = new Global_SubRegion__c(
            Name = 'Southern Asia',
            Region__c = greg.Id
        );
        insert reg;

        // Create Country List (Country_List__c, not Country__c)
        Country_List__c country = new Country_List__c(
            Name = 'India',
            Sub_Region__c = reg.Id,
            Region_Master__c = greg.Id
        );
        insert country;

        // Create User_Setup__c for the running user (Required by Trg_Account trigger)
        User_Setup__c userSetup = new User_Setup__c(
            User__c = UserInfo.getUserId(),
            Subsidiari__c = sub.Id,
            Country__c = country.Id,
            Signature_Image__c = 'test'
        );
        insert userSetup;

        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            CurrencyIsoCode = 'USD',
            Subsidiary__c = sub.Id,
            Is_Converted__c = true,
            ADDRESS_LINE_1__c = 'Test Address',
            BillingCountry = 'United States',
            Billing_Country__c = country.Id
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

        // Create Quote
        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            ContactId = con.Id,
            Status = 'Released',
            CurrencyIsoCode = 'USD'
        );
        insert qt;

        // Create Contract with valid status
        Contract contract = new Contract(
            Name = 'Contract Expiring',
            AccountId = acc.Id,
            Opportunity__c = opp.Id,
            Quote__c = qt.Id,
            Status = 'Activated',
            Expiration_Date__c = Date.today().addDays(3),
            CurrencyIsoCode = 'USD',
            Subsidiary__c = sub.Id,
            SUBSIDARY__c = sub.Id,
            StartDate = Date.today().addDays(-30),
            ContractTerm = 12,
            OwnerId = UserInfo.getUserId(),
            Revision_Number__c = '001',
            Contact__c = con.Id,
            DATE__c = Date.today(),
            SOLD_TO__c = acc.Id,
            SHIP_TO__c = acc.Id,
            INCO_TERMS__c = 'FOB',
            MFG_AT__c = 'Test MFG',
            TYPE__c = 'Test Type',
            END_CUSTOMER_NAME__c = 'Test End Customer',
            ADVANCE_PAYMENT__c = '10',
            PO_Number__c = 'PO123',
            PO_Date__c = Date.today(),
            Signed_SC_PO_receipt_date__c = Date.today(),
            PO_No_from_customer__c = 'CustPO123'
        );
        insert contract;
    }

    @IsTest
    static void testSchedulerExecution() {
        Test.startTest();

        String jobId = System.schedule(
            'Test Contract Expiration Scheduler',
            '0 0 12 * * ?',
            new ContractExpirationScheduler()
        );

        Test.stopTest();
        
        System.assertNotEquals(null, jobId);
    }

    @IsTest
    static void testExecuteDirectly() {
        Test.startTest();

        ContractExpirationScheduler scheduler = new ContractExpirationScheduler();
        scheduler.execute(null);

        Test.stopTest();
        
        List<Task> tasks = [SELECT Id, Subject, WhatId, Status, Priority FROM Task];
        System.assertEquals(1, tasks.size());
        System.assertEquals('High', tasks[0].Priority);
        System.assertEquals('Open', tasks[0].Status);
    }

    @IsTest
    static void testExecuteDirectlyWithNoMatchingContracts() {
        Contract c = [SELECT Id FROM Contract WHERE Name = 'Contract Expiring' LIMIT 1];
        c.Status = 'Draft';
        update c;

        Test.startTest();

        new ContractExpirationScheduler().execute(null);

        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task];
        System.assertEquals(0, tasks.size());
    }
    
    @IsTest
    static void testExecuteDirectlyWithNoExpiringContracts() {
        Contract c = [SELECT Id FROM Contract WHERE Name = 'Contract Expiring' LIMIT 1];
        c.Expiration_Date__c = Date.today().addDays(20);
        update c;

        Test.startTest();

        new ContractExpirationScheduler().execute(null);

        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task];
        System.assertEquals(0, tasks.size());
    }
}