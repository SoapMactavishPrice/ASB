/***************************************************************
 * FILENAME: CloneQuoteCurrencyController.cls
 * DESCRIPTION: Controller for cloning Quotes with different currency,
 *              handling Opportunity cloning and Opportunity Group management.
 * AUTHOR: Praveen Kumar S
 * DATE: 19/12/2025
 ***************************************************************/

public with sharing class CloneQuoteCurrencyController {
    
    /**
     * Get all available currencies except the current one
     */
    @AuraEnabled(cacheable=true)
    public static List<CurrencyWrapper> getAvailableCurrencies(String currentCurrency) {
        List<CurrencyWrapper> currencies = new List<CurrencyWrapper>();
        
        for(CurrencyType ct : [SELECT IsoCode, ConversionRate, DecimalPlaces 
                                FROM CurrencyType 
                                WHERE IsActive = true 
                                AND IsoCode != :currentCurrency
                                ORDER BY IsoCode]) {
            currencies.add(new CurrencyWrapper(ct.IsoCode, ct.ConversionRate, ct.DecimalPlaces));
        }
        
        return currencies;
    }
    
    /**
     * Clone Quote with new currency and handle Opportunity/Opportunity Group
     */
    @AuraEnabled
    public static ResponseWrapper cloneQuoteWithNewCurrency(String sourceQuoteId, String newCurrency, String exchangeRate) {
        ResponseWrapper response = new ResponseWrapper();
        
        try {
            
            Quote sourceQuote = [SELECT Id, Name, OpportunityId, CurrencyIsoCode, Quote_Number1__c, 
                                 QU_REVISION_NUMBER__c, Pricebook2Id, SOLD_TO__c, SHIP_TO__c
                                 FROM Quote 
                                 WHERE Id = :sourceQuoteId 
                                 LIMIT 1];
            
                                 
            Opportunity sourceOpp = [SELECT Id, Name, StageName, CloseDate, Contact__c, 
                                     AccountId, CurrencyIsoCode, Opportunity_Group__c,
                                     Subsidiary__c, Zero_Cooling__c, Class__c, MFG_AT__c, APPLICATION__c
                                     FROM Opportunity 
                                     WHERE Id = :sourceQuote.OpportunityId 
                                     LIMIT 1];
            
                                     
            Id opportunityGroupId = handleOpportunityGroup(sourceOpp);
            
            
            Opportunity clonedOpp = cloneOpportunity(sourceOpp, newCurrency, opportunityGroupId);
            insert clonedOpp;
            
            
            if(sourceOpp.Opportunity_Group__c == null) {
                sourceOpp.Opportunity_Group__c = opportunityGroupId;
                update sourceOpp;
            }
            
            
            Map<String, Object> cloneResult = QuoteCreationCMPController.cloneExistingQuote(
                sourceQuoteId,
                sourceQuote.Name,
                newCurrency,
                clonedOpp.Id,
                exchangeRate,
                '1.00',
                sourceQuote.SOLD_TO__c,
                sourceQuote.SHIP_TO__c,
                sourceQuote.Pricebook2Id
            );
            
            if(cloneResult.containsKey('Id')) {
                response.success = true;
                response.newQuoteId = (String)cloneResult.get('Id');
                response.newOpportunityId = clonedOpp.Id;
                response.message = 'Quote and Opportunity cloned successfully';
            } else {
                response.success = false;
                response.message = 'Failed to clone quote';
            }
            
        } catch(Exception e) {
            response.success = false;
            response.message = e.getMessage();
            System.debug('Error in cloneQuoteWithNewCurrency: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
        }
        
        return response;
    }
    
    /**
     * Handle Opportunity Group creation or retrieval
     */
    private static Id handleOpportunityGroup(Opportunity sourceOpp) {
        Id oppGroupId;
        
        if(sourceOpp.Opportunity_Group__c != null) {
            oppGroupId = sourceOpp.Opportunity_Group__c;
        } else {
            Opportunity_Group__c newOppGroup = createOpportunityGroup(sourceOpp.Subsidiary__c);
            insert newOppGroup;
            oppGroupId = newOppGroup.Id;
        }
        
        return oppGroupId;
    }
    
    /**
     * Create new Opportunity Group with auto-number
     */
    private static Opportunity_Group__c createOpportunityGroup(Id subsidiaryId) {
        Opportunity_Group__c oppGroup = new Opportunity_Group__c();
        
        
        Fiscal_Year_Master__c fy = [SELECT Id, Name FROM Fiscal_Year_Master__c 
                                     WHERE Active__c = true LIMIT 1];
        
        Unique_No__c uniqueNo;

        uniqueNo = [SELECT Id, Serial_No__c, Subsidiary__c, Fiscal_Year__c 
                    FROM Unique_No__c 
                    WHERE Subsidiary__c = :subsidiaryId 
                    AND Fiscal_Year__c = :fy.Id 
                    AND Object_Name__c = 'Opportunity Group' 
                    LIMIT 1 FOR UPDATE];
        
        uniqueNo.Serial_No__c = uniqueNo.Serial_No__c + 1;
        
        Subsidiari_Master__c subsidiary = [SELECT Name FROM Subsidiari_Master__c WHERE Id = :subsidiaryId LIMIT 1];
        
        String serialPadded = String.valueOf(uniqueNo.Serial_No__c).leftPad(5, '0');
        String oppGroupNumber = 'OG' + subsidiary.Name + fy.Name + '-' + serialPadded;
        
        oppGroup.Name = oppGroupNumber;
        
        update uniqueNo;
        
        return oppGroup;
    }
    
    /**
     * Clone Opportunity with new currency
     */
    private static Opportunity cloneOpportunity(Opportunity sourceOpp, String newCurrency, Id oppGroupId) {
        Opportunity clonedOpp = sourceOpp.clone(false, false, false, false);
        
        clonedOpp.Name = sourceOpp.Name;
        clonedOpp.CurrencyIsoCode = newCurrency;
        clonedOpp.Opportunity_Group__c = oppGroupId;
        clonedOpp.StageName = sourceOpp.StageName;
        clonedOpp.CloseDate = sourceOpp.CloseDate;
        clonedOpp.Contact__c = sourceOpp.Contact__c;
        clonedOpp.AccountId = sourceOpp.AccountId;
        
        return clonedOpp;
    }
    
    /**
     * Cancel all related opportunities except the active one
     * Called when Contract is created
     */
    @AuraEnabled
    public static void cancelRelatedOpportunities(Id activeOpportunityId) {
        try {
            
            Opportunity activeOpp = [SELECT Id, Opportunity_Group__c 
                                     FROM Opportunity 
                                     WHERE Id = :activeOpportunityId 
                                     LIMIT 1];
            
            if(activeOpp.Opportunity_Group__c == null) {
                return;
            }
            
            List<Opportunity> relatedOpps = [SELECT Id, StageName 
                                             FROM Opportunity 
                                             WHERE Opportunity_Group__c = :activeOpp.Opportunity_Group__c 
                                             AND Id != :activeOpportunityId];
            

            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opp : relatedOpps) {
                oppIds.add(opp.Id);
            }
            
            List<Quote> relatedQuotes = [SELECT Id, Status 
                                         FROM Quote 
                                         WHERE OpportunityId IN :oppIds 
                                         AND Status NOT IN ('CANCELLED', 'CLOSE - SC CREATED', 'DISCARD/VOID')];
            
                                         
            for(Opportunity opp : relatedOpps) {
                opp.StageName = 'Cancelled';
            }
            
            
            for(Quote q : relatedQuotes) {
                q.Skip_Status_Validation__c = true;
                q.Status = 'CANCELLED';
            }
            
            if(!relatedOpps.isEmpty()) {
                update relatedOpps;
            }
            
            if(!relatedQuotes.isEmpty()) {
                update relatedQuotes;
            }

            for(Quote q : relatedQuotes) {
                q.Skip_Status_Validation__c = false;
            }

            if(!relatedQuotes.isEmpty()) {
                update relatedQuotes;
            }
            
        } catch(Exception e) {
            System.debug('Error in cancelRelatedOpportunities: ' + e.getMessage());
            throw new AuraHandledException('Failed to cancel related opportunities: ' + e.getMessage());
        }
    }
    
    // Wrapper Classes
    public class CurrencyWrapper {
        @AuraEnabled public String isoCode;
        @AuraEnabled public Decimal conversionRate;
        @AuraEnabled public Integer decimalPlaces;
        
        public CurrencyWrapper(String isoCode, Decimal conversionRate, Integer decimalPlaces) {
            this.isoCode = isoCode;
            this.conversionRate = conversionRate;
            this.decimalPlaces = decimalPlaces;
        }
    }
    
    public class ResponseWrapper {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String newQuoteId;
        @AuraEnabled public String newOpportunityId;
        
        public ResponseWrapper() {
            this.success = false;
            this.message = '';
            this.newQuoteId = '';
            this.newOpportunityId = '';
        }
    }
}