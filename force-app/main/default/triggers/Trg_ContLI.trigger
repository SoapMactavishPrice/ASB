/*
*  Author   : Amol wagh
*  Date     : 27-06-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      16-08-2022   Amol Wagh      added Exception handling for Create contract option

*********************************************/
trigger Trg_ContLI on Contract_Line_Item__c (before insert, after update, before update, after insert) {
    
    if(trigger.isAfter && trigger.isInsert){
        system.debug('This trigger will make null desc as empty string ');
        Set<id> CLIid = new Set<id>();
        for(Contract_Line_Item__c QLO : Trigger.new){
            CLIid.add(QLO.Id);
        }
        system.debug('CLIid ===>>>> ' + CLIid);
        List<Contract_Line_Item__c> listQLO = new List<Contract_Line_Item__c>();
        listQLO = [Select id, Discount__c, Discount_Allowed__c, Approval_Note__c from Contract_Line_Item__c where id IN: CLIid];
        if(CLIid.size() > 0){
            List<Contract_Line_Item__c> listQLO2 = new List<Contract_Line_Item__c>();
            for(Contract_Line_Item__c varQLO : listQLO){
                System.debug('varQLO ===>>>> ' + varQLO);
                if((varQLO.Discount__c <= varQLO.Discount_Allowed__c || varQLO.Discount__c == null) && (varQLO.Approval_Note__c == 'Null' || varQLO.Approval_Note__c == 'undefined')){
                    system.debug('in of');
                    varQLO.Approval_Note__c = '';
                    listQLO2.add(varQLO);
                }
            }
            if(listQLO2.size() > 0){
                update listQLO2;
            }
        }
        
    }
    
    
    /*if(trigger.IsAfter && trigger.isUpdate){
system.debug('this trigger update desc of CLO after CLI is cancelled');
List<Contract_Line_Option__c> NewLst = new List<Contract_Line_Option__c>();
List<Contract_Line_Item__c> NewLst1ToAdd  = new List<Contract_Line_Item__c>();
for (Contract_Line_Item__c newOpp : Trigger.new) {
system.debug(newOpp.Cancelled__c);
system.debug(trigger.oldMap.get(newOpp.id).Cancelled__c);
if (newOpp.Cancelled__c && (!trigger.oldMap.get(newOpp.id).Cancelled__c ) && newOpp.Cancellation_Reason__c != ''){ 
system.debug('in else');
List<Contract_Line_Option__c> lstClo = new List<Contract_Line_Option__c>();
lstClo = [select id,name,cancelled__c,Line_Item_Cancelled__c,Cancelled_Date__c, Cancellation_Reason__c from Contract_Line_Option__c where Contract_Line_Item__c =: newOpp.Id];
for(Contract_Line_Option__c clo : lstClo){
system.debug('clo ==>>> '+clo);
system.debug('newOpp.Cancellation_Reason__c ==>>> ' + newOpp.Cancellation_Reason__c);
clo.Cancellation_Reason__c = newOpp.Cancellation_Reason__c;
NewLst.add(clo);
}

}



}
system.debug('NewLst ==>> ' + NewLst);
if(NewLst.size() > 0){
update NewLst;
system.debug('NewLst ==>> ' + NewLst);
}

}*/
    
    
    if(trigger.IsAfter && trigger.isUpdate){
        system.debug('this trigger update desc of CLO after CLI is cancelled');
        List<Contract_Line_Option__c> NewLst = new List<Contract_Line_Option__c>();
        List<Contract_Line_Item__c> NewLst1ToAdd  = new List<Contract_Line_Item__c>();
        set<Id> conLineId = new set<Id>();
        
        for (Contract_Line_Item__c newOpp : Trigger.new) {
            system.debug(newOpp.Cancelled__c);
            system.debug(trigger.oldMap.get(newOpp.id).Cancelled__c);
            if (newOpp.Cancelled__c && (!trigger.oldMap.get(newOpp.id).Cancelled__c ) && newOpp.Cancellation_Reason__c != ''){ 
                system.debug('in else');
                List<Contract_Line_Option__c> lstClo = new List<Contract_Line_Option__c>();
                conLineId.add(newOpp.Id);
                
                for(Contract_Line_Option__c clo : lstClo){
                    system.debug('clo ==>>> '+clo);
                    system.debug('newOpp.Cancellation_Reason__c ==>>> ' + newOpp.Cancellation_Reason__c);
                    clo.Cancellation_Reason__c = newOpp.Cancellation_Reason__c;
                    NewLst.add(clo);
                }
                
            }
            
            
            
        }
        system.debug('NewLst ==>> ' + conLineId.size());
        
        if(conLineId.size() > 0){
            map<Id, Contract_Line_Option__c> conOptionMap = new map<Id, Contract_Line_Option__c>();
            for(Contract_Line_Option__c conOption :  [select id,name,cancelled__c,Contract_Line_Item__c,Line_Item_Cancelled__c,Cancelled_Date__c, Cancellation_Reason__c from Contract_Line_Option__c where Contract_Line_Item__c IN :  conLineId]){ 
                conOptionMap.put(conOption.Contract_Line_Item__c , conOption);
            }
            
            for (Contract_Line_Item__c newOpp : Trigger.new) {
                system.debug(newOpp.Cancelled__c);
                system.debug(trigger.oldMap.get(newOpp.id).Cancelled__c);
                if (newOpp.Cancelled__c && (!trigger.oldMap.get(newOpp.id).Cancelled__c ) && newOpp.Cancellation_Reason__c != ''){ 
                    if(conOptionMap.containsKey(newOpp.Id)){
                        Contract_Line_Option__c clo = conOptionMap.get(newOpp.Id);
                        system.debug('newOpp.Cancellation_Reason__c ==>>> ' + newOpp.Cancellation_Reason__c);
                        clo.Cancellation_Reason__c = newOpp.Cancellation_Reason__c;
                        NewLst.add(clo);
                    }
                    
                }
             }
        }
        
    
    if(NewLst.size() > 0){
        update NewLst;
        system.debug('NewLst ==>> ' + NewLst);
    }
    
}

if (Trigger.isBefore && Trigger.isUpdate) {
    
    Set<Id> cliIds = new Set<Id>();
    Set<Id> contractIds = new Set<Id>();
    
    for (Contract_Line_Item__c cli : Trigger.new) {
        cliIds.add(cli.Id);
        contractIds.add(cli.ContractId__c);
    }

    // Query count of Cancelled Projects grouped by Contract Line Item
    Map<Id, Integer> contractLineItemToCancelledCount = new Map<Id, Integer>();
    if (cliIds.size()> 0) {
        for (AggregateResult ar : [
            SELECT Contract_Line_Item__c, COUNT(Id) cLineCount
            FROM ProjectManagement__c
            WHERE Contract_Line_Item__c IN :cliIds AND Phase__c = 'Cancelled'
            GROUP BY Contract_Line_Item__c
        ]) {
            contractLineItemToCancelledCount.put(
                (Id) ar.get('Contract_Line_Item__c'),
                (Integer) ar.get('cLineCount')
            );
        }
    }

    // Prepare set of Contract IDs that need revision updates
    Set<Id> contractIdsToUpdate = new Set<Id>();

    for (Contract_Line_Item__c cli : Trigger.new) {
        Contract_Line_Item__c oldCli = Trigger.oldMap.get(cli.Id);

        Integer cancelledProjectCount = contractLineItemToCancelledCount.get(cli.Id);
        if (cancelledProjectCount != null && cli.Quantity__c < cancelledProjectCount) {
            cli.addError('Please cancel the project first before canceling the contract line item, as the quantity is less than the number of active projects.');
        }

        // Only add to update list if relevant fields changed
        if (cli.cancelled__c != oldCli.cancelled__c || cli.Quantity__c != oldCli.Quantity__c) {
            contractIdsToUpdate.add(cli.ContractId__c);
        }
    }

    // Update revision numbers for affected contracts
    if (!contractIdsToUpdate.isEmpty()) {
        Map<Id, Contract> contractsToUpdate = new Map<Id, Contract>(
            [SELECT Id, Revision_Number__c FROM Contract WHERE Id IN :contractIdsToUpdate]
        );

        for (Id contractId : contractIdsToUpdate) {
            Contract con = contractsToUpdate.get(contractId);
            Integer revision = 0;

            if (String.isNotBlank(con.Revision_Number__c)) {
                revision = Integer.valueOf(con.Revision_Number__c);
            }
            con.Revision_Number__c = String.valueOf(revision + 1);
        }

        update contractsToUpdate.values();
    }
}


/* if(trigger.isBefore && trigger.isInsert){
for(Contract_Line_Item__c con : Trigger.new){
if(con.Sr_No__c > 0){
con.Original_SQ_No__c	= con.Sr_No__c;
}
}

}*/


}