trigger Trg_ContractLineOption on Contract_Line_Option__c (before Update, after update, after insert) {
    
    
      
    if(trigger.IsAfter && trigger.isInsert){
        system.debug('this trigger');
        List<Contract_Line_Option__c> NewLst = new List<Contract_Line_Option__c>();
        List<Contract_Line_Option__c> NewLstToUpload = new List<Contract_Line_Option__c>();
        Set<id> sID = new Set<id>();
        for (Contract_Line_Option__c newOpp : Trigger.new) {
            //system.debug(newOpp.Cancelled__c);
            sID.add(newOpp.id);
        }
        if(sID.size() > 0){
            
        
        NewLst = [select Select_Option__c, Description__c,Product_Description__c, Option_Name__c,Discount_Description__c,
                  Added_On_Date__c from Contract_Line_Option__c where id IN: sID];
        }
        if(NewLst.size() > 0){
        
            for(Contract_Line_Option__c clo : NewLst){
            clo.Added_On_Date__c = system.today();
                if(clo.Discount_Description__c == 'Null'){
                    system.debug('is null');
                    clo.Discount_Description__c = '';
                }
                if(clo.Select_Option__c){
                    system.debug('in update desc to option name');
                    clo.Product_Description__c   = clo.Option_Name__c;
                    //NewLstToUpload.add(clo);
                }
                NewLstToUpload.add(clo);
            }
        }
        if(NewLstToUpload.size() > 0){
            update NewLstToUpload;
        }
    }
    
    
    
    
    /*  if(trigger.isbefore && trigger.isUpdate)
{
for(Contract_Line_Option__c objCLO: trigger.new)
{
if (objCLO.Cancelled__c!=null && (trigger.oldMap.get(objCLO.id).Cancelled__c != objCLO.Cancelled__c)){
if(objCLO.Cancelled__c = true){
objCLO.Manual_Option_Base_Price__c = 0;
objCLO.Discount__c = 0;
//  objCLO.Quantity__c = 0;
}

if(objCLO.Cancelled__c = true){
objCLO.Manual_Option_Base_Price__c = objCLO.Manual_Option_Base_Price_Clone__c;
objCLO.Discount__c = objCLO.Discount_Clone__c;
//   objCLO.Quantity__c = objCLO.;
}

}
}
}    */
    
    
    
    
    /*   if(trigger.isAfter  && trigger.isUpdate)
{    
for (Contract_Line_Option__c newClo : Trigger.new) {
if (newClo.Cancelled__c!=null && (trigger.oldMap.get(newClo.id).Cancelled__c != newClo.Cancelled__c)){
if(newClo.Cancelled__c == true && newClo.Line_Item_Cancelled__c == false){
System.debug('Reached True');
//  String RecordId = newClo.id;
String RecordId = newClo.ContractId__c;
TriggerContractLineOptionHandler TriggerHandler = new TriggerContractLineOptionHandler();
TriggerHandler.ReviseContract(RecordId);
}
if(newClo.Cancelled__c == false && newClo.Line_Item_Cancelled__c == truef){

System.debug('Reached True false' );
String RecordId = newClo.ContractId__c;
TriggerContractLineOptionHandler TriggerHandler = new TriggerContractLineOptionHandler();
TriggerHandler.ReviseContract(RecordId);
}
}  
}
}    */
    
    /*if(trigger.isBefore && trigger.isUpdate)
{
for(Contract_Line_Option__c objCLO: trigger.new)
{
if(objCLO.Cancelled__c==true)
{
objCLO.Discount__c=0;
objCLO.Manual_Option_Base_Price__c=0;
objCLO.Manual_Option_List_Price__c=0;
objCLO.Final_Price__c=0;
}
}
}*/
    
    
}