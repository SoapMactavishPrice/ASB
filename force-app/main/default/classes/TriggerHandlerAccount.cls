public class TriggerHandlerAccount {
    Public List<Account> ObjAcctList{get;set;} 
    
  /*  public static void assignRecordType(List<Account> newRecordList){
        map<string,string> recMap = assignRecordTypecls.getRecordTypeList('Account');
        for(Account acc: newRecordList){
            if(acc.Is_DTA_Account__c){
                acc.recordTypeId = recMap.get('DTA');
            }else{
                acc.recordTypeId = recMap.get('USA');
            }
        }
        
    } */
    //=======================================SHUBHAM KADU (14th June 2025)=============================================
       public static void assignRecordType(List<Account> newRecordList) {
    Map<String, String> recMap = assignRecordTypecls.getRecordTypeList('Account');

    // Collect Subsidiary IDs
    Set<Id> subsidiaryIds = new Set<Id>();
    for (Account acc : newRecordList) {
        if (acc.Subsidiary__c != null) {
            subsidiaryIds.add(acc.Subsidiary__c);
        }
    }

    // Query Subsidiary Names
    Map<Id, Subsidiari_Master__c> subMap = new Map<Id, Subsidiari_Master__c>(
        [SELECT Id, Name FROM Subsidiari_Master__c WHERE Id IN :subsidiaryIds]
    );

    // Assign RecordType based on Subsidiary Name
    for (Account acc : newRecordList) {
        if (acc.Subsidiary__c != null && subMap.containsKey(acc.Subsidiary__c)) {
            String subName = subMap.get(acc.Subsidiary__c).Name;
            if (subName == 'ASI') {
                acc.RecordTypeId = recMap.get('DTA'); // DTA Record Type
            } else {
                acc.RecordTypeId = recMap.get('USA'); // USA Record Type
            }
        }
    }
}
    //=================================================================================
    
    public static void AccountUpdate(List<String> AcctIdList){
        List<Account> ObjAcctList =new List<Account>(); 
        map<id,Account> AccMap=new Map<id,Account>();
        ObjAcctList = [Select id,CurrencyIsoCode,Name,AccountNumber,Ownerid,Site,AccountSource,AnnualRevenue,BillingAddress,
                       Jigsaw,Description,NumberOfEmployees,Fax,Industry,Ownership,ParentId,Phone,Rating,ShippingAddress,
                       Type,Website,Account_Business__c,Account_Type__c,sales_Address__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,
                       ADDRESS_LINE_3__c,City__c,Country__c,Countries__c,Country_Code__c,Customer_Category__c,ERP_ID__c,External_ID__c,FY__c,
                       Global_Customer__c,Global_Customer_ID__c,Global_Customer_Name__c,GSTIN_No__c,sales_Industry__c,sales_No_of_Employees__c,
                       PAN__c,Party_Group_Name__c,Pin_Code__c,Prepared_By__c,sales_Rating__c,/*,Region__c,*/SF_ID__c,State__c,States__c,Subsidary__c,
                       TIN__c from Account where id in: AcctIdList];
        
        
        for(Account a:ObjAcctList)
        {
            AccMap.put(a.id,a);
        }
        
        List<Opportunity> ListObjOppty = new List<Opportunity>();
        
        ListObjOppty = [Select id,Accountid,sales_Any_Customized_Requirement__c,APPLICATION__c,APPROXIMATE_AMOUNT__c,AUTO_NUMBER_ASSIGNED__c,
                        Budget_Confirmed__c,Class__c,COMMENT__c,DETAILS__c,Discovery_Completed__c,Drawing_Request__c,ERP_ID__c,
                        FEASIBILITY_STUDY__c,Feasibilty_Study_Result__c,FY__c,Global_Customer_Id__c,Global_Customer_Name__c,Lead_Id__c,Loss_Reason__c,
                        Opportunity_Number__c,Opportunity_Number1__c,Parent_Account__c,Parent_Account_Id__c,Parent_Company_Name__c,Prepared_By__c,
                        Probability__c,Request_Date__c,ROI_Analysis_Completed__c,Source__c,STUDY_REQUEST_DATE__c,Subsidaries__c 
                        from Opportunity
                        where AccountId In:AcctIdList ];
        
        System.debug('ListObjOppty'+ListObjOppty);
        System.debug('ListObjOppty'+ListObjOppty.size());
        
        List<Opportunity> ls1 = new List<Opportunity>();
        
        
        if(ListObjOppty != null){
            for(Opportunity ObjOppty : ListObjOppty){
                Account ObjAcct =new Account();  
                Opportunity pro = new Opportunity();
                ObjAcct=AccMap.get(ObjOppty.Accountid);
                
                if(ObjOppty.Id != null){
                    pro.id = ObjOppty.Id;
                }
                if(objAcct.ERP_ID__c != null && objAcct.ERP_ID__c != ''){
                    pro.ERP_ID__c = objAcct.ERP_ID__c;
                }
                if(objAcct.ParentId != null){
                    pro.Parent_Account__c = objAcct.ParentId;
                }
                if(objAcct.ParentId != null){
                    pro.Parent_Account_Id__c = objAcct.ParentId;
                }
                if(objAcct.Customer_Category__c != null && objAcct.Customer_Category__c != ''){
                    pro.Probability__c = objAcct.Customer_Category__c;
                }
                if(objAcct.Global_Customer_ID__c != null && objAcct.Global_Customer_ID__c != ''){
                    pro.Global_Customer_Id__c = objAcct.Global_Customer_ID__c;
                }
                if(objAcct.Global_Customer_Name__c != null && objAcct.Global_Customer_Name__c != ''){
                    pro.Global_Customer_Name__c = objAcct.Global_Customer_Name__c;
                }
                if(objAcct.Account_Type__c != null){
                    pro.Account_Type__c = objAcct.Account_Type__c;
                }
                
                
                ls1.add(pro);
            }
        }
        try{
            update ls1;
            System.debug('ls1'+ls1);
        }Catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
        
    }
    
    
    
    
    
}