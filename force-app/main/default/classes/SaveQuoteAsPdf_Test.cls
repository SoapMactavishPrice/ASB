@isTest
public class SaveQuoteAsPdf_Test {
    static testmethod void UnitTest1(){
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
        insert sub;
        
        Fiscal_Year_Master__c f=new Fiscal_Year_Master__c();
        f.Fiscal_Year_Start_Date__c=System.today()-200;
        f.Fiscal_Year_End_Date__c=System.today()+165;
        f.Active__c=true;
        f.Name='44';
        insert f;
          
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
        us.Subsidiari__c = sub.id;
        us.Country__c = c1.id;
        us.User__c = Userinfo.getUserId();
        Insert us;
        
        Account acc = new Account();
        acc.Name = 'acc anem';
        acc.CurrencyIsoCode = 'INR';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '250001';
        acc.Type = 'Press';
        acc.Subsidiary__c = sub.id;
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = acc.id;
        con.Title = 'dev';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;
        
        Opportunity op = new Opportunity();
        op.CurrencyIsoCode = 'INR';
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        insert op;
        
        Quote_Template__c qtemp = new Quote_Template__c();
        qtemp.Active__c=true;
        qtemp.Label__c = 'Label';
        Insert qtemp;
        
        Quote_Template_Line__c qtempLi = new Quote_Template_Line__c();
        qtempLi.Quote_Template__c = qtemp.id;
        qtempLi.Active__c=true;
        qtempLi.Is_Terms_Condition__c = true;
        qtempLi.Is_General_Remarks__c = true;
        Insert qtempLi;
        
        Quote_Dynamic_Text__c qdt = new Quote_Dynamic_Text__c();
        qdt.Quote_Template_Line__c = qtempLi.id;
        qdt.Active__c=true;
        insert qdt;
        
        quote qt = new quote();
        qt.CurrencyIsoCode = 'INR';
        qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Insurance__c = 'By Seller';
        qt.Freight__c = 'By Seller';
        qt.VALITY_DATE__c = system.today() +2;
        qt.Application__c = 'BIB - Bag in box';
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
        qt.Quote_Template__c=  qtemp.id;
        qt.ContactId = con.Id; 
        insert qt;
        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        //qli.Discount__c = 12;
        qli.Quantity__c = 1;
        //qli.Application__c = 'EDIBLE OIL';
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
        qli.Advance_Percentage__c = 30;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        qli.Product_Description__c = '#adasds';
        qli.UOM__c = 'm';
        insert qli;
        
       
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Description__c = '#adasds';
        qlo.Manual_Product_Name__c = 'sdsdfghjk';
        insert qlo;
        
        
        Additional_Document__c  a=new Additional_Document__c();
        a.name='test';
        a.Active__c=true;
        a.Type__c='Quote';
        insert a;
        
        PageReference pageRef = Page.SaveQuoteAsPdf;
        pageRef.getparameters().put('Id', qt.id);  
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(qt);
		SaveQuoteAsPdf controller = new SaveQuoteAsPdf(sc);
        controller.body = 'test';
        controller.add();
        controller.Increment = 1;
        controller.displayPopup = true;
        controller.createNew = true;
        //controller.showPopup();
        controller.showModal();
        controller.save();
        controller.attachQuote();
        controller.SaveToQuote();
        controller.SaveAndEmailQuote();
        controller.Cancel();
        controller.saveAndSendcall();
        controller.SaveValues();
        controller.closePopup();
        
    }
}