trigger Trg_Contact on Contact (before insert, before update) {

    for(Contact Cont: trigger.new){
        Cont.Designation__c = cont.title;
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        for(Contact Cont: trigger.new){
            if(cont.Salutation !=null){
                if(cont.FirstName != null){
                    Cont.Name_in_Local_language__c = cont.Salutation+' '+cont.FirstName+' '+cont.LastName;
                }else{
                    Cont.Name_in_Local_language__c = cont.Salutation+' '+cont.LastName;
                }
            }else{
                if(cont.FirstName != null){
                Cont.Name_in_Local_language__c = cont.FirstName+' '+cont.LastName;
                }else{
                    Cont.Name_in_Local_language__c = cont.LastName;
                }
            }
                
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Contact Cont: trigger.new){
           if(cont.Salutation !=null){
                if(cont.FirstName != null){
                    Cont.Name_in_Local_language__c = cont.Salutation+' '+cont.FirstName+' '+cont.LastName;
                }else{
                    Cont.Name_in_Local_language__c = cont.Salutation+' '+cont.LastName;
                }
            }else{
                if(cont.FirstName != null){
                Cont.Name_in_Local_language__c = cont.FirstName+' '+cont.LastName;
                }else{
                    Cont.Name_in_Local_language__c = cont.LastName;
                }
            }
                
        }
    }
        
}