public class ContractTriggerHandler {
    public static void assignAccountOwner(List<Contract> newRecordList){
        set<Id> accId = new set<Id>();
        for(Contract quo :  newRecordList){
            if(string.isNotBlank(quo.Quote__c)){
                accId.add(quo.Quote__c);
            }
        }
        
        if(accId.size() > 0){
            map<Id,Quote> accMap = new map<Id,Quote>([Select Id,OwnerId from Quote where Id IN : accId]);
            for(Contract opp :  newRecordList){
                if(accMap.containsKey(opp.Quote__c)){
                    opp.OwnerId =  accMap.get(opp.Quote__c).OwnerId;
                }
            }
        }
    }
    
     public static void contactUpdateEmail(List<Contract> newRecordList ,map<Id,Contract> oldMap){
        set<Id> conId = new set<Id>();
        Map<Id, Contact> conToMap = new Map<Id, Contact>();
        for(Contract quo :  newRecordList){
            if(string.isNotBlank(quo.Contact_Id__c) && quo.Contact_Id__c != oldmap.get(quo.Id).Contact_Id__c){
                conId.add(quo.Contact_Id__c);
            }
        }
        
        if(conId.size() > 0){
            List<Contact> conList = [select Id,Name,Email from Contact where Id IN :conId]; 
            
            for(Contact con: conList){
                conToMap.put(con.Id,con);
            }
            for(Contract q : newRecordList){
                if(conToMap.containsKey(q.Contact_Id__c)){
                    q.Email__c	 = conToMap.get(q.Contact_Id__c).Email;
                }
            }
        }
    }
}