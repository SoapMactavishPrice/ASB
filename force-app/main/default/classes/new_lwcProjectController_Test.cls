@IsTest
private class new_lwcProjectController_Test {

    @TestSetup
    static void setupData() {
        Fiscal_Year_Master__c fy = new Fiscal_Year_Master__c(
            Name = 'FY',
            Active__c = true,
            Fiscal_Year_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
            Fiscal_Year_End_Date__c = Date.newInstance(Date.today().year(), 12, 31)
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

        User_Setup__c userSetup = new User_Setup__c(
            User__c = UserInfo.getUserId(),
            Subsidiari__c = sub.Id,
            Country__c = country.id,
            Signature_Image__c = 'test'
        );
        insert userSetup;

        Account acc = new Account(
            Name = 'Test Account',
            CurrencyIsoCode = 'USD',
            Subsidiary__c = sub.Id,
            Legal_Name__c = 'Test Account',
            Is_Converted__c = true,
            BillingCountry = 'United States',
            BillingStreet = 'Test Street',
            BillingCity = 'Test City',
            BillingState = 'Test State',
            BillingPostalCode = '12345',
            ADDRESS_LINE_1__c = 'Test',
            Customer_Category__c = 'Medium'
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@test.com',
            AccountId = acc.Id
        );
        insert con;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            CurrencyIsoCode = 'USD',
            Source__c = 'DIRECT'
        );
        insert opp;

        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Status = 'Draft',
            CurrencyIsoCode = 'USD'
        );
        insert qt;

