public class ReviseProductOnContract {
    
    public ReviseProductOnContract(ApexPages.StandardController controller){
        
    }
    
    public PageReference UpdateProductOnContract(){
        String quoteID = ApexPages.currentPage().getParameters().get('id');
        System.debug('quoteID'+quoteID);
        Quote quote = [SELECT Id, Name, Status FROM Quote WHERE Id =: quoteID];
        Contract conDetail = [SELECT Id, Name, Status, Quote__c FROM Contract WHERE Quote__c =: quoteID and Status!='Cancelled' limit 1];
        System.debug('conDetail ----> '+ conDetail);
        if(conDetail.Status == 'Hold for Revision') {
            List<Quote_Line_Item_Custom__c> qli = new List<Quote_Line_Item_Custom__c>();
            qli = [Select id,Discount_Approval_Note__c,Class_2__c,Division__c,Drawing_No__c,Advance_Percentage__c,Expected_Customer_PO__c,Discount_Allowed__c,
                   Expected_Delivery__c,Expected_Delivery_date__c,Expected_Drawing_Final__c,Zero_Cooling_2__c,Product_Name__c,Payment_Terms__c,Product__r.Scope_of_Mold__c,
                   Mach_Mold_No__c,MFG_AT__c,Quantity__c,Discount__c,Base_Price__c,Product__r.Model__c,Product__r.Number_Of_Cavity_Mould__c,Application__c,
                   List_Price__c,Product__c,Quote__c,Quote__r.ContractId,UOM__c,Product__r.UOM__c,Product__r.Product_Type__c,Product_Description__c,Level_Of_Ceiling__c,
                   (Select id,Discount__c,Final_Price__c,Manual_Option__c,Quantity__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Mould_Cavity__c,Sales_price_Total__c,
                    Other_Charges_Base_Price__c,Other_Charges_Function__c,Manula_Option_List_Price__c,Product__c,Quote__c,Quote_Line_Item__c,Select_Option__c,
                    Manual_Product_Name__c,Description__c,Price_Type__c,Discount_Description__c,Option_Number__c
                    from Quote_Line_Options__r)
                   from Quote_Line_Item_Custom__c Where Quote__c =: quoteID ];
            System.debug('qli ----> '+ qli);           
            
            List<Quote_Line_Options__c> quoteLineOpt = new   List<Quote_Line_Options__c>();
            
            quoteLineOpt = [Select id,Discount__c,Final_Price__c,Manual_Option__c,Quantity__c,Manual_Option_Base_Price__c,Manual_Option_Function__c,Other_Charges__c,Mould_Cavity__c,Sales_price_Total__c,
                            Other_Charges_Base_Price__c,Other_Charges_Function__c,Manula_Option_List_Price__c,Product__c,Quote__c,Quote_Line_Item__c,Select_Option__c,
                            Manual_Product_Name__c,Description__c,Price_Type__c,Discount_Description__c,Option_Number__c,Unique_Id__c
                            from Quote_Line_Options__c  where Quote__c=:quoteID	];
            
            List<Contract_Line_Item__c> cli = new List<Contract_Line_Item__c>();
            cli = [SELECT Id, Name, Product2Id__c, ContractId__c, Quote_Line_Item_Name__c From Contract_Line_Item__c where ContractId__c =: conDetail.Id ];            
            List<Contract_Line_Item__c> newClis = new List<Contract_Line_Item__c>();
            List<Contract_Line_Item__c> cliToDelete = new List<Contract_Line_Item__c>();
            List<Contract_Line_Option__c> clo = new  List<Contract_Line_Option__c>();
            clo = [SELECT Id, Name, Product__c, ContractId__c, Contract_Line_Item__c,Unique_Id__c From Contract_Line_Option__c where ContractId__c =: conDetail.Id ];            
            List<Contract_Line_Option__c> newClo = new  List<Contract_Line_Option__c>();
            
            map<String,Contract_Line_Item__c> mapConLineItem = new map<String,Contract_Line_Item__c>();
            for(Contract_Line_Item__c contCli:cli){
                mapConLineItem.put(contCli.Quote_Line_Item_Name__c,contCli);
            }
            
            
            map<String,Contract_Line_Option__c> mapConLineOptn = new map<String,Contract_Line_Option__c>();
            for(Contract_Line_Option__c contLinOp:clo){
                mapConLineOptn.put(contLinOp.Unique_Id__c,contLinOp);
            }
            
            
            
            
            
            
            
            /*Set<Id> cliMatchFound = new Set<Id>();
Set<Id> qliMatchFound = new Set<Id>();*/
            
            
            for(Quote_Line_Item_Custom__c ql : qli){//Quote line item
                
                
                if(mapConLineItem.containsKey(ql.id)){  //If contract Line Item update
                    Contract_Line_Item__c cl = new Contract_Line_Item__c();
                    cl.Id = mapConLineItem.get(ql.id).Id;
                    
                    
                    
                    cl.UOM__c = ql.UOM__c; 
                    cl.Model__c = ql.Product__r.Model__c;
                    cl.Product_Type__c = ql.Product__r.Product_Type__c;
                    cl.Level_Of_Ceiling__c=ql.Level_Of_Ceiling__c; 
                    if(ql.Product__c !=null){
                        cl.Product2Id__c = ql.Product__c;
                    }
                    if(ql.Application__c !=null && ql.Application__c !=''){ 
                        cl.Application__c = ql.Application__c; 
                    }
                    if(ql.Mach_Mold_No__c !=null){ 
                        cl.Mach_Mold_No__c = ql.Mach_Mold_No__c; 
                    }
                    if(ql.Level_Of_Ceiling__c !=null){ 
                        cl.Level_Of_Ceiling__c = ql.Level_Of_Ceiling__c; 
                    }
                    if(ql.Expected_Delivery_date__c !=null){ 
                        cl.Expected_Delivery_date__c = ql.Expected_Delivery_date__c; 
                    }
                    if(ql.Expected_Customer_PO__c !=null){ 
                        cl.Expected_Customer_PO__c = ql.Expected_Customer_PO__c; 
                    }
                    if(ql.Expected_Drawing_Final__c !=null){ 
                        cl.Expected_Drawing_Final__c = ql.Expected_Drawing_Final__c; 
                    }
                    if(ql.Drawing_No__c !=null){ 
                        cl.Drawing_No__c = ql.Drawing_No__c; 
                    }
                    if(ql.Product_Description__c !=null){ 
                        cl.Product_Description__c = ql.Product_Description__c; 
                    }
                    cl.Scope__c = ql.Product__r.Scope_of_Mold__c;
                    cl.Cavity__c = ql.Product__r.Number_Of_Cavity_Mould__c;
                    if(ql.Payment_Terms__c !=null){ 
                        cl.Payment_Terms__c = ql.Payment_Terms__c; 
                    }
                    if(ql.Discount_Allowed__c !=null){ 
                        cl.Discount_Allowed__c = ql.Discount_Allowed__c; 
                    } 
                    if(ql.Product_Name__c !=null){ 
                        cl.Product_Name_2__c = ql.Product_Name__c; 
                    } 
                    if(ql.Discount_Approval_Note__c !=null){ 
                        cl.Approval_Note__c = ql.Discount_Approval_Note__c; 
                    } 
                    else{
                        cl.Approval_Note__c = 'Null';
                    }
                    if(ql.Zero_Cooling_2__c !=null){ 
                        cl.Zero_Cooling__c = ql.Zero_Cooling_2__c; 
                    }
                    if(ql.Class_2__c !=null){ 
                        cl.Class__c = ql.Class_2__c; 
                    }
                    if(ql.MFG_AT__c !=null){ 
                        cl.MFG_Location__c = ql.MFG_AT__c; 
                    }                        
                    if(ql.List_Price__c!=null){
                        cl.List_Price__c = ql.List_Price__c; 
                    }
                   /* if(ql.Base_Price__c!=null){
                        cl.Base_Price_Line_Item__c = ql.Base_Price__c; 
                    }*/
                    if(ql.Advance_Percentage__c!=null){
                        cl.Advance_Required__c = ql.Advance_Percentage__c; 
                    }
                    if(ql.List_Price__c!=null){
                        cl.List_Price_Clone__c = ql.List_Price__c; 
                    }
                    if(ql.Quantity__c!=null){
                        cl.Quantity__c = ql.Quantity__c; 
                    }
                    if(ql.Quantity__c!=null){
                        cl.Quantity_Clone__c = ql.Quantity__c; 
                    }
                    if(ql.division__c !=null){
                        cl.division__c = ql.division__c; 
                    }
                    if(ql.Discount__c!=null){
                        cl.Discount__c = ql.Discount__c; 
                    }
                    if(ql.Discount__c!=null){
                        cl.Discount_Clone__c = ql.Discount__c; 
                    }
                    newClis.add(cl);
                    
                }
                else {
                    // Create new Contract line item
                    Contract_Line_Item__c cl = new Contract_Line_Item__c();
                    cl.Quote_Line_Item_Name__c = ql.Id;
                    
                    cl.ContractId__c = conDetail.Id;
                    cl.UOM__c = ql.UOM__c; 
                    cl.Model__c = ql.Product__r.Model__c;
                    cl.Product_Type__c = ql.Product__r.Product_Type__c;
                    cl.Level_Of_Ceiling__c=ql.Level_Of_Ceiling__c;
                    if(ql.Product__c !=null){
                        cl.Product2Id__c = ql.Product__c;
                    }
                    if(ql.Application__c !=null && ql.Application__c !=''){ 
                        cl.Application__c = ql.Application__c; 
                    }
                    if(ql.Mach_Mold_No__c !=null){ 
                        cl.Mach_Mold_No__c = ql.Mach_Mold_No__c; 
                    }
                    if(ql.Level_Of_Ceiling__c !=null){ 
                        cl.Level_Of_Ceiling__c = ql.Level_Of_Ceiling__c; 
                    }
                    if(ql.Expected_Delivery_date__c !=null){ 
                        cl.Expected_Delivery_date__c = ql.Expected_Delivery_date__c; 
                    }
                    if(ql.Expected_Customer_PO__c !=null){ 
                        cl.Expected_Customer_PO__c = ql.Expected_Customer_PO__c; 
                    }
                    if(ql.Expected_Drawing_Final__c !=null){ 
                        cl.Expected_Drawing_Final__c = ql.Expected_Drawing_Final__c; 
                    }
                    if(ql.Drawing_No__c !=null){ 
                        cl.Drawing_No__c = ql.Drawing_No__c; 
                    }
                    if(ql.Product_Description__c !=null){ 
                        cl.Product_Description__c = ql.Product_Description__c; 
                    }
                    cl.Scope__c = ql.Product__r.Scope_of_Mold__c;
                    cl.Cavity__c = ql.Product__r.Number_Of_Cavity_Mould__c;
                    if(ql.Payment_Terms__c !=null){ 
                        cl.Payment_Terms__c = ql.Payment_Terms__c; 
                    }
                    if(ql.Discount_Allowed__c !=null){ 
                        cl.Discount_Allowed__c = ql.Discount_Allowed__c; 
                    } 
                    if(ql.Product_Name__c !=null){ 
                        cl.Product_Name_2__c = ql.Product_Name__c; 
                    } 
                    if(ql.Discount_Approval_Note__c !=null){ 
                        cl.Approval_Note__c = ql.Discount_Approval_Note__c; 
                    } 
                    else{
                        cl.Approval_Note__c = 'Null';
                    }
                    if(ql.Zero_Cooling_2__c !=null){ 
                        cl.Zero_Cooling__c = ql.Zero_Cooling_2__c; 
                    }
                    if(ql.Class_2__c !=null){ 
                        cl.Class__c = ql.Class_2__c; 
                    }
                    if(ql.MFG_AT__c !=null){ 
                        cl.MFG_Location__c = ql.MFG_AT__c; 
                    }                        
                    if(ql.List_Price__c!=null){
                        cl.List_Price__c = ql.List_Price__c; 
                    }
                    /*if(ql.Base_Price__c!=null){
                        cl.Base_Price_Line_Item__c = ql.Base_Price__c; 
                    }*/
                    if(ql.Advance_Percentage__c!=null){
                        cl.Advance_Required__c = ql.Advance_Percentage__c; 
                    }
                    if(ql.List_Price__c!=null){
                        cl.List_Price_Clone__c = ql.List_Price__c; 
                    }
                    if(ql.Quantity__c!=null){
                        cl.Quantity__c = ql.Quantity__c; 
                    }
                    if(ql.Quantity__c!=null){
                        cl.Quantity_Clone__c = ql.Quantity__c; 
                    }
                    if(ql.division__c !=null){
                        cl.division__c = ql.division__c; 
                    }
                    if(ql.Discount__c!=null){
                        cl.Discount__c = ql.Discount__c; 
                    }
                    if(ql.Discount__c!=null){
                        cl.Discount_Clone__c = ql.Discount__c; 
                    }
                    
                    newClis.add(cl);
                    
                }
                
                
                
            }//end Quote line item loop
            
            upsert newClis;  //Con
            //cli = [SELECT Id, Name, Product2Id__c, ContractId__c, Quote_Line_Item_Name__c From Contract_Line_Item__c where ContractId__c =: conDetail.Id ];            
            for(Contract_Line_Item__c contCli:newClis){
                mapConLineItem.put(contCli.Quote_Line_Item_Name__c,contCli);
            }
            
            for(Quote_Line_Options__c qlo : quoteLineOpt){
                Contract_Line_Option__c ContLO= new Contract_Line_Option__c();
                if(mapConLineOptn.containsKey(qlo.Unique_Id__c)) {
                    contLo.id=mapConLineOptn.get(qlo.Unique_Id__c).id;
                    if(qlo.Discount__c != null){
                        ContLO.Discount__c = qlo.Discount__c;
                    }
                    if(qlo.Description__c != null){
                        ContLO.Product_Description__c = qlo.Description__c;
                    }
                    if(qlo.Price_Type__c != null){
                        ContLO.Price_Type__c = qlo.Price_Type__c;
                    }
                    if(qlo.Sales_price_Total__c != null){
                        ContLO.Sales_price_Total__c = qlo.Sales_price_Total__c;
                    }
                    if(qlo.Discount_Description__c != null){
                        ContLO.Discount_Description__c = qlo.Discount_Description__c;
                    }
                    else{
                        ContLO.Discount_Description__c = 'Null';
                    }
                    if(qlo.Manual_Option__c !=null){
                        ContLO.Manual_Option__c = qlo.Manual_Option__c;
                    }
                    if(qlo.Mould_Cavity__c !=null){
                        ContLO.Mould_Cavity__c = qlo.Mould_Cavity__c;
                    }
                    if(qlo.Manual_Product_Name__c !=null){
                        ContLO.Option_Name__c = qlo.Manual_Product_Name__c;
                    }
                    if(qlo.Manual_Option_Function__c !=null){
                        ContLO.Manual_Option_Function__c = qlo.Manual_Option_Function__c;
                    }
                    if(qlo.Other_Charges__c !=null){
                        ContLO.Other_Charges__c = qlo.Other_Charges__c;
                    }
                    if(qlo.Other_Charges_Base_Price__c !=null){
                        ContLO.Other_Charges_Base_Price__c = qlo.Other_Charges_Base_Price__c;
                    }
                    if(qlo.Quantity__c !=null){
                        ContLO.Quantity__c = qlo.Quantity__c;
                    }
                    if(qlo.Option_Number__c !=null){
                        ContLO.Contract_Line_Option_No__c = qlo.Option_Number__c;
                    }
                    if(qlo.Other_Charges_Function__c !=null){
                        ContLO.Other_Charges_Function__c = qlo.Other_Charges_Function__c;
                    }
                    if(qlo.Product__c !=null){
                        ContLO.Product__c = qlo.Product__c;
                    }
                    if(qlo.Select_Option__c !=null){
                        ContLO.Select_Option__c = qlo.Select_Option__c;
                    }
                 /*   if(qlo.Manual_Option_Base_Price__c !=null){
                        ContLO.Manual_Option_Base_Price_Clone__c = qlo.Manual_Option_Base_Price__c;
                    }
                    if(qlo.Manula_Option_List_Price__c !=null){
                        ContLO.Manual_Option_List_Price_Clone__c = qlo.Manula_Option_List_Price__c;
                    }*/
                    if(qlo.Discount__c !=null){
                        ContLO.Discount_Clone__c = qlo.Discount__c;
                    }
                    System.debug('newClo1====>'+ContLO);
                   // if(!newClo.contains(ContLO))
                        newClo.add(ContLO);
                }
                else{
                    
                    // Create new Contract line option
                    // Contract_Line_Option__c ContLO = new Contract_Line_Option__c();
                    ContLO.ContractId__c = conDetail.Id;
                    ContLO.Contract_Line_Item__c = mapConLineItem.get(qlo.Quote_Line_Item__c).id;
                    if(qlo.Discount__c != null){
                        ContLO.Discount__c = qlo.Discount__c;
                    }
                    if(qlo.Description__c != null){
                        ContLO.Product_Description__c = qlo.Description__c;
                    }
                    if(qlo.Price_Type__c != null){
                        ContLO.Price_Type__c = qlo.Price_Type__c;
                    }
                    if(qlo.Sales_price_Total__c != null){
                        ContLO.Sales_price_Total__c = qlo.Sales_price_Total__c;
                    }
                    if(qlo.Discount_Description__c != null){
                        ContLO.Discount_Description__c = qlo.Discount_Description__c;
                    }
                    else{
                        ContLO.Discount_Description__c = 'Null';
                    }
                    if(qlo.Manual_Option__c !=null){
                        ContLO.Manual_Option__c = qlo.Manual_Option__c;
                    }
                    if(qlo.Mould_Cavity__c !=null){
                        ContLO.Mould_Cavity__c = qlo.Mould_Cavity__c;
                    }
                    if(qlo.Manual_Product_Name__c !=null){
                        ContLO.Option_Name__c = qlo.Manual_Product_Name__c;
                    }
                    if(qlo.Manual_Option_Function__c !=null){
                        ContLO.Manual_Option_Function__c = qlo.Manual_Option_Function__c;
                    }
                    if(qlo.Other_Charges__c !=null){
                        ContLO.Other_Charges__c = qlo.Other_Charges__c;
                    }
                    if(qlo.Other_Charges_Base_Price__c !=null){
                        ContLO.Other_Charges_Base_Price__c = qlo.Other_Charges_Base_Price__c;
                    }
                    if(qlo.Quantity__c !=null){
                        ContLO.Quantity__c = qlo.Quantity__c;
                    }
                    if(qlo.Option_Number__c !=null){
                        ContLO.Contract_Line_Option_No__c = qlo.Option_Number__c;
                    }
                    if(qlo.Other_Charges_Function__c !=null){
                        ContLO.Other_Charges_Function__c = qlo.Other_Charges_Function__c;
                    }
                    if(qlo.Product__c !=null){
                        ContLO.Product__c = qlo.Product__c;
                    }
                    if(qlo.Select_Option__c !=null){
                        ContLO.Select_Option__c = qlo.Select_Option__c;
                    }
                   /* if(qlo.Manual_Option_Base_Price__c !=null){
                        ContLO.Manual_Option_Base_Price_Clone__c = qlo.Manual_Option_Base_Price__c;
                    }*/
                   /* if(qlo.Manula_Option_List_Price__c !=null){
                        ContLO.Manual_Option_List_Price_Clone__c = qlo.Manula_Option_List_Price__c;
                    }*/
                    if(qlo.Discount__c !=null){
                        ContLO.Discount_Clone__c = qlo.Discount__c;
                    }
                    System.debug('newClo2====>'+ContLO);
                    // if(!newClo.contains(ContLO))
                    newClo.add(ContLO);
                    
                }
            }//end of Quote lin custom 
            
            
            
            System.debug('newClo====>'+newClo);
            
            upsert newClo;
            //delete cliToDelete;
            
            conDetail.Status = 'RELEASED';
            update conDetail;
            
            RecordType qRec= [select Id,Name from RecordType where sObjectType='Quote' And Name='After Released Locked' limit 1];
            
            quote.Status = 'CLOSE - SC CREATED';
            quote.RecordTypeId=qRec.id;
            update quote;
            
            
        }
        PageReference myVFPage = new PageReference('/'+quoteID);
        myVFPage.setRedirect(true);
        return myVFPage;
    }
    
}