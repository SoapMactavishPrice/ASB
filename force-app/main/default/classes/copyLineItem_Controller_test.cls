@isTest(seeAllData=true)
public class copyLineItem_Controller_test {
public static testMethod void unitTest1(){
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@tegkhljk' + orgId + '.org', 
                         Username = uniqueName + '@testghjk' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id, 
                         Level__c='L1'); 
        
        insert uu;
        
        
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
        
        Fiscal_Year_Master__c f = new Fiscal_Year_Master__c();
        f.Active__c = true;
        f.Name = '42';
        f.Fiscal_Year_Start_Date__c = System.today();
        f.Fiscal_Year_End_Date__c = System.today() + 10 ; 
       // insert f;
        
        Global_Region__c gr = new Global_Region__c();
        gr.Name = 'asia';
        insert gr;

      
        Global_SubRegion__c sr = new Global_SubRegion__c();
        sr.Name = 'india'; 
        sr.Region__c = gr.Id;
        insert sr;

        
        Country_List__c c1=new Country_List__c();
        c1.Active__c=true;
        c1.Country_Code__c='IN';
        c1.language__c='EN';
        c1.Region_Master__c = gr.Id;
        c1.Sub_Region__c = sr.Id;
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
        try{
        insert us;   
        }Catch(Exception e){}  
    
       /* PIN_Code_Master__c pin = new PIN_Code_Master__c();
        pin.Active__c = true;
        //pin.City__c = o.Id;
        insert pin; */

        account acc=new account(name='test', CurrencyIsoCode='INR', ERP_ID__c='Test ERP');
        insert acc;
        
        acc.Name = 'new update';
        acc.Shipping_Postal_Code__c = 'qw234e';
        acc.Pin_Code__c = '432221';
        acc.Billing_City__c=o.id;
        acc.Billing_Country__c=c1.Id;
        acc.Billing_State__c=s1.Id;
        acc.Shipping_City__c=o.Id;
        acc.Shipping_Country__c=c1.Id;
        acc.ShippingState=s1.id;
        acc.Is_Converted__c = true;
       
        
        
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
        insert op;
        
