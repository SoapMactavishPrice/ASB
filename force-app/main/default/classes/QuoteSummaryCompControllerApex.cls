public class QuoteSummaryCompControllerApex {
    
    @AuraEnabled 
    public static Quote getQuoteDetail(String QuotationID){
        Quote qt = [Select Id, Is_DTA_Quote__c, Sales_Margin__c, Status from Quote where Id =: QuotationID limit 1];
        return qt;
    }
    
    @AuraEnabled
    Public Static List<Quote_Line_Item_Custom__c> FetchdataWrapper(String QuotationID, String orderby){
        System.debug('QuotationID' + QuotationID);
        System.debug('orderby' + orderby);

        List<Quote_Line_Item_Custom__c> lstData = new List<Quote_Line_Item_Custom__c>();
        Decimal quantity = 0;

        // ─────────────────────────────────────────────────────────────────────────
        // Column mapping (new layout):
        //   Qty                  → Quantity__c
        //   Total Qty (item)     → Quantity__c  (same as Qty for parent rows)
        //   Unit TP              → Base_Price__c
        //   Total TP             → Total_Global_Price_Item__c  ← NEW
        //   Unit List Price      → List_Price__c
        //   Total List Price     → Total_List_Price2__c         ← NEW
        //   Discount %           → Discount_in_Value_Percent__c                  ← NEW COLUMN
        //   Total Discount Value → Discount_Value__c
        //   Unit Sales Price     → Average_Sales_Price__c
        //   Total Sales Price    → Sales_Price__c
        //   Sales Margin%        → Sales_Margin__c
        //
        // Option column mapping:
        //   Qty                  → Quantity__c
        //   Total Qty            → Total_Quantity__c
        //   Unit TP              → Manual_Option_Base_Price__c
        //   Total TP             → Total_Transfer_Price__c
        //   Unit List Price      → Manula_Option_List_Price__c
        //   Total List Price     → Total_List_Price__c
        //   Discount %           → Discount_in_Value_Percent__c                  ← NEW COLUMN
        //   Total Discount Value → Discount_Amount__c
        //   Unit Sales Price     → Unit_Sales_Price__c
        //   Total Sales Price    → Total_Sales_Price__c
        //   Sales Margin%        → Sales_Margin__c
        // ─────────────────────────────────────────────────────────────────────────

        String query = '';
        query += 'Select id, name, Advance_Percentage__c, CurrencyIsoCode, Sr_No__c, Application__c, Average_Discount_Value__c, Average_Sales_Price__c, Approval_Status__c, Cavity__c, Ceiling_Total_Sales_Price__c, Class_2__c, Class__c, Discount__c,' +
                 'Discount_Allowed__c, Discount_Allowed_New__c, Discount_Approval_Note__c, Discount_Earlier__c, Division__c, Drawing_No__c, Expected_Customer_PO__c, Expected_Delivery__c,' +
                 'Expected_Delivery_date__c, Expected_Drawing_Final__c, Base_Price__c, BP_Ratio_Line_Item__c, Is_Discount_Changes_Allow__c, Is_Manual__c,' +
                 'Level_Of_Ceiling__c, Line_Item_Id__c, List_Price__c, Mach_Mold_No__c, MFG_AT__c, MFG__c, Model__c, Overall_Discount__c, Payment_Terms__c, Product__c,' +
                 'Product_Code__c, Product_Name__c, Product_Type__c, Quantity__c, Quote__c, Quote_No__c, Sales_Price__c, Sales_price_Options__c, Product_Description__c,' +
                 'Scope_of_mould__c, Total_Base_Price__c, Discount_in_Value_Percent__c, Total_Base_Price_Options__c, Total_List_Price__c, Total_List_Price_options__c, Total_Sales_Price__c,' +
                 'UOM__c, User_Level__c, Zero_Cooling_2__c, Zero_Cooling__c, Sales_Margin_including_Options__c, Discount_Value__c, Manual_Product_Code__c, Discount_in_Value__c, Sales_Margin__c,' +
                 'Total_Global_Price_Item__c, Total_List_Price2__c,' +
                 '(' +
                     'Select id, name, Discount__c, Discount_Allowed__c, Discount_in_Value_Percent__c, CurrencyIsoCode, Discount_Allowed_New__c, Serial_Number__c,' +
                     'Average_Discount_Value__c, Average_Sales_Price__c, Discount_Description__c, Sales_Margin__c, Discount_Earlier__c, Discount_in_Value__c,' +
                     'Final_Price__c, Final_price_Ceiling__c, Final_Sales_Price__c,' +
                     'Base_price_Total__c, List_Price_Quantity__c, Select_Option__c, Manual_Option__c, Manual_Option_Function__c, Mould_Cavity__c, Manual_Product_Name__c,' +
                     'Option_No__c, Option_Number__c, Option_Product_Code__c, Option_Type__c, Other_Charges__c, Other_Charges_Function__c, Other_Charges_Base_Price__c,' +
                     'Price__c, Price_Type__c, Product__c, Description__c, Product_Name__c, Product_Number__c, Quantity__c, Quantity_Line_Item__c, Quote__c, Quote_Line_Item__c,' +
                     'Quote_Line_Item_Custom__c, Quote_No__c, Sales_Price__c, Sales_Price_Clone__c, Sales_price_Total__c, Manual_Option_Base_Price__c, Manula_Option_List_Price__c,' +
                     'UOM_2__c, UOM__c, User_Level__c, Manual_Product_Code__c, Discount_Value__c,' +
                     'Total_Quantity__c, Total_Transfer_Price__c, Total_List_Price__c, Discount_Amount__c, Unit_Sales_Price__c, Total_Sales_Price__c' +
                     ' from Quote_Line_Options__r ORDER BY Serial_Number__c' +
                 ') from Quote_Line_Item_Custom__c' +
                 ' where Quote__c =\'' + QuotationID + '\' and Quantity__c >: quantity ORDER BY Sr_No__c ' + orderby + ' NULLS LAST';

        lstData = database.query(query);
        System.debug('lstData' + lstData.size());
        return lstData;
    }
    
    @AuraEnabled
    public static void exportCSV(String qId){
        String QuoteName = '';
        Quote qt = [Select Id, Is_DTA_Quote__c, Sales_Margin__c from Quote where Id =: qId limit 1];

        List<Quote_Line_Item_Custom__c> lstData =
            [Select id, name, Advance_Percentage__c, Sr_No__c, Application__c, Approval_Status__c, Cavity__c, Ceiling_Total_Sales_Price__c, Class_2__c, Class__c, Discount__c,
                    Discount_Allowed__c, Discount_Allowed_New__c, Discount_Approval_Note__c, Discount_Earlier__c, Division__c, Drawing_No__c, Expected_Customer_PO__c, Expected_Delivery__c,
                    Expected_Delivery_date__c, Expected_Drawing_Final__c, Base_Price__c, BP_Ratio_Line_Item__c, Is_Discount_Changes_Allow__c, Is_Manual__c,
                    Level_Of_Ceiling__c, Line_Item_Id__c, List_Price__c, Mach_Mold_No__c, MFG_AT__c, MFG__c, Model__c, Overall_Discount__c, Payment_Terms__c, Product__c,
                    Product_Code__c, Product_Name__c, Product_Type__c, Quantity__c, Quote__c, Quote_No__c, Sales_Price__c, Sales_price_Options__c, Product_Description__c,
                    Scope_of_mould__c, Total_Base_Price__c, Total_Base_Price_Options__c, Total_List_Price__c, Total_List_Price_options__c, Total_Sales_Price__c,
                    UOM__c, User_Level__c, Zero_Cooling_2__c, Zero_Cooling__c, Discount_Value__c, Sales_Margin__c, Quote__r.Is_DTA_Quote__c,
                    Quote__r.Quote_Number1__c, Average_Discount_Value__c, Average_Sales_Price__c, Manual_Product_Code__c, Discount_in_Value_Percent__c, Sales_Margin_including_Options__c,
                    Total_Global_Price_Item__c, Total_List_Price2__c,
                    (Select id, name,
                     Average_Discount_Value__c, Final_Sales_Price__c, Average_Sales_Price__c, Discount__c, Discount_in_Value_Percent__c, Serial_Number__c, Sales_Margin__c,
                     Discount_Allowed__c, Discount_Description__c, Discount_Earlier__c, Final_Price__c, Final_price_Ceiling__c,
                     Base_price_Total__c, List_Price_Quantity__c, Select_Option__c, Manual_Option__c, Manual_Option_Function__c, Mould_Cavity__c, Manual_Product_Name__c,
                     Option_No__c, Option_Number__c, Option_Product_Code__c, Option_Type__c, Other_Charges__c, Other_Charges_Function__c, Other_Charges_Base_Price__c,
                     Price__c, Price_Type__c, Product__c, Description__c, Product_Name__c, Product_Number__c, Quantity__c, Quantity_Line_Item__c, Quote__c, Quote_Line_Item__c,
                     Quote_Line_Item_Custom__c, Quote_No__c, Sales_Price__c, Sales_Price_Clone__c, Sales_price_Total__c, Manual_Option_Base_Price__c, Manula_Option_List_Price__c,
                     UOM_2__c, UOM__c, User_Level__c, Manual_Product_Code__c, Discount_Value__c,
                     Total_Quantity__c, Total_Transfer_Price__c, Total_List_Price__c, Discount_Amount__c, Unit_Sales_Price__c, Total_Sales_Price__c
                     from Quote_Line_Options__r ORDER BY Serial_Number__c)
             from Quote_Line_Item_Custom__c where Quote__c =: qId and Quantity__c >: 0];

        List<String> tempExcelData = new List<String>();

        Decimal totalQuantity       = 0;
        Decimal totalTP             = 0;
        Decimal totalListPrice2     = 0;
        Decimal totalDiscountValue  = 0;
        Decimal totalSalesPrice     = 0;
        Decimal salesMargin         = qt.Sales_Margin__c != null ? qt.Sales_Margin__c : 0;

        // ── CSV Header row ──────────────────────────────────────────────────────
        tempExcelData.add('I.sno,');
        tempExcelData.add('O.sno,');
        tempExcelData.add('Product Name,');
        tempExcelData.add('Product Code,');
        tempExcelData.add('Qty,');
        tempExcelData.add('Total Qty,');
        if (!qt.Is_DTA_Quote__c) {
            tempExcelData.add('Unit TP,');
        }
        tempExcelData.add('Total TP,');
        tempExcelData.add('Unit List Price,');
        tempExcelData.add('Total List Price,');
        tempExcelData.add('Discount %,');                   // NEW column header
        tempExcelData.add('Total Discount in Value,');
        tempExcelData.add('Unit Sales Price,');
        tempExcelData.add('Total Sales Price,');
        tempExcelData.add('Sales Margin,');
        tempExcelData.add('\n');

        for (Quote_Line_Item_Custom__c qlc : lstData) {

            Decimal sub_TotalQuantity    = qlc.Quantity__c != null ? qlc.Quantity__c : 0;
            Decimal sub_totalTP          = qlc.Total_Global_Price_Item__c != null ? qlc.Total_Global_Price_Item__c : 0;
            Decimal sub_totalListPrice2  = qlc.Total_List_Price2__c != null ? qlc.Total_List_Price2__c : 0;
            Decimal sub_totalDiscount    = qlc.Discount_Value__c != null ? qlc.Discount_Value__c : 0;
            Decimal sub_totalSalesPrice  = qlc.Sales_Price__c != null ? qlc.Sales_Price__c : 0;
            Decimal sub_Margin           = qlc.Sales_Margin_including_Options__c != null ? qlc.Sales_Margin_including_Options__c : 0;

            QuoteName = qlc.Quote__r.Quote_Number1__c;

            // ── Parent row ──────────────────────────────────────────────────────
            tempExcelData.add((qlc.Sr_No__c != null ? qlc.Sr_No__c : 0) + ',');
            tempExcelData.add(' ,'); // O.sno blank for parent
            tempExcelData.add((qlc.Product_Name__c != null ? qlc.Product_Name__c : ' ') + ',');

            if (qlc.Product_Code__c != null && !qlc.Is_Manual__c)
                tempExcelData.add(qlc.Product_Code__c + ',');
            else if (qlc.Manual_Product_Code__c != null && qlc.Is_Manual__c)
                tempExcelData.add(qlc.Manual_Product_Code__c + ',');
            else
                tempExcelData.add(' ,');

            // Qty
            tempExcelData.add((qlc.Quantity__c != null ? String.valueOf(qlc.Quantity__c) : ' ') + ',');
            // Total Qty (same as Qty for parent rows)
            tempExcelData.add((qlc.Quantity__c != null ? String.valueOf(qlc.Quantity__c) : ' ') + ',');

            if (!qt.Is_DTA_Quote__c) {
                tempExcelData.add((qlc.Base_Price__c != null ? String.valueOf(qlc.Base_Price__c) : ' ') + ',');
            }
            // Total TP
            tempExcelData.add((qlc.Total_Global_Price_Item__c != null ? String.valueOf(qlc.Total_Global_Price_Item__c) : ' ') + ',');
            // Unit List Price
            tempExcelData.add((qlc.List_Price__c != null ? String.valueOf(qlc.List_Price__c) : ' ') + ',');
            // Total List Price
            tempExcelData.add((qlc.Total_List_Price2__c != null ? String.valueOf(qlc.Total_List_Price2__c) : ' ') + ',');
            // Discount % — NEW
            tempExcelData.add((qlc.Discount_in_Value_Percent__c != null ? String.valueOf(qlc.Discount_in_Value_Percent__c) + '%' : ' ') + ',');
            // Total Discount in Value
            tempExcelData.add((qlc.Discount_Value__c != null ? String.valueOf(qlc.Discount_Value__c) : ' ') + ',');
            // Unit Sales Price
            tempExcelData.add((qlc.Average_Sales_Price__c != null ? String.valueOf(qlc.Average_Sales_Price__c) : ' ') + ',');
            // Total Sales Price
            tempExcelData.add((qlc.Sales_Price__c != null ? String.valueOf(qlc.Sales_Price__c) : ' ') + ',');
            // Sales Margin%
            tempExcelData.add((qlc.Sales_Margin__c != null ? String.valueOf(qlc.Sales_Margin__c) + '%' : ' ') + ',');
            tempExcelData.add('\n');

            // ── Option rows ─────────────────────────────────────────────────────
            for (Quote_Line_Options__c qlo : qlc.Quote_Line_Options__r) {

                sub_totalTP         += qlo.Total_Transfer_Price__c  != null ? qlo.Total_Transfer_Price__c  : 0;
                sub_totalListPrice2 += qlo.Total_List_Price__c       != null ? qlo.Total_List_Price__c       : 0;
                sub_totalDiscount   += qlo.Discount_Amount__c        != null ? qlo.Discount_Amount__c        : 0;
                sub_totalSalesPrice += qlo.Total_Sales_Price__c      != null ? qlo.Total_Sales_Price__c      : 0;

                tempExcelData.add(' ,'); // I.sno blank for options
                tempExcelData.add((qlo.Serial_Number__c != null ? qlo.Serial_Number__c : 0) + ',');

                if (qlo.Manual_Product_Name__c != null)
                    tempExcelData.add(qlo.Manual_Product_Name__c + ',');
                else
                    tempExcelData.add(' ,');

                if (qlo.Option_Product_Code__c != null && !qlo.Select_Option__c)
                    tempExcelData.add(qlo.Option_Product_Code__c + ',');
                else if (qlo.Manual_Product_Code__c != null && qlo.Select_Option__c)
                    tempExcelData.add(qlo.Manual_Product_Code__c + ',');
                else
                    tempExcelData.add(' ,');

                // Qty
                tempExcelData.add((qlo.Quantity__c != null ? String.valueOf(qlo.Quantity__c) : ' ') + ',');
                // Total Qty
                tempExcelData.add((qlo.Total_Quantity__c != null ? String.valueOf(qlo.Total_Quantity__c) : ' ') + ',');

                if (!qt.Is_DTA_Quote__c) {
                    tempExcelData.add((qlo.Manual_Option_Base_Price__c != null ? String.valueOf(qlo.Manual_Option_Base_Price__c) : ' ') + ',');
                }
                // Total TP
                tempExcelData.add((qlo.Total_Transfer_Price__c != null ? String.valueOf(qlo.Total_Transfer_Price__c) : ' ') + ',');
                // Unit List Price
                tempExcelData.add((qlo.Manula_Option_List_Price__c != null ? String.valueOf(qlo.Manula_Option_List_Price__c) : ' ') + ',');
                // Total List Price
                tempExcelData.add((qlo.Total_List_Price__c != null ? String.valueOf(qlo.Total_List_Price__c) : ' ') + ',');
                // Discount % — NEW
                tempExcelData.add((qlo.Discount_in_Value_Percent__c != null ? String.valueOf(qlo.Discount_in_Value_Percent__c) + '%' : ' ') + ',');
                // Total Discount in Value
                tempExcelData.add((qlo.Discount_Amount__c != null ? String.valueOf(qlo.Discount_Amount__c) : '0') + ',');
                // Unit Sales Price
                tempExcelData.add((qlo.Unit_Sales_Price__c != null ? String.valueOf(qlo.Unit_Sales_Price__c) : '0') + ',');
                // Total Sales Price
                tempExcelData.add((qlo.Total_Sales_Price__c != null ? String.valueOf(qlo.Total_Sales_Price__c) : '0') + ',');
                // Sales Margin%
                tempExcelData.add((qlo.Sales_Margin__c != null ? String.valueOf(qlo.Sales_Margin__c) + '%' : ' ') + ',');
                tempExcelData.add('\n');
            }

            // ── Sub Total row (only when options exist) ──────────────────────────
            if (qlc.Quote_Line_Options__r.size() > 0) {
                tempExcelData.add(' ,');
                tempExcelData.add(' ,');
                tempExcelData.add('Sub Total,');
                tempExcelData.add(' ,');
                // Qty = item qty
                tempExcelData.add(sub_TotalQuantity + ',');
                // Total Qty = blank
                tempExcelData.add('-,');
                if (!qt.Is_DTA_Quote__c) {
                    tempExcelData.add('-,'); // Unit TP blank
                }
                // Total TP
                tempExcelData.add(sub_totalTP + ',');
                // Unit List Price blank
                tempExcelData.add('-,');
                // Total List Price
                tempExcelData.add(sub_totalListPrice2 + ',');
                // Discount % — blank for sub-total — NEW
                tempExcelData.add('-,');
                // Total Discount in Value
                tempExcelData.add(sub_totalDiscount + ',');
                // Unit Sales Price blank
                tempExcelData.add('-,');
                // Total Sales Price
                tempExcelData.add(sub_totalSalesPrice + ',');
                // Sales Margin%
                tempExcelData.add(sub_Margin + '%,');
                tempExcelData.add('\n');
            }

            // Accumulate into grand totals
            totalQuantity      += sub_TotalQuantity;
            totalTP            += sub_totalTP;
            totalListPrice2    += sub_totalListPrice2;
            totalDiscountValue += sub_totalDiscount;
            totalSalesPrice    += sub_totalSalesPrice;
        }

        // ── Grand Total row ───────────────────────────────────────────────────
        tempExcelData.add(' ,');
        tempExcelData.add(' ,');
        tempExcelData.add('Grand Total,');
        tempExcelData.add(' ,');
        // Qty blank
        tempExcelData.add('-,');
        // Total Qty = sum of item quantities
        tempExcelData.add(totalQuantity + ',');
        if (!qt.Is_DTA_Quote__c) {
            tempExcelData.add('-,'); // Unit TP blank
        }
        // Total TP
        tempExcelData.add(totalTP + ',');
        // Unit List Price blank
        tempExcelData.add('-,');
        // Total List Price
        tempExcelData.add(totalListPrice2 + ',');
        // Discount % — blank for grand total — NEW
        tempExcelData.add('-,');
        // Total Discount in Value
        tempExcelData.add(totalDiscountValue + ',');
        // Unit Sales Price blank
        tempExcelData.add('-,');
        // Total Sales Price
        tempExcelData.add(totalSalesPrice + ',');
        // Sales Margin%
        tempExcelData.add(salesMargin + '%,');
        tempExcelData.add('\n');

        String temp1 = '';
        temp1 += String.join(tempExcelData, ' ');
        tempExcelData.clear();
        tempExcelData.add(temp1);

        DateTime dt = DateTime.now();
        String dateTimeStr = dt.format('ddMMyyhhmm');

        ContentVersion cv = new ContentVersion();
        Blob b = Blob.valueOf(String.join(tempExcelData, ''));
        cv.VersionData  = b;
        cv.Title        = QuoteName + '-' + dateTimeStr + '.csv';
        cv.PathOnClient = QuoteName + '.csv';
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId    = qId;
        cdl.ShareType         = 'V';
        insert cdl;
    }
    
    @AuraEnabled
    public static String deleteMultipleLineItems(List<Id> lineItemIds) {
        Map<String, String> result = new Map<String, String>();
        try {
            if (lineItemIds == null || lineItemIds.isEmpty()) return '';

            List<Quote_Line_Options__c> childOptions = [
                SELECT Id FROM Quote_Line_Options__c
                WHERE Id IN :lineItemIds
                OR Quote_Line_Item_Custom__c IN :lineItemIds
            ];
            if (!childOptions.isEmpty()) {
                delete childOptions;
            }

            List<Quote_Line_Item_Custom__c> parents = [
                SELECT Id FROM Quote_Line_Item_Custom__c WHERE Id IN :lineItemIds
            ];
            if (!parents.isEmpty()) {
                delete parents;
            }

            result.put('Status', 'Success');
            result.put('Message', 'Record Deleted !!');
        } catch (Exception e) {
            result.put('Status', 'Failed');
            String errMsg = e.getMessage();
            Integer commaIndex = errMsg.indexOf(',');
            if (commaIndex != -1) {
                errMsg = errMsg.substring(commaIndex + 1).trim();
            }
            result.put('Message', errMsg);
        }
        return JSON.serialize(result);
    }
}