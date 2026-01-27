@isTest
public class ContractDiscountcontroller_test {
    public static testMethod void validateTestMethod1(){
        
        Boolean IsDiscountGreater = false;
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ABC';
        sub.Name__c = 'xyg';
        sub.Active__c = true;
        sub.Office__c = 'Airforce';
        sub.Rounding_Off_Digits__c = '10000';
        sub.Permitted_Currency__c = 'INR';
        sub.Permitted_Language__c = 'EN';
        sub.Discount_Level_1__c = 5;
        sub.Discount_Level_2__c = 10;
        sub.Discount_Level_3__c = 15;
        sub.Quote_Approval__c ='Line Item level';
        sub.Contract_Approval__c = 'Line Item level';
        sub.Negative_Discount__c = 10;
        insert sub;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = 'IP';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
          
        Country_List__c c1=new Country_List__c();
        c1.Name='test';
        c1.Subsidiary__c = sub.id;
        insert c1;
        
        Region__c r = new Region__c();
        r.Name = 'test';
        r.Name__c = 'test';
        r.Country__c =c1.id;
        Insert r;
        
        State_List__c s1=new State_List__c();
        s1.Name='test1';
        s1.Country__c = c1.id;
        s1.Region__c = r.id;
        insert s1;
        
        City_List__c o=new City_List__c();
        o.Name='test';
        o.State__c = s1.id;
        o.Subsidiary_Master__c = sub.id;
        insert o;
        
        User_Setup__c us = new User_Setup__c();
        us.Subsidiari__c = sub.Id;
        us.User__c = userInfo.getUserId();
        us.Country__c = c1.id;
        insert us;
        
        PIN_Code_Master__c pin = new PIN_Code_Master__c();
        pin.Active__c = true;
        //pin.City__c = o.Id;
        pin.Name='123456';
        insert pin;
        
     //   Account accObject = new Account( CurrencyIsoCode = 'INR' , Name = 'Test1');
      //  insert accObject;
        
        Account accObject=new Account(name='test', CurrencyIsoCode='INR', ERP_ID__c='Test ERP', Global_Customer_Name__c='MARS', Account_Type__c='LOCAL', Billing_Postal_ZIP_Code__c = pin.Id);
        insert accObject;
        
        accObject.Name = 'new update';
        accObject.Shipping_Postal_Code__c = 'qw234e';
        accObject.Pin_Code__c = '432221';
        accObject.Billing_City__c=o.id;
        accObject.Billing_Country__c=c1.Id;
        accObject.Billing_State__c=s1.Id;
        accObject.Shipping_City__c=o.Id;
        accObject.Shipping_Country__c=c1.Id;
        accObject.ShippingState=s1.id;
        
        update accObject;
        
        Opportunity oppObject = new Opportunity(AccountId = accObject.Id  , Name = 'Opp1' , CurrencyIsoCode = 'INR' , StageName	= 'New' , CloseDate = System.today() );
        insert oppObject;
        
        Product2 proObject = new Product2(CurrencyIsoCode	= 'INR' , Name = 'Pro1');
        insert proObject;
        
        Pricebook2	priObject = new Pricebook2(Name	= 'Pri1');
        insert priObject;
        
        Quote qObject = new Quote(Name = 'Quo1' , OpportunityId	= oppObject.Id ,Status = 'CREATED',
                             CountryCustom__c = 'abc' ,   
                                 CityCustom__c =  'abc',
                                 COUNTRY_CODE__c = 'AE'  ,
                               Insurance__c  = 'By Buyer' ,
                                Insurance_Amount__c = 35  , 
                                Freight__c  = 'By Buyer' ,
                                Freight_Amount__c =  25,
                                Exchange_Rate__c = 1,
                                Subsidiary__c = sub.Id);
        insert qObject;
        
        Contract cObject = new Contract(AccountId = accObject.Id   ,Status__c = 'CREATED', Quote__c = qObject.Id,
                                       Country_Text__c = 'Test1',State_Text__c = 'abc',City_Text__c = 'efg',COUNTRY_CODE__c = 'AD',Revision__c = 'Test',
            Numeric_Revision__c = 10,Insurance_Amount__c = 24,Freight_Amount1__c = 12, Subsidiary__c = sub.id, FY1__c = fym.id );
        insert cObject;
        
        Contract_Line_Item__c ContLineObj = new Contract_Line_Item__c();
        ContLineObj.ContractId__c = cObject.Id;
        ContLineObj.Product2Id__c = proObject.Id;
        ContLineObj.Approval_Note__c = 'This is for test record';
        ContLineObj.Division__c = 'Machine';
        ContLineObj.Discount__c = 16.0;
        ContLineObj.Discount_Allowed__c = 20.0;
        ContLineObj.List_Price__c = 100;
        ContLineObj.Quantity__c = 10;
        ContLineObj.Level_Of_Ceiling__c = '1000';   
        ContLineObj.Grand_Total_before_TCS__c = 1000;
        insert ContLineObj;
        
        Contract_Line_Item__c ContLineObj2 = new Contract_Line_Item__c();
        ContLineObj2.ContractId__c = cObject.Id;
        ContLineObj2.Product2Id__c = proObject.Id;
        ContLineObj2.Approval_Note__c = 'This is for test record';
        ContLineObj2.Division__c = 'Machine';
        ContLineObj2.Discount__c = 16.0;
        ContLineObj2.Discount_Allowed__c = 20.0;
        ContLineObj2.List_Price__c = 100;
        ContLineObj2.Quantity__c = 10;
        ContLineObj2.Level_Of_Ceiling__c = '1000';   
        ContLineObj2.Grand_Total_before_TCS__c = 1000;
        insert ContLineObj2;
        
        Contract_Line_Item__c ContLineObj3 = new Contract_Line_Item__c();
        ContLineObj3.ContractId__c = cObject.Id;
        ContLineObj3.Product2Id__c = proObject.Id;
        ContLineObj3.Approval_Note__c = 'This is for test record';
        ContLineObj3.Division__c = 'Machine';
        ContLineObj3.Discount__c = 16.0;
        ContLineObj3.Discount_Allowed__c = 20.0;
        ContLineObj3.List_Price__c = 100;
        ContLineObj3.Quantity__c = 10;
        ContLineObj3.Level_Of_Ceiling__c = '1000';   
        ContLineObj3.Grand_Total_before_TCS__c = 1000;
        insert ContLineObj3;
        
        Contract_Line_Option__c cliOptions = new Contract_Line_Option__c();
        cliOptions.Contract_Line_Item__c = ContLineObj.Id;
        cliOptions.ContractId__c = cObject.Id;
        cliOptions.Cancellation_Reason__c = 'Cancel Product';
        cliOptions.Cancelled__c = false;
        cliOptions.Discount__c = 20;
        cliOptions.Quantity__c = 3;
        insert cliOptions;
        
        Contract_Line_Option__c cliOptions2 = new Contract_Line_Option__c();
        cliOptions2.Contract_Line_Item__c = ContLineObj.Id;
        cliOptions2.ContractId__c = cObject.Id;
        cliOptions2.Cancellation_Reason__c = 'Cancel Product';
        cliOptions2.Cancelled__c = true;
        cliOptions2.Discount__c = 20;
        cliOptions2.Quantity__c = 3;
        insert cliOptions2;
        

        Test.StartTest();
        ApexPages.StandardController conobj = new ApexPages.StandardController(cObject);
        ApexPages.currentPage().getParameters().put('Id',cObject.id);
        ContractDiscountcontroller OBJ = new ContractDiscountcontroller(conobj );
        
        PageReference testPage = Page.ContractSummaryFor_HOD;
        Test.setCurrentPage(testPage);
      /*  OBJ.UpdateDataOnDiscount();
        OBJ.gotoContract();
        OBJ.onLineItemDiscountUpdate();
        OBJ.dummy();  */
        //OBJ.cancel();
        Test.StopTest();
        
        //ApexPages.StandardController sc = new ApexPages.StandardController(cObject);
        //ContractDiscountcontroller cdc = new ContractDiscountcontroller (sc);
        //cdc.UpdateDataOnDiscount();
        
    }
    
