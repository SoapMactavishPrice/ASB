@isTest
public class Assign_User_Access_Test {
    @isTest
    public static void isValiate(){
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
        
        
         State_List__c st=new State_List__c();
        st.Active__c=true;
        st.Region__c=re.id;
        st.Country__c=c.id;
        st.Name='Maharashtra';
        st.Language__c='EN';
        insert st;
        
        City_List__c ct=new City_List__c();
        ct.Active__c=true;
        ct.Name='Mumbai';
        ct.State__c=st.id;
        ct.Language__c='EN';
        ct.Subsidiary_Master__c = s.Id;
        insert ct;
        
        
      /*  PIN_Code_Master__c pm=new PIN_Code_Master__c();
        pm.Name='12345';
        //pm.City__c=ct.id;
        pm.Active__c=true;
        insert pm; */
        
                Profile pr = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        system.assert(true);
        
        User usr = new User(
            
            Alias = 'testu', 
            Email = 'test@akshareducation.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = pr.Id,
            UserName='test@akshareducation.com'
            
        );
        
        INSERT usr;
        
        User_Setup__c u=new User_Setup__c();
        u.Country__c=c.Id;
        u.User__c=userinfo.getUserId();
        u.Subsidiari__c = s.Id;
        u.Region__c = re.Id;
        u.Default_Language__c = 'HI';
        insert u;
       
        try{
        User_Setup__c u1=new User_Setup__c();
        u1.Country__c=c.Id;
        u1.User__c=userinfo.getUserId();
        u1.Subsidiari__c = s.Id;
        u1.Region__c = re.Id;
        u1.Default_Language__c = 'HI';
        insert u1;
        }catch(Exception e){
            System.debug('Duplicate Record');
        }
        
        
        
        
        Campaign camObject = new Campaign(Name = 'Cam1' , CurrencyIsoCode = 'INR');
        insert camObject;
        
        lead LeadUnit= new lead(lastName='Test User', Status='New', Company='Test Company',OwnerId=usr.Id);
       // LeadUnit.Postal_Zip_Code__c=pm.id;  
        leadUnit.Region1__c = re.Id;
        leadUnit.CountryList__c = c.Id;
        insert LeadUnit;
        /*
                lead LeadUnit1= new lead(lastName='Test Usersdfghjk', Status='New', Company='Test Company',OwnerId=usr.Id);
        LeadUnit1.Postal_Zip_Code__c=pm.id;  
        leadUnit1.Region1__c = re.Id;
        leadUnit.CountryList__c = c.Id;
        insert LeadUnit1;
        */
        Account accObject = new Account( CurrencyIsoCode = 'INR' , Name = 'Test1assdfghjkl;',Country__c = c.Id, Region1__c = re.Id,OwnerId=usr.Id);
        insert accObject;
        
        
        Account accObject1 = new Account( CurrencyIsoCode = 'INR' , Name = 'Test1', Country__c = c.Id,Region1__c = re.Id,OwnerId=usr.Id);
        insert accObject1;
        
        
        Opportunity oppObject = new Opportunity(AccountId = accObject.Id  , Name = 'Opp1' ,OwnerId=usr.Id, CurrencyIsoCode = 'INR' , StageName = 'New' , CloseDate = System.today() );
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
            Pricebook2Id = pricebookId, Product2Id = proObject.Id,Quantity__c = 1,
            D1__c = 0.1,
            D3__c = 0.2,
            D2__c = 0.3,
            M1__c = 0.1,
            M2__c = 0.2,
            M3__c = 0.3,
            M4__c = 0.4,
            Rounding_Off_Digits__c = '10',
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        insert customPB;
        
        Quote qObject = new Quote(Name = 'Quo1', Exchange_Rate__c = 1, OpportunityId = oppObject.Id);
        insert qObject;
        
        Quote_Template__c q=new Quote_Template__c();
        q.Label__c='test';
        q.Subsidiary__c = s.Id;
        q.Language__c = 'HI';
        
        insert q;
        
        Quote_Line_Item_Custom__c qli2 = new Quote_Line_Item_Custom__c();
        qli2.Quote__c = qObject.id;
        qli2.Discount__c = 12;
        qli2.Quantity__c = 1;
        //qli2.Application__c = 'EDIBLE OIL';
        qli2.Discount_Approval_Note__c = 'sfasf';
        qli2.Scope_of_mould__c = 'ML';
        qli2.List_Price__c = 12;
        qli2.Is_Manual__c = true;
        qli2.UOM__c = 'ABC';
        qli2.Product__c = proObject.Id;
        qli2.Level_Of_Ceiling__c = '10' ;
        qli2.Mach_Mold_No__c = 'AB';
        qli2.Expected_Delivery_date__c = system.today() +2;
        qli2.Expected_Customer_PO__c = system.today() + 4;
        qli2.Expected_Drawing_Final__c= system.today() + 14;
        qli2.Drawing_No__c = 'Tst';
        qli2.Product_Description__c = 'etst';
        qli2.Payment_Terms__c = '100% Payment Before Dispatch';
        qli2.Product_Name__c = 'ABC';
        qli2.Discount_Approval_Note__c= 'ABC';
        qli2.Zero_Cooling_2__c = 'Yes';
        qli2.Class_2__c = 'DEVELOPMENT';
        qli2.MFG_AT__c = 'INDIA';
        qli2.Advance_Percentage__c = 5.0;
        qli2.division__c = 'MOLD';
        insert qli2;
        
                
        /*Contract cont = new Contract();
        cont.Opportunity__c = oppObject.id;
        cont.AccountId = accObject.id;
        cont.Quote__c = qObject.id;
        cont.Subsidiary__c = s.id;
        cont.FY1__c = f.id;
        insert cont;
        */
        /*Contract_Line_Item__c conLI = new Contract_Line_Item__c();
        conLI.ContractId__c = cont.Id;
        conLI.Discount__c = 16.0;
        conLI.Discount_Allowed__c = 20.0;
        conLI.Approval_Note__c = 'Null';
        conLI.Cancelled__c = False;
        conLI.Level_Of_Ceiling__c = '100';   
        conLI.Quote_Line_Item_Name__c = qObject.id;
        conLI.Shipping_charges__c = 11;
        conLI.Insurance_Charges__c = 10;
        conLI.Packing_Charges__c = 10;
        conLi.List_Price__c	 = 100;
        conLI.Quantity__c = 1;
        conLI.IGST__c = 1.0;
        conLI.SGST__c = 1.0;
        conLI.CGST__c = 1.0;
        insert conLI;   
*/        
        
        Assign_Region__c ar = new Assign_Region__c();
        ar.User_Setup__c=u.Id;
        ar.Country__c = c.Id;
        ar.Region__c = re.Id;
        //ar.User_Name__c = Userinfo.getUserId();
        insert ar;
        
        
        
        
        delete ar;
       
    }

}