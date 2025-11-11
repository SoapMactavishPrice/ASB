public class Create_Project_Controller {
    public String Contractid{get;set;}
    public list<Contract_Line_Item__c> LtsCli{get;set;}
    public String strSelected  {get;set;}
    public boolean show {get; set;}
    public List<SelectOption> options {get;set;}
    public list<Contract> contLst {get; set;}
    public List<wrapper> wrapList {get;set;}
    
    
    public Create_Project_Controller(ApexPages.StandardController controller){
        Contractid = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('Contractid'+Contractid);
        LtsCli = [Select Id,Name,ContractId__c from Contract_Line_Item__c where ContractId__c = : Contractid];
        //list<Contract> contLst = new list<Contract>();
        contLst = [Select id,Original_Contract__c, ExpirationDate__c,PO_Number__c,PO_Date__c,Total_Payment_Received_Roll_Up__c,Total_Advance_Required_In_Amount__c
                   from Contract where id =: Contractid];
        if(contLst.size() > 0){
            if(contLst[0].ExpirationDate__c < System.today()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Contract is Expired'));
                System.debug('contact expired');  
                //show = true;
            }
        if(contLst[0].Total_Payment_Received_Roll_Up__c < contLst[0].Total_Advance_Required_In_Amount__c )
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info,'Project should be created only after advance payment is received...!!!'));
           // return null;
        }
             
        }
        
        
        wrapList = new List<wrapper>();
        // added by rishikesh
        
        Map<string,ProjectManageMent__c> exiProjectMap = new Map<string,ProjectManageMent__c>();
        if(string.isNotBlank(contLst[0].Original_Contract__c)){
            List<ProjectManageMent__c> pmList = [Select Id,Name, Contract_Line_Item__c,Contract_Line_Item__r.Product2Id__c,
                                                 Contract_Line_Item__r.Product2Id__r.ProductCode from ProjectManageMent__c
                                                 where Contract__c =:contLst[0].Original_Contract__c]; 
            for(ProjectManageMent__c pm : pmList){
                string  key = pm.Contract_Line_Item__r.Product2Id__c+'_'+pm.Contract_Line_Item__r.Product2Id__r.ProductCode;
                exiProjectMap.put(key,pm);
            }

        }
        
        
        
        
        
        strSelected = '';
        options = new List<SelectOption>();
        map<id,Integer> contractLineItemAndQty=new map<id,Integer>();
        AggregateResult[] groupedResults= [SELECT Contract_Line_Item__c, count(id) cLineCount FROM ProjectManagement__c where Contract__c=:Contractid and Phase__c!='Cancelled'  group BY Contract_Line_Item__c];
            for (AggregateResult ar : groupedResults)  {
                contractLineItemAndQty.put((Id)ar.get('Contract_Line_Item__c'), (Integer)ar.get('cLineCount'));
                System.debug('contractLineItemAndQty ' +contractLineItemAndQty);
                System.debug('cLineCount= ' +ar.get('cLineCount'));
               
            }
        
        
        for(Contract_Line_Item__c obj :[SELECT Id, Product_Name__c,Project_Created__c,Product_Name_2__c ,LineNumber__c,Quantity__c,
                                        Product2Id__r.ProductCode,Product2Id__c
                                        FROM Contract_Line_Item__c WHERE ContractId__c =: Contractid and Cancelled__c=false ] )//AND Project_Created__c =false  //instead of BU_Project__c.Id pass actual id
        {
           string  key = obj.Product2Id__c+'_'+obj.Product2Id__r.ProductCode;
            if(exiProjectMap.containskey(key)){
                wrapper wrp = new wrapper();
                wrp.isSelect = false;
                wrp.proName = exiProjectMap.get(key).PRODUCT__c;
                wrp.salesPrice = exiProjectMap.get(key).Total_Sales_Price__c;
                wrp.proLineId = exiProjectMap.get(key).Id;
                wrp.proNumber = exiProjectMap.get(key).Name;
                wrp.proLineNumber = obj.Id;
            }else{
                wrapper wrp = new wrapper();
                wrp.isSelect = false;
                if(string.isBlank(obj.Product_Name_2__c)){
                    wrp.proName = obj.Product_Name__c;
                }else{
                    wrp.proName = obj.Product_Name_2__c;
                }
                wrp.salesPrice = null;
                wrp.proLineId = Null;
                wrp.proNumber = null;
                wrp.proLineNumber = null;
            }
            
            
            
            //System.debug('cLineCount= 1 >>>>> ' +contractLineItemAndQty.get(obj.Id));
            //System.debug('cLineCount= 2 :::  ' +obj.Quantity__c);
            //if(contractLineItemAndQty.get(obj.Id) < obj.Quantity__c || !contractLineItemAndQty.containsKey(obj.Id)){
                  
                // Added on 29 March by rishi
                  
              //  if(string.isBlank(obj.Product_Name_2__c)){
                // options.add(new SelectOption(obj.Id,obj.Product_Name__c +'   ('+obj.LineNumber__c+')'));   
                //}else{
                  //  options.add(new SelectOption(obj.Id,obj.Product_Name_2__c+'   ('+obj.LineNumber__c+')'));
               // }
                
            //}
          
        }
        
        if(options.size()==0)
        {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'All projects have been created for this contract.'));
           System.debug('options'+options.size());    
        }
    }
    
    
    public PageReference ProjectCreation(){
        
        String ValSelected = strSelected;
        System.debug('ValSelected'+ValSelected);
        Contract_Line_Item__c ObjCli =new Contract_Line_Item__c();
        ObjCli = [Select id,Approval_Note__c,Approval_Status__c,Class__c,Contract_Item_No__c,ContractId__c,ServiceDate__c,Description__c,Discount__c,Division__c,Drawing_No__c,L_C__c,
                  Expected_Advance__c,Expected_Customer_PO__c,Expected_Delivery__c,Expected_Delivery_date__c,Expected_Drawing_Final__c,Extra_Discount__c,Final_Price_Roll_Up__c,Dept_Collection_date__c,
                  Item_Addition_Function__c,Line_Item_Description__c,Line_Item_Number__c,LineNumber__c,List_Price__c,Mach_Mold_No__c,MFG_Location__c,Product2Id__c,Product_Name__c,
                  Project_Created__c,QTY__c,Quantity__c,UnitPrice__c,Sub_Total__c,Total_Discount_Value__c,Total_Price__c,Product2Id__r.ProductCode,Product2Id__r.Description,Product_Description__c,
                  Product2Id__r.name,Scope__c,Cavity__c,Total_Amount_Received__c,Advance_Required_In_Amount__c,APPLICATION__c,Payment_Terms__c,Product_Name_2__c,Zero_Cooling__c
                  ,Sr_No__c from Contract_Line_Item__c where id = :ValSelected];
        String ContractId = ObjCli.ContractId__c;
        
        Contract Objcont = new Contract();
        
        
        ObjCont = [select id,CurrencyIsoCode,REGION1__c,name,ExpirationDate__c,AccountId,Revision_Number__c,Country_Text__c,FY__c,SUBSIDARY__c,COUNTRY__c,REGION__c,ContractNumber,Quote__c,
                   Contact__r.name,DATE__c,SOLD_TO__r.name,SHIP_TO__c,SHIP_TO__r.name,SHIP_TO__r.Customer_Category__c,SHIP_TO__r.Global_Customer_ID__c, SOLD_TO__c,
                   INCO_TERMS__c,MFG_AT__c,TYPE__c,END_CUSTOMER_NAME__c,ADVANCE_PAYMENT__c,Total_Advance_Required_In_Amount__c, Opportunity__c,
                   Opportunity__r.Source__c,PO_Number__c,PO_Date__c,FY1__c,Subsidiary__c from Contract where id = : ContractId];
        
        //Checking for PO and PO Date 
        /*if(String.isBlank(ObjCont.PO_Number__c) || ObjCont.PO_Date__c==Null  ){
             	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'PO Number and PO Date is required'));
            return null;
             } */
       
        
        system.debug('Test Payment' +ObjCont.ADVANCE_PAYMENT__c);
        
        List<ProjectManagement__c> ListObjPro = new  List<ProjectManagement__c>();
        
        ListObjPro  =[Select id,Contract_Line_Item__c from ProjectManagement__c where Contract_Line_Item__c = : ValSelected ];
        
        System.debug('data'+ListObjPro.size());
        
        
          map<id,Integer> contractLineItemAndQty=new map<id,Integer>();
        AggregateResult[] groupedResults= [SELECT Contract_Line_Item__c, count(id) cLineCount FROM ProjectManagement__c where Contract_Line_Item__c=:ValSelected  and Phase__c!='Cancelled' group BY Contract_Line_Item__c];
        System.debug('groupedResults'+groupedResults);
        for (AggregateResult ar : groupedResults)  {
                contractLineItemAndQty.put((Id)ar.get('Contract_Line_Item__c'), (Integer)ar.get('cLineCount'));
                System.debug('contractLineItemAndQty ' +contractLineItemAndQty);
               
            }
        
         if(contractLineItemAndQty.get(ObjCli.Id) < ObjCli.Quantity__c || groupedResults.size()==0 ){
             
             
             
        //if(ListObjPro.size() == 0){
            //if((ObjCont.ADVANCE_PAYMENT__c == 'YES' && ObjCli.Total_Amount_Received__c >= ObjCli.Advance_Required_In_Amount__c) || (ObjCont.ADVANCE_PAYMENT__c == 'NO')){
            if(ObjCont.ExpirationDate__c > System.today()){
                system.debug('Test Line 1');
            ProjectManagement__c ObjPro = new ProjectManagement__c();
                ObjPro.CurrencyIsoCode=ObjCont.CurrencyIsoCode;
                 
               //ObjPro.REGION__c= ObjCont.REGION1__c;
            ObjPro.Project_Creation_Date__c = system.today();
            if(ObjCont.Revision_Number__c != null && ObjCont.Revision_Number__c != ''){
                ObjPro.SC_Revision_Number__c =  ObjCont.Revision_Number__c;
            }
            if(ObjCont.AccountId != null){
                ObjPro.Account__c =  ObjCont.AccountId;
            }
            if(ObjCont.Quote__c != null){
                ObjPro.Quote_Name__c =  ObjCont.Quote__c;
            }
                if(ObjCont.Opportunity__c != null){
                ObjPro.Opportunity_Name__c =  ObjCont.Opportunity__c;
            }
                
            if(string.valueOf(ObjCli.Sr_No__c) != null){
                    ObjPro.Sq_No__c =  ObjCli.Sr_No__c;
            }
            if(ObjCli.LineNumber__c != null && ObjCli.LineNumber__c != ''){
                ObjPro.LINE_ITEM_NUMBER__c =  ObjCli.LineNumber__c;
            }
            if(ObjCont.FY__c != null && ObjCont.FY__c != ''){
                ObjPro.FY__c = ObjCont.FY__c;
            }
            if(ObjCont.FY1__c != null){
                ObjPro.FY1__c =  ObjCont.FY1__c;
            }
            if(ObjCli.id != null){
                ObjPro.Contract_Line_Item__c = ObjCli.id;
            }
            if(ObjCont.id != null){
                ObjPro.Contract__c = ObjCont.id;
            }
            if(ObjCont.SUBSIDARY__c != null && ObjCont.SUBSIDARY__c != ''){
                ObjPro.SUBSIDARIY__c = ObjCont.SUBSIDARY__c;
            }
            if(ObjCont.Subsidiary__c != null){
                ObjPro.Subsidiary__c =  ObjCont.Subsidiary__c;
            }    
            if(ObjCont.Country_Text__c != null && ObjCont.Country_Text__c != ''){
                ObjPro.COUNTRY__c = ObjCont.Country_Text__c;
            }
            if(ObjCont.REGION1__c != null && ObjCont.REGION1__c != ''){
                ObjPro.REGION__c = ObjCont.REGION1__c;
            }
            if(ObjCont.Contact__r.name != null){
                ObjPro.SALES_PERSON__c = ObjCont.Contact__r.name;
            }
            if(ObjCont.date__C != null){
                ObjPro.date__C = ObjCont.date__C;
            }
            if(ObjCont.ContractNumber != null && ObjCont.ContractNumber != ''){
                ObjPro.SC_NUMBER__c = ObjCont.ContractNumber;
            }
            
            if(ObjCont.SHIP_TO__c != null){
                ObjPro.Ship_To_Party__c = ObjCont.SHIP_TO__c;
                //ObjPro.GLOBAL_CUSTOMER_ID__c = ObjCont.SHIP_TO__r.Global_Customer_ID__c;
                ObjPro.CUSTOMER_TYPE__c = ObjCont.SHIP_TO__r.Customer_Category__c;
            }
            
            if(ObjCont.SOLD_TO__c != null){
                ObjPro.Sold_to_party__c = ObjCont.SOLD_TO__c;
            }
            
            if(ObjCont.INCO_TERMS__c != null && ObjCont.INCO_TERMS__c != ''){
                ObjPro.INCO_TERMS__c = ObjCont.INCO_TERMS__c;
            }
            if(ObjCli.Zero_Cooling__c != null && ObjCli.Zero_Cooling__c != ''){
                ObjPro.Zero_Cooling__c = ObjCli.Zero_Cooling__c;
            }
            if(ObjCli.Drawing_No__c != null && ObjCli.Drawing_No__c != ''){
                ObjPro.CONTAINER_DRG_NO__c = ObjCli.Drawing_No__c;
            }
            if(ObjCli.Dept_Collection_date__c != null){
                ObjPro.DEBT_COLLECTION_DATE__c = ObjCli.Dept_Collection_date__c;
            }
            /*if(ObjCli.Payment_Terms__c != null && ObjCli.Payment_Terms__c != ''){
                ObjPro.PAYMENT_TERMS__c = ObjCli.Payment_Terms__c;
            }*/
            if(ObjCli.MFG_Location__c != null && ObjCli.MFG_Location__c != ''){
                ObjPro.MFG_AT__c = ObjCli.MFG_Location__c;
            }
            if(ObjCli.L_C__c != null && ObjCli.L_C__c != ''){
                ObjPro.LC_TERMS__c = ObjCli.L_C__c;
            }
            if(ObjCli.APPLICATION__c != null && ObjCli.APPLICATION__c != ''){
                ObjPro.APPLICATION__c = ObjCli.APPLICATION__c;
            }
            if(ObjCli.CLASS__c != null && ObjCli.CLASS__c != ''){
                ObjPro.CLASS__c = ObjCli.CLASS__c;
            }
            if(ObjCli.Description__c != null && ObjCli.Description__c != ''){
                ObjPro.COMMENT__c = ObjCli.Description__c;
            }
            if(ObjCont.TYPE__c != null && ObjCont.TYPE__c != ''){
                ObjPro.TYPE__c = ObjCont.TYPE__c;
            }
            
            if(ObjCont.Opportunity__c != null){
                ObjPro.SOURCE__c = ObjCont.Opportunity__r.Source__c;
            }
            
            if(ObjCont.END_CUSTOMER_NAME__c != null && ObjCont.END_CUSTOMER_NAME__c != ''){
                ObjPro.END_USER__c = ObjCont.END_CUSTOMER_NAME__c;
            }
            
            if(ObjCli.Division__c != null && ObjCli.Division__c != ''){
                ObjPro.Division__c =  ObjCli.Division__c;
            }
            /*if(ObjCli.Product2Id__c != null){
                ObjPro.MATERIAL_CODE__c =  ObjCli.Product2Id__r.ProductCode;
            }
            if(ObjCli.Product2Id__c != null){
                ObjPro.MATERIAL_DESCRIPTIO__c =  ObjCli.Product2Id__r.Description;
            }*/
            if(ObjCli.Quantity__c != null){
                ObjPro.QTY__c =  ObjCli.Quantity__c;
            }
            if(ObjCli.Product2Id__c != null){
                system.debug('ObjCli.Product2Id__r.name --->>> ' + ObjCli.Product2Id__r.name);
                ObjPro.PRODUCT__c =  ObjCli.Product2Id__r.name;
            }
            else{
                ObjPro.PRODUCT__c = ObjCli.Product_Name_2__c;
            }
            if(ObjCli.Scope__c != null){
                ObjPro.SCOPE__c =  ObjCli.Scope__c;
            }
            if(ObjCli.Cavity__c != null){
                ObjPro.CAVITY__c =  ObjCli.Cavity__c;
            }
            if(ObjCli.QTY__c != null){
                ObjPro.QTY__c =  1;//ObjCli.QTY__c;
            }
            /*if(ObjCli.UnitPrice__c != null){
                ObjPro.UNIT_PRICE__c =  ObjCli.UnitPrice__c;
            }*/
            if(ObjCli.Total_Price__c != null){
                ObjPro.TOTAL_PRICE__c =  ObjCli.Total_Price__c;
            }
                
                 if(ObjCont.PO_Number__c != null){
                ObjPro.CUSTOMER_PO__c =  ObjCont.PO_Number__c;
            }
                  
              if(ObjCont.PO_Date__c != null){
                ObjPro.CUSTOMER_PO_DATE__c =  ObjCont.PO_Date__c;
            }
                
            
            try{
                insert ObjPro;
                if(contractLineItemAndQty.containskey(ObjCli.Id))
                	ObjCli.Number_of_project_created__c = contractLineItemAndQty.get(ObjCli.Id)+1;
                else
                     ObjCli.Number_of_project_created__c = 1;
                ObjCli.Project_Created__c = true;
                update ObjCli;
                
                Map<Id,Integer> contractLineQuantity = new Map<Id,Integer>(); 
                 Map<Id,Contract> updateContractStatus = new Map<Id,Contract>(); 
                AggregateResult[] groupedAllResults= [SELECT Contract__c, count(id) cLineCount FROM ProjectManagement__c where 
                                                   Contract__c=:ContractId and Phase__c!='Cancelled'  group BY Contract__c];
                 for (AggregateResult ar : groupedAllResults)  {
                     contractLineQuantity.put((Id)ar.get('Contract__c'), (Integer)ar.get('cLineCount'));
                 }
                system.debug('contractLineQuantity :::: > '+contractLineQuantity);
                for(Contract obj :[Select Id,(SELECT Id, Product_Name__c,Project_Created__c,Product_Name_2__c, LineNumber__c,Quantity__c
                                                FROM Contract_Line_Item__r where Cancelled__c =: false)
                                   from contract
                                   WHERE Id =: Contractid])
                
                {
                    if(contractLineQuantity.containsKey(obj.Id)){
                        system.debug(' size -- > '+obj.Contract_Line_Item__r.size());
                        if(obj.Contract_Line_Item__r.size() > contractLineQuantity.get(obj.Id)){
                           obj.Status = 'Converted to PM – Partial'; 
                            updateContractStatus.put(obj.Id,obj);
                        }else if(obj.Contract_Line_Item__r.size() == contractLineQuantity.get(obj.Id)){
                            obj.Status = 'Converted to PM – Complete';
                            updateContractStatus.put(obj.Id,obj);
                        }
                    }
                }
                
                if(updateContractStatus.size() > 0){
                   update updateContractStatus.values();
                }
                
                System.debug('ObjPro : : : :'+ObjPro.id);
                PageReference myVFPage = new PageReference('/'+ObjPro.id);
                myVFPage.setRedirect(true);
                return myVFPage;
            }
            catch(Exception e){
                System.debug('e'+e);
            }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Project can not be created because Contract is expired.'));
            }
            
           /* }  
			else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Project can not be created before advance payment.'));
            
        }*/
            
        }
        else if(ListObjPro.size() != 0){
           // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter Account site'));
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Project already created'));
            return null;
        }
        
        
        
         return null;        
    }
    
    public class wrapper{
        public boolean isSelect{get;set;}
        public string proName {get;set;}
        public string proLineId {get;set;}
        public string proNumber {get;set;}
        public string proLineNumber {get;set;}
        public decimal salesPrice {get;set;}
        
    }
    
}