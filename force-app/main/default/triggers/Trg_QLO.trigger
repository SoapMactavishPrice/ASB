trigger Trg_QLO on Quote_Line_Options__c (before insert, After insert ,before  delete, After Update, before Update) {

    if(Trigger.isBefore && Trigger.isUpdate){
        for(Quote_Line_Options__c pt : Trigger.new){
            if((pt.Manula_Option_List_Price__c != null && pt.Manula_Option_List_Price__c != 0)){
                if(pt.Discount__c != null && pt.Discount_in_Value__c !=null && pt.Discount__c != 0 && pt.Discount_in_Value__c != 0){
                    pt.addError('fill only one from  Discount or Discount in Value');
                }else if(pt.Discount__c != null && pt.Discount__c != 0.00){
                    pt.Discount_Type__c = 'Percent';
                    pt.Discount_in_Value__c = 0;
                } else if(pt.Discount_in_Value__c != null && pt.Discount_in_Value__c != 0.00){
                    pt.Discount_Type__c = 'Value'; 
                    pt.Discount__c = 0; 
                }
                else if((pt.Discount_in_Value__c == null || pt.Discount_in_Value__c == 0) && (pt.Discount__c == null || pt.Discount__c == 0)){
                    pt.Discount_Type__c = null; 
                    pt.Discount__c = 0; 
                    pt.Discount_in_Value__c = 0; 
                }
            }else{
                pt.Discount_Type__c = null; 
                pt.Discount__c = 0; 
                pt.Discount_in_Value__c = 0; 
            }
            
        }
     }
    //serial number
    if(Trigger.isBefore && (Trigger.isInsert)){
        set<Id> qId = new set<Id>(); 
        
        for(Quote_Line_Options__c pt : Trigger.new){
            qId.add(pt.Quote_Line_Item_Custom__c);
        }
        
        map<Id,Decimal> quoteMaxCount = new map<Id,decimal>();
        
        for(Quote_Line_Item_Custom__c qt: [select Id,Name,Max_Serial_Number__c from Quote_Line_Item_Custom__c where Id IN : qId]){
            quoteMaxCount.put(qt.Id,qt.Max_Serial_Number__c);
        }
        for(Quote_Line_Options__c qt :Trigger.new){
            if(quoteMaxCount.containskey(qt.Quote__c) && STring.isNotblank(String.valueOf(qt.Serial_Number__c))){
                system.debug('if conatins');
                if(string.isNotBlank(string.valueOf(quoteMaxCount.get(qt.Quote_Line_Item_Custom__c)))){
                    system.debug('if');
                    qt.Serial_Number__c=quoteMaxCount.get(qt.Quote_Line_Item_Custom__c)+10;
                    quoteMaxCount.put(qt.Quote_Line_Item_Custom__c, quoteMaxCount.get(qt.Quote_Line_Item_Custom__c) + 10);
                }else{
                    qt.Serial_Number__c=10; 
                    quoteMaxCount.put(qt.Quote_Line_Item_Custom__c, 10);
                }
            } 
            
           
            
        }
        //update quoteList.values();
        
    }
    
    if(Trigger.isBefore && (Trigger.IsInsert || Trigger.IsUpdate)){
        for(Quote_Line_Options__c qli : Trigger.new){
            if(qli.Discount_Type__c =='Value' && qli.Discount_in_Value__c !=null && qli.P_D3__c !=null && qli.Manula_Option_List_Price__c > 0){
                if(qli.P_D3__c  < (qli.Discount_in_Value__c / qli.Manula_Option_List_Price__c)*100){
                    system.debug('inside '+qli.Discount_in_Value__c / qli.Manula_Option_List_Price__c);
                    qli.Discount_in_Value__c.addError('Discount Value '+ ((qli.Discount_in_Value__c / qli.Manula_Option_List_Price__c)*100).SetScale(2) +'% Should not be greater than '+qli.P_D3__c+'%');
                }
                
            }
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Quote_Line_Options__c qli : trigger.new){
            if(qli.User_Level__c == 'L1'){
                    if(qli.P_D1__c != null){
                        qli.Discount_Allowed_New__c = qli.P_D1__c;
                    }
                }
                if(qli.User_Level__c == 'L2'){
                    if(qli.P_D2__c != null){
                        qli.Discount_Allowed_New__c = qli.P_D2__c;
                    }
                }
                if(qli.User_Level__c == 'L3'){
                    if(qli.P_D3__c != null){
                        qli.Discount_Allowed_New__c = qli.P_D3__c;
                    }
                }
        }
       
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        set<Id> qId = new set<Id>(); 
         set<Id> nowUpdateId = new set<Id>(); 
        for(Quote_Line_Options__c pt : Trigger.new){
            //if(trigger.newMap =trigger.oldMap){
            if(pt.Serial_Number__c == null){
               qId.add(pt.Quote_Line_Item_Custom__c);
               nowUpdateId.add(pt.Id);   
            }

            
        }
        
        map<Id,Decimal> uniqueSerialNumber = new map<Id,decimal>();
        map<Id,Decimal> quoteMaxCount = new map<Id,decimal>();
        if(qId.size() > 0){
        for(Quote_Line_Item_Custom__c qt: [Select Id ,Sr_No__c,Quote__c,Max_Serial_Number__c, (select Id ,Serial_Number__c ,Quote_Line_Item_Custom__c from  Quote_Line_Options__r where Id Not IN :nowUpdateId) 
                                           from  Quote_Line_Item_Custom__c  where ID IN : qId]){
            quoteMaxCount.put(qt.Id,qt.Max_Serial_Number__c);
            for(Quote_Line_Options__c qc :qt.Quote_Line_Options__r){
                if(qc.Serial_Number__c > 0){
                    uniqueSerialNumber.put(qc.Quote_Line_Item_Custom__c,qc.Serial_Number__c);
                }
                
            }
        }
        
        for(Quote_Line_Options__c qt :Trigger.new){
            system.debug('indese --> '+quoteMaxCount.get(qt.Quote_Line_Item_Custom__c));
            if(string.isBlank(string.valueOf(qt.Serial_Number__c)) && quoteMaxCount.containskey(qt.Quote_Line_Item_Custom__c)){
                if(quoteMaxCount.get(qt.Quote_Line_Item_Custom__c) == null){
                    system.debug('inside null');
                    qt.Serial_Number__c=10; 
                    quoteMaxCount.put(qt.Quote_Line_Item_Custom__c, 10);
                }else{
                    system.debug('inside well');
                    qt.Serial_Number__c=quoteMaxCount.get(qt.Quote_Line_Item_Custom__c)+10;
                    quoteMaxCount.put(qt.Quote_Line_Item_Custom__c, quoteMaxCount.get(qt.Quote_Line_Item_Custom__c) + 10);
                }
                    
            }
            
            if(uniqueSerialNumber.get(qt.Quote_Line_Item_Custom__c) == qt.Serial_Number__c && string.isNOTBlank(string.valueOf(qt.Serial_Number__c))){
                //qt.Serial_Number__c.addError('Serial Number Should be Unique');   
            }
            
        }
        } 
    }
    
    //==========================================================================================================================================================
    //==========================================================================================================================================================
    //                                                      Added by Vishesh
    //==========================================================================================================================================================
    //==========================================================================================================================================================
   
    
    if(trigger.isBefore && trigger.isDelete){
        List<Quote_Line_Options__c> listQLO = new List<Quote_Line_Options__c>();
        Set<Id> QuoteID = new Set<Id>();
        for (Quote_Line_Options__c QLO: trigger.old) {
            system.debug('QLO===>>>' + QLO.Quote__c);
            listQLO.add(QLO);
            QuoteID.add(QLO.Quote__c);
        }
        system.debug('listQLO==>>'+listQLO);
        system.debug('QuoteID==>>' + QuoteID);
        List<Quote> listQuote = new List<Quote>();
        listQuote = [Select id, name, Status from quote where id IN: QuoteID];
        system.debug('listQuote==>>>' + listQuote);
        for (Quote_Line_Options__c QLO: trigger.old) {
            for(Quote qList : listQuote){
                if(qList.Status == 'RELEASED' || qList.Status == 'UNDER NEGOTIATION - COOL' || qList.Status == 'UNDER NEGOTIATION - HOT' || qList.Status == 'WAITING FOR SC/DRG APPROVAL/CLARIFICATION' || qList.Status == 'CLOSE - REVISIED' || qList.Status == 'CLOSE - SC CREATED' || qList.Status == 'CLOSE - LOST'){
                    system.debug('qList.Status==>>>' + qList.Status);
                   /* QLO.adderror('You cannot delete Quote Line Options because it\'s status is '+ qList.Status);*/
                }
            }
        }
    }
    
    //===============================================================================================================
    //                                         SHUBHAM KADU (If Stage is Released Prevent Deletion Of Records)
    //===============================================================================================================
    if(trigger.isBefore && trigger.isDelete){
        // Collect unique parent Quote IDs
        Set<Id> quoteIds = new Set<Id>();
        for (Quote_Line_Options__c qli : Trigger.old) {
            quoteIds.add(qli.Quote__c);
        }
        
        // Fetch related Quotes only if there are Quote IDs
        if (!quoteIds.isEmpty()) {
            Map<Id, Quote> quoteMap = new Map<Id, Quote>(
                [SELECT Id, Status FROM Quote WHERE Id IN :quoteIds]
            );
            
            // Restrict deletion if the parent Quote's Status is "Released"
            for (Quote_Line_Options__c qli : Trigger.old) {
                Quote parentQuote = quoteMap.get(qli.Quote__c);
                if (parentQuote != null && ( parentQuote.Status == 'Released' ||  parentQuote.Status == 'CLOSE - SC CREATED' )) {
                    qli.addError('❌ You cannot delete this Quote Line Item because the Quote is in "' + parentQuote.Status + '" status.');
                }
            }
        }
    }
    
    
    
    
    //==========================================================================================================================================================
   
    
    //==========================================================================================================================================================
    //==========================================================================================================================================================
    //                                                      Added by Vishesh
    //==========================================================================================================================================================
    //                                      This trigger will make null desc as empty string
    ////==========================================================================================================================================================
    
    
    if(trigger.isAfter && trigger.isInsert){
        system.debug('This trigger will make null desc as empty string ');
        Set<id> QLOid = new Set<id>();
        for(Quote_Line_Options__c QLO : Trigger.new){
            QLOid.add(QLO.Id);
        }
        system.debug('QLOid ===>>>> ' + QLOid);
        List<Quote_Line_Options__c> listQLO = new List<Quote_Line_Options__c>();
        listQLO = [Select id, Discount__c, Discount_Allowed__c,Discount_Allowed_New__c, Discount_Description__c from Quote_Line_Options__c where id IN: QLOid];
        if(QLOid.size() > 0){
            List<Quote_Line_Options__c> listQLO2 = new List<Quote_Line_Options__c>();
            for(Quote_Line_Options__c varQLO : listQLO){
                System.debug('varQLO ===>>>> ' + varQLO);
                if((varQLO.Discount__c <= varQLO.Discount_Allowed_New__c || varQLO.Discount__c == null) && (varQLO.Discount_Description__c == 'Null' || varQLO.Discount_Description__c == 'undefined')){
                    system.debug('in of');
                    //varQLO.Discount_Description__c = '';
                    listQLO2.add(varQLO);
                }
            }
            if(listQLO2.size() > 0){
                update listQLO2;
            }
        }
        
    }
    
    
    
   
 
    
    //==========================================================================================================================================================
    //==========================================================================================================================================================
    //                                                      Added by Vishesh
    //==========================================================================================================================================================
    //												This trigger will fill the QLO fields
    ////==========================================================================================================================================================
    
    if(trigger.isAfter && trigger.isInsert){
        system.debug('This trigger will fill the QLO fields');
        Set<id> QLOid = new Set<id>();
        for(Quote_Line_Options__c QLO : Trigger.new){
            QLOid.add(QLO.Id);
        }
         system.debug('QLOid ===>>>> ' + QLOid);
        List<Quote_Line_Options__c> listQLO = new List<Quote_Line_Options__c>();
        listQLO = [Select id, Discount__c, Discount_Allowed__c, Discount_Allowed_New__c,Discount_Description__c, Product__r.Description,Select_Option__c, Manual_Product_Name__c from Quote_Line_Options__c where id IN: QLOid];
        if(QLOid.size() > 0){
            List<Quote_Line_Options__c> listQLO2 = new List<Quote_Line_Options__c>();
            for(Quote_Line_Options__c varQLO : listQLO){
                
                if(!varQLO.Select_Option__c){
                   system.debug('in if');
                    //varQLO.Description__c = varQLO.Product__r.Description;
                    listQLO2.add(varQLO);
                }
                else{
                    //varQLO.Description__c = varQLO.Manual_Product_Name__c;
                    listQLO2.add(varQLO);
                }
               
                
            }
            if(listQLO2.size() > 0){
                system.debug('in more that 1 size');
                update listQLO2;
            }
        }
        
    }
    
    
}