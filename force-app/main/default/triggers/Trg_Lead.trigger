/*
*  Author   : Amol wagh
*  Date     : 27-06-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      27-06-2022   Amol Wagh      trigger to update Financial year and Subsidiary
*********************************************/
trigger Trg_Lead on Lead (before insert,after insert,after update,before update ) 
{
    try{
        if(Trigger.isbefore)
        {
            
            Fiscal_Year_Master__c f=[select id,name from Fiscal_Year_Master__c where Active__c=true limit 1];
            List<id>ids =new list<id>();
            List<String> cCode=new List<String>();
            map<String,id> cSub=new map<String,id>();
            map<String,String> nEmail=new map<String,String>();
            map<id,id> uMap=new map<id,id>();
            Map<String,id>cMap=new Map<String,id>();
            for(lead l: trigger.new)
            {
                ids.add(l.OwnerId);
                cCode.add(l.Country_Code__c);
            }
            
            for(User_Setup__c u:[select id,name,User__c,Subsidiari__c  from User_Setup__c where User__c in: ids])
            {
                uMap.put(u.User__c,u.Subsidiari__c);        
            }
            
            for(Country_List__c c: [select id,name, Subsidiary__c,Subsidiary__r.Notification_Email__c,Short_Name__c,language__c  from Country_List__c where Short_Name__c in:cCode and Active__c=true and language__c='EN' ])
            {
                cSub.put(c.Short_Name__c,c.Subsidiary__c);
                cMap.put(c.Short_Name__c,c.id);
                nEmail.put(c.Short_Name__c,c.Subsidiary__r.Notification_Email__c);
            }
            for(lead l: trigger.new) 
            {
                l.Financial_year__c=f.id;
                if(l.LeadSource=='WEB')
                {
                    l.Subsidiary__c=cSub.get(l.Country_Code__c);
                    l.CountryList__c=cMap.get(l.Country_Code__c);
                    l.Notification_Email__c=nEmail.get(l.Country_Code__c);
                }
                else
                    l.Subsidiary__c=uMap.get(l.OwnerId);        
            }
        } 
        
        /*if(RecursiveTriggerHandler2.isFirstTimeOnAdd) 
{

if(Trigger.isAfter && (Trigger.IsInsert || Trigger.IsUpdate))
{
List<id> ids =new list<id>();
map<id,Lead> addMap=new map<id,Lead>();
for(Lead ai : Trigger.New)
{ 
ids.add(ai.id);  
}	
list<Lead> addList=[SELECT id,CityList__c,CountryList__c,StateList__c,Region1__c,Postal_Zip_Code__c,
Postal_Zip_Code__r.City__c,Postal_Zip_Code__r.City__r.State__c,
Postal_Zip_Code__r.City__r.State__r.Country__c,Postal_Zip_Code__r.City__r.State__r.Region__c 
from Lead where id in :ids and Postal_Zip_Code__c!=null];
System.debug('addList'+addList);
for(Lead ai:addList )
{
addMap.put(ai.id,ai);  
}

for(Lead ai : addList)
{ 
System.debug('addMap.get(ai.id)'+addMap);
ai.CityList__c=addMap.get(ai.id).Postal_Zip_Code__r.City__c;
ai.CountryList__c=addMap.get(ai.id).Postal_Zip_Code__r.City__r.State__r.Country__c;
ai.StateList__c=addMap.get(ai.id).Postal_Zip_Code__r.City__r.State__c;
ai.Region1__c=addMap.get(ai.id).Postal_Zip_Code__r.City__r.State__r.region__c;

}
RecursiveTriggerHandler2.isFirstTimeOnAdd=false;
update addList;
}  } */
    }
    catch(exception e)
    {
        system.debug(e);
        trigger.new[0].adderror('Something went wrong, please contact System Admin with following details '+e);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        List<Account> accountsToUpdate = new List<Account>();
        map<Id,boolean> accId = new map<Id,boolean>();  
        map<Id,string> getLeadName = new map<Id,string>();    
        // Iterate through the leads that have been updated
        for(Lead lead : Trigger.new) {
            if (lead.IsConverted && lead.ConvertedAccountId != null) {
                accId.put(lead.ConvertedAccountId,lead.IsConverted);
                getLeadName.put(lead.ConvertedAccountId,lead.Legal_Name__c);
            }
        }
        
        List<Account> convertedAccount = [SELECT Id,Legal_Name__c, Is_Converted__c FROM Account WHERE Id = :accId.keyset()];
        for(Account acc : convertedAccount){
            if(accId.containsKey(acc.Id) && accId.get(acc.Id)){
                acc.Is_Converted__c = true; // Or set it to whatever value you need
                acc.Legal_Name__c = getLeadName.get(acc.Id);
                accountsToUpdate.add(acc);
            }
            
        }   
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        Map<Id,Country_List__c>contryMap = new Map<Id,Country_List__c>();
        Map<Id,Id> shipToId = new Map<Id,Id>();
        set<Id> countId = new set<Id>();
        for(Lead ac: Trigger.new ){
            if(string.isnotBlank(ac.CountryList__c)){
                countId.add(ac.CountryList__c);
            }
        }
        
        List<Country_List__c> clist = [select Id,Sub_Region__c,Region_Master__c from Country_List__c where Id IN : countId];
        for(Country_List__c con : clist){
            contryMap.put(con.Id,con);
        }
        
        
        for(Lead ac: Trigger.new ){
            if(contryMap.containsKey(ac.CountryList__c)){
                ac.Global_SubRegion__c = contryMap.get(ac.CountryList__c).Sub_Region__c;
                ac.Global_Region__c = contryMap.get(ac.CountryList__c).Region_Master__c;
            }
        }        
    }
    
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        Map<Id,Country_List__c>contryMap = new Map<Id,Country_List__c>();
        Map<Id,Id> shipToId = new Map<Id,Id>();
        set<Id> countId = new set<Id>();
        for(Lead ac: Trigger.new ){
            if(string.isnotBlank(ac.CountryList__c)){
                countId.add(ac.CountryList__c);
            }
            /*  if(string.isnotBlank(ac.Shipping_Country__c)){
countId.add(ac.Shipping_Country__c);
} */
        }
        
        List<Country_List__c> clist = [select Id,Sub_Region__c,Region_Master__c from Country_List__c where Id IN : countId];
        for(Country_List__c con : clist){
            contryMap.put(con.Id,con);
        }
        
        
        for(Lead ac: Trigger.new ){
            if(contryMap.containsKey(ac.CountryList__c)){
                ac.Global_SubRegion__c = contryMap.get(ac.CountryList__c).Sub_Region__c;
                ac.Global_Region__c = contryMap.get(ac.CountryList__c).Region_Master__c;
            }
            
            /*  if(contryMap.containsKey(ac.Shipping_Country__c)){
ac.Shipping_Sub_Region__c = contryMap.get(ac.Shipping_Country__c).Sub_Region__c;
ac.Shipping_Region_Master__c = contryMap.get(ac.Shipping_Country__c).Region_Master__c;
} */
        }        
    }
    
    if(Trigger.isBefore){
        if(trigger.isInsert ){
          for (Lead obj : Trigger.new) {
                //if (string.isNotblank(obj.Region1__c)) {
                    obj.Region_Text_Backend__c =obj.Region_Text_Backend_for__c; 
                //}
            }
              
        }
        
        if(Trigger.isUpdate){
            for (Lead obj : Trigger.new) {
                if (obj.Region1__c!= Trigger.oldMap.get(obj.Id).Region1__c) {
                    obj.Region_Text_Backend__c =obj.Region_Text_Backend_for__c; 
                }
            }
            
        }
    }
    
}