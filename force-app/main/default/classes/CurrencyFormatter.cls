global class CurrencyFormatter {
    
    public static string MapValues(string currencyCode ,Date input_date) {
        
        Map<String, object> locale_map = new Map<String, object>(); //holds the locale to timedate formats
        system.debug('currencyCode'+currencyCode);
        string dtr = '';
        string inputMonth = string.valueOf(input_date.Month());
        string inputDays = string.valueOf(input_date.day());
        if(input_date.Month() < 10){
           inputMonth = '0'+input_date.Month();
        }
        
        if(input_date.day() < 10){
           inputDays = '0'+input_date.day();
        }
        
        if(currencyCode == 'USD'){
            dtr = inputMonth + '/' + inputDays + '/' + input_date.year();
        }   
        
        if(currencyCode == 'INR'){
            dtr = inputDays + '.' + inputMonth + '.' + input_date.year();
        } 
        
        if(currencyCode == 'AED' || currencyCode == 'RUB' || currencyCode == 'BRL'){
            dtr = inputDays + '/' + inputMonth + '/' + input_date.year();
        } 
        
        if(currencyCode == 'BRL'){
            dtr = inputDays + '/' + inputMonth + '/' + input_date.year();
            
        }
        
        if(currencyCode == 'GBP'){
            dtr = inputDays + '/' + inputMonth + '/' + input_date.year();
        }
        
        if(currencyCode == 'EUR'){
            dtr = inputDays + '/' + inputMonth + '/' + input_date.year();
            
        } 
        
        if(currencyCode == 'JPY'){
            dtr = input_date.year() + '/' + inputMonth + '/' + inputDays;
            
        }
        
        
        if(currencyCode == 'SGD'){
            dtr = inputMonth + ' ' + inputDays + ',' + input_date.year();
            
        }
        
        if(currencyCode == 'LKR'){
            dtr = inputDays + '-' + inputMonth + '-' + input_date.year();
            
        }
        
        if(currencyCode == 'CAD'){
            dtr = input_date.year() + '-' + inputMonth + '-' + inputDays;
            
        }
        
        if(currencyCode == 'MXV'){
            dtr = inputDays + '/' + inputMonth + '/' + input_date.year();
            
        }
        
        system.debug('currencyCode'+dtr);
        
        
        return dtr; //return the map
        
    }
    
    public static string formatDouble(Decimal myNumber,string isCurrency){
        system.debug('myNumber'+myNumber);
        List<string> CurrencyCodeList = new List<string>(); 
        CurrencyCodeList.add('INR');
        //CurrencyCodeList.add('JPY');
        
        String formattedString = '';
        boolean bless = false; 
        String myNumberAsString = String.valueOf(myNumber).substringBefore('.');
        if(myNumber < 0){
            bless = true;
            myNumberAsString = myNumberAsString.replace('-','');
        }
        
        string decimAfter = String.valueOf(myNumber).substringAfter('.');
        integer i = Integer.valueOf(myNumberAsString);
        if(CurrencyCodeList.contains(isCurrency)){
            if(i>999999999){
                formattedString += myNumberAsString.substring(0,myNumberAsString.length()-9)+ ',' + myNumberAsString.substring(myNumberAsString.length()-9,myNumberAsString.length()-7) + ',' + myNumberAsString.substring(myNumberAsString.length()-7,myNumberAsString.length()-5) + ',' + myNumberAsString.substring(myNumberAsString.length()-5,myNumberAsString.length()-3) + ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
            } else if(i < 999999999 && i > 9999999){
                formattedString += myNumberAsString.substring(0,myNumberAsString.length()-7)+','+ myNumberAsString.substring(myNumberAsString.length()-7,myNumberAsString.length()-5)+ ',' + myNumberAsString.substring(myNumberAsString.length()-5,myNumberAsString.length()-3) + ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
            }else if(i < 9999999 && i > 99999){
                formattedString += myNumberAsString.substring(0,myNumberAsString.length()-5)+ ',' + myNumberAsString.substring(myNumberAsString.length()-5,myNumberAsString.length()-3) + ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
            }
            else if(i>999 && i < 99999){
                formattedString += myNumberAsString.substring(0,myNumberAsString.length()-3)+ ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
            } 
            else {
                formattedString += myNumberAsString;
            }
        }
        else{
            if(i > 999999999){
                formattedString += myNumberAsString.substring(0,myNumberAsString.length()-9)+','+ myNumberAsString.substring(myNumberAsString.length()-9,myNumberAsString.length()-6)+ ',' + myNumberAsString.substring(myNumberAsString.length()-6,myNumberAsString.length()-3) + ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
            }else if(i < 999999999 && i > 999999){
                formattedString += myNumberAsString.substring(0,myNumberAsString.length()-6)+ ',' + myNumberAsString.substring(myNumberAsString.length()-6,myNumberAsString.length()-3) + ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
                 system.debug('deciaml'+formattedString);
            }
            else if(i>999 && i < 999999){
                formattedString += myNumberAsString.substring(0,myNumberAsString.length()-3)+ ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
            } 
            else {
                formattedString += myNumberAsString;
            }
            
        }
        
        
        if(string.isNotblank(decimAfter)){
            formattedString =formattedString+'.'+decimAfter;
        }else{
            formattedString =formattedString+'.00';
        }
        
        if(bless){
            formattedString = '-'+formattedString;
        }
        
        system.debug('formattedString'+formattedString);
        return formattedString;
    }
    
    
}