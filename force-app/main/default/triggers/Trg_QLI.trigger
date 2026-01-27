/*
*  Author   : Amol Wagh
*  Date     : 8-04-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      8-04-2022   Amol Wagh      To update Discount from Quote 
*********************************************/
trigger Trg_QLI on Quote_Line_Item_Custom__c (before insert,after insert,Before delete, before update, after update) {
    
    
    if(Trigger.isBefore && Trigger.isInsert){
        set<Id> qId = new set<Id>(); 
        
        for(Quote_Line_Item_Custom__c pt : Trigger.new){
            qId.add(pt.Quote__c);
        }
        
        map<Id,Quote> quoteList = new map<Id,Quote>([select Id,Name,Max_Serial_Number__c, (select Id ,Sr_No__c,Quote__c from  Quote_Line_Items__r ) from Quote where Id IN : qId]);
        map<Id,Decimal> quoteMaxCount = new map<Id,decimal>();
        
        if(qId.size() > 0){
            for(quote qt: [select Id,Name,Max_Serial_Number__c from Quote where Id IN : qId]){
                quoteMaxCount.put(qt.Id,qt.Max_Serial_Number__c);
            }
        }
        
        system.debug('quoteMaxCount'+quoteMaxCount);
        for(Quote_Line_Item_Custom__c qt :Trigger.new){
            if(quoteMaxCount.containskey(qt.Quote__c)){
                system.debug('if contains');
                if(string.isNotBlank(string.valueOf(quoteMaxCount.get(qt.Quote__c)))){
                    system.debug('if contains if'+quoteMaxCount.get(qt.Quote__c));
                    qt.Sr_No__c=quoteMaxCount.get(qt.Quote__c)+10;
                    quoteMaxCount.put(qt.Quote__c, quoteMaxCount.get(qt.Quote__c) + 10);
                    system.debug('if contains if'+qt.Sr_No__c);
                }else{
                    system.debug('contains else');
                    qt.Sr_No__c=10; 
                    quoteMaxCount.put(qt.Quote__c, 10);
                }
            } 
        }
        
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        //Boolean checkRecurssive = true;
        if(RecursiveTriggerHandler.isQuotelineTime){
            RecursiveTriggerHandler.isQuotelineTime = false;
            
            for(Quote_Line_Item_Custom__c pt : Trigger.new){
                system.debug('inside update List_Price__c'+pt.List_Price__c);
                system.debug('inside update Discount__c'+pt.Discount__c +' type '+pt.Discount_Type__c);
                system.debug('inside update Discount_in_Value__c'+pt.Discount_in_Value__c);
                system.debug('inside update 1'+pt.List_Price__c);
                //if(Trigger.oldMap.get(pt.Id).Discount_Type__c != pt.Discount_Type__c){
                
                
                //checkRecurssive = false;
                
                if((pt.List_Price__c != null && pt.List_Price__c != 0 && pt.Quantity__c > 0)){
                    if(pt.Discount__c != null && pt.Discount_in_Value__c !=null && pt.Discount__c != 0  && pt.Discount_in_Value__c !=0){
                        system.debug('inside 1');
                        pt.addError('fill only one from  Discount or Discount in Value');
                    }else if(pt.Discount__c != null && pt.Discount__c > 0.00){
                        system.debug('inside 2');
                        pt.Discount_Type__c = 'Percent';
                        pt.Discount_in_Value__c = 0;
                    } else if(pt.Discount_in_Value__c != null && pt.Discount_in_Value__c !=0){
                        system.debug('inside 4');
                        pt.Discount_Type__c = 'Value'; 
                        pt.Discount__c = 0; 
                    }
                    /*else if((pt.Discount_in_Value__c == null && pt.Discount__c == null) || ( pt.Discount_in_Value__c == 0 && pt.Discount__c == 0)){
system.debug('inside 1 else');
pt.Discount_Type__c = null; 
pt.Discount__c = 0; 
pt.Discount_in_Value__c = 0; 
}*/
                    
                }else{
                    system.debug('inside 1 else last'); 
                    pt.Discount_Type__c = null; 
                    pt.Discount__c = 0; 
                    pt.Discount_in_Value__c = 0; 
                }
                //}
            }
        }
    }
    
    if(Trigger.isBefore && (Trigger.IsInsert || Trigger.IsUpdate)){
        for(Quote_Line_Item_Custom__c qli : Trigger.new){
            //system.debug(qli.P_D3__c  +' -- '+ (qli.Discount_in_Value__c / qli.List_Price__c)*100);
            if(qli.Discount_Type__c =='Value' && qli.Discount_in_Value__c !=null && qli.P_D3__c !=null && qli.List_Price__c > 0 && qli.Quantity__c > 0){
                if(qli.P_D3__c  < (qli.Discount_in_Value__c / qli.List_Price__c)*100){
                    system.debug('inside '+qli.Discount_in_Value__c / qli.List_Price__c);
                    qli.Discount_in_Value__c.addError('Discount Value '+ ((qli.Discount_in_Value__c / qli.List_Price__c)*100).SetScale(2) +'% Should not be greater than '+qli.P_D3__c+'%');
                }
                
            }
        }
    }
    
    
    
    /* if(Trigger.isBefore && Trigger.isInsert){
set<Id> Ids = new set<Id>();
set<Id> qIds = new set<Id>();
set<Id> rIds = new set<Id>();
for(Quote_Line_Item_Custom__c qli : trigger.new){
if(string.isNotBlank(qli.Quote__r.Subsidiary__c)){
Ids.add(qli.Quote__r.Subsidiary__c);
rIds.add(qli.Id);
qIds.add(qli.Quote__c);
}
}

List<Quote> qlist = [select Id,Name,Max_Serial_Number__c,Subsidiary__c,Total_List_Price__c,Total_Sales_Price__c, (select Id ,Quote__c,Discount__c,List_Price__c,Sales_Price__c from  Quote_Line_Items__r) from Quote where Id IN : qIds];

if(Ids.size()  > 0){
Map<Id,Subsidiari_Master__c> sbMaster = new Map<Id,Subsidiari_Master__c>([select Id, Quote_Approval__c from Subsidiari_Master__c where Id IN : Ids]);
Decimal ListPrice = 0;
Decimal SalesPrice = 0;
Decimal Discount = 0 ;     
for(Quote qli : qlist){
if(sbMaster.containsKey(qli.Id) && sbMaster.get(qli.Id).Quote_Approval__c =='Line Item level'){
for(Quote_Line_Item_Custom__c qlio : qli.Quote_Line_Items__r){
ListPrice += qlio.List_Price__c;
SalesPrice+=qlio.Sales_Price__c;
}
}

qli.Overall_Discount__c =  (Total_Sales_Price__c/ListPrice)*100;
}
}
}
*/
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Quote_Line_Item_Custom__c qli : trigger.new){
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
        for(Quote_Line_Item_Custom__c pt : Trigger.new){
            if(pt.Sr_No__c == null){
                qId.add(pt.Quote__c);
                nowUpdateId.add(pt.Id);
            }
        }
        system.debug('quote Id'+qId);
        map<Id,Decimal> quoteMaxCount = new map<Id,decimal>();
        map<Id,Decimal> uniqueSerialNumber = new map<Id,decimal>();
        
        if(qId.size() > 0){
            system.debug('inside if'+qId.size());
            for(quote qt: [select Id,Name,Max_Serial_Number__c,(Select Id ,Sr_No__c,Quote__c from  Quote_Line_Items__r  where ID NOT IN : nowUpdateId) from Quote where Id IN : qId]){
                quoteMaxCount.put(qt.Id,qt.Max_Serial_Number__c);
                for(Quote_Line_Item_Custom__c qc :qt.Quote_Line_Items__r){
                    if(qc.Sr_No__c > 0){
                        uniqueSerialNumber.put(qc.quote__c,qc.Sr_No__c);
                    }
                }
            }
            
            system.debug('inside uniqueSerialNumber'+uniqueSerialNumber);
            
            for(Quote_Line_Item_Custom__c qt :Trigger.new){
                if(string.isNotBlank(string.valueOf(quoteMaxCount.get(qt.Quote__c)))){
                    system.debug('if');
                    qt.Sr_No__c=quoteMaxCount.get(qt.Quote__c)+10; 
                    quoteMaxCount.put(qt.Quote__c, quoteMaxCount.get(qt.Quote__c) + 10);
                    
                }else if(string.isBlank(string.valueOf(qt.Sr_No__c))){
                    qt.Sr_No__c=10;
                    quoteMaxCount.put(qt.Quote__c, 10);
                }
                
                
                if(uniqueSerialNumber.get(qt.Quote__c) == qt.Sr_No__c && string.isNOTBlank(string.valueOf(qt.Sr_No__c))){
                    qt.Sr_No__c.addError('Serial Number Should be Unique');   
                }
            }
        }
    }
    
    /*if(Trigger.isAfter && Trigger.isInsert){
QuoteLineTriggerHandler.updateQuoteDiscount(null,Trigger.New);
}

if(Trigger.isAfter && Trigger.isUpdate){
QuoteLineTriggerHandler.updateQuoteDiscount(Trigger.OldMap,Trigger.New);
}*/
    //==========================================================================================================================================================
    //==========================================================================================================================================================
    //                                                      Added by Vishesh
    //==========================================================================================================================================================
    //                                      this trigger prevents deletion of records
    ////==========================================================================================================================================================
    
    
    if(trigger.isBefore && trigger.isDelete){
        system.debug('this trigger prevents deletion of records');
        List<Quote_Line_Item_Custom__c> listQLI = new List<Quote_Line_Item_Custom__c>();
        Set<Id> QuoteID = new Set<Id>();
        for (Quote_Line_Item_Custom__c QLI: trigger.old) {
            system.debug('QLI===>>>' + QLI.Quote__c);
            listQLI.add(QLI);
            QuoteID.add(QLI.Quote__c);
        }
        system.debug('listQLI==>>'+listQLI);
        system.debug('QuoteID==>>' + QuoteID);
        List<Quote> listQuote = new List<Quote>();
        if(QuoteID.size() > 0){
        listQuote = [Select id, name, Status from quote where id IN: QuoteID];
        system.debug('listQuote==>>>' + listQuote);
        for (Quote_Line_Item_Custom__c QLI: trigger.old) {
            for(Quote qList : listQuote){
                if(qList.Status == 'RELEASED' || qList.Status == 'UNDER NEGOTIATION - COOL' || qList.Status == 'UNDER NEGOTIATION - HOT' || qList.Status == 'WAITING FOR SC/DRG APPROVAL/CLARIFICATION' || qList.Status == 'CLOSE - REVISIED' || qList.Status == 'CLOSE - SC CREATED' || qList.Status == 'CLOSE - LOST'){
                    system.debug('qList.Status==>>>' + qList.Status);
                  /*  QLI.adderror('You cannot delete  Quote Line Items because it\'s status is '+ qList.Status); */
                }
            }
        }
        }
    }
    //===============================================================================================================
    //  SHUBHAM KADU -- 31/03/2025 -- (If Stage is Released Prevent Deletion Of Records)
    //===============================================================================================================
    if(trigger.isBefore && trigger.isDelete){
        // Collect unique parent Quote IDs
        Set<Id> quoteIds = new Set<Id>();
        for (Quote_Line_Item_Custom__c qli : Trigger.old) {
            quoteIds.add(qli.Quote__c);
        }
        
        // Fetch related Quotes only if there are Quote IDs
        if (!quoteIds.isEmpty()) {
            Map<Id, Quote> quoteMap = new Map<Id, Quote>(
                [SELECT Id, Status FROM Quote WHERE Id IN :quoteIds]
            );
            
            // Restrict deletion if the parent Quote's Status is "Released"
            for (Quote_Line_Item_Custom__c qli : Trigger.old) {
                Quote parentQuote = quoteMap.get(qli.Quote__c);
                if (parentQuote != null && ( parentQuote.Status == 'Released' ||  parentQuote.Status == 'CLOSE - SC CREATED' )) {
                    qli.addError('❌❌ You cannot delete this Quote Line Item because the Quote is in "' + parentQuote.Status + '" status.');
                }
            }
        }
    }
    
    
    
    
    //==========================================================================================================================================================
    //==========================================================================================================================================================
    //                                                      Added by Vishesh
    //==========================================================================================================================================================
    //                                      This trigger will make null desc as empty string
    ////==========================================================================================================================================================
    
    
    if(trigger.isAfter && trigger.isInsert){
        system.debug('This trigger will make null desc as empty string ');
        Set<id> QLOid = new Set<id>();
        for(Quote_Line_Item_Custom__c QLO : Trigger.new){
            QLOid.add(QLO.Id);
        }
        system.debug('QLOid ===>>>> ' + QLOid);
        List<Quote_Line_Item_Custom__c> listQLO = new List<Quote_Line_Item_Custom__c>();
        if(QLOid.size() > 0){
        listQLO = [Select id, Discount__c, Discount_Allowed__c, Discount_Approval_Note__c, Quote__r.Opportunity.APPLICATION__c from Quote_Line_Item_Custom__c 
                   where id IN: QLOid];
        }
        if(QLOid.size() > 0){
            List<Quote_Line_Item_Custom__c> listQLO2 = new List<Quote_Line_Item_Custom__c>();
            for(Quote_Line_Item_Custom__c varQLO : listQLO){
                System.debug('varQLO ===>>>> ' + varQLO);
                System.debug('varQLO.Discount__c ===>>>> ' + varQLO.Discount__c);
                varQLO.Application__c = varQLO.Quote__r.Opportunity.APPLICATION__c;
                if((varQLO.Discount__c <= varQLO.Discount_Allowed__c || varQLO.Discount__c == null) && (varQLO.Discount_Approval_Note__c == 'Null' || varQLO.Discount_Approval_Note__c == 'undefined')){
                    system.debug('in of');
                    varQLO.Discount_Approval_Note__c = '';
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
    //                                              This trigger will fill the QLI fields
    ////==========================================================================================================================================================
    
    
    if(trigger.isAfter && trigger.isInsert){
        system.debug('This trigger will fill the QLI fields ');
        Set<id> QLOid = new Set<id>();
        for(Quote_Line_Item_Custom__c QLO : Trigger.new){
            QLOid.add(QLO.Id);
        }
        system.debug('QLOid ===>>>> ' + QLOid);
        List<Quote_Line_Item_Custom__c> listQLO = new List<Quote_Line_Item_Custom__c>();
        listQLO = [Select id, Discount__c, Discount_Allowed__c, Discount_Approval_Note__c, Quote__r.Opportunity.APPLICATION__c, Quote__r.QU_REVISION_NUMBER__c,Quote__r.Opportunity.Zero_Cooling__c, 
                   Quote__r.Discount__c,Quote__r.Opportunity.Class__c, Quote__r.Opportunity.MFG_AT__c, Product__r.UOM__c, Product__r.Model__c, Product__r.Division__c, Is_Manual__c, Product__r.Description, Product_Name__c
                   from Quote_Line_Item_Custom__c where id IN: QLOid];
        if(QLOid.size() > 0){
            List<Quote_Line_Item_Custom__c> listQLO2 = new List<Quote_Line_Item_Custom__c>();
            for(Quote_Line_Item_Custom__c varQLO : listQLO){
                if(!test.isRunningTest()){
                    //varQLO.Discount__c=varQLO.Quote__r.Discount__c;
                }
                
                System.debug('varQLO ===>>>> ' + varQLO);
                System.debug('Quote__r.QU_REVISION_NUMBER__ ===>>>> ' + varQLO.Quote__r.QU_REVISION_NUMBER__c);
                System.debug('varQLO.Quote__r.Opportunity.APPLICATION__c ===>>>> ' + varQLO.Quote__r.Opportunity.APPLICATION__c);
                
                if(!varQLO.Is_Manual__c){
                    varQLO.Division__c = varQLO.Product__r.Division__c;
                    varQLO.Model__c = varQLO.Product__r.Model__c;
                    varQLO.UOM__c = varQLO.Product__r.UOM__c;
                    //varQLO.Product_Description__c = varQLO.Product__r.Description;
                }
                /*else{
varQLO.Product_Description__c = varQLO.Product_Name__c;
}*/
                
                if(varQLO.Quote__r.QU_REVISION_NUMBER__c == '000'){
                    varQLO.Application__c = varQLO.Quote__r.Opportunity.APPLICATION__c;
                    varQLO.Class_2__c = varQLO.Quote__r.Opportunity.Class__c;
                    varQLO.MFG_AT__c = varQLO.Quote__r.Opportunity.MFG_AT__c;
                    varQLO.Zero_Cooling_2__c     = varQLO.Quote__r.Opportunity.Zero_Cooling__c;
                }
                listQLO2.add(varQLO);
            }
            if(listQLO2.size() > 0){
                update listQLO2;
            }
            
        }
    }
    
    
    //==========================================================================================================================================================
    //==========================================================================================================================================================
    //                                                      Added by Rishikesh k 21 08 2023
    //==========================================================================================================================================================
    //                                              This trigger will fill the QLI fields
    ////==========================================================================================================================================================
    
    
    if(Trigger.isAfter && Trigger.isUpdate){
        system.debug('inside update');
        set<Id> ownerId = new set<Id>();
        map<Id,Id> subWithQuoMap =  new map<Id,Id>();
        List<Quote_Line_Item_Custom__c> qtlineCustom = new List<Quote_Line_Item_Custom__c>();
        for(Quote_Line_Item_Custom__c qt : Trigger.new){
            if(qt.Discount_Type__c == 'Percent' && qt.Discount__c != trigger.oldMap.get(qt.Id).Discount__c){
                //ownerId.add(qt.OwnerId);
                subWithQuoMap.put(qt.Quote__c,qt.Id);
            } else if(qt.Discount_Type__c == 'Value' && qt.discount_in_Value__c != trigger.oldMap.get(qt.Id).discount_in_Value__c){
                //ownerId.add(qt.OwnerId);
                subWithQuoMap.put(qt.Quote__c,qt.Id);
                
            }
        }
        
        system.debug('subWithQuoMap'+subWithQuoMap);
        map<Id,User> ApproverMap = new map<Id,User>();
        
        if(subWithQuoMap.size() > 0){
            List<Quote> quoteList = [select Id, Name, discount__c,OwnerId, Owner_Level__c, Approval_Status__c,Subsidiary__r.Quote_Approval__c, Subsidiary__c, Subsidiary__r.Discount_Level_1__c,
                                     Subsidiary__r.Discount_Level_2__c, Approver_User__c ,Quote_Locked_for_Approval__c, Subsidiary__r.Discount_Level_3__c 
                                     ,(SELECT Id, Discount__c, Quote__r.Owner_Level__c,Discount_in_Value__c,List_Price__c,Discount_Type__c,
                                       P_D1__c,P_D2__c,P_D3__c,Discount_Allowed__c FROM Quote_Line_Items__r) from Quote where Id In : subWithQuoMap.keyset()];
            
            for(Quote quo: quoteList ){
                ownerId.add(quo.OwnerId);
            }
            
            List<User>userList = new List<User>();
            if(ownerId.size() >0){
                userList =   [select Id, ManagerId , Manager.Name, Manager.Level__c, Manager.Manager.Level__c ,Manager.ManagerId,Manager.Manager.Name, level__c 
                              from User where Id IN : ownerId];
                
                for(User us :userList){
                    ApproverMap.put(us.Id,us);
                }
            }
            List<Quote> UpdateQuoteRecords = new List<Quote>();
            system.debug('inside for if'+quoteList.size());
            
            integer counterLevel1 = 0;
            integer totalLineItem = 0;
            if(quoteList.size()> 0){
                
                for(Quote qt : quoteList){
                    system.debug('inside inside sub subsidary '+qt.Subsidiary__r.Quote_Approval__c);
                    system.debug('inside'+qt.Subsidiary__r.Quote_Approval__c);
                    system.debug('inside'+qt.Quote_Locked_for_Approval__c);
                    system.debug('inside');
                    if(qt.Subsidiary__r.Quote_Approval__c == 'Line Item level' && subWithQuoMap.containskey(qt.Id)){
                        system.debug('inside subsidary '+qt.Subsidiary__r.Quote_Approval__c);
                        set<Id> managerId = new set<Id>();
                        for(Quote_Line_Item_Custom__c qtc : qt.Quote_Line_Items__r){
                            system.debug('inside for if  subsidary ');
                            totalLineItem = qt.Quote_Line_Items__r.size();
                            system.debug('inside level P_D2__c'+qtc.P_D2__c+'P_D3__c'+qtc.P_D3__c);
                            switch on qt.Owner_Level__c {
                                
                                when 'L1'{
                                    system.debug('else inside switch'+qt.Owner_Level__c);
                                    if(qtc.Discount_Type__c == 'Percent'){
                                        if(qtc.Discount__c > qtc.P_D1__c  &&
                                           qtc.Discount__c <= qtc.P_D2__c
                                           && string.isNOTBlank(ApproverMap.get(qt.OwnerId).ManagerId)){
                                               qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).ManagerId;
                                               qtc.Goes_for_Approval__c = true;
                                               
                                               counterLevel1 ++;
                                           }else if(qtc.Discount__c > qtc.P_D2__c
                                                    && qtc.Discount__c <= qtc.P_D3__c
                                                    && string.isNOTBlank(ApproverMap.get(qt.OwnerId).Manager.ManagerId)){
                                                        qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).Manager.ManagerId;
                                                        qtc.Goes_for_Approval__c = true;
                                                        counterLevel1++;
                                                    } else if(qt.Discount__c < qt.Subsidiary__r.Discount_Level_1__c ){
                                                        qt.Approver_User__c = null;
                                                        qtc.Goes_for_Approval__c = false;
                                                        //UpdateQuoteRecords.add(qt);
                                                        counterLevel1 -- ;
                                                    }
                                    } 
                                    else{
                                        if(qtc.Discount_Type__c == 'Value' && qtc.Discount_in_Value__c > 0){
                                            if(qtc.Discount_Allowed__c < ((qtc.Discount_in_Value__c /qtc.List_Price__c)*100)){
                                                qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).Manager.ManagerId;
                                                qtc.Goes_for_Approval__c = true;
                                                counterLevel1++;
                                            }
                                        }
                                        
                                    }
                                }
                                when 'L2'{
                                    if(qtc.Discount_Type__c == 'Percent'){
                                        if(qtc.Discount__c > qtc.P_D2__c 
                                           && qtc.Discount__c <= qtc.P_D3__c
                                           && string.isNOTBlank(ApproverMap.get(qt.OwnerId).ManagerId)){
                                               qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).ManagerId;
                                               qtc.Goes_for_Approval__c = true;
                                               counterLevel1++;
                                           } else if(qtc.Discount__c < qtc.P_D2__c){
                                               qt.Approver_User__c = null;
                                               qtc.Goes_for_Approval__c = false;
                                               counterLevel1 --;
                                           }
                                        
                                    }else
                                        if(qtc.Discount_Type__c == 'Value' && qtc.Discount_in_Value__c > 0){
                                            if(qtc.Discount_Allowed__c < ((qtc.Discount_in_Value__c /qtc.List_Price__c)*100)){
                                                qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).ManagerId;
                                                qtc.Goes_for_Approval__c = true;
                                                counterLevel1++;
                                                
                                                
                                            }
                                            
                                        }
                                    
                                }
                                When 'L3'{
                                    
                                }
                            }
                            qtlineCustom.add(qtc);
                        }
                        system.debug('counterLevel'+counterLevel1+'  totalLineItem '+totalLineItem);
                        //if(counterLevel1 == totalLineItem){
                        UpdateQuoteRecords.add(qt);
                        system.debug('counterLevel'+counterLevel1+'  totalLineItem '+totalLineItem);
                    }
                }
                
            }
            
            
            
            system.debug('rec to upadte'+UpdateQuoteRecords.size());
            if(UpdateQuoteRecords.size () > 0){
                update UpdateQuoteRecords;
            }
        }
        
        if(qtlineCustom.size() > 0){
            update qtlineCustom;
        }
        
        
    }
    
    // added by rishikesh to get a original sequence no
    if(trigger.isBefore && trigger.isInsert){
        for(Quote_Line_Item_Custom__c con : Trigger.new){
            if(con.Sr_No__c > 0){
                con.Original_SQ_No__c   = con.Sr_No__c;
            }
        }
        
    }
}