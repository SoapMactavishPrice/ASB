/*
*  Author   : Saksham Jain
*  Date     : 19-07-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      19-07-2022   Saksham Jain      test class for account trigger 
*********************************************/

@isTest
public class Trg_AccountTest
{
    static testMethod void UnitTest()
    {
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
        insert f;
        
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
        insert us;       
        
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
          // 	acc1.Billing_Postal_ZIP_Code__c = pin.Id;
            acc1.Is_Converted__c = true;
            insert acc1;
        }catch(exception e){
            System.debug('exception '+e);
        }
        
        
        opportunity opp=new opportunity(name='Test opp', AccountId=acc.id, CurrencyIsoCode='INR', CloseDate=date.today(), StageName='New');
        insert opp;
        List<id>ids=new List<id>();
        ids.add(acc.id);
        TriggerHandlerAccount.AccountUpdate(ids);
    }
    
}