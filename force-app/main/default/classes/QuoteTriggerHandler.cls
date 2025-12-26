public class QuoteTriggerHandler {
    
    /*public static void statusValidation(List<Quote> newRecordList, map<Id,quote> oldMap){
        for(Quote qt :  newRecordList){
            if(qt.Is_DTA_Quote__c &&  qt.Status !=oldMap.get(qt.Id).status && qt.Status =='RELEASED'){
                
            }
        }
    }*/
    
    
    
    public static void assignInsertRecordType(List<Quote> newRecordList){
        map<string,string> recMap = assignRecordTypecls.getRecordTypeList('Quote');
        for(Quote qt :  newRecordList){
            if(qt.Is_DTA_Quote__c){
                qt.RecordTypeId = recMap.get('Blank Quote(DTA)');
                //qt.status='Draft';
            }else{
                qt.RecordTypeId = recMap.get('Blank Quote');
                //qt.status='Created';
            }
            
            System.debug('Opportunity Id: ' + qt.Id + ', RecordTypeId: ' + qt.RecordTypeId);
        }
    }
    
    public static void assignUpdateRecordType(List<Quote> newRecordList ,map<Id,quote> oldMap){
        map<string,string> recMap = new map<string,string>();
        
       boolean bcheck = false;
        
        for(Quote qt :  newRecordList){
            if(qt.Is_DTA_Quote__c &&  qt.Status !=oldMap.get(qt.Id).status && qt.Status =='RELEASED'){
                bcheck = true;
            }else if(!qt.Is_DTA_Quote__c &&  qt.Status !=oldMap.get(qt.Id).status && qt.Status =='RELEASED'){
                bcheck = true;
            }
        }
        
        if(bcheck){
            recMap = assignRecordTypecls.getRecordTypeList('Quote');
        }
        
        
        for(Quote qt :  newRecordList){
            if(qt.Is_DTA_Quote__c &&  qt.Status !=oldMap.get(qt.Id).status && qt.Status =='RELEASED'){
                qt.RecordTypeId = recMap.get('After Released Locked(DTA)');
            }else if(!qt.Is_DTA_Quote__c &&  qt.Status !=oldMap.get(qt.Id).status && qt.Status =='RELEASED'){
                qt.RecordTypeId = recMap.get('After Released Locked');
            }
        }
    }
    
    public static void assignAccountOwner(List<Quote> newRecordList){
        set<Id> accId = new set<Id>();
        for(Quote quo :  newRecordList){
            if(string.isNotBlank(quo.OpportunityId)){
                accId.add(quo.OpportunityId);
            }
        }
        
        if(accId.size() > 0){
            map<Id,Opportunity> accMap = new map<Id,Opportunity>([Select Id,OwnerId from Opportunity where Id IN : accId]);
            for(Quote opp :  newRecordList){
                if(accMap.containsKey(opp.OpportunityId)){
                    opp.OwnerId =  accMap.get(opp.OpportunityId).OwnerId;
                }
            }
        }
    }
    
    public static void contactUpdateEmail(List<Quote> newRecordList ,map<Id,quote> oldMap){
        set<Id> conId = new set<Id>();
        Map<Id, Contact> conToMap = new Map<Id, Contact>();
        for(Quote quo :  newRecordList){
            if(string.isNotBlank(quo.contactId) && quo.ContactId != oldmap.get(quo.Id).ContactId){
                conId.add(quo.contactId);
            }
        }
        
        if(conId.size() > 0){
            List<Contact> conList = [select Id,Name,Email from Contact where Id IN :conId]; 
            
            for(Contact con: conList){
                conToMap.put(con.Id,con);
            }
            for(Quote q : newRecordList){
                if(conToMap.containsKey(q.ContactId)){
                    q.Email	 = conToMap.get(q.ContactId).Email;
                }
            }
        }
    }
    
    public static void contactChangeTOContract(List<Quote> newRecordList ,map<Id,quote> oldMap){
        map<Id,Id> quoteMap = new map<Id,Id>();
        for(Quote quo :  newRecordList){
            if(string.isNotBlank(quo.contactId) && quo.ContactId != oldmap.get(quo.Id).ContactId){
                quoteMap.put(quo.Id,quo.contactId);
            }
        }
        
        if(quoteMap.size() > 0){
            List<Contract> contractList  = new List<Contract>();
            for(Contract opp :  [Select Id,Quote__c from contract where Quote__c IN : quoteMap.keyset()]){
                if(quoteMap.containsKey(opp.quote__c)){
                    opp.Contact_Id__c =  quoteMap.get(opp.quote__c);
                    contractList.add(opp);
                }
            }
            
            if(contractList.size() > 0){
                update contractList;
            }
        }
    }
    
    
    public static void ShipTocontactChangeTOContract(List<Quote> newRecordList ,map<Id,quote> oldMap){
        map<Id,Id> quoteMap = new map<Id,Id>();
        for(Quote quo :  newRecordList){
            if(string.isNotBlank(quo.SHIP_To_Contact_Name__c) && quo.SHIP_To_Contact_Name__c != oldmap.get(quo.Id).SHIP_To_Contact_Name__c){
                quoteMap.put(quo.Id,quo.SHIP_To_Contact_Name__c);
            }
        }
        
        if(quoteMap.size() > 0){
            List<Contract> contractList  = new List<Contract>();
            for(Contract opp :  [Select Id,Quote__c from contract where Quote__c IN : quoteMap.keyset()]){
                if(quoteMap.containsKey(opp.quote__c)){
                    opp.SHIP_To_Contact_Name__c =  quoteMap.get(opp.quote__c);
                    contractList.add(opp);
                }
            }
            if(contractList.size() > 0){
                update contractList;
            }
        }
    }

    public static void updateListPriceAndBasePriceUsingAdjustExchangeRate(List<Quote> quotes, Map<Id, Quote> oldMap) {
        
        if (quotes == null || quotes.isEmpty() || oldMap == null || oldMap.isEmpty()) {
            return;
        }

        Map<Id, Quote> quoteMap = new Map<Id, Quote>();

        for (Quote qt : quotes) {
            if (qt == null || qt.Id == null) {
                continue;
            }
            
            Quote oldQuote = oldMap.get(qt.Id);
            
            if (oldQuote != null && 
                qt.Adjust_Exchange_Rate_for_manual_item_opt__c != null && 
                oldQuote.Adjust_Exchange_Rate_for_manual_item_opt__c != null &&
                qt.Adjust_Exchange_Rate_for_manual_item_opt__c != oldQuote.Adjust_Exchange_Rate_for_manual_item_opt__c) {
                quoteMap.put(qt.Id, qt);
            }
        }

        if (quoteMap.isEmpty()) {
            return;
        }

        List<Quote_Line_Item_Custom__c> quoteLineItems = [
            SELECT Id, List_Price__c, Base_Price__c, Quote__c
            FROM Quote_Line_Item_Custom__c
            WHERE Quote__c IN :quoteMap.keySet() AND Is_Manual__c = true
        ];

        List<Quote_Line_Options__c> quoteLineOptions = [
            SELECT Id, Manula_Option_List_Price__c, Manual_Option_Base_Price__c, Quote__c
            FROM Quote_Line_Options__c
            WHERE Quote__c IN :quoteMap.keySet() AND Select_Option__c = true
        ];

        if (quoteLineItems.isEmpty() && quoteLineOptions.isEmpty()) {
            return;
        }

        if (!quoteLineItems.isEmpty()) {
            for (Quote_Line_Item_Custom__c qli : quoteLineItems) {
                if (qli == null || qli.Quote__c == null) {
                    continue;
                }
                
                Quote qt = quoteMap.get(qli.Quote__c);
                
                if (qt != null && qt.Adjust_Exchange_Rate_for_manual_item_opt__c != null) {
                    if (qli.List_Price__c != null) {
                        qli.List_Price__c = qli.List_Price__c * qt.Adjust_Exchange_Rate_for_manual_item_opt__c;
                    }
                    if (qli.Base_Price__c != null) {
                        qli.Base_Price__c = qli.Base_Price__c * qt.Adjust_Exchange_Rate_for_manual_item_opt__c;
                    }
                }
            }

            if (!quoteLineItems.isEmpty()) {
                update quoteLineItems;
            }
        }

        if (!quoteLineOptions.isEmpty()) {
            for (Quote_Line_Options__c qlo : quoteLineOptions) {
                if (qlo == null || qlo.Quote__c == null) {
                    continue;
                }
                
                Quote qt = quoteMap.get(qlo.Quote__c);
                
                if (qt != null && qt.Adjust_Exchange_Rate_for_manual_item_opt__c != null) {
                    if (qlo.Manula_Option_List_Price__c != null) {
                        qlo.Manula_Option_List_Price__c = qlo.Manula_Option_List_Price__c * qt.Adjust_Exchange_Rate_for_manual_item_opt__c;
                    }
                    if (qlo.Manual_Option_Base_Price__c != null) {
                        qlo.Manual_Option_Base_Price__c = qlo.Manual_Option_Base_Price__c * qt.Adjust_Exchange_Rate_for_manual_item_opt__c;
                    }
                }
            }

            if (!quoteLineOptions.isEmpty()) {
                update quoteLineOptions;
            }
        }
    }
}