public class QuoteTriggerHandlerForLatestRevNo {
    public static void updateLatestRevisionDetails(List<Quote> newQuotes,Map<id,Quote>oldMap) {
        Map<string, Quote> latestQuoteMap = new Map<String, Quote>();
        set<Id> latestQuote = new set<Id>();
        for (Quote q : newQuotes) {
            if (q.QU_REVISION_NUMBER__c != null  && q.QU_REVISION_NUMBER__c != oldMap.get(q.id).QU_REVISION_NUMBER__c) {
                latestQuoteMap.put(q.AccountId , q);
                latestQuote.add(q.Id);
            }
        }
        
        if(latestQuote.size()  > 0){
        
        List<Quote> quoteList = [Select Id,AccountId from Quote where AccountId IN :latestQuoteMap.keyset() and ID NOt IN : latestQuote];
        map<Id,Quote> updateMap = new map<Id,Quote>();
        for(Quote qt : quoteList){
            if(latestQuoteMap.containsKey(qt.AccountId)){
                qt.Latest_Quote_Revision_Id__c = latestQuoteMap.get(qt.AccountId).Id;
                qt.Latest_Quote_Revision__c = latestQuoteMap.get(qt.AccountId).QU_REVISION_NUMBER__c;
                updateMap.put(qt.Id,qt);
            }
        }
        
        if(updateMap.size() > 0)
            update updateMap.values();
      }
    }
}