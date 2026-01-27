trigger PincodeMastertrigger on PIN_Code_Master__c (before insert,before update) {
    
    /*Set<String> names = new Set<String>();
Set<Id> cityIds = new Set<Id>();
Set<Id> Ids=new set<id>();
for(PIN_Code_Master__c ai : Trigger.New) {
names.add(ai.Name);
cityIds.add(ai.City__c);
Ids.add(ai.id);
}

List<City_List__c> cities = [select Id, State__r.Country__c from City_List__c where Id in: cityIds];
Map<Id, City_List__c> mapCities = new Map<Id, City_List__c>();
mapCities.putAll(cities);

List<PIN_Code_Master__c> pinList = [SELECT Id, Name, Active__c, City__c, City__r.State__r.Country__c,Language__c from PIN_Code_Master__c
Where Name in: names and Active__c =: true and id not in : Ids];

Map<String, PIN_Code_Master__c> mapPinCode = new Map<String, PIN_Code_Master__c>();
for(PIN_Code_Master__c item: pinList) {
mapPinCode.put(item.Name+':'+item.City__r.State__r.Country__c+':'+item.Language__c, item); // put -> {key : id, value: pin_code}
}

for(PIN_Code_Master__c item: Trigger.New) {
if(mapPinCode.containsKey(item.Name+':'+mapCities.get(item.City__c).State__r.Country__c+':'+item.Language__c) && item.Active__c) {
item.addError('Duplicate Record Found Please Enter Unique.');
}
}*/
    
    if(Trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate)){
        Set<String> names = new Set<String>();
        Set<Id> Ids=new set<id>();
        for(PIN_Code_Master__c ai : Trigger.New) {
            names.add(ai.Name);
            Ids.add(ai.id);
        }
        
        
        List<PIN_Code_Master__c> pinList = [SELECT Id, Name, Active__c from PIN_Code_Master__c
                                            Where Name in: names and Active__c =: true and id not in : Ids];
        
        Map<String, PIN_Code_Master__c> mapPinCode = new Map<String, PIN_Code_Master__c>();
        for(PIN_Code_Master__c item: pinList) {
            mapPinCode.put(item.Name,item); // put -> {key : id, value: pin_code}
        }
        
        for(PIN_Code_Master__c ai : Trigger.New) {
            if(mapPinCode.containsKey(ai.Name)) {
                ai.addError('Duplicate Record Found. Please Enter Unique Postal/Zip Code.');
            }
        }
    }
    
    
}