trigger mapaddress on Quote (before insert, before update,after update,after insert) {
    IF(trigger.isBefore && Trigger.isInsert){
        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        set<Id> accId = new set<Id>();
        
        for (Quote quote : Trigger.new) {
            //accountMap.put(quote.AccountId, null);
            accId.add(quote.AccountId);
        }
        
        List<Account> accList= [SELECT Id, City__c, Global_SubRegion__c, Global_Region__c FROM Account WHERE Id IN :accId];
        for(Account acc : accList){
            accountMap.put(acc.Id,acc);
        }
        System.debug('Global Region:14 ' + accountMap.size());
        
        
        for (Quote quote : Trigger.new) {
            System.debug('before contains ' + accountMap.size());
            if(accountMap.containsKey(quote.AccountId)){
                System.debug('inside if ' + accountMap.size());
                Account acc = accountMap.get(quote.AccountId);
                quote.Global_SubRegion__c = acc.Global_SubRegion__c;
                quote.Global_Region__c = acc.Global_Region__c;
                quote.Ship_To_Global_Region__c = acc.Shipping_Region_Master__c;
                quote.Ship_To_Global_SubRegion__c = acc.Shipping_Sub_Region__c;
                
            }
        }
    }
    
    if(Trigger.IsBefore && Trigger.IsUpdate){
          for (Quote quote : Trigger.new) {
              if(quote.QU_REVISION_NUMBER__c != trigger.oldMap.get(quote.id).QU_REVISION_NUMBER__c && quote.Latest_Quote_Revision_Id__c ==null 
                 && quote.Latest_Quote_Revision__c ==null){
                  quote.Latest_Quote_Revision__c = quote.QU_REVISION_NUMBER__c;
                  quote.Latest_Quote_Revision_Id__c = quote.Id;
                 }
                  
           }
     }
    
    IF(trigger.isBefore && Trigger.isUpdate){
        
        Map<Id, Account> ShipTo = new Map<Id, Account>();
        Map<Id, Contact> conToMap = new Map<Id, Contact>();
        set<Id> soldTo = new set<Id>();
        for (Quote qu : Trigger.new) {
            if(qu.SOLD_TO__c != Trigger.oldMap.get(qu.Id).SOLD_TO__c){
                soldTo.add(qu.SOLD_TO__c);  
            }
            
            if(qu.SHIP_TO__c != Trigger.oldMap.get(qu.Id).SHIP_TO__c){
                soldTo.add(qu.SHIP_TO__c);  
            }
            
        }
        
        if(soldTo.size() > 0){
            List<Account> accList= [SELECT Id, City__c, Global_SubRegion__c,Shipping_Address_Line_1__c,Shipping_Address_Line_2__c,Shipping_Address_Line_3__c,
                                    Shipping_City__r.Name,Shipping_Postal_ZIP_Code__r.Name,
                                    Shipping_Country__r.Name,Shipping_State__r.Name,Shipping_Region_Master__c,Shipping_Sub_Region__c,
                                    Global_Region__c,
                                    ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,Billing_City__r.Name,
                                    Billing_Postal_ZIP_Code__r.Name,Billing_State__r.Name,Billing_Country__r.Name
                                    FROM Account WHERE Id IN :soldTo limit 1];
            
            //List<Contact> conList = [select Id,Name,AccountId from Contact where AccountId IN :soldTo]; 
            
            /*for(Contact con: conList){
                conToMap.put(con.AccountId,con);
            }
            */
            for(Account acc: accList){
                ShipTo.put(acc.Id,acc);
            }
            
            for(Quote q : trigger.new){
                if(ShipTo.containsKey(q.SHIP_TO__c)){
                    Account acc = ShipTo.get(q.SHIP_TO__c);
                    q.SHIP_TO_ADDRESS_LINE_1__c = acc.Shipping_Address_Line_1__c;
                    q.SHIP_TO_ADDRESS_LINE_2__c = acc.Shipping_Address_Line_2__c;
                    q.SHIP_TO_ADDRESS_LINE_3__c = acc.Shipping_Address_Line_3__c;
                    q.Ship_To_City__c = acc.Shipping_City__r.Name;
                    q.SHIP_TO_POSTAL_CODE__c = acc.Shipping_Postal_ZIP_Code__r.Name;
                    q.Ship_To_State__c = acc.Shipping_State__r.Name;
                    q.Ship_To_Country__c = acc.Shipping_Country__r.Name;
                    q.Ship_To_Global_Region__c = acc.Shipping_Region_Master__c;
                    q.Ship_To_Global_SubRegion__c = acc.Shipping_Sub_Region__c;
                }
                
                /*if(conToMap.containsKey(q.SHIP_TO__c)){
                    q.SHIP_To_Contact_Name__c	 = conToMap.get(q.SHIP_TO__c).Id;
                }
                
                if(conToMap.containsKey(q.SOLD_TO__c)){
                    q.ContactId = conToMap.get(q.SOLD_TO__c).Id;
                }*/
                
                if(ShipTo.containsKey(q.SOLD_TO__c)){
                    Account acc = ShipTo.get(q.SOLD_TO__c);
                    q.ADDRESS_LINE_1__c = acc.ADDRESS_LINE_1__c;
                    q.ADDRESS_LINE_2__c = acc.ADDRESS_LINE_2__c;
                    q.ADDRESS_LINE_3__c = acc.ADDRESS_LINE_3__c;
                    q.CityCustom__c = acc.Billing_City__r.Name;
                    q.POSTAL_CODE__c = acc.Billing_Postal_ZIP_Code__r.Name;
                    q.StateCustom__c = acc.Billing_State__r.Name;
                    q.CountryCustom__c = acc.Billing_Country__r.Name;
                    q.Global_Region__c = acc.Global_Region__c;
                    q.Global_SubRegion__c = acc.Global_SubRegion__c;
                }
            }
        }
    }
    
    
    IF(trigger.isBefore && Trigger.IsInsert){
        
        Map<Id, Account> ShipTo = new Map<Id, Account>();
        Map<Id, Contact> conToMap = new Map<Id, Contact>();
        set<Id> soldTo = new set<Id>();
        for (Quote qu : Trigger.new) {
            if(qu.SOLD_TO__c != null){
                soldTo.add(qu.SOLD_TO__c);  
            }
            
            if(qu.SHIP_TO__c != null){
                soldTo.add(qu.SHIP_TO__c);  
            }
            
        }
        
        if(soldTo.size() > 0){
            List<Account> accList= [SELECT Id, City__c, Global_SubRegion__c,Shipping_Address_Line_1__c,Shipping_Address_Line_2__c,Shipping_Address_Line_3__c,
                                    Shipping_City__r.Name,Shipping_Postal_ZIP_Code__r.Name,
                                    Shipping_Country__r.Name,Shipping_State__r.Name,Shipping_Region_Master__c,Shipping_Sub_Region__c,
                                    Global_Region__c,
                                    ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,Billing_City__r.Name,
                                    Billing_Postal_ZIP_Code__r.Name,Billing_State__r.Name,Billing_Country__r.Name
                                    FROM Account WHERE Id IN :soldTo];
            
            //List<Contact> conList = [select Id,Name,AccountId from Contact where AccountId IN :soldTo]; 
            
            /*for(Contact con: conList){
                conToMap.put(con.AccountId,con);
            }
            */
            for(Account acc: accList){
                ShipTo.put(acc.Id,acc);
            }
            
            for(Quote q : trigger.new){
                if(ShipTo.containsKey(q.SHIP_TO__c)){
                    Account acc = ShipTo.get(q.SHIP_TO__c);
                    q.SHIP_TO_ADDRESS_LINE_1__c = acc.Shipping_Address_Line_1__c;
                    q.SHIP_TO_ADDRESS_LINE_2__c = acc.Shipping_Address_Line_2__c;
                    q.SHIP_TO_ADDRESS_LINE_3__c = acc.Shipping_Address_Line_3__c;
                    q.Ship_To_City__c = acc.Shipping_City__r.Name;
                    q.SHIP_TO_POSTAL_CODE__c = acc.Shipping_Postal_ZIP_Code__r.Name;
                    q.Ship_To_State__c = acc.Shipping_State__r.Name;
                    q.Ship_To_Country__c = acc.Shipping_Country__r.Name;
                    q.Ship_To_Global_Region__c = acc.Shipping_Region_Master__c;
                    q.Ship_To_Global_SubRegion__c = acc.Shipping_Sub_Region__c;
                }
                
                /*if(conToMap.containsKey(q.SHIP_TO__c)){
                    q.SHIP_To_Contact_Name__c	 = conToMap.get(q.SHIP_TO__c).Id;
                }
                
                if(conToMap.containsKey(q.SOLD_TO__c)){
                    q.ContactId = conToMap.get(q.SOLD_TO__c).Id;
                }*/
                
                if(ShipTo.containsKey(q.SOLD_TO__c)){
                    Account acc = ShipTo.get(q.SOLD_TO__c);
                    q.ADDRESS_LINE_1__c = acc.ADDRESS_LINE_1__c;
                    q.ADDRESS_LINE_2__c = acc.ADDRESS_LINE_2__c;
                    q.ADDRESS_LINE_3__c = acc.ADDRESS_LINE_3__c;
                    q.CityCustom__c = acc.Billing_City__r.Name;
                    q.POSTAL_CODE__c = acc.Billing_Postal_ZIP_Code__r.Name;
                    q.StateCustom__c = acc.Billing_State__r.Name;
                    q.CountryCustom__c = acc.Billing_Country__r.Name;
                    q.Global_Region__c = acc.Global_Region__c;
                    q.Global_SubRegion__c = acc.Global_SubRegion__c;
                }
            }
        }
    }
    
   /* IF(trigger.isBefore && Trigger.IsInsert){
        Map<Id, Account> ShipTo = new Map<Id, Account>();
        Map<Id, Contact> conToMap = new Map<Id, Contact>();
        set<Id> soldTo = new set<Id>();
        for (Quote qu : Trigger.new) {
            if(qu.SOLD_TO__c == null){
                qu.SOLD_TO__c = qu.AccountId;
                
            }
            
            if(qu.SHIP_TO__c == null){
                qu.SHIP_TO__c = qu.AccountId;
            }
            system.debug('qu.AccountId-->'+qu.AccountId);
            if(string.isNotBlank(qu.Account_Id__c)){
                soldTo.add(qu.Account_Id__c);  
            }
            
        }
        
        if(soldTo.size() > 0){
            List<Account> accList= [SELECT Id, City__c, Global_SubRegion__c,Shipping_Address_Line_1__c,Shipping_Address_Line_2__c,Shipping_Address_Line_3__c,
                                    Shipping_City__r.Name,Shipping_Postal_ZIP_Code__r.Name,
                                    Shipping_Country__r.Name,Shipping_State__r.Name,Shipping_Region_Master__c,Shipping_Sub_Region__c,
                                    Global_Region__c,
                                    ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,Billing_City__r.Name,
                                    Billing_Postal_ZIP_Code__r.Name,Billing_State__r.Name,Billing_Country__r.Name
                                    FROM Account WHERE Id IN :soldTo];
            
            system.debug('accList-->'+accList.size());
            if(accList.size() > 0){
            for(Account acc: accList){
                ShipTo.put(acc.Id,acc);
            }
                
            
            for(Quote q : trigger.new){
                if(ShipTo.containsKey(q.Account_Id__c)){
                    Account acc = ShipTo.get(q.Account_Id__c);
                    q.SHIP_TO_ADDRESS_LINE_1__c = acc.Shipping_Address_Line_1__c;
                    q.SHIP_TO_ADDRESS_LINE_2__c = acc.Shipping_Address_Line_2__c;
                    q.SHIP_TO_ADDRESS_LINE_3__c = acc.Shipping_Address_Line_3__c;
                    q.Ship_To_City__c = acc.Shipping_City__r.Name;
                    q.SHIP_TO_POSTAL_CODE__c = acc.Shipping_Postal_ZIP_Code__r.Name;
                    q.Ship_To_State__c = acc.Shipping_State__r.Name;
                    q.Ship_To_Country__c = acc.Shipping_Country__r.Name;
                    q.Ship_To_Global_Region__c = acc.Shipping_Region_Master__c;
                    q.Ship_To_Global_SubRegion__c = acc.Shipping_Sub_Region__c;
                }
                
                if(ShipTo.containsKey(q.Account_Id__c)){
                    Account acc = ShipTo.get(q.Account_Id__c);
                    q.ADDRESS_LINE_1__c = acc.ADDRESS_LINE_1__c;
                    q.ADDRESS_LINE_2__c = acc.ADDRESS_LINE_2__c;
                    q.ADDRESS_LINE_3__c = acc.ADDRESS_LINE_3__c;
                    q.CityCustom__c = acc.Billing_City__r.Name;
                    q.POSTAL_CODE__c = acc.Billing_Postal_ZIP_Code__r.Name;
                    q.StateCustom__c = acc.Billing_State__r.Name;
                    q.CountryCustom__c = acc.Billing_Country__r.Name;
                    q.Global_Region__c = acc.Global_Region__c;
                    q.Global_SubRegion__c = acc.Global_SubRegion__c;
                }
            }
        }
    }
    }
    
    */
    if(Trigger.isBefore && Trigger.isInsert){
        QuoteTriggerHandler.assignInsertRecordType(Trigger.new);
        QuoteTriggerHandler.assignAccountOwner(Trigger.new);
    }
    
    If(trigger.isBefore && Trigger.isUpdate){
        QuoteTriggerHandler.assignUpdateRecordType(Trigger.new,trigger.oldMap);
        QuoteTriggerHandler.contactUpdateEmail(Trigger.new,trigger.oldMap);
       }
    
    
     If(trigger.isAfter && Trigger.isUpdate){
        QuoteTriggerHandler.contactChangeTOContract(Trigger.new,trigger.oldMap);
        QuoteTriggerHandler.ShipTocontactChangeTOContract(Trigger.new,trigger.oldMap);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
       QuoteTriggerHandlerForLatestRevNo.updateLatestRevisionDetails(Trigger.new,trigger.oldMap);
    }
}