    public static testMethod void validateTestMethod2(){
        Boolean IsDiscountGreater = false;
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'AB2';
        sub.Name__c = 'xyg';
        sub.Active__c = true;
        sub.Office__c = 'Airforce';
        sub.Rounding_Off_Digits__c = '10000';
        sub.Permitted_Currency__c = 'INR';
        sub.Permitted_Language__c = 'EN';
        sub.Discount_Level_1__c = 5;
        sub.Discount_Level_2__c = 10;
        sub.Discount_Level_3__c = 15;
        sub.Quote_Approval__c ='Line Item level';
        sub.Contract_Approval__c = 'Line Item level';
        sub.Negative_Discount__c = 10;
        insert sub;
        
        Fiscal_Year_Master__c fym=new Fiscal_Year_Master__c();
        fym.Fiscal_Year_Start_Date__c=System.today()-200;
        fym.Fiscal_Year_End_Date__c=System.today()+165;
        fym.Active__c=true;
        fym.Name='AA';
        insert fym;
          
        Country_List__c c1=new Country_List__c();
        c1.Name='test';
        c1.Subsidiary__c = sub.id;
        insert c1;
        
        Region__c r = new Region__c();
        r.Name = 'test';
        r.Name__c = 'test';
        r.Country__c =c1.id;
        Insert r;
        
        State_List__c s1=new State_List__c();
        s1.Name='test1';
        s1.Country__c = c1.id;
        s1.Region__c = r.id;
        insert s1;
        
        City_List__c o=new City_List__c();
        o.Name='test';
        o.State__c = s1.id;
        o.Subsidiary_Master__c = sub.Id;
        insert o;
        
        User_Setup__c us = new User_Setup__c();
        us.Subsidiari__c = sub.Id;
        us.User__c = userInfo.getUserId();
        us.Country__c = c1.id;
        insert us;
        
        PIN_Code_Master__c pin = new PIN_Code_Master__c();
        pin.Active__c = true;
        //pin.City__c = o.Id;
        pin.Name='123456';
        insert pin;
        
     //   Account accObject = new Account( CurrencyIsoCode = 'INR' , Name = 'Test1');
      //  insert accObject;
        
        Account accObject=new Account(name='test', CurrencyIsoCode='INR', ERP_ID__c='Test ERP', Global_Customer_Name__c='MARS', Account_Type__c='LOCAL', Billing_Postal_ZIP_Code__c = pin.Id);
        insert accObject;
        
        accObject.Name = 'new update';
        accObject.Shipping_Postal_Code__c = 'qw234e';
        accObject.Pin_Code__c = '432221';
        accObject.Billing_City__c=o.id;
        accObject.Billing_Country__c=c1.Id;
        accObject.Billing_State__c=s1.Id;
        accObject.Shipping_City__c=o.Id;
        accObject.Shipping_Country__c=c1.Id;
        accObject.ShippingState=s1.id;
        
        update accObject;
        
        Opportunity oppObject = new Opportunity(AccountId = accObject.Id  , Name = 'Opp1' , CurrencyIsoCode = 'INR' , StageName	= 'New' , CloseDate = System.today() );
        insert oppObject;
        
        Product2 proObject = new Product2(CurrencyIsoCode	= 'INR' , Name = 'Pro1');
        insert proObject;
        
        Pricebook2	priObject = new Pricebook2(Name	= 'Pri1');
        insert priObject;
        
        Quote qObject = new Quote(Name = 'Quo1' , OpportunityId	= oppObject.Id ,Status = 'CREATED',
                                  Subsidiary__c = sub.Id,
                             CountryCustom__c = 'abc' ,   
                                 CityCustom__c =  'abc',
                                 COUNTRY_CODE__c = 'AE'  ,
                               Insurance__c  = 'By Buyer' ,
                                Insurance_Amount__c = 35  , 
                                Freight__c  = 'By Buyer' ,
                                Freight_Amount__c =  25,
                                 Exchange_Rate__c = 1);
        insert qObject;
        
        Contract cObject = new Contract(AccountId = accObject.Id   ,Status__c = 'CREATED', Quote__c = qObject.Id,
                                       Country_Text__c = 'Test1',State_Text__c = 'abc',City_Text__c = 'efg',COUNTRY_CODE__c = 'AD',Revision__c = 'Test',
            Numeric_Revision__c = 10,Insurance_Amount__c = 24,Freight_Amount1__c = 12, Subsidiary__c = sub.id, FY1__c = fym.id );
        insert cObject;
        
        List<Contract_Line_Item__c> Clitem = new List<Contract_Line_Item__c>();
        Contract_Line_Item__c ContLineObj = new Contract_Line_Item__c(ContractId__c = cObject.Id, Product2Id__c = proObject.Id,
                                                                      Approval_Note__c = 'This is for test record',
                                                                     Division__c = 'Machine', Discount__c = 16.0, Discount_Allowed__c = 20.0, 
                                                                     List_Price__c = 100, Quantity__c = 10, Level_Of_Ceiling__c = '1000', 
                                                                     Grand_Total_before_TCS__c = 1000);
        Clitem.add(ContLineObj);
        insert Clitem;
        
        List<Contract_Line_Option__c> clcList = new List<Contract_Line_Option__c>();
        Contract_Line_Option__c clc = new Contract_Line_Option__c(Contract_Line_Item__c = ContLineObj.Id, ContractId__c = cObject.Id,
                                                                  Cancellation_Reason__c = 'Cancel Product', Cancelled__c = false, Discount__c = 25,
                                                                  Quantity__c = 3);
        clcList.add(clc);
        insert clcList;
        

        Test.StartTest();
        ApexPages.StandardController conobj = new ApexPages.StandardController(cObject);
        ApexPages.currentPage().getParameters().put('Id',cObject.id);
        ContractDiscountcontroller OBJ = new ContractDiscountcontroller(conobj );
        
        PageReference testPage = Page.ContractSummaryFor_HOD;
        Test.setCurrentPage(testPage);
      /*  OBJ.UpdateDataOnDiscount();
        OBJ.gotoContract();
        OBJ.onLineItemDiscountUpdate();
        OBJ.dummy();  */
        //OBJ.cancel();
        Test.StopTest();
        
        //ApexPages.StandardController sc = new ApexPages.StandardController(cObject);
        //ContractDiscountcontroller cdc = new ContractDiscountcontroller (sc);
        //cdc.UpdateDataOnDiscount();
        
    }
    
}