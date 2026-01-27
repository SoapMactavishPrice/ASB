@isTest
public class SetApproverUserForDTA_Test {

    @isTest
    public static void testSetApproverUserForDTA() {

        // 1. Create test User with the username from the custom label (use unique username to avoid DUPLICATE_USERNAME)
        User testUser = new User(
            Username = 'kaushal.agrawal@nisseiasb1111.com', // unique username
            Alias = 'kkAgrl',
            LastName = 'Agrawal',
            Email = 'kaushal.agrawal@nisseiasb.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // 2. Insert Fiscal Year
        Fiscal_Year_Master__c f = new Fiscal_Year_Master__c();
        f.Active__c = true;
        f.Fiscal_Year_Start_Date__c = System.today() - 65;
        f.Fiscal_Year_End_Date__c = System.today() + 300;
        f.Name = 'NPL';
        insert f;

        // 3. Pricebook and Subsidiary
        Pricebook2 priObject = new Pricebook2(Name = 'Pri1');
        insert priObject;

        Subsidiari_Master__c s = new Subsidiari_Master__c(
            Name = 'ASI',
            Name__c = 'xyg',
            Active__c = true,
            Price_Book__c = priObject.Id,
            Office__c = 'Airforce',
            Rounding_Off_Digits__c = '1',
            Permitted_Currency__c = 'INR',
            Permitted_Language__c = 'HI',
            Discount_Level_1__c = 5,
            Discount_Level_2__c = 10,
            Discount_Level_3__c = 15,
            Quote_Approval__c = 'Line Item level',
            Contract_Approval__c = 'Line Item level'
        );
        insert s;

        // 4. Country and Region
        Country_List__c c = new Country_List__c(Name = 'India', Active__c = true, Subsidiary__c = s.Id);
        insert c;

        Region__c re = new Region__c(Name = 'EAST', Name__c = 'EAST', Active__c = true, Country__c = c.Id);
        insert re;

        // 5. User Setup & Region Assignment
        User_Setup__c u = new User_Setup__c(
            Country__c = c.Id,
            User__c = UserInfo.getUserId(),
            Subsidiari__c = s.Id,
            Region__c = re.Id,
            Default_Language__c = 'HI'
        );
        insert u;

        Assign_Region__c ar = new Assign_Region__c(
            User_Setup__c = u.Id,
            Country__c = c.Id,
            Region__c = re.Id
        );
        insert ar;

        // 6. Campaign, Account, Opportunity
        Campaign camObject = new Campaign(Name = 'Cam1', CurrencyIsoCode = 'INR');
        insert camObject;

        Account accObject = new Account(CurrencyIsoCode = 'INR', Name = 'Test1', Region1__c = re.Id);
        insert accObject;

        Opportunity oppObject = new Opportunity(
            AccountId = accObject.Id,
            Name = 'Opp1',
            Zero_Cooling__c = 'Yes',
            CurrencyIsoCode = 'INR',
            StageName = 'New',
            CloseDate = System.today()
        );
        insert oppObject;

        // 7. Products and Pricebook Entries
        Product2 proObject = new Product2(
            CurrencyIsoCode = 'INR',
            ProductCode = '123',
            Family = 'Items',
            Language__c = 'EN',
            Description = '56789',
            Name = 'Pro1',
            IsActive = true,
            Product_Number__c = '123',
            Subsidiari__c = s.Id
        );
        insert proObject;

        Id standardPBId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = standardPBId,
            Product2Id = proObject.Id,
            UnitPrice = 10000,
            UseStandardPrice = false,
            IsActive = true,
            Base_Price__c = 123,
            Discount_Level_3__c = 12,
            Pricing_Type__c = 1,
            Quantity__c = 1,
            D1__c = 0.1,
            D2__c = 0.3,
            D3__c = 0.2,
            M1__c = 0.1,
            M2__c = 0.2,
            M3__c = 0.3,
            M4__c = 0.4,
            Rounding_Off_Digits__c = '10'
        );
        insert standardPrice;

        // 8. Prepare Quote

        // Try to get the DTA RecordType if exists
        List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote' AND Name = 'DTA' LIMIT 1];

        Quote testQuote;

        if (!rtList.isEmpty()) {
            testQuote = new Quote(
                Name = 'Q1',
                Exchange_Rate__c = 1,
                OpportunityId = oppObject.Id,
                Language__c = 'EN',
                Subsidiary__c = s.Id,
                RecordTypeId = rtList[0].Id
            );
        } else {
            // No DTA record type, insert without RecordTypeId
            testQuote = new Quote(
                Name = 'Q1',
                Exchange_Rate__c = 1,
                OpportunityId = oppObject.Id,
                Language__c = 'EN',
                Subsidiary__c = s.Id
            );
        }

        Test.startTest();
        insert testQuote;
        Test.stopTest();

        // 9. Verify Approver_User__c was set (trigger should have set this field)
        Quote insertedQuote = [SELECT Id, Approver_User__c FROM Quote WHERE Id = :testQuote.Id LIMIT 1];

        System.assertNotEquals(null, insertedQuote.Approver_User__c, 'Approver User should be set by the trigger.');
    }
}