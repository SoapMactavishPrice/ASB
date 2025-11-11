public class numToWords {
    
    private static final List<String> smallnums = new List<String>{'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'};
    private static final List<String> tens = new List<String>{'', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'};
    private static final List<String> thousands = new List<String>{'', 'Thousand',   'Million',     'Billion',    'trillion',    'quadrillion',  
                    'quintillion', 's!xtillion',   'septillion',  'octillion',   'nonillion',  
                    'decillion',  'undecillion',   'duodecillion', 'tredecillion',  'quattuordecillion',  
                    's!xdecillion', 'septendecillion', 'octodecillion', 'novemdecillion', 'vigintillion'};
    
    
    public static String convert(Integer num, string currencyIsoCode ) {
        Map<String, String> strMap = new Map<String, String>();
        strMap.put('USD', 'US Dollars only.');
        strMap.put('JPY', 'Japanese Yen only.');
        strMap.put('EUR', 'Euro only.');
        string strCurrency = ' '+string.valueOf(strMap.get(currencyIsoCode));
        
        if (num == null) return 'Zero '+strMap.get(currencyIsoCode);
        if (num == 0) return 'Zero '+strMap.get(currencyIsoCode);

        String words = '';
        Integer thousandCounter = 0;

        if(num < 0){
            string n1 = string.valueOf(num).substringAfter('-');
            num= Integer.valueOf(n1);
        }
        while (num > 0) {
            Integer remainder = Math.mod(num, 1000);
            if (remainder > 0) {
                words = convertHundred(remainder) + thousands[thousandCounter] + ' ' + words;
            }
            num = Integer.valueOf(Math.floor(num / 1000));
            thousandCounter++;
        }

        return words.trim() + ' '+strMap.get(currencyIsoCode);
    }

    private static String convertHundred(Integer num) {
        String words = '';

        if (num >= 100) {
            Integer hundreds = Integer.valueOf(Math.floor(num / 100));
            words += smallnums[hundreds] + ' Hundred ';
            num = Math.mod(num, 100);
        }

        if (num >= 20) {
            Integer ten = Integer.valueOf(Math.floor(num / 10));
            words += tens[ten] + ' ';
            num = Math.mod(num, 10);
        }

        if (num > 0) {
            words += smallnums[num] + ' ';
        }

        return words;
    }
}