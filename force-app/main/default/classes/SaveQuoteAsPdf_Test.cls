@isTest
public class SaveQuoteAsPdf_Test {

static testmethod void UnitTest1(){

    Subsidiari_Master__c sub = new Subsidiari_Master__c(
        Name='ASI',
        Name__c='xyg',
        Active__c=true,
        Office__c='Airforce',
        Rounding_Off_Digits__c='10000',
        Permitted_Currency__c='INR',
        Permitted_Language__c='EN',
        Discount_Level_1__c=5,
        Discount_Level_2__c=10,
        Discount_Level_3__c=15,
        Quote_Approval__c='Line Item level'
    );
    insert sub;

    Fiscal_Year_Master__c fy = new Fiscal_Year_Master__c(
        Name='FY',
        Active__c=true,
        Fiscal_Year_Start_Date__c=System.today()-200,
        Fiscal_Year_End_Date__c=System.today()+200
    );
    insert fy;

    Country_List__c country = new Country_List__c(
        Name='India',
        Subsidiary__c=sub.Id
    );
    insert country;

    Region__c region = new Region__c(
        Name='Region',
        Name__c='Region',
        Country__c=country.Id
    );
    insert region;

    State_List__c state = new State_List__c(
        Name='State',
        Country__c=country.Id,
        Region__c=region.Id
    );
    insert state;

    City_List__c city = new City_List__c(
        Name='City',
        State__c=state.Id,
        Subsidiary_Master__c=sub.Id
    );
    insert city;

    User_Setup__c us = new User_Setup__c(
        User__c=UserInfo.getUserId(),
        Subsidiari__c=sub.Id,
        Country__c=country.Id
    );
    insert us;

    Account acc = new Account(
        Name='Test Account',
        CurrencyIsoCode='INR',
        Subsidiary__c=sub.Id,
        ADDRESS_LINE_1__c='Line1',
        ADDRESS_LINE_2__c='Line2',
        ADDRESS_LINE_3__c='Line3'
    );
    insert acc;

    Contact con = new Contact(
        LastName='Test Contact',
        Email='test@test.com',
        AccountId=acc.Id
    );
    insert con;

    Opportunity opp = new Opportunity(
        Name='Test Opp',
        StageName='Prospecting',
        CloseDate=System.today()+10,
        AccountId=acc.Id,
        CurrencyIsoCode='INR'
    );
    insert opp;

    Quote_Template__c qtTemp = new Quote_Template__c(
        Name='Template',
        Label__c='Template',
        Active__c=true
    );
    insert qtTemp;

    Quote qt = new Quote(
        Name='Test Quote',
        OpportunityId=opp.Id,
        ContactId=con.Id,
        CurrencyIsoCode='INR',
        Status='RELEASED',
        Insurance__c='By Seller',
        Freight__c='By Seller',
        Quote_Template__c=qtTemp.Id,
        Subsidiary_Picklist__c='ASI',
        Quote_Release_Date__c=System.today(),
        Quote_Number1__c='QT-001',
        QU_REVISION_NUMBER__c='000'
    );
    insert qt;

    Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c(
        Quote__c=qt.Id,
        Quantity__c=1,
        Product_Name__c='Test Product',
        Product_Description__c='#Test Desc',
        UOM__c='Nos',
        List_Price__c=100,
        Sr_No__c=1
    );
    insert qli;

    Quote_Line_Options__c qlo = new Quote_Line_Options__c(
        Quote__c=qt.Id,
        Quote_Line_Item_Custom__c=qli.Id,
        Description__c='Option Desc',
        Manual_Product_Name__c='Option Product'
    );
    insert qlo;

    Additional_Document__c doc = new Additional_Document__c(
        Name='Test Doc',
        Active__c=true,
        Type__c='Quote'
    );
    insert doc;

    PageReference pageRef = Page.SaveQuoteAsPdf;
    pageRef.getParameters().put('Id',qt.Id);
    Test.setCurrentPage(pageRef);

    ApexPages.StandardController sc = new ApexPages.StandardController(qt);
    SaveQuoteAsPdf controller = new SaveQuoteAsPdf(sc);

    controller.ObjQuote = qt;
    controller.emailId = 'test@test.com';
    controller.subject = 'Test Email';
    controller.body = 'Test Body';

    Test.startTest();

    controller.openOptionsModal();
    controller.saveOptions();
    controller.closeOptions();

    controller.CreateQuote();
    controller.save();
    controller.attachQuote();
    controller.updateOptions();
    controller.saveAndSendcall();

    Test.stopTest();
}


}