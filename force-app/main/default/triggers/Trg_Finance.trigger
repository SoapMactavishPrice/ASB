trigger Trg_Finance on Finance__c (Before Delete, After Insert) {
    
    if(trigger.isAfter && trigger.isInsert){
      system.debug('This trigger will fill the ContLI fields when Finance is created');
        Set<id> Fid = new Set<id>();
        Set<id> Contid = new Set<id>();
        List<Contract_Line_Item__c> LstcontLI = new List<Contract_Line_Item__c>();
        List<Finance__c> finList = new List<Finance__c>();
        List<Contract_Line_Item__c> LstcontLItoUpdate = new List<Contract_Line_Item__c>();
        for(Finance__c fi : Trigger.New){
            Contid.add(fi.Contract_Line_Item__c);
            Fid.add(fi.id);
        }  
        finList = [select id, name, Contract_Line_Item__c from Finance__c where id IN: Fid];
        system.debug('finList ====>>> ' + finList);
        LstcontLI = [select id, Finance_Created__c,Finance__c from Contract_Line_Item__c where id IN : Contid];
        system.debug('LstcontLI -->> ' + LstcontLI);
        for(Finance__c fi : finList){
            for(Contract_Line_Item__c objContLI : LstcontLI){
                if(fi.Contract_Line_Item__c == objContLI.Id){
                    system.debug('objContLI -->>> ' + objContLI);
                    objContLI.Finance__c = fi.Id;
                    LstcontLItoUpdate.add(objContLI);
                }
            }
        }
        try{
            update LstcontLItoUpdate;  
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
    }
    
	if(trigger.isBefore && trigger.isDelete){
        system.debug('This trigger will fill the ContLI fields when Finance is deleted');
        Set<id> Fid = new Set<id>();
        List<Contract_Line_Item__c> LstcontLI = new List<Contract_Line_Item__c>();
        List<Contract_Line_Item__c> LstcontLItoUpdate = new List<Contract_Line_Item__c>();
        for(Finance__c fi : Trigger.Old){
            Fid.add(fi.Contract_Line_Item__c);
        }
        system.debug('Fid -->> ' + Fid);
        LstcontLI = [select id, Finance_Created__c from Contract_Line_Item__c where id IN : Fid];
        system.debug('LstcontLI -->> ' + LstcontLI);
        for(Contract_Line_Item__c objContLI : LstcontLI){
            system.debug('objContLI -->>> ' + objContLI);
            objContLI.Finance_Created__c = False;
            LstcontLItoUpdate.add(objContLI);
        }
        try{
            update LstcontLItoUpdate;  
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
    }
}