trigger TrgTask on Task (before update, after update) {
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        QuoteContractExpirationDateSetter.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    } 
    else if (Trigger.isAfter && Trigger.isUpdate) {
        QuoteContractExpirationDateSetter.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}