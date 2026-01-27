public class assignRecordTypecls {
    
    public static map<string,string> getRecordTypeList(string sObjectType) {
        List<RecordType> recList= [SELECT Id, Name, DeveloperName, Description, SobjectType, IsActive FROM RecordType where SobjectType=:sObjectType and IsActive =: true];
        
        map<string,string> recTypeMap= new map<string,string>();
        for(RecordType rec: recList){
            recTypeMap.put(rec.Name,rec.Id);
            }
        return recTypeMap;
        }
    
    
    
}