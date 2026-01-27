public class QuoteHelperForPM {
    public static void updateProjectManagementFlag(List<Quote> quoteList) {
        Set<Id> quoteIds = new Set<Id>();
        for (Quote q : quoteList) {
            quoteIds.add(q.Id);
        }

        if (quoteIds.isEmpty()) {
            return;
        }

        // Query Project Management records related to the Quotes
        Map<Id, Integer> quoteToPMCount = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT COUNT(Id) num, Quote_Name__c FROM ProjectManagement__c
            WHERE Quote_Name__c IN :quoteIds
            GROUP BY Quote_Name__c
        ]) {
            quoteToPMCount.put((Id) ar.get('Quote_Name__c'), (Integer) ar.get('num'));
        }

        // Prepare list of quotes to update
        List<Quote> quotesToUpdate = new List<Quote>();
        for (Quote q : quoteList) {
            Boolean hasPM = quoteToPMCount.containsKey(q.Id);
            if (q.Has_Project_Management__c != hasPM) {  //  Has_Project_Management__c is the checkbox field
                q.Has_Project_Management__c = hasPM;
                quotesToUpdate.add(q);
            }
        }

        // Perform DML
        if (!quotesToUpdate.isEmpty()) {
            update quotesToUpdate;
        }
    }
}