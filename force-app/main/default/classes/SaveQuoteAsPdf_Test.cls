@IsTest
private class SaveQuoteAsPdf_Test {

    @TestSetup
    static void setupData() {

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
            Legal_Name__c='Test Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Test Opportunity',
            AccountId=acc.Id,
            StageName='Prospecting',
            CloseDate=Date.today(),
            CurrencyIsoCode = 'USD'
        );
        insert opp;

        Contact con = new Contact(
            FirstName='Test',
            LastName='Contact',
            Email='test@test.com',
            AccountId=acc.Id
        );
        insert con;

        Quote_Template__c qtTemp = new Quote_Template__c(
            Name='Template',
            Active__c=true,
            Subsidiary__c=sub.Id,
            Label__c='Label'
        );
        insert qtTemp;

        Quote_Template_Line__c termLine = new Quote_Template_Line__c(
            Quote_Template__c = qtTemp.Id,
            Active__c = true,
            Is_Terms_Condition__c = true,
            Content__c = 'Test Terms',
            Sr_No__c = 1
        );
        insert termLine;
        
        Quote_Template_Line__c remarkLine = new Quote_Template_Line__c(
            Quote_Template__c = qtTemp.Id,
            Active__c = true,
            Is_General_Remarks__c = true,
            Content__c = 'Test Remarks',
            Sr_No__c = 1
        );
        insert remarkLine;
        
        Quote_Template_Line__c provisionLine = new Quote_Template_Line__c(
            Quote_Template__c = qtTemp.Id,
            Active__c = true,
            Is_General_Provision__c = true,
            Content__c = 'Test Provisions',
            Sr_No__c = 1
        );
        insert provisionLine;

        Quote qt = new Quote(
            Name='Test Quote',
            OpportunityId=opp.Id,
            ContactId=con.Id,
            Status='Draft',
            Freight__c='By Buyer',
            Insurance__c='By Buyer',
            Quote_Template__c=qtTemp.Id,
            Quote_Number1__c='TEST-001',
            QU_REVISION_NUMBER__c='001',
            CurrencyIsoCode='USD',
            Price_in_Word_Required__c=true,
            Quote_Release_Date__c=Date.today(),
            ADDRESS_LINE_1__c='Line1',
            CityCustom__c='Mumbai',
            StateCustom__c='MH',
            POSTAL_CODE__c='400001',
            CountryCustom__c='India',
            Advance_Percentage__c = 10
        );
        insert qt;

        Id stdPb = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name='Test Product',
            ProductCode='TP01',
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

        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c(
            Quote__c=qt.Id,
            Product__c=prod.Id,
            Product_Name__c='Test Product',
            Quantity__c=2,
            Product_Description__c='@Test Description',
            UOM__c='Pcs',
            Sr_No__c=1,
            Is_Tax__c=false,
            Division__c = 'MOLD'
        );
        insert qli;

        Quote_Line_Options__c qlo = new Quote_Line_Options__c(
            Quote__c=qt.Id,
            Quote_Line_Item_Custom__c=qli.Id,
            Manual_Product_Name__c='Test Option',
            Serial_Number__c=1,
            Pdf_Checked__c=false,
            Name_Hide__c = false,
            Description__c = '@Option Description',
            Select_Option__c = true
        );
        insert qlo;
        
        Quote_Line_Options__c qlo2 = new Quote_Line_Options__c(
            Quote__c=qt.Id,
            Quote_Line_Item_Custom__c=qli.Id,
            Manual_Product_Name__c='.Hidden Option',
            Serial_Number__c=2,
            Pdf_Checked__c=false,
            Name_Hide__c = true,
            Description__c = '#Hidden Description'
        );
        insert qlo2;

