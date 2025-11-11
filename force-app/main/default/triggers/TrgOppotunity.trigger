/*
*  Author   : Amol wagh
*  Date     : 5-07-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      5-07-2022   Amol Wagh      trigger to update Financial year and Subsidiary
V1.2      7-07-2022   Amol Wagh      trigger to update Opportunity number
V1.3      11-07-2022  Saksham Jain   trigger to check opportunity close date should be greated than quote date
V1.4      29-07-2022   Amol Wagh      trigger to update Opportunity close date today +two years and Opportunity Number
V1.5      11-08-2022   Sourav Kushari  Trigger to Update Prepare by Field Atomaticly When Opportunity Create
*********************************************/
trigger TrgOppotunity on Opportunity (After Update,Before Insert,After insert,Before Update, Before Delete)
{ 
    
    public String StrOpptyId{get;set;}
    public List<Period> LstPrd{get;set;}
    Public User ObjUsr{get;set;}
    public integer FinalFY;
    try
    {
        if(RecursiveTriggerHandler2.isFirstTimeOnOpp) 
        {
            if(trigger.isBefore && trigger.isInsert)
            {
                for(Opportunity opp : Trigger.New) {
                    opp.Prepared_By__c = UserInfo.getUserId();
                }
                if(trigger.isBefore && trigger.isInsert){ 
                    //updated This logic to assign fy and Subsidiary
                    Fiscal_Year_Master__c f=[select id,name from Fiscal_Year_Master__c where Active__c=true limit 1];
                    List<id>ids =new list<id>();
                    map<id,id> uMap=new map<id,id>();
                    Map<id,Unique_No__c> sMap=new Map<id,Unique_No__c>();
                    
                    // Get Last Count
                    for(Unique_No__c u:[select id,name,Serial_No__c,Object_Name__c,Subsidiary__c,Fiscal_Year__c from Unique_No__c where Fiscal_Year__c=:f.id and
                                        Object_Name__c='Opportunity' For Update])
                    { 
                        sMap.put(u.Subsidiary__c,u);
                    }
                    
                    map<id,String> subMap=new Map<id,String> ();
                    for(Opportunity ObjOppty: trigger.new)
                    {
                        ids.add(ObjOppty.OwnerId);
                    }
                    
                    for(User_Setup__c u:[select id,name,User__c,Subsidiari__c,Subsidiari__r.name  from User_Setup__c where User__c in: ids])
                    {
                        uMap.put(u.User__c,u.Subsidiari__c);
                        subMap.put(u.User__c,u.Subsidiari__r.name);
                    }
                    for(Opportunity ObjOppty: trigger.new)
                    {
                        ObjOppty.Financial_Year__c= f.id;
                        ObjOppty.Subsidiary__c = uMap.get(ObjOppty.OwnerId); 
                        objoppty.closedate = system.today()+1825; // Five years
                        objoppty.stagename='New';
                        //V1.2
                        if(sMap.containskey(uMap.get(ObjOppty.OwnerId)))
                        {   
                            Unique_No__c un=sMap.get(uMap.get(ObjOppty.OwnerId));
                            String temp='';
                            for(Integer i=5;i>String.valueof(un.Serial_No__c+1).length();i--)
                            {
                                temp=temp+'0';
                                
                            }
                            temp=temp+String.valueof(un.Serial_No__c+1);
                            objoppty.Opportunity_Number_auto__c='O'+ subMap.get(ObjOppty.OwnerId)+f.Name+'-'+temp ;
                            un.Serial_No__c=un.Serial_No__c+1;
                            sMap.put(uMap.get(ObjOppty.OwnerId),un);
                        }
                        else
                        {
                            objoppty.Opportunity_Number_auto__c='O'+ subMap.get(ObjOppty.OwnerId)+f.Name+'-00001';
                            Unique_No__c un=new Unique_No__c();
                            un.Object_Name__c='Opportunity';
                            un.Subsidiary__c=uMap.get(ObjOppty.OwnerId);
                            un.Fiscal_Year__c=f.id;
                            un.Serial_No__c=1;  
                            sMap.put(uMap.get(ObjOppty.OwnerId),un);
                            
                        }
                        
                    } 
                    upsert sMap.values();
                    
                } 
            }
            
            if(trigger.IsUpdate && trigger.IsBefore)
            {
                List<id> obj=new List<id>();          
                for(Opportunity ObjOppty: Trigger.new)
                { 
                    obj.add(ObjOppty.Id);
                } 
                
                Map<Id,Opportunity> mp=new Map<Id,Opportunity>();
                
                mp.putAll([select id,name,Amount, CloseDate , Quote_Amount__c, (select id,name,Closed_Date__c from Quotes ) from opportunity where id in: obj]);
                
                for(Opportunity o:Trigger.new)
                {
                    Opportunity op=mp.get(o.Id);
                    // Quote qt = mp.get(o.Id);
                    for(Quote q: op.Quotes)
                    {
                        if(o.CloseDate< q.Closed_Date__c)
                        {
                            o.CloseDate.adderror('Opportunity Close Date should always be greater or equal to Quote Close Date');
                        }
                        
                    } 
                    
                }
                
            }
            
            
            if(trigger.isAfter && trigger.isInsert){
                
                
                for(Opportunity ObjOppty: Trigger.new)
                {
                    StrOpptyId = ObjOppty.id;
                    System.debug('ObjOppty'+StrOpptyId);
                    TriggerOpportunityHandler Triggerhandler = new TriggerOpportunityHandler();
                    Triggerhandler.OpptyRecUpdate(StrOpptyId);
                    //Triggerhandler.updateVisitOnOpportunity(Trigger.New, Trigger.NewMap);
                }
            }
            
            
            RecursiveTriggerHandler2.isFirstTimeOnOpp=false;
            
            system.debug('<=== Started selected in Subsidiary Permited Currency ===>');
            
            
            if(Trigger.IsBefore  && (trigger.isUpdate || trigger.isInsert)) {
                
                Map<String, Opportunity> idSubOppMap = new Map<String, Opportunity>();
                map<String,List<String>> idlistCurrencyMap = new map<String,List<String>>();
                
                for(Opportunity opp : trigger.new) {
                    
                    system.debug('Opportunity.Subsidiari Master' + opp.Subsidiary__c); 
                    idSubOppMap.put(opp.Subsidiary__c, opp);
                }
                system.debug('idSubOppMap'+idSubOppMap);
                
                List<Subsidiari_Master__c> subList = [SELECT Id, Permitted_Language__c, Permitted_Currency__c
                                                      FROM Subsidiari_Master__c WHERE Id IN :idSubOppMap.keySet()];
                system.debug('subList' +subList);
                for(Subsidiari_Master__c sub : subList) 
                {   
                    if(sub.Permitted_Currency__c!=null) 
                        idlistCurrencyMap.put(sub.id,sub.Permitted_Currency__c.split(';'));
                    system.debug('in loop idlistCurrencyMap==> ' +idlistCurrencyMap);
                }
                
                for(Opportunity oppsub:trigger.new){
                    if(oppsub.Subsidiary__c!=null && idlistCurrencyMap.get(oppsub.Subsidiary__c)!=null){
                        if(!idlistCurrencyMap.get(oppsub.Subsidiary__c).contains(oppsub.CurrencyIsoCode)){
                            oppsub.addError('Your Opportunity Currency must be the same as your Subsidiary Currency.');
                        }
                    }
                }
            }
            system.debug('<=== Ended selected in Subsidiary Permited Currency ===>');
            
        }
    }
    catch(exception e)
    {
        system.debug(e);
        trigger.new[0].adderror('Something went wrong, please contact System Admin with following details '+e);
    }
    Set<Id> oppId = new Set<Id>();
    if(Trigger.IsDelete && trigger.isBefore){
        for(Opportunity opp : Trigger.old) {
            oppId.add(opp.Id);
        }
        List <Quote> qtList = [select id, name from Quote where OpportunityId =: oppId];
        for(Opportunity opp1 : Trigger.old) {
            if(qtList.size()>0){
                opp1.adderror('Sorry, we cannot delete this record because Quotation already created.');
            }
        }
    }
    
    if(Trigger.isBefore && Trigger.isInsert) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        set<Id> ids = new set<Id>();
        for (Opportunity opp : Trigger.new) {
            ids.add(opp.AccountId);
        }
        
        List<Contact> conList = [select Id, AccountId from Contact where AccountId IN : ids];
        
        Map<Id,Id> conMap = new Map<Id,Id>(); 
        for(Contact con : conList){
            conMap.put(con.AccountId,con.Id);
        }
        
        for (Opportunity opp : Trigger.new) {
            if(conMap.containsKey(opp.AccountId) && opp.StageName == 'New' && string.isblank(opp.contact__c)){
                if(string.isNotBlank(conMap.get(opp.AccountId))){
                    opp.contact__c = conMap.get(opp.AccountId);
                }
                
            }
        }
    } 
    
    
     if(Trigger.isBefore && Trigger.isUpdate){
        for(Opportunity con : Trigger.new){
            if((con.closeDate < system.today() || con.closeDate ==null) && con.closeDate != Trigger.oldMap.get(con.Id).closeDate ){
                con.addError('You Cannot make Opportunity whose date is expired or null');
            }
        }
    }
     if(Trigger.isAfter && Trigger.isUpdate){
        if (CheckRecursive.isExecuting) return;
        CheckRecursive.isExecuting = true;
        map<Id,Opportunity> qIdmap = new  map<Id,Opportunity>();
        for(Opportunity con : Trigger.new){
            if(con.closeDate < system.today() && con.closeDate != Trigger.oldMap.get(con.Id).closeDate ){
                con.addError('You Cannot make Quote whose date is expired');
            }
            
            if(con.closeDate != Trigger.oldMap.get(con.Id).closeDate && con.closeDate >= system.today() && con.closeDate !=null){
                if(string.isNotBlank(con.Id) ){
                    qIdmap.put(con.Id,con);
                }
              }
        }
        
         Map<Id,Contract> qlist = new  Map<Id,Contract>();
        
        if(qIdmap.size() > 0){
            List<Contract> conlist = [select Id ,Opportunity__c,Expiration_Date__c from Contract where Opportunity__c IN : qIdmap.keyset() FOR UPDATE];
            if(conlist.size() > 0){
            for(Contract q :  conlist){
                if(qIdmap.containskey(q.Opportunity__c)){
                     if( q.Expiration_Date__c != qIdmap.get(q.Opportunity__c).closeDate){
                      q.Expiration_Date__c = qIdmap.get(q.Opportunity__c).closeDate;
                      q.Expiration_Date_Change_Reason__c = qIdmap.get(q.Opportunity__c).Expiration_Date_Change_Reason__c;
                      qlist.put(q.Id,q);
                     }
                }
            }
            }
        }
        
        
        Map<Id,Quote> opplist = new Map<Id,Quote>();
        if(qIdmap.size() > 0){
            List<Quote> quolist = [select Id ,ExpirationDate,OpportunityId  from Quote where OpportunityId IN : qIdmap.keyset() FOR UPDATE];
            if(quolist.size() > 0){
            for(Quote q : quolist){
                if(qIdmap.containskey(q.OpportunityId)){
                    if(q.ExpirationDate != qIdmap.get(q.OpportunityId).closeDate){
                        q.ExpirationDate  = qIdmap.get(q.OpportunityId).CloseDate;
                        q.Expiration_Date_Change_Reason__c = qIdmap.get(q.OpportunityId).Expiration_Date_Change_Reason__c;
                        opplist.put(q.Id,q);
                    }
                }
            }
            }
        }
        
        
        if(!qlist.isEmpty()){
            if (Schema.sObjectType.Contract.isUpdateable()) {
               update qlist.values();
            }
        }
        
        if(!opplist.isEmpty()){
            update opplist.values();
        }
    }
    
    if(Trigger.isBefore){
        if(trigger.isInsert ){
          for (Opportunity obj : Trigger.new) {
                //if (string.isNotblank(obj.Region__c)) {
                    obj.Region_For_Sharing__c =obj.Region__c; 
                //}
            }
              
        }
        
        if(Trigger.isUpdate){
            for (Opportunity obj : Trigger.new) {
                if (obj.Region__c!= Trigger.oldMap.get(obj.Id).Region__c) {
                    obj.Region_For_Sharing__c =obj.Region__c; 
                }
            }
            
        }
    }
    
     if (Trigger.isBefore  && Trigger.isInsert) {
        OpportunityTriggerHandler.assignInsertRecordType(Trigger.new);
        OpportunityTriggerHandler.assignAccountOwner(Trigger.new);
        OpportunityTriggerHandler.getOpportunityRegion(Trigger.new);
    }

    
    if (Trigger.isBefore && Trigger.isUpdate) {
        OpportunityTriggerHandler.assignUpdateRecordType(Trigger.new, Trigger.oldMap);
        OpportunityTriggerHandler.getUpdateOpportunityRegion(Trigger.new,Trigger.oldMap);
    }
    

}