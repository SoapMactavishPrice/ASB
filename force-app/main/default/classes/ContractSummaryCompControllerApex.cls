public class ContractSummaryCompControllerApex {

    @AuraEnabled
    public static Contract getContractDetail(String ContractID) {
        return [
            SELECT Id, Is_DTA_Contract__c, CurrencyIsoCode, Grand_Total_Item_Quantity__c,
                   Total_Base_Price__c, Contract_Total_List_Price__c,
                   Contract_Total_Discount_Value__c, Contract_Total_Sales_price__c,
                   Sales_Margin_Percent__c
            FROM Contract
            WHERE Id = :ContractID
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static List<Contract_Line_Item__c> FetchdataWrapper(String ContractID, String orderby) {
        Decimal quantity = 0;
        String query =
            'SELECT Id, Name, CurrencyIsoCode, Sr_No__c, Product2Id__r.Name, Product_Number__c, ' +
            'Base_Price_Line_Item__c, List_Price__c, Discount_in_Value_Percent__c, Discount_Value__c, ' +
            'Average_Sales_Price__c, Quantity__c, Total_Sales_Price2__c, Sales_Margin_Percent__c, Product_Name_2__c,' +
            'Sales_Margin_including_Options__c, Total_Global_Price_Item__c, Total_List_Price3__c, ' +
            'Total_Base_Price_including_Options__c, Total_List_Price__c, ' +
            'Total_Discount_Value_Including_Options__c, Total_Sales_Price_including_Options__c, ' +
            '(SELECT Id, Name, Product__r.Name, CurrencyIsoCode, Serial_Number__c, Product_Code__c, Quantity__c, Manual_Product_Name_c__c,' +
            'Total_Quantity__c, Manual_Option_Base_Price__c, Manual_Option_List_Price__c, Total_Transfer_Price__c, ' +
            'Total_List_Price__c, Discount_in_Value_Percent__c, Discount_Amount__c, Unit_Sales_Price__c, ' +
            'Total_Sales_Price__c, Sales_Margin_New__c ' +
            'FROM Contract_Line_Option__r ORDER BY Serial_Number__c) ' +
            'FROM Contract_Line_Item__c ' +
            'WHERE ContractId__c = \'' + ContractID + '\' AND Quantity__c > :quantity ' +
            'ORDER BY Sr_No__c ' + orderby + ' NULLS LAST';

        return Database.query(query);
    }

    @AuraEnabled
    public static void exportCSV(String cId) {
        Contract ct = [
            SELECT Id, Is_DTA_Contract__c, Grand_Total_Item_Quantity__c, Total_Base_Price__c,
                   Contract_Total_List_Price__c, Contract_Total_Discount_Value__c,
                   Contract_Total_Sales_price__c, Sales_Margin_Percent__c
            FROM Contract
            WHERE Id = :cId
            LIMIT 1
        ];

        List<Contract_Line_Item__c> lstData = [
            SELECT Id, Name, CurrencyIsoCode, Sr_No__c, Product2Id__r.Name, Product_Number__c,
                   Base_Price_Line_Item__c, List_Price__c, Discount_in_Value_Percent__c, Discount_Value__c,
                   Average_Sales_Price__c, Quantity__c, Total_Sales_Price2__c, Sales_Margin_Percent__c,
                   Sales_Margin_including_Options__c, Total_Global_Price_Item__c, Total_List_Price3__c,
                   Total_Base_Price_including_Options__c, Total_List_Price__c,
                   Total_Discount_Value_Including_Options__c, Total_Sales_Price_including_Options__c,
                   ContractId__r.Contract_Number__c, ContractId__r.QU_Revise_Number__c,
                   (
                       SELECT Id, Name, Product__r.Name, CurrencyIsoCode, Serial_Number__c, Product_Code__c,
                              Quantity__c, Total_Quantity__c, Manual_Option_Base_Price__c,
                              Manual_Option_List_Price__c, Total_Transfer_Price__c, Total_List_Price__c,
                              Discount_in_Value_Percent__c, Discount_Amount__c, Unit_Sales_Price__c,
                              Total_Sales_Price__c, Sales_Margin_New__c
                       FROM Contract_Line_Option__r
                       ORDER BY Serial_Number__c
                   )
            FROM Contract_Line_Item__c
            WHERE ContractId__c = :cId
              AND Quantity__c > 0
            ORDER BY Sr_No__c
        ];

        Decimal totalQuantity = ct.Grand_Total_Item_Quantity__c != null ? ct.Grand_Total_Item_Quantity__c : 0;
        Decimal totalTP = ct.Total_Base_Price__c != null ? ct.Total_Base_Price__c : 0;
        Decimal totalListPrice2 = ct.Contract_Total_List_Price__c != null ? ct.Contract_Total_List_Price__c : 0;
        Decimal totalDiscountValue = ct.Contract_Total_Discount_Value__c != null ? ct.Contract_Total_Discount_Value__c : 0;
        Decimal totalSalesPrice = ct.Contract_Total_Sales_price__c != null ? ct.Contract_Total_Sales_price__c : 0;
        Decimal salesMargin = ct.Sales_Margin_Percent__c != null ? ct.Sales_Margin_Percent__c : 0;

        String contractName = '';
        List<String> tempExcelData = new List<String>();

        tempExcelData.add('I.sno,');
        tempExcelData.add('O.sno,');
        tempExcelData.add('Product Name,');
        tempExcelData.add('Product Code,');
        tempExcelData.add('Qty,');
        tempExcelData.add('Total Qty,');
        tempExcelData.add('Unit TP,');
        tempExcelData.add('Unit List Price,');
        tempExcelData.add('Total TP,');
        tempExcelData.add('Total List Price,');
        tempExcelData.add('Discount %,');
        tempExcelData.add('Total Discount in Value,');
        tempExcelData.add('Unit Sales Price,');
        tempExcelData.add('Total Sales Price,');
        tempExcelData.add('Sales Margin,');
        tempExcelData.add('\n');

        for (Contract_Line_Item__c cli : lstData) {
            Decimal subTotalQuantity = cli.Quantity__c != null ? cli.Quantity__c : 0;
            Decimal subTotalTP = cli.Total_Base_Price_including_Options__c != null ? cli.Total_Base_Price_including_Options__c : 0;
            Decimal subTotalListPrice2 = cli.Total_List_Price__c != null ? cli.Total_List_Price__c : 0;
            Decimal subTotalDiscount = cli.Total_Discount_Value_Including_Options__c != null ? cli.Total_Discount_Value_Including_Options__c : 0;
            Decimal subTotalSalesPrice = cli.Total_Sales_Price_including_Options__c != null ? cli.Total_Sales_Price_including_Options__c : 0;
            Decimal subMargin = cli.Sales_Margin_including_Options__c != null ? cli.Sales_Margin_including_Options__c : 0;

            contractName = cli.ContractId__r != null && cli.ContractId__r.Contract_Number__c != null
                ? cli.ContractId__r.Contract_Number__c
                : '';
            if (cli.ContractId__r != null && String.isNotBlank(cli.ContractId__r.QU_Revise_Number__c)) {
                Integer revNo = Integer.valueOf(cli.ContractId__r.QU_Revise_Number__c);
                if (revNo > 0) {
                    contractName += '-' + cli.ContractId__r.QU_Revise_Number__c;
                }
            }

            tempExcelData.add((cli.Sr_No__c != null ? String.valueOf(cli.Sr_No__c) : ' ') + ',');
            tempExcelData.add(' ,');
            tempExcelData.add((cli.Product2Id__r != null && cli.Product2Id__r.Name != null ? cli.Product2Id__r.Name : ' ') + ',');
            tempExcelData.add((cli.Product_Number__c != null ? cli.Product_Number__c : ' ') + ',');
            tempExcelData.add((cli.Quantity__c != null ? String.valueOf(cli.Quantity__c) : ' ') + ',');
            tempExcelData.add((cli.Quantity__c != null ? String.valueOf(cli.Quantity__c) : ' ') + ',');
            tempExcelData.add((cli.Base_Price_Line_Item__c != null ? String.valueOf(cli.Base_Price_Line_Item__c) : ' ') + ',');
            tempExcelData.add((cli.List_Price__c != null ? String.valueOf(cli.List_Price__c) : ' ') + ',');
            tempExcelData.add((cli.Total_Global_Price_Item__c != null ? String.valueOf(cli.Total_Global_Price_Item__c) : ' ') + ',');
            tempExcelData.add((cli.Total_List_Price3__c != null ? String.valueOf(cli.Total_List_Price3__c) : ' ') + ',');
            tempExcelData.add((cli.Discount_in_Value_Percent__c != null ? String.valueOf(cli.Discount_in_Value_Percent__c) + '%' : ' ') + ',');
            tempExcelData.add((cli.Discount_Value__c != null ? String.valueOf(cli.Discount_Value__c) : ' ') + ',');
            tempExcelData.add((cli.Average_Sales_Price__c != null ? String.valueOf(cli.Average_Sales_Price__c) : ' ') + ',');
            tempExcelData.add((cli.Total_Sales_Price2__c != null ? String.valueOf(cli.Total_Sales_Price2__c) : ' ') + ',');
            tempExcelData.add((cli.Sales_Margin_Percent__c != null ? String.valueOf(cli.Sales_Margin_Percent__c) + '%' : ' ') + ',');
            tempExcelData.add('\n');

            for (Contract_Line_Option__c clo : cli.Contract_Line_Option__r) {
                tempExcelData.add(' ,');
                tempExcelData.add((clo.Serial_Number__c != null ? String.valueOf(clo.Serial_Number__c) : ' ') + ',');
                tempExcelData.add((clo.Product__r != null && clo.Product__r.Name != null ? clo.Product__r.Name : ' ') + ',');
                tempExcelData.add((clo.Product_Code__c != null ? clo.Product_Code__c : ' ') + ',');
                tempExcelData.add((clo.Quantity__c != null ? String.valueOf(clo.Quantity__c) : ' ') + ',');
                tempExcelData.add((clo.Total_Quantity__c != null ? String.valueOf(clo.Total_Quantity__c) : ' ') + ',');
                tempExcelData.add((clo.Manual_Option_Base_Price__c != null ? String.valueOf(clo.Manual_Option_Base_Price__c) : ' ') + ',');
                tempExcelData.add((clo.Manual_Option_List_Price__c != null ? String.valueOf(clo.Manual_Option_List_Price__c) : ' ') + ',');
                tempExcelData.add((clo.Total_Transfer_Price__c != null ? String.valueOf(clo.Total_Transfer_Price__c) : ' ') + ',');
                tempExcelData.add((clo.Total_List_Price__c != null ? String.valueOf(clo.Total_List_Price__c) : ' ') + ',');
                tempExcelData.add((clo.Discount_in_Value_Percent__c != null ? String.valueOf(clo.Discount_in_Value_Percent__c) + '%' : ' ') + ',');
                tempExcelData.add((clo.Discount_Amount__c != null ? String.valueOf(clo.Discount_Amount__c) : '0') + ',');
                tempExcelData.add((clo.Unit_Sales_Price__c != null ? String.valueOf(clo.Unit_Sales_Price__c) : '0') + ',');
                tempExcelData.add((clo.Total_Sales_Price__c != null ? String.valueOf(clo.Total_Sales_Price__c) : '0') + ',');
                tempExcelData.add((clo.Sales_Margin_New__c != null ? String.valueOf(clo.Sales_Margin_New__c) + '%' : ' ') + ',');
                tempExcelData.add('\n');
            }

            if (cli.Contract_Line_Option__r.size() > 0) {
                tempExcelData.add(' ,');
                tempExcelData.add(' ,');
                tempExcelData.add('Sub Total,');
                tempExcelData.add(' ,');
                tempExcelData.add(subTotalQuantity + ',');
                tempExcelData.add(subTotalQuantity + ',');
                tempExcelData.add(' ,');
                tempExcelData.add(' ,');
                tempExcelData.add(subTotalTP + ',');
                tempExcelData.add(subTotalListPrice2 + ',');
                tempExcelData.add(' ,');
                tempExcelData.add(subTotalDiscount + ',');
                tempExcelData.add(' ,');
                tempExcelData.add(subTotalSalesPrice + ',');
                tempExcelData.add(subMargin.setScale(2) + '%,');
                tempExcelData.add('\n');
            }
        }

        tempExcelData.add(' ,');
        tempExcelData.add(' ,');
        tempExcelData.add('Grand Total,');
        tempExcelData.add(' ,');
        tempExcelData.add(' ,');
        tempExcelData.add(totalQuantity + ',');
        tempExcelData.add(' ,');
        tempExcelData.add(' ,');
        tempExcelData.add(totalTP + ',');
        tempExcelData.add(totalListPrice2 + ',');
        tempExcelData.add(' ,');
        tempExcelData.add(totalDiscountValue + ',');
        tempExcelData.add(' ,');
        tempExcelData.add(totalSalesPrice + ',');
        tempExcelData.add(salesMargin + '%,');
        tempExcelData.add('\n');

        String csvBody = String.join(tempExcelData, ' ');
        DateTime dt = DateTime.now();
        String dateTimeStr = dt.format('ddMMyyhhmm');

        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf(csvBody);
        cv.Title = contractName + '-' + dateTimeStr + '.csv';
        cv.PathOnClient = contractName + '.csv';
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ].ContentDocumentId;
        cdl.LinkedEntityId = cId;
        cdl.ShareType = 'V';
        insert cdl;
    }
}
