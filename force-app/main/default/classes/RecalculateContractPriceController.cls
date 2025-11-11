public class RecalculateContractPriceController {
public String recID{get;set;}
    
    public RecalculateContractPriceController(ApexPages.StandardController controller){
        
    }
    
    public PageReference Recalculate(){
        recID=ApexPages.CurrentPage().getparameters().get('Id');
        Contract ObjCOntract=[select id,name,Subsidiary__r.Price_Book__c from Contract where id=:recID];
        List<Contract_Line_Item__c> ObjCLI = new List<Contract_Line_Item__c>();
        List<Contract_Line_Option__c> ObjCLIO = new List<Contract_Line_Option__c>();
        List<id> prod = new List<id>();
        List<id> prodqlio = new List<id>();
        List<PricebookEntry> pricebookentryList = new List<PricebookEntry>();
        List<Contract_Line_Item__c> cliList = new List<Contract_Line_Item__c>();
        List<Contract_Line_Option__c> clioList = new List<Contract_Line_Option__c>();
        
        ObjCLI = [select id,ContractId__c,Base_Price_Line_Item__c,Quantity__c,ContractId__r.Subsidiary__c,ContractId__r.Subsidiary__r.Price_Book__c,
                  Product2Id__c,ContractId__r.Exchange_Rate__c,ContractId__r.Subsidiary__r.Additional_Margin__c,
                  ContractId__r.Subsidiary__r.Rounding_Off_Digits__c,ContractId__r.Additinal_Margin__c,
                  ContractId__r.Subsidiary__r.M1__c,ContractId__r.Subsidiary__r.D1__c,ContractId__r.Subsidiary__r.D2__c,Quote_Line_Item_Name__c,Quote_Line_Item_Name__r.Is_Manual__c
                  from Contract_Line_Item__c where ContractId__c = : recID and Quote_Line_Item_Name__r.Is_Manual__c=false];
        
        ObjCLIO = [select id,ContractId__c,ContractId__r.Subsidiary__c,ContractId__r.Subsidiary__r.Price_Book__c, 
                  Product__c,ContractId__r.Exchange_Rate__c,ContractId__r.Subsidiary__r.Additional_Margin__c,
                  ContractId__r.Subsidiary__r.Rounding_Off_Digits__c,ContractId__r.Additinal_Margin__c,
                  ContractId__r.Subsidiary__r.M1__c,ContractId__r.Subsidiary__r.D1__c,ContractId__r.Subsidiary__r.D2__c,Contract_Line_Item__c,Select_Option__c
                  from Contract_Line_Option__c where ContractId__c = : recID and Select_Option__c=false];
       
        for(Contract_Line_Item__c clis:ObjCLI){
            prod.add(clis.Product2Id__c);
        }
        
        for(Contract_Line_Option__c clios:ObjCLIO){
            prodqlio.add(clios.Product__c);
        }
        
        List<PricebookEntry> pbe = [Select Product2Id,UnitPrice,Pricebook2Id from PricebookEntry WHERE Product2Id IN: prod 
                                   AND Pricebook2Id =: ObjCOntract.Subsidiary__r.Price_Book__c];
        
        List<PricebookEntry> pbeqlio = [Select Product2Id,UnitPrice,Pricebook2Id from PricebookEntry WHERE Product2Id IN: prodqlio 
                                   AND Pricebook2Id =: ObjCOntract.Subsidiary__r.Price_Book__c];
        
        map<ID,PricebookEntry> pmap= new map<ID,PricebookEntry>();
        map<ID,PricebookEntry> pmapqlio= new map<ID,PricebookEntry>();
        for(PricebookEntry pbel:pbe){
            pmap.put(pbel.Product2Id, pbel);
        }
        
        for(PricebookEntry pbel:pbeqlio){
            pmapqlio.put(pbel.Product2Id, pbel);
        }
        try{
        For(Contract_Line_Item__c cli:ObjCLI){
        String PriceBoodId;
        
        cli.List_Price__c=AddProducts.getListPrice(pmap.get(cli.Product2Id__c).UnitPrice, cli.ContractId__r.Exchange_Rate__c, cli.ContractId__r.Subsidiary__r.D1__c, cli.ContractId__r.Subsidiary__r.D2__c, cli.ContractId__r.Additinal_Margin__c, Integer.valueof(cli.ContractId__r.Subsidiary__r.Rounding_Off_Digits__c));
           
        decimal price=((pmap.get(cli.Product2Id__c).UnitPrice*cli.ContractId__r.Exchange_Rate__c))*cli.Quantity__c;
        system.debug('cli.Quantity__c'+cli.Quantity__c);      
        cli.Base_Price_Line_Item__c=Math.ceil(price/Integer.valueOf(cli.ContractId__r.Subsidiary__r.Rounding_Off_Digits__c))*Integer.valueOf(cli.ContractId__r.Subsidiary__r.Rounding_Off_Digits__c);
        
          system.debug('cli.Base_Price__c'+cli.Base_Price_Line_Item__c);  
        
        cliList.add(cli);
        }
        
        Update cliList;
        }
        catch(exception e)
        {
         System.debug('e.getMessage() at 75'+e.getMessage());
         e.setMessage('Something went wrong Please contact System Admin.');  
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,e.getMessage())); 
         return null;
        }
        try{
        for(Contract_Line_Option__c clio:ObjCLIO){
        String PriceBoodId;
        clio.Manual_Option_List_Price__c=AddProducts.getListPrice(pmapqlio.get(clio.Product__c).UnitPrice, clio.ContractId__r.Exchange_Rate__c, clio.ContractId__r.Subsidiary__r.D1__c, clio.ContractId__r.Subsidiary__r.D2__c, clio.ContractId__r.Additinal_Margin__c, Integer.valueof(clio.ContractId__r.Subsidiary__r.Rounding_Off_Digits__c));
        
            
        Decimal price =  pmapqlio.get(clio.Product__c).UnitPrice *clio.ContractId__r.Exchange_Rate__c;
        clio.Manual_Option_Base_Price__c=Math.ceil(price / Integer.valueof(clio.ContractId__r.Subsidiary__r.Rounding_Off_Digits__c)) * Integer.valueof(clio.ContractId__r.Subsidiary__r.Rounding_Off_Digits__c);
            
        clioList.add(clio);
        }
        
        Update clioList;
        }
        catch(exception e)
        {
         System.debug('e.getMessage() at 101'+e.getMessage());
         e.setMessage('Something went wrong Please contact System Admin.');
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,e.getMessage())); 
         return null;
        }
        PageReference myVFPage = new PageReference('/'+ObjCOntract.Id);
        myVFPage.setRedirect(true);
        return myVFPage;
    }
}