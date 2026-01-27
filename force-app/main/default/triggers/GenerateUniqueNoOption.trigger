trigger GenerateUniqueNoOption on Quote_Line_Options__c (before insert) {
 /*   List<Unique_No__c> uniqueNosToCreate = new List<Unique_No__c>();
    
    Set<Id> quoteIds = new Set<Id>();
    Set<Id> fiscalYearIds = new Set<Id>();
    Set<Id> subsidiary = new Set<Id>();
    
    // Collect data for processing
    for (Quote_Line_Options__c quo : Trigger.new) {
        if(quo.Select_Option__c && String.isBlank(quo.Manual_Product_Code__c)) {
            quoteIds.add(quo.Quote__c);
            fiscalYearIds.add(quo.Fiscal_Year__c);
            subsidiary.add(quo.Subsidiary__c);
        }
    }
    
    // If fiscal year and subsidiary are present, proceed with querying Unique_No__c records
    if(fiscalYearIds.size() > 0 && subsidiary.size() > 0) {
        system.debug('Manual check -> fiscalYearIds -> ' + fiscalYearIds);
        system.debug('Manual check -> subsidiary -> ' + subsidiary);
        
        // Query Unique_No__c records for the matching Subsidiary and Fiscal Year
        List<Unique_No__c> insertedUniqueNos = [
            SELECT Id, Name, Serial_No__c, Subsidiary__c, Subsidiary__r.Name, Object_Name__c, Fiscal_Year__c, Fiscal_Year__r.Name
            FROM Unique_No__c 
            WHERE Object_Name__c = 'Manual Option' 
            AND Subsidiary__c IN :subsidiary 
            AND Fiscal_Year__c IN :fiscalYearIds
        ];
        
        system.debug('Manual check -> insertedUniqueNos -> ' + insertedUniqueNos.size());
        
        // Create a map to store the Unique_No__c records
        Map<String, Unique_No__c> unq = new Map<String, Unique_No__c>();
        
        // Populate the map with key as 'SubsidiaryId_FiscalYear'
        for (Unique_No__c uniqueNo : insertedUniqueNos) {
            String subsidiaryId = String.valueOf(uniqueNo.Subsidiary__c);
            // Remove last 3 characters only if necessary (this could be specific to your logic)
            subsidiaryId = subsidiaryId.substring(0, subsidiaryId.length() - 3);
            
            String fiscalYearId = String.valueOf(uniqueNo.Fiscal_Year__c);
            fiscalYearId = fiscalYearId.substring(0, fiscalYearId.length() - 3);
            
            String key = subsidiaryId + '_' + fiscalYearId;
            unq.put(key, uniqueNo);
        }
        
        system.debug('Manual check -> Unique_No__c Map -> ' + unq);

        // Process each Quote_Line_Item_Custom__c and generate Manual_Product_Code__c
        for (Quote_Line_Options__c quo : Trigger.new) {
            if(quo.Select_Option__c && String.isBlank(quo.Manual_Product_Code__c)) {
                String key = String.valueOf(quo.Subsidiary__c) + '_' + String.valueOf(quo.Fiscal_Year__c);
                system.debug('Manual check -> Inside Key -> ' + key);
                
                // Check if the map contains the key and if so, update the Manual_Product_Code__c
                if(unq.containsKey(key)) {
                    Unique_No__c unc = unq.get(key);
                    String temp = '';
                    Decimal srNo = unc.Serial_No__c + 1;
                    
                    // Create a zero-padded serial number
                    for (Integer i = 7; i > String.valueOf(srNo).length(); i--) {
                        temp += '0';
                    }
                    temp += String.valueOf(srNo);
                    
                    // Generate Manual Product Code
                    quo.Manual_Product_Code__c = 'M' + unc.Subsidiary__r.Name + unc.Fiscal_Year__r.Name + '-' + temp;
                    unc.Serial_No__c = srNo;
                    system.debug('Manual_Product_Code__c -> ' + quo.Manual_Product_Code__c);
                }
            }
        }

        // Update the modified Unique_No__c records (if any)
        if (!unq.isEmpty()) {
            update unq.values();
        }
    }		*/
}