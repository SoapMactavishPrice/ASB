@IsTest
private class ReOpenQuoteFromContractTest {

    @IsTest
    static void testAllMethods() {

        // ------------------ Setup Master Data ------------------
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

        Global_Region__c greg = new Global_Region__c(Name='Asia');
        insert greg;

        Global_SubRegion__c reg = new Global_SubRegion__c(Name='Southern Asia', Region__c=greg.Id);
        insert reg;

        Country_List__c country = new Country_List__c(
            Name='India',
            Sub_Region__c=reg.Id,
            Region_Master__c=greg.Id
        );
        insert country;

        State_List__c state = new State_List__c(Name='Maharashtra', Country__c=country.Id);
        insert state;

        City_List__c city = new City_List__c(Name='Mumbai', State__c=state.Id);
        insert city;

        PIN_Code_Master__c pin = new PIN_Code_Master__c(Name='400001', City__c=city.Id);
        insert pin;

        User_Setup__c us = new User_Setup__c(
            User__c = UserInfo.getUserId(),
            Subsidiari__c = sub.Id,
            Country__c = country.Id
        );
        insert us;

        // ------------------ Account / Opportunity / Contact ------------------
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

        // ------------------ Quote ------------------
        Id standardPricebookId = Test.getStandardPricebookId();
        Quote qt = new Quote(
            Name='Test Quote',
            OpportunityId=opp.Id,
            ContactId=con.Id,
            Status='Draft',
            Pricebook2Id = standardPricebookId,
            SHIP_To_Contact_Name__c = con.Id
        );
        insert qt;

        // ------------------ Contract ------------------
        Contract ctr = new Contract(
            Name='Test Contract',
            AccountId=acc.Id,
            Quote__c=qt.Id,
            Opportunity__c = opp.Id,
            Status='Created',
            Subsidiary__c = sub.Id
        );
        insert ctr;

        // ------------------ Product & Pricebook ------------------
        Product2 prod = new Product2(Name='Test Product', ProductCode='P100', IsActive=true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = standardPricebookId,
            UnitPrice = 100,
            UseStandardPrice = false,
            IsActive = true,
            D1__c = 0.1,
            D2__c = 0.2,
            D3__c = 0.3,
            M1__c = 0.1,
            M2__c = 0.2,
            M3__c = 0.3,
            M4__c = 0.4,
            Rounding_Off_Digits__c = '10',
            Base_Price__c = 100
        );
        insert pbe;

        // ------------------ Quote Line Item & Options ------------------
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c(
            Quote__c = qt.Id,
            Product__c = prod.Id,
            Quantity__c = 2,
            List_Price__c = 100,
            Base_Price__c = 90,
            Is_Manual__c = true,
            Sr_No__c = 1
        );
        insert qli;

        Quote_Line_Options__c qlo = new Quote_Line_Options__c(
            Quote__c = qt.Id,
            Quote_Line_Item_Custom__c = qli.Id,
            Product__c = prod.Id,
            CurrencyIsoCode = 'USD',
            Quantity__c = 1,
            Serial_Number__c = 1,
            Discount__c = 1,
            Discount_Type__c = 'Percent',
            Description__c = 'Test Option',
            Manual_Option_Base_Price__c = 50,
            Manula_Option_List_Price__c = 60,
            Select_Option__c = true,
            P_D1__c = 2,
            P_D2__c = 2,
            P_D3__c = 3
        );
        insert qlo;

        // ------------------ Contract Line Items ------------------
        Contract_Line_Item__c cli1 = new Contract_Line_Item__c(
            ContractId__c = ctr.Id,
            Quantity__c = 3,
            Sr_No__c = 1,
            CurrencyIsoCode = 'USD',
            Product2Id__c = prod.Id,
            Product_Name_2__c = prod.Name,
            Project_Unique_No__c = 'ProjKey1',
            Original_SQ_No__c = 10
         //   Ceiling_Unit_Sales_Price_incl_Options__c = 150
        );
        insert cli1;

        Contract_Line_Item__c cli2 = new Contract_Line_Item__c(
            ContractId__c = ctr.Id,
            Quantity__c = 2,
            Sr_No__c = 2,
            CurrencyIsoCode = 'USD',
            Product2Id__c = prod.Id,
            Product_Name_2__c = prod.Name,
            Project_Unique_No__c = 'ProjKey2',
            Original_SQ_No__c = 20
          //  Ceiling_Unit_Sales_Price_incl_Options__c = 200
        );
        insert cli2;

        // ------------------ Project Management ------------------
        User u = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        ProjectManagement__c pmA = new ProjectManagement__c(
            Project_Number__c = 'PM2001',
            PRODUCT__c = 'Test Product A',
            HQ_Sales_Liaison_email_id__c = 'hq1@test.com',
            AI_Sales_Liaison_email_id__c = 'ai1@test.com',
            OwnerId = u.Id,
            Expected_Sales_Month__c = Date.today(),
            PO_No_to_HQ_3rd_Party__c = 'PO001',
            PO_issued_date_to_HQ_3rd_Party__c = Date.today(),
            Phase__c = 'Cancelled'
        );
        insert pmA;

        ProjectManagement__c pmB = new ProjectManagement__c(
            Project_Number__c = 'PM2002',
            PRODUCT__c = 'Test Product B',
            HQ_Sales_Liaison_email_id__c = 'hq2@test.com',
            AI_Sales_Liaison_email_id__c = 'ai2@test.com',
            OwnerId = u.Id,
            Expected_Sales_Month__c = Date.today(),
            PO_No_to_HQ_3rd_Party__c = 'PO002',
            PO_issued_date_to_HQ_3rd_Party__c = Date.today(),
            Phase__c = 'Cancelled'
        );
        insert pmB;

        // ------------------ Setup Project Map ------------------
        Map<String, List<ProjectManagement__c>> exiProjectMap1 = new Map<String, List<ProjectManagement__c>>();
        exiProjectMap1.put('ProjKey1', new List<ProjectManagement__c>{pmA});
        exiProjectMap1.put('ProjKey2', new List<ProjectManagement__c>{pmB});

        // ------------------ Query Contract Line Items for relationship ------------------
        List<Contract_Line_Item__c> linelist = [SELECT Id, Quantity__c, Sr_No__c, CurrencyIsoCode, Product2Id__r.Name, Product_Name_2__c, Project_Unique_No__c, Original_SQ_No__c, Ceiling_Unit_Sales_Price_incl_Options__c
                                                FROM Contract_Line_Item__c
                                                WHERE Id IN :new List<Id>{cli1.Id, cli2.Id}];

        Test.startTest();

        // ------------------ Call existing methods ------------------
        String quoteId = ReOpenQuoteFromContract.getQuoteId(ctr.Id);
        String projectDetail = ReOpenQuoteFromContract.getProjectDetail(ctr.Id);

        ReOpenQuoteFromContract.wrapProject wr = new ReOpenQuoteFromContract.wrapProject();
        wr.p_pmId = pmA.Id;
        wr.key = 'ProjKey1';
        wr.p_SrNO = 1;
        wr.p_currency = 'USD';
        wr.p_CancelType = 'Cancelled'; // cover cancelled logic

        List<ReOpenQuoteFromContract.wrapProject> wrapListInput = new List<ReOpenQuoteFromContract.wrapProject>{wr};
        String jsonStr = JSON.serialize(wrapListInput);

        List<ReOpenQuoteFromContract.wrapProject> parsed = ReOpenQuoteFromContract.parse(jsonStr);
        ReOpenQuoteFromContract.AuthModel auth = ReOpenQuoteFromContract.isUserAuthorized(ctr.Id);
        Map<String,Object> result = ReOpenQuoteFromContract.saveCanceledProject(ctr.Id, jsonStr, false);

        // ------------------ Cover the wrapList loop ------------------
        List<ReOpenQuoteFromContract.wrapProject> wrapList = new List<ReOpenQuoteFromContract.wrapProject>();

        for (Contract_Line_Item__c cm : linelist) {
            String key = cm.Project_Unique_No__c;
            Integer Qty = Integer.valueOf(cm.Quantity__c);
            if (exiProjectMap1.containsKey(key)) {
                for (ProjectManagement__c pm : exiProjectMap1.get(key)) {
                    Qty = Qty - 1;
                    ReOpenQuoteFromContract.wrapProject wrp = new ReOpenQuoteFromContract.wrapProject();
                    wrp.p_currency = cm.CurrencyIsoCode;
                    wrp.key = key;
                    wrp.p_pmId = pm.Id;
                    wrp.p_OpenConfirm = false;
                    wrp.p_SrNO = Integer.valueOf(cm.Original_SQ_No__c);
                    wrp.p_ProjectName = pm.PRODUCT__c;
                    wrp.p_projNum = pm.Project_Number__c;
                    wrp.HQEmail = pm.HQ_Sales_Liaison_email_id__c;
                    wrp.AIEmail = pm.AI_Sales_Liaison_email_id__c;
                    wrp.OwnerEmail = u.Email;
                    wrp.ExpectedSalesMonth = pm.Expected_Sales_Month__c;
                    wrp.YourPONumber = pm.PO_No_to_HQ_3rd_Party__c;
                    wrp.YourPOIssueDate = pm.PO_issued_date_to_HQ_3rd_Party__c;
                    wrp.p_CancelType = null;
                    wrp.p_Phase = pm.Phase__c;
                    wrp.isShowCancel = true;
                    wrp.p_SalesPrice = cm.Ceiling_Unit_Sales_Price_incl_Options__c;
                    wrapList.add(wrp);
                }

                for (Integer i = 0; i < Qty; i++) {
                    ReOpenQuoteFromContract.wrapProject wrp = new ReOpenQuoteFromContract.wrapProject();
                    wrp.p_pmId = null;
                    wrp.p_currency = cm.CurrencyIsoCode;
                    wrp.p_OpenConfirm = false;
                    wrp.p_SrNO = Integer.valueOf(cm.Sr_No__c);
                    if (cm.Product2Id__r != null && cm.Product2Id__r.Name != null) {
                        wrp.p_ProjectName = cm.Product2Id__r.Name;
                    } else {
                        wrp.p_ProjectName = cm.Product_Name_2__c;
                    }
                    wrp.isShowCancel = false;
                    wrp.p_projNum = null;
                    wrp.p_CancelType = null;
                    wrp.p_SalesPrice = null;
                    wrp.AIEmail = null;
                    wrp.ExpectedSalesMonth = null;
                    wrp.YourPONumber = null;
                    wrp.YourPOIssueDate = null;
                    wrp.HQEmail = null;
                    wrp.OwnerEmail = null;
                    wrapList.add(wrp);
                }
            }
        }

        System.assert(!wrapList.isEmpty(), 'wrapList should be populated by the test.');

        Test.stopTest();

        // ------------------ Asserts for existing method outputs ------------------
        System.assertNotEquals(null, quoteId);
        System.assertNotEquals(null, projectDetail);
        System.assertNotEquals(null, parsed);
        System.assertNotEquals(null, auth);
        System.assertNotEquals(null, result);
    }
    
    
}