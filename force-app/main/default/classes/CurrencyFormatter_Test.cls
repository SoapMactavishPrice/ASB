@isTest
public class CurrencyFormatter_Test {
    @isTest
    public static void isValidate(){
        test.startTest();
        List<string> strlist = new List<string>();
        strlist.add('INR');
        strlist.add('USD');
        strlist.add('AED');
        strlist.add('RUB');
        strlist.add('BRL');
        
        strlist.add('GBP');
        
        strlist.add('EUR');
        
        strlist.add('JPY');
        
        strlist.add('SGD');
        strlist.add('LKR');
        strlist.add('CAD');
        strlist.add('MXV');
        
        for(integer i  = 0; i < strlist.size() ; i++){
            CurrencyFormatter.MapValues(strlist[i],date.today());
        }
        
        CurrencyFormatter.formatDouble(43356789,'INR');
        CurrencyFormatter.formatDouble(789,'INR');
        CurrencyFormatter.formatDouble(-46789,'INR');
        CurrencyFormatter.formatDouble(456789,'INR');
        
        test.stopTest();
    }

}