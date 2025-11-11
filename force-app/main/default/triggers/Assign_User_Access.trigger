trigger Assign_User_Access on Assign_Region__c (after insert,after Update ,After delete) {
    
    if(trigger.isAfter && trigger.IsInsert){
        
        
        map<Id,Assign_Region__c> mpAssign = new map<Id,Assign_Region__c>();
        for(Assign_Region__c asr : Trigger.new){
            if(string.isNotBlank(asr.Region__c)){
                mpAssign.put(asr.Region__c,asr);   
            }
        }
        
        map<string,List<Lead>> LeadLevel = new map<string,List<Lead>>();
        set<Id> leadId = new set<Id>();
        for(Lead acc: [select Id,Region1__c,OwnerId  from Lead where Region1__c IN: mpAssign.keyset()]){
            leadId.add(acc.Id);
            if(LeadLevel.containskey(acc.Region1__c)){
                LeadLevel.get(acc.Region1__c).add(acc);
            } else{
                LeadLevel.put(acc.Region1__c,new List<Lead>{acc});
            }
        }
        
        map<string,List<Account>> AccountLevel = new map<string,List<Account>>();
        set<Id> accId = new set<Id>();
        for(Account acc: [select Id,Region1__c ,OwnerId from Account where Region1__c IN: mpAssign.keyset()]){
            accId.add(acc.Id);
            if(AccountLevel.containskey(acc.Region1__c)){
                AccountLevel.get(acc.Region1__c).add(acc);
            } else{
                AccountLevel.put(acc.Region1__c,new List<Account>{acc});
            }
        }
        
        map<string,List<Quote>> QuoteLevel = new map<string,List<Quote>>();
        for(Quote acc: [select Id,Region1__c,OwnerId  from Quote where Region1__c IN: mpAssign.keyset() and AccountId IN: accId]){
            if(QuoteLevel.containskey(acc.Region1__c)){
                QuoteLevel.get(acc.Region1__c).add(acc);
            } else{
                QuoteLevel.put(acc.Region1__c,new List<Quote>{acc});
            }
        }
        
        map<string,set<Id>> ContractLevel = new map<string,set<Id>>();
        set<Id> contrctaId = new set<Id>();
        for(Contract acc: [select Id,Region1__c  from Contract where Region1__c IN: mpAssign.keyset() and AccountId IN: accId]){
            contrctaId.add(acc.Id);
            if(ContractLevel.containskey(acc.Region1__c)){
                ContractLevel.get(acc.Region1__c).add(acc.Id);
            } else{
                ContractLevel.put(acc.Region1__c,new set<Id>{acc.Id});
            }
        }
        
        
        system.debug('AccountLevel'+AccountLevel);
        List<LeadShare> leadShareList = new List<LeadShare>();
        List<AccountShare> assShareList = new List<AccountShare>();
        List<QuoteShare> QuoteShareList = new List<QuoteShare>();
        //List<ContractShare> ContractShareList = new List<ContractShare>();
        
        for(Assign_Region__c asr : Trigger.new){
            
            if(LeadLevel.containskey(asr.Region__c)){
                for (Lead idKey : LeadLevel.get(asr.Region__c)) {
                    if(mpAssign.get(asr.Region__c).User_Name__c != idKey.OwnerId){
                        LeadShare lsh = new LeadShare();
                        lsh.LeadId = idKey.Id;
                        lsh.LeadAccessLevel = 'Create';
                        lsh.UserOrGroupId = (Id)mpAssign.get(asr.Region__c).User_Name__c;
                        lsh.RowCause = 'Manual'; // reason
                        leadShareList.add(lsh);
                    }
                }
            }
            
            if(AccountLevel.containskey(asr.Region__c)){
                for (Account idKey : AccountLevel.get(asr.Region__c)) {
                    if(mpAssign.get(asr.Region__c).User_Name__c != idKey.OwnerId){
                        AccountShare ash = new AccountShare();
                        ash.AccountId = idKey.Id;
                        ash.AccountAccessLevel = 'Edit';
                        system.debug('idKey'+idKey);
                        system.debug('user Name'+(Id)mpAssign.get(asr.Region__c).User_Name__c);
                        ash.UserOrGroupId = (Id)mpAssign.get(asr.Region__c).User_Name__c;
                        ash.OpportunityAccessLevel = 'Edit';
                        //ash.ContactAccessLevel = 'Edit';
                        ash.RowCause = 'Manual'; // reason
                        
                        
                        assShareList.add(ash);
                    }
                }
            }
            
            
            if(QuoteLevel.containskey(asr.Region__c)){
                for (Quote idKey : QuoteLevel.get(asr.Region__c)) {
                    if(mpAssign.get(asr.Region__c).User_Name__c != idKey.OwnerId){
                        QuoteShare ash = new QuoteShare();
                        ash.ParentId = idKey.Id;
                        ash.AccessLevel = 'Create';
                        ash.UserOrGroupId = (Id)mpAssign.get(asr.Region__c).User_Name__c;
                        ash.RowCause = 'Manual'; // reason
                        
                        QuoteShareList.add(ash);
                    }
                }
            }
            
            /* if(QuoteLevel.containskey(asr.Region__c)){
for (ID idKey : QuoteLevel.get(asr.Region__c)) {
QuoteShare ash = new QuoteShare();
ash.ParentId = idKey;
ash.AccessLevel = 'Create';
ash.UserOrGroupId = (Id)mpAssign.get(asr.Region__c).User_Name__c;
ash.RowCause = 'Manual'; // reason
QuoteShareList.add(ash);
}
}
*/        }
        
        
        if(assShareList.size() > 0)
            insert assShareList;
        
        if(assShareList.size() > 0)
            insert QuoteShareList;
        
        if(leadShareList.size() > 0){
            insert QuoteShareList;
        }
    }
    
    if(trigger.isAfter && trigger.IsDelete){
        map<Id,Assign_Region__c> mpAssign = new map<Id,Assign_Region__c>();
        map<Id,Id> parentId = new  map<Id,Id>();
        for(Assign_Region__c asr : trigger.old){
            if(string.isNotBlank(asr.Region__c)){
                mpAssign.put(asr.Region__c,asr);
                parentId.put(asr.User_Name__c,asr.Region__c);
            }
        }
        
        set<Id> leadId = new set<Id>();
        for(Lead acc: [select Id,Region1__c  from Lead where Region1__c IN: parentId.values() and OwnerId NOT IN :  parentId.keyset()]){
            leadId.add(acc.Id);
            
        }
        
        set<Id> AccountLevel = new set<Id>();
        for(Account acc: [select Id,Region1__c  from Account where Region1__c IN: parentId.values() and OwnerId NOT IN :  parentId.keyset()]){
            AccountLevel.add(acc.Id);
        }
        
        set<Id> quoteLevelId = new set<Id>();
        for(Quote acc: [select Id,Region1__c  from Quote where Region1__c IN: parentId.values() and AccountId =:AccountLevel and OwnerId NOT IN :  parentId.keyset()]){
            quoteLevelId.add(acc.Id);
        }
        
        List<LeadShare> deleteToLeadShare = new List<LeadShare>();
        List<AccountShare> deleteToAccountShare = new List<AccountShare>();
        List<QuoteShare> deleteToQuoteShare = new List<QuoteShare>();
        
        for( LeadShare accShare : [select id , LeadId, UserOrGroupId from LeadShare where  UserOrGroupId IN:parentId.keyset() and LeadId IN : leadId]){
            if(parentId.containskey(accShare.UserOrGroupId)){
                deleteToLeadShare.add(accShare);
            }
        }
        
        for( AccountShare accShare : [select id , AccountId, UserOrGroupId from AccountShare where  UserOrGroupId IN:parentId.keyset() and AccountId IN : AccountLevel]){
            if(parentId.containskey(accShare.UserOrGroupId)){
                system.debug(accShare.AccountId);
                deleteToAccountShare.add(accShare);
            }
            
        }
        
        for( QuoteShare accShare : [select id , ParentId, UserOrGroupId from QuoteShare where  UserOrGroupId IN:parentId.keyset() and ParentId IN : quoteLevelId]){
            if(parentId.containskey(accShare.UserOrGroupId)){
                deleteToQuoteShare.add(accShare);
            }
            
        }
        
        if(deleteToLeadShare.size() > 0){
            delete deleteToLeadShare;
            system.debug('Lead deleted Records'+deleteToLeadShare.size());
        }
        
        if(deleteToAccountShare.size() > 0){
            delete deleteToAccountShare;
            system.debug('deleted Records'+deleteToAccountShare.size());
        }
        
        if(deleteToQuoteShare.size() > 0){
            delete deleteToQuoteShare;
            system.debug('Quote deleted Records'+deleteToQuoteShare.size());
        }
        
    }
}