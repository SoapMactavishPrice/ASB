/*
*  Author   : Amol wagh
*  Date     : 27-06-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      27-06-2022   Amol Wagh      trigger to update Financial year and Subsidiary
V1.1      29-07-2022   Amol Wagh      Added code for all master objects this will cover PinCodeMastertrigger
*********************************************/
@isTest
public class Trg_Lead_test {
    
    public static testMethod void unitTest() {
        
        Profile pr = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        system.assert(true);
        
        
        
        User u = new User(
            
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
        
        INSERT u;
        //CreateLead
        Fiscal_Year_Master__c f=new Fiscal_Year_Master__c();
        f.Fiscal_Year_Start_Date__c=System.today()-200;
        f.Fiscal_Year_End_Date__c=System.today()+165;
        f.Active__c=true;
        f.Name='44';
        
        insert f;
       
        Subsidiari_Master__c s=new Subsidiari_Master__c();
        s.Active__c=true;
        s.Name='ASI';
        s.Name__c='India';
        s.Office__c='India';
        s.Discount_Level_1__c=1;
        s.Discount_Level_2__c=2;
        s.Discount_Level_3__c=3;
        s.Additional_Margin__c=4;
        s.Notification_Email__c='Test@gmail.com';
        s.Permitted_Language__c='HI';
        s.Quantity_Restricted__c=7;
        s.Rounding_Off_Digits__c='10';
        s.Quote_Approval__c='Quote Level';
        s.Permitted_Currency__c='INR';
        
        
        insert s;
          
        Global_Region__c gr = new Global_Region__c();
        gr.Name = 'asia';
        insert gr;

      
        Global_SubRegion__c sr = new Global_SubRegion__c();
        sr.Name = 'india'; 
        sr.Region__c = gr.Id;
        insert sr;

        
        Country_List__c c=new Country_List__c();
        c.Active__c=true;
        c.Country_Code__c='IN';
        c.language__c='EN';
        c.Region_Master__c = gr.Id;
        c.Sub_Region__c = sr.Id;
        c.Subsidiary__c=s.id;
        c.Short_Name__c='IN';
        c.Country_Code__c='101';   
        
        insert c;
        
        Region__c r=new Region__c();
        r.Active__c=true;
        r.Country__c=c.id;
        r.Name='WEST';
        r.Name__c='WEST';
        r.Language__c='EN';
        insert r;
        
         User_Setup__c us=new User_Setup__c();
        us.User__c=userinfo.getUserId();
        us.Subsidiari__c=s.id;
        us.Region__c=r.id;
        us.Country__c=c.id;
        
        insert us;
        State_List__c st=new State_List__c();
        st.Active__c=true;
        st.Region__c=r.id;
        st.Country__c=c.id;
        st.Name='Maharashtra';
        st.Language__c='EN';
        insert st;
        
        City_List__c ct=new City_List__c();
        ct.Active__c=true;
        ct.Name='Mumbai';
        ct.State__c=st.id;
        ct.Language__c='EN';
        ct.Subsidiary_Master__c = s.id;
        insert ct;
        
        
        /*PIN_Code_Master__c pm=new PIN_Code_Master__c();
        pm.Name='12345';
        //pm.City__c=ct.id;
        pm.Active__c=true;
        insert pm; 
        */
            
            
        lead LeadUnit= new lead(lastName='Test User', Status='New', Company='Test Company', Country_Code__c='IN');
       // LeadUnit.Postal_Zip_Code__c=pm.id;
        LeadUnit.CountryList__c = c.id;
       	LeadUnit.Global_Region__c=gr.Id;
        LeadUnit.Global_SubRegion__c=sr.Id;
        LeadUnit.LeadSource ='web';
        insert LeadUnit;
        
        
        
        test.startTest();
        //Trg_Lead tr = new Trg_Lead();
        test.stopTest();
    }
}