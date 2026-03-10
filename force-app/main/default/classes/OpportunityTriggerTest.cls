@IsTest
private class OpportunityTriggerTest {

@IsTest
static void testOpportunityTriggerCoverage() {

    Fiscal_Year_Master__c fy = new Fiscal_Year_Master__c(
        Name='FY',
        Active__c=true,
        Fiscal_Year_Start_Date__c=Date.today().addDays(-10),
        Fiscal_Year_End_Date__c=Date.today().addDays(365)
    );
    insert fy;

    Subsidiari_Master__c sub = new Subsidiari_Master__c(
        Name='ABC',
        Permitted_Currency__c='USD',
        Permitted_Language__c='EN',
        Office__c='Mumbai',
        Discount_Level_1__c=5,
        Discount_Level_2__c=10,
        Discount_Level_3__c=15
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
        Country__c=country.Id
    );
    insert us;

    Unique_No__c un = new Unique_No__c(
        Object_Name__c='Opportunity',
        Subsidiary__c=sub.Id,
        Fiscal_Year__c=fy.Id,
        Serial_No__c=1
    );
    insert un;

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

    Contact con = new Contact(
        FirstName='Test',
        LastName='Contact',
        AccountId=acc.Id,
        Email='test@test.com'
    );
    insert con;

    // allow trigger to run
    RecursiveTriggerHandler2.isFirstTimeOnOpp = true;

    Test.startTest();

    Opportunity opp = new Opportunity(
        Name='Test Opportunity',
        AccountId=acc.Id,
        StageName='New',
        CloseDate=Date.today().addDays(10),
        CurrencyIsoCode='USD'
    );
    insert opp;

    // Create Quote BEFORE updating opportunity
    Quote qt = new Quote(
        Name='Test Quote',
        OpportunityId=opp.Id,
        Status='Draft',
        ExpirationDate=Date.today().addDays(5)
    );
    insert qt;

    // reset recursion flag for update block
    CheckRecursive.isExecuting = false;

    opp.CloseDate = Date.today().addDays(30);
    update opp;

    // Test delete restriction
    Boolean deleteError = false;

    try{
        delete opp;
    }catch(Exception e){
        deleteError = true;
    }

    System.assert(deleteError,'Opportunity should not delete when Quote exists');

    Test.stopTest();
}


}