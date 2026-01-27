public with sharing class Lwc_report_ProjectManagementController {
    
    @AuraEnabled 
    public static string getProjectManagementDail(string pId){
        ProjectManagement__c pmo =  [SELECT Id, Contract__c FROM ProjectManagement__c WHERE Id =:pId];
        set<Id> pIdlist = new set<Id>();
        pIdlist.add(pmo.Id);
        List<wrapper> wrapList = new List<wrapper>();
        if(pIdlist.size() > 0){
            List<ProjectManagement__c> pmoList = [SELECT Id, Contract_No_Rev_No_NEW__c,CurrencyIsoCode,Project_No_Link__c,Name, Phase__c , Contract__c,Sq_No__c,Product_Type__c,PRODUCT__c,Total_Sales_Price__c,MATERIAL_CODE__c
                                                  FROM ProjectManagement__c WHERE  Contract__c =:pmo.Contract__c order by Sq_No__c asc];//Id NOT IN :pIdlist and
            
            for(ProjectManagement__c pm : pmoList){
                wrapper wrp = new wrapper();
                wrp.Id = pm.Id;
                wrp.Name = pm.Project_No_Link__c.subStringBetween('>','</a>');
                wrp.pNo = '/lightning/r/' +pm.Id+'/view';
                wrp.contractId = '/lightning/r/' +pm.Contract__c+'/view';
                wrp.pNo = '/lightning/r/' +pm.Id+'/view';
                wrp.Contract_No_Rev_No_NEW = pm.Contract_No_Rev_No_NEW__c.subStringBetween('>','</a>');
                wrp.Phase = pm.Phase__c;
                wrp.Product_Type = pm.Product_Type__c;
                wrp.currencycode = pm.CurrencyIsoCode;
                wrp.Product = pm.PRODUCT__c;
                wrp.Total_Sales_Price = pm.Total_Sales_Price__c;
                wrp.MATERIAL_CODE = string.ValueOf(pm.MATERIAL_CODE__c);
                wrapList.add(wrp);
            }
        }
        system.debug(wrapList.size());
        if(wrapList.size() > 0)
            return JSON.serialize(wrapList);
        else 
            return null;
        
    }
    
    public class wrapper{
        public string Id;
        public string Name;
        public string contractId;
         public string contractNo;
        public string pNo;
        public string Contract_No_Rev_No_NEW;
        public string Phase;
        public string currencycode;
        public string Product_Type;
        public string Product;
        public decimal Total_Sales_Price;
        public string MATERIAL_CODE;
    }
}