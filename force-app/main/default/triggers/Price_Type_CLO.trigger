trigger Price_Type_CLO on Contract_Line_Option__c (before insert) {
    
        if(trigger.isBefore && trigger.isInsert){
        for (Contract_Line_Option__c clo : Trigger.new) {
            if (clo.Select_Option__c) {
                clo.Price_Type__c = null;
            }
        }
    }

}