        Product2 prod = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP01',
            Description = 'Test Description',
            IsActive = true
        );
        insert prod;

        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c(
            Quote__c = qt.Id,
            Product__c = prod.Id,
            Product_Name__c = 'Test Product',
            Quantity__c = 2,
            Sr_No__c = 1
        );
        insert qli;

        Contract contract = new Contract(
            Name = 'Test Contract',
            AccountId = acc.Id,
            Status = 'CREATED',
            StartDate = Date.today(),
            ContractTerm = 12,
            Subsidiary__c = sub.Id,
            SUBSIDARY__c = sub.Id,
            Opportunity__c = opp.Id,
            Quote__c = qt.Id,
            Project_Management_Quote_Id__c = qt.Id,
            CurrencyIsoCode = 'USD',
            Expiration_Date__c = Date.today().addDays(30),
            ExpirationDate__c = Date.today().addDays(30),
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
            PO_No_from_customer__c = 'CustPO123',
            Global_Region__c = greg.Id,
            Global_SubRegion__c = reg.Id,
            Country_Text__c = 'India',
            FY__c = 'FY',
            FY1__c = fy.Id
        );
        insert contract;

        Contract_Line_Item__c cli = new Contract_Line_Item__c(
            ContractId__c = contract.Id,
            Product2Id__c = prod.Id,
            Product_Name_2__c = 'Test Product 2',
            Quantity__c = 2,
            QTY__c = 2,
            Sr_No__c = 1,
            Quote_Line_Item_Name__c = qli.Id,
            CurrencyIsoCode = 'USD',
            Original_SQ_No__c = 001,
            Division__c = 'MOLD',
            Drawing_No__c = 'DRG001',
            MFG_Location__c = 'Test Location',
            L_C__c = 'Yes',
            APPLICATION__c = 'BIB - Bag in box',
            CLASS__c = 'Test Class',
            Description__c = 'Test Description',
            Scope__c = 'Test Scope',
            Cavity__c = 2,
            Zero_Cooling__c = 'Yes'
        );
        insert cli;
        
        Contract_Line_Item__c cli2 = new Contract_Line_Item__c(
            ContractId__c = contract.Id,
            Product2Id__c = prod.Id,
            Product_Name_2__c = 'Test Product 3',
            Quantity__c = 1,
            QTY__c = 1,
            Sr_No__c = 2,
            Quote_Line_Item_Name__c = null,
            CurrencyIsoCode = 'USD',
            Original_SQ_No__c = 002,
            Division__c = 'MOLD',
            Drawing_No__c = 'DRG002',
            MFG_Location__c = 'Test Location 2',
            L_C__c = 'No',
            APPLICATION__c = 'BIB - Bag in box',
            CLASS__c = 'Test Class 2',
            Description__c = 'Test Description 2',
            Scope__c = 'Test Scope',
            Cavity__c = 4
        );
        insert cli2;
    }

    @IsTest
    static void testGetExistingProjectDetails() {
        Contract con = [SELECT Id FROM Contract LIMIT 1];
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.getExistingProjectDetails(con.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetExistingProjectDetailsWithExpiredContract() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        Subsidiari_Master__c sub = [SELECT Id FROM Subsidiari_Master__c WHERE Name = 'ABC' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Global_Region__c greg = [SELECT Id FROM Global_Region__c LIMIT 1];
        Global_SubRegion__c reg = [SELECT Id FROM Global_SubRegion__c LIMIT 1];
        Fiscal_Year_Master__c fy = [SELECT Id FROM Fiscal_Year_Master__c WHERE Active__c = true LIMIT 1];
        
        Contract expiredContract = new Contract(
            Name = 'Expired Test Contract',
            AccountId = acc.Id,
            Status = 'CREATED',
            StartDate = Date.today().addMonths(-3),
            ContractTerm = 12,
            Subsidiary__c = sub.Id,
            SUBSIDARY__c = sub.Id,
            Opportunity__c = opp.Id,
            Quote__c = qt.Id,
            Project_Management_Quote_Id__c = qt.Id,
            CurrencyIsoCode = 'USD',
            Expiration_Date__c = Date.today().addDays(-30),
            ExpirationDate__c = Date.today().addDays(-30),
            Revision_Number__c = '001',
            Contact__c = contact.Id,
            DATE__c = Date.today(),
            SOLD_TO__c = acc.Id,
            SHIP_TO__c = acc.Id,
            INCO_TERMS__c = 'FOB',
            MFG_AT__c = 'Test MFG',
            TYPE__c = 'Test Type',
            END_CUSTOMER_NAME__c = 'Test End Customer',
            ADVANCE_PAYMENT__c = '10',
            PO_Number__c = 'PO456',
            PO_Date__c = Date.today().addMonths(-3),
            Signed_SC_PO_receipt_date__c = Date.today().addMonths(-3),
            PO_No_from_customer__c = 'CustPO456',
            Global_Region__c = greg.Id,
            Global_SubRegion__c = reg.Id,
            Country_Text__c = 'India',
            FY__c = 'FY',
            FY1__c = fy.Id
        );
        
        Test.startTest();
        insert expiredContract;
        Map<String, Object> result = new_lwcProjectController.getExistingProjectDetails(expiredContract.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetExistingProjectDetailsWithNoCLI() {
        Contract con = [SELECT Id FROM Contract LIMIT 1];
        List<Contract_Line_Item__c> cliList = [SELECT Id FROM Contract_Line_Item__c WHERE ContractId__c = :con.Id];
        delete cliList;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.getExistingProjectDetails(con.Id);
        Test.stopTest();
    }

  /*  @IsTest
    static void testGetExistingProjectDetailsWithOriginalContract() {
        Contract con = [SELECT Id, Original_Contract__c FROM Contract LIMIT 1];
        con.Original_Contract__c = con.Id;
        update con;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.getExistingProjectDetails(con.Id);
        Test.stopTest();
    }	*/

    @IsTest
    static void testSaveProjectDetails() {
        Contract con = [SELECT Id, Quote__c, Opportunity__c, AccountId, Subsidiary__c, SUBSIDARY__c, 
                               Global_Region__c, Global_SubRegion__c, Country_Text__c,
                               FY__c, FY1__c, Revision_Number__c, Contact__c, DATE__c, ContractNumber,
                               SOLD_TO__c, SHIP_TO__c, INCO_TERMS__c, MFG_AT__c, TYPE__c, 
                               END_CUSTOMER_NAME__c, PO_No_from_customer__c, Signed_SC_PO_receipt_date__c,
                               CurrencyIsoCode, Expiration_Date__c
                        FROM Contract LIMIT 1];
        
        Contract_Line_Item__c cli = [SELECT Id, Product2Id__c, Product2Id__r.Name, Sr_No__c, 
                                            Quote_Line_Item_Name__c, Project_Unique_No__c,
                                            Zero_Cooling__c, Drawing_No__c,
                                            MFG_Location__c, L_C__c, APPLICATION__c, CLASS__c,
                                            Description__c, Division__c, Scope__c, Cavity__c,
                                            QTY__c, Quantity__c, Product_Name_2__c
                                     FROM Contract_Line_Item__c 
                                     WHERE ContractId__c = :con.Id AND Sr_No__c = 1 LIMIT 1];
        
        List<new_lwcProjectController.wrapper> wrapList = new List<new_lwcProjectController.wrapper>();
        
        new_lwcProjectController.wrapper wrap1 = new new_lwcProjectController.wrapper();
        wrap1.isSelect = true;
        wrap1.key = 'UNIQUE001';
        wrap1.LineNumberId = cli.Id;
        wrap1.LineNumberIdClone = cli.Id + '_0';
        wrap1.proName = 'Test Product';
        wrap1.proLineId = null;
        wrap1.proNumber = null;
        wrap1.ExpectedSalesMonth = Date.today();
        wrap1.YourPONumber = 'PO123';
        wrap1.YourPOIssueDate = Date.today();
        wrap1.isDisabled = false;
        wrap1.qty = 1;
        wrap1.p_currency = 'USD';
        wrapList.add(wrap1);
        
        String jsonData = JSON.serialize(wrapList);
        Integer totalProgram = 1;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.SaveProjectDeatils(con.Id, jsonData, totalProgram);
        Test.stopTest();
    }

    @IsTest
    static void testSaveProjectDetailsWithExistingProjects() {
        Contract con = [SELECT Id, Quote__c, Opportunity__c, AccountId, Subsidiary__c, SUBSIDARY__c, 
                               Global_Region__c, Global_SubRegion__c, Country_Text__c,
                               FY__c, FY1__c, Revision_Number__c, Contact__c, DATE__c, ContractNumber,
                               SOLD_TO__c, SHIP_TO__c, INCO_TERMS__c, MFG_AT__c, TYPE__c, 
                               END_CUSTOMER_NAME__c, PO_No_from_customer__c, Signed_SC_PO_receipt_date__c,
                               CurrencyIsoCode, Expiration_Date__c
                        FROM Contract LIMIT 1];
        
        Contract_Line_Item__c cli = [SELECT Id, Product2Id__c, Product2Id__r.Name, Sr_No__c, 
                                            Quote_Line_Item_Name__c, Project_Unique_No__c,
                                            Zero_Cooling__c, Drawing_No__c,
                                            MFG_Location__c, L_C__c, APPLICATION__c, CLASS__c,
                                            Description__c, Division__c, Scope__c, Cavity__c,
                                            QTY__c, Quantity__c, Product_Name_2__c
                                     FROM Contract_Line_Item__c 
                                     WHERE ContractId__c = :con.Id AND Sr_No__c = 1 LIMIT 1];
        
        ProjectManagement__c existingPM = new ProjectManagement__c(
            Contract__c = con.Id,
            Contract_Line_Item__c = cli.Id,
            Opportunity_Name__c = con.Opportunity__c,
            Quote_Name__c = con.Quote__c,
            Project_Unique_No__c = 'UNIQUE001',
            PRODUCT__c = 'Test Product',
            Phase__c = 'Under Moulding',
            Old_Phase__c = 'Under Manufacturing/Assembly'
        );
        insert existingPM;
        
        List<new_lwcProjectController.wrapper> wrapList = new List<new_lwcProjectController.wrapper>();
        
        new_lwcProjectController.wrapper wrap1 = new new_lwcProjectController.wrapper();
        wrap1.isSelect = true;
        wrap1.key = 'UNIQUE001';
        wrap1.LineNumberId = cli.Id;
        wrap1.LineNumberIdClone = cli.Id + '_0';
        wrap1.proName = 'Test Product';
        wrap1.proLineId = existingPM.Id;
        wrap1.proNumber = existingPM.Project_Number__c;
        wrap1.ExpectedSalesMonth = Date.today();
        wrap1.YourPONumber = 'PO123';
        wrap1.YourPOIssueDate = Date.today();
        wrap1.isDisabled = true;
        wrap1.qty = 1;
        wrapList.add(wrap1);
        
        String jsonData = JSON.serialize(wrapList);
        Integer totalProgram = 1;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.SaveProjectDeatils(con.Id, jsonData, totalProgram);
        Test.stopTest();
    }

    @IsTest
    static void testSaveProjectDetailsWithMultipleProjects() {
        Contract con = [SELECT Id FROM Contract LIMIT 1];
        Contract_Line_Item__c cli = [SELECT Id, Project_Unique_No__c, Quantity__c 
                                     FROM Contract_Line_Item__c 
                                     WHERE ContractId__c = :con.Id AND Sr_No__c = 2 LIMIT 1];
        
        List<new_lwcProjectController.wrapper> wrapList = new List<new_lwcProjectController.wrapper>();
        
        for (Integer i = 0; i < 2; i++) {
            new_lwcProjectController.wrapper wrap = new new_lwcProjectController.wrapper();
            wrap.isSelect = true;
            wrap.key = 'UNIQUE002';
            wrap.LineNumberId = cli.Id;
            wrap.LineNumberIdClone = cli.Id + '_' + i;
            wrap.proName = 'Test Product 3';
            wrap.proLineId = null;
            wrap.proNumber = null;
            wrap.ExpectedSalesMonth = Date.today();
            wrap.YourPONumber = 'PO' + i;
            wrap.YourPOIssueDate = Date.today();
            wrap.isDisabled = false;
            wrap.qty = 1;
            wrapList.add(wrap);
        }
        
        String jsonData = JSON.serialize(wrapList);
        Integer totalProgram = 2;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.SaveProjectDeatils(con.Id, jsonData, totalProgram);
        Test.stopTest();
    }

    @IsTest
    static void testSaveProjectDetailsWithPartialConversion() {
        Contract con = [SELECT Id FROM Contract LIMIT 1];
        con.Total_Quantity_Of_Products__c = 2;
        update con;
        
        Contract_Line_Item__c cli = [SELECT Id, Project_Unique_No__c, Quantity__c 
                                     FROM Contract_Line_Item__c 
                                     WHERE ContractId__c = :con.Id AND Sr_No__c = 2 LIMIT 1];
        
        List<new_lwcProjectController.wrapper> wrapList = new List<new_lwcProjectController.wrapper>();
        
        for (Integer i = 0; i < 1; i++) {
            new_lwcProjectController.wrapper wrap = new new_lwcProjectController.wrapper();
            wrap.isSelect = true;
            wrap.key = 'UNIQUE002';
            wrap.LineNumberId = cli.Id;
            wrap.LineNumberIdClone = cli.Id + '_' + i;
            wrap.proName = 'Test Product 3';
            wrap.proLineId = null;
            wrap.proNumber = null;
            wrap.ExpectedSalesMonth = Date.today();
            wrap.YourPONumber = 'PO' + i;
            wrap.YourPOIssueDate = Date.today();
            wrap.isDisabled = false;
            wrap.qty = 1;
            wrapList.add(wrap);
        }
        
        String jsonData = JSON.serialize(wrapList);
        Integer totalProgram = 1;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.SaveProjectDeatils(con.Id, jsonData, totalProgram);
        Test.stopTest();
    }

    @IsTest
    static void testSaveProjectDetailsWithCompleteConversion() {
        Contract con = [SELECT Id FROM Contract LIMIT 1];
        con.Total_Quantity_Of_Products__c = 2;
        update con;
        
        Contract_Line_Item__c cli = [SELECT Id, Project_Unique_No__c, Quantity__c 
                                     FROM Contract_Line_Item__c 
                                     WHERE ContractId__c = :con.Id AND Sr_No__c = 2 LIMIT 1];
        
        List<new_lwcProjectController.wrapper> wrapList = new List<new_lwcProjectController.wrapper>();
        
        for (Integer i = 0; i < 2; i++) {
            new_lwcProjectController.wrapper wrap = new new_lwcProjectController.wrapper();
            wrap.isSelect = true;
            wrap.key = 'UNIQUE002';
            wrap.LineNumberId = cli.Id;
            wrap.LineNumberIdClone = cli.Id + '_' + i;
            wrap.proName = 'Test Product 3';
            wrap.proLineId = null;
            wrap.proNumber = null;
            wrap.ExpectedSalesMonth = Date.today();
            wrap.YourPONumber = 'PO' + i;
            wrap.YourPOIssueDate = Date.today();
            wrap.isDisabled = false;
            wrap.qty = 1;
            wrapList.add(wrap);
        }
        
        String jsonData = JSON.serialize(wrapList);
        Integer totalProgram = 2;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.SaveProjectDeatils(con.Id, jsonData, totalProgram);
        Test.stopTest();
    }

    @IsTest
    static void testSaveProjectDetailsWithExpiredContract() {
        Contract con = [SELECT Id FROM Contract LIMIT 1];
        con.Expiration_Date__c = Date.today().addDays(+1);
        update con;
        
        Contract_Line_Item__c cli = [SELECT Id, Project_Unique_No__c, Quantity__c 
                                     FROM Contract_Line_Item__c 
                                     WHERE ContractId__c = :con.Id LIMIT 1];
        
        List<new_lwcProjectController.wrapper> wrapList = new List<new_lwcProjectController.wrapper>();
        
        new_lwcProjectController.wrapper wrap = new new_lwcProjectController.wrapper();
        wrap.isSelect = true;
        wrap.key = 'UNIQUE001';
        wrap.LineNumberId = cli.Id;
        wrap.LineNumberIdClone = cli.Id + '_0';
        wrap.proName = 'Test Product';
        wrap.proLineId = null;
        wrap.proNumber = null;
        wrap.ExpectedSalesMonth = Date.today();
        wrap.YourPONumber = 'PO123';
        wrap.YourPOIssueDate = Date.today();
        wrap.isDisabled = false;
        wrap.qty = 1;
        wrapList.add(wrap);
        
        String jsonData = JSON.serialize(wrapList);
        Integer totalProgram = 1;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.SaveProjectDeatils(con.Id, jsonData, totalProgram);
        Test.stopTest();
    }

    @IsTest
    static void testSaveProjectDetailsWithException() {
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.SaveProjectDeatils(null, 'invalid json', 0);
        Test.stopTest();
    }

    @IsTest
    static void testCreateUniqueNo() {
        Contract con = [SELECT Id, Quote__c FROM Contract LIMIT 1];
        
        Quote_Line_Item_Custom__c qli1 = new Quote_Line_Item_Custom__c(
            Quote__c = con.Quote__c,
            Product_Name__c = 'Test Product A',
            Manual_Product_Code__c = 'MPC001',
            Quantity__c = 1,
            Sr_No__c = 2
        );
        insert qli1;
        
        Quote_Line_Item_Custom__c qli2 = new Quote_Line_Item_Custom__c(
            Quote__c = con.Quote__c,
            Product_Name__c = 'Test Product B',
            Manual_Product_Code__c = 'MPC002',
            Quantity__c = 1,
            Sr_No__c = 3
        );
        insert qli2;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.createUniqueNo(con.Id);
        Test.stopTest();
    }

  /*  @IsTest
    static void testCreateUniqueNoWithExistingUniqueNo() {
        Contract con = [SELECT Id, Quote__c FROM Contract LIMIT 1];
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c(
            Quote__c = con.Quote__c,
            Product_Name__c = 'Existing Product',
            Project_Unique_No__c = 'EXISTING001',
            Quantity__c = 1,
            Sr_No__c = 4
        );
        insert qli;
        
        Contract_Line_Item__c cli = new Contract_Line_Item__c(
            ContractId__c = con.Id,
            Quote_Line_Item_Name__c = qli.Id,
            Quantity__c = 1,
            Sr_No__c = 5,
            Product_Name_2__c = 'Existing Product'
        );
        insert cli;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.createUniqueNo(con.Id);
        Test.stopTest();
    }	*/

    @IsTest
    static void testCreateUniqueNoWithProductNameOnly() {
        Contract con = [SELECT Id, Quote__c FROM Contract LIMIT 1];
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c(
            Quote__c = con.Quote__c,
            Product_Name__c = 'Product Name Only',
            Manual_Product_Code__c = null,
            Quantity__c = 1,
            Sr_No__c = 6
        );
        insert qli;
        
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.createUniqueNo(con.Id);
        Test.stopTest();
    }

    @IsTest
    static void testCreateUniqueNoWithException() {
        Test.startTest();
        Map<String, Object> result = new_lwcProjectController.createUniqueNo(null);
        Test.stopTest();
    }

    @IsTest
    static void testGetQuoteNumber() {
        Test.startTest();
        new_lwcProjectController.UserSetup us = new_lwcProjectController.getQuoteNumber();
        Test.stopTest();
    }

    @IsTest
    static void testGetQuoteNumberWithExistingUniqueNo() {
        Subsidiari_Master__c sub = [SELECT Id FROM Subsidiari_Master__c WHERE Name = 'ABC' LIMIT 1];
        Fiscal_Year_Master__c fy = [SELECT Id FROM Fiscal_Year_Master__c WHERE Active__c = true LIMIT 1];
        
        Unique_No__c uniqueNo = new Unique_No__c(
            Object_Name__c = 'Project Management',
            Subsidiary__c = sub.Id,
            Fiscal_Year__c = fy.Id,
            Serial_No__c = 5
        );
        upsert uniqueNo;
        
        Test.startTest();
        new_lwcProjectController.UserSetup us = new_lwcProjectController.getQuoteNumber();
        Test.stopTest();
    }

    @IsTest
    static void testIsUserAuthorized() {
        Contract con = [SELECT Id FROM Contract LIMIT 1];
        
        Test.startTest();
        new_lwcProjectController.AuthModel result = new_lwcProjectController.isUserAuthorized(con.Id);
        Test.stopTest();
    }

    @IsTest
    static void testIsUserAuthorizedWithDifferentSubsidiary() {
        Subsidiari_Master__c sub = new Subsidiari_Master__c(
            Name = 'ASI',
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
            Name='Sri Lanka',
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
            Name='Pune',
            State__c=state.Id
        );
        insert city;
        
        PIN_Code_Master__c pin = new PIN_Code_Master__c(
            Name='400002',
            City__c=city.Id
        );
        insert pin;
        
        List<User_Setup__c> existingUserSetup = [SELECT Id FROM User_Setup__c WHERE User__c = :UserInfo.getUserId() LIMIT 1];
        
        if (existingUserSetup.isEmpty()) {
            User_Setup__c userSetup = new User_Setup__c(
                User__c = UserInfo.getUserId(),
                Subsidiari__c = sub.Id,
                Country__c = country.id
            );
            insert userSetup;
        } else {
            User_Setup__c userSetup = existingUserSetup[0];
            userSetup.Subsidiari__c = sub.Id;
            userSetup.Country__c = country.id;
            update userSetup;
        }
        
        Contract con = [SELECT Id FROM Contract LIMIT 1];
        
        Test.startTest();
        new_lwcProjectController.AuthModel result = new_lwcProjectController.isUserAuthorized(con.Id);
        Test.stopTest();
    }

    @IsTest
    static void testParse() {
        List<new_lwcProjectController.wrapper> wrapList = new List<new_lwcProjectController.wrapper>();
        new_lwcProjectController.wrapper wrap = new new_lwcProjectController.wrapper();
        wrap.isSelect = true;
        wrap.key = 'TEST001';
        wrap.proName = 'Test Product';
        wrapList.add(wrap);
        
        String jsonData = JSON.serialize(wrapList);
        
        Test.startTest();
        List<new_lwcProjectController.wrapper> result = new_lwcProjectController.parse(jsonData);
        Test.stopTest();
    }
}