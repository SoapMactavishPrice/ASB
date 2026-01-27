public class QuoteLineTriggerHandler  {
	
    public static Boolean isUpdateQLIDiscountRun = false;
	
	public static void updateQuoteDiscount(Map<Id, Quote_Line_Item_Custom__c> oldQLIObjMap, List<Quote_Line_Item_Custom__c> qliObjList) {
		
		if(!isUpdateQLIDiscountRun) {
            system.debug('inside updateQuoteDiscount' );
            
			Map<Id, Quote> qouteObjMap = new Map<Id, Quote> ();
            
			for(Quote_Line_Item_Custom__c qliObj : qliObjList) {
				if(oldQLIObjMap == null
                   || (qliObj.Discount__c != oldQLIObjMap.get(qliObj.Id).Discount__c)) {
					Quote quoteObj = new Quote(Id = qliObj.Quote__c);
					quoteObj.Discount__c = qliObj.Discount__c;
					qouteObjMap.put(qliObj.Quote__c, quoteObj);
				}
			}
			
            system.debug('Map = ' +qouteObjMap);
            
			//update qouteObjMap
			if(!qouteObjMap.isEmpty())
				update qouteObjMap.values();
			
			isUpdateQLIDiscountRun = true;
		}
	}
}