public class ContractSummaryCompControllerApex {
   
        @AuraEnabled 
    public static Contract getContractDetail(String ContractID){
        	Contract qt =  [Select Id, Is_DTA_Contract__c,Sales_Margin_Percent__c from Contract where Id=: ContractID limit 1];
        	return qt;
        }
    
    @AuraEnabled
    Public Static List<Contract_Line_Item__c> FetchdataWrapper(String ContractID, string orderby){
        System.debug('ContractID'+ContractID);
        System.debug('orderby'+orderby);
        List<Contract_Line_Item__c> lstData = new List<Contract_Line_Item__c>();
        string query ='';
          query+= 'Select id,name,CurrencyIsoCode,Sr_No__c,Product_Name__c,Product_Number__c,Manual_Product_Number__c,Base_Price_Line_Item__c,Product_Name_2__c,Total_Sales_Price2__c,'+
                   'List_Price__c,Discount_in_Value_Percent__c,Average_Discount_Value__c,Average_Sales_Price__c,Is_Manual__c,Quantity__c,Total_Sales_Price__c,Sales_Margin_Percent__c,'+
                  'Sales_Margin_including_Options__c,('+
                       'Select id,name,Option_Name__c,CurrencyIsoCode,Serial_Number__c,Select_Option__c,Product_Code__c,Product_Name__c,Manual_Option_Number__c,Product_Number__c,'+
                       ' Average_Discount_Value__c,Discount_in_Value_Percent__c,Average_Sales_Price__c,Quantity__c,Final_Sales_Price__c,Sales_Margin_Percent__c,Manual_Option_Base_Price__c,Manual_Option_List_Price__c'+
                       ' from Contract_Line_Option__r ORDER BY Serial_Number__c'+
                   ') from Contract_Line_Item__c where ContractId__c =\''+ContractID+'\' ORDER BY Sr_No__c ' + orderby + ' NULLS LAST ';

        lstData = database.query(query);
        
        System.debug('lstData'+lstData.size());
      
        return lstData;
        
        
    }
    
    
     @AuraEnabled
    public static void exportCSV(string cId){
        string QuoteName = '';
        string query ='';
           Contract qt =  [Select Id, Is_DTA_Contract__c,Sales_Margin_Percent__c from Contract where Id=: cId limit 1];

        List<Contract_Line_Item__c> lstData = new List<Contract_Line_Item__c>();
          query+= 'Select id,name,CurrencyIsoCode,Sr_No__c,Product_Name__c,Product_Number__c,Manual_Product_Number__c,Is_Manual__c,Base_Price_Line_Item__c,Product_Name_2__c,Total_Sales_Price2__c,'+
                   'List_Price__c,Discount_in_Value_Percent__c,Average_Discount_Value__c,Average_Sales_Price__c,Quantity__c,Total_Sales_Price__c,Sales_Margin_Percent__c,Discount_Value__c,'+
                  'ContractId__r.Contract_Number__c,ContractId__r.QU_Revise_Number__c,'+
                   'Sales_Margin_including_Options__c,('+
                       'Select id,name,Option_Name__c,CurrencyIsoCode,Serial_Number__c,Select_Option__c,Product_Code__c,Sales_Price__c,Product_Name__c,Manual_Option_Number__c,Product_Number__c,Manual_Product_Name_c__c	,'+
                       ' Average_Discount_Value__c,Discount_in_Value_Percent__c,Average_Sales_Price__c,Quantity__c,Final_Sales_Price__c,Manual_Option_Base_Price__c,Sales_Margin_Percent__c,Manual_Option_List_Price__c'+
                       ' from Contract_Line_Option__r ORDER BY Serial_Number__c'+
                   ') from Contract_Line_Item__c where ContractId__c =\''+cId+'\'';

        lstData = database.query(query);
       
        decimal  totalBasicPrice = 0;
                    decimal  totalListPrice = 0;
                    decimal totalQuantity = 0;
                    decimal totalAvgDiscount = 0;
                    decimal totalFinalSales = 0;
                    decimal totalSalesPrice = 0;
                    decimal discount_total = 0;
         decimal salesMargin = qt.Sales_Margin_Percent__c !=null? qt.Sales_Margin_Percent__c : 0;

        List<string> tempExcelData = new List<string>();
        tempExcelData.add('I.sno'+',');
        tempExcelData.add('O.sno'+',');
        tempExcelData.add('Product Name'+',');
        tempExcelData.add('Product Code'+',');
         if(!qt.Is_DTA_Contract__c){
        tempExcelData.add('Unit Base Price'+',');
         }
        tempExcelData.add('Unit List Price'+',');
        
        /*tempExcelData.add('Total List price'+',');
        tempExcelData.add('DISCOUNT'+',');
*/      
        tempExcelData.add('Unit Discount Percentage'+',');
        tempExcelData.add('Unit Discount Value'+',');
        tempExcelData.add('Unit Sales Price'+',');
        tempExcelData.add('Qty'+',');
        tempExcelData.add('Total Sales Price'+',');
        tempExcelData.add('Sales Margin'+',');
        tempExcelData.add('\n');
        integer j = 0;
          
        
        for(Contract_Line_Item__c qlc: lstData){
            
            
            QuoteName = qlc.ContractId__r.Contract_Number__c; 
            
            if(Integer.valueOf(qlc.ContractId__r.QU_Revise_Number__c) > 0){
                QuoteName+= '-'+qlc.ContractId__r.QU_Revise_Number__c;
            }
            j++;
            
            if(qlc.Sr_No__c != null)
                tempExcelData.add(qlc.Sr_No__c+',');
            else 
                tempExcelData.add(' '+',');
            
            tempExcelData.add(' '+',');
            if(qlc.Product_Name_2__c != null)
            tempExcelData.add(qlc.Product_Name_2__c+',');
            else 
                    tempExcelData.add(' '+',');
            
            if(qlc.Product_Number__c != null && !qlc.Is_Manual__c)
                tempExcelData.add(qlc.Product_Number__c+',');
            else 
                if(qlc.Manual_Product_Number__c != null && qlc.Is_Manual__c)
                tempExcelData.add(qlc.Manual_Product_Number__c+',');
            else 
                tempExcelData.add(' '+',');
            
            
            if(!qt.Is_DTA_Contract__c){
            if(qlc.Base_Price_Line_Item__c != null)
            tempExcelData.add(string.valueOf(qlc.Base_Price_Line_Item__c)+',');
            else 
                    tempExcelData.add(' '+',');
            }
            
            if(qlc.List_Price__c != null)
            tempExcelData.add(string.valueOf(qlc.List_Price__c)+',');
            else 
                    tempExcelData.add(' '+',');
            
            
            
            
           /* if(qlc.List_Price__c != null)
            tempExcelData.add(string.valueOf(qlc.List_Price__c * qlc.Quantity__c)+',');
            else 
                    tempExcelData.add(' '+',');
            
            if(qlc.Discount__c != null)
            tempExcelData.add(string.valueOf(qlc.Discount__c)+',');
            else 
                    tempExcelData.add(' '+',');
            */
            if(qlc.Discount_Value__c != null)
            tempExcelData.add(string.valueOf(qlc.Discount_in_Value_Percent__c)+',');
            else 
                 tempExcelData.add(' '+',');
            if(qlc.Discount_Value__c != null)
            tempExcelData.add(string.valueOf(qlc.Average_Discount_Value__c)+',');
            else 
                 tempExcelData.add(' '+',');
            if(qlc.Average_Sales_Price__c != null)
                tempExcelData.add(string.valueOf(qlc.Average_Sales_Price__c)+',');
            else 
                tempExcelData.add(' '+',');
            
            if(qlc.Quantity__c != null)
            tempExcelData.add(string.valueOf(qlc.Quantity__c)+',');
            else 
                    tempExcelData.add(' '+',');
            
            if(qlc.Total_Sales_Price2__c != null)
                tempExcelData.add(string.valueOf(qlc.Total_Sales_Price2__c)+',');
            else 
                tempExcelData.add(' '+',');
            
            if(qlc.Sales_Margin_Percent__c != null)
                tempExcelData.add(string.valueOf(qlc.Sales_Margin_Percent__c)+'%'+',');
            else 
                tempExcelData.add(' '+',');
            //tempExcelData.add(string.valueOf(qlc.Ceiling_Total_Sales_Price__c)+',');
            tempExcelData.add('\n');
            integer i = 0;
             
            system.debug('size'+qlc.Contract_Line_Option__r.size());
            decimal sub_totalBasicPrice = 0;
                     decimal sub_totalListPrice = 0;
                    decimal sub_totalQuantity = 0;
                    decimal sub_totalAvgDiscount = 0;
                    decimal sub_totalFinalSales = 0;
                    decimal sub_totalSalesPrice = 0;
                     decimal sub_Margin = qlc.Sales_Margin_including_Options__c !=null? qlc.Sales_Margin_including_Options__c : 0;

            sub_totalBasicPrice += qlc.Base_Price_Line_Item__c != null ? qlc.Base_Price_Line_Item__c : 0;
            sub_totalListPrice += qlc.List_Price__c != null ? qlc.List_Price__c : 0;
            sub_totalQuantity += qlc.Quantity__c != null ? qlc.Quantity__c : 0;
            sub_totalAvgDiscount += qlc.Average_Discount_Value__c != null ? qlc.Average_Discount_Value__c : 0;
            sub_totalFinalSales += qlc.Average_Sales_Price__c != null ? qlc.Average_Sales_Price__c : 0;
            sub_totalSalesPrice += qlc.Total_Sales_Price2__c != null ? qlc.Total_Sales_Price2__c : 0;
                
            for(Contract_Line_Option__c qlo: qlc.Contract_Line_Option__r){
                
                
                sub_totalBasicPrice += qlo.Manual_Option_Base_Price__c != null ? qlo.Manual_Option_Base_Price__c : 0;
                sub_totalListPrice += qlo.Manual_Option_List_Price__c != null ? qlo.Manual_Option_List_Price__c : 0;
                //sub_totalQuantity += qlo.Quantity__c != null ? qlo.Quantity__c : 0;
                sub_totalAvgDiscount += qlo.Average_Discount_Value__c != null ? qlo.Average_Discount_Value__c : 0;
                sub_totalFinalSales += qlo.Final_Sales_Price__c != null ? qlo.Final_Sales_Price__c : 0;
                sub_totalSalesPrice += qlo.Final_Sales_Price__c != null ? qlo.Final_Sales_Price__c : 0;
                discount_total += qlo.Discount_in_Value_Percent__c != null ? qlo.Discount_in_Value_Percent__c : 0;
                
                i++;
                system.debug('inside for'+i);
                tempExcelData.add(' '+',');
                if(qlc.Sr_No__c != null)
                    tempExcelData.add(qlo.Serial_Number__c+',');
                else 
                    tempExcelData.add(' '+',');
               
                if(qlo.Option_Name__c	 != null)
                   tempExcelData.add(qlo.Option_Name__c	+',');
                else
                  tempExcelData.add(' '+',');
                
                if(qlo.Product_Code__c != null && !qlo.Select_Option__c)
                tempExcelData.add(qlo.Product_Code__c+',');
                else
                    if(qlo.Manual_Option_Number__c != null && qlo.Select_Option__c)
                tempExcelData.add(qlo.Manual_Option_Number__c+',');
                else
                  tempExcelData.add(' '+',');
                
                if(!qt.Is_DTA_Contract__c){
                if(qlo.Manual_Option_Base_Price__c != null)
                   tempExcelData.add(string.valueOf(qlo.Manual_Option_Base_Price__c)+',');
                else
                  tempExcelData.add(' '+',');
                }
                
                
                if(qlo.Manual_Option_List_Price__c != null)
                   tempExcelData.add(string.valueOf(qlo.Manual_Option_List_Price__c)+',');
                else
                  tempExcelData.add(' '+',');
                
                
                
              /*  if(qlo.Manula_Option_List_Price__c != null)
                    tempExcelData.add(string.valueOf(qlo.Manula_Option_List_Price__c * qlo.Quantity__c)+',');
                 else
                     tempExcelData.add(string.valueOf(0+','));
                
                if(qlo.Manula_Option_List_Price__c != null)
                     tempExcelData.add(string.valueOf(qlo.Discount__c)+',');
                else
                     tempExcelData.add(string.valueOf(0+','));
                */
                if(qlo.Manual_Option_List_Price__c != null)
                      tempExcelData.add(string.valueOf(qlo.Discount_in_Value_Percent__c)+',');
                else
                     tempExcelData.add(string.valueOf(0+','));
                if(qlo.Manual_Option_List_Price__c != null)
                      tempExcelData.add(string.valueOf(qlo.Average_Discount_Value__c)+',');
                else
                     tempExcelData.add(string.valueOf(0+','));
                
                if(qlo.Manual_Option_List_Price__c != null)
                       tempExcelData.add(string.valueOf(qlo.Average_Sales_Price__c)+',');
                else
                     tempExcelData.add(string.valueOf(0+','));
                
                if(qlo.Quantity__c != null)
                     tempExcelData.add(string.valueOf(qlo.Quantity__c)+',');
                else
                  tempExcelData.add(' '+',');
                
                if(qlo.Final_Sales_Price__c != null)
                       tempExcelData.add(string.valueOf(qlo.Final_Sales_Price__c)+',');
                else
                     tempExcelData.add(string.valueOf(0+','));
                
               if(qlo.Sales_Margin_Percent__c != null)
                tempExcelData.add(string.valueOf(qlo.Sales_Margin_Percent__c)+'%'+',');
               else 
                tempExcelData.add(' '+',');
               
                tempExcelData.add('\n');
                
            }
            
            totalBasicPrice += sub_totalBasicPrice;
                totalListPrice += sub_totalListPrice;
                totalQuantity += sub_totalQuantity;
                totalAvgDiscount += sub_totalAvgDiscount;
                totalFinalSales += sub_totalFinalSales;
                totalSalesPrice += sub_totalSalesPrice;
            
              if(qlc.Contract_Line_Option__r.size() > 0){
            tempExcelData.add(' '+',');
            tempExcelData.add(' '+',');
            tempExcelData.add('Sub Total '+',');
            tempExcelData.add(' '+',');
            if(!qt.Is_DTA_Contract__c)
            tempExcelData.add(sub_TotalBasicPrice+',');
            tempExcelData.add(sub_totalListPrice+',');
            tempExcelData.add('-'+',');
            tempExcelData.add(sub_TotalAvgDiscount+',');
            tempExcelData.add(sub_TotalFinalSales+',');
            
            tempExcelData.add(sub_totalQuantity+',');
            tempExcelData.add(sub_totalSalesPrice+',');
           tempExcelData.add(sub_Margin+',');
                tempExcelData.add('\n');
            }
            
        }
        
        tempExcelData.add(' '+',');
            tempExcelData.add(' '+',');
            tempExcelData.add('Grand Total '+',');
            tempExcelData.add(' '+',');
            if(!qt.Is_DTA_Contract__c)
            tempExcelData.add(totalBasicPrice+',');
            tempExcelData.add(totalListPrice+',');
            tempExcelData.add('-'+',');
            tempExcelData.add(totalAvgDiscount+',');
            tempExcelData.add(totalFinalSales+',');
            
            tempExcelData.add(totalQuantity+',');
            tempExcelData.add(totalSalesPrice+',');
            tempExcelData.add(salesMargin+',');
        
                tempExcelData.add('\n');
        
        string temp1 ='';
        temp1 += String.join(tempExcelData,' ');
        tempExcelData.clear();
        tempExcelData.add(temp1);
        
        DateTime dt = DateTime.now();
        String dateTimeStr = dt.format('ddMMyyhhmm');
            ContentVersion cv = new ContentVersion();
            blob b = blob.valueOf(string.join(tempExcelData,''));
            cv.VersionData = b;
            cv.Title = QuoteName+'-'+dateTimeStr+'.csv';
            cv.PathOnClient = QuoteName+'.csv';
            system.debug('title'+cv.Title);
            insert cv;
            
            
            //Link the File to Parent Record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId, contentDocument.LatestPublishedVersionId  FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = cId;
            cdl.ShareType = 'V';
            insert cdl;
    }

}