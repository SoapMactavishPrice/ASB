@isTest
public class UserSetupTrigger_Test {

    public Static testMethod void unitTest(){
        Fiscal_Year_Master__c f= new Fiscal_Year_Master__c();
        f.Active__c=true;
        f.Fiscal_Year_Start_Date__c=system.today()-65;
        f.Fiscal_Year_End_Date__c=system.today()+300;
        f.Name='44';
        insert f;
        
        Subsidiari_Master__c s = new Subsidiari_Master__c();
        s.Name = 'ABC';
        s.Name__c = 'xyg';
        s.Active__c = true;
        s.Office__c = 'Airforce';
        s.Rounding_Off_Digits__c = '10000';
        s.Permitted_Currency__c = 'INR';
        s.Permitted_Language__c = 'EN';
        s.Discount_Level_1__c = 5;
        s.Discount_Level_2__c = 10;
        s.Discount_Level_3__c = 15;
        s.Quote_Approval__c ='Line Item level';
        s.Contract_Approval__c = 'Line Item level';
        s.Permitted_Language__c = 'HI';
        insert s;
        
        Country_List__c c=new Country_List__c();
        c.Active__c = true;
        c.Name = 'India';	
        c.Subsidiary__c=s.id;
        insert c;
        
        Region__c re = new Region__c();
        re.Active__c = true;
        re.Country__c = c.Id;
        re.Name = 'EAST';
        re.Name__c = 'EAST';
        insert re;
        
        User_Setup__c u=new User_Setup__c();
        u.Country__c=c.Id;
        u.User__c=Userinfo.getUserId();
        u.Subsidiari__c = s.Id;
        u.Region__c = re.Id;
        u.Default_Language__c = 'HI';
        insert u;
       
        try{
        User_Setup__c u1=new User_Setup__c();
        u1.Country__c=c.Id;
        u1.User__c=Userinfo.getUserId();
        u1.Subsidiari__c = s.Id;
        u1.Region__c = re.Id;
        u1.Default_Language__c = 'HI';
        insert u1;
        }catch(Exception e){
            System.debug('Duplicate Record');
        }
        
        
        Assign_Region__c ar = new Assign_Region__c();
        ar.User_Setup__c=u.Id;
        ar.Country__c = c.Id;
        ar.Region__c = re.Id;
        insert ar;
        
        Campaign camObject = new Campaign(Name = 'Cam1' , CurrencyIsoCode = 'INR');
        insert camObject;
        
        Account accObject = new Account( CurrencyIsoCode = 'INR' , Name = 'Test1', Region1__c = re.Id);
        insert accObject;
        
        Opportunity oppObject = new Opportunity(AccountId = accObject.Id  , Name = 'Opp1' , CurrencyIsoCode = 'INR' , StageName = 'New' , CloseDate = System.today() );
        insert oppObject;
        
        Product2 proObject = new Product2(CurrencyIsoCode   = 'INR' , Name = 'Pro1', isActive = TRUE);
        insert proObject;
        
        Pricebook2  priObject = new Pricebook2(Name = 'Pri1' );
        insert priObject;
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Options');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = proObject.Id,
                    D1__c = 0.1,
    D3__c = 0.2,
    D2__c = 0.3,
    
   M1__c = 0.1,
   M2__c = 0.2,
   M3__c = 0.3,
   M4__c = 0.4,

            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        insert customPB;
        
        Quote qObject = new Quote(Name = 'Quo1', Exchange_Rate__c = 1, OpportunityId = oppObject.Id );
        insert qObject;
        
        Quote_Template__c q=new Quote_Template__c();
        q.Label__c='test';
        q.Subsidiary__c = s.Id;
        q.Language__c = 'HI';
        insert q;
        
    }
}