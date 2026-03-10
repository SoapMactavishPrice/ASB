@IsTest
private class QuoteTriggerHandlerTest {

    @IsTest
    static void testAllQuoteTriggerHandlerMethods() {

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

        Contact con1 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact1',
            AccountId = acc.Id,
            Email = 'test1@example.com'
        );
        insert con1;

        Contact con2 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact2',
            AccountId = acc.Id,
            Email = 'test2@example.com'
        );
        insert con2;

        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            ContactId = con1.Id,
            Status = 'Draft',
            Adjust_Exchange_Rate_for_manual_item_opt__c = 2.0,
            SHIP_To_Contact_Name__c = con1.Id
        );
        insert qt;

        Contract ctr = new Contract(
            Name = 'Test Contract',
            AccountId = acc.Id,
            Quote__c = qt.Id,
            Status = 'Created'
        );
        insert ctr;

        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c(
            Quote__c = qt.Id,
            List_Price__c = 100,
            Base_Price__c = 90,
            Is_Manual__c = true
        );
        insert qli;

        Quote_Line_Options__c qlo = new Quote_Line_Options__c(
            Quote__c = qt.Id,
            Quote_Line_Item_Custom__c = qli.Id,
            Manula_Option_List_Price__c = 50,
            Manual_Option_Base_Price__c = 40,
            Select_Option__c = true
        );
        insert qlo;

        Map<Id, Quote> oldMap = new Map<Id, Quote>(
            [SELECT Id, ContactId, SHIP_To_Contact_Name__c,
                    Adjust_Exchange_Rate_for_manual_item_opt__c
             FROM Quote WHERE Id = :qt.Id]
        );

        qt.ContactId = con2.Id;
        qt.SHIP_To_Contact_Name__c = con2.Id;
        qt.Adjust_Exchange_Rate_for_manual_item_opt__c = 3.0;
        update qt;

        List<Quote> newQuoteList = [
            SELECT Id, Status, ContactId,
                   Adjust_Exchange_Rate_for_manual_item_opt__c,
                   Email, OpportunityId,
                   SHIP_To_Contact_Name__c
            FROM Quote
            WHERE Id = :qt.Id
        ];

        Test.startTest();

        QuoteTriggerHandler.contactChangeTOContract(newQuoteList, oldMap);
        QuoteTriggerHandler.ShipTocontactChangeTOContract(newQuoteList, oldMap);
        QuoteTriggerHandler.updateListPriceAndBasePriceUsingAdjustExchangeRate(newQuoteList, oldMap);

        Test.stopTest();
    }
}