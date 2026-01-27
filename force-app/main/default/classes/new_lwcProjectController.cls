public with sharing class new_lwcProjectController {
    @AuraEnabled
    public static Map<string,Object> getExistingProjectDetails(string contractId){
        Map<string,Object> result = new Map<string,Object>();
        Contract contLst = [Select id,Original_Contract__c,Master_Contract__c,Expiration_Date__c, ExpirationDate__c,PO_Number__c,PO_Date__c,
                            Total_Payment_Received_Roll_Up__c,Total_Advance_Required_In_Amount__c,Project_Management_Quote_Id__c,Quote__c,Opportunity__c
                            from Contract where id =: Contractid];
        
        set<Id> conId = new set<Id>();
        conId.add(contLst.Id);
        if(string.isNotBlank(contLst.Original_Contract__c)){conId.add(contLst.Original_Contract__c);
                                                           }
        system.debug('conId'+conId);
        Map<Id,Id> currentContractMap = new Map<Id,Id>();
        Map<Id,Id> masterContractMap = new Map<Id,Id>();
        currentContractMap.put(contLst.Id,contLst.Original_Contract__c);
        
        if(contLst != null){
            if(contLst.Expiration_Date__c < System.today()){result.put('Information','Contract is Expired');
                                                           } 
            
        }
        
        List<Contract_Line_Item__c> countOrCI =[SELECT Id, Name,Product_Name__c,Project_Created__c,Product_Name_2__c,Project_Unique_No__c ,LineNumber__c,
                                                Ceiling_Unit_Sales_Price_incl_Options__c,Quantity__c,CurrencyIsoCode,
                                                Product2Id__r.ProductCode,Product2Id__c,Sr_No__c,Original_SQ_No__c
                                                FROM Contract_Line_Item__c WHERE ContractId__c =: Contractid AND Project_Unique_No__c = null order by Sr_No__c asc];
        system.debug('countOrCI --'+countOrCI.size());
        if(countOrCI.size() > 0){
            result.put('UniquePM',countOrCI.size());
        }else{
            if(contLst != null){
                if(contLst.Total_Payment_Received_Roll_Up__c < contLst.Total_Advance_Required_In_Amount__c ){result.put('Warning','Project can be created if Advance Payment is received. Should Project be Created ?');
                                                                                                            }
            }
            
            List<String> quoteIds = new List<String> ();
            if(string.isNotBlank(contLst.Project_Management_Quote_Id__c)){quoteIds= contLst.Project_Management_Quote_Id__c.split(',');
                                                                         }else{quoteIds.add(contLst.Quote__c);
                                                                              }
            
            Map<string,List<ProjectManageMent__c>> exiProjectMap = new Map<string,List<ProjectManageMent__c>>();
            Map<string,List<ProjectManageMent__c>> exiProjectMap1 = new Map<string,List<ProjectManageMent__c>>();
            Map<string,ProjectManageMent__c> masterProjectMap1 = new Map<string,ProjectManageMent__c>();
            List<ProjectManageMent__c> pmList = [Select Id,Name, Contract__c,Sq_No__c,Contract_Line_Item__c,Contract_Line_Item__r.Product2Id__c,Project_Number__c,
                                                 Contract_Line_Item__r.Product2Id__r.ProductCode,PRODUCT__c,Total_Sales_Price__c,
                                                 PO_No_to_HQ_3rd_Party__c,PO_issued_date_to_HQ_3rd_Party__c,Expected_Sales_Month__c,
                                                 Contract_Line_Item__r.Original_SQ_No__c,Project_Unique_No__c
                                                 from ProjectManageMent__c 
                                                 where
                                                 Opportunity_Name__c =:contLst.Opportunity__c
                                                 //Quote_Name__c IN : quoteIds 
                                                 and Phase__c !='Cancelled' 
                                                 order by Contract_Line_Item__r.Original_SQ_No__c asc
                                                 /*or Contract__c =:contLst.Master_Contract__c*/]; 
            system.debug('pmList-->'+pmList.size());    
            for(ProjectManageMent__c pm : pmList){
                string  key = pm.Project_Unique_No__c;//+'_'+pm.Contract_Line_Item__r.Original_SQ_No__c;
                if(exiProjectMap.containsKey(key)){ exiProjectMap.get(key).add(pm);
                                                  }else {
                                                      exiProjectMap.put(key,new List<ProjectManageMent__c>{pm});
                                                  }
            }
            
            system.debug('exiProjectMap'+exiProjectMap.size());
            List<wrapper> wrapList = new List<wrapper>();
            for(Contract_Line_Item__c obj :[SELECT Id, Name,Product_Name__c,Project_Created__c,Product_Name_2__c,Project_Unique_No__c ,LineNumber__c,Ceiling_Unit_Sales_Price_incl_Options__c,Quantity__c,CurrencyIsoCode,
                                            Product2Id__r.ProductCode,Product2Id__c,Sr_No__c,Original_SQ_No__c
                                            FROM Contract_Line_Item__c WHERE ContractId__c =: Contractid order by Sr_No__c asc
                                            
                                           ])
            {
                
                string  key = obj.Project_Unique_No__c;//+'_'+obj.Original_SQ_No__c;
                system.debug('1st key'+key);
                if(exiProjectMap.containskey(key)){
                    system.debug('inside 1st-->'+key);
                    for(ProjectManageMent__c  pmo: exiProjectMap.get(key)){
                        wrapper wrp = new wrapper();
                        wrp.isSelect = true;
                        wrp.p_currency = obj.CurrencyIsoCode;
                        wrp.isDisabled = true;
                        wrp.key = key;
                        wrp.proName = pmo.PRODUCT__c+'('+string.valueOf(obj.LineNumber__c)+')';
                        //wrp.proName = exiProjectMap.get(key).PRODUCT__c;
                        wrp.salesPrice = obj.Ceiling_Unit_Sales_Price_incl_Options__c;
                        wrp.proLineId = pmo.Id;
                        wrp.proNumber = pmo.Project_Number__c;
                        wrp.LineNumber = obj.Name;
                        wrp.LineNumberId = obj.Id;
                        wrp.LineNumberIdClone = obj.Id;
                        wrp.ExpectedSalesMonth = pmo.Expected_Sales_Month__c;
                        wrp.YourPONumber =pmo.PO_No_to_HQ_3rd_Party__c;
                        wrp.YourPOIssueDate=pmo.PO_issued_date_to_HQ_3rd_Party__c;
                        wrapList.add(Wrp);
                    }                
                    List<ProjectManageMent__c> pmoList  = exiProjectMap.get(key);
                    Integer qty  = Integer.valueOf(obj.Quantity__c) - pmoList.size();
                    
                    system.debug('inside 1st-->'+qty);
                    for(Integer i = 0 ; i < qty ; i++){
                        system.debug('inside 1st-- index>'+i);
                        wrapper wrp1 = new wrapper();
                        wrp1.isSelect = true;
                        wrp1.isDisabled = false;
                        wrp1.key = key;
                        if(string.isBlank(obj.Product_Name_2__c)){
                            wrp1.proName = obj.Product_Name__c+'('+string.valueOf(obj.LineNumber__c)+')';
                        }else{
                            wrp1.proName = obj.Product_Name_2__c+'('+string.valueOf(obj.LineNumber__c)+')';
                        }
                        wrp1.salesPrice = null;
                        wrp1.proLineId = Null;
                        wrp1.proNumber = null;
                        wrp1.LineNumber = obj.Name;
                        wrp1.LineNumberId = obj.Id;
                        wrp1.LineNumberIdClone = obj.Id +'_'+i;
                        wrp1.ExpectedSalesMonth = null;
                        wrp1.YourPONumber ='';
                        wrp1.YourPOIssueDate=date.today();
                        wrp1.qty = 1;
                        wrapList.add(Wrp1);
                    }
                    
                }    
                
                else{
                    for(Integer i = 0 ; i < obj.Quantity__c ; i++){
                        system.debug('key 2 -->'+key);
                        wrapper wrp = new wrapper();
                        wrp.isSelect = true;
                        wrp.key = key;
                        wrp.isDisabled = false;
                        if(string.isBlank(obj.Product_Name_2__c)){
                            wrp.proName = obj.Product_Name__c+'('+string.valueOf(obj.LineNumber__c)+')';
                        }else{ wrp.proName = obj.Product_Name_2__c+'('+string.valueOf(obj.LineNumber__c)+')';
                             }
                        wrp.salesPrice = null;
                        wrp.proLineId = Null;
                        wrp.proNumber = null;
                        wrp.LineNumber = obj.Name;
                        wrp.LineNumberId = obj.Id;
                        wrp.LineNumberIdClone = obj.Id +'_'+i;
                        wrp.ExpectedSalesMonth = null;
                        wrp.YourPONumber ='';
                        wrp.YourPOIssueDate=date.today();
                        wrp.qty = 1;
                        wrapList.add(Wrp);
                    }
                }
            }
            if(wrapList.size() > 0){
                result.put('data',JSON.Serialize(wrapList) );
            }
        }
        
        system.debug('result--->'+result);
        return result;
        
        
    }
    
    @AuraEnabled
    public static Map<string,Object> SaveProjectDeatils(string ContractId,string js ,Integer TotalProgram){
        Map<string,string> result = new Map<string,string>();
        system.debug('js-->'+js);
        try{
            Contract Objcont = new Contract();
            
            ObjCont = [select id,CurrencyIsoCode,REGION1__c,Expiration_Date__c,name,ExpirationDate__c,AccountId,Revision_Number__c,Country_Text__c,FY__c,SUBSIDARY__c,COUNTRY__c,REGION__c,ContractNumber,Quote__c,
                       Contact__r.name,DATE__c,SOLD_TO__r.name,SHIP_TO__c,SHIP_TO__r.name,SHIP_TO__r.Customer_Category__c,SHIP_TO__r.Global_Customer_ID__c, SOLD_TO__c,
                       INCO_TERMS__c,MFG_AT__c,TYPE__c,END_CUSTOMER_NAME__c,ADVANCE_PAYMENT__c,Total_Advance_Required_In_Amount__c, Opportunity__c,
                       Opportunity__r.Source__c,PO_Number__c,PO_Date__c,Signed_SC_PO_receipt_date__c,Project_Management_Quote_Id__c,PO_No_from_customer__c,FY1__c,Subsidiary__c,Global_Region__c,Global_SubRegion__c from Contract where id = : ContractId];           
            List<wrapper> wrpJs =  new_lwcProjectController.parse(js);
            Integer totalQty = wrpJs.size();
            Map<Id,List<wrapper>> LineItemId = new Map<Id,List<wrapper>>();
            set<Id> ExistingProjectId = new  set<Id>();
            
            List<String> quoteIds = new List<String> ();
            if(string.isNotBlank(ObjCont.Project_Management_Quote_Id__c)){  
                quoteIds= ObjCont.Project_Management_Quote_Id__c.split(',');
                system.debug('quoteIds-->'+quoteIds);
            }else{
                quoteIds.add(ObjCont.Quote__c);
            }
            
            
            for (Integer i = 0; i < wrpJs.size(); i++) {
                wrapper wrp = wrpJs[i];
                
                if(wrp.isSelect && String.isBlank(wrp.proLineId) && !wrp.isDisabled) {
                    if(LineItemId.containsKey(wrp.LineNumberId)) {                        LineItemId.get(wrp.LineNumberId).add(wrp);
                                                                 } else {
                                                                     LineItemId.put(wrp.LineNumberId, new List<wrapper>{wrp});
                                                                 }
                } else if(wrp.isSelect && String.isNotBlank(wrp.proLineId) && wrp.isDisabled) {                ExistingProjectId.add(wrp.proLineId);                     wrpJs.remove(i);                    i--; 
                                                                                              }
            }
            
            
            map<string,Contract_Line_Item__c> exeMap = new map<string,Contract_Line_Item__c>();
            
            set<Id> conId = new set<Id>();
            List<Contract_Line_Item__c> conList = [SELECT  id,Approval_Note__c,Quote_Line_Item_Name__c,Approval_Status__c,Class__c,Contract_Item_No__c,ContractId__c,ServiceDate__c,Description__c,Discount__c,Division__c,Drawing_No__c,L_C__c,
                                                   Expected_Advance__c,Expected_Customer_PO__c,Expected_Delivery__c,Expected_Delivery_date__c,Expected_Drawing_Final__c,Extra_Discount__c,Final_Price_Roll_Up__c,Dept_Collection_date__c,
                                                   Item_Addition_Function__c,Line_Item_Description__c,Line_Item_Number__c,LineNumber__c,List_Price__c,Mach_Mold_No__c,MFG_Location__c,Product2Id__c,Product_Name__c,
                                                   Project_Created__c,QTY__c,Quantity__c,UnitPrice__c,Sub_Total__c,Total_Discount_Value__c,Total_Price__c,Product2Id__r.ProductCode,Product2Id__r.Description,Product_Description__c,
                                                   Product2Id__r.name,Scope__c,Cavity__c,Total_Amount_Received__c,Advance_Required_In_Amount__c,APPLICATION__c,Payment_Terms__c,Product_Name_2__c,Zero_Cooling__c
                                                   ,Sr_No__c ,Original_SQ_No__c,Total_Sales_Price2__c,Project_Unique_No__c
                                                   FROM Contract_Line_Item__c WHERE ContractId__c =: Contractid];
            
            //map<Id,string> prjMap = new map<Id,string>();
            for(Contract_Line_Item__c obj : conList)
            {
                string  key = obj.Project_Unique_No__c;//+'_'+obj.Original_SQ_No__c;
                exeMap.put(key,obj);
            }
            
            system.debug('exeMap'+exeMap);
            List<ProjectManageMent__c> pmList = [Select Id,Name, Sq_No__c,MATERIAL_CODE__c,Contract_Line_Item__c,Phase__c,Project_Unique_No__c,Contract_Line_Item__r.Product2Id__c,Contract_Line_Item__r.Original_SQ_No__c,
                                                 Contract_Line_Item__r.Product2Id__r.ProductCode,Old_Phase__c from ProjectManageMent__c
                                                 where
                                                 
                                                 Opportunity_Name__c =:ObjCont.Opportunity__c
                                                 
                                                 //Quote_Name__c IN : quoteIds 
                                                 and Phase__c !=:'Cancelled'];
            
            system.debug('pmList'+pmList.size());
            List<ProjectManageMent__c> pmglist = new List<ProjectManageMent__c>();
            for(ProjectManageMent__c pm : pmList){
                string  key = pm.Project_Unique_No__c;//+pm.Contract_Line_Item__r.Original_SQ_No__c;
                if(exeMap.containsKey(key) && exeMap.get(key).Id != pm.Contract_Line_Item__c){
                    pm.Contract_Line_Item__c = exeMap.get(key).Id;                    pm.Contract__c = contractid;
                    pm.Phase__c = pm.Old_Phase__c;                    pm.Sq_No__c =  exeMap.get(key).Sr_No__c;
                    pm.Quote_Name__c = Objcont.Quote__c;                  pmglist.add(pm);
                }
            }
            
            if(pmglist.size() > 0){                update pmglist;
                                  }
            
            
            system.debug('Test Payment' +ObjCont.ADVANCE_PAYMENT__c);
            
            List<ProjectManagement__c> ListObjPro = new  List<ProjectManagement__c>();
            
            ListObjPro  =[Select id,Contract_Line_Item__c,Old_Phase__c,Project_Unique_No__c from ProjectManagement__c where Quote_Name__c IN : quoteIds ];
            
            //System.debug('data'+ListObjPro.size());
            
            system.debug('conList'+conList.size()+' Line Number '+LineItemId.size() +  ' data '+ LineItemId);
            
            List<ProjectManagement__c> ObjProToNew = new  List<ProjectManagement__c>();
            //for(Contract_Line_Item__c ObjCli : conList){
            
            //string  key = ObjCli.Project_Unique_No__c;
            //system.debug('key  --  '+key);
            
            if(test.isRunningtest()){
                ObjCont.Expiration_Date__c  = system.today().addDays(1);
                }
                if(ObjCont.Expiration_Date__c >= System.today())
                {
                    for(Wrapper wrp: wrpJs){
                        if(wrp.key !=null  && wrp.isSelect){
                            
                            
                            Contract_Line_Item__c ObjCli = exeMap.get(wrp.key);
                            ProjectManagement__c ObjPro = new ProjectManagement__c();
                            UserSetup us=getQuoteNumber();
                            ObjPro.Project_Number__c	= us.ContractNo;
                            
                            
                            ObjPro.Expected_Sales_Month__c =  wrp.ExpectedSalesMonth;
                            ObjPro.PO_No_to_HQ_3rd_Party__c = wrp.YourPONumber ;
                            ObjPro.PO_issued_date_to_HQ_3rd_Party__c = wrp.YourPOIssueDate;
                            
                            
                            ObjPro.CurrencyIsoCode=ObjCont.CurrencyIsoCode;
                            objPro.Project_Unique_No__c = ObjCli.Project_Unique_No__c;
                            //objPro.MATERIAL_CODE__c = string.valueOf(ObjCli.Sr_No__c);
                            objPro.Old_Phase__c = 'Under Manufacturing/Assembly';
                            ObjPro.Global_Region__c = ObjCont.Global_Region__c;
                            
                            ObjPro.Global_SubRegion__c = ObjCont.Global_SubRegion__c;
                            
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
                            
                            if(string.valueOf(ObjCli.Sr_No__c) != null){                                ObjPro.Sq_No__c =  ObjCli.Sr_No__c;
                                                                       }
                            if(ObjCli.LineNumber__c != null && ObjCli.LineNumber__c != ''){
                                ObjPro.LINE_ITEM_NUMBER__c =  ObjCli.LineNumber__c;
                            }
                            if(ObjCont.FY__c != null && ObjCont.FY__c != ''){                                ObjPro.FY__c = ObjCont.FY__c;
                                                                            }
                            if(ObjCont.FY1__c != null){
                                ObjPro.FY1__c =  ObjCont.FY1__c;
                            }
                            if(ObjCli.id != null){
                                ObjPro.Contract_Line_Item__c = ObjCli.id;
                            }
                            if(ObjCli.Quote_Line_Item_Name__c != null){
                                ObjPro.Quote_Line_Item_New_Custom__c = ObjCli.Quote_Line_Item_Name__c;
                            }
                            if(ObjCont.id != null){
                                ObjPro.Contract__c = ObjCont.id;
                            }
                            if(ObjCont.SUBSIDARY__c != null && ObjCont.SUBSIDARY__c != ''){                                ObjPro.SUBSIDARIY__c = ObjCont.SUBSIDARY__c;
                                                                                          }
                            if(ObjCont.Subsidiary__c != null){
                                ObjPro.Subsidiary__c =  ObjCont.Subsidiary__c;
                            }    
                            if(ObjCont.Country_Text__c != null && ObjCont.Country_Text__c != ''){                                ObjPro.COUNTRY__c = ObjCont.Country_Text__c;
                                                                                                }
                            if(ObjCont.REGION1__c != null && ObjCont.REGION1__c != ''){                                ObjPro.REGION__c = ObjCont.REGION1__c;
                                                                                      }
                            if(ObjCont.Contact__r.name != null){                                ObjPro.SALES_PERSON__c = ObjCont.Contact__r.name;
                                                               }
                            if(ObjCont.date__C != null){
                                ObjPro.date__C = ObjCont.date__C;
                            }
                            if(ObjCont.ContractNumber != null && ObjCont.ContractNumber != ''){
                                ObjPro.SC_NUMBER__c = ObjCont.ContractNumber;
                            }
                            
                            if(ObjCont.SHIP_TO__c != null){
                                ObjPro.Ship_To_Party__c = ObjCont.SHIP_TO__c;                                ObjPro.CUSTOMER_TYPE__c = ObjCont.SHIP_TO__r.Customer_Category__c;
                            }
                            
                            if(ObjCont.SOLD_TO__c != null){                                ObjPro.Sold_to_party__c = ObjCont.SOLD_TO__c;
                                                          }
                            
                            if(ObjCont.INCO_TERMS__c != null && ObjCont.INCO_TERMS__c != ''){                                ObjPro.INCO_TERMS__c = ObjCont.INCO_TERMS__c;
                                                                                            }
                            if(ObjCli.Zero_Cooling__c != null && ObjCli.Zero_Cooling__c != ''){                                ObjPro.Zero_Cooling__c = ObjCli.Zero_Cooling__c;
                                                                                              }
                            if(ObjCli.Drawing_No__c != null && ObjCli.Drawing_No__c != ''){                                ObjPro.CONTAINER_DRG_NO__c = ObjCli.Drawing_No__c;
                                                                                          }
                            if(ObjCli.Dept_Collection_date__c != null){                                ObjPro.DEBT_COLLECTION_DATE__c = ObjCli.Dept_Collection_date__c;
                                                                      }
                            /*if(ObjCli.Payment_Terms__c != null && ObjCli.Payment_Terms__c != ''){
ObjPro.PAYMENT_TERMS__c = ObjCli.Payment_Terms__c;
}*/
                            if(ObjCli.MFG_Location__c != null && ObjCli.MFG_Location__c != ''){                                ObjPro.MFG_AT__c = ObjCli.MFG_Location__c;
                                                                                              }
                            if(ObjCli.L_C__c != null && ObjCli.L_C__c != ''){                                ObjPro.LC_TERMS__c = ObjCli.L_C__c;
                                                                            }
                            if(ObjCli.APPLICATION__c != null && ObjCli.APPLICATION__c != ''){                                ObjPro.APPLICATION__c = ObjCli.APPLICATION__c;
                                                                                            }
                            if(ObjCli.CLASS__c != null && ObjCli.CLASS__c != ''){                             ObjPro.CLASS__c = ObjCli.CLASS__c;
                                                                                }
                            if(ObjCli.Description__c != null && ObjCli.Description__c != ''){                                ObjPro.COMMENT__c = ObjCli.Description__c;
                                                                                            }
                            if(ObjCont.TYPE__c != null && ObjCont.TYPE__c != ''){                                ObjPro.TYPE__c = ObjCont.TYPE__c;
                                                                                }
                            
                            if(ObjCont.Opportunity__c != null){
                                ObjPro.SOURCE__c = ObjCont.Opportunity__r.Source__c;
                            }
                            
                            if(ObjCont.END_CUSTOMER_NAME__c != null && ObjCont.END_CUSTOMER_NAME__c != ''){                                ObjPro.END_USER__c = ObjCont.END_CUSTOMER_NAME__c;
                                                                                                          }
                            
                            if(ObjCli.Division__c != null && ObjCli.Division__c != ''){                                ObjPro.Division__c =  ObjCli.Division__c;
                                                                                      }
                            /*if(ObjCli.Product2Id__c != null){
ObjPro.MATERIAL_CODE__c =  ObjCli.Product2Id__r.ProductCode;
}
if(ObjCli.Product2Id__c != null){
ObjPro.MATERIAL_DESCRIPTIO__c =  ObjCli.Product2Id__r.Description;
}*/
                            //if(ObjCli.Quantity__c != null){
                            ObjPro.QTY__c =  1;
                            //}
                            if(ObjCli.Product2Id__c != null){
                                system.debug('ObjCli.Product2Id__r.name --->>> ' + ObjCli.Product2Id__r.name);                                ObjPro.PRODUCT__c =  ObjCli.Product2Id__r.name;
                            }
                            else{
                                ObjPro.PRODUCT__c = ObjCli.Product_Name_2__c;
                            }
                            if(ObjCli.Scope__c != null){                                ObjPro.SCOPE__c =  ObjCli.Scope__c;
                                                       }
                            if(ObjCli.Cavity__c != null){                                ObjPro.CAVITY__c =  ObjCli.Cavity__c;
                                                        }
                            if(ObjCli.QTY__c != null){                                ObjPro.QTY__c =  1;//ObjCli.QTY__c;
                                                     }
                            /*if(ObjCli.UnitPrice__c != null){
ObjPro.UNIT_PRICE__c =  ObjCli.UnitPrice__c;
}*/
                            if(ObjCli.Total_Sales_Price2__c != null){
                                ObjPro.TOTAL_PRICE__c =  ObjCli.Total_Sales_Price2__c /ObjCli.Quantity__c;
                            }
                            
                            if(ObjCont.PO_No_from_customer__c	 != null){
                                ObjPro.CUSTOMER_PO__c =  ObjCont.PO_No_from_customer__c	;
                            }
                            
                            
                            if(ObjCont.Signed_SC_PO_receipt_date__c != null){
                                ObjPro.CUSTOMER_PO_DATE__c =  ObjCont.Signed_SC_PO_receipt_date__c;
                            }
                            
                            ObjProToNew.add(ObjPro);
                        }
                    }
                }
                //}      
                
                system.debug('ObjProToNew'+ObjProToNew.size());
                if(ObjProToNew.size() > 0){
                    insert ObjProToNew;
                }
                
                map<id,Integer> contractLineItemAndQty=new map<id,Integer>();
                AggregateResult[] groupedResults= [SELECT Contract_Line_Item__c, count(id) cLineCount FROM ProjectManagement__c 
                                                   where Contract_Line_Item__c=:LineItemId.keyset()  and Phase__c!='Cancelled' 
                                                   group BY Contract_Line_Item__c];
                System.debug('groupedResults'+groupedResults);
                for (AggregateResult ar : groupedResults)  {
                    contractLineItemAndQty.put((Id)ar.get('Contract_Line_Item__c'), (Integer)ar.get('cLineCount'));
                    System.debug('contractLineItemAndQty ' +contractLineItemAndQty);
                    
                }
                
                List<Contract_Line_Item__c> objCliList = new List<Contract_Line_Item__c>();
                for(Contract_Line_Item__c ObjCli : conList){
                    
                    if(ObjCont.Expiration_Date__c > System.today() && LineItemId.containsKey(ObjCli.Id)){
                        if(contractLineItemAndQty.containskey(ObjCli.Id))
                            ObjCli.Number_of_project_created__c = contractLineItemAndQty.get(ObjCli.Id)+1;
                        else
                            ObjCli.Number_of_project_created__c = 1;
                        ObjCli.Project_Created__c = true;
                        
                        objCliList.add(ObjCli);
                    }
                }
                
                if(objCliList.size() > 0){
                    update objCliList; 
                }
                
                //Map<Id,Integer> contractLineQuantity = new Map<Id,Integer>(); 
                Map<Id,Contract> updateContractStatus = new Map<Id,Contract>(); 
                /*AggregateResult[] groupedAllResults= [SELECT Contract__c, count(id) cLineCount FROM ProjectManagement__c where 
Contract__c=:ContractId    group BY Contract__c];
for (AggregateResult ar : groupedAllResults)  {
contractLineQuantity.put((Id)ar.get('Contract__c'), (Integer)ar.get('cLineCount'));
}*/
                //system.debug('contractLineQuantity :::: > '+contractLineQuantity);
                
                if(Contractid !=null){
                    List<Contract> conelist =  [Select Id,Total_Quantity_Of_Products__c,Count_of_PM__c,(SELECT Id, Product_Name__c,Project_Created__c,Product_Name_2__c, LineNumber__c,Quantity__c
                                                                                                        FROM Contract_Line_Item__r where Cancelled__c =: false)
                                                from contract
                                                WHERE Id =: Contractid];
                    
                    if(conelist.size() > 0){
                        
                        ReOpenQuoteFromContract.isbypassRule =  true;
                        for(Contract obj :conelist)
                            
                        {
                            system.debug('TotalProgram'+TotalProgram);
                            obj.Count_of_PM__c = TotalProgram;
                            obj.Total_Quantity_Of_Products__c = totalQty; 
                            system.debug('obj.Count_of_PM__c-->'+obj.Count_of_PM__c);
                            if(obj.Total_Quantity_Of_Products__c > obj.Count_of_PM__c){
                                system.debug('inside obj-->'+obj.Count_of_PM__c);
                                obj.Status = 'Converted to PM – Partial'; 
                                updateContractStatus.put(obj.Id,obj);
                            }else if(obj.Total_Quantity_Of_Products__c  == obj.Count_of_PM__c){
                                system.debug('else obj-->'+obj.Count_of_PM__c);
                                obj.Status = 'Converted to PM – Complete';
                                updateContractStatus.put(obj.Id,obj);
                            }
                        }
                        
                        if(updateContractStatus.size() > 0){
                            update updateContractStatus.values();
                        }
                        result.put('Success','Project Management Created Successfully');
                    }
                }
                //result.put('status','true');
                return result;
                
            }
            catch(exception e){
                result.put('Error',e.getMessage());
                // result.put('status','false');
                system.debug('err ' + e.getLineNumber() +' msg '+e.getMessage());
                return result;
            }
        }
        
        @AuraEnabled
        public static Map<string,Object> createUniqueNo(string conId){
            
            Map<string,Object> result = new Map<string,Object>(); 
            try{
                
                //Quote qt = [SELECT Id, Project_Management_Quote_Id__c FROM Quote WHERE Id IN :projIds];
                
                List<Quote_Line_Item_Custom__c> lineItems = [
                    SELECT Id, Quote__c, Project_Unique_No__c, Product_Name__c, Product_Code__c, Manual_Product_Code__c
                    FROM Quote_Line_Item_Custom__c
                    WHERE Quote__c IN (Select Quote__c from Contract where Id=:conId) 
                    
                ]; 
                
                List<Quote_Line_Item_Custom__c> toUpdate = new List<Quote_Line_Item_Custom__c>();
                map<string,string> uniqueMap =new map<string,string>(); 
                Map<String, Integer> uniquenessCounter = new Map<String, Integer>();

for (Quote_Line_Item_Custom__c qle : lineItems) {
    if (String.isBlank(qle.Project_Unique_No__c)) {
        String baseUniqueNo = '';

        if (String.isNotBlank(qle.Product_Name__c)) {
            baseUniqueNo += qle.Product_Name__c + '_';
        }
        if (String.isNotBlank(qle.Product_Code__c)) {
            baseUniqueNo += qle.Product_Code__c + '_';
        }
        if (String.isNotBlank(qle.Manual_Product_Code__c)) {
            baseUniqueNo += qle.Manual_Product_Code__c + '_';
        }

        // Use date for partial uniqueness
        baseUniqueNo += DateTime.now().format('dd_MM_yyyy_HH_mm_ss');

        // Track how many times this base ID has been seen
        Integer count = uniquenessCounter.containsKey(baseUniqueNo) ? uniquenessCounter.get(baseUniqueNo) + 1 : 1;
        uniquenessCounter.put(baseUniqueNo, count);

        // Append count to ensure uniqueness
        String finalUniqueNo = baseUniqueNo + '_' + String.valueOf(count);

        qle.Project_Unique_No__c = finalUniqueNo;
        toUpdate.add(qle);
    } else {
        uniqueMap.put(qle.Id, qle.Project_Unique_No__c);
    }
}

                
                //if (!toUpdate.isEmpty()) {
                update toUpdate;
                for (Quote_Line_Item_Custom__c qle : toUpdate) {
                    uniqueMap.put(qle.Id,qle.Project_Unique_No__c);
                }
                
                if(uniqueMap.size() > 0){
                    List<Contract_Line_Item__c> conLinetoUpdate = new List<Contract_Line_Item__c>();
                    
                    List<Contract_Line_Item__c> conLineList =[Select Id,Project_Unique_No__c,Quote_Line_Item_Name__c from Contract_Line_Item__c where ContractId__c=:conId
                                                              AND Project_Unique_No__c=null];
                    for(Contract_Line_Item__c conLine : conLineList){
                        if(uniqueMap.containsKey(conLine.Quote_Line_Item_Name__c)){
                            conLine.Project_Unique_No__c =uniqueMap.get(conLine.Quote_Line_Item_Name__c);  
                            conLinetoUpdate.add(conLine);
                        }
                    }
                    
                    if(conLinetoUpdate.size() > 0){
                        update conLinetoUpdate;
                    }
                    
                }
                
                //}
                result.put('Message','Data Updated Successfully');
                result.put('Status','Success');
            }catch(exception e){
                result.put('Message',e.getMessage());
                result.put('Status','Failed');
            }
            return result;
        }
        
        
        
        
        
        Public static UserSetup getQuoteNumber()
        {
            //updated This logic to assign fy and Subsidiary
            UserSetup us=new UserSetup();
            Fiscal_Year_Master__c f=[select id,name from Fiscal_Year_Master__c where Active__c=true limit 1];
            system.debug('f '+f);
            Map<id,Unique_No__c> sMap=new Map<id,Unique_No__c>();
            // Get Last Count
            for(Unique_No__c u:[select id,name,Serial_No__c,Object_Name__c,Subsidiary__c,Fiscal_Year__c from Unique_No__c where Fiscal_Year__c=:f.id and 
                                Object_Name__c='Project Management' For Update])
            { sMap.put(u.Subsidiary__c,u);}
            
            
            
            User_Setup__c u=[select id,name,User__c,Subsidiari__c,Subsidiari__r.name,Default_Language__c  from User_Setup__c where User__c =: Userinfo.getUserId()];
            system.debug('f '+f);
            system.debug('User_Setup__c '+u);
            if(sMap.containskey(u.Subsidiari__c)){
                Unique_No__c un=sMap.get(u.Subsidiari__c);
                String temp='';
                
                for(Integer i=6;i>String.valueof(un.Serial_No__c+1).length();i--)
                {temp=temp+'0';}
                temp=temp+String.valueof(un.Serial_No__c+1);us.ContractNo='PRJ'+u.Subsidiari__r.name+'-'+temp;
                un.Serial_No__c=un.Serial_No__c+1; sMap.put(u.Subsidiari__c,un);
            }
            else
            {
                us.ContractNo='PRJ'+u.Subsidiari__r.name +'-'+'000001';
                Unique_No__c un=new Unique_No__c();
                un.Object_Name__c='Project Management';
                un.Subsidiary__c=u.Subsidiari__c;
                un.Fiscal_Year__c=f.id;
                un.Serial_No__c=1;  
                sMap.put(u.Subsidiari__c,un);
            }
            upsert sMap.values();
            system.debug(' us.ContractNo '+ us.ContractNo);
            us.FY=f.id;  
            us.Subsidiari=u.Subsidiari__c;
            return us;
        }
        
        
        Public Class UserSetup {
            public String FY;
            Public String Subsidiari;
            Public String ContractNo;
        }
        
        public static List<wrapper> parse(string js){
            return ((List<wrapper>)system.JSON.deserialize(js,List<wrapper>.class));
        }
        
                                
        
        public class wrapper{
            public Id LineNumberId {get;set;}
            public string key {get;set;}
            public string LineNumberIdClone {get;set;}
            public boolean isSelect{get;set;}
            public Integer qty{get;set;}
            public string p_currency {get;set;}
            public string proName {get;set;}
            public string proLineId {get;set;}
            public string proNumber {get;set;}
            public Date ExpectedSalesMonth {get;set;}
            public string YourPONumber {get;set;}
            public date YourPOIssueDate {get;set;}
            public string LineNumber {get;set;}
            public boolean isDisabled {get;set;}
            public decimal salesPrice {get;set;}
            
        }
    }