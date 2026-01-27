@isTest
public class CurrencyToWords_test {
    public static testMethod void unitTest1(){
        integer num = 12;
        integer num6 = 21;
        Double num2 = 123.32;
        Decimal num3 = 23.2;
        Decimal num5 = 100001.4;
        String num4 = '372036854775807284';
        CurrencyToWords ctw = new CurrencyToWords();
        ctw.CurrencyToWordsFormat(num);
        ctw.CurrencyToWordsFormat(num2);
        ctw.CurrencyToWordsFormat(num3);
        
        //ConvertCurrencyToWords ctw2 = new ConvertCurrencyToWords();
        ConvertCurrencyToWords.convert_nn(num6);
        ConvertCurrencyToWords.convert_nnn(num);
        ConvertCurrencyToWords.english_number(num5);
        ConvertCurrencyToWords.convert(Long.valueOf(num4));
        
        //-------------------------------------------------------------------------------
        Decimal num7 = 123456567.7;
        NumberTOWordConvertion toWrd = new NumberTOWordConvertion();
        toWrd.getNumberTOWordConvertion(num7);
    }
}