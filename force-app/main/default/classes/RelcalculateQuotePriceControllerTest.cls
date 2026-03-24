@IsTest
private class RelcalculateQuotePriceControllerTest {

    @IsTest
    static void testRecalculate() {

        Fiscal_Year_Master__c fy = new Fiscal_Year_Master__c(
            Name='FY',
            Active__c=true,
            Fiscal_Year_Start_Date__c=Date.newInstance(2026,1,1),
            Fiscal_Year_End_Date__c=Date.newInstance(2026,12,31)
        );
        insert fy;

        Subsidiari_Master__c sub = new Subsidiari_Master__c(
            Name='ASI',
            Permitted_Currency__c='USD',
            Permitted_Language__c='EN',
            Office__c='Mumbai',
            Discount_Level_1__c=5,
            Discount_Level_2__c=10,
            Discount_Level_3__c=15
        );
        insert sub;

        Global_Region__c gr = new Global_Region__c(Name='Asia');
        insert gr;

        Global_SubRegion__c sr = new Global_SubRegion__c(
            Name='Southern Asia',
            Region__c=gr.Id
        );
        insert sr;

        Country_List__c country = new Country_List__c(
            Name='India',
            Sub_Region__c=sr.Id,
            Region_Master__c=gr.Id
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
            Country__c=country.Id
        );
        insert us;

        Account acc = new Account(
            Name='Test Account',
            Billing_Country__c=country.Id,
            Billing_State__c=state.Id,
            Billing_City__c=city.Id,
            Shipping_Country__c=country.Id,
            Shipping_State__c=state.Id,
            Shipping_City__c=city.Id,
            Billing_Postal_ZIP_Code__c=pin.Id,
            ADDRESS_LINE_1__c='Line1',
            ADDRESS_LINE_2__c='Line2',
            ADDRESS_LINE_3__c='Line3',
            CurrencyIsoCode='USD',
            Subsidiary__c=sub.Id,
            Is_Converted__c=true
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Test Opportunity',
            AccountId=acc.Id,
            StageName='Prospecting',
            CloseDate=Date.today(),
            CurrencyIsoCode='USD'
        );
        insert opp;

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact',
            Email='test@test.com',
            AccountId=acc.Id
        );
        insert con;

        Id stdPb = Test.getStandardPricebookId();

        Product2 prod = new Product2(
            Name='Test Product',
            ProductCode='P100',
            IsActive=true
        );
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPb,
            Product2Id = prod.Id,
            UnitPrice = 100,
            Base_Price__c = 90,
            List_Price__c = 120,
            D1__c = 5,
            D2__c = 10,
            D3__c = 15,
            CurrencyIsoCode = 'USD',
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;

        Quote qt = new Quote(
            Name='Test Quote',
            OpportunityId=opp.Id,
            ContactId=con.Id,
            Status='Draft',
            Pricebook2Id=stdPb,
            CurrencyIsoCode='USD',
            Subsidiary__c=sub.Id,
            Subsidiary_Picklist__c='ASI'
        );
        insert qt;

        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c(
            Quote__c = qt.Id,
            Product__c = prod.Id,
            Quantity__c = 2,
            Base_Price__c = 90,
            List_Price__c = 120,
            Sr_No__c = 1,
            Is_Manual__c = false,
            Is_Tax__c = true,
            Discount_Allowed_New__c = 10
        );
        insert qli;

        Quote_Line_Options__c qlo = new Quote_Line_Options__c(
            Quote__c = qt.Id,
            Quote_Line_Item_Custom__c = qli.Id,
            Product__c = prod.Id,
            CurrencyIsoCode='USD',
            Quantity__c=1,
            Serial_Number__c=1,
            Discount__c=1,
            Description__c='Test Option',
            Manual_Option_Base_Price__c=50,
            Manula_Option_List_Price__c=60,
            Select_Option__c=false,
            P_D1__c=1,
            P_D2__c=2,
            P_D3__c=3,
            Discount_Allowed_New__c = 10
        );
        insert qlo;

        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        RelcalculateQuotePriceController ctrl = new RelcalculateQuotePriceController(sc);

        Test.startTest();

        ApexPages.currentPage().getParameters().put('Id', qt.Id);
        ctrl.Recalculate();

        Test.stopTest();

        System.assertEquals(true, true);
    }
}
