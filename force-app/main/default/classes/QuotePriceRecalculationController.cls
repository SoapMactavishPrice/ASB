/***************************************************************
 * FILENAME: QuotePriceRecalculationController.cls
 * DESCRIPTION: Controller to handle Quote Price Recalculation based on selected Pricebook.
 * AUTHOR: Praveen Kumar S
 * DATE: 29/12/2025
 ***************************************************************/

public class QuotePriceRecalculationController {
    
    /**
     * Get list of pricebooks filtered by Quote's Subsidiary
     * @param recordId - Quote Id
     * @return List of pricebook options with label and value
     */
    @AuraEnabled
    public static List<Map<String, String>> getPricebooks(String recordId) {
        Quote quote = [
            SELECT Id, Subsidiary__c, Subsidiary__r.Name, Subsidiary__r.Price_Book__c 
            FROM Quote 
            WHERE Id = :recordId 
            LIMIT 1
        ];
        
        List<Map<String, String>> pricebookOptions = new List<Map<String, String>>();
        
        List<Pricebook2> pricebooks = [
            SELECT Id, Name, IsActive, IsStandard 
            FROM Pricebook2 
            WHERE IsActive = true 
            AND (Subsidiary__c = :quote.Subsidiary__c OR Id = :quote.Subsidiary__r.Price_Book__c)
            ORDER BY IsStandard DESC, Name ASC
        ];
        
        for (Pricebook2 pb : pricebooks) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', pb.Name + (pb.IsStandard ? ' (Standard)' : ''));
            option.put('value', pb.Id);
            pricebookOptions.add(option);
        }
        
