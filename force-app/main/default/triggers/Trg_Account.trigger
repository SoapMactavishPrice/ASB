/*
*  Author   : Amol Wagh
*  Date     : 5-05-2022
----------------------------------------------------------------------
Version  Date         Author             Remarks
=======   ==========   =============  ==================================
V1.1      6-05-2022   Amol Wagh      trigger to update Financial year.
*********************************************/
trigger Trg_Account on Account (After Update,After insert,Before Insert,Before Update){
    
    if(Trigger.isBefore && Trigger.isInsert){
       TriggerHandlerAccount.assignRecordType(Trigger.new);
    }
    
    
    
    if(trigger.isAfter && trigger.isUpdate){
        List<id>accountIds=new List<id>();
        for(Account ObjAcct : trigger.new){
            //if(trigger.newMap.get(ObjAcct.Id) != trigger.oldMap.get(ObjAcct.Id)){
                String AcctId = ObjAcct.Id;
                accountIds.add(AcctId);
            //}  
        }
        // call handler
        TriggerHandlerAccount TriggerHandler = new TriggerHandlerAccount();
        TriggerHandlerAccount.AccountUpdate(accountIds);
        
    }
    
    if(trigger.isBefore && (trigger.isInsert)){
        // V1.1 
        List<id> ids =new list<id>();
        map<id,PIN_Code_Master__c> addMap=new map<id,PIN_Code_Master__c>();
        
        
        Fiscal_Year_Master__c f=[select id,name from Fiscal_Year_Master__c where Active__c=true limit 1]; 
        User_Setup__c u=[Select id,name,Subsidiari__c from User_Setup__c where user__c=:userinfo.getUserId() limit 1];
        for(Account objAct : trigger.new){
          /*  if(objAct.Is_Converted__c){
                objAct.Financial_Year__c=f.id; // V1.1 
                objAct.Subsidiary__c = u.Subsidiari__c;        */
                
                //=====================SHUBHAM KADU (14th June 2025)======================
                if(objAct.Subsidiary__c == null){
                    objAct.Subsidiary__c = u.Subsidiari__c;
                }
                
                if(objAct.Is_Converted__c){
                    objAct.Financial_Year__c = f.Id;
                //===========================================
                if(objAct.Legal_Name__c==Null ||objAct.Legal_Name__c=='')
                {
                    objAct.Legal_Name__c=objAct.name;
                }
                if(objAct.Billing_Country__c != null){
                    objAct.Shipping_Country__c = objAct.Billing_Country__c;
                }
                if(objAct.Billing_State__c != null){
                    objAct.Shipping_State__c = objAct.Billing_State__c;
                }
                if(objAct.Billing_City__c != null){
                    objAct.Shipping_City__c = objAct.Billing_City__c;
                }
                if(objAct.ADDRESS_LINE_1__c != null){
                    objAct.Shipping_Address_Line_1__c = objAct.ADDRESS_LINE_1__c;
                }
                if(objAct.ADDRESS_LINE_2__c != null){
                    objAct.Shipping_Address_Line_2__c = objAct.ADDRESS_LINE_2__c;
                }
                if(objAct.ADDRESS_LINE_3__c != null){
                    objAct.Shipping_Address_Line_3__c = objAct.ADDRESS_LINE_3__c;
                }
                if(objAct.Pin_Code__c != null){
                    objAct.Shipping_Postal_Code__c = objAct.Pin_Code__c;
                }
            }
            ids.add(objAct.Billing_Postal_ZIP_Code__c);
        }
        /* List<PIN_Code_Master__c> addList=[SELECT id,City__r.State__r.Region__c 
from PIN_Code_Master__c where id IN:ids];
for(PIN_Code_Master__c pin:addList )
{
addMap.put(pin.id,pin);  
}
for(Account ai: trigger.new)
{ 
if(ai.Billing_Postal_ZIP_Code__c!=null)
ai.Region1__c = addMap.get(ai.Billing_Postal_ZIP_Code__c).City__r.State__r.Region__c;
}
*/    
    } 
    
    
    if(trigger.isBefore && (Trigger.IsUpdate)){
        
        List<id> ids =new list<id>();
        map<id,PIN_Code_Master__c> addMap=new map<id,PIN_Code_Master__c>();
        
        
        for(Account objAct : trigger.new){
            if(objAct.Is_Converted__c){
                if(objAct.Billing_Country__c != null){
                    objAct.BillingCountry = objAct.Billing_Country__r.name;
                }
                if(objAct.Billing_State__c != null){
                    objAct.BillingState = objAct.Billing_State__r.name;
                }
                if(objAct.Billing_City__c != null){
                    objAct.BillingCity = objAct.Billing_City__r.name;
                }
                if(objAct.Shipping_Country__c != null){
                    objAct.ShippingCountry = objAct.Shipping_Country__r.name;
                }
                if(objAct.Shipping_State__c != null){
                    objAct.ShippingState = objAct.Shipping_State__r.name;
                }
                if(objAct.Shipping_City__c != null){
                    objAct.ShippingCity = objAct.Shipping_City__r.name;
                }
                if(objAct.Pin_Code__c != null){
                    objAct.BillingPostalCode = objAct.Pin_Code__c;
                }
                if(objAct.Shipping_Postal_Code__c != null){
                    objAct.ShippingPostalCode = objAct.Shipping_Postal_Code__c;
                }
                ids.add(objAct.Billing_Postal_ZIP_Code__c);
            }
        } 
        /* List<PIN_Code_Master__c> addList=[SELECT id,City__r.State__r.Region__c 
from PIN_Code_Master__c where id IN:ids];
for(PIN_Code_Master__c pin:addList )
{
addMap.put(pin.id,pin);  
}

for(Account ai: trigger.new)
{ 
if(addMap.containskey(ai.Billing_Postal_ZIP_Code__c) && addMap.get(ai.Billing_Postal_ZIP_Code__c)!=null)
//ai.Region1__c = addMap.get(ai.Billing_Postal_ZIP_Code__c).City__r.State__r.region__c;
}
*/
    }
    
    system.debug('<=== Started selected in Subsidiary Permited Currency ===>');
    
    
    if(Trigger.IsBefore && (trigger.isUpdate || trigger.isInsert)) {
        
        Map<String, Account> idSubAccMap = new Map<String, Account>();
        map<String,List<String>> idlistCurrencyMap = new map<String,List<String>>();
        
        for(Account acc : trigger.new) {
            system.debug('Account.Subsidiari Master' + acc.Subsidiary__c); 
            idSubAccMap.put(acc.Subsidiary__c, acc);
        }
        system.debug('idSubAccMap'+idSubAccMap);
        
        List<Subsidiari_Master__c> subList = [SELECT Id, Permitted_Language__c, Permitted_Currency__c
                                              FROM Subsidiari_Master__c WHERE Id IN :idSubAccMap.keySet()];
        system.debug('subList' +subList);
        for(Subsidiari_Master__c sub : subList) 
        {   
            idlistCurrencyMap.put(sub.id,sub.Permitted_Currency__c.split(';'));
            system.debug('in loop idlistCurrencyMap==> ' +idlistCurrencyMap);
        }
        
        for(Account accsub:trigger.new){
            if(accsub.Subsidiary__c!=null){
                if(!idlistCurrencyMap.get(accsub.Subsidiary__c).contains(accsub.CurrencyIsoCode)){
                    accsub.addError('Your Account Currency must be the same as your Subsidiary Currency.');
                }
            }
        }
    }
    system.debug('<=== Ended selected in Subsidiary Permited Currency ===>');
    
    
    if(Trigger.isInsert && Trigger.isAfter){
        List<Address_Information__c> adList = new List<Address_Information__c>();
        for(Account acc : Trigger.new){
            if(!acc.Is_Converted__c){
                Address_Information__c adi = new Address_Information__c();
                adi.Account__c = acc.Id;
                adi.State__c = acc.Shipping_State__c;
                adi.Pin_Code__c = acc.Shipping_Postal_ZIP_Code__c;
                adi.City__c = acc.Shipping_City__c;
                adi.Country__c = acc.billing_country__c;
                adi.Field_Address_1__c = acc.Shipping_Address_Line_1__c;
                adi.Field_Address_2__c = acc.Shipping_Address_Line_2__c;
                adi.Field_Address_3__c = acc.Shipping_Address_Line_3__c;
                adi.Region__c = acc.Region1__c;
                adi.Is_Primary__c = false;
                adi.Type__c = 'Ship To';
                adList.add(adi);
            }
            
        }
        
        if(adList.size() > 0){
            insert adList;
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        set<Id> accId = new set<Id>();
        Map<Id,Account> billToAddmap = new Map<Id,Account>();
        Map<Id,Account> shipToAddmap = new Map<Id,Account>();
        for(Account ac : Trigger.new){
            accId.add(ac.Id);
            //if(Trigger.oldMap.get(ac.Id).Billing_Country__c	 != ac.Billing_Country__c){
            billToAddmap.put(ac.Id,ac);
            //accId.add(ac.Id);
            //}
            //if(Trigger.oldMap.get(ac.Id).Shipping_Country__c!= ac.Shipping_Country__c	){
            shipToAddmap.put(ac.Id,ac);
            //accId.add(ac.Id);
            //}
        }
        
        List<Address_Information__c> addressList = [select Id,Account__c,Country__c,Type__c from Address_Information__c where Account__c IN : accId and (Type__c=:'Bill To' or Type__c=:'Ship To') ];
        
        map<Id,Address_Information__c> ToUpdateaddressList  = new map<Id,Address_Information__c>();
        for(Address_Information__c adr : addressList){
            if(billToAddmap.containsKey(adr.Account__c) && adr.Type__c=='Bill To'){
                adr.Country__c = billToAddmap.get(adr.Account__c).Billing_Country__c;
                ToUpdateaddressList.put(adr.Id,adr);
            }
            
            if(shipToAddmap.containsKey(adr.Account__c) && adr.Type__c=='Ship To'){
                adr.Country__c = shipToAddmap.get(adr.Account__c).Shipping_Country__c;
                ToUpdateaddressList.put(adr.Id,adr);
            }
            
        }
        
        if(ToUpdateaddressList.size() > 0){
            update ToUpdateaddressList.values();
        }
        
        
        /*
List<Opportunity> oplIst = [select Id, Name ,AccountId,Global_Region__c,Global_SubRegion__c from Opportunity where AccountId IN : accId];
List<Opportunity> opsList = new List<Opportunity>();

for(Opportunity ops : oplIst){
if(billToAddmap.containsKey(ops.AccountId)){
ops.Global_Region__c = billToAddmap.get(ops.AccountId).Global_Region__c;
ops.Global_SubRegion__c = billToAddmap.get(ops.AccountId).Global_SubRegion__c;
opsList.add(ops);
}
}

if(opsList.size() > 0){
update opsList;
}


List<Quote> quList = [select Id ,AccountId,Global_Region__c,Global_SubRegion__c from Quote where AccountId IN : accId];

List<Quote> quoList = new List<Quote>();
for(Quote qu :quList ){
if(billToAddmap.containsKey(qu.AccountId)){
qu.Global_Region__c = billToAddmap.get(qu.AccountId).Global_Region__c;
qu.Global_SubRegion__c = billToAddmap.get(qu.AccountId).Global_SubRegion__c;
}

if(shipToAddmap.containsKey(qu.AccountId)){
qu.Ship_To_Global_Region__c = shipToAddmap.get(qu.AccountId).Shipping_Region_Master__c;
qu.Ship_To_Global_SubRegion__c = shipToAddmap.get(qu.AccountId).Shipping_Sub_Region__c;
}
quoList.add(qu); 
}

if(quoList.size() > 0){
update quoList;
}

List<ProjectManagement__c> pmnList = [select Id, Name,Account__c,Global_Region__c,Global_SubRegion__c from ProjectManagement__c where Account__c IN : accId];
List<ProjectManagement__c> pmnListToUpdate = new List<ProjectManagement__c>();

for(ProjectManagement__c pm : pmnList){
if(billToAddmap.containsKey(pm.Account__c)){
pm.Global_Region__c = billToAddmap.get(pm.Account__c).Global_Region__c;
pm.Global_SubRegion__c = billToAddmap.get(pm.Account__c).Global_SubRegion__c;
pmnListToUpdate.add(pm);
}
}
if(pmnListToUpdate.size() > 0){
update pmnListToUpdate;
}


List<Contract> contraList = [select Id, Name,Account__c,Global_Region__c,Global_SubRegion__c from Contract where Account__c IN : accId];
List<Contract> contractListToUpdate = new List<Contract>();

for(ProjectManagement__c pm : contraList){
if(billToAddmap.containsKey(pm.Account__c)){
pm.Global_Region__c = billToAddmap.get(pm.Account__c).Global_Region__c;
pm.Global_SubRegion__c = billToAddmap.get(pm.Account__c).Global_SubRegion__c;
contractListToUpdate.add(pm);
}
}

if(pmnListToUpdate.size() > 0){
update pmnListToUpdate;
}*/
    }
    
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        Map<Id,Country_List__c>contryMap = new Map<Id,Country_List__c>();
        Map<Id,Id> shipToId = new Map<Id,Id>();
        set<Id> countId = new set<Id>();
        for(Account ac: Trigger.new ){
            if(string.isnotBlank(ac.Billing_Country__c)){
                countId.add(ac.Billing_Country__c);
            }
            if(string.isnotBlank(ac.Shipping_Country__c)){
                countId.add(ac.Shipping_Country__c);
            }
        }
        
        List<Country_List__c> clist = [select Id,Sub_Region__c,Region_Master__c from Country_List__c where Id IN : countId];
        for(Country_List__c con : clist){
            contryMap.put(con.Id,con);
        }
        
        
        for(Account ac: Trigger.new ){
            if(contryMap.containsKey(ac.Billing_Country__c)){
                ac.Global_SubRegion__c = contryMap.get(ac.Billing_Country__c).Sub_Region__c;
                ac.Global_Region__c = contryMap.get(ac.Billing_Country__c).Region_Master__c;
            }
            
            if(contryMap.containsKey(ac.Shipping_Country__c)){
                ac.Shipping_Sub_Region__c = contryMap.get(ac.Shipping_Country__c).Sub_Region__c;
                ac.Shipping_Region_Master__c = contryMap.get(ac.Shipping_Country__c).Region_Master__c;
            }
        }        
    }
    
    if(Trigger.isBefore &&(Trigger.isUpdate || Trigger.isInsert)){
        for (Account acc : Trigger.new) {
            
            if (acc.LastModifiedById != null) {
                
                acc.Prepared_By__c = acc.LastModifiedById;
                
            }
        }
    }    
    
    if(Trigger.isBefore){
        if(trigger.isInsert ){
          for (Account obj : Trigger.new) {
                //if (string.isNotblank(obj.Region1__c)) {
                    obj.Region_Text_Backend__c =obj.Region_Text_Backend_for__c; 
                //}
            }
              
        }
        
        if(Trigger.isUpdate){
            for (Account obj : Trigger.new) {
                if (obj.Region1__c!= Trigger.oldMap.get(obj.Id).Region1__c) {
                    obj.Region_Text_Backend__c =obj.Region_Text_Backend_for__c; 
                }
            }
            
        }
    }
    /*
    If(Trigger.isBefore && Trigger.isUpdate){
    for (Account acc : Trigger.new) {
        
        if (acc.Copy_Billling_Add_To_Shipping_Add__c == true) 
        {
            
            acc.Shipping_Address_Line_1__c = acc.ADDRESS_LINE_1__c;
            acc.Shipping_Address_Line_2__c = acc.ADDRESS_LINE_2__c;
            acc.Shipping_Address_Line_3__c = acc.ADDRESS_LINE_3__c;
            acc.Shipping_City__c = acc.Billing_City__c;
            acc.Shipping_State__c = acc.Billing_State__c;
            acc.Shipping_Region_Master__c = acc.Global_Region__c;
            acc.Shipping_Sub_Region__c = acc.Global_SubRegion__c;
            acc.Shipping_Postal_ZIP_Code__c = acc.Billing_Postal_ZIP_Code__c;
            acc.Shipping_Country__c = acc.Billing_Country__c;
        }
    }
    } */
    
   // ==========================================================================================
   // SHUBHAM KADU - 16/Jan/2025
   // ==========================================================================================
   if ((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)) {
        for (Account acc : Trigger.new) {
            
            // If the checkbox is checked, copy billing address to shipping address
            if (acc.Copy_Billling_Add_To_Shipping_Add__c == true) {
                
                acc.Shipping_Address_Line_1__c = acc.ADDRESS_LINE_1__c;
                acc.Shipping_Address_Line_2__c = acc.ADDRESS_LINE_2__c;
                acc.Shipping_Address_Line_3__c = acc.ADDRESS_LINE_3__c;
                acc.Shipping_City__c = acc.Billing_City__c;
                acc.Shipping_State__c = acc.Billing_State__c;
                acc.Shipping_Region_Master__c = acc.Global_Region__c;
                acc.Shipping_Sub_Region__c = acc.Global_SubRegion__c;
                acc.Shipping_Postal_ZIP_Code__c = acc.Billing_Postal_ZIP_Code__c;
                acc.Shipping_Country__c = acc.Billing_Country__c;
            }

       /*
                            // If the checkbox is not checked and Shipping Country and City are blanks
                            else if (!acc.Copy_Billling_Add_To_Shipping_Add__c && 
                                     String.isBlank(acc.Shipping_Country__c) && 
                                     String.isBlank(acc.Shipping_City__c)) {
                                         acc.addError('Please provide the "Shipping Country" and "Shipping City".');
                                     } 
 
                            // If the checkbox is not checked and Shipping Country and City are blank
                            else if (!acc.Copy_Billling_Add_To_Shipping_Add__c && 
                                     String.isBlank(acc.Shipping_Country__c) && 
                                     String.isBlank(acc.Shipping_City__c)) {
                                         
                                         // Check if the account is created from lead conversion
                                         if (!Trigger.isInsert || acc.Is_Converted__c != true) { 
                                             acc.addError('Please provide the "Shipping Country" and "Shipping City".');
                                         }
                                     }    
          */
            
        } 
    }
    
    if ((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)) {
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : Trigger.new) {
            if (acc.Copy_Billling_Add_To_Shipping_Add__c == true) {
                Account updatedAccount = new Account(Id = acc.Id);
                updatedAccount.Copy_Billling_Add_To_Shipping_Add__c = false;
                accountsToUpdate.add(updatedAccount);
            }
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    /*
    if ((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)) {
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : Trigger.new) {
            // If the checkbox is checked, uncheck it after saving the record
            if (acc.Copy_Billling_Add_To_Shipping_Add__c == true) {
                acc.Copy_Billling_Add_To_Shipping_Add__c = false;
                accountsToUpdate.add(acc);
            }
        }
        
        // Perform the update operation to uncheck the checkbox
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    */

    
    // =============================================================================
    // ============================================================================    
    
}