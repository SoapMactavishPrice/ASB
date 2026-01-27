trigger pricetype on Quote_Line_Options__c (before insert) {
    
    if(trigger.isBefore && trigger.isInsert){
        for (Quote_Line_Options__c qlo : Trigger.new) {
            if (qlo.Select_Option__c) {
                qlo.Price_Type__c = null;
            }
        }
    }
}