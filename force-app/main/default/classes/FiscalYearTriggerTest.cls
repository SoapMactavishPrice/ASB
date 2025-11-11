/*
*  Author   : Saksham Jain
*  Date     : 22-07-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1     22-07-2022  Saksham Jain      test class for trigger to ensure we have only one active financial year
*********************************************/
@isTest
public class FiscalYearTriggerTest 
{
    public static testMethod void unitTest()
    {
        Fiscal_Year_Master__c f=new Fiscal_Year_Master__c();
        f.Fiscal_Year_Start_Date__c=System.today()-200;
        f.Fiscal_Year_End_Date__c=System.today()+165;
        f.Active__c=true;
        f.Name='44';
        
        insert f;
        
    }
    

}