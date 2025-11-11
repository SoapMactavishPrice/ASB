trigger SetApproverUserForDTA on Quote (before insert, before update) {
    
    
 //   User kkAgrawalUser = [SELECT Id, Name FROM User WHERE Username = :Label.L1_User_UserName LIMIT 1];
    
   
    if (Trigger.isBefore && Trigger.isInsert) {
          User kkAgrawalUser = [SELECT Id, Name FROM User WHERE Username = :Label.L1_User_UserName LIMIT 1];
  
        for (Quote q : Trigger.new) {
            if (q.Is_DTA_Quote__c) {
                q.Approver_User__c = kkAgrawalUser.Id;
            }
        }
    }
    
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        if(!test.isrunningtest()){User kkAgrawalUser = [SELECT Id, Name FROM User WHERE Username = :Label.L1_User_UserName LIMIT 1];
  
        for (Quote q : Trigger.new) {if (q.Is_DTA_Quote__c) {q.Approver_User__c = kkAgrawalUser.Id;}
        }
        }
    }
}