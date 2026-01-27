@isTest
public class QuoteCreationCMPController_test {

    public static testMethod void validateTestMethod1(){
        
        Fiscal_Year_Master__c f= new Fiscal_Year_Master__c();
        f.Active__c=true;
        f.Fiscal_Year_Start_Date__c=system.today()-65;
        f.Fiscal_Year_End_Date__c=system.today()+300;
        f.Name='NPL';
        insert f;
        
        Subsidiari_Master__c s = new Subsidiari_Master__c();
        s.Name = 'IPL';
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
        
        Assign_Region__c ar = new Assign_Region__c();
        ar.User_Setup__c=u.Id;
        ar.Country__c = c.Id;
        ar.Region__c = re.Id;
        insert ar;
        
        Campaign camObject = new Campaign(Name = 'Cam1' , CurrencyIsoCode = 'INR');
        insert camObject;
        
        Account accObject = new Account( CurrencyIsoCode = 'INR' , Name = 'Test1', Region1__c = re.Id);
        insert accObject;
        
        Contact con = new Contact();
        con.lastName = 'lname';
        con.AccountId = accObject.id;
        con.Title = 'dev';
        //con.Phone = 9837371155;
        con.Email = 'vd@gmail.com';
        insert con;

        Opportunity oppObject = new Opportunity(AccountId = accObject.Id  , Name = 'Opp1' ,Contact__c=con.Id, CurrencyIsoCode = 'INR' , StageName = 'New' , CloseDate = System.today() );
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
            UnitPrice = 10000, 
            UseStandardPrice= false,
            IsActive = true,
            Base_Price__c = 123,
            Discount_Level_3__c = 12,
            Pricing_Type__c = 1,
            Quantity__c = 1,
            D1__c = 0.1,
            D3__c = 0.2,
            D2__c = 0.3,
            M1__c = 0.1,
            M2__c = 0.2,
            M3__c = 0.3,
            M4__c = 0.4,
            Rounding_Off_Digits__c = '10');
        insert standardPrice;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true
                                            );
        insert customPB;
        
        QuoteRecursionCheck.isfirsttime=false;
        Quote qObject = new Quote(Name = 'Q1', Exchange_Rate__c = 1, OpportunityId = oppObject.Id );
        insert qObject;
        
        Quote_Template__c q=new Quote_Template__c();
        q.Label__c='test';
        q.Subsidiary__c = s.Id;
        q.Language__c = 'HI';
        q.Active__c = true;
        insert q;

        Quote_Line_Item_Custom__c qli = new  Quote_Line_Item_Custom__c(Quote__c = qObject.Id , Product__c = proObject.Id,
                                                                       Is_Manual__c = false, UOM__c = 'Test UOM', Product_Description__c = 'Test Data', 
                                                                       Model__c = 'Test Model', Division__c = 'MACHINE', Product_Type__c = 'MC',
                                                                       Scope_of_mould__c = 'Test Scope', Cavity__c = 12.00, List_Price__c = 10,
                                                                       Product_Name__c = 'ASB12M COMPLETE MOLD_2CAVITY',Level_Of_Ceiling__c ='10',
                                                                       Quantity__c = 4, Base_Price__c = 1, Discount__c = 20,Approved_Discount__c = 10,
                                                                       Discount_Approval_Note__c = 'Approval Test'
                                                                      );
        insert qli;
        
        Quote_Line_Item_Custom__c qli1 = new  Quote_Line_Item_Custom__c(Quote__c = qObject.Id , Product__c = proObject.Id,
                                                                        Is_Manual__c = true,  UOM__c = 'Test UOM', Product_Description__c = 'Test Data',
                                                                        Model__c = 'Test Model', Division__c = 'MACHINE', Product_Type__c = 'MC',
                                                                        Scope_of_mould__c = 'Test Scope', Cavity__c = 12.00, List_Price__c = 10,Level_Of_Ceiling__c ='10',
                                                                        Product_Name__c = 'ASB12M COMPLETE MOLD_2CAVITY',
                                                                        Quantity__c = 4, Base_Price__c = 1, Discount__c = 20,Approved_Discount__c = 5,
                                                                        Discount_Approval_Note__c = 'Approval Test'
                                                                       );
        insert qli1;
        
        Quote_Line_Options__c Qlioptions = new Quote_Line_Options__c(Quote__c = qObject.Id, Quote_Line_Item_Custom__c = qli1.Id,
                                                                     Manual_Product_Name__c = 'Manual testing', Product__c = proObject.Id, Select_Option__c = true,
                                                                     Discount__c = 3.00, Description__c = 'Test Option', Discount_Description__c ='Another test',
                                                                     quantity__c = 4, Manula_Option_List_Price__c = 123456.98,
                                                                     Manual_Option_Base_Price__c = 5465767.87, Manual_Option__c = 'False',
                                                                     Option_Number__c = 'Test-3',
                                                                     Discount_Type__c = 'Value',
                                                                     Mould_Cavity__c=21, Price_Type__c = 1, Manual_Option_Function__c = 'Add',
                                                                     Other_Charges__c='NA', Other_Charges_Base_Price__c = 123458.88,
                                                                     Other_Charges_Function__c='Add');
        
        insert Qlioptions;
        
        Quote_Line_Options__c Qlioptions2 = new Quote_Line_Options__c(Quote__c = qObject.Id, Quote_Line_Item_Custom__c = qli.Id,
                                                                     Manual_Product_Name__c = 'Manual testing', Product__c = proObject.Id, Select_Option__c = false,
                                                                     Discount__c = 3.00, Description__c = 'Test Option', Discount_Description__c ='Another test',
                                                                     quantity__c = 4, Manula_Option_List_Price__c = 123456.98,
                                                                     Manual_Option_Base_Price__c = 5465767.87, Manual_Option__c = 'False',
                                                                     Option_Number__c = 'Test-3',Discount_Type__c = 'Value',
                                                                     Mould_Cavity__c=21, Price_Type__c = 1, Manual_Option_Function__c = 'Add',
                                                                     Other_Charges__c='NA', Other_Charges_Base_Price__c = 123458.88,
                                                                     Other_Charges_Function__c='Add');
        
        insert Qlioptions2;
        
        Quote qObject2 = new Quote(Name = 'New Quo1', Exchange_Rate__c = 1, OpportunityId = oppObject.Id );
        insert qObject2;
        
        Quote_Line_Item_Custom__c qli2 = new  Quote_Line_Item_Custom__c(Quote__c = qObject2.Id , Product__c = proObject.Id,
                                                                        Is_Manual__c = True,  UOM__c = 'Test', Product_Description__c = 'Test Data',
                                                                        Model__c = 'Test Model', Division__c = 'MACHINE', Product_Type__c = 'MC',
                                                                        Scope_of_mould__c = 'Test Scope', Cavity__c = 12.00, List_Price__c = 10,
                                                                        Product_Name__c = 'ASB12M COMPLETE MOLD_2CAVITY',
                                                                        Quantity__c = 4, Base_Price__c = 1, Discount__c = 20,Approved_Discount__c=5,
                                                                        Discount_Approval_Note__c = 'Approval Test'
                                                                       );
        insert qli2;
        
    
        String rec = String.valueOf(oppObject.id);
        String cRate = String.valueOf(qObject2.Exchange_Rate__c);
        String aMargin = '10.654';
        Quote QuoteClone  = QObject.clone(false, false, false, false);
        // String str = 'Name,AccountNumber,Type,Accountsource,Industry\n Esha Patharabe,10001,Prospect,Test,Banking\n Trupti Nimje,10002,Prospect,Test,Banking';       
        
        Test.StartTest();
        QuoteCreationCMPController.IntialDataFetch(oppObject.Id);
        QuoteCreationCMPController.CheckQuoteTemplate();
        ApexPages.currentPage().getParameters().put('Id',qObject2.id);
        QuoteCreationCMPController.createBlankQuoteController(qObject.Name ,oppObject.id,'INR', cRate, aMargin);
        QuoteCreationCMPController.cloneExistingQuote(qObject.Id , qObject2.Name,'INR', rec, cRate, aMargin,accObject.Id,accObject.Id);
        QuoteCreationCMPController.importQuoteFromCSV('str', oppObject.Id);
        Test.StopTest();
    }
    
    
}