public class CommonData {
    
    public static decimal getExchangeRate(string currencyCode){
        
        CurrencyType ctype=[select Id, IsCorporate, IsoCode, ConversionRate, DecimalPlaces 
                            from CurrencyType where IsActive=true and IsoCode=:currencyCode limit 1 ];
          return ctype.ConversionRate;
    }

}