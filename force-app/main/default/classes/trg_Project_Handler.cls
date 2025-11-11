public class trg_Project_Handler {
    
    public void ProjDelete(Set<id> Project){
        System.debug('Project'+Project);
        ProjectManagement__c ObjPro = new ProjectManagement__c();
        ObjPro =[select id,contract_Line_Item__C from ProjectManagement__c where id = : Project];
        System.debug('ObjPro'+ObjPro);
        String LineId = ObjPro.contract_Line_Item__C;
        
        Contract_Line_Item__c ObjCli = new contract_Line_Item__C();
        ObjCli = [Select id,Project_Created__c from Contract_Line_Item__c where id = :LineId];
        
        ObjCli.Project_Created__c = false;
        update ObjCli;
    }

}