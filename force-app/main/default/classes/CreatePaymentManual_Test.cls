@isTest
public class CreatePaymentManual_Test {
   
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
        fym.Name = '420';
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
        
        quote qt = new quote();
        qt.Status = 'CREATED';
        qt.Name = 'qt test';
        qt.OpportunityId = op.id;
        qt.Exchange_Rate__c = 1;
        qt.Discount__c = 12;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Additinal_Margin__c = 10;
        insert qt;
        
        Product2 pro = new Product2();
        pro.name = 'prod namen';
        pro.IsActive = true;
        pro.Description = 'sfas';
        pro.Family = 'Options';
        insert pro;
        
        //Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = pro.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 10000;
        pbe.UseStandardPrice= false;
        pbe.IsActive = true;
        pbe.Base_Price__c = 123;
        pbe.Discount_Level_3__c = 12;
        pbe.Pricing_Type__c = 1;
        pbe.Quantity__c = 1;
        pbe.D1__c = 0.1;
        pbe.D2__c = 0.2;
        pbe.D3__c = 0.3;
        pbe.M1__c = 0.1;
        pbe.M2__c = 0.2;
        pbe.M3__c = 0.3;
        pbe.M4__c = 0.4;
        insert pbe;

        
        Quote_Line_Item_Custom__c qli = new Quote_Line_Item_Custom__c();
        qli.Quote__c = qt.id;
        qli.Discount__c = 12;
        qli.Quantity__c = 1;
        qli.Discount_Approval_Note__c = 'sfasf';
        qli.Scope_of_mould__c = 'ML';
        qli.List_Price__c = 12;
        qli.Product__c = pro.id;
        qli.Is_Manual__c = true;
        insert qli;
         
        
        
        Quote_Line_Options__c qlo = new Quote_Line_Options__c();
        qlo.Quote__c = qt.id;
        qlo.Quote_Line_Item_Custom__c = qli.id;
        qlo.Select_Option__c = true;
        qlo.Manula_Option_List_Price__c = 12;
        qlo.Product__c = pro.id;
        insert qlo;
    
        qt.Status = 'RELEASED';
        Update qt;
        
        Contract cont = new Contract();
        cont.Opportunity__c = op.id;
        cont.AccountId = acc.id;
        cont.Quote__c = qt.id;
        cont.Subsidiary__c = sub.id;
        cont.FY1__c = fym.id;
        cont.Contract_Locked_for_Approval__c = true;
        insert cont;
        
        cont.Discount__c = 12;
        update cont;
        
        
        Contract cont1 = new Contract();
        cont1.Opportunity__c = op.id;
        cont1.AccountId = acc.id;
        cont1.Quote__c = qt.id;
        cont1.Discount__c = 10 ;
        cont1.Subsidiary__c = sub.id;
        cont1.FY1__c = fym.id;
        cont1.Contract_Locked_for_Approval__c = true;
        cont1.Exchange_Rate__c = 1; 
        cont1.Additinal_Margin__c = 10;    
        insert cont1;
        
        Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont1.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 10.0;
        conLI.Approved_Discount__c = 10.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.List_Price__c = 100;
        conLI.Quantity__c = 10;
        conLI.Level_Of_Ceiling__c = '1000';   
        conLI.Grand_Total_before_TCS__c = 1000;
        conLI.Product2Id__c = pro.id;
        conLI.Amount_Allocated__c = 0;
        conLI.id__c = cont1.Id;
        insert conLI;
        
        
        
        
        Payment__c pay = new Payment__c();
        pay.Payment_Date__c = system.today();
        pay.Mode_Of_Payment__c = 'Cheque';
        pay.Amount_In_Local_CUR__c = 122342343;
        pay.Payment_Type__c = 'Actual';
        
        insert pay;
        Test.startTest();
        try{
            Payment_Transaction__c pt1 = new Payment_Transaction__c();
        	pt1.Payment__c = pay.id;
        	pt1.Contract__c = cont.id;
        	pt1.Contract_Line_Item__c = conLI.id;
       		pt1.Amount_Allocated__c = 25000;
        	insert pt1;
        }catch(Exception e){
            System.debug('Error:'+e.getMessage());
        }
        Payment_Transaction__c pt = new Payment_Transaction__c();
        	pt.Payment__c = pay.id;
        	pt.Contract__c = cont.id;
        	pt.Contract_Line_Item__c = conLI.id;
       		pt.Amount_Allocated__c = 0;
        	insert pt;
        
        String conID = String.valueOf(cont.id);
        String payID = String.valueOf(pay.id);
        Decimal amt = 0;
        String reason = '';
        List<Contract_Line_Item__c> lstConLI = new List<Contract_Line_Item__c>();
        lstConLI.add(conLI);
        String PaymentMode = 'Check';
        String Cheque = '0007number';
        Date Datedata = system.today();
        Decimal Amountrecieved = 123.32;
        Decimal ExchangeRate = 2;
        string Cur1 = 'INR';
        string LocalCurrency = 'indian';
        Decimal AmountLocalCurrency = 300;
        string InvoiceNumber = pay.Invoice_Number__c;
        String PaymentType = pay.Payment_Type__c;
        
        
        CreatePaymentManual.fetchExpdate(conID);
        CreatePaymentManual.fetchContractDetails(conID);
        CreatePaymentManual.fatchContractLineItem(conID);
        CreatePaymentManual.fetchProductWrapper(conID);
        CreatePaymentManual.fetchUser();
        CreatePaymentManual.blockPayment(payID, amt, reason);
        CreatePaymentManual.makeTrans(lstConLI, payID);
        

        CreatePaymentManual.SelectedLead(conID , lstConLI, PaymentMode, Cheque, Datedata, Amountrecieved, ExchangeRate, Cur1, LocalCurrency, AmountLocalCurrency, InvoiceNumber, Datedata, PaymentType);
        new CreatePaymentManual.LeadListWrapper(true, conLI);
        Test.stopTest();
    }
}