// Converts a manual item/option amount from one currency to another
// using the conversion rate stored in the Manual_Item_Option_Currency_Rate__mdt
public class ManualCurrencyConverter {
    public static Decimal convert(Decimal amount, String fromIso, String toIso) {

        Manual_Item_Option_Currency_Rate__mdt rate = [
            SELECT Conversion_Rate__c
            FROM Manual_Item_Option_Currency_Rate__mdt
            WHERE From__c = :fromIso
              AND To__c   = :toIso
            LIMIT 1
        ];

        return amount * rate.Conversion_Rate__c;
    }
}