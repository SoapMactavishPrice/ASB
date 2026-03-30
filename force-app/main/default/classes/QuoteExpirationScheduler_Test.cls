@IsTest
private class QuoteExpirationScheduler_Test {

    @TestSetup
    static void setupData() {

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

        Account acc = new Account(
            Name = 'Test Account',
            CurrencyIsoCode = 'USD',
            Subsidiary__c = sub.Id,
            ADDRESS_LINE_1__c = 'Text'
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

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id
        );
        insert con;

        // Quote that SHOULD trigger scheduler
        Quote q1 = new Quote(
            Name = 'Quote Expiring',
            OpportunityId = opp.Id,
            ContactId = con.Id,
            Status = 'Released',
            ExpirationDate = Date.today().addDays(3)
        );
        insert q1;

        // Quote that should NOT trigger scheduler
        Quote q2 = new Quote(
            Name = 'Quote Draft',
            OpportunityId = opp.Id,
            ContactId = con.Id,
            Status = 'Draft',
            ExpirationDate = Date.today().addDays(3)
        );
        insert q2;
    }

    @IsTest
    static void testSchedulerExecution(){

        Test.startTest();

        System.schedule(
            'Test Quote Expiration Scheduler',
            '0 0 12 * * ?',
            new QuoteExpirationScheduler()
        );

        Test.stopTest();

        List<Task> tasks = [
            SELECT Id, Subject, Priority, Status
            FROM Task
        ];

    }

    @IsTest
    static void testExecuteDirectly(){

        Test.startTest();

        new QuoteExpirationScheduler().execute(null);

        Test.stopTest();

        List<Task> tasks = [
            SELECT Id, Subject
            FROM Task
            WHERE Subject LIKE '%expired in 3 days%'
        ];

       
    }
}