@isTest
public class RecursiveTriggerHandler_test {
    public static testMethod void unitTest1(){
        RecursiveTriggerHandler2.isFirstTime = true;
        RecursiveTriggerHandler.isQuoteLineItemFirstTime = true;
        RecursiveTriggerHandler.isOppLineItemFirstTime = true;
    }
}