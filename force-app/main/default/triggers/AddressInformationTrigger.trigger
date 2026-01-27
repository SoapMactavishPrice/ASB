/*
*  Author   : Saksham Jain
*  Date     : 04-07-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1     04-07-2022  Saksham Jain      trigger to check that primary address can be only one for both ship to and bill to
*********************************************/
trigger AddressInformationTrigger on Address_Information__c (before insert,before update,after update)
{
    if(RecursiveTriggerHandler2.isFirstTimeOnAdd) 
    {
        
      /*  if(Trigger.isafter && (Trigger.IsInsert || Trigger.IsUpdate))
        {
            List<id> ids =new list<id>();
            map<id,Address_Information__c> addMap=new map<id,Address_Information__c>();
            for(Address_Information__c ai : Trigger.New)
            { 
                ids.add(ai.id);  
            }
            list<Address_Information__c> addList=[SELECT id,City__c,Country__c,State__c,Region__c,Account__c,Pin_Code__c,Pin_Code__r.City__c,Pin_Code__r.City__r.State__c,Pin_Code__r.City__r.State__r.Country__c,Pin_Code__r.City__r.State__r.Region__c   from Address_Information__c where id in :ids and Pin_Code__c!=null];
            System.debug('addList'+addList);
            for(Address_Information__c ai:addList )
            {
                addMap.put(ai.id,ai);  
            }
            
            for(Address_Information__c ai : addList)
            { 
                System.debug('addMap.get(ai.id)'+addMap);
                ai.City__c=addMap.get(ai.id).Pin_Code__r.City__c;
                ai.Country__c=addMap.get(ai.id).Pin_Code__r.City__r.State__r.Country__c;
                ai.State__c=addMap.get(ai.id).Pin_Code__r.City__r.State__c;
                ai.Region__c=addMap.get(ai.id).Pin_Code__r.City__r.State__r.region__c;
                
            }
            RecursiveTriggerHandler2.isFirstTimeOnAdd=false;
            update addList;
        }*/
        if(Trigger.isbefore)
        {
            
            List<id> ids =new list<id>();
            list<id> rids=new list<id>();
            for(Address_Information__c ai : Trigger.New){
                
                ids.add(ai.Account__c);
                rids.add(ai.id);
            }
            
            //fetch the address information ids where isPrimary is true
            list<Address_Information__c> cList = [SELECT Id,Account__c, Is_Primary__c,Type__c FROM Address_Information__c where Account__c in :ids
                                                  and Is_Primary__c = true and id not in: rids]; 
            
            //used for storing the billto Ids of the address information 
            Map<Id,Boolean> mapisPrimaryBillTo= new  Map<Id,Boolean>();
            
            //used for storing the shipto Ids of the address information 
            Map<Id,Boolean> mapisPrimaryShipTo= new  Map<Id,Boolean>();
            
            //used for adding the ids into the above map
            for(Address_Information__c c:cList)
            {
                if(c.Type__c=='Bill To')
                {
                    mapisPrimaryBillTo.put(c.Account__c, true); 
                   
                }
                else if(c.Type__c=='Ship To')   
                {
                    
                    mapisPrimaryShipTo.put(c.Account__c, true); 
                }
            }
            
            //adderror can be used only with trigger.new
            for(Address_Information__c ai : Trigger.New)
            {
                
                if(trigger.isUpdate || trigger.IsInsert)
                {
                    if(ai.Is_Primary__c == true && ai.Type__c=='Bill To' && mapisPrimaryBillTo.containsKey(ai.Account__c))
                    {
                      ai.addError('Account cannot have multiple Bill To Address');
                    }
                    
                    if(ai.Is_Primary__c == true && ai.Type__c=='Ship To' && mapisPrimaryShipTo.containsKey(ai.Account__c))
                        ai.addError('Account cannot have multiple Ship To Address');
                    
                }
            }
        }
    }
    
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        Map<Id,Country_List__c>contryMap = new Map<Id,Country_List__c>();
        Map<Id,Id> shipToId = new Map<Id,Id>();
        set<Id> countId = new set<Id>();
        for(Address_Information__c ac: Trigger.new ){
            if(string.isnotBlank(ac.Country__c)){
                countId.add(ac.Country__c);
             }
        }
        
        List<Country_List__c> clist = [select Id,Sub_Region__c,Region_Master__c from Country_List__c where Id IN : countId];
        for(Country_List__c con : clist){
            contryMap.put(con.Id,con);
        }


         for(Address_Information__c ac: Trigger.new ){
            if(contryMap.containsKey(ac.Country__c)){
               ac.Global_SubRegion__c = contryMap.get(ac.Country__c).Sub_Region__c;
               ac.Global_Region__c = contryMap.get(ac.Country__c).Region_Master__c;
			}
         }        
    }
    
}