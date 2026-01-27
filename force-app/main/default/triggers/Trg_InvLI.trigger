trigger Trg_InvLI on Performa_Invoice_Line_Item__c (after update, after insert, before delete) {
    
    if(trigger.Isafter && trigger.isInsert){
        system.debug('this trigger update fields of paymentTransaction when InvLI is created');
        Set<id> ContLIid = new Set<id>();
        Set<id> Perfid = new Set<id>();
        Set<id> PerfLIid = new Set<id>();
        for (Performa_Invoice_Line_Item__c invLI : Trigger.new) {
            system.debug(invLI);
            PerfLIid.add(invLI.id);
            ContLIid.add(invLI.Contract_Line_Item__c);
            Perfid.add(invLI.Performa_Invoice__c);
        }
        system.debug('PerfLIid ---->>>> ' + PerfLIid);
        system.debug('ContLIid -->> ' + ContLIid);
        system.debug('Perfid -->> ' + Perfid);
        List<Performa_Invoice__c> LstPerf = new List<Performa_Invoice__c>();
        List<Performa_Invoice_Line_Item__c> LstPerfLI = new List<Performa_Invoice_Line_Item__c>();
        LstPerfLI = [Select id, name, Contract_Line_Item__c from Performa_Invoice_Line_Item__c where Id In: PerfLIid];
        LstPerf = [select id, name, Contract__c from Performa_Invoice__c where Id IN: Perfid];
        system.debug('LstPerf -->> ' + LstPerf);
        List<Payment_Transaction__c> LstPayTrans = new List<Payment_Transaction__c>();
        List<Payment_Transaction__c> LstPayTransToUpdate = new List<Payment_Transaction__c>();
        List<Payment_Transaction__c> LstPayTransToUpdate1 = new List<Payment_Transaction__c>();
        LstPayTrans = [select id, name, Contract__c, Performa_Invoice_Line_Item__c, Performa_Created__c, Performa_Invoice__c, Contract_Line_Item__c from Payment_Transaction__c where Contract_Line_Item__c IN: ContLIid];
        system.debug('LstPayTrans -->> ' + LstPayTrans);
        for(Performa_Invoice__c per : LstPerf){
            for(Payment_Transaction__c pt : LstPayTrans){
                if(per.Contract__c == pt.Contract__c){
                    system.debug('pt -->>> ' + pt);
                    //pt.Performa_Created__c = true;
                    pt.Performa_Invoice__c = per.Id;
                    LstPayTransToUpdate.add(pt);
                }
            }
        }
        for(Performa_Invoice_Line_Item__c per : LstPerfLI){
            for(Payment_Transaction__c pt : LstPayTrans){
                if(per.Contract_Line_Item__c == pt.Contract_Line_Item__c){
                    system.debug('pt -->>> ' + pt);
                    //pt.Performa_Created__c = true;
                    pt.Performa_Invoice_Line_Item__c = per.Id;
                    LstPayTransToUpdate1.add(pt);
                }
            }
        }
        system.debug('LstPayTransToUpdate -->> ' + LstPayTransToUpdate);
        system.debug('LstPayTransToUpdate1 -->> ' + LstPayTransToUpdate1);
        try{
            update LstPayTransToUpdate; 
            update LstPayTransToUpdate1;
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
    }
    
    
    if(trigger.IsBefore && trigger.isDelete){
        system.debug('this trigger update fields of ContrLI and Payment Transaction when InvLI is deleted');
        Set<id> invLIid = new Set<id>();
        Id invId;
        for (Performa_Invoice_Line_Item__c invLI : Trigger.old) {
            system.debug(invLI);
            invLIid.add(invLI.id);
            invId = invLI.Performa_Invoice__c;
        }
        system.debug('invLIid -->> ' + invLIid);
        system.debug('invId -->> ' + invId);
        List<Performa_Invoice_Line_Item__c> LstInvLI = new List<Performa_Invoice_Line_Item__c>();
        List<Contract_Line_Item__c> LstConLI = new List<Contract_Line_Item__c>();
        List<Contract_Line_Item__c> LstConLIdel = new List<Contract_Line_Item__c>();
        //List<Payment_Transaction__c> LstPayTrans = new List<Payment_Transaction__c>();
        Set<id> conLI = new Set<id>();
        List<Performa_Invoice__c> LstInv = new List<Performa_Invoice__c>();
        //LstPayTrans = [select id, name from Payment_Transaction__c where id IN: invLIid];
        LstInvLI = [select id, Performa_Invoice__c, Contract_Line_Item__c from Performa_Invoice_Line_Item__c where id IN: invLIid];
        system.debug('LstInvLI -->> ' + LstInvLI);
        for(Performa_Invoice_Line_Item__c objLI : LstInvLI){
            system.debug('objLI -->> ' + objLI);
            conLI.add(objLI.Contract_Line_Item__c);
        }
        system.debug('conLI -->> ' + conLI);
        LstConLI = [select id, Performa_Created__c from Contract_Line_Item__c where id IN:conLI];
        for(Contract_Line_Item__c objLI : LstConLI){
            system.debug('objLI -->> ' + objLI);
            objLI.Performa_Created__c = False;
            LstConLIdel.add(objLI);
        }
        system.debug('LstConLIdel -->>> ' + LstConLIdel);
        try{
            update LstConLIdel;  
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
    }
}