@isTest
public class Address_Information_Trigger_Test 
{    
    public static testMethod void unitTest1(){
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
        f.Name = '420';
        f.Fiscal_Year_Start_Date__c = System.today();
        f.Fiscal_Year_End_Date__c = System.today() + 10 ; 
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
        o.Subsidiary_Master__c = sub.Id;
        o.State__c = s1.id;
        insert o;
        
        User_Setup__c us = new User_Setup__c();
        us.Subsidiari__c = sub.Id;
        us.User__c = userInfo.getUserId();
        us.Country__c = c1.id;
        insert us;       
        
       /* PIN_Code_Master__c pin = new PIN_Code_Master__c();
        pin.Active__c = true;
        //pin.City__c = o.Id;
        pin.name ='123445';
        insert pin; */
        
        account acc=new account(name='test', CurrencyIsoCode='INR', ERP_ID__c='Test ERP', Global_Customer_Name__c='MARS', Account_Type__c='LOCAL');
        insert acc;
        
        acc.Name = 'new update';
        acc.Shipping_Postal_Code__c = 'qw234e';
        //acc.Pin_Code__c = '432221';
        acc.Billing_City__c=o.id;
        acc.Billing_Country__c=c1.Id;
        acc.Billing_State__c=s1.Id;
        acc.Shipping_City__c=o.Id;
        acc.Shipping_Country__c=c1.Id;
        acc.ShippingState=s1.id;
        acc.Customer_Category__c = 'Medium';
        
        update acc;
        try{
            Account acc1 = new Account();
            acc1.Name = 'aslkdj';
            acc1.ADDRESS_LINE_1__c = 'qwe';
            acc1.ADDRESS_LINE_2__c = 'sfer';
            acc1.ADDRESS_LINE_3__c = 'cdsf43';
           // acc1.Pin_Code__c = '234447';
            acc1.Shipping_City__c=o.Id;
            acc1.Shipping_Country__c=c1.Id;
            acc1.ShippingState=s1.id;
           // acc1.Billing_Postal_ZIP_Code__c = pin.Id;
            insert acc1;
        }catch(exception e){
            System.debug('exception '+e);
        }
        
        Address_Information__c addressUnit= new Address_Information__c();
        addressUnit.Type__c='Bill To';
        addressUnit.Account__c=acc.id;
       // addressUnit.Pin_Code__c=pin.id;
        addressUnit.Is_Primary__c = true;
        RecursiveTriggerHandler2.isFirstTimeOnAdd=false;  
        insert addressUnit;
        
                
    }
        public static testMethod void unitTest2(){
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
        f.Name = '420';
        f.Fiscal_Year_Start_Date__c = System.today();
        f.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert f;
        
        Country_List__c c1=new Country_List__c();
        c1.Name='test';
        c1.Subsidiary__c = sub.id;
        insert c1;
        
        Region__c r = new Region__c();
        r.Name = 'test';
        r.Name__c = 'test';
        r.Country__c =c1.id;
        r.Active__c = true;
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
        
       /* PIN_Code_Master__c pin = new PIN_Code_Master__c();
        pin.Active__c = true;
        //pin.City__c = o.Id;
            pin.name ='123445';
        insert pin; */
        
        account acc=new account(name='test', CurrencyIsoCode='INR', ERP_ID__c='Test ERP', Global_Customer_Name__c='MARS', Account_Type__c='LOCAL');
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
        acc.Customer_Category__c = 'Medium';
        
        update acc;
        try{
            Account acc1 = new Account();
            acc1.Name = 'aslkdj';
            acc1.ADDRESS_LINE_1__c = 'qwe';
            acc1.ADDRESS_LINE_2__c = 'sfer';
            acc1.ADDRESS_LINE_3__c = 'cdsf43';
            acc1.Pin_Code__c = '234447';
            acc1.Shipping_City__c=o.Id;
            acc1.Shipping_Country__c=c1.Id;
            acc1.ShippingState=s1.id;
           // acc1.Billing_Postal_ZIP_Code__c = pin.Id;
            insert acc1;
            
            
            acc1.Pin_Code__c = '234047';
			update acc1;
        }catch(exception e){
            System.debug('exception '+e);
        }
        
        Address_Information__c addressUnit= new Address_Information__c();
        addressUnit.Type__c='Bill To';
        addressUnit.Account__c=acc.id;
        //addressUnit.Pin_Code__c=pin.id;
        addressUnit.Is_Primary__c = true;
        addressUnit.Region__c = r.Id;
        RecursiveTriggerHandler2.isFirstTimeOnAdd=false;  
        insert addressUnit;
            
            Address_Information__c addressUnit1= new Address_Information__c();
        addressUnit1.Type__c='Ship To';
        addressUnit1.Account__c=acc.id;
       // addressUnit1.Pin_Code__c=pin.id;
        addressUnit1.Is_Primary__c = true;
        addressUnit1.Region__c = r.Id;
        RecursiveTriggerHandler2.isFirstTimeOnAdd=false;  
        insert addressUnit1;
        
        RecursiveTriggerHandler2.isFirstTimeOnAdd=true;
        
        addressUnit.Type__c='Bill To';
        addressUnit.Is_Primary__c=false;
        update addressUnit;
            
            addressUnit1.Type__c='Ship To';
        addressUnit.Is_Primary__c=true;
        update addressUnit1;

    }
}