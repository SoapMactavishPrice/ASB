/*
*  Author   : Saksham Jain
*  Date     : 22-07-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1     22-07-2022  Saksham Jain      trigger to ensure we have only one active financial year
*********************************************/

trigger FiscalYearTrigger on Fiscal_Year_Master__c (before insert,before update)
{    
    List<id> ids =new list<id>();
    list<id> rids=new list<id>();
    for(Fiscal_Year_Master__c ai : Trigger.New){
        
        ids.add(ai.id);
        rids.add(ai.id);
    }
    list<Fiscal_Year_Master__c> addList=[SELECT Id,Active__c,Fiscal_Year_End_Date__c,Fiscal_Year_Start_Date__c from Fiscal_Year_Master__c 
                                         where Active__c=true and id not in: rids];
    for(Fiscal_Year_Master__c c:Trigger.new)
    {   
        if(addList.size()>0 && c.Active__c==true)
        {
            Trigger.new[0].addError('Only one financial year can be active');
        }
    }
}