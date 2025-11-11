public class CreatePerformaInvoiceController {
    
    Public Static List<ProdListWrapper> lstProductListWrapper = new List<ProdListWrapper>();
    
    @AuraEnabled 
    public static List<ProdListWrapper> getProductList(String recordId){
        system.debug('recordId -->>' + recordId);
        List<Contract_Line_Item__c> prodList = new List<Contract_Line_Item__c>([SELECT Id,Last_Performa_Amount__c,Product_Name__c,Product_Name_2__c,Product2Id__c,Performa_Created__c, Name, Final_Grand_Total__c, Balance_Payment__c, Total_Amount_Received__c
                                                                                FROM Contract_Line_Item__c WHERE ContractId__c =: recordId AND Balance_Payment__c>0 AND Cancelled__c = False]); //Performa_Created__c = False 
        
        for(Contract_Line_Item__c lstprod : prodList){
            lstprod.Last_Performa_Amount__c=0;
            lstProductListWrapper.add(new ProdListWrapper(false, lstprod));
        }
        system.debug('lstProductListWrapper===>>'+lstProductListWrapper);
        system.debug('lstProductListWrapper===>>'+lstProductListWrapper.size());
        return lstProductListWrapper;
    }
    
    @AuraEnabled 
    public static void SelectedProd(List<Contract_Line_Item__c> selectedRecordList , String RecId){
        system.debug('selectedRecordList===>>'+selectedRecordList);
        system.debug('recordId===>>'+RecId);
        List<Contract> contlst = new List<Contract>([SELECT Id,CurrencyIsoCode,Subsidiary__c,FY1__c,Language__c,Freight_Amount1__c, SOLD_TO__c, SHIP_TO__c, Contact_Id__c FROM Contract WHERE id =: RecId]);
        List<Performa_Invoice_Template__c> PerformaIT = new List<Performa_Invoice_Template__c>([SELECT Id,Name,Active__c,Subsidiary__c,Language__c FROM Performa_Invoice_Template__c WHERE Subsidiary__c =: contlst[0].Subsidiary__c and Language__c =: contlst[0].Language__c AND Active__c = true limit 1]);
        Performa_Invoice__c  ObjInv = new Performa_Invoice__c();
        ObjInv.CurrencyIsoCode=contlst[0].CurrencyIsoCode;
        ObjInv.Contract__c = RecId;
        ObjInv.Account__c = contlst[0].SOLD_TO__c;
        ObjInv.Ship_To_Party__c = contlst[0].SHIP_TO__c;
        ObjInv.Contact__c = contlst[0].Contact_Id__c;
        ObjInv.Subsidiary__c = contlst[0].Subsidiary__c	;
        ObjInv.FY__c = contlst[0].FY1__c;
        if(PerformaIT.size()>0)
        ObjInv.Performa_Invoice_Template__c = PerformaIT[0].Id;
          
        if(contlst[0].Freight_Amount1__c != null && contlst[0].Freight_Amount1__c >0){
          ObjInv.Freight_Amount__c = contlst[0].Freight_Amount1__c;   
        }else{
             ObjInv.Freight_Amount__c = 0;
        }       
        ObjInv.Transaction_Date__c = system.today();
        try{
            insert ObjInv;  
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
        
        List<Performa_Invoice_Line_Item__c> lstInvLI = new List<Performa_Invoice_Line_Item__c>();
        List<Contract_Line_Item__c> conLI = new List<Contract_Line_Item__c>();
        if(selectedRecordList.size() > 0){
            for(Contract_Line_Item__c cli : selectedRecordList){
                system.debug('cli ===>>>' + cli);
                Performa_Invoice_Line_Item__c  ObjInvLI = new Performa_Invoice_Line_Item__c();
                ObjInvLI.Performa_Invoice__c = ObjInv.id;
                ObjInvLI.CurrencyIsoCode=ObjInv.CurrencyIsoCode;
                ObjInvLI.Contract_Line_Item__c = cli.Id;
                ObjInvLI.Product__c = cli.Product2Id__c;
                
                 ObjInvLI.Final_Grand_Total1__c = cli.Final_Grand_Total__c;
                ObjInvLI.Balance_Payment1__c = cli.Balance_Payment__c;
                ObjInvLI.Total_Payment_Received1__c =cli.Total_Amount_Received__c;
                // Added by Amol
                ObjInvLI.Invoice_Amount__c=cli.Last_Performa_Amount__c;
                //ObjInvLI.Final_Grand_Total1__c=cli.Last_Performa_Amount__c;
                
                lstInvLI.add(ObjInvLI);
                cli.Performa_Created__c = true;
                conLI.add(cli);
            }
            try{
                insert lstInvLI;
                update conLI;
            }catch(Exception e){
                system.debug('Exception'+e.getMessage());
            }
            
        }
        
    }
    
    public class ProdListWrapper {
        @AuraEnabled public boolean isChecked;
        @AuraEnabled public  Contract_Line_Item__c objprod;
        
        public ProdListWrapper(boolean isChecked, Contract_Line_Item__c objprod){
            this.isChecked = isChecked;
            this.objprod = objprod;
        }
    }
    

}