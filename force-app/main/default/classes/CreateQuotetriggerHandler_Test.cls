@isTest
public class CreateQuotetriggerHandler_Test {
    
    public Static testMethod void unitTest1(){  
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
        
        Fiscal_Year_Master__c fym=new Fiscal_Year_Master__c();
        fym.Fiscal_Year_Start_Date__c=System.today()-200;
        fym.Fiscal_Year_End_Date__c=System.today()+165;
        fym.Active__c=true;
        fym.Name='44';
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
        o.Subsidiary_Master__c= sub.Id;
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
        acc.Billing_Postal_ZIP_Code__c = acc.id;
        acc.Pin_Code__c = '250001';
        acc.Type = 'Press';
        acc.Billing_Country__c  =c1.Id;
        acc.Billing_State__c =s1.id;
        acc.Billing_City__c =o.Id;
        acc.BillingCountry ='India';
        acc.BillingState ='Goa';
        acc.BillingCity = 'Goa';
        acc.BillingPostalCode = '123321';
        acc.BillingCountry ='India';
        acc.ShippingState ='Goa';
        acc.ShippingCity = 'Goa';
        acc.ShippingPostalCode = '123321';
        acc.ShippingCountry  ='India';
        //acc.Region__c ='NORTH';
        acc.Country_Code__c ='IN';
        acc.Account_Business__c  ='CONVERTER';
        acc.Account_Type__c='LOCAL';
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        con.Phone = '9837371155';
        con.Email = 'vd@gmail.com';
        con.fax ='8384838485';
        insert con;
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.APPLICATION__c = 'DTR - Detergent';
        op.MFG_AT__c ='INDIA';
        op.Zero_Cooling__c ='Yes';
        //op.Probability__c  = 'A';
        op.Contact__c = con.Id;
        insert op;
        
        Map <id,Quote> qmap = new Map <id,Quote>();
        quote qt = new quote();
        qt.Status = 'RELEASED';
        qt.Contact__c = con.Id;
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Discount__c = 12;
        qt.Quote_Number__c = '1234';
        qt.Exchange_Rate__c = 1;
        qt.PROBABILITY__c = 'A';
        insert qt;
        
        qt.Status = 'RELEASED';
        qt.Name = 'qt test upd';
        //qt.Discount__c = 10;
        qt.Quote_Number__c = '1234';
        qt.Discount__c = 13;
        qt.Expiration_Date_Change_Reason__c = 'Changed Expired date';
        update qt;
        qmap.put(qt.id, qt);
        quote qt1 = new quote();
        qt1.Status = 'RELEASED';
        qt1.Name = 'qt test';
        qt1.OpportunityId = op.id;
        qt1.Discount__c = 12;
        qt1.Quote_Number__c = '1234';
        qt1.Expiration_Date_Change_Reason__c = 'Changed Expired date';
        qt1.Exchange_Rate__c = 1;
        insert qt1;
        List<Quote> qt1List = new List<Quote>();
        List<Quote> qt1List1 = new List<Quote>();
        qt1List.add(qt);
        qt1List1.add(qt1);
        // insert qt1List;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Application__c = 'EOL - Edible oil/Soy sauce';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        qli.Level_Of_Ceiling__c = '1000';
        qli.MFG_AT__c = 'INDIA';
        qli.Mach_Mold_No__c = 'wqwet';
        qli.Zero_Cooling_2__c = 'Yes';
        qli.Cavity__c = 2;
        qli.Product_Type__c = 'MC';
        qli.Advance_Percentage__c = 10;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
        insert qli;
        List<Quote_Line_Item_Custom__c> qliList = new List<Quote_Line_Item_Custom__c>();
        qliList.add(qli);
        
        /*Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        //qlo.Product__c = pro.id;
        qlo.Description__c = 'sfsd';
        qlo.Discount__c = 12;
        qlo.Discount_Type__c = 'Percent';
        qlo.quantity__c = 2;
        qlo.Discount_Description__c = 'adas';
        qlo.Mould_Cavity__c = 2;
        qlo.description__c = 'sfsdfds';
        qlo.Manual_Product_Name__c = 'name dummy';
        //insert qlo;
        List<Quote_Line_Options__c> qloList = new List<Quote_Line_Options__c>();
        qloList.add(qlo);
        insert qloList;  */      
        CreateQuotetriggerHandler cqth = new CreateQuotetriggerHandler ();
        Test.starttest();
        cqth.QuoteUpdate(qt.id);
        CreateQuotetriggerHandler.updateQLIDiscount(qmap,qmap.values());
        CreateQuotetriggerHandler.updateQLODiscount(qmap,qmap.values());
        CreateQuotetriggerHandler.updateQuote(new List<Id>{qt.Id});
        
        
        
        Test.stoptest();
    }
    
    
    public Static testMethod void unitTest2(){  
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
        
        Fiscal_Year_Master__c fym=new Fiscal_Year_Master__c();
        fym.Fiscal_Year_Start_Date__c=System.today()-200;
        fym.Fiscal_Year_End_Date__c=System.today()+165;
        fym.Active__c=true;
        fym.Name='44';
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
        o.Subsidiary_Master__c=sub.id;
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
        acc.Billing_Postal_ZIP_Code__c=acc.id;
        acc.Billing_Country__c  =c1.Id;
        acc.Billing_State__c =s1.id;
        acc.Billing_City__c =o.Id;
        acc.BillingCountry ='India';
        acc.BillingState ='Goa';
        acc.BillingCity = 'Goa';
        acc.BillingPostalCode = '123321';
        acc.BillingCountry ='India';
        acc.ShippingState ='Goa';
        acc.ShippingCity = 'Goa';
        acc.ShippingPostalCode = '123321';
        acc.ShippingCountry  ='India';
        acc.Shipping_Country__c = c1.id;
        acc.Shipping_State__c = s1.id;
        acc.Shipping_City__c =o.id;
        acc.Shipping_Address_Line_1__c ='1,qwerty';
        acc.Shipping_Address_Line_2__c ='test 2';
        acc.Shipping_Address_Line_3__c = 'test 3';
        //acc.Region__c ='NORTH';
        acc.Country_Code__c ='IN';
        acc.Account_Business__c  ='CONVERTER';
        acc.Account_Type__c='LOCAL';
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        con.Phone = '9837371155';
        con.Email = 'vd@gmail.com';
        con.fax ='8384838485';
        insert con;
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.APPLICATION__c = 'DTR - Detergent';
        op.MFG_AT__c ='INDIA';
        op.Zero_Cooling__c ='Yes';
        //op.Probability__c  = 'A';
        op.Contact__c = con.Id;
        op.FY__c='24';
        insert op;
        
        Map <id,Quote> qmap = new Map <id,Quote>();
        quote qt = new quote();
        qt.Status = 'Draft';
        qt.Contact__c = con.Id;
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Discount__c = 1;
        qt.Quote_Number__c = '1234';
        qt.Exchange_Rate__c = 1;
qt.PROBABILITY__c = 'A';        insert qt;
        
        qt.Discount__c = 12;
        update qt;
        
        qmap.put(qt.id, qt);
        
         
       
       
        List<Quote> qt1List = new List<Quote>();
        List<Quote> qt1List1 = new List<Quote>();
        qt1List.add(qt);

        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Application__c = 'EOL - Edible oil/Soy sauce';
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        qli.Level_Of_Ceiling__c = '1000';
        qli.MFG_AT__c = 'INDIA';
        qli.Mach_Mold_No__c = 'wqwet';
        qli.Zero_Cooling_2__c = 'Yes';
        qli.Cavity__c = 2;
        qli.Product_Type__c = 'MC';
        qli.Advance_Percentage__c = 10;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
        insert qli;
        List<Quote_Line_Item_Custom__c> qliList = new List<Quote_Line_Item_Custom__c>();
        qliList.add(qli);
        
       /* Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        //qlo.Product__c = pro.id;
        qlo.Description__c = 'sfsd';
        qlo.Discount__c = 12;
        qlo.Discount_Type__c = 'Percent';
        qlo.quantity__c = 2;
        qlo.Discount_Description__c = 'adas';
        qlo.Mould_Cavity__c = 2;
        qlo.description__c = 'sfsdfds';
        qlo.Manual_Product_Name__c = 'name dummy';
        //insert qlo;
        List<Quote_Line_Options__c> qloList = new List<Quote_Line_Options__c>();
        qloList.add(qlo);
        insert qloList;   */     
        CreateQuotetriggerHandler cqth = new CreateQuotetriggerHandler ();
        Test.starttest();
        cqth.QuoteUpdate(qt.id);
         qt.Name = 'qt test upd';
        //qt.Discount__c = 10;
        qt.Quote_Number__c = '1234';
        qt.Discount__c = 10;
        qt.Expiration_Date_Change_Reason__c = 'Changed Expired date';
        update qt;
        CreateQuotetriggerHandler.updateQLIDiscount(qmap,new List < Quote >{qt});
        CreateQuotetriggerHandler.updateQLODiscount(qmap, new List < Quote >{qt});
        CreateQuotetriggerHandler.updateQuote(new List<Id>{qt.Id});
        
        
        
        Test.stoptest();
    }
        
    
}