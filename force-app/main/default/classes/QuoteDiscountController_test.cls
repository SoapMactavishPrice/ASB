@isTest
public class QuoteDiscountController_test {
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
        sub.Contract_Approval__c = 'Line Item level';
        sub.Negative_Discount__c= 99;
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
        pin.Name = '001';
        insert pin;  
        
        account acc=new account(name='test', CurrencyIsoCode='INR', ERP_ID__c='Test ERP', Global_Customer_Name__c='MARS', Account_Type__c='LOCAL', Billing_Postal_ZIP_Code__c = pin.Id);
        insert acc;
        
        acc.Name = 'new update';
        acc.Shipping_Postal_Code__c = 'qw234e';
        acc.Pin_Code__c = '001';
        acc.Billing_City__c=o.id;
        acc.Billing_Country__c=c1.Id;
        acc.Billing_State__c=s1.Id;
        acc.Shipping_City__c=o.Id;
        acc.Shipping_Country__c=c1.Id;
        acc.ShippingState=s1.id;
        
        update acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
       op.CurrencyIsoCode = 'INR';
        insert op;
        
       // Subsidiari_Master__c sub = new Subsidiari_Master__c();
        //insert sub;
        
        quote qt = new quote();
        qt.Status = 'CREATED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        //qt.Application__c = 'EDIBLE OIL';
        qt.Zero_Cooling__c = 'Yes';
        qt.Fax = '1234562';
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
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 1;
        qt.Subsidiary__c = sub.Id;
        
        insert qt;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        //qli.Discount__c = 1;
        qli.Discount_Type__c = 'Value';
        qli.Discount_in_Value__c = 2000;
        //qli.Discount_Allowed__c = 10;
        qli.Quantity__c = 1;
        //qli.Application__c = 'EDIBLE OIL';
        qli.Discount_Approval_Note__c = '';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
          qli.List_Price__c = 50;
        //qli.Discount__c = 1;
        qli.Approved_Discount__c=5;
        insert qli;
          
          
        qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        //qli.Discount__c = 1;
        qli.Discount_Type__c = 'Percent';
        qli.Discount__c  = 20;
        //qli.Discount_Allowed__c = 10;
        qli.Quantity__c = 1;
        //qli.Application__c = 'EDIBLE OIL';
        qli.Discount_Approval_Note__c = '';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Is_Manual__c = true;
        qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
        qli.Discount__c = 1;
        qli.Approved_Discount__c=5;
          //try{
         	insert qli;
         /* }
        catch(Exception e){
            System.Assert(e.getMessage().contains('Discount In Value should not be blank'));
        }*/
        
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Discount_Type__c = 'Value';
          qlo.Quantity__c = 1;
        qlo.Discount_in_Value__c = 2000;
        //qlo.Discount__c  = 20;
          qlo.Manula_Option_List_Price__c = 3400000;
        insert qlo;
          
          qlo.Manula_Option_List_Price__c = -1;
         try{
         update qlo;
         }catch(exception e){}
        
        
        Test.StartTest();
        ApexPages.StandardController conobj = new ApexPages.StandardController(qt);
        ApexPages.currentPage().getParameters().put('Id',qt.id);
        QuoteDiscountController OBJ = new QuoteDiscountController(conobj );
        
       
        OBJ.UpdateDataOnDiscount();
        OBJ.onLineItemDiscountUpdate();
         OBJ.cancel();
         OBJ.gotoquote();
         OBJ.ShowpageBlockFlag=true;
         OBJ.isSuccess=false;
         OBJ.displayPopup=true;
         OBJ.ShowpageBlockFlag2=true;
         OBJ.ObjAccount=acc;
         OBJ.ObjQuote=qt;
       	OBJ.Increment=5;
         OBJ.no2words='TEST';
         OBJ.TodayDate=system.today();
          obj.ObjUser = [select Id,Email from User Where Id=:userInfo.getUserId()];
         obj.discuntLineId = 'test';
        PageReference testPage = Page.discRevVFpage2;
          
        Test.setCurrentPage(testPage);
         Test.StopTest();
             
    }
    
    
     public static testMethod void testMethod2(){
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
        sub.Negative_Discount__c= 5;
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
        o.Subsidiary_Master__c =sub.Id;
        insert o;
       
        User_Setup__c us = new User_Setup__c();
        us.Subsidiari__c = sub.Id;
        us.User__c = userInfo.getUserId();
        us.Country__c = c1.id;
        insert us;       
        
        PIN_Code_Master__c pin = new PIN_Code_Master__c();
        pin.Active__c = true;
        //pin.City__c = o.Id;
        pin.Name = '001';
        insert pin;
        
        account acc=new account(name='test', CurrencyIsoCode='INR', ERP_ID__c='Test ERP', Global_Customer_Name__c='MARS', Account_Type__c='LOCAL', Billing_Postal_ZIP_Code__c = pin.Id);
        insert acc;
        
        acc.Name = 'new update';
        acc.Shipping_Postal_Code__c = 'qw234e';
        acc.Pin_Code__c = '001';
        acc.Billing_City__c=o.id;
        acc.Billing_Country__c=c1.Id;
        acc.Billing_State__c=s1.Id;
        acc.Shipping_City__c=o.Id;
        acc.Shipping_Country__c=c1.Id;
        acc.ShippingState=s1.id;
        
        update acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        Opportunity op = new Opportunity();
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.CurrencyIsoCode = 'INR';
        insert op;
        
       // Subsidiari_Master__c sub = new Subsidiari_Master__c();
        //insert sub;
        
        quote qt = new quote();
        qt.Status = 'CREATED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        //qt.Application__c = 'EDIBLE OIL';
        qt.Zero_Cooling__c = 'Yes';
        qt.Fax = '1234562';
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
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 1;
        qt.Subsidiary__c = sub.Id;
        
        insert qt;
         
         
        
        Test.StartTest();
        ApexPages.StandardController conobj = new ApexPages.StandardController(qt);
        ApexPages.currentPage().getParameters().put('Id',qt.id);
        QuoteDiscountController OBJ = new QuoteDiscountController(conobj );
        
       
        OBJ.UpdateDataOnDiscount();
        OBJ.onLineItemDiscountUpdate();
         OBJ.cancel();
         OBJ.gotoquote();
         OBJ.ShowpageBlockFlag=true;
         OBJ.isSuccess=false;
         OBJ.displayPopup=true;
         OBJ.ShowpageBlockFlag2=true;
         OBJ.ObjAccount=acc;
         OBJ.ObjQuote=qt;
       	OBJ.Increment=5;
         OBJ.no2words='TEST';
         OBJ.TodayDate=system.today();
         
        PageReference testPage = Page.discRevVFpage2;
        Test.setCurrentPage(testPage);
         Test.StopTest();
             
    }
     
   
}