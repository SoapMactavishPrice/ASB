trigger GenerateUniqueNo on Quote_Line_Item_Custom__c (before update,before delete,before insert) {
    if(Trigger.isBefore && trigger.isUpdate){
        
        set<Id> qliId = new set<Id>();
        for(Quote_Line_Item_Custom__c qli : trigger.new){
            system.debug('give only 15 Quantity__c -->'+qli.Quantity__c+' - '+Trigger.oldMap.get(qli.Id).Quantity__c);
           // system.debug('give only 15 digit -->'+Trigger.oldMap.get(qli.Id).Quantity__c);
            //Trigger.oldMap.get(qli.Id).Quantity__c = 10;
            if(qli.Quantity__c < Trigger.oldMap.get(qli.Id).Quantity__c && string.isNotBlank(qli.Quote__c)){                qliId.add(qli.Quote__c);
            }
            //if(test.isRunningTest()){
              //  if(qli.Quantity__c > 0){
                //qliId.add(qli.Quote__c);
                //}
            //}
        }
        if(qliId.size()> 0){
            Quote qte = [select Id,Project_Management_Quote_Id__c from Quote where Id IN : qliId limit 1];
            List<String> quoteIds = new List<String> ();
            if(string.isNotBlank(qte.Project_Management_Quote_Id__c)){quoteIds= qte.Project_Management_Quote_Id__c.split(',');
            }else{quoteIds.add(qte.Id);
            }
            
            if(quoteIds.size() > 0){
                List<ProjectManagement__c> pmoList = [Select Id,Sq_No__c,Product__c,Quote_Name__c,Project_Unique_No__c from ProjectManagement__c where Quote_Name__c IN : quoteIds and Phase__c !='Cancelled' 
                                                      and Phase__c !='Close']; 
                map<string, Integer> pmoMap = new   map<string, Integer>();
                for(ProjectManagement__c pmo : pmoList){
                    string str  = pmo.Project_Unique_No__c;if(pmoMap.containsKey(str)){ pmoMap.put(str,pmoMap.get(str)+1);}else{pmoMap.put(str,1); }            
                }
                
                if(pmoMap.size() > 0){
                    for(Quote_Line_Item_Custom__c qli : trigger.new){
                        string str  =qli.Project_Unique_No__c;// qli.Original_Quote__c + '_'+qli.Product_Name__c+'_'+qli.Sr_No__c;
                        if(qli.Quantity__c < Trigger.oldMap.get(qli.Id).Quantity__c){ if(pmoMap.containsKey(str)){  qli.Quantity__c.addError('You cannot decrease the quantity because a project management record already exists.'); 
                            }
                        }
                    }
                }
            }   
        }
    }
    
    if(Trigger.isBefore && trigger.isUpdate){
        
        set<Id> qliId = new set<Id>();
        for(Quote_Line_Item_Custom__c qli : trigger.new){
            if(qli.Quantity__c != Trigger.oldMap.get(qli.Id).Quantity__c && string.isNotBlank(qli.Quote__c)){
                system.debug('give only 15 digit -->'+qli.Quote__c);
                qliId.add(qli.Quote__c);
            }
        }
        
        if(qliId.size()> 0){
            Quote qte = [select Id,Project_Management_Quote_Id__c from Quote where Id IN : qliId limit 1];
            List<String> quoteIds = new List<String> ();
            if(string.isNotBlank(qte.Project_Management_Quote_Id__c)){quoteIds= qte.Project_Management_Quote_Id__c.split(',');
            }else{
                quoteIds.add(qte.Id);
            }
            
            if(quoteIds.size() > 0){
                List<ProjectManagement__c> pmoList = [Select Id,Sq_No__c,Project_Unique_No__c,Phase__c,Product__c,Quote_Name__c,Contract_Line_Item__r.Product2Id__r.ProductCode from ProjectManagement__c where Quote_Name__c IN : quoteIds 
                                                      and (Phase__c =:'Cancelled' or Phase__c =:'Amendment') 
                                                     ]; 
                system.debug('pmoList==+'+pmoList.size());
                map<string, Integer> pmoMap = new   map<string, Integer>();
                for(ProjectManagement__c pmo : pmoList){
                    string str  =pmo.Project_Unique_No__c;// pmo.Product__c+'_'+pmo.Contract_Line_Item__r.Product2Id__r.ProductCode;
                    
                    if(pmoMap.containsKey(str)){if(pmo.Phase__c =='Amendment'){ pmoMap.put(str,pmoMap.get(str)+1);}  }else if(pmo.Phase__c =='Cancelled'){pmoMap.put(str,1);
                    }            
                }
                
                system.debug('pmoMap==+'+pmoMap);
                if(pmoMap.size() > 0){
                    for(Quote_Line_Item_Custom__c qli : trigger.new){
                        string str  = qli.Project_Unique_No__c; if(qli.Quantity__c  != Trigger.oldMap.get(qli.Id).Quantity__c){if(pmoMap.containsKey(str) && pmoMap.get(str) > 0){qli.Quantity__c.addError('You cannot Increase/Decrease the quantity because a project management record is Cancelled.'); 
                            }
                        }
                    }
                }
            }   
        }
    }
    
    
    if(Trigger.isBefore && trigger.isDelete){
        set<Id> qliId = new set<Id>();
        for (Quote_Line_Item_Custom__c qli : Trigger.old) {
            if(qli.Quantity__c > 0 && string.isNotBlank(qli.Quote__c)){
                system.debug('give only 15 digit -->'+qli.Quote__c);
                qliId.add(qli.Quote__c);
            }
            
        }
        
        List<String> quoteIds = new List<String> ();
        
        if(qliId.size()> 0){
            Quote qte = [select Id,Project_Management_Quote_Id__c from Quote where Id IN : qliId limit 1];
            
            if(string.isNotBlank(qte.Project_Management_Quote_Id__c)){
                quoteIds= qte.Project_Management_Quote_Id__c.split(',');}else{quoteIds.add(qte.Id);}
        }
        
        if(quoteIds.size() > 0){
            List<ProjectManagement__c> pmoList = [Select Id,Sq_No__c,Product__c,Project_Unique_No__c,Quote_Name__c,Contract_Line_Item__r.Product2Id__r.ProductCode from ProjectManagement__c where Quote_Name__c IN : quoteIds
                                                  and Phase__c =:'Amendment' ];
            
            //Map<Id,Quote> qMap =  [Select Id from Quote ];
            map<string, Integer> pmoMap = new   map<string, Integer>();
            for(ProjectManagement__c pmo : pmoList){
                //string str  = string.valueOf(pmo.Quote_Name__c).substring(0, 15)  + '_'+pmo.Product__c+'_'+pmo.Sq_No__c;
                string str  = pmo.Project_Unique_No__c;//pmo.Product__c+'_'+pmo.Contract_Line_Item__r.Product2Id__r.ProductCode;
                if(pmoMap.containsKey(str)){pmoMap.put(str,pmoMap.get(str)+1);
                }else{
                    pmoMap.put(str,1);
                }            
            }
            
            if(pmoMap.size() > 0){
                for(Quote_Line_Item_Custom__c qli : trigger.old){
                    string str  = qli.Project_Unique_No__c;//qli.Product_Name__c+'_'+qli.Product_Code__c;
                    if(qli.Quantity__c > 0){
                        if(pmoMap.containsKey(str)){qli.addError('You cannot Delete the Quote Line Item '+ qli.Name +' because a project management record already exists.'); 
                        }
                    }
                }
            }
        }   
    }
    
    /* List<Unique_No__c> uniqueNosToCreate = new List<Unique_No__c>();

Set<Id> quoteIds = new Set<Id>();
Set<Id> fiscalYearIds = new Set<Id>();
Set<Id> subsidiary = new Set<Id>();

// Collect data for processing
for (Quote_Line_Item_Custom__c quo : Trigger.new) {
if(quo.Is_Manual__c && String.isBlank(quo.Manual_Product_Code__c)) {
quoteIds.add(quo.Quote__c);
fiscalYearIds.add(quo.Fiscal_Year__c);
subsidiary.add(quo.Subsidiary__c);
}
}

// If fiscal year and subsidiary are present, proceed with querying Unique_No__c records
if(fiscalYearIds.size() > 0 && subsidiary.size() > 0) {
system.debug('Manual check -> fiscalYearIds -> ' + fiscalYearIds);
system.debug('Manual check -> subsidiary -> ' + subsidiary);

// Query Unique_No__c records for the matching Subsidiary and Fiscal Year
List<Unique_No__c> insertedUniqueNos = [
SELECT Id, Name, Serial_No__c, Subsidiary__c, Subsidiary__r.Name, Object_Name__c, Fiscal_Year__c, Fiscal_Year__r.Name
FROM Unique_No__c 
WHERE Object_Name__c = 'Manual Product' 
AND Subsidiary__c IN :subsidiary 
AND Fiscal_Year__c IN :fiscalYearIds
];

system.debug('Manual check -> insertedUniqueNos -> ' + insertedUniqueNos.size());

// Create a map to store the Unique_No__c records
Map<String, Unique_No__c> unq = new Map<String, Unique_No__c>();

// Populate the map with key as 'SubsidiaryId_FiscalYear'
for (Unique_No__c uniqueNo : insertedUniqueNos) {
String subsidiaryId = String.valueOf(uniqueNo.Subsidiary__c);
// Remove last 3 characters only if necessary (this could be specific to your logic)
subsidiaryId = subsidiaryId.substring(0, subsidiaryId.length() - 3);

String fiscalYearId = String.valueOf(uniqueNo.Fiscal_Year__c);
fiscalYearId = fiscalYearId.substring(0, fiscalYearId.length() - 3);

String key = subsidiaryId + '_' + fiscalYearId;
unq.put(key, uniqueNo);
}

system.debug('Manual check -> Unique_No__c Map -> ' + unq);

// Process each Quote_Line_Item_Custom__c and generate Manual_Product_Code__c
for (Quote_Line_Item_Custom__c quo : Trigger.new) {
if(quo.Is_Manual__c && String.isBlank(quo.Manual_Product_Code__c)) {
String key = String.valueOf(quo.Subsidiary__c) + '_' + String.valueOf(quo.Fiscal_Year__c);
system.debug('Manual check -> Inside Key -> ' + key);

// Check if the map contains the key and if so, update the Manual_Product_Code__c
if(unq.containsKey(key)) {
Unique_No__c unc = unq.get(key);
String temp = '';
Decimal srNo = unc.Serial_No__c + 1;

// Create a zero-padded serial number
for (Integer i = 7; i > String.valueOf(srNo).length(); i--) {
temp += '0';
}
temp += String.valueOf(srNo);

// Generate Manual Product Code
quo.Manual_Product_Code__c = 'M' + unc.Subsidiary__r.Name + unc.Fiscal_Year__r.Name + '-' + temp;
unc.Serial_No__c = srNo;
system.debug('Manual_Product_Code__c -> ' + quo.Manual_Product_Code__c);
}
}
}

// Update the modified Unique_No__c records (if any)
if (!unq.isEmpty()) {
update unq.values();
}
}	*/
    
    
    if(Trigger.isBefore && Trigger.isInsert){
        for(Quote_Line_Item_Custom__c qle : trigger.new){
            if(string.isBlank(qle.Project_Unique_No__c)){
                string uniqueNo ='';
                if(string.isNotBlank(qle.Product_Name__c)){
                    uniqueNo+=qle.Product_Name__c+'_';
                }
                if(string.isNotBlank(qle.Product_Code__c)){uniqueNo+=qle.Product_Code__c+'_';
                }
                if(string.isNotBlank(qle.Manual_Product_Code__c)){uniqueNo+=qle.Manual_Product_Code__c+'_';
                }
                DateTime now = DateTime.now();
                uniqueNo+= now.format('dd_MM_yyyy_HH_mm_ss');
                qle.Project_Unique_No__c = uniqueNo;
            }
            
        }
    }
}