        quote qt = new quote();
        qt.Status = 'Draft';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        insert qt;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        pro.IsActive = true;
        insert pro;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];

        PricebookEntry pbe = new PricebookEntry();
        //pricebook2id = stdPb.id
        pbe.Pricebook2Id = stdPb.id;
        pbe.Product2Id = pro.id;
        pbe.UnitPrice = 45;
        pbe.UseStandardPrice=FALSE;
        pbe.IsActive = true;
        pbe.D1__c = 1;
        pbe.D2__c = 1;
        pbe.D3__c = 1;
        pbe.M1__c = 0.1;
        pbe.M2__c = 0.1;
        pbe.M3__c = 0.1;
        pbe.M4__c = 0.1;
         pbe.Quantity__c = 1;
        insert pbe;
        
        Quote_Line_Item_Custom__c qli2 = new Quote_Line_Item_Custom__c();
        qli2.Quote__c = qt.id;
        qli2.Discount__c = 1;
        qli2.Quantity__c = 1;
        qli2.Discount_Approval_Note__c = 'sfasf';
        qli2.Scope_of_mould__c = 'ML';
        qli2.List_Price__c = 12;
        qli2.Product_Name__c = pro.id;
        qli2.Is_Manual__c = true;
        insert qli2;

        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        insert qli;
        
        
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Select_Option__c = false;
        insert qlo;
        
        Quote_Line_Options__c qlo2 = new Quote_Line_Options__c();
        qlo2.Quote__c = qt.id;
        qlo2.Quote_Line_Item_Custom__c = qli.id;
        qlo2.Select_Option__c = true;
        insert qlo2;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        copyLineItem_Controller test1 = new copyLineItem_Controller(sc);
        PageReference pageRef = Page.copyLineItemVFpage; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        test1.strSelected = qli.id;
        test1.strSelected = qli2.id;
        integer val = 1;
        test1.inputValue = val;
		test1.copyItems();
        Test.StopTest(); 
    }
    
    public static testMethod void unitTest2(){
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@tegkhljk' + orgId + '.org', 
                         Username = uniqueName + '@testghjk' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id, 
                         Level__c='L1'); 
        
        insert uu;
        
        
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
        
        Fiscal_Year_Master__c f = new Fiscal_Year_Master__c();
        f.Active__c = true;
        f.Name = '42';
        f.Fiscal_Year_Start_Date__c = System.today();
        f.Fiscal_Year_End_Date__c = System.today() + 10 ; 
      //  insert f;
        
        Global_Region__c gr = new Global_Region__c();
        gr.Name = 'asia';
        insert gr;

      
        Global_SubRegion__c sr = new Global_SubRegion__c();
        sr.Name = 'india'; 
        sr.Region__c = gr.Id;
        insert sr;

        
        Country_List__c c1=new Country_List__c();
        c1.Active__c=true;
        c1.Country_Code__c='IN';
        c1.language__c='EN';
        c1.Region_Master__c = gr.Id;
        c1.Sub_Region__c = sr.Id;
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
        try{
        insert us;    
        }Catch(Exception e){}   
        
       /* PIN_Code_Master__c pin = new PIN_Code_Master__c();
        pin.Active__c = true;
        //pin.City__c = o.Id;
        insert pin; */

        account acc=new account(name='test', CurrencyIsoCode='INR', ERP_ID__c='Test ERP');
        insert acc;
        
        acc.Name = 'new update';
        acc.Shipping_Postal_Code__c = 'qw234e';
        acc.Pin_Code__c = '432221';
        acc.Billing_City__c=o.id;
        acc.Billing_Country__c=c1.Id;
        acc.Billing_State__c=s1.Id;
        acc.Shipping_City__c=o.Id;
        acc.Shipping_Country__c=c1.Id;
        acc.ShippingState=s1.id;
        acc.Is_Converted__c = true;
       
        
        
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
        insert op;
        
        quote qt = new quote();
        qt.Status = 'Draft';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        insert qt;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        pro.IsActive = true;
        insert pro;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];

        PricebookEntry pbe = new PricebookEntry();
        //pricebook2id = stdPb.id
        pbe.Pricebook2Id = stdPb.id;
        pbe.Product2Id = pro.id;
        pbe.UnitPrice = 45;
        pbe.UseStandardPrice=FALSE;
        pbe.IsActive = true;
        pbe.D1__c = 1;
        pbe.D2__c = 1;
        pbe.D3__c = 1;
        pbe.M1__c = 0.1;
        pbe.M2__c = 0.1;
        pbe.M3__c = 0.1;
        pbe.M4__c = 0.1;
         pbe.Quantity__c = 1;
        insert pbe;
        
        Quote_Line_Item_Custom__c qli2 = new Quote_Line_Item_Custom__c();
        qli2.Quote__c = qt.id;
        qli2.Discount__c = 1;
        qli2.Quantity__c = 1;
        qli2.Discount_Approval_Note__c = 'sfasf';
        qli2.Scope_of_mould__c = 'ML';
        qli2.List_Price__c = 12;
        qli2.Product_Name__c = pro.id;
        qli2.Is_Manual__c = true;
        insert qli2;

        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        insert qli;
        
        
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Select_Option__c = false;
        insert qlo;
        
        Quote_Line_Options__c qlo2 = new Quote_Line_Options__c();
        qlo2.Quote__c = qt.id;
        qlo2.Quote_Line_Item_Custom__c = qli.id;
        qlo2.Select_Option__c = true;
        insert qlo2;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        copyLineItem_Controller test1 = new copyLineItem_Controller(sc);
        PageReference pageRef = Page.copyLineItemVFpage; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        test1.strSelected = qli.id;
        integer val = 1;
        test1.inputValue = val;
		test1.copyItems();
        Test.StopTest(); 
    }
    
  /*  public static testMethod void unitTest3(){
        
        
        Subsidiari_Master__c s = new Subsidiari_Master__c();
        s.Name = 'IPL';
        s.Name__c = 'xyg';
        s.Active__c = true;
        s.Office__c = 'Airforce';
        s.Rounding_Off_Digits__c = '10000';
        s.Permitted_Currency__c = 'INR';
        s.Permitted_Language__c = 'EN';
        s.Discount_Level_1__c = 5;
        s.Discount_Level_2__c = 10;
        s.Discount_Level_3__c = 15;
        s.Quote_Approval__c ='Line Item level';
        s.Contract_Approval__c = 'Line Item level';
        s.Permitted_Language__c = 'HI';
        insert s;
        
        Country_List__c c=new Country_List__c();
        c.Active__c = true;
        c.Name = 'India';	
        c.Subsidiary__c=s.id;
        insert c;
        
        Region__c re = new Region__c();
        re.Active__c = true;
        re.Country__c = c.Id;
        re.Name = 'EAST';
        re.Name__c = 'EAST';
        insert re;
        
        User_Setup__c u=new User_Setup__c();
        u.Country__c=c.Id;
        u.User__c=Userinfo.getUserId();
        u.Subsidiari__c = s.Id;
        u.Region__c = re.Id;
        u.Default_Language__c = 'HI';
        insert u;
        
        Assign_Region__c ar = new Assign_Region__c();
        ar.User_Setup__c=u.Id;
        ar.Country__c = c.Id;
        ar.Region__c = re.Id;
        insert ar;

        Account acc = new Account();
        acc.Name = 'acc anem';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '250001';
        acc.Type = 'Press';
        insert acc;
        
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
        insert op;
        
        quote qt = new quote();
        qt.Status = 'Draft';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        insert qt;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        pro.IsActive = true;
        insert pro;
        
        Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];

        PricebookEntry pbe = new PricebookEntry();
        //pricebook2id = stdPb.id
        pbe.Pricebook2Id = stdPb.id;
        pbe.Product2Id = pro.id;
        pbe.UnitPrice = 45;
        pbe.UseStandardPrice=FALSE;
        pbe.IsActive = true;
        insert pbe;

        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = false;
        insert qli;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Select_Option__c = true;
        insert qlo;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        copyLineItem_Controller test1 = new copyLineItem_Controller(sc);
        PageReference pageRef = Page.copyLineItemVFpage; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(qt.Id));
        Test.setCurrentPage(pageRef);
        test1.strSelected = qli.id;
        integer val = 1;
        test1.inputValue = val;
		test1.copyItems();
        Test.StopTest(); 
    }
*/
}