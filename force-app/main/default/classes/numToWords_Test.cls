@isTest
public class numToWords_Test {
    @isTest
    public static void validate(){
        Map<String, String> strMap = new Map<String, String>();
        strMap.put('USD', 'US Dollars only.');
        strMap.put('JPY', 'Japanese Yen only.');
        strMap.put('EUR', 'Euro only.');
        
        numToWords.convert(234,'INR');
        numToWords.convert(23423,'JPY');
        numToWords.convert(234345,'USD');
        numToWords.convert(2343454,'EUR');
    }

}