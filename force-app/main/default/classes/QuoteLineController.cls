/***************************************************************
 * FILENAME: QuoteLineController.cls
 * DESCRIPTION: Discount Revision Lightning Web Component Apex Controller
 * AUTHOR: Praveen Kumar S
 * DATE: 18/11/2025
 ***************************************************************/
public with sharing class QuoteLineController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getQuoteLineData(Id quoteId) {
        List<Quote_Line_Item_Custom__c> lineItems = [
            SELECT Id, Sr_No__c, Product_Name__c, Base_Price__c, Quantity__c, 
                   Total_Global_Price_Item__c, List_Price__c, Total_List_Price2__c,
                   Discount_Allowed_New__c, P_D3__c, Discount__c, Discount_in_Value__c,
                   Desired_Price__c, Desired_Price_Subtotal__c, Discount_In_Percentage_Sub_Total__c, Discount_Value__c,
                   Average_Sales_Price__c, Sales_Price__c, Sales_Margin__c, 
                   Quote__r.Sales_Margin__c, Quote__r.Quote_Total_Base_Price__c, Quote__r.Quote_Total_List_Price__c,
                   Quote__r.Quote_Total_Discount_Value__c, Quote__r.Quote_Totoal__c, Quote__r.Quote_Number__c, Quote__r.CurrencyIsoCode,
                   P_M1__c, P_M2__c, P_M3__c, P_M4__c, Rounding_Off_Digits__c,
                   Total_List_Price__c, Total_Base_Price_including_Options__c,
                   Total_Discount_Value_including_options__c, 
                   Total_Sales_Price_including_Options__c,
                   Sales_Margin_including_Options__c,
                   (SELECT Id, Option_No__c, Serial_Number__c, Manual_Product_Name__c, Quantity__c,
                           Base_price_Total__c, Manula_Option_List_Price__c, Manual_Option_Base_Price__c,
                           List_Price_Total2__c, Discount__c, Discount_in_Value__c,
                           Desired_Price__c, Discount_Allowed_New__c, P_D3__c, Discount_Value__c,
                           Average_Sales_Price__c, Sales_Price__c, Sales_Margin__c,
                           Total_List_Price__c, Discount_Amount__c, Total_Quantity__c, Unit_Sales_Price__c, Total_Sales_Price__c, Total_Transfer_Price__c,
                           P_M1__c, P_M2__c, P_M3__c, P_M4__c, Rounding_Off_Digits__c
                    FROM Quote_Line_Options__r
                    ORDER BY Serial_Number__c ASC)
            FROM Quote_Line_Item_Custom__c
            WHERE Quote__c = :quoteId
            ORDER BY Sr_No__c ASC
        ];
        
        return new Map<String, Object>{
            'lineItems' => lineItems,
            'quoteName' => lineItems.size() > 0 ? lineItems[0].Quote__r.Quote_Number__c : '',
            'quoteCurrency' => lineItems.size() > 0 ? lineItems[0].Quote__r.CurrencyIsoCode : ''
        };
    }
    
    @AuraEnabled
    public static Map<String, Object> saveQuoteLineData(String lineItemsJson, String optionsJson) {
        try {
            List<Quote_Line_Item_Custom__c> lineItems = 
                (List<Quote_Line_Item_Custom__c>) JSON.deserialize(lineItemsJson, List<Quote_Line_Item_Custom__c>.class);
            List<Quote_Line_Options__c> options = 
                (List<Quote_Line_Options__c>) JSON.deserialize(optionsJson, List<Quote_Line_Options__c>.class);
            
            update lineItems;
            update options;
            
            return new Map<String, Object>{
                'success' => true,
                'message' => 'Records saved successfully'
            };
        } catch (Exception e) {
            return new Map<String, Object>{
                'success' => false,
                'message' => e.getMessage()
            };
        }
    }
}