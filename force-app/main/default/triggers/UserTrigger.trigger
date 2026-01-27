trigger UserTrigger on User (Before Update) {
    
    
    if(Trigger.isBefore && Trigger.isUpdate){
        
        Id currentProfileId = UserInfo.getProfileId();
        
        // Check if the logged-in user is a System Administrator
        Profile currentUserProfile = [SELECT Name FROM Profile WHERE Id = :currentProfileId limit 1];
        
        set<Id> usId = new set<Id> ();
        for(User us : Trigger.new){
            usId.add(us.Id);
        }
        
        if(usId.size() > 0){
            map<Id ,user> us2Map = new map<Id ,user>([SELECT Id, Name,Profile.Name FROM User WHERE Id IN : usId]);
            
            for(User us : Trigger.new){
                if(us2Map.containskey(us.Id)){
                    system.debug('inside if'+us2Map.get(us.Id).Profile.Name +'-- '+currentUserProfile.Name);
                    if(currentUserProfile.Name !='System Administrator' && Trigger.oldMap.get(us.Id).UserRoleId != us.UserRoleId){
                        system.debug('inside 2 nd if');
                        us.addError('If you want to change your role, please contact the system administrator.');    
                    }
                }
            }
        }
        
    }
    
}