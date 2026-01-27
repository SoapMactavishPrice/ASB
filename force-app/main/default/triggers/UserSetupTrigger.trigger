trigger UserSetupTrigger on User_Setup__c (before insert,before update) {
   Map<Id,User_Setup__c> uMap=new Map<id,User_Setup__c>();
    For(User_Setup__c us:[select id,name,user__c,user__r.id from User_Setup__c])
    {
        uMap.put(us.user__r.id,us);
    }
    
    for(User_Setup__c u:trigger.new)
    {
      if(uMap.containsKey(u.user__c) && u.id!=uMap.get(u.user__c).id)
      {
          u.addError('Duplicate Record found for this User.');
      }
    }
}