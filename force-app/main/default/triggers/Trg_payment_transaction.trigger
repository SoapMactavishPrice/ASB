trigger Trg_payment_transaction on Payment_Transaction__c(After insert, before update, after delete, before delete, After Update) {
    
    if((trigger.IsAfter && trigger.isInsert) || (trigger.IsAfter && trigger.isUpdate)){
        system.debug('this trigger update ContLI  after PT is made');
        Set<id> PTid = new Set<id>();
        List<Payment_Transaction__c> NewLst = new List<Payment_Transaction__c>();
        for (Payment_Transaction__c newPT : Trigger.new) {
            system.debug('newPT-->>> '+newPT);
            PTid.add(newPT.id);
        }
        system.debug('PTid-->>> '+PTid);
        NewLst = [Select id, Contract_Line_Item__c, Amount_Allocated__c from Payment_Transaction__c where id IN: PTid];
        system.debug('NewLst-->>> '+NewLst);
        List<id> lstCLI = new List<id>();
        List<Contract_Line_Item__c> lstCLI2 = new List<Contract_Line_Item__c>();
        List<id> unCheckCLI = new List<id>();
        List<Contract_Line_Item__c> unCheckCLI2 = new List<Contract_Line_Item__c>();
        List<Contract_Line_Item__c> unCheckCLI3 = new List<Contract_Line_Item__c>();
        List<Contract_Line_Item__c> lstCLI3 = new List<Contract_Line_Item__c>();
        if(NewLst.size() > 0){
            system.debug('in if cond');
            for(Payment_Transaction__c pt : NewLst){
                if(pt.Amount_Allocated__c > 0){
                    lstCLI.add(pt.Contract_Line_Item__c);
                }
                else{
                    unCheckCLI.add(pt.Contract_Line_Item__c);
                }
            }
            unCheckCLI2 = [select id, name, Payment_Created__c from Contract_Line_Item__c where id IN: unCheckCLI];
            system.debug('lstCLI2 --->>> ' + unCheckCLI2);
            for(Contract_Line_Item__c cli : unCheckCLI2){
                cli.Payment_Created__c = False;
                unCheckCLI3.add(cli);
            }
            
            lstCLI2 = [select id, name, Payment_Created__c from Contract_Line_Item__c where id IN: lstCLI];
            system.debug('lstCLI2 --->>> ' + lstCLI2);
            for(Contract_Line_Item__c cli : lstCLI2){
                cli.Payment_Created__c = True;
                lstCLI3.add(cli);
            }
        }
       update lstCLI3;
       update unCheckCLI3;
    }
    
    if(trigger.IsBefore && trigger.isDelete){
        system.debug('this trigger update ContLI  after PT is deleted');
        Set<id> PTid = new Set<id>();
        List<Payment_Transaction__c> NewLst = new List<Payment_Transaction__c>();
        for (Payment_Transaction__c newPT : trigger.old){
            system.debug('newPT-->>> '+newPT);
            PTid.add(newPT.id);
        }
        NewLst = [Select id, Contract_Line_Item__c, Amount_Allocated__c from Payment_Transaction__c where id IN: PTid];
        system.debug('NewLst-->>> '+NewLst);
        List<id> lstCLI = new List<id>();
        List<Contract_Line_Item__c> lstCLI2 = new List<Contract_Line_Item__c>();
        List<id> unCheckCLI = new List<id>();
        List<Contract_Line_Item__c> unCheckCLI2 = new List<Contract_Line_Item__c>();
        List<Contract_Line_Item__c> unCheckCLI3 = new List<Contract_Line_Item__c>();
        List<Contract_Line_Item__c> lstCLI3 = new List<Contract_Line_Item__c>();
        if(NewLst.size() > 0){
            system.debug('in if cond');
            for(Payment_Transaction__c pt : NewLst){
                lstCLI.add(pt.Contract_Line_Item__c);
            }
            
            lstCLI2 = [select id, name, Payment_Created__c,(Select id,Contract_Line_Item__c, Amount_Allocated__c from Payment_Transactions__r )
                       from Contract_Line_Item__c where id IN: lstCLI];
            system.debug('lstCLI2 --->>> ' + lstCLI2);
            for(Contract_Line_Item__c cli : lstCLI2){
                system.debug('cli.Payment_Transactions__r.size ==>>> ' + cli.Payment_Transactions__r.size());
                if(cli.Payment_Transactions__r.size() == 1){
                    cli.Payment_Created__c = False;
                    lstCLI3.add(cli);
                }
                
            }
        }
          
        update lstCLI3;
    }
}