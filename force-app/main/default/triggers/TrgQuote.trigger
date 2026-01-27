/*
*  Author   : 
*  Date     : 7-05-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      7-05-2022        trigger to update Financial year.
*********************************************/

trigger TrgQuote on Quote (After insert , After Update,Before Update )   
{
    
    Org_Setting__mdt orgMtd = [Select Active__c from Org_Setting__mdt where Masterlabel ='QuoteTrigger'];
    
    public String StrQuoteID{get;set;}
    opportunity obj = new Opportunity();
    opportunity obj1 = new Opportunity();
    List<quote> qty = new List<quote>();
    List<quote> qtyopp = new List<quote>();
    Set<id> QID = new Set<id>();
    list<Account> ObjAccount = new list<Account>();
    //  list<Quote> ObjQuote1 = new list<Quote>();
    public Quote errorObj{get;set;}
    list<opportunity> opty = new list<opportunity>();
    list<opportunity> opty1 = new list<opportunity>();
    list<opportunity> opty2 = new list<opportunity>();
    list<Quote> qty1 = new list<Quote>();
    Map<Id, Quote> quoteWQuoteLineItems; 
    Boolean discountLiMore;
     System.debug('Inside the trigger*** 1'+QuoteRecursionCheck.RunQTrg);
     System.debug('Inside the trigger*** 1'+QuoteRecursionCheck.isfirsttime);
     System.debug('Inside the trigger*** 1');
    if(QuoteRecursionCheck.RunQTrg)
    {
        if(QuoteRecursionCheck.isfirsttime)
        {
            QuoteRecursionCheck.isfirsttime=false;   
            if(orgMtd.Active__c==true){  
                System.debug('Inside the trigger*** 1');
                // to check for quote line items by discount allowed
                quoteWQuoteLineItems =new Map<Id, Quote>( [SELECT Id, (SELECT Id,Discount__c,Discount_Allowed__c,Discount_Allowed_New__c,Discount_in_Value__c,List_Price__c,Discount_Type__c,Approved_Discount__c,P_D3__c ,P_D2__c   FROM Quote_Line_Items__r),(SELECT Id,Discount__c,Discount_Type__c,Approved_Discount__c,Discount_in_Value__c,Manula_Option_List_Price__c, Discount_Allowed_New__c,Discount_Allowed__c FROM Quote_Line_Options__r) FROM Quote WHERE Id = :Trigger.newMap.values()]);
                system.debug('quoteWQuoteLineItems--->' + quoteWQuoteLineItems);
                for(Quote ObjQuote: Trigger.new)
                {
                    StrQuoteID = ObjQuote.id;
                    String OpptyID = ObjQuote.OpportunityId;
                    QID.add( ObjQuote.id);
                    System.debug('StrQuoteID'+StrQuoteID);
                    if(trigger.isAfter && trigger.isInsert){
                        
                        System.debug('QuoteID'+StrQuoteID);
                        CreateQuotetriggerHandler Triggerhandler = new CreateQuotetriggerHandler();
                        Triggerhandler.QuoteUpdate(StrQuoteID);            
                        
                    } 
                    
                    if(trigger.isAfter && trigger.isUpdate){
                        system.debug('in update');
                        obj = [Select id,name,Amount, Quote_Amount__c from opportunity where id =: OpptyID];
                        
                        if(trigger.newMap.get(ObjQuote.Id).Quote_Total_Summary_of_Sales_Price__c != trigger.oldMap.get(ObjQuote.Id).Quote_Total_Summary_of_Sales_Price__c){
                            System.debug('Reaching Here to update quote amount');
                            obj.Quote_Amount__c =  ObjQuote.Quote_Total_Summary_of_Sales_Price__c;
                            opty.add(obj);
                        }
                        
                    }
                    
                    system.debug('<=== Started  selected Status RELEASED then copy the Grand Total to Opportunity Amount ===>');
                    
                    if(trigger.isBefore && trigger.isUpdate){
                        system.debug('RELEASED update');
                        obj = [Select id,name,Amount, Quote_Amount__c from opportunity where id =: OpptyID];
                        
                        if(ObjQuote.Status == 'RELEASED' && ObjQuote.id ==StrQuoteID){
                            obj.Amount =  ObjQuote.Grand_Total__c;
                            obj.Quote_Amount__c=ObjQuote.Grand_Total__c;
                            ObjQuote.Sync_Quote__c = true;
                            qty = [Select id,name,Grand_Total__c, Sync_Quote__c from Quote 
                                   where Sync_Quote__c = true and opportunityId =: OpptyID and id !=:ObjQuote.ID and Status!='CLOSE - REVISIED'];
                            System.debug('qty'+qty.size());
                            for (Quote q: qty ){
                                q.Sync_Quote__c = false;
                                //q.Status='CANCELLED';
                                qty1.add(q);
                            }
                        }
                        if(qty.size()==0 &&ObjQuote.Sync_Quote__c==false)
                            if(obj.Amount !=0){
                                //if (CheckRecursive.isExecuting) return;
                                //CheckRecursive.isExecuting = true;
                                obj.Amount =  0;
                                system.debug('call this first');
                                opty1.add(obj);
                            }
                    } 
                }
                if(opty.size() > 0){update opty;}
                if(opty1.size() > 0){update opty1;}
                if(qty1.size() > 0){update qty1;}
                
                
                //update opty1;
                
                //update qty1;
                System.debug('Lock for Approval');
                // to lock record for approval
                if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert)) {
                    System.debug('in side Lock for Approval');
                    Set<id>ids=new set<id>();
                    map<id,Quote> qMap=new map<id,Quote>();
                    for (Quote qt: Trigger.new) {
                        ids.add(qt.id);
                    }
                    For(Quote q:[Select id,name,Approved_Amount__c,Subsidiary__c,Subsidiary__r.Quote_Approval__c,Subsidiary__r.Discount_Level_1__c,
                                 Subsidiary__r.Discount_Level_2__c,Subsidiary__r.Discount_Level_3__c,Quote_Total_List_Price__c,Quote_Totoal__c 
                                 from Quote where id in:ids])
                    {
                        qMap.put(q.id,q); 
                    }
                    User u=[select id,name,Level__c from user where id=:userinfo.getUserId()];
                    for (Quote qt: Trigger.new) {
                        //if (qt.Discount__c != Trigger.oldMap.get(qt.Id).Discount__c) {
                        qt.Quote_Locked_for_Approval__c = false;
                        System.debug('qMap.get(qt.id).Subsidiary__r.Quote_Approval__c'+qMap.get(qt.id).Subsidiary__r.Quote_Approval__c);
                        if(qMap.get(qt.id).Subsidiary__r.Quote_Approval__c=='Line Item level')
                        {
                            System.debug('in side Line item wise Approval');
                            Quote thisQuote = quoteWQuoteLineItems.get(qt.Id);
                            
                            for(Quote_Line_Item_Custom__c qli:thisQuote.Quote_Line_Items__r){
                                
                                switch on qt.Owner_Level__c {
                                    when 'L1'{
                                        system.debug('inside Discount_Type__c'+qli.Discount_Type__c);
                                        system.debug('inside Discount__c'+qli.Discount__c);
                                        system.debug('inside Approved_Discount__c'+qli.Approved_Discount__c);
                                        system.debug('inside Discount_Allowed_New__c'+qli.Discount_Allowed_New__c);
                                        system.debug('inside P_D2__c'+qli.P_D2__c);
                                        
                                        if (qli.Discount_Type__c == 'Percent' && qli.Discount__c != NULL && qli.Discount__c > qli.Discount_Allowed_New__c && qli.Discount__c !=qli.Approved_Discount__c && !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D2__c)) {
                                            qt.Quote_Locked_for_Approval__c = true;
                                            break;
                                        }
                                        
                                        if (qli.Discount_Type__c == 'Percent' && qli.Discount__c != NULL && qli.Discount__c > qli.Discount_Allowed_New__c && qli.Discount__c !=qli.Approved_Discount__c && qli.Approved_Discount__c != null&&  !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D3__c)) {
                                            qt.Quote_Locked_for_Approval__c = true;
                                            break;
                                        }
                                        
                                        
                                        if(qli.Discount_Type__c == 'Value' && qli.Discount_in_Value__c > 0){
                                            if(qli.Discount_Allowed_New__c < ((qli.Discount_in_Value__c /qli.List_Price__c)*100) && qli.Approved_Discount__c != null && !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D2__c)){
                                                qt.Quote_Locked_for_Approval__c = true;
                                                break;
                                            }
                                            
                                        }
                                        
                                        
                                        if(qli.Discount_Type__c == 'Value' && qli.Discount_in_Value__c > 0){
                                            if(qli.Discount_Allowed_New__c < ((qli.Discount_in_Value__c /qli.List_Price__c)*100) &&  qli.Approved_Discount__c != null && !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D3__c)){
                                                qt.Quote_Locked_for_Approval__c = true;
                                                break;
                                            }
                                            
                                        }
                                    }
                                    
                                    when 'L2'{
                                        system.debug('inside Discount_Type__c'+qli.Discount_Type__c);
                                        system.debug('inside Discount__c'+qli.Discount__c);
                                        system.debug('inside Approved_Discount__c'+qli.Approved_Discount__c);
                                        system.debug('inside Discount_Allowed_New__c'+qli.Discount_Allowed_New__c);
                                        system.debug('inside P_D2__c'+qli.P_D2__c);
                                        
                                        
                                        if (qli.Discount_Type__c == 'Percent' && qli.Discount__c != NULL && qli.Discount__c > qli.Discount_Allowed_New__c && qli.Discount__c!=qli.Approved_Discount__c &&  qli.Approved_Discount__c != null && !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D3__c)){
                                            system.debug('Inside level 2'+qt.Quote_Locked_for_Approval__c);
                                            qt.Quote_Locked_for_Approval__c = true;
                                            break;
                                        }
                                        
                                        if(qli.Discount_Type__c == 'Value' && qli.Discount_in_Value__c > 0){
                                            if(qli.Discount_Allowed_New__c < ((qli.Discount_in_Value__c /qli.List_Price__c)*100) &&  qli.Approved_Discount__c != null && !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D3__c)){
                                                qt.Quote_Locked_for_Approval__c = true;
                                                break;
                                            }
                                            
                                        }
                                        
                                        
                                        
                                    }
                                    
                                    when 'L3'{
                                    }
                                }
                            }
                            for(Quote_Line_Options__c qli:thisQuote.Quote_Line_Options__r){ 
                                
                                /* when 'L1'{
if (qli.Discount__c != NULL && qli.Discount__c > qli.Discount_Allowed_New__c && qli.Discount__c>qli.Approved_Discount__c) {
qt.Quote_Locked_for_Approval__c = true;
system.debug('---exceeded---');
break;
}
}*/
                                switch on qt.Owner_Level__c {
                                    when 'L1'{
                                        if (qli.Discount_Type__c == 'Percent' && qli.Discount__c != NULL && qli.Discount__c > qli.Discount_Allowed_New__c && qli.Discount__c !=qli.Approved_Discount__c && !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D2__c)) {
                                            qt.Quote_Locked_for_Approval__c = true;
                                            break;
                                        }
                                        
                                        if (qli.Discount_Type__c == 'Percent' && qli.Discount__c != NULL && qli.Discount__c > qli.Discount_Allowed_New__c && qli.Discount__c !=qli.Approved_Discount__c && qli.Approved_Discount__c != null&&  !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D3__c)) {
                                            qt.Quote_Locked_for_Approval__c = true;
                                            break;
                                        }
                                        
                                        if(qli.Discount_Type__c == 'Value' && qli.Discount_in_Value__c > 0){
                                            if(qli.Discount_Allowed_New__c < ((qli.Discount_in_Value__c /qli.Manula_Option_List_Price__c)*100) && qli.Approved_Discount__c != null && !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D2__c)){
                                                qt.Quote_Locked_for_Approval__c = true;
                                                break;
                                            }
                                            
                                        }
                                        
                                        if(qli.Discount_Type__c == 'Value' && qli.Discount_in_Value__c > 0){
                                            if(qli.Discount_Allowed_New__c < ((qli.Discount_in_Value__c /qli.Manula_Option_List_Price__c)*100) &&  qli.Approved_Discount__c != null && !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D3__c)){
                                                qt.Quote_Locked_for_Approval__c = true;
                                                break;
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    when 'L2'{
                                        
                                        if (qli.Discount_Type__c == 'Percent' && qli.Discount__c != NULL && qli.Discount__c > qli.Discount_Allowed_New__c && qli.Discount__c!=qli.Approved_Discount__c &&  qli.Approved_Discount__c != null &&!( qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D3__c)){
                                            qt.Quote_Locked_for_Approval__c = true;
                                            break;
                                        }
                                        
                                        if(qli.Discount_Type__c == 'Value' && qli.Discount_in_Value__c > 0){
                                            if(qli.Discount_Allowed_New__c < ((qli.Discount_in_Value__c /qli.Manula_Option_List_Price__c)*100) &&  qli.Approved_Discount__c != null && !(qli.Approved_Discount__c > qli.Discount_Allowed_New__c && qli.Approved_Discount__c < qli.P_D3__c)){
                                                qt.Quote_Locked_for_Approval__c = true;
                                                break;
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    when 'L3'{
                                    }
                                }
                                
                            }
                            
                            QuoteRecursionCheck.isfirsttime=true;    
                        }
                        else
                        {
                            if(qMap.get(qt.id).Subsidiary__r.Quote_Approval__c=='Quote Level')
                            {
                                System.debug('in side Quote wise Approval');
                                Double Disc=0;
                                if(u.Level__c=='L1')
                                    Disc=qMap.get(qt.id).Subsidiary__r.Discount_Level_1__c;
                                if(u.Level__c=='L2')
                                    Disc=qMap.get(qt.id).Subsidiary__r.Discount_Level_2__c;
                                if(u.Level__c=='L3')
                                    Disc=qMap.get(qt.id).Subsidiary__r.Discount_Level_3__c;
                                if((qMap.get(qt.id).Quote_Total_List_Price__c-(qMap.get(qt.id).Quote_Total_List_Price__c*(Disc/100)))>qMap.get(qt.id).Quote_Totoal__c && (qMap.get(qt.id).Approved_Amount__c>qMap.get(qt.id).Quote_Totoal__c||qMap.get(qt.id).Approved_Amount__c==0)) 
                                {
                                    qt.Quote_Locked_for_Approval__c = true;
                                    qt.Approved_Amount_Temp__c= qMap.get(qt.id).Quote_Totoal__c;	// qMap.get(qt.id).Quote_Total_List_Price__c-(qMap.get(qt.id).Quote_Total_List_Price__c*(Disc/100));
                                    
                                }
                                else
                                    qt.Quote_Locked_for_Approval__c = false;
                            }
                        }
                        
                    }
                }
                
                System.debug('Inside the trigger*** 2');
                
                //Event After Update
                if(trigger.isAfter && trigger.isUpdate){
                    //Update Discount on Lines and Options.
                    CreateQuotetriggerHandler.updateQLIDiscount(Trigger.OldMap, Trigger.New);
                    CreateQuotetriggerHandler.updateQLODiscount(Trigger.OldMap, Trigger.New);
                    
                    System.debug('Inside the trigger*** 3');
                    
                    //Updating the Record Types of QLI and Line Options once Quote Status is being updated to 'Released'.
                    Set<id> parentQuoteID = new Set<id>();
                    //List<Quote_Line_Options__c> lstQLO = new List<Quote_Line_Options__c>();
                    //List<Quote_Line_Item_Custom__c> lstQLI = new List<Quote_Line_Item_Custom__c>();
                    List<Quote_Line_Options__c> lstQLOUpd = new List<Quote_Line_Options__c>();
                    List<Quote_Line_Item_Custom__c> lstQLIUpd = new List<Quote_Line_Item_Custom__c>();
                    
                    for(Quote qt: Trigger.new){
                        if(qt.Status == 'RELEASED'){
                            parentQuoteID.add(qt.id);
                        }
                    }
                    
                    //lstQLO = [select id,RecordTypeId from Quote_Line_Options__c where Quote__c IN: QID1];
                    //lstQLI = [select id, RecordTypeId from Quote_Line_Item_Custom__c where Quote__c IN: QID1];
                    Id idQLO = Schema.SObjectType.Quote_Line_Options__c.getRecordTypeInfosByName().get('After Released').getRecordTypeId();
                    Id idQLI = Schema.SObjectType.Quote_Line_Item_Custom__c.getRecordTypeInfosByName().get('QLI After Released').getRecordTypeId();
                    
                    for(Quote_Line_Item_Custom__c qli : [select id, RecordTypeId from Quote_Line_Item_Custom__c where Quote__c IN: parentQuoteID]){
                        qli.RecordTypeId = String.valueOf(idQLI);
                        lstQLIUpd.add(qli);
                    }
                    update lstQLIUpd;
                    
                    for(Quote_Line_Options__c qlo : [select id,RecordTypeId from Quote_Line_Options__c where Quote__c IN: parentQuoteID]){
                        qlo.RecordTypeId = String.valueOf(idQLO);
                        lstQLOUpd.add(qlo);
                    }
                    update lstQLOUpd;
                }
            }
            
            
            if(Trigger.IsBefore && Trigger.IsUpdate)
            {
                
                Map<String, Quote> idOppQuoteMap = new Map<String, Quote>();
                for(Quote quote : trigger.new) {
                    
                    system.debug('quote.Opportunity' + quote.Opportunity); 
                    if(quote.Status == 'CLOSE - SC CREATED') {
                        idOppQuoteMap.put(quote.OpportunityId, quote);
                    }
                }
                system.debug('idOppQuoteMap'+idOppQuoteMap);
                
                List<Opportunity> oppList = [SELECT Id,  
                                             (SELECT Id FROM Quotes WHERE Status = 'CLOSE - SC CREATED')
                                             FROM Opportunity WHERE Id IN :idOppQuoteMap.keySet()];
                system.debug('oppList' +oppList);
                for(Opportunity opp : oppList) 
                {   
                    
                    if(opp.Quotes == null) 
                        continue;
                    else
                    {
                        System.debug('opp.Quotes.size()'+opp.Quotes.size());
                        if(opp.Quotes.size()==0 || (opp.Quotes.size()==1 && opp.Quotes[0].id==idOppQuoteMap.get(opp.id).id))
                        {
                            continue;                    
                        }
                       /* else
                            idOppQuoteMap.get(opp.Id).addError('Opportunity already has a CLOSE - SC CREATED quote'); */
                    }
                }
            } 
            system.debug('<=== Started selected in Subsidiary Permited Currency and Permited Language ===>');
            
            
            if(Trigger.IsBefore && (trigger.isUpdate || trigger.isInsert)) {
                
                Map<String, Quote> idSubQuoteMap = new Map<String, Quote>();
                map<String,List<String>> idlistCurrencyMap = new map<String,List<String>>();
                map<String,List<String>> idlistLanguageMap = new map<String,List<String>>();
                
                for(Quote quote : trigger.new) {
                    
                    system.debug('Quote.Subsidiari Master' + quote.Subsidiary__c); 
                    idSubQuoteMap.put(quote.Subsidiary__c, quote);
                }
                system.debug('idSubQuoteMap'+idSubQuoteMap);
                
                List<Subsidiari_Master__c> subList = [SELECT Id, Permitted_Language__c, Permitted_Currency__c
                                                      FROM Subsidiari_Master__c WHERE Id IN :idSubQuoteMap.keySet()];
                system.debug('subList' +subList);
                for(Subsidiari_Master__c sub : subList) 
                {   
                    idlistCurrencyMap.put(sub.id,sub.Permitted_Currency__c.split(';'));
                    idlistLanguageMap.put(sub.id,sub.Permitted_Language__c.split(';'));
                    system.debug('in loop idlistCurrencyMap==> ' +idlistCurrencyMap);
                    system.debug('in loop idlistLanguageMap==> ' +idlistLanguageMap);
                }
                
                for(Quote qsub:trigger.new){
                    if(qsub.Subsidiary__c!=null){
                        /*if(!idlistCurrencyMap.get(qsub.Subsidiary__c).contains(qsub.CurrencyIsoCode)){
qsub.addError('Your Quote Currency must be the same as your Subsidiary Currency.');
}*/
                       /* if(!idlistLanguageMap.get(qsub.Subsidiary__c).contains(qsub.Language__c)){
                            qsub.addError('Your Quote Language must be the same as your Subsidiary Language.');
                        }  */
                    }
                }
            }
            
            system.debug('<=== Ended selected in Subsidiary Permited Currency and Permited Language ===>');
        }
        
        // for Quote Approved Logic
        if(Trigger.IsAfter && Trigger.IsUpdate)
        {
            set<id> ids=new set<id>();
            List<id> qIds=new List<Id>();
            for(Quote q:trigger.new)
            {
                if(q.Skip_Status_Validation__c)
                    qIds.add(q.id);
                
                if(q.Approval_Status_From_HOD__c=='Approved' && Trigger.oldMap.get(q.Id).Approval_Status_From_HOD__c!='Approved')
                    ids.add(q.Id);
            }
            List<Quote> qlist =new List<Quote>();
            if(ids.size()>0)
                qlist=[select id,name,Quote_Locked_for_Approval__c,Approved_Amount_Temp__c from quote where id in:ids];
            List<Quote_Line_Item_Custom__c> QLIList=new List<Quote_Line_Item_Custom__c>();
            if(ids.size()>0)
                QLIList=[select id,name,Discount__c,Approved_Discount__c from Quote_Line_Item_Custom__c where Quote__c in:ids];
            for(Quote_Line_Item_Custom__c QLI:QLIList)
            {
                QLI.Approved_Discount__c=QLI.Discount__c;
            }
            update QLIList;
            
            
            List<Quote_Line_Options__c>QLOList=new List<Quote_Line_Options__c>();
            if(ids.size()>0)
                QLOList=[select id,name,Discount__c,Approved_Discount__c from Quote_Line_Options__c where Quote__c in:ids];
            for(Quote_Line_Options__c QLI:QLOList)
            {
                QLI.Approved_Discount__c=QLI.Discount__c;
            }
            update QLOList;
            for(Quote q:qlist)
            {
                q.Quote_Locked_for_Approval__c=false;
                q.Approved_Amount__c=q.Approved_Amount_Temp__c;
            }
            update qlist;
            
            if(qIds.size()>0)
                CreateQuotetriggerHandler.updateQuote(qIds);
        }
        
        //for Quote should not be allowed to be Released if no Products added
        if(Trigger.IsBefore && Trigger.IsUpdate)
        {
            // set<id> ids=new set<id>();
            for(Quote q:trigger.new)
            {
                if(q.Line_Item_Count_2__c==0 && q.Status=='RELEASED' && q.Status != trigger.oldMap.get(q.Id).status && RecursiveTriggerHandler.isNewQuoteCode == false)
                {
                    if(!Test.isRunningTest())
                        q.addError('Please add the products'); 
                }
            }
            Set<id> qId = new Set<id>();
            for(Quote qt: trigger.new){
                if(qt.Status == 'CLOSE - SC CREATED'){
                    qId.add(qt.Id);
                }
            }
            map<id,list<Contract>> cmap=new map<id,list<Contract>>();
            List<Contract> con = new List<Contract>();
            if(qId.size() >0){
                AggregateResult[] conCount = [SELECT Quote__c, COUNT(Id) ContractCount FROM 
                                              Contract WHERE Quote__c =: qId GROUP BY Quote__c];
                System.debug('conCount ===> '+conCount.size());
                for(Quote qt: trigger.new){
                    if(conCount.size() == 0 && qt.Status == 'CLOSE - SC CREATED'){
                        qt.addError('Please create Contract first.');
                    } 
                }
            }
            
        }
    }
    
    
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Quote q: Trigger.new ){
            if(!CreateContractsFromQuoteController.isbypassStatusRule){
            if(q.QU_REVISION_NUMBER__c !='000' & q.status=='DISCARD/VOID' && Trigger.oldMap.get(q.Id).Status != q.Status ){
                q.addError('You can change the status only if the Status is "created " and the Revision Number should be "000"');
            }
            else
                if(q.QU_REVISION_NUMBER__c =='000'){
                    if(Trigger.oldMap.get(q.Id).Status != q.Status && Trigger.oldMap.get(q.Id).Status !='CREATED' && q.status=='DISCARD/VOID'){
                        q.addError('You can change the status only if the Status is "created " and the Revision Number should be "000"');
                    }
                    
                }  
            }
        }
    }
    

    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        set<Id> ids = new set<Id>();
        for(Quote qt : trigger.new){
            if(qt.Is_DTA_Quote__c){
                if(!qt.Price_in_Word_Required__c){
                    qt.Price_in_Word_Required__c = true; 
                }
            }
            
        }
        
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        
        system.debug('inside update');
        set<Id> ownerId = new set<Id>();
        map<Id,Id> subWithQuoMap =  new map<Id,Id>();
        for(Quote qt : Trigger.new){
            if(qt.Discount__c != trigger.oldMap.get(qt.Id).Discount__c && string.isNotBlank(qt.Subsidiary__c)){
                ownerId.add(qt.OwnerId);
                subWithQuoMap.put(qt.Subsidiary__c,qt.Id);
            }
        }
        
        map<Id,User> ApproverMap = new map<Id,User>();
        if(ownerId.size() > 0){
            
            List<User>userList = [select Id, ManagerId , Manager.Name, Manager.Level__c, Manager.Manager.Level__c ,Manager.ManagerId,Manager.Manager.Name, level__c from User where Id IN : ownerId limit 1];
            for(User us :userList){
                ApproverMap.put(us.Id,us);
            }
            
        }        
        
        if(subWithQuoMap.size() > 0){
            List<Quote> quoteList = [select Id, Name, discount__c,OwnerId, Owner_Level__c, Approval_Status__c,Subsidiary__r.Quote_Approval__c, Subsidiary__c, Subsidiary__r.Discount_Level_1__c,
                                     Subsidiary__r.Discount_Level_2__c, Approver_User__c ,Quote_Locked_for_Approval__c, Subsidiary__r.Discount_Level_3__c 
                                     ,(SELECT Id, Discount__c, Quote__r.Owner_Level__c,Discount_in_Value__c,Discount_Type__c FROM Quote_Line_Items__r) from Quote where Id In : subWithQuoMap.values()];
            
            List<Quote> UpdateQuoteRecords = new List<Quote>();
            system.debug('inside for if'+quoteList.size());
            
            integer counterLevel1 = 0;
            integer totalLineItem = 0;
            if(quoteList.size()> 0){
                
                for(Quote qt : quoteList){
                    system.debug('inside for if'+qt.Subsidiary__r.Quote_Approval__c);
                    system.debug('inside for if'+qt.Quote_Locked_for_Approval__c);
                    if(qt.Subsidiary__r.Quote_Approval__c == 'Quote Level' && subWithQuoMap.containskey(qt.Subsidiary__c) /*&& qt.Quote_Locked_for_Approval__c*/){
                        system.debug('inside for if'+qt.Quote_Locked_for_Approval__c);
                        switch on qt.Owner_Level__c {
                            when 'L1'{
                                system.debug('inside switch'+qt.Owner_Level__c);
                                
                                if(qt.Discount__c > qt.Subsidiary__r.Discount_Level_1__c  && 
                                   qt.Discount__c <= qt.Subsidiary__r.Discount_Level_2__c
                                   && string.isNOTBlank(ApproverMap.get(qt.OwnerId).ManagerId)){
                                       qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).ManagerId;
                                       UpdateQuoteRecords.add(qt);
                                   }else 
                                       
                                       if(qt.Discount__c > qt.Subsidiary__r.Discount_Level_2__c 
                                          && qt.Discount__c <= qt.Subsidiary__r.Discount_Level_3__c
                                          && string.isNOTBlank(ApproverMap.get(qt.OwnerId).Manager.ManagerId)){
                                              qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).Manager.ManagerId;
                                              UpdateQuoteRecords.add(qt);
                                          } else if(qt.Discount__c < qt.Subsidiary__r.Discount_Level_1__c ){
                                              qt.Approver_User__c = null;
                                              UpdateQuoteRecords.add(qt);
                                          }
                                
                            }
                            when 'L2'{
                                system.debug('inside switch'+qt.Owner_Level__c);
                                if(qt.Discount__c > qt.Subsidiary__r.Discount_Level_2__c 
                                   && qt.Discount__c <= qt.Subsidiary__r.Discount_Level_3__c
                                   && string.isNOTBlank(ApproverMap.get(qt.OwnerId).ManagerId)){
                                       qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).ManagerId;
                                       UpdateQuoteRecords.add(qt);
                                   } else if(qt.Discount__c < qt.Subsidiary__r.Discount_Level_2__c ){
                                       qt.Approver_User__c = null;
                                       UpdateQuoteRecords.add(qt);
                                   }
                                
                            }
                            When 'L3'{
                                
                            }
                        }
                    }
                    
                    /*else if(qt.Subsidiary__r.Quote_Approval__c == 'Line Item level' && subWithQuoMap.containskey(qt.Subsidiary__c) && qt.Quote_Locked_for_Approval__c){

set<Id> managerId = new set<Id>();
for(Quote_Line_Item_Custom__c qtc : qt.Quote_Line_Items__r){
totalLineItem = qt.Quote_Line_Items__r.size();
switch on qtc.Quote__r.Owner_Level__c {
when 'L1'{
system.debug('else inside switch'+qt.Owner_Level__c);

if(qtc.Discount__c > qt.Subsidiary__r.Discount_Level_1__c  && 
qt.Discount__c <= qt.Subsidiary__r.Discount_Level_2__c
&& string.isNOTBlank(ApproverMap.get(qt.OwnerId).ManagerId)){
//qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).ManagerId;
counterLevel1 ++;
//UpdateQuoteRecords.add(qt);
}else 

if(qt.Discount__c > qt.Subsidiary__r.Discount_Level_2__c 
&& qt.Discount__c <= qt.Subsidiary__r.Discount_Level_3__c
&& string.isNOTBlank(ApproverMap.get(qt.OwnerId).Manager.ManagerId)){
qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).Manager.ManagerId;
//UpdateQuoteRecords.add(qt);
counterLevel1++;
} else if(qt.Discount__c < qt.Subsidiary__r.Discount_Level_1__c ){
qt.Approver_User__c = null;
//UpdateQuoteRecords.add(qt);
counterLevel1 -- ;
}

}
when 'L2'{
system.debug('inside switch'+qt.Owner_Level__c);
if(qt.Discount__c > qt.Subsidiary__r.Discount_Level_2__c 
&& qt.Discount__c <= qt.Subsidiary__r.Discount_Level_3__c
&& string.isNOTBlank(ApproverMap.get(qt.OwnerId).ManagerId)){
qt.Approver_User__c = (Id)ApproverMap.get(qt.OwnerId).ManagerId;
//UpdateQuoteRecords.add(qt);
counterLevel1++;
} else if(qt.Discount__c < qt.Subsidiary__r.Discount_Level_2__c ){
qt.Approver_User__c = null;
//UpdateQuoteRecords.add(qt);
counterLevel1 --;
}

}
When 'L3'{

}
}

}
system.debug('counterLevel'+counterLevel1+'  totalLineItem '+totalLineItem);
if(counterLevel1 == totalLineItem){
UpdateQuoteRecords.add(qt);
}
}
*/
                }
                
            }
            
            
            
            system.debug('counterLevel'+UpdateQuoteRecords.size());
            if(UpdateQuoteRecords.size () > 0){
                update UpdateQuoteRecords;
            }
        }
        
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Quote con : Trigger.new){
            if((con.ExpirationDate < system.today() || con.ExpirationDate ==null) && con.ExpirationDate != Trigger.oldMap.get(con.Id).ExpirationDate ){
                con.addError('You Cannot make Quote whose date is expired or null');
            }
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        //if (CheckRecursive.isExecuting) return;
        system.debug('inside after update'+CheckRecursive.isExecutingQuote);
        if(!CheckRecursive.isExecutingQuote){
            
            CheckRecursive.isExecutingQuote = true;
            map<Id,Quote> qIdmap = new  map<Id,Quote>();
            map<Id,Quote> oIdmap = new  map<Id,Quote>();
            for(Quote con : Trigger.new){
                if(con.ExpirationDate < system.today() && con.ExpirationDate != Trigger.oldMap.get(con.Id).ExpirationDate ){
                    con.addError('You Cannot make Quote whose date is expired');
                }
                
                if(con.ExpirationDate != Trigger.oldMap.get(con.Id).ExpirationDate && con.ExpirationDate >= system.today() && con.ExpirationDate !=null){
                    if(string.isNotBlank(con.Id) ){
                        qIdmap.put(con.Id,con);
                    }
                    
                    if(string.isNotBlank(con.OpportunityId) ){
                        oIdmap.put(con.OpportunityId,con);
                    }
                }
            }
            
            List<Contract> qlist = new List<Contract>();
            if(qIdmap.size() > 0){
                List<Contract> conList = [select Id ,Quote__c,Expiration_Date__c from Contract where Quote__c IN : qIdmap.keyset() FOR UPDATE];
                if(conList.size() > 0){
                for(Contract q : conList){
                    if(qIdmap.containskey(q.Quote__c)){
                        if( q.Expiration_Date__c != qIdmap.get(q.Quote__c).ExpirationDate){
                            q.Expiration_Date__c = qIdmap.get(q.Quote__c).ExpirationDate;
                            q.Expiration_Date_Change_Reason__c = qIdmap.get(q.Quote__c).Expiration_Date_Change_Reason__c;
                            qlist.add(q);
                        }
                    }
                }
                }
            }
            
            
            List<Opportunity> opplist = new List<Opportunity>();
            
            system.debug('inside size check'+oIdmap.size());
            if(oIdmap.size() > 0){
                system.debug('inside size');
               List<Opportunity> opList =  [select Id ,CloseDate from Opportunity where Id IN : oIdmap.keyset() FOR UPDATE];
                if(opList.size() > 0){
                for(Opportunity q : opList){
                    if(oIdmap.containskey(q.Id)){
                        system.debug('inside containse');
                        if( q.CloseDate != oIdmap.get(q.Id).ExpirationDate){
                            system.debug('inside if');
                            q.CloseDate = oIdmap.get(q.Id).ExpirationDate;
                            q.Expiration_Date_Change_Reason__c = oIdmap.get(q.Id).Expiration_Date_Change_Reason__c;
                            opplist.add(q);
                        }
                    }
                }
                }
            }
            
            if(qlist.size() > 0){
                if (Schema.sObjectType.Contract.isUpdateable()) {
                   update qlist;
                }
            }
            
            if(opplist.size() > 0){
                update opplist;
            }
        }
    }
    
    
    if(Trigger.isbefore && Trigger.isUpdate){
        set<Id> Ids = new set<Id>();
        
        for(Quote qtc: Trigger.new){
            if(qtc.Approval_Status__c =='Approved' && qtc.Approval_Status__c !=trigger.oldMap.get(qtc.Id).Approval_Status__c){
                Ids.add(qtc.Id);
            }
        }
        List<Quote_Line_Item_Custom__c> qliList = new List<Quote_Line_Item_Custom__c>();
        if(Ids.size() > 0){
            List< Quote >quoteItems = new List<Quote>([SELECT Id,Approval_Status__c, (SELECT Id,Discount__c,Goes_for_Approval__c,Discount_Allowed__c,Discount_Allowed_New__c,Discount_in_Value__c,List_Price__c,Discount_Type__c,Approved_Discount__c,P_D3__c ,P_D2__c   FROM Quote_Line_Items__r where  Goes_for_Approval__c =:true),(SELECT Id,Discount__c,Approved_Discount__c, Discount_Allowed_New__c,Discount_Allowed__c FROM Quote_Line_Options__r) FROM Quote WHERE Id IN :Ids]);
            for(Quote qt : quoteItems){
                for(Quote_Line_Item_Custom__c qtc :qt.Quote_Line_Items__r){
                    
                    if(qtc.Goes_for_Approval__c){
                        if(qtc.Discount_Type__c == 'Percent'){
                            qtc.Approved_Discount__c = qtc.Discount__c;
                            qtc.Goes_for_Approval__c = false;
                            qliList.add(qtc);
                        }else  if(qtc.Discount_Type__c == 'Value'){
                            qtc.Approved_Discount__c = ((qtc.Discount_in_Value__c /qtc.List_Price__c)*100);
                            qtc.Goes_for_Approval__c = false;
                            qliList.add(qtc);
                            
                        }
                    }
                    
                }
            }
        }
        
        if(qliList.size() >0){
            update qliList;
        }
    }
    
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Quote q : Trigger.new) {
            Quote oldQuote = Trigger.oldMap.get(q.Id);
            System.debug('pre '+ ReviseQuoteController.isbypassRule);
            System.debug('pre 2'+ ReOpenQuoteFromContract.isbypassRule);
            System.debug('pre 3'+ CreateContractsFromQuoteController.isbypassRule);
            if (oldQuote.Status != q.Status && (ReviseQuoteController.isbypassRule == false && ReOpenQuoteFromContract.isbypassRule == false && 
                                                CreateContractsFromQuoteController.isbypassRule == false) && 
                (q.Status == 'CLOSE - REVISED' || q.Status == 'CLOSE - SC CREATED')) {
                    q.addError('You cannot set the status to '+ q.Status+' by manually.');
                }
        }
    }     
    //=========== Shubham Kadu =============
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Quote q : Trigger.new) {
            Quote oldQuote = Trigger.oldMap.get(q.Id);
           
            if (oldQuote.Status != q.Status && (ReviseQuoteController.isbypassRule == false && ReOpenQuoteFromContract.isbypassRule == false && 
                                                CreateContractsFromQuoteController.isbypassRule == false) && 
                (q.Status == 'CANCELLED AFTER PM')) {
                    q.addError('You cannot set the status to '+ q.Status+' by manually.');
                }
        }
    }     
     // ===================
    
    /*/ ==========Shubham Kadu=========
    
   if (Trigger.isBefore && Trigger.isInsert) {
        QuoteSoldToShipToUpdate.handleInsert(Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        QuoteSoldToShipToUpdate.handleUpdate(Trigger.oldMap, Trigger.new);
    }
    // ===================  */
    
    
    
}