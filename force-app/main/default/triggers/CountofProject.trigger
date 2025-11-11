trigger CountofProject on Contract (before update,after insert,after update) {
    
    if  (Trigger.isUpdate && Trigger.isBefore)  {
        Map<Id, Integer> contractLineItemCountMap = new Map<Id, Integer>();
        set<Id> conId = new set<Id>();
        
        for (Contract contract : Trigger.new){
            if(trigger.oldMap.get(contract.Id).Status != contract.status && (contract.status =='Converted to PM – Complete' || 
                                                                             contract.status =='Converted to PM – Partial')){
                                                                                 conId.add(contract.Id) ;                                                    
                                                                             }
            
        }
        
        if(conId.size() > 0){
            for (Contract contract : [SELECT Id, (SELECT Id FROM Contract_Line_Item__r) FROM Contract WHERE Id IN :conId and 
                                      (Status =: 'Converted to PM – Complete' 
                                       or contract.Status =:'Converted to PM – Partial' )]) {
                                           contractLineItemCountMap.put(contract.Id, contract.Contract_Line_Item__r.size());
                                       }
        }
        
        /*for (Contract contract : [SELECT Id, (SELECT Id FROM Contract_Line_Item__r) FROM Contract WHERE Id IN :Trigger.newMap.keySet() and 
(Status =: 'Converted to PM – Complete' 
or contract.Status =:'Converted to PM – Partial' )]) {
contractLineItemCountMap.put(contract.Id, contract.Contract_Line_Item__r.size());
}*/
        
        
        List<String> errorMessages = new List<String>();
        
        
        for (Contract contract : Trigger.new) {
            if (contract.Status == 'Converted to PM – Complete') {
                //if(contractLineItemCountMap.containsKey(contract.Id)){
                //Integer contractLineItemCount = contractLineItemCountMap.get(contract.Id);
                
                if (contract.Count_of_PM__c < contract.Total_Quantity_Of_Products__c || contract.Count_of_PM__c == 0) {
                    errorMessages.add('Cannot change stage to Converted to PM – Complete because Count of PM should be equal to the Total Quantity of Contract Line Item.');
                }
                //}
            }
        }
        
        
        for (Contract contract : Trigger.new) {
            if (contract.Status == 'Converted to PM – Partial' && contract.Count_of_PM__c == 0) {
                errorMessages.add('To mark status as Converted to PM – Partial, make sure at least one project should be created.');
            }
        }
        
        
        if (!errorMessages.isEmpty()) {
            for (Contract contract : Trigger.new) {
                if (errorMessages.size() > 0) {
                    contract.addError(String.join(errorMessages, '\n'));
                }
            }
        }
    }
    
    /*if (Trigger.isAfter && Trigger.isInsert) {
        
        Set<Id> projIds = new Set<Id>();
        for (Contract prj : Trigger.new) {
            if (prj.Quote__c != null) {
                projIds.add(prj.Quote__c);
            }
        }
        
        system.debug('projIds-->'+projIds);
        List<Quote> quotes = [SELECT Id, Contract_Quote_Id__c FROM Quote WHERE Id IN :projIds];
        
        system.debug('quotes-->'+quotes);
        map<Id,Quote> quotesToUpdate = new map<Id,Quote> ();
        for (Quote qte : quotes) {
            Set<String> existingQuoteIds = new Set<String>();
            
            if (qte.Contract_Quote_Id__c != null) {
                existingQuoteIds.addAll(qte.Contract_Quote_Id__c.split(','));
            }
            
            for (Id projId : projIds) {
                if (!existingQuoteIds.contains(String.valueOf(projId))) {
                    if (qte.Contract_Quote_Id__c != null) {
                        qte.Contract_Quote_Id__c += ',' + projId;
                    } else {
                        qte.Contract_Quote_Id__c = String.valueOf(projId);
                    }
                    quotesToUpdate.put(qte.Id,qte);
                }
            }
            
            
        }
        
        if(quotesToUpdate.size() > 0){
            system.debug(quotesToUpdate);
            update quotesToUpdate.values();
        }
    }
*/}