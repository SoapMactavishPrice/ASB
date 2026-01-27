public class QuoteSummaryCompControllerApex {
    
    @AuraEnabled 
    public static Quote getQuoteDetail(String QuotationID){
        	Quote qt =  [Select Id, Is_DTA_Quote__c,Sales_Margin__c,Status from Quote where Id=: QuotationID limit 1];
        	return qt;
        }
    
    @AuraEnabled
    Public Static List<Quote_Line_Item_Custom__c> FetchdataWrapper(String QuotationID, string orderby){
        System.debug('QuotationID'+QuotationID);
        System.debug('QuotationID'+orderby);
        List<Quote_Line_Item_Custom__c> lstData = new List<Quote_Line_Item_Custom__c>();
        string query ='';
        Decimal quantity = 0;
          query+= 'Select id,name,Advance_Percentage__c,CurrencyIsoCode,Sr_No__c,Application__c,Average_Discount_Value__c,Average_Sales_Price__c,Approval_Status__c,Cavity__c,Ceiling_Total_Sales_Price__c,Class_2__c,Class__c,Discount__c,'+
                   'Discount_Allowed__c,Discount_Allowed_New__c,Discount_Approval_Note__c,Discount_Earlier__c,Division__c,Drawing_No__c,Expected_Customer_PO__c,Expected_Delivery__c,'+
                   'Expected_Delivery_date__c,Expected_Drawing_Final__c,Base_Price__c,BP_Ratio_Line_Item__c,Is_Discount_Changes_Allow__c,Is_Manual__c,'+
                   'Level_Of_Ceiling__c,Line_Item_Id__c,List_Price__c,Mach_Mold_No__c,MFG_AT__c,MFG__c,Model__c,Overall_Discount__c,Payment_Terms__c,Product__c,'+
                   'Product_Code__c,Product_Name__c,Product_Type__c,Quantity__c,Quote__c,Quote_No__c,Sales_Price__c,Sales_price_Options__c,Product_Description__c,'+
                   'Scope_of_mould__c,Total_Base_Price__c,Discount_in_Value_Percent__c,Total_Base_Price_Options__c,Total_List_Price__c,Total_List_Price_options__c,Total_Sales_Price__c,'+
                   'UOM__c,User_Level__c,Zero_Cooling_2__c,Zero_Cooling__c,Sales_Margin_including_Options__c, Discount_Value__c,Manual_Product_Code__c,Discount_in_Value__c,Sales_Margin__c,'+
                   '('+
                       'Select id,name,Discount__c,Discount_Allowed__c,Discount_in_Value_Percent__c,CurrencyIsoCode,Discount_Allowed_New__c,Serial_Number__c,Average_Discount_Value__c,Average_Sales_Price__c,Discount_Description__c,Sales_Margin__c,Discount_Earlier__c,Discount_in_Value__c,Final_Price__c,Final_price_Ceiling__c, Final_Sales_Price__c,'+
                       'Base_price_Total__c,List_Price_Quantity__c,Select_Option__c,Manual_Option__c,Manual_Option_Function__c,Mould_Cavity__c,Manual_Product_Name__c,'+
                       'Option_No__c,Option_Number__c,Option_Product_Code__c,Option_Type__c,Other_Charges__c,Other_Charges_Function__c,Other_Charges_Base_Price__c,'+
                      ' Price__c,Price_Type__c,Product__c,Description__c,Product_Name__c,Product_Number__c,Quantity__c,Quantity_Line_Item__c,Quote__c,Quote_Line_Item__c,'+
                       'Quote_Line_Item_Custom__c,Quote_No__c,Sales_Price__c,Sales_Price_Clone__c,Sales_price_Total__c,Manual_Option_Base_Price__c,Manula_Option_List_Price__c,'+
                       'UOM_2__c,UOM__c,User_Level__c,Manual_Product_Code__c, Discount_Value__c from Quote_Line_Options__r ORDER BY Serial_Number__c'+
                   ') from Quote_Line_Item_Custom__c where Quote__c =\''+QuotationID+'\' and Quantity__c >: quantity ORDER BY Sr_No__c ' + orderby + ' NULLS LAST ';

        lstData = database.query(query);
        /*lstData = [Select id,name,Advance_Percentage__c,Sr_No__c,Application__c,Approval_Status__c,Cavity__c,Ceiling_Total_Sales_Price__c,Class_2__c,Class__c,Discount__c,
                   Discount_Allowed__c,Discount_Approval_Note__c,Discount_Earlier__c,Division__c,Drawing_No__c,Expected_Customer_PO__c,Expected_Delivery__c,
                   Expected_Delivery_date__c,Expected_Drawing_Final__c,Base_Price__c,BP_Ratio_Line_Item__c,Is_Discount_Changes_Allow__c,Is_Manual__c,
                   Level_Of_Ceiling__c,Line_Item_Id__c,List_Price__c,Mach_Mold_No__c,MFG_AT__c,MFG__c,Model__c,Overall_Discount__c,Payment_Terms__c,Product__c,
                   Product_Code__c,Product_Name__c,Product_Type__c,Quantity__c,Quote__c,Quote_No__c,Sales_Price__c,Sales_price_Options__c,Product_Description__c,
                   Scope_of_mould__c,Total_Base_Price__c,Total_Base_Price_Options__c,Total_List_Price__c,Total_List_Price_options__c,Total_Sales_Price__c,
                   UOM__c,User_Level__c,Zero_Cooling_2__c,Zero_Cooling__c, Discount_Value__c,Discount_in_Value__c,
                   
                   (
                       Select id,name,Discount__c,Discount_Allowed__c,Discount_Description__c,Discount_Earlier__c,Discount_in_Value__c,Final_Price__c,Final_price_Ceiling__c, Final_Sales_Price__c,
                       Base_price_Total__c,List_Price_Quantity__c,Select_Option__c,Manual_Option__c,Manual_Option_Function__c,Mould_Cavity__c,Manual_Product_Name__c,
                       Option_No__c,Option_Number__c,Option_Product_Code__c,Option_Type__c,Other_Charges__c,Other_Charges_Function__c,Other_Charges_Base_Price__c,
                       Price__c,Price_Type__c,Product__c,Description__c,Product_Name__c,Product_Number__c,Quantity__c,Quantity_Line_Item__c,Quote__c,Quote_Line_Item__c,
                       Quote_Line_Item_Custom__c,Quote_No__c,Sales_Price__c,Sales_Price_Clone__c,Sales_price_Total__c,Manual_Option_Base_Price__c,Manula_Option_List_Price__c,
                       UOM_2__c,UOM__c,User_Level__c, Discount_Value__c from Quote_Line_Options__r ORDER BY Select_Option__c
                   )
                   from Quote_Line_Item_Custom__c where Quote__c =:QuotationID ORDER BY Sr_No__c DESC NULLS LAST];*/
        System.debug('lstData'+lstData.size());
      
        return lstData;
        
        
    }
    
    @AuraEnabled
    public static void exportCSV(string qId){
        string QuoteName = '';
        Quote qt =  [Select Id, Is_DTA_Quote__c,Sales_Margin__c from Quote where Id=: qId limit 1];
        List<Quote_Line_Item_Custom__c> lstData 
            = [Select id,name,Advance_Percentage__c,Sr_No__c,Application__c,Approval_Status__c,Cavity__c,Ceiling_Total_Sales_Price__c,Class_2__c,Class__c,Discount__c,
                   Discount_Allowed__c,Discount_Allowed_New__c,Discount_Approval_Note__c,Discount_Earlier__c,Division__c,Drawing_No__c,Expected_Customer_PO__c,Expected_Delivery__c,
                   Expected_Delivery_date__c,Expected_Drawing_Final__c,Base_Price__c,BP_Ratio_Line_Item__c,Is_Discount_Changes_Allow__c,Is_Manual__c,
                   Level_Of_Ceiling__c,Line_Item_Id__c,List_Price__c,Mach_Mold_No__c,MFG_AT__c,MFG__c,Model__c,Overall_Discount__c,Payment_Terms__c,Product__c,
                   Product_Code__c,Product_Name__c,Product_Type__c,Quantity__c,Quote__c,Quote_No__c,Sales_Price__c,Sales_price_Options__c,Product_Description__c,
                   Scope_of_mould__c,Total_Base_Price__c,Total_Base_Price_Options__c,Total_List_Price__c,Total_List_Price_options__c,Total_Sales_Price__c,
                   UOM__c,User_Level__c,Zero_Cooling_2__c,Zero_Cooling__c, Discount_Value__c,Sales_Margin__c,Quote__r.Is_DTA_Quote__c,
                   Quote__r.Quote_Number1__c,Average_Discount_Value__c,Average_Sales_Price__c,Manual_Product_Code__c,Discount_in_Value_Percent__c,Sales_Margin_including_Options__c,
                   (Select id,name,
                    Average_Discount_Value__c,Final_Sales_Price__c,Average_Sales_Price__c,Discount__c,Discount_in_Value_Percent__c,Serial_Number__c,Sales_Margin__c,Discount_Allowed__c,Discount_Description__c,Discount_Earlier__c,Final_Price__c,Final_price_Ceiling__c,
                    Base_price_Total__c,List_Price_Quantity__c,Select_Option__c,Manual_Option__c,Manual_Option_Function__c,Mould_Cavity__c,Manual_Product_Name__c,
                    Option_No__c,Option_Number__c,Option_Product_Code__c,Option_Type__c,Other_Charges__c,Other_Charges_Function__c,Other_Charges_Base_Price__c,
                    Price__c,Price_Type__c,Product__c,Description__c,Product_Name__c,Product_Number__c,Quantity__c,Quantity_Line_Item__c,Quote__c,Quote_Line_Item__c,
                    Quote_Line_Item_Custom__c,Quote_No__c,Sales_Price__c,Sales_Price_Clone__c,Sales_price_Total__c,Manual_Option_Base_Price__c,Manula_Option_List_Price__c,
                    UOM_2__c,UOM__c,User_Level__c,Manual_Product_Code__c, Discount_Value__c from Quote_Line_Options__r ORDER BY Serial_Number__c) from Quote_Line_Item_Custom__c where Quote__c =:qId and Quantity__c >: 0];
       
        List<string> tempExcelData = new List<string>();
        
        
        
             decimal  totalBasicPrice = 0;
                    decimal  totalListPrice = 0;
                    decimal totalQuantity = 0;
                    decimal totalAvgDiscount = 0;
                    decimal totalFinalSales = 0;
                    decimal totalSalesPrice = 0;
                    decimal discount_total = 0;
         decimal salesMargin = qt.Sales_Margin__c !=null? qt.Sales_Margin__c : 0;
        
        
        tempExcelData.add('I.sno'+',');
        tempExcelData.add('O.sno'+',');
        tempExcelData.add('Product Name'+',');
        tempExcelData.add('Product Code'+',');
        
        if(!qt.Is_DTA_Quote__c){
          tempExcelData.add('Unit Base Price'+',');
        }
        tempExcelData.add('Unit List Price'+',');
        
        /*tempExcelData.add('Total List price'+',');
        tempExcelData.add('DISCOUNT'+',');
*/        tempExcelData.add('Unit Discount(%)'+',');
        tempExcelData.add('Unit Discount Value'+',');
        tempExcelData.add('Unit Sales Price'+',');
        tempExcelData.add('Qty'+',');
        tempExcelData.add('Total Sales Price'+',');
        tempExcelData.add('Sales Margin'+',');
        tempExcelData.add('\n');
        integer j = 0;
        
          
                
        for(Quote_Line_Item_Custom__c qlc: lstData){
            
            decimal sub_totalBasicPrice = 0;
                     decimal sub_totalListPrice = 0;
                    decimal sub_totalQuantity = 0;
                    decimal sub_totalAvgDiscount = 0;
                    decimal sub_totalFinalSales = 0;
                    decimal sub_totalSalesPrice = 0;
            decimal sub_Margin = qlc.Sales_Margin_including_Options__c !=null ? qlc.Sales_Margin_including_Options__c : 0;
            
            
            sub_totalBasicPrice += qlc.Base_Price__c != null ? qlc.Base_Price__c : 0;
            sub_totalListPrice += qlc.List_Price__c != null ? qlc.List_Price__c : 0;
            sub_totalQuantity += qlc.Quantity__c != null ? qlc.Quantity__c : 0;
            sub_totalAvgDiscount += qlc.Average_Discount_Value__c != null ? qlc.Average_Discount_Value__c : 0;
            sub_totalFinalSales += qlc.Average_Sales_Price__c != null ? qlc.Average_Sales_Price__c : 0;
            sub_totalSalesPrice += qlc.Sales_Price__c != null ? qlc.Sales_Price__c : 0;

            
            
            QuoteName = qlc.Quote__r.Quote_Number1__c; 
            j++;
            if(qlc.Sr_No__c != null)
                tempExcelData.add(qlc.Sr_No__c+',');
            else 
                tempExcelData.add(' '+',');
            
            tempExcelData.add(' '+',');
            if(qlc.Product_Name__c != null)
            tempExcelData.add(qlc.Product_Name__c+',');
            else 
                    tempExcelData.add(' '+',');
            
            if(qlc.Product_Code__c != null && !qlc.Is_Manual__c)
                tempExcelData.add(qlc.Product_Code__c+',');
            else if(qlc.Manual_Product_Code__c != null && qlc.Is_Manual__c)
                tempExcelData.add(qlc.Manual_Product_Code__c+',');
            else 
                tempExcelData.add(' '+',');
            
            if(!qt.Is_DTA_Quote__c){
                if(qlc.Base_Price__c != null)
                    tempExcelData.add(string.valueOf(qlc.Base_Price__c)+',');
                else 
                    tempExcelData.add(' '+',');
            }
            if(qlc.List_Price__c != null)
                    tempExcelData.add(string.valueOf(qlc.List_Price__c)+',');
                else 
                    tempExcelData.add(' '+',');
            
           
            
            
           if(qlc.Discount_in_Value_Percent__c != null)
            tempExcelData.add(string.valueOf(qlc.Discount_in_Value_Percent__c)+'%'+',');
            else 
                    tempExcelData.add('0%'+',');
            
            /*if(qlc.Discount__c != null)
            tempExcelData.add(string.valueOf(qlc.Discount__c)+',');
            else 
                    tempExcelData.add(' '+',');
            */
            if(qlc.Discount_Value__c != null)
            tempExcelData.add(string.valueOf(qlc.Average_Discount_Value__c)+',');
            else 
                 tempExcelData.add(' '+',');
            if(qlc.Sales_Price__c != null)
                tempExcelData.add(string.valueOf(qlc.Average_Sales_Price__c)+',');
            else 
                tempExcelData.add(' '+',');
            
            if(qlc.Quantity__c != null)
            tempExcelData.add(string.valueOf(qlc.Quantity__c)+',');
            else 
                    tempExcelData.add(' '+',');
            
            if(qlc.Sales_Price__c != null)
                tempExcelData.add(string.valueOf(qlc.Sales_Price__c)+',');
            else 
                tempExcelData.add(' '+',');
            
            if(qlc.Sales_Margin__c != null)
                tempExcelData.add(string.valueOf(qlc.Sales_Margin__c)+'%'+',');
            else 
                tempExcelData.add(' '+',');
            //tempExcelData.add(string.valueOf(qlc.Ceiling_Total_Sales_Price__c)+',');
            tempExcelData.add('\n');
            integer i = 0;
             
            system.debug('size'+qlc.Quote_Line_Options__r.size());
            for(Quote_Line_Options__c qlo: qlc.Quote_Line_Options__r){
                
                
                
                sub_totalBasicPrice += qlo.Manual_Option_Base_Price__c != null ? qlo.Manual_Option_Base_Price__c : 0;
                sub_totalListPrice += qlo.Manula_Option_List_Price__c != null ? qlo.Manula_Option_List_Price__c : 0;
                //sub_totalQuantity += qlo.Quantity__c != null ? qlo.Quantity__c : 0;
                sub_totalAvgDiscount += qlo.Average_Discount_Value__c != null ? qlo.Average_Discount_Value__c : 0;
                sub_totalFinalSales += qlo.Final_Sales_Price__c != null ? qlo.Final_Sales_Price__c : 0;
                sub_totalSalesPrice += qlo.Sales_Price__c != null ? qlo.Sales_Price__c : 0;
                discount_total += qlo.Discount_in_Value_Percent__c != null ? qlo.Discount_in_Value_Percent__c : 0;
				i++;
                
                
                
                system.debug('inside for'+i);
                tempExcelData.add(' '+',');
                if(qlc.Sr_No__c != null)
                    tempExcelData.add(qlo.Serial_Number__c+',');
                else 
                    tempExcelData.add(' '+',');
               
                if(qlo.Manual_Product_Name__c != null)
                   tempExcelData.add(qlo.Manual_Product_Name__c+',');
                else
                  tempExcelData.add(' '+',');
                
                if(qlo.Option_Product_Code__c != null && !qlo.Select_Option__c)
                    tempExcelData.add(qlo.Option_Product_Code__c+',');
                else
                    if(qlo.Manual_Product_Code__c != null && qlo.Select_Option__c)
                    tempExcelData.add(qlo.Manual_Product_Code__c+',');
                else
                    tempExcelData.add(' '+',');
                
                if(!qt.Is_DTA_Quote__c){
                    if(qlo.Manual_Option_Base_Price__c != null)
                        tempExcelData.add(string.valueOf(qlo.Manual_Option_Base_Price__c)+',');
                    else
                        tempExcelData.add(' '+',');
                }
                
                    if(qlo.Manula_Option_List_Price__c != null)
                        tempExcelData.add(string.valueOf(qlo.Manula_Option_List_Price__c)+',');
                    else
                        tempExcelData.add(' '+',');
                
                if(qlo.Discount_in_Value_Percent__c != null)
                     tempExcelData.add(string.valueOf(qlo.Discount_in_Value_Percent__c)+'%'+',');
                else
                     tempExcelData.add(string.valueOf(0+'%'+','));
                
                if(qlo.Manula_Option_List_Price__c != null)
                      tempExcelData.add(string.valueOf(qlo.Average_Discount_Value__c)+',');
                else
                     tempExcelData.add(string.valueOf(0+','));
                
                if(qlo.Manula_Option_List_Price__c != null)
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
                
               if(qlo.Sales_Margin__c != null)
                tempExcelData.add(string.valueOf(qlo.Sales_Margin__c)+'%'+',');
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
            
            if(qlc.Quote_Line_Options__r.size() > 0){
            tempExcelData.add(' '+',');
            tempExcelData.add(' '+',');
            tempExcelData.add('Sub Total '+',');
            tempExcelData.add(' '+',');
            if(!qt.Is_DTA_Quote__c)
            tempExcelData.add(sub_TotalBasicPrice+',');
            tempExcelData.add(sub_totalListPrice+',');
            tempExcelData.add('-'+',');
            tempExcelData.add(sub_TotalAvgDiscount+',');
            tempExcelData.add(sub_TotalFinalSales+',');
            
            tempExcelData.add(sub_TotalQuantity+',');
            tempExcelData.add(sub_totalSalesPrice+',');
            tempExcelData.add(sub_Margin+'%'+',');
                tempExcelData.add('\n');
            }
            
            
        }
        
            tempExcelData.add(' '+',');
            tempExcelData.add(' '+',');
            tempExcelData.add('Grand Total '+',');
            tempExcelData.add(' '+',');
            if(!qt.Is_DTA_Quote__c)
            tempExcelData.add(totalBasicPrice+',');
            tempExcelData.add(totalListPrice+',');
            tempExcelData.add('-'+',');
            tempExcelData.add(totalAvgDiscount+',');
            tempExcelData.add(totalFinalSales+',');
            
            tempExcelData.add(totalQuantity+',');
            tempExcelData.add(totalSalesPrice+',');
            tempExcelData.add(salesMargin+'%'+',');
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
            insert cv;
            
            
            //Link the File to Parent Record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId, contentDocument.LatestPublishedVersionId  FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = qId;
            cdl.ShareType = 'V';
            insert cdl;
    }
    
   @AuraEnabled
public static string deleteMultipleLineItems(List<Id> lineItemIds) {
    map<string,string> result = new map<string,string> ();
    try {
        
        if (lineItemIds == null || lineItemIds.isEmpty()) return '';

        // Delete child options first
        List<Quote_Line_Options__c> childOptions = [
            SELECT Id FROM Quote_Line_Options__c WHERE Id IN :lineItemIds
            OR Quote_Line_Item_Custom__c IN :lineItemIds
        ];
        if (!childOptions.isEmpty()) {
            delete childOptions;
        }

        // Delete parent line items
        List<Quote_Line_Item_Custom__c> parents = [
            SELECT Id FROM Quote_Line_Item_Custom__c WHERE Id IN :lineItemIds
        ];
        if (!parents.isEmpty()) {
            delete parents;
        }
        
        result.put('Status','Success');
        result.put('Message','Record Deleted !!');
    } catch (Exception e) {
        result.put('Status','Failed');
        String errMsg = e.getMessage();
    // Check if the error contains a comma (common pattern in DML messages)
    Integer commaIndex = errMsg.indexOf(',');
    if (commaIndex != -1) {
        // Get text after the comma and trim spaces
        errMsg = errMsg.substring(commaIndex + 1).trim();
    }
    result.put('Message', errMsg);

        
    }
    return JSON.serialize(result);
}

}