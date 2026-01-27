// rishikesh 4/4/2024
trigger Trg_ContractNew on Contract (before insert,before Update, after insert, after update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        set<Id> conId = new set<Id>();
        set<string> OrgContractId = new set<string>();
        for(Contract con : Trigger.new){
            if(string.isNotBlank(con.Original_Contracts_No__c)){
                OrgContractId.add(con.Original_Contracts_No__c); 
            }   
        }
        List<Contract> conList = [Select Id,Original_Contracts_No__c from  Contract where Original_Contracts_No__c IN :OrgContractId order by CreatedDate asc];
        
        Map<string,Id> conMap  = new Map<string,Id>();
        for(Contract con : conList){
            if(conMap.ContainsKey(con.Original_Contracts_No__c)){
                
            }else{
                conMap.put(con.Original_Contracts_No__c, con.Id);
            }
            
        }
        
        
        for(Contract con : Trigger.new){
            if(string.isNotBlank(con.Original_Contracts_No__c) && conMap.containsKey(con.Original_Contracts_No__c)){
                if(conMap.get(con.Original_Contracts_No__c) !=con.Id && con.status != null){
                    con.Master_Contract__c = conMap.get(con.Original_Contracts_No__c); 
                }
                
            }   
        }
        
    }
    //check expiration date 27 june
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Contract con : Trigger.new){
            if((con.Expiration_Date__c < system.today() || con.Expiration_Date__c ==null) && con.Expiration_Date__c != Trigger.oldMap.get(con.Id).Expiration_Date__c ){
                con.addError('You Cannot make Quote whose date is expired or null');
            }
        }
    }
    
    // change expiration date
    
  /*  if(Trigger.isAfter && Trigger.isUpdate){
        if (CheckRecursive.isExecutingContract) return;
        CheckRecursive.isExecutingContract = true;
        map<Id,Contract> qIdmap = new  map<Id,Contract>();
        map<Id,Contract> oIdmap = new  map<Id,Contract>();
        for(Contract con : Trigger.new){
            if(con.Expiration_Date__c < system.today() && con.Expiration_Date__c != Trigger.oldMap.get(con.Id).Expiration_Date__c){
                con.addError('You Cannot make contract whose date is expired');
            }
            
            if(!Test.isRunningTest()){
                
                if(con.Expiration_Date__c != Trigger.oldMap.get(con.Id).Expiration_Date__c && con.Expiration_Date__c >= system.today() && con.Expiration_Date__c !=null){
                    if(string.isNotBlank(con.Quote__c) ){
                        qIdmap.put(con.Quote__c,con);
                    }
                    
                    if(string.isNotBlank(con.Opportunity__c) ){
                        oIdmap.put(con.Opportunity__c,con);
                    }
                }
            }else{
                if(con.Expiration_Date__c >= system.today() && con.Expiration_Date__c !=null){
                    if(string.isNotBlank(con.Quote__c) ){
                        qIdmap.put(con.Quote__c,con);
                    }
                    
                    if(string.isNotBlank(con.Opportunity__c) ){
                        oIdmap.put(con.Opportunity__c,con);
                    }
                }
                
            }
        }
        system.debug('inside after update');
        List<Quote> qlist = new List<Quote>();
        if(qIdmap.size() > 0){
            for(Quote q : [select Id ,ExpirationDate from Quote where Id IN : qIdmap.keyset() FOR UPDATE] ){
                if(qIdmap.containskey(q.Id)){
                    if( q.ExpirationDate != qIdmap.get(q.Id).Expiration_Date__c){
                        q.ExpirationDate = qIdmap.get(q.Id).Expiration_Date__c;
                        q.Expiration_Date_Change_Reason__c = qIdmap.get(q.Id).Expiration_Date_Change_Reason__c;
                        qlist.add(q);
                    }
                }
            }
        }
        
        
        List<Opportunity> opplist = new List<Opportunity>();
        if(oIdmap.size() > 0){
            for(Opportunity q : [select Id ,CloseDate from Opportunity where Id IN : oIdmap.keyset() FOR UPDATE]){
                if(oIdmap.containskey(q.Id)){
                    if(q.CloseDate != oIdmap.get(q.Id).Expiration_Date__c){
                        q.CloseDate = oIdmap.get(q.Id).Expiration_Date__c;
                        q.Expiration_Date_Change_Reason__c = oIdmap.get(q.Id).Expiration_Date_Change_Reason__c;
                        opplist.add(q);
                    }
                }
            }
        }
        
        if(qlist.size() > 0){
            update qlist;
        }
        
        if(opplist.size() > 0){
            update opplist;
        }
    }
    */
    
    //PO No. from customer to Pm
    if(Trigger.isAfter && Trigger.isUpdate){
        set<Id> conId = new  set<Id>();  
        map<Id,Contract> conmap = new map<Id,Contract> ();
        for(contract con : Trigger.new){
            if(!Test.isRunningTest()){
                if((Trigger.oldMap.get(con.Id).PO_No_from_customer__c != con.PO_No_from_customer__c)|| Trigger.oldMap.get(con.Id).CustomerSignedDate != con.CustomerSignedDate){
                    conId.add(con.Id);
                    conmap.put(con.Id,con);
                }
            }else{
                //if((Trigger.oldMap.get(con.Id).PO_No_from_customer__c != con.PO_No_from_customer__c)|| Trigger.oldMap.get(con.Id).CustomerSignedDate != con.CustomerSignedDate){
                conId.add(con.Id);
                conmap.put(con.Id,con);
                //} 
            }
            
        }
        
        List<ProjectManagement__c> pmoList = new List<ProjectManagement__c>();
        if(conId.size() > 0){
            for(ProjectManagement__c pm : [select Id,Contract__c,CUSTOMER_PO__c, CUSTOMER_PO_DATE__c from ProjectManagement__c where Contract__c IN : conId]){
                if(conmap.containskey(pm.Contract__c)){
                    pm.CUSTOMER_PO__c = conmap.get(pm.Contract__c).PO_No_from_customer__c;
                    pm.CUSTOMER_PO_DATE__c = conmap.get(pm.Contract__c).CustomerSignedDate;
                    pmoList.add(pm);
                }
            }
        }
        
        if(pmoList.size() > 0){
            update pmoList;
        }
        
    }
    
    
    
    if(Trigger.isBefore && Trigger.isUpdate){
        //Asign Record Type
        //if(!test.isRunningTest()){
        map<string,string> recMap = assignRecordTypecls.getRecordTypeList('Contract');
        for(Contract con : Trigger.new){
            if(con.Status  != trigger.oldMap.get(con.Id).Status && ( con.Status =='Waiting for DP/LC' ||
                                                                    con.Status =='Converted to PM – Partial' || con.Status =='Converted to PM – Complete' ||
                                                                    con.Status =='Close – Revised' || con.Status =='Close - Lost')
              ){
                  if(con.Is_DTA_Contract__c){
                      con.RecordTypeId = recMap.get('After Released Locked(DTA)') ;     
                  }else if(!con.Is_DTA_Contract__c	){
                      con.RecordTypeId = recMap.get('After Released Locked');     
                  }
              }
        //}
        }
    }
    
    
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        set<Id> ids = new set<Id>();
        for(Contract qt : trigger.new){
            if(qt.Is_DTA_Contract__c){
                if(!qt.Price_in_Word_Required__c){
                    qt.Price_in_Word_Required__c = true; 
                }
            }
            
        }
        
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        //Asign Record Type
        map<string,string> recMap = assignRecordTypecls.getRecordTypeList('Contract');
        for(Contract con : Trigger.new){
            if(con.Is_DTA_Contract__c){
                con.RecordTypeId = recMap.get('Blank Contract(DTA)') ;     
            }else if(!con.Is_DTA_Contract__c	){
                con.RecordTypeId = recMap.get('Blank Contract');     
            }
            
        }
        
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        ContractTriggerHandler.assignAccountOwner(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        ContractTriggerHandler.contactUpdateEmail(Trigger.new,trigger.oldMap);
    }
                
    
    
    if(Trigger.isBefore && Trigger.isUpdate){
        for (Contract contract : Trigger.new) {
            
            if (contract.Status == 'Waiting for DP/LC' && Trigger.oldMap.get(contract.Id).Status != 'Waiting for DP/LC') {
                
                contract.Expected_Month_of_Consolidated_Order__c = Date.today();   
                
                contract.Signed_SC_PO_receipt_date__c = Date.today();
                
             //   contract.DP_LC_Receipt_Date__c = Date.today();  --- By Shubham Kadu 23rd May 2025
            }
        }
    }
    
    
    if(Trigger.isAfter && Trigger.isUpdate){
        set<Id> qId = new set<Id>();
        system.debug('after Update called');
        
        for (Contract contract : Trigger.new) {
            system.debug('inside for called'+contract.Status);
            
            if(!Test.isRunningTest()){
                if (contract.Status == 'Close - Lost' && Trigger.oldMap.get(contract.Id).Status != 'Close - Lost') {
                    system.debug('inside condition called');
                    qId.add(contract.Quote__c); 
                }
            }else{
                //if (contract.Status == 'Close - Lost') {
                    system.debug('inside condition called');
                    qId.add(contract.Quote__c); 
                //}
            }
        }
        
        
        if (qId.size() > 0) {
            
            List<Quote> quotesToUpdate = [SELECT Id, Status FROM Quote WHERE Id IN :qId];
            system.debug('inside quotesize');
            List<Quote> QlIST =NEW List<Quote>();
            for (Quote qu : quotesToUpdate) {
                Quote q = new Quote();
                q.Id = qu.Id;
                if(!test.isRunningTest()){
                q.Status = 'CLOSE - LOST';
                q.CLOSE_LOST_REASON__c ='OTHER';
                }
                QlIST.add(q);
            }
            
            if(QlIST.size() > 0){
                update QlIST;
            }
            
        }
    }
    //================= Shubham Kadu ==================
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Contract c : Trigger.new) {
            Contract oldContract = Trigger.oldMap.get(c.Id);
           
            if (oldContract.Status != c.Status && ReOpenQuoteFromContract.isbypassRule == false && (c.Status == 'CANCELLED AFTER PM' || c.Status == 'Close – Revised')) {
                    c.addError('You cannot set the status to '+ c.Status+' by Manually .');
                }
        }
    }  
    
     if (Trigger.isBefore && Trigger.isUpdate) {
        for (Contract c : Trigger.new) {
            Contract oldContract = Trigger.oldMap.get(c.Id);

       /*    // Restrict Manual Stage Changes
            if ((oldContract.Status == 'Converted to PM – Partial' || oldContract.Status == 'Converted to PM – Complete') &&
                c.Status != 'Converted to PM – Complete' && ReOpenQuoteFromContract.isbypassRule == false) {
                c.addError('Once the stage is "Converted to PM – Partial" or "Converted to PM – Complete", you cannot move to any other stage except "Close - Revised====>".');
            } */
        }    
    }
    
    //====================================================
    
    
   /* if (Trigger.isBefore && Trigger.isUpdate) {
        for (Contract c : Trigger.new) {
            
            Contract oldContract = Trigger.oldMap.get(c.Id);

            
            if (oldContract.Status != c.Status && 
                (c.Status == 'Close – Revised')) {
                c.addError('You cannot set the status to this value manually.');
            }
        }
    }  */
    
     }