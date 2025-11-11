@isTest
public class EmailInvoice_Controller_Test {
    
    static testMethod void testMethod1(){
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
        
        Fiscal_Year_Master__c fm=new Fiscal_Year_Master__c();
        fm.Fiscal_Year_Start_Date__c=System.today()-200;
        fm.Fiscal_Year_End_Date__c=System.today()+165;
        fm.Active__c=true;
        fm.Name='44';
        insert fm;
                        
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
        insert op;
        
        QuoteRecursionCheck.isfirsttime=false;
        quote qt = new quote();
        qt.Status = 'RELEASED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.VALITY_DATE__c = system.today() +2;
        qt.Application__c = 'EDIBLE OIL';
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
        qt.Exchange_Rate__c = 11;
        insert qt;
        
        acc.Subsidiary__c = sub.Id;
        update acc;
        
        Bank_Detail__c bd = new Bank_Detail__c();
        bd.Subsidiary_Master__c = sub.Id;
        bd.Active__c = true;
        bd.Bank_A_C_No__c = 'AB2321CD';
        bd.Beneficiary__c = 'Test';
        insert bd;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Discount__c = 10;
        cont.Subsidiary__c=sub.id;
        cont.Approved_Amount__c = 10;
        insert cont;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.Level_Of_Ceiling__c = '10';
        
        insert conLI;
        
         Contract_Line_Option__c conLO = new Contract_Line_Option__c();
        conLO.Contract_Line_Item__c = conLI.id;
        conLO.ContractId__c = cont.id;
        conLO.Discount_Description__c = 'Null';
        conLO.Select_Option__c = true;
        insert conLO;
        
        Performa_Invoice_Template__c pit = new Performa_Invoice_Template__c();
        pit.Active__c = true;
        pit.Label__c = 'Performa Invoice';
        pit.Subsidiary__c = sub.Id;
        insert pit;
       
        Performa_Invoice__c PI = new Performa_Invoice__c();
        PI.Contract__c = cont.id;
        PI.Contact__c = con.id;
        PI.Account__c = acc.id;
        PI.Is_IGST__c=true;
        PI.Is_CGST__c=true;
        PI.Is_SGST__c=true;
        PI.Performa_Invoice_Template__c = pit.Id;
        PI.Subsidiary__c = sub.id;
        insert PI;
        system.debug('PI test classs ==== = =' + PI);
        Performa_Invoice_Line_Item__c PLI = new Performa_Invoice_Line_Item__c();
        PLI.Performa_Invoice__c = PI.id;
        PLI.Contract_Line_Item__c = conLI.id;
        insert PLI;
        
        Attachment at = new Attachment();
        at.Name = 'test';
        at.Body=Blob.valueOf('Test Body');
        at.ParentId=PI.Id;
        insert at;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(PI);
        ApexPages.currentPage().getParameters().put('id', PI.Id);
        EmailPerfromaInvoiceControler ec = new EmailPerfromaInvoiceControler(sc);
        ec.check1 = true;
        ec.check2 = true;
        ec.checkABM = true;
        ec.checkTech = true;
        ec.rendABM = true;
        ec.rendTech = true;
        ec.ABMName = 'qweqwe';
        ec.TechnicalName = 'asdasd';
        ec.sendQuote();
        ec.cancel();
        Test.stopTest();
        
        
        
    }
}