        Additional_Document__c doc = new Additional_Document__c(
            Name='Test Doc',
            Active__c=true,
            Type__c='Quote',
            OwnerId=UserInfo.getUserId(),
            Is_User_Specific__c=true,
            Subsidiary__c = sub.Id
        );
        insert doc;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test Note',
            PathOnClient = 'TestNote.txt',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = qt.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;
    }

    static ApexPages.StandardController getController(){
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        Quote qt = quotes[0];
        Test.setCurrentPage(Page.pdfPreview);
        ApexPages.currentPage().getParameters().put('id',qt.Id);
        return new ApexPages.StandardController(qt);
    }

    @IsTest
    static void testCreateQuote(){
        Test.startTest();
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.stopTest();
    }

    @IsTest
    static void testCreateQuoteWithASISubsidiary(){
        Subsidiari_Master__c asiSub = [SELECT Id, Name FROM Subsidiari_Master__c WHERE Name = 'ABC' LIMIT 1];
        asiSub.Name = 'ASI';
        update asiSub;
        Test.startTest();
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.stopTest();
    }

    @IsTest
    static void testSave(){
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        Test.startTest();
        PageReference pr = ctrl.save();
        Test.stopTest();
    }

    @IsTest
    static void testSaveAndSend(){
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.emailId='test@test.com';
        ctrl.subject='Test Subject';
        ctrl.body='Test Body';
        ctrl.CC_Addresses='cc1@test.com,cc2@test.com';
        Test.startTest();
        PageReference pr = ctrl.saveAndSendcall();
        Test.stopTest();
    }
    
    @IsTest
    static void testSaveAndSendWithNoEmail(){
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.emailId = null;
        ctrl.subject='Test Subject';
        ctrl.body='Test Body';
        Test.startTest();
        PageReference pr = ctrl.saveAndSendcall();
        Test.stopTest();
    }

    @IsTest
    static void testAttachQuote(){
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.startTest();
        ctrl.attachQuote();
        Test.stopTest();
    }

    @IsTest
    static void testModal(){
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        Test.startTest();
        ctrl.showModal();
        if(ctrl.addDocs != null && ctrl.addDocs.size() > 0) {
            ctrl.addDocs[0].isSelected = true;
        }
        ctrl.SaveValues();
        ctrl.showModal();
        ctrl.closePopup();
        Test.stopTest();
    }

    @IsTest
    static void testOptions(){
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.startTest();
        ctrl.openOptionsModal();
        ctrl.saveOptions();
        ctrl.closeOptions();
        ctrl.updateOptions();
        Test.stopTest();
    }

 /*   @IsTest
    static void testSaveToQuote(){
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        Test.startTest();
        PageReference pr = ctrl.SaveToQuote();
        Test.stopTest();
    }

    @IsTest
    static void testSaveAndEmailQuote(){
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        Test.startTest();
        PageReference pr = ctrl.SaveAndEmailQuote();
        Test.stopTest();
    }	*/

    @IsTest
    static void testCancel(){
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        Test.startTest();
        PageReference pr = ctrl.Cancel();
        Test.stopTest();
    }

    @IsTest
    static void testAddMethod(){
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        Test.startTest();
        ctrl.add();
        Test.stopTest();
    }

    @IsTest
    static void testSystemAdminUser(){
        User systemAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(systemAdmin) {
            Test.startTest();
            SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
            ctrl.CreateQuote();
            Test.stopTest();
        }
    }

  /*  @IsTest
    static void testNonSystemAdminUser(){
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User standardUser = new User(
            Alias = 'standrd',
            Email = 'standarduser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser' + DateTime.now().getTime() + '@test.com'
        );
        insert standardUser;
        System.runAs(standardUser) {
            Test.startTest();
            SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
            ctrl.CreateQuote();
            Test.stopTest();
        }
    }	*/

 /*   @IsTest
    static void testDifferentQuoteStatuses(){
        Quote qt = [SELECT Id, Status FROM Quote LIMIT 1];
        qt.Status = 'RELEASED';
        qt.PROBABILITY__c = 'A';
        qt.Expected_Month_of_Consolidated_Order__c = system.today();
        update qt;
        Test.startTest();
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.stopTest();
        qt.Status = 'DISCARD/VOID';
        update qt;
        Test.startTest();
        ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.stopTest();
    }	*/

    @IsTest
    static void testWithNullQuoteReleaseDate(){
        Quote qt = [SELECT Id, Quote_Release_Date__c FROM Quote LIMIT 1];
        qt.Quote_Release_Date__c = null;
        update qt;
        Test.startTest();
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.stopTest();
    }

 /*   @IsTest
    static void testWithDifferentBarcodeScenarios(){
        Quote qt = [SELECT Id, Quote_Number1__c, QU_REVISION_NUMBER__c FROM Quote LIMIT 1];
        qt.Quote_Number1__c = 'TEST-002';
        qt.QU_REVISION_NUMBER__c = '';
        update qt;
        Test.startTest();
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.stopTest();
        qt.QU_REVISION_NUMBER__c = '002';
        update qt;
        Test.startTest();
        ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.stopTest();
    }	*/
    
    @IsTest
    static void testFreightAndInsuranceValues(){
        Quote qt = [SELECT Id, Freight__c, Insurance__c FROM Quote LIMIT 1];
        qt.Freight__c = 'By Seller';
        qt.Insurance__c = 'By Seller';
        update qt;
        Test.startTest();
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        Test.stopTest();
    }
    
    @IsTest
    static void testWithExistingAttachments(){
        Quote qt = [SELECT Id, Name FROM Quote LIMIT 1];
        Attachment existingAtt = new Attachment(
            ParentId = qt.Id,
            Name = 'Test_V1.pdf',
            Body = Blob.valueOf('Test')
        );
        insert existingAtt;
        Test.startTest();
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        ctrl.attachQuote();
        Test.stopTest();
    }
    
    @IsTest
    static void testPriceInWordNotRequired(){
        Quote qt = [SELECT Id, Price_in_Word_Required__c FROM Quote LIMIT 1];
        qt.Price_in_Word_Required__c = false;
        update qt;
        Test.startTest();
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.stopTest();
    }
    
    @IsTest
    static void testINRCurrencyForWordConversion(){
        Quote qt = [SELECT Id, CurrencyIsoCode FROM Quote LIMIT 1];
        qt.CurrencyIsoCode = 'USD';
        update qt;
        Test.startTest();
        SaveQuoteAsPdf ctrl = new SaveQuoteAsPdf(getController());
        ctrl.CreateQuote();
        Test.stopTest();
    }
}