@isTest
public class SaveContractAsPdf_test {
    public static testMethod void unitTest1(){
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'IPL';
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
        o.Subsidiary_Master__c = sub.id;
        insert o;
        
        User_Setup__c us = new User_Setup__c();
        us.Subsidiari__c = sub.id;
        us.Country__c = c1.id;
        us.User__c = Userinfo.getUserId();
        Insert us;
        
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
        op.CurrencyIsoCode = 'INR';
        insert op;
        
        QuoteRecursionCheck.isfirsttime=false;
        quote qt = new quote();
       // qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        qt.Application__c = 'EOL - Edible oil/Soy sauce';
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
        insert qt;
        
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
        qli.Advance_Percentage__c = 30;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
        insert qli;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        insert qlo;
        
        qt.Status = 'RELEASED';
        Update qt;
        
        Contract_Template__c conTemp = new Contract_Template__c();
        conTemp.Active__c = true;
        conTemp.Subsidiary__c = sub.id;
        conTemp.Name = 'Test';
        Insert conTemp;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Contract_Template__c = conTemp.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = f.id;
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.List_Price__c = 100;
        conLI.Quantity__c = 10;
        conLI.Level_Of_Ceiling__c = '1000';   
        conLI.Grand_Total_before_TCS__c = 1000;
        insert conLI;
        conLI.Cancelled__c = true;
        conLI.Cancellation_Reason__c = '';
        update conLI;
        
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        insert conLO;
        
        
        test.startTest();
        PageReference pageRef = Page.PdfPreviewContract;
        pageRef.getparameters().put('id', Cont.id);  
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(Cont);
		SaveContractAsPdf controller = new SaveContractAsPdf(sc);
        controller.recordID = Cont.id;
        controller.emailId = 'test@gmail.com';
        controller.CC_Addresses = 'test1@gmail.com';
        controller.subject = 'test';
        controller.body = 'test';
        controller.ContractNumber = '1';
        controller.isModalOpen = true;
        controller.toshowSaveButton = true;
        controller.createNew = true;    
        //controller.attachQuote();
        controller.SaveToContract();
        controller.SaveAndEmailContract();
        controller.Cancel();
        controller.showPopup();
        controller.showSaveContract= true;
        test.stopTest();
    }
     public static testMethod void unitTest2(){
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'ICC';
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
        o.Subsidiary_Master__c = sub.id;
        insert o;
        
        User_Setup__c us = new User_Setup__c();
        us.Subsidiari__c = sub.id;
        us.Country__c = c1.id;
        us.User__c = Userinfo.getUserId();
        //us.User__r.Level__c = 'L1';
        Insert us;
         
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
        op.CurrencyIsoCode = 'INR';
        insert op;
        
        QuoteRecursionCheck.isfirsttime=false;
        quote qt = new quote();
       // qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        qt.Application__c = 'EOL - Edible oil/Soy sauce';
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
        insert qt;
        
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
        qli.Advance_Percentage__c = 30;
        qli.Expected_Customer_PO__c = system.today();
        qli.Expected_Delivery_date__c = system.today();
        qli.Expected_Drawing_Final__c = system.today();
        qli.Product_Description__c = 'adasds';
        qli.UOM__c = 'm';
        insert qli;
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        insert qlo;
        
        qt.Status = 'RELEASED';
        Update qt;
        
        Contract_Template__c conTemp = new Contract_Template__c();
        conTemp.Active__c = true;
        conTemp.Subsidiary__c = sub.id;
        conTemp.Name = 'Test';
        Insert conTemp;
         
        Contract_Template_Line__c conTempLI = new Contract_Template_Line__c();
        conTempLI.Active__c = false;
        conTempLI.Contract_Template__c = conTemp.Id;
        insert conTempLI;
        
        Contract_Dynamic_Text__c conDyT = new Contract_Dynamic_Text__c();
        conDyT.Active__c = true;
        conDyT.Contract_Template_Line__c = conTempLI.id;
        Insert conDyT;
         
        conTempLI.Active__c = true;
        Update conTempLI;
         
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Contract_Template__c = conTemp.id;
      //  cont.Status = 'Draft';
        cont.Freight_Pick__c = 'By Seller';
        cont.Insurance_Picklist__c = 'By Seller';
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = f.id;
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.List_Price__c = 100;
        conLI.Quantity__c = 10;
        conLI.Level_Of_Ceiling__c = '1000';   
        conLI.Grand_Total_before_TCS__c = 1000;
        insert conLI;
        conLI.Cancelled__c = true;
        conLI.Cancellation_Reason__c = '';
        update conLI;
        
        
        Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        insert conLO;
               
        Test.startTest();
        PageReference pageRef = Page.PdfPreviewContract;
        pageRef.getparameters().put('id', Cont.id);  
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(Cont);
		SaveContractAsPdf controller = new SaveContractAsPdf(sc);
        controller.recordID = Cont.id;
        controller.emailId = 'test@gmail.com';
        controller.CC_Addresses = 'test1@gmail.com';
        controller.subject = 'test';
        controller.body = 'test';
        controller.ContractNumber = '1';
        controller.isModalOpen = true;
        controller.toshowSaveButton = true;
        controller.createNew = true;  
        controller.freight = Cont.Freight_Pick__c;
        controller.Increment = 1;
        //controller.attachQuote();
        controller.SaveToContract();
        controller.SaveAndEmailContract();
        controller.Cancel();
        controller.showPopup();
        controller.showSaveContract= true;
        controller.SaveValues();
        controller.closePopup();
        controller.saveAndSend();
        controller.showModal();
        controller.save();
        Test.stopTest();
    }
}