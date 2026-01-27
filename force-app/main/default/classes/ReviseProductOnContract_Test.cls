@isTest
public class ReviseProductOnContract_Test {
    public static testMethod void testMethod1(){
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
        sub.Additional_Margin__c = 10;
        sub.Price_Book__c = Test.getStandardPricebookId();
        sub.Quote_Approval__c ='Line Item level';
        sub.Contract_Approval__c = 'Line Item level';
        sub.D1__c = 10;
        sub.M1__c = 10;
        insert sub;
		
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = '44';
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
        insert o;
        
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = c1.Id;
        insert us;
    
        Account acc = new Account();
        acc.Name = 'acc anem';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '250001';
        acc.Type = 'Press';
        insert acc;
        
		lead ld= new lead(lastName='Test User', Status='New', Company='Test Company');
        insert ld;
		
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.IsActive = true;
        insert pb;
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.Pricebook2Id = pb.id;
        op.Subsidiary__c = sub.id;
        insert op;
        
        Product2 prod = new Product2();
        prod.name = 'prod namen';
        prod.Subsidiari__c = sub.Id;
        prod.Scope_of_Mold__c = 'a';
        prod.Model__c = 'ASB-12M' ; 
        prod.Product_Type__c = 'MC';
        prod.Number_Of_Cavity_Mould__c = 5 ;
        insert prod;
        
        Product2 prod1 = new Product2();
        prod1.name = 'prod namen 1';
        prod1.Subsidiari__c = sub.Id;
        prod1.Scope_of_Mold__c = 'a';
        prod1.Model__c = 'ASB-12M' ; 
        prod1.Product_Type__c = 'MC';
        prod1.Number_Of_Cavity_Mould__c = 5 ;
        insert prod1;
        
        quote qt = new quote();
        qt.Contact__c = con.Id;
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        qt.Application__c = 'EDIBLE OIL';
        qt.Zero_Cooling__c = 'Yes';
        qt.Fax = '1234562';
        qt.SHIP_TO_ADDRESS_LINE_1__c = 'Test Ship 1';
        qt.SHIP_TO_ADDRESS_LINE_2__c = 'Test Ship 2';
        qt.SHIP_TO_ADDRESS_LINE_3__c = 'test Ship 3';
        qt.SHIP_TO_POSTAL_CODE__c = '201001';
        qt.ACCOUNT_BUSINESS__c = 'CONVERTER';
        qt.AdditionalName = 'Test Additional';
        qt.Insurance__c = 'By Buyer';
        qt.Freight__c = 'By Buyer';
        qt.ShippingName = 'Not Null Shipping';
        qt.FY__c = 'FY';
        qt.TYPE__c = 'GLOBAL';
        qt.ADDRESS_LINE_1__c = 'Address Line 1';
        qt.ADDRESS_LINE_2__c = 'Address Line 2';
        qt.ADDRESS_LINE_3__c = 'Address Line 3';
        qt.CITY__c = 'Noida';
        qt.BillingName = 'Test Billing Name';
        qt.Email = 'test@tets.com';
        qt.Ship_To_City__c = 'mrt';
        qt.Ship_To_State__c = 'up';
        qt.Ship_To_Country__c = 'india';
        qt.Description = 'asd';
        qt.ShippingHandling = 123;
        qt.Phone = '7898562485';
        qt.ACCOUNT_TYPE__c = 'GLOBAL';
        qt.Tax = 12;
        qt.MFG_AT__c = 'INDIA';
        qt.Shipping_And_Handling__c  =32;
        qt.Approval_Status_From_HOD__c = 'Approved';
        qt.Exchange_Rate__c = 1;
        insert qt;
        
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Application__c = 'EDIBLE OIL';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        qli.UOM__c = 'ABC';
        qli.Product__c = prod.Id;
        qli.Level_Of_Ceiling__c = '10' ;
        qli.Mach_Mold_No__c = 'AB';
        qli.Expected_Delivery_date__c = system.today() +2;
        qli.Expected_Customer_PO__c = system.today() + 4;
        qli.Expected_Drawing_Final__c= system.today() + 14;
        qli.Drawing_No__c = 'Tst';
        qli.Product_Description__c = 'etst';
        qli.Payment_Terms__c = '100% Payment Before Dispatch';
        qli.Product_Name__c = 'ABC';
        qli.Discount_Approval_Note__c= 'ABC';
        qli.Zero_Cooling_2__c = 'Yes';
        qli.Class_2__c = 'DEVELOPMENT';
        qli.MFG_AT__c = 'INDIA';
        qli.Advance_Percentage__c = 5.0;
        qli.division__c = 'MOLD';
        insert qli;
        
        
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Product__c = prod.Id;
        qlo.Discount__c = 1.0 ;
        qlo.Description__c = 'Test';
        qlo.Price_Type__c = 1;
        qlo.Sales_price_Total__c = 11;
        qlo.Discount_Description__c = 'Test';
        qlo.Manual_Option__c= 'Abc';
        qlo.Mould_Cavity__c= 12;
        qlo.Manual_Product_Name__c= 'Abc';
        qlo.Manual_Option_Function__c= 'Add';
        qlo.Other_Charges__c= 'Test';
        qlo.Other_Charges_Base_Price__c=11;
        qlo.Quantity__c=1;
        qlo.Option_Number__c='Abc';
        qlo.Other_Charges_Function__c= 'Add';
        qlo.Select_Option__c= true;
        qlo.Discount__c=1.0;
        insert qlo;
        
        
        Quote_Line_Item_Custom__c qli2 = new Quote_Line_Item_Custom__c();
        qli2.Quote__c = qt.id;
        qli2.Discount__c = 12;
        qli2.Quantity__c = 1;
        qli2.Application__c = 'EDIBLE OIL';
        qli2.Discount_Approval_Note__c = 'sfasf';
        qli2.Scope_of_mould__c = 'ML';
        qli2.List_Price__c = 12;
        qli2.Is_Manual__c = true;
        qli2.UOM__c = 'ABC';
        qli2.Product__c = prod1.Id;
        qli2.Level_Of_Ceiling__c = '10' ;
        qli2.Mach_Mold_No__c = 'AB';
        qli2.Expected_Delivery_date__c = system.today() +2;
        qli2.Expected_Customer_PO__c = system.today() + 4;
        qli2.Expected_Drawing_Final__c= system.today() + 14;
        qli2.Drawing_No__c = 'Tst';
        qli2.Product_Description__c = 'etst';
        qli2.Payment_Terms__c = '100% Payment Before Dispatch';
        qli2.Product_Name__c = 'ABC';
        qli2.Discount_Approval_Note__c= 'ABC';
        qli2.Zero_Cooling_2__c = 'Yes';
        qli2.Class_2__c = 'DEVELOPMENT';
        qli2.MFG_AT__c = 'INDIA';
        qli2.Advance_Percentage__c = 5.0;
        qli2.division__c = 'MOLD';
        insert qli2;
        
        Quote_Line_Options__c qlo2 = new Quote_Line_Options__c();
        qlo2.Quote__c = qt.id;
        qlo2.Quote_Line_Item_Custom__c = qli2.id;
        qlo2.Product__c = prod1.Id;
        qlo2.Discount__c = 1.0 ;
        qlo2.Description__c = 'Test';
        qlo2.Price_Type__c = 1;
        qlo2.Sales_price_Total__c = 11;
        qlo2.Discount_Description__c = 'Test';
        qlo2.Manual_Option__c= 'Abc';
        qlo2.Mould_Cavity__c= 12;
        qlo2.Manual_Product_Name__c= 'Abc';
        qlo2.Manual_Option_Function__c= 'Add';
        qlo2.Other_Charges__c= 'Test';
        qlo2.Other_Charges_Base_Price__c=11;
        qlo2.Quantity__c=1;
        qlo2.Option_Number__c='Abc';
        qlo2.Other_Charges_Function__c= 'Add';
        qlo2.Select_Option__c= true;
        qlo2.Discount__c=1.0;
        insert qlo2;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.Level_Of_Ceiling__c = '100';   
        conLI.Quote_Line_Item_Name__c = qli.id;
        conLI.Shipping_charges__c = 11;
        conLI.Insurance_Charges__c = 10;
        conLI.Packing_Charges__c = 10;
        conLi.List_Price__c	 = 100;
        conLI.Quantity__c = 1;
        conLI.IGST__c = 1.0;
        conLI.SGST__c = 1.0;
        conLI.CGST__c = 1.0;
        insert conLI;   
        
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        conLO.Sales_price_Total__c = 123;
        conLO.Manual_Option_List_Price__c = -12;
        conLO.Price_Type__c = 1;
        conLO.Quantity__c = 32;
        conLO.Product__c = prod.Id;
        conLO.Discount__c = 2;
        insert conLO;
        
        system.debug('Quantity_Line_Item__c'+conLO.Quantity_Line_Item__c);
        system.debug('Final_Price_Clone__c'+conLO.Final_Price_Clone__c);
         
        cont.Status = 'Hold for Revision';
        update cont;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        ReviseProductOnContract test1 = new ReviseProductOnContract(sc);
        PageReference pageRef = Page.ReviseProductOnContract; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        test1.UpdateProductOnContract();
        Test.StopTest(); 
    }
    
}