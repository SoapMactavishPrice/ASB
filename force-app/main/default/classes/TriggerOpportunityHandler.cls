public class TriggerOpportunityHandler {
    
    Public Opportunity ObjOppty{get;set;}
    public Account objAcct{get;set;}
    public List<task> ObjTask{get;set;}
    
    public void OpptyRecUpdate(String OpptyId){
        String RecordId = OpptyId;
        ObjOppty = [select id, name,AccountId from Opportunity where Id =: RecordId limit 1];
        System.debug('ObjOppty : : '+ObjOppty);
        String AccountId = ObjOppty.AccountId;
        
        objAcct = [select id,name,Account_Business__c,Account_Type__c,sales_Address__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,
                   City__c,Country__c,Countries__c,Country_Code__c,Customer_Category__c,ERP_ID__c,External_ID__c,Global_Customer__c,Global_Customer_ID__c,
                   GSTIN_No__c,sales_Industry__c,sales_No_of_Employees__c,PAN__c,Party_Group_Name__c,Pin_Code__c,Prepared_By__c
                   ,sales_Rating__c,/*Region__c,*/SF_ID__c,Global_Customer_Name__c,State__c,States__c,Subsidary__c,TIN__c,Parentid,Parent.SF_ID__c
                   from Account where id=:AccountId limit 1];
        System.debug('objAcct'+objAcct);
        
        if(objAcct.ERP_ID__c != null && objAcct.ERP_ID__c != ''){
            ObjOppty.ERP_ID__c = objAcct.ERP_ID__c;
        }
        if(objAcct.ParentId != null){
            ObjOppty.Parent_Account__c = objAcct.ParentId;
        }
         if(objAcct.ParentId != null){
            ObjOppty.Parent_Account_Id__c = objAcct.Parent.sf_id__c;
        }
        if(objAcct.Global_Customer_ID__c != null && objAcct.Global_Customer_ID__c != ''){
            ObjOppty.Global_Customer_Id__c = objAcct.Global_Customer_ID__c;
        }
        if(objAcct.Global_Customer_Name__c != null && objAcct.Global_Customer_Name__c != ''){
            ObjOppty.Global_Customer_Name__c = objAcct.Global_Customer_Name__c;
        }
        if(objAcct.Account_Type__c != null){
            ObjOppty.Account_Type__c = objAcct.Account_Type__c;
        }
        if(objAcct.Customer_Category__c != null){
            ObjOppty.Probability__c = objAcct.Customer_Category__c;
        }
        
        update ObjOppty;
        
    }
    
   /* public void updateVisitOnOpportunity(List<Opportunity> newOpportunity, Map<Id, Opportunity> mapOpportunity)
    {
        List<String> lstLeadId = new List<String>();
        for (Opportunity opp : newOpportunity)
        {
            if (opp.Lead_Id__c != null && opp.Lead_Id__c !='')
            {
                lstLeadId.add(opp.Lead_Id__c);
            }
        }
        if (lstLeadId.Size() >0 && lstLeadId !=null)
        {
            List<Task> lstNewTask = new List<Task>();
            List<Task> lstTask = [select id, subject, Visit_Information__c, OwnerId, Priority, Status, WhoId from task where subject='Visit' and WhoId in :lstLeadId ];
            if (lstTask.Size() > 0 && lstTask !=null)
            {
                for (Task t1 : lstTask)
                {
                    Task tt = new Task();
                    tt.subject = t1.Subject;
                    tt.Visit_Information__c = t1.Visit_Information__c;
                    tt.Priority = t1.Priority;
                    tt.Status = t1.Status;
                    tt.WhoId  = newOpportunity[0].id;
                    lstNewTask.add(tt);
                }
                
                Database.Insert(lstNewTask);
            }
        }
        
    } */
    
    
    Public void OnUpdateOpportunity(String RecordId){
       String OpptyId =  RecordId;
      //  ObjTask = [Select id,name,Subject,WhatId From Activitites];
       // ObjOppty = [Select Id , name,stagename from Opportunity]
    }
    
     
    
}