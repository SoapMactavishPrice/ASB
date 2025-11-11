/*
*  Author   : Saksham Jain
*  Date     : 07-07-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1     07-07-2022   Saksham Jain      test trigger to check opportunity trigger
*/
@isTest
public class TrgOpportunityTest 
{
    public static testMethod void unitTest1()
    {
        Fiscal_Year_Master__c f=new Fiscal_Year_Master__c();
        f.Fiscal_Year_Start_Date__c=System.today()-200;
        f.Fiscal_Year_End_Date__c=System.today()+165;
        f.Active__c=true;
        f.Name='A44';
        insert f;
        
        Subsidiari_Master__c o=new Subsidiari_Master__c();
        o.Name='IPL';
        o.Active__c=true;
        o.Name__c='IPL';
        o.Office__c='test';
        o.Permitted_Currency__c = 'INR';
        o.Rounding_Off_Digits__c = '10000';
        o.Discount_Level_1__c=1;
        o.Discount_Level_2__c=2;
        o.Discount_Level_3__c=3;
        insert o;
        
        Country_List__c c1=new Country_List__c();
        c1.Name='India';
        c1.Subsidiary__c=o.id;
        insert c1;
        
        
        User_Setup__c us=new User_Setup__c();
        us.Country__c=c1.id;
        us.Subsidiari__c=o.id;
        us.User__c=Userinfo.getUserId();
        insert us;
        
        Account acc = new Account();
        acc.CurrencyIsoCode = 'INR';
        acc.Name = 'acc anem';
        acc.ERP_ID__c = 'das';
        acc.Global_Customer_Name__c = 'COLGATE-PALMOLIVE';
        acc.Account_Type__c = 'GLOBAL';
        acc.Customer_Category__c = 'Low';
        insert acc;
        
        Account acc1 = new Account();
        acc1.CurrencyIsoCode = 'INR';
        acc1.Name = 'acc1 anem';
        acc1.ERP_ID__c = 'das';
        acc1.Global_Customer_Name__c = 'COLGATE-PALMOLIVE';
        acc1.Account_Type__c = 'GLOBAL';
        acc1.Customer_Category__c = 'High';
        acc1.ParentId=acc.id;
        insert acc1;
        
        
        
        Opportunity op = new Opportunity();
        op.CurrencyIsoCode = 'INR';
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.Global_Customer_Id__c=acc.Global_Customer_ID__c;
        op.Global_Customer_Name__c=acc.Global_Customer_Name__c;
  	//    op.Probability__c ='High';
        op.Subsidiary__c=o.id;
        op.Financial_Year__c=f.id;
        op.Amount=234;
        op.Subsidiary__c = o.id;
        RecursiveTriggerHandler2.isFirstTimeOnOpp=true;
        insert op;
        RecursiveTriggerHandler2.isFirstTimeOnOpp=true;
        
        Opportunity op1 = new Opportunity();
        op1.CurrencyIsoCode = 'INR';
        op1.Name= 'test opp';
        op1.StageName = 'New';
        op1.CloseDate = system.today() + 10;
        op1.AccountId = acc.id;
        op1.Global_Customer_Id__c=acc.Global_Customer_ID__c;
        op1.Global_Customer_Name__c=acc.Global_Customer_Name__c;
    //    op1.Probability__c='High';
        op1.Subsidiary__c=o.id;
        op1.Financial_Year__c=f.id;
        op1.Amount=234;
        op1.Subsidiary__c = o.id;
        insert op1;
        RecursiveTriggerHandler2.isFirstTimeOnOpp=true;
        op.StageName = 'Visit Planned';
        op.CloseDate = system.today() + 10;
        op.Amount=2345;
        update op;
        
        Quote q=new Quote();
        q.Closed_Date__c  = system.today() + 8;
        q.Name='test1';
        q.OpportunityId=op.Id;
        q.Exchange_Rate__c = 1;
  //      q.PROBABILITY__c = 'High';
        insert q;        

        delete op1;
        try{
            delete op;
        }catch(Exception e){
            System.debug('Exception '+e.getMessage());
        }
        
    }
  
}