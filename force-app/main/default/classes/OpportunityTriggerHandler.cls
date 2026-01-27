public class OpportunityTriggerHandler {

     public static void assignInsertRecordType(List<Opportunity> newRecordList){
       map<string,string> recMap = assignRecordTypecls.getRecordTypeList('Opportunity');
         
        System.debug('RecordTypeMap: ' + recMap);
         
        for(Opportunity opp :  newRecordList){
            if(opp.Is_DTA_Opportunity__c){
                opp.RecordTypeId = recMap.get('New Opportunity (DTA)');
                System.debug('RecordTypeMap: Id ' + recMap.get('New Opportunity (DTA)'));
            }else{
                opp.RecordTypeId = recMap.get('New Opportunity');
                System.debug('RecordTypeMap: Isd ' + recMap.get('New Opportunity (DTA)'));
                 
            }
           
             System.debug('Opportunity Id: ' + opp.Id + ', RecordTypeId: ' + opp.RecordTypeId);
        }
    }
    
    public static void assignUpdateRecordType(List<Opportunity> newRecordList,map<Id,Opportunity> oldMap){
       map<string,string> recMap = assignRecordTypecls.getRecordTypeList('Opportunity');
        for(Opportunity opp :  newRecordList){
            if(opp.Is_DTA_Opportunity__c &&  opp.StageName !=oldMap.get(opp.Id).StageName && opp.StageName =='Under Quotation'){
                opp.RecordTypeId = recMap.get('After stage Under Quotation (DTA)');
            }else if(!opp.Is_DTA_Opportunity__c &&  opp.StageName !=oldMap.get(opp.Id).StageName && opp.StageName =='Under Quotation'){
                opp.RecordTypeId = recMap.get('After stage Under Quotation');
            }
            
            System.debug('Opportunity Id: ' + opp.Id + ', RecordTypeId: ' + opp.RecordTypeId);
        }
    }
    
    public static void assignAccountOwner(List<Opportunity> newRecordList){
        set<Id> accId = new set<Id>();
        for(Opportunity opp :  newRecordList){
            if(string.isNotBlank(opp.AccountId)){
                accId.add(opp.AccountId);
            }
        }
        
        if(accId.size() > 0){
            map<Id,Account> accMap = new map<Id,Account>([Select Id,OwnerId from Account where Id IN : accId]);
            for(Opportunity opp :  newRecordList){
                if(accMap.containsKey(opp.AccountId)){
                    opp.OwnerId =  accMap.get(opp.AccountId).OwnerId;
                }
            }
        }
    }
    
    
    public static void getOpportunityRegion(List<Opportunity> newRecordList){
        set<Id> accId = new set<Id>();
        for(Opportunity opp :  newRecordList){
            if(string.isNotBlank(opp.AccountId)){
                accId.add(opp.AccountId);
            }
        }
        
        if(accId.size() > 0){
            map<Id,Account> accMap = new map<Id,Account>([Select Id,Global_Region__c,Global_SubRegion__c from Account where Id IN : accId]);
            for(Opportunity opp :  newRecordList){
                if(accMap.containsKey(opp.AccountId)){
                    opp.Global_Region__c =  accMap.get(opp.AccountId).Global_Region__c;
                    opp.Global_SubRegion__c =  accMap.get(opp.AccountId).Global_SubRegion__c;
                }
            }
        }
    }
    
     public static void getUpdateOpportunityRegion(List<Opportunity> newRecordList,Map<Id,Opportunity>oldMap){
        set<Id> accId = new set<Id>();
        for(Opportunity opp :  newRecordList){
            if(string.isNotBlank(opp.AccountId) && oldMap.get(opp.Id).AccountId != opp.AccountId){
                accId.add(opp.AccountId);
            }
        }
        
        if(accId.size() > 0){
            map<Id,Account> accMap = new map<Id,Account>([Select Id,Global_Region__c,Global_SubRegion__c from Account where Id IN : accId]);
            for(Opportunity opp :  newRecordList){
                if(accMap.containsKey(opp.AccountId)){
                    opp.Global_Region__c =  accMap.get(opp.AccountId).Global_Region__c;
                    opp.Global_SubRegion__c =  accMap.get(opp.AccountId).Global_SubRegion__c;
                }
            }
        }
    }
}