        return pricebookOptions;
    }
    
    /**
     * Validate if all products in Quote Line Items and Options exist in the selected pricebook
     * @param quoteId - Quote Id
     * @param selectedPricebookId - Selected Pricebook Id
     * @return Validation result with success flag and message
     */
    @AuraEnabled
    public static Map<String, Object> validateProductsInPricebook(String quoteId, String selectedPricebookId) {
        Map<String, Object> result = new Map<String, Object>();
        
        Quote quote = [
            SELECT Id, Opportunity.CurrencyISOCode 
            FROM Quote 
            WHERE Id = :quoteId 
            LIMIT 1
        ];
        
        Set<Id> qliProductIds = new Set<Id>();
        for (Quote_Line_Item_Custom__c qli : [
            SELECT Product__c 
            FROM Quote_Line_Item_Custom__c 
            WHERE Quote__c = :quoteId 
            AND Quantity__c > 0 
            AND Is_Manual__c = false
        ]) {
            if (qli.Product__c != null) {
                qliProductIds.add(qli.Product__c);
            }
        }
        
        Set<Id> qlioProductIds = new Set<Id>();
        for (Quote_Line_Options__c qlio : [
            SELECT Product__c 
            FROM Quote_Line_Options__c 
            WHERE Quote__c = :quoteId 
            AND Select_Option__c = false
        ]) {
            if (qlio.Product__c != null) {
                qlioProductIds.add(qlio.Product__c);
            }
        }
        
        Set<Id> allProductIds = new Set<Id>();
        allProductIds.addAll(qliProductIds);
        allProductIds.addAll(qlioProductIds);
        
        if (allProductIds.isEmpty()) {
            result.put('success', true);
            result.put('message', 'No products to validate.');
            return result;
        }
        
        Set<Id> productsInPricebook = new Set<Id>();
        for (PricebookEntry pbe : [
            SELECT Product2Id 
            FROM PricebookEntry 
            WHERE Product2Id IN :allProductIds 
            AND Pricebook2Id = :selectedPricebookId
            AND CurrencyISOCode = :quote.Opportunity.CurrencyISOCode
            AND IsActive = true
        ]) {
            productsInPricebook.add(pbe.Product2Id);
        }
        
        Set<Id> missingProducts = new Set<Id>();
        for (Id productId : allProductIds) {
            if (!productsInPricebook.contains(productId)) {
                missingProducts.add(productId);
            }
        }
        
        if (!missingProducts.isEmpty()) {
            List<String> missingProductNames = new List<String>();
            for (Product2 prod : [SELECT Name FROM Product2 WHERE Id IN :missingProducts]) {
                missingProductNames.add(prod.Name);
            }
            
            result.put('success', false);
            result.put('message', 'The following products do not exist in the selected pricebook: ' + String.join(missingProductNames, ', '));
            return result;
        }
        
        result.put('success', true);
        result.put('message', 'All products are available in the selected pricebook.');
        return result;
        
    }
    
    /**
     * Recalculate Quote Line Items and Options with selected pricebook
     * @param quoteId - Quote Id
     * @param selectedPricebookId - Selected Pricebook Id
     * @return Success message
     */
    @AuraEnabled
    public static String recalculateQuotePrice(String quoteId, String selectedPricebookId) {
        try {
            
            Quote objQuote = [
                SELECT Id, Name, Subsidiary__r.Price_Book__c, Opportunity.CurrencyISOCode, 
                       Additinal_Margin__c, Pricebook2Id 
                FROM Quote 
                WHERE Id = :quoteId 
                LIMIT 1
            ];
            
            List<Quote_Line_Item_Custom__c> objQLI = [
                SELECT Id, Quote__c, Sales_Price__c, Is_Tax__c, List_Price__c, Base_Price__c, 
                       Quantity__c, Quote__r.Subsidiary__c, Quote__r.Subsidiary__r.Price_Book__c,
                       Product__c, Quote__r.Subsidiary__r.Additional_Margin__c, Quote__r.Additinal_Margin__c, 
                       Level_Of_Ceiling__c, Quote__r.Subsidiary__r.Rounding_Off_Digits__c, 
                       Discount_Allowed_New__c, Quote__r.Subsidiary__r.M1__c, Quote__r.Subsidiary__r.D1__c, 
                       Quote__r.Subsidiary__r.D2__c, P_D1__c, P_D2__c, P_D3__c
                FROM Quote_Line_Item_Custom__c 
                WHERE Quote__c = :quoteId 
                AND Quantity__c > 0 
                AND Is_Manual__c = false
            ];
            
            List<Quote_Line_Options__c> objQLIO = [
                SELECT Id, Quote__c, Manual_Option_Base_Price__c, Quote__r.Subsidiary__c, 
                       Manula_Option_List_Price__c, Quote__r.Subsidiary__r.Price_Book__c,
                       Product__c, Quote__r.Subsidiary__r.Additional_Margin__c, Quote__r.Additinal_Margin__c,
                       Quote__r.Subsidiary__r.Rounding_Off_Digits__c, Discount_Allowed_New__c, 
                       Quote__r.Subsidiary__r.M1__c, Quote__r.Subsidiary__r.D1__c, Quote__r.Subsidiary__r.D2__c, 
                       Quote_Line_Item_Custom__c, Select_Option__c, P_D1__c, P_D2__c, P_D3__c
                FROM Quote_Line_Options__c 
                WHERE Quote__c = :quoteId 
                AND Select_Option__c = false
            ];
            
            Set<Id> qliProductIds = new Set<Id>();
            for (Quote_Line_Item_Custom__c qli : objQLI) {
                qliProductIds.add(qli.Product__c);
            }
            
            Set<Id> qlioProductIds = new Set<Id>();
            for (Quote_Line_Options__c qlio : objQLIO) {
                qlioProductIds.add(qlio.Product__c);
            }
            
            List<PricebookEntry> pbeQLI = [
                SELECT Product2Id, Pricebook2Id, D1__c, D2__c, D3__c, 
                       Base_Price__c, List_Price__c, Rounding_Off_Digits__c 
                FROM PricebookEntry 
                WHERE Product2Id IN :qliProductIds 
                AND Pricebook2Id = :selectedPricebookId 
                AND CurrencyISOCode = :objQuote.Opportunity.CurrencyISOCode
                AND IsActive = true
            ];
            
            List<PricebookEntry> pbeQLIO = [
                SELECT Product2Id, Pricebook2Id, D1__c, D2__c, D3__c, 
                       Base_Price__c, List_Price__c, Rounding_Off_Digits__c 
                FROM PricebookEntry 
                WHERE Product2Id IN :qlioProductIds 
                AND Pricebook2Id = :selectedPricebookId 
                AND CurrencyISOCode = :objQuote.Opportunity.CurrencyISOCode
                AND IsActive = true
            ];
            
            Map<Id, PricebookEntry> qliPriceMap = new Map<Id, PricebookEntry>();
            for (PricebookEntry pbe : pbeQLI) {
                qliPriceMap.put(pbe.Product2Id, pbe);
            }
            
            Map<Id, PricebookEntry> qlioPriceMap = new Map<Id, PricebookEntry>();
            for (PricebookEntry pbe : pbeQLIO) {
                qlioPriceMap.put(pbe.Product2Id, pbe);
            }
            
            List<Quote_Line_Item_Custom__c> qliToUpdate = new List<Quote_Line_Item_Custom__c>();
            for (Quote_Line_Item_Custom__c qli : objQLI) {
                if (qliPriceMap.containsKey(qli.Product__c)) {
                    PricebookEntry pbe = qliPriceMap.get(qli.Product__c);
                    
                    qli.P_D1__c = pbe.D1__c;
                    qli.P_D2__c = pbe.D2__c;
                    qli.P_D3__c = pbe.D3__c;
                    qli.Base_Price__c = pbe.Base_Price__c;
                    qli.List_Price__c = pbe.List_Price__c;
                    
                    qliToUpdate.add(qli);
                } else {
                    qliToUpdate.add(qli);
                }
            }
            
            List<Quote_Line_Options__c> qlioToUpdate = new List<Quote_Line_Options__c>();
            for (Quote_Line_Options__c qlio : objQLIO) {
                if (qlioPriceMap.containsKey(qlio.Product__c)) {
                    PricebookEntry pbe = qlioPriceMap.get(qlio.Product__c);
                    
                    qlio.P_D1__c = pbe.D1__c;
                    qlio.P_D2__c = pbe.D2__c;
                    qlio.P_D3__c = pbe.D3__c;
                    qlio.Manula_Option_List_Price__c = pbe.List_Price__c;
                    qlio.Manual_Option_Base_Price__c = pbe.Base_Price__c;
                    
                    qlioToUpdate.add(qlio);
                } else {
                    qlioToUpdate.add(qlio);
                }
            }
            
            objQuote.Pricebook2Id = selectedPricebookId;
            
            update objQuote;
            
            if (!qliToUpdate.isEmpty()) {
                update qliToUpdate;
            }
            
            if (!qlioToUpdate.isEmpty()) {
                update qlioToUpdate;
            }
            
            return 'Quote recalculated successfully with the selected pricebook.';
            
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating records: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error recalculating quote: ' + e.getMessage());
        }
    }
}