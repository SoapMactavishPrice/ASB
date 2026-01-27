trigger Trg_Performa on Performa_Invoice__c (before delete) {
    
    //==========================================================================================================================================================
    //==========================================================================================================================================================
    //                                                      Added by Vishesh
    //==========================================================================================================================================================
    //							This trigger will make the contLI field uncheck when performa is deleted
    //==========================================================================================================================================================
    
    
    if(trigger.isBefore && trigger.isDelete){
        system.debug('This trigger will make the contLI field uncheck when performa is deleted');
        List<Performa_Invoice__c> listper = new List<Performa_Invoice__c>();
        List<Performa_Invoice_Line_Item__c> listperInv = new List<Performa_Invoice_Line_Item__c>();
        List<Contract_Line_Item__c> contLI = new List<Contract_Line_Item__c>();
        List<Contract_Line_Item__c> contLItoUpdate = new List<Contract_Line_Item__c>();
        Set<Id> perID = new Set<Id>();
        Set<Id> IdcontLI = new Set<Id>();
        for (Performa_Invoice__c per: trigger.old) {
            system.debug('per===>>>' + per);
            //listper.add(per);
            perID.add(per.id);
        }
        system.debug('perID==>>' + perID);
        listperInv = [select id, Name, Contract_Line_Item__c, Performa_Invoice__c from Performa_Invoice_Line_Item__c where Performa_Invoice__r.id IN: perID];
        for(Performa_Invoice_Line_Item__c pli : listperInv){
            system.debug('pli -->>> ' + pli);
            IdcontLI.add(pli.Contract_Line_Item__c);
        }
        system.debug('IdcontLI -->>> ' + IdcontLI);
        contLI = [Select id, Performa_Created__c from Contract_Line_Item__c where id IN: IdcontLI];
        for(Contract_Line_Item__c objContLI : contLI){
            objContLI.Performa_Created__c = False;
            contLItoUpdate.add(objContLI);
        }
        try{
            update contLItoUpdate;
        }
        catch(Exception e){
            System.debug('e'+e);
        }
    }
}