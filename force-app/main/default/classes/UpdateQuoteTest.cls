@isTest
public class UpdateQuoteTest {
	
    @isTest
    public static void isValidate(){
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id, 
                         Level__c='L1'); 
        
        insert uu;
        
        Subsidiari_Master__c sub = new Subsidiari_Master__c();
        sub.Name = 'A12';
        sub.Name__c = 'xyg';
        sub.Active__c = true;
        sub.Office__c = 'Airforce';
        sub.Rounding_Off_Digits__c = '10000';
        sub.Permitted_Currency__c = 'INR';
        sub.Permitted_Language__c = 'EN';
        sub.Discount_Level_1__c = 5;
        sub.Discount_Level_2__c = 10;
        sub.Discount_Level_3__c = 15;
        sub.Quote_Approval__c ='Line Item level';
        insert sub;
        
        Country_List__c cl = new Country_List__c();
        cl.Name = 'India';
        cl.Country_Code__c = '+91';
        cl.Subsidiary__c = sub.Id;
        insert cl;
        
        User_Setup__c us = new User_Setup__c();
        us.User__c = UserInfo.getUserId();
        us.Country__c = cl.Id;
        insert us;
        
        Fiscal_Year_Master__c fym = new Fiscal_Year_Master__c();
        fym.Active__c = true;
        fym.Name = 'A44';
        fym.Fiscal_Year_Start_Date__c = System.today();
        fym.Fiscal_Year_End_Date__c = System.today() + 10 ; 
        insert fym;
        
        Account acc = new Account();
        acc.CurrencyIsoCode = 'INR';
        acc.Name = 'VJ';
        acc.ADDRESS_LINE_1__c = 'add 1';
        acc.ADDRESS_LINE_2__c = 'add 2';
        acc.ADDRESS_LINE_3__c = 'add 3';
        acc.Pin_Code__c = '2501';
        //acc.Subsidiary__c = sub.id;
        insert acc;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.IsActive = true;
        insert pb;
        
        opportunity op = new Opportunity();
        op.CurrencyIsoCode = 'INR';
        op.Name= 'test opp';
        op.StageName = 'New';
        op.CloseDate = system.today() + 10;
        op.AccountId = acc.id;
        op.Pricebook2Id = pb.id;
        op.Subsidiary__c = sub.id;
        insert op;
        
        
        Account acc1 = new Account();
        acc1.CurrencyIsoCode = 'INR';
        acc1.Name = 'VewrtycznmJ';
        acc1.ADDRESS_LINE_1__c = 'add 1';
        acc1.ADDRESS_LINE_2__c = 'add 2';
        acc1.ADDRESS_LINE_3__c = 'add 3';
        acc1.Pin_Code__c = '2501';
        //acc.Subsidiary__c = sub.id;
        insert acc1;
        
        
        Account acc2 = new Account();
        acc2.CurrencyIsoCode = 'INR';
        acc2.Name = 'VhkdthsrtyukilyturyehsdkhJ';
        acc2.ADDRESS_LINE_1__c = 'add 1';
        acc2.ADDRESS_LINE_2__c = 'add 2';
        acc2.ADDRESS_LINE_3__c = 'add 3';
        acc2.Pin_Code__c = '2501';
        //acc.Subsidiary__c = sub.id;
        insert acc2;
        
        quote qt = new quote();
        qt.CurrencyIsoCode = 'INR';
        qt.Status = 'Released';
        qt.Name = 'qt test';
        qt.Exchange_Rate__c = 1;
        qt.OpportunityId = op.id;
        //qt.AccountId = acc.Id;
        qt.Language__c = 'EN';
        qt.Discount__c = 3;
        qt.SUBSIDARY__c = sub.id;
        qt.Subsidiary__c = sub.id;
        qt.Sync_Quote__c = false;
        
        qt.SOLD_TO__c = acc2.Id;
        qt.SHIP_TO__c = acc1.Id;
        
        
        
        insert qt;
        
         
        
        string js = '{"shippingSubRegionName":null,"shippingStateName":null,"shippingRegionMaster":null,"shippingPostalZipCode":null,"shippingCountryName":"India","shippingCityName":null,"shippingAddressLine3":null,"shippingAddressLine2":null,"shippingAddressLine1":null,"globalSubRegion":null,"globalRegion":null,"billingStateName":"Maharashtra","billingPostalZipCode":"444604","billingCountryName":"India","billingCityName":"Amravati","addressLine3":"AAA","addressLine2":"AA","addressLine1":"AA"}';
        UpdateQuote.getAccountAddress(acc.Id);
        UpdateQuote.updateQuoteAddress(acc.Id,js);
        Contract cont1 = new Contract();
        cont1.Opportunity__c = op.id;
        cont1.AccountId = acc.id;
        cont1.status ='Created';
        cont1.Quote__c = qt.id;
        cont1.Discount__c = 10 ;
        cont1.Subsidiary__c = sub.id;
        cont1.FY1__c = fym.id;
        cont1.Contract_Locked_for_Approval__c = true;
        cont1.SOLD_TO__c = acc.Id;
        cont1.SHIP_TO__c = acc.Id;
        insert cont1;
        
        UpdateQuote.updateContractAddress(acc.Id,js);
        
    }
}