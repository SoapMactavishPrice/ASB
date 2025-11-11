public class QuoteLineOptionClass
{
    public string recordID;
    public List<Quote_Line_Item_Custom__c> QlineItm {get;set;}
    public Quote objQuote{get;set;}
    
    public QuoteLineOptionClass(ApexPages.StandardController stdController)
    {
        objQuote = (Quote)stdController.getRecord();
        recordID = objQuote.Id;
        objQuote = [Select id,AccountId,AdditionalAddress,AdditionalName,BillingAddress,BillingName,ContactId,Description,
                    Discount,Email,ExpirationDate,Fax,GrandTotal,LineItemCount,OpportunityId,Phone,CurrencyIsoCode,Name,
                    QuoteNumber,QuoteToAddress,QuoteToName,ShippingHandling,ShippingAddress,ShippingName,Status,Quote_Total_Summary_of_Sales_Price__c,
                    Subtotal,IsSyncing,Tax,TotalPrice,ACCOUNT_BUSINESS__c,ACCOUNT_TYPE__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,
                    ADVANCE_PAYMENT__c,CITY__c,CLOSE_LOST_REASON__c,Contact__r.name,COUNTRY__c,COUNTRY_CODE__c,DATE__c,Designation__c,END_CUSTOMER_NAME__c,
                    FUNCTION__c,INCO_TERMS__c,MFG_AT__c,POSTAL_CODE__c,PREPARED_BY__c,PROBABILITY__c,QUOTATION_ADDRESSED_TO__c,QUOTATION_CREATE__c,QU_REVISION_NUMBER__c,
                    /*REGION__c,*/SHIP_TO__c,SOLD_TO__c,STATE__c,SUBSIDARY__c,TYPE__c,VALIDITY__c,VALITY_DATE__c,Quote_Number__c,Pricebook2Id,ownerId,Total_Quote__c,Grand_Total__c
                    from Quote Where id =:recordID limit 1];
        QlineItm = new List<Quote_Line_Item_Custom__c>();
        showQuoteLineOptions();
    }
    
    public void showQuoteLineOptions()
    {
        QlineItm = [select Product__c, Product__r.Name,List_Price__c,Name,Quantity__c,Division__c,Total_List_Price__c,Total_Sales_Price__c,Discount__c,
                    (select Name,Product_Name__c,Manula_Option_List_Price__c,Option_Number__c,Discount__c,Final_Price__c, quantity__c, Manual_Option_Base_Price__c from Quote_Line_Options__r)
                    from Quote_Line_Item_Custom__c where Quote__c = :recordID order by Name ];
        sYSTEM.DEBUG('QlineItm' +QlineItm);
    }
}