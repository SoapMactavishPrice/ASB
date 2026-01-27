trigger Trg_project on ProjectManagement__c (before delete, before update, after update,before Insert,after insert) {
    system.debug('in trg proj');
    
    if(Trigger.IsBefore && Trigger.isUpdate){ 
        for(ProjectManagement__c prj : Trigger.new){
            if(Trigger.OldMap.get(prj.Id).Phase__c != prj.Phase__c){
                prj.Old_Phase__c = Trigger.OldMap.get(prj.Id).Phase__c;
            }
        }
    }
    
    
    //Validation
    if(Trigger.IsBefore && Trigger.isUpdate){ 
        for(ProjectManagement__c prj : Trigger.new){
            if(Trigger.OldMap.get(prj.Id).Phase__c != prj.Phase__c && !ReOpenQuoteFromContract.isPassValidationRule && (prj.Phase__c=='Amendment' || prj.Phase__c== 'Cancelled')){
               prj.addError('You Cannot Select the "Amendment" and "Cancelled" Phase Manually.');
            }
        }
    }
    
    // PM owner is came form Contract Owner 
    if (Trigger.isBefore && Trigger.isInsert) {
        Set<Id> contractIds = new Set<Id>();
        
        for (ProjectManagement__c pm : Trigger.new) {
            if (pm.Contract__c != null) {
                contractIds.add(pm.Contract__c);
            }
        }
        
        Map<Id, Contract> contractMap = new Map<Id, Contract>(
            [SELECT Id, OwnerId FROM Contract WHERE Id IN :contractIds]
        );
        
        for (ProjectManagement__c pm : Trigger.new) {
            if (pm.Contract__c != null && contractMap.containsKey(pm.Contract__c)) {
                pm.OwnerId = contractMap.get(pm.Contract__c).OwnerId;
            }
        }
    }



    // ===================================================================================================
    /*
    // Added By Shubham Kadu : 27th March 2025 
    // To Set the Phase Close Automatically.
    if(Trigger.isBefore && Trigger.isUpdate){
        for (ProjectManagement__c prj : Trigger.new) {
          /*  if (prj.Phase__c != 'Close'  && String.isNotBlank(prj.Currency_2__c)  
                                         && prj.Sales_Value__c != null  
                                         && prj.Actual_Sales_Recoded_Date__c != null) 
            {  
                prj.Phase__c = 'Close';
                prj.Is_System_Update__c = true;
            }    
            ProjectManagement__c oldPrj = Trigger.oldMap.get(prj.Id);
            if (oldPrj.Phase__c == 'Close' && prj.Phase__c != 'Close') {
                prj.addError('Phase cannot be changed once it is set to Close. XXXXXXXXXXXXXXXX');
            }
        }
    }
   /*
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (ProjectManagement__c prj : Trigger.new) {
            // Check if Phase is NOT 'Close'
            if (prj.Phase__c != 'Close') {
                List<String> missingFields = new List<String>();
                
                // Check for missing fields and add field names to the list
                if (String.isBlank(prj.Currency_2__c)) {
                    missingFields.add('Currency');
                }
                if (prj.Sales_Value__c == null) {
                    missingFields.add('Sales Value');
                }
                if (prj.Actual_Sales_Recoded_Date__c == null) {
                    missingFields.add('Actual Sales Recorded Date');
                }
                
                // If any field is missing, prevent update and show error
                if (!missingFields.isEmpty()) {
                    prj.addError('Please fill the following fields: ' + String.join(missingFields, ', '));
                } else {
                    // If all fields are filled, proceed with the update
                    prj.Phase__c = 'Close';
                    prj.Is_System_Update__c = true;
                }
            }
        }
    } */
   //===============================================================================
   
    
    // add by rishikesh 5 pril 2024
    if(Trigger.isBefore && Trigger.isInsert){
        set<Id> subId = new set<Id>();
        for(ProjectManagement__c prj : Trigger.new){
            if(string.isNotBlank(prj.Subsidiary__c)){
                subId.add(prj.Subsidiary__c);  
            }
        }
        if(subId.size()> 0){
            Map<Id,Subsidiari_Master__c> subMap = new Map<Id,Subsidiari_Master__c>([Select Id,AI_Sales_Liaison__c,AI_Sales_Liaison_email_id__c,
                                                                                    HQ_Sales_Liaison__c	, HQ_Sales_Liaison_email_id__c	
                                                                                    from Subsidiari_Master__c  where Id IN : subId]);
            
            for(ProjectManagement__c prj : Trigger.new){
                if(subMap.containsKey(prj.Subsidiary__c)){
                    prj.AI_Sales_Liaison__c = subMap.get(prj.Subsidiary__c).AI_Sales_Liaison__c;
                    prj.AI_Sales_Liaison_email_id__c = subMap.get(prj.Subsidiary__c).AI_Sales_Liaison_email_id__c;
                    prj.HQ_Sales_Liaison__c = subMap.get(prj.Subsidiary__c).HQ_Sales_Liaison__c;
                    prj.HQ_Sales_Liaison_email_id__c = subMap.get(prj.Subsidiary__c).HQ_Sales_Liaison_email_id__c;
                }
                
            }
        }
    }
    
    
    /*if(Trigger.isAfter && Trigger.IsInsert){
set<Id> conId = new set<Id>();
map<Id,Id> conIdmap =new map<Id,Id>();
for(ProjectManagement__c  pm : Trigger.new){
if(pm.Contract__c!=null){
conId.add(pm.Contract__c);
conIdmap.put(pm.Contract__c,pm.Id);
} 
}

if(conId.size() > 0){

List<Contract> conListToUpdate = new List<Contract>();
List<Contract> conList  =[select Id,Count_of_PM__c from contract where Id IN : conId];
for(Contract con: conList){
if(conIdmap.containsKey(con.Id)){
system.debug(con.Count_of_PM__c+1);
con.Count_of_PM__c = con.Count_of_PM__c +1;
conListToUpdate.add(con);
}


}

if(conListToUpdate.size() > 0){
update conListToUpdate;
}
}
}
*/
    /*if(trigger.isBefore && trigger.isDelete){
system.debug('in delete');
for(ProjectManagement__c ProVar:trigger.old)
{
OptionsId.add(ProVar.id);
}

System.debug('OptionsId'+OptionsId);
trg_Project_Handler TriggerHandler =new trg_Project_Handler(); 
TriggerHandler.ProjDelete(OptionsId);

}*/
    system.debug('RecursiveTriggerHandler2.isFirstTime ===>>> ' + RecursiveTriggerHandler2.isFirstTime);
    
     set<id> OptionsId =new set<id>();
    
    if(trigger.isafter && trigger.isUpdate){
        if(RecursiveTriggerHandler2.isFirstTime){
            RecursiveTriggerHandler2.isFirstTime = false;
            system.debug('in before update');
            for(ProjectManagement__c ProVar:trigger.new){
                OptionsId.add(ProVar.id);
            }
            System.debug('OptionsId'+OptionsId);
            
            List<ProjectManagement__c> lstPro = new List<ProjectManagement__c>();
            List<ProjectManagement__c> lstProUpdate = new List<ProjectManagement__c>();
            
            lstPro = [select id,Phase__c,ACTUAL_ASSEMBLY_DATE__c,ACTUAL_MOLDING_DATE__c,ACTUAL_HANDOVER_DATE__c,ACTUAL_DISPATCH_DATE__c,Hold__c
                      from ProjectManagement__c where id IN:OptionsId];
            system.debug('lstPro -->> ' + lstPro);
            for(ProjectManagement__c pr : lstPro){
                /*if(pr.Hold__c){
pr.Phase__c = 'Hold';
}*/
                //comment by rishikesh to cancel or temprory cancel project
                //else{
                //pr.Phase__c = 'Cancelled';
                //}
                //system.debug('Trigger.oldMap.get(pr.ACTUAL_ASSEMBLY_DATE__c) -->>> ' + Trigger.oldMap.get(pr.Id).ACTUAL_ASSEMBLY_DATE__c);
                if(Trigger.oldMap.get(pr.Id).ACTUAL_ASSEMBLY_DATE__c == Null && pr.ACTUAL_ASSEMBLY_DATE__c != Null){
                    pr.Phase__c = 'Under Moulding';
                }
                if(Trigger.oldMap.get(pr.Id).ACTUAL_ASSEMBLY_DATE__c != Null && pr.ACTUAL_ASSEMBLY_DATE__c == Null){
                    pr.Phase__c = 'Under Manufacturing';
                }
                if(Trigger.oldMap.get(pr.Id).ACTUAL_MOLDING_DATE__c == Null && pr.ACTUAL_MOLDING_DATE__c != Null){
                    pr.Phase__c = 'Under T1 Approval';
                }
                if(Trigger.oldMap.get(pr.Id).ACTUAL_MOLDING_DATE__c != Null && pr.ACTUAL_MOLDING_DATE__c == Null){
                    pr.Phase__c = 'Under Moulding';
                }
                if(Trigger.oldMap.get(pr.Id).ACTUAL_HANDOVER_DATE__c == Null && pr.ACTUAL_HANDOVER_DATE__c != Null){
                    pr.Phase__c = 'Waiting For Shipment Clearance';
                }
                if(Trigger.oldMap.get(pr.Id).ACTUAL_HANDOVER_DATE__c != Null && pr.ACTUAL_HANDOVER_DATE__c == Null){
                    pr.Phase__c = 'Under T1 Approval';
                }
                if(Trigger.oldMap.get(pr.Id).ACTUAL_DISPATCH_DATE__c == Null && pr.ACTUAL_DISPATCH_DATE__c != Null){
                    pr.Phase__c = 'Dispatch';
                }
                if(Trigger.oldMap.get(pr.Id).ACTUAL_DISPATCH_DATE__c != Null && pr.ACTUAL_DISPATCH_DATE__c == Null){
                    pr.Phase__c = 'Waiting For Shipment Clearance';
                }
                
                lstProUpdate.add(pr);
            }
            system.debug('lstProUpdate ===>>> ' + lstProUpdate);
            update lstProUpdate;
        }
    }
    
    
    if(Trigger.isAfter){
        if(trigger.isInsert){
            
            map<Id,Id> projMap = new  map<Id,Id>();
            for(ProjectManagement__c prj : Trigger.new){
                if(prj.Phase__c != 'Cancelled'){
                    projMap.put(prj.Quote_Name__c,prj.Quote_Name__c);
                }
            }
            
            Set<Id> projIds = new Set<Id>(projMap.values()); // Extract the values from projMap as a Set of IDs
            
            // Query the relevant Quote records based on the projIds\
            if(projIds.size() > 0){
            List<Quote> quotes = [SELECT Id, Project_Management_Quote_Id__c FROM Quote WHERE Id IN :projIds];
            
            for (Quote qte : quotes) {
                Set<String> existingQuoteIds = new Set<String>();
                if (qte.Project_Management_Quote_Id__c != null) {
                    existingQuoteIds.addAll(qte.Project_Management_Quote_Id__c.split(','));
                }
                
                for (Id projId : projMap.values()) {
                    if (!existingQuoteIds.contains(projId)) {
                        if (qte.Project_Management_Quote_Id__c != null) {
                            qte.Project_Management_Quote_Id__c += ',' + projId;
                        } else {
                            qte.Project_Management_Quote_Id__c = String.valueOf(projId);
                        }
                    }
                }
                system.debug('qte-->'+qte);
                update qte;
            }
            }
        }
        
        if(trigger.isUpdate){
            /*if (RecursiveTriggerHandler.isProjManUpdateExecuted) {
            return;
            }
            RecursiveTriggerHandler.isProjManUpdateExecuted = true;
*/
            map<Id,Id> projMap = new  map<Id,Id>();
            for(ProjectManagement__c prj : Trigger.new){
                if(prj.Phase__c != 'Cancelled'){
                    projMap.put(prj.Quote_Name__c,prj.Quote_Name__c);
                }
            }
            if(projMap.size() > 0){
            Set<Id> projIds = new Set<Id>(projMap.values()); // Extract the values from projMap as a Set of IDs
            
            List<Quote> quotes = [SELECT Id, Project_Management_Quote_Id__c FROM Quote WHERE Id IN :projIds];
            
            for (Quote qte : quotes) {
                Set<String> existingQuoteIds = new Set<String>();
                if (qte.Project_Management_Quote_Id__c != null) {
                    existingQuoteIds.addAll(qte.Project_Management_Quote_Id__c.split(','));
                }
                
                for (Id projId : projMap.values()) {
                    if (!existingQuoteIds.contains(projId)) {
                        if (qte.Project_Management_Quote_Id__c != null) {
                            qte.Project_Management_Quote_Id__c += ',' + projId;
                        } else {
                            qte.Project_Management_Quote_Id__c = String.valueOf(projId);
                        }
                    }
                }
                system.debug('qte-->'+qte);
                update qte;
            }
            }
        }
        
    }
    
}