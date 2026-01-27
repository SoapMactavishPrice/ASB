trigger Trg_IP on Installment_Payment__c (After Update) {
	if(trigger.isAfter && trigger.isUpdate){
        system.debug('This trigger will fill the date fields in IP when date is entered on first IP');
        Set<id> Fid = new Set<id>();
        List<Finance__c> LstFin = new List<Finance__c>();
        List<Installment_Payment__c> LstIP = new List<Installment_Payment__c>();
        List<Installment_Payment__c> LstIPtoUpdate = new List<Installment_Payment__c>();
        for(Installment_Payment__c fi : Trigger.new){
            if(Trigger.oldmap.get(fi.id).Start_Date__c == Null){
            Fid.add(fi.Finance__c);
            }
        }
        system.debug('Fid -->> ' + Fid);
        for(id f : Fid){
            integer i = 1;
            LstIP = [select id, Name , Start_Date__c, Due_Date__c, Finance__c from Installment_Payment__c where Finance__c =: f ORDER BY Name ASC];
            Date dt = LstIP[0].Start_Date__c;
            system.debug('dt -->> '+dt);
            system.debug('LstIP -->> '+LstIP);
            if(dt != null){
                for(Installment_Payment__c ipObj : LstIP){
                    system.debug('ipObj -->>> ' + ipObj);
                    if(ipObj.Start_Date__c == null){
                        system.debug('in if');
                        Date dt2 = dt.addMonths(i);
                        system.debug('dt2 ===>> ' +dt2);
                        ipObj.Start_Date__c = dt2;
                        //ipObj.Due_Date__c=dt2.addDays(7);
                        system.debug('in if debug -->>> '+ipObj);
                        LstIPtoUpdate.add(ipObj);
                        i++;
                    }
                    else{
                        system.debug('in else');
                        //ipObj.Due_Date__c=dt.addDays(7);
                        //LstIPtoUpdate.add(ipObj);
                    }
                }
            }
        }
        system.debug('LstIPtoUpdate ---->>> ' + LstIPtoUpdate);
        try{
            update LstIPtoUpdate;  
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
    }
}