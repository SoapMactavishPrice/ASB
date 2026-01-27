trigger Treg_Contract on Contract (Before Insert, Before Update,after insert,After Update) {
   
    
    List<contract> LstContract = new List<Contract>();
    
    public String StrQuoteID{get;set;}
    opportunity obj = new Opportunity();
    opportunity obj1 = new Opportunity(); 
    List<Contract> qty = new List<Contract>();
    List<Contract> qtyopp = new List<Contract>();
    Set<id> QID = new Set<id>();
    list<Account> ObjAccount = new list<Account>();
    //  list<Quote> ObjQuote1 = new list<Quote>();
    public Contract errorObj{get;set;}
    list<opportunity> opty = new list<opportunity>();
    list<opportunity> opty1 = new list<opportunity>();
    list<opportunity> opty2 = new list<opportunity>();
    list<Contract> qty1 = new list<Contract>();
    Map<Id, Contract> contractWContractLineItems=new Map<Id,Contract>(); 
    Boolean discountLiMore;
    set<Id> cId = new set<Id>();
    
    
    System.debug('Inside the trigger*** 1');
    /*if(trigger.isBefore && trigger.isUpdate) {
        
        for(Contract con: Trigger.New) {
            cID.add(con.Id);
        }
        
        List<Contract> contList =[Select Id, Opportunity__r.CloseDate From Contract where Id=:cID];       
        for(Contract con: contList) {
        if(con.Opportunity__r.CloseDate < System.today()){
            //Trigger.newMap.get(con.Id).addError('Opportunity Date Should Not Be Past Date.');
        	}
        }
    }*/
    
    
    
    
    
    
    
    /*if(trigger.isBefore && trigger.isUpdate) {
       
        
        Map<Id, Integer> contractWiseCount = new Map<Id, Integer>();
        for(AggregateResult result: [select Contract__c, count(Id) cnt from ProjectManagement__c where Contract__c in: Trigger.New  group by Contract__c]) {
            contractWiseCount.put(String.valueOf(result.get('Contract__c')), Integer.valueOf(result.get('cnt')));
        }
        for(Contract cont: Trigger.New) {
            if(cont.Status == 'Cancelled'){
                if(contractWiseCount.containsKey(cont.Id)) {
                if(contractWiseCount.get(cont.Id) > 0) {
                    cont.Status.addError('After Creation Of Project Unable To Cancel The Contract. ');
                }
            }
            }
        }
    }
    */
    /*if(trigger.isBefore && trigger.isUpdate) {
        // to check for quote line items by discount allowed
    contractWContractLineItems =new Map<Id, Contract>( [SELECT Id, (SELECT Id,Discount__c,Discount_Allowed__c,Approved_Discount__c  
                                                                    FROM Contract_Line_Item__r),
                                                        		(SELECT Id,Discount__c,Approved_Discount__c, Discount_Allowed__c 
                                                                 FROM Contract_Line_Option__r) 
                                                        FROM Contract WHERE Id = :Trigger.newMap.values()]);
     system.debug('contractWContractLineItems--->' + contractWContractLineItems);
     
        System.debug('in side Lock for Approval');
        Set<id>ids=new set<id>();
        map<id,Contract> qMap=new map<id,Contract>();
        for (Contract qt: Trigger.new) {
            ids.add(qt.id);
        }
        For(Contract q:[Select id,name,Approved_Amount__c,Subsidiary__c,Subsidiary__r.Contract_Approval__c,Subsidiary__r.Discount_Level_1__c,Subsidiary__r.Discount_Level_2__c,Subsidiary__r.Discount_Level_3__c,Contract_Total_List_Price__c,Contract_Total_Sales_price__c from Contract where id in:ids])
        {
            qMap.put(q.id,q); 
        }
        User u=[select id,name,Level__c from user where id=:userinfo.getUserId()];
        for (Contract qt: Trigger.new) {
           qt.Contract_Locked_for_Approval__c = false;
            
            if(qMap.get(qt.id).Subsidiary__r.Contract_Approval__c=='Line Item level')
            {
                Contract thisContract = contractWContractLineItems.get(qt.Id);
                for(Contract_Line_Item__c qli:thisContract.Contract_Line_Item__r){
                    System.debug('in side Line item wise Approval'+qli.Discount__c);
                    System.debug('in side Line item wise Approval'+qli.Discount_Allowed__c);
                    System.debug('in side Line item wise Approval'+qli.Approved_Discount__c);
                    if (qli.Discount__c != NULL && qli.Discount__c > qli.Discount_Allowed__c && qli.Discount__c>qli.Approved_Discount__c) {
                         System.debug('in side Line item wise Approval'+thisContract.Contract_Line_Item__r);
                        qt.Contract_Locked_for_Approval__c = true;
                        system.debug('---exceeded---');
                        break;
                    }
                    
                }
                for(Contract_Line_Option__c qli:thisContract.Contract_Line_Option__r){  
                    if (qli.Discount__c != NULL && qli.Discount__c > qli.Discount_Allowed__c && qli.Discount__c>qli.Approved_Discount__c) {
                        qt.Contract_Locked_for_Approval__c = true;
                        system.debug('---exceeded---');
                        break;
                    }
                    
                }
                
                //ContractRecursionCheck.isfirsttime=true;
            }
            else
            {
                System.debug('in side Contract wise Approval');
                Double Disc=0;
                if(u.Level__c=='L1')
                    Disc=qMap.get(qt.id).Subsidiary__r.Discount_Level_1__c;
                if(u.Level__c=='L2')
                    Disc=qMap.get(qt.id).Subsidiary__r.Discount_Level_2__c;
                if(u.Level__c=='L3')
                    Disc=qMap.get(qt.id).Subsidiary__r.Discount_Level_3__c;
                
                if((qMap.get(qt.id).Contract_Total_List_Price__c-(qMap.get(qt.id).Contract_Total_List_Price__c*(Disc/100)))>qMap.get(qt.id).Contract_Total_Sales_price__c &&( qMap.get(qt.id).Approved_Amount__c>qMap.get(qt.id).Contract_Total_Sales_price__c ||qMap.get(qt.id).Approved_Amount__c==0)) 
                {
                    qt.Contract_Locked_for_Approval__c = true;
                    qt.Approved_Amount_Temp__c=qMap.get(qt.id).Contract_Total_List_Price__c-(qMap.get(qt.id).Contract_Total_List_Price__c*(Disc/100));
                    
                }
                else
                    qt.Contract_Locked_for_Approval__c = false;
            }
        }
    }
    */
    if(trigger.IsBefore && trigger.IsInsert){
        for(Contract Cont : trigger.new){
            String QuoteId = Cont.Quote__c;
            //Quote ObjQuote = new Quote();
            Quote ObjQuote = [Select id,CountryCustom__c,StateCustom__c,CityCustom__c,COUNTRY_CODE__c,Insurance__c,Insurance_Amount__c,Freight__c,Freight_Amount__c from quote where id =: QuoteId];
            Cont.Country_Text__c = ObjQuote.CountryCustom__c;
            Cont.State_Text__c = ObjQuote.StateCustom__c;
            cont.City_Text__c = ObjQuote.CityCustom__c;
            cont.COUNTRY_CODE__c = ObjQuote.COUNTRY_CODE__c;
            cont.Revision__c = '000';
            cont.Numeric_Revision__c = 0;
            cont.Insurance_Picklist__c = objQuote.Insurance__c;
            cont.Insurance_Amount__c = objQuote.Insurance_Amount__c;
            cont.Freight_Pick__c = objQuote.Freight__c;
            cont.Freight_Amount1__c = objQuote.Freight_Amount__c;
            
            
        }
    }
    
    if(trigger.IsAfter && trigger.IsInsert){
        set<id> sid = new set<id>();
        for(Contract cont : trigger.new){
            Contract ObjContract =new Contract();
            sid.add(cont.id);
            ObjContract.id = cont.id;
            String RecId = cont.id;
            sTRING ContnUMBER = cont.ContractNumber;
            String ContNumberClone = cont.Contract_Number__c;
            
            System.debug('ContNumberClone ===>'+ContNumberClone);
            System.debug('RecId ===>'+RecId+'ContnUMBER======>'+ContnUMBER);
            List<Contract> LstCont = new  List<Contract>();
            LstCont = [select id,name,Contract_Number__c,ContractNumber from contract where Contract_Number__c =: ContNumberClone];
            System.debug('LstCont.size'+LstCont.size());
            
            if(ContNumberClone == null){
                ObjContract.Contract_Number__c = cont.ContractNumber;
                ObjContract.Revision_Number__c = '000';
                LstContract.add(ObjContract);
            }
            else if(LstCont.size() > 0){
                ObjContract.Revision_Number__c = '00'+(LstCont.size()-1);
                LstContract.add(ObjContract);  
            }
        }
        List<Contract_Line_Item__c> LstContLI = new  List<Contract_Line_Item__c>();
        //LstContLI = [select id, name, ContractId__c from Contract_Line_Item__c where ContractId__c IN:sid];
        
        if(LstContract.size() > 0 && LstContract != null){
            update LstContract;
        }
    }
    
   
    if(trigger.IsAfter && trigger.IsUpdate)
    {
        if(CheckRecursive.contractAfterUpdate){
            return ;
        }
        CheckRecursive.contractAfterUpdate=true;
         //If the contract gets cancelled, then user will manually update the individual quote else quote will be open state.
        set<id> sid = new set<id>();
        set<id> qsid = new set<id>();
        for(Contract cont : trigger.new)
        {
            if(cont.Status=='Cancelled')
            {
                sid.add(cont.Quote__c);
            }
            
            if(cont.Status=='Hold For Revision')
            {
                qsid.add(cont.Quote__c);
            }
        }
        
        if(sid.size()>0)
        {
            Quote q=[Select id,Status,Skip_Status_Validation__c from quote where Id in : sid];
            q.Status='RELEASED';
            q.Skip_Status_Validation__c = true; 
            update q;
        }
        if(qsid.size()>0)
        {
            RecordType qRec= [select Id,Name from RecordType where sObjectType='Quote' And Name='Blank Quote' limit 1];
            Quote q=[Select id,Status,Skip_Status_Validation__c,Contract_Hold_For_Revision__c from quote where Id in : qsid];
            q.Status='CREATED';
            q.Skip_Status_Validation__c = true;
            q.Contract_Hold_For_Revision__c = true;
            q.RecordTypeId=qRec.id;
            update q;
        }
         
        // for Contract Approved Logic
          set<id> approvedContract=new set<id>();
        for(Contract cont : trigger.new)
        {
           
            if(cont.Approval_Status_From_HOD__c=='Approved' && Trigger.oldMap.get(cont.Id).Approval_Status_From_HOD__c!='Approved'){
                 approvedContract.add(cont.Id);
            }
           
        }
        List<Contract> lC = new List<Contract>();
        lC = [select id,name,Approved_Amount_Temp__c,Subsidiary__r.Contract_Approval__c,Contract_Locked_for_Approval__c from Contract where id in:approvedContract];
        map<id,Contract> qlist= new map<id,Contract>();
        for(Contract lcc : lC){
           qlist.put(lcc.id,lcc); 
            
        }

        List<Contract> contractLvlList = new  List<Contract>();
        List<Contract> lineItemList = new  List<Contract>();
        for(id cId:qlist.keyset()){
             qlist.get(cId).Approved_Amount__c   = qlist.get(cId).Approved_Amount_Temp__c;
             qlist.get(cId).Contract_Locked_for_Approval__c   = false;
             contractLvlList.add(qlist.get(cId));
          
              if(qlist.get(cId).Subsidiary__r.Contract_Approval__c=='Line Item level'){
                lineItemList.add(qlist.get(cId));
            }
            
        }
        
        if(lineItemList.size()  > 0){
        map<id,Contract_Line_Item__c> contractLinelist= new map<id,Contract_Line_Item__c>([select id,Approved_Discount__c,Discount__c from Contract_Line_Item__c where ContractId__c in:lineItemList]);
       
        for(id cId:contractLinelist.keyset()){
             contractLinelist.get(cId).Approved_Discount__c   = contractLinelist.get(cId).Discount__c;
            
        }
        
         map<id,Contract_Line_Option__c> contractLineOplist= new map<id,Contract_Line_Option__c>([select id,Approved_Discount__c,Discount__c from Contract_Line_Option__c where ContractId__c in:lineItemList]);
       
        for(id cId:contractLineOplist.keyset()){
             contractLineOplist.get(cId).Approved_Discount__c   = contractLineOplist.get(cId).Discount__c;
            
        }
        
        if(contractLinelist.values().size()>0){
              update contractLinelist.values();
        }
        if(contractLineOplist.values().size()>0){
              update contractLineOplist.values();
        }
      
         if(contractLvlList.size()>0){
              update contractLvlList;
        }
        }
       
         // End of Contract Approved Logic
    }
    
    IF(trigger.isBefore && Trigger.isUpdate){
        
        Map<Id, Account> ShipTo = new Map<Id, Account>();
        Map<Id, Contact> conToMap = new Map<Id, Contact>();
        set<Id> soldTo = new set<Id>();
        for (Contract qu : Trigger.new) {
            if(qu.SOLD_TO__c != Trigger.oldMap.get(qu.Id).SOLD_TO__c){
              soldTo.add(qu.SOLD_TO__c);  
            }
            
            if(qu.SHIP_TO__c != Trigger.oldMap.get(qu.Id).SHIP_TO__c){
              soldTo.add(qu.SHIP_TO__c);  
            }
            
        }
        
        if(soldTo.size() > 0){
        List<Account> accList= [SELECT Id, City__c, Global_SubRegion__c,Shipping_Address_Line_1__c,Shipping_Address_Line_2__c,Shipping_Address_Line_3__c,
                                Shipping_City__r.Name,Shipping_Postal_ZIP_Code__r.Name,
                                Shipping_Country__r.Name,Shipping_State__r.Name,Shipping_Region_Master__c,Shipping_Sub_Region__c,
                                Global_Region__c,
                                ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,Billing_City__r.Name,
                                Billing_Postal_ZIP_Code__r.Name,Billing_State__r.Name,Billing_Country__r.Name
                                FROM Account WHERE Id IN :soldTo];
        
        List<Contact> conList = [select Id,Name,AccountId from Contact where AccountId IN :soldTo]; 
        
        for(Contact con: conList){
            conToMap.put(con.AccountId,con);
        }
        
        for(Account acc: accList){
            ShipTo.put(acc.Id,acc);
        }
        
        for(Contract q : trigger.new){
            if(ShipTo.containsKey(q.SHIP_TO__c)){
                Account acc = ShipTo.get(q.SHIP_TO__c);
                 q.ADDRESS_LINE_ShipTo_1__c = acc.Shipping_Address_Line_1__c;
                 q.ADDRESS_LINE_ShipTo_2__c = acc.Shipping_Address_Line_2__c;
                 q.ADDRESS_LINE_ShipTo_3__c = acc.Shipping_Address_Line_3__c;
                 q.Ship_To_City__c = acc.Shipping_City__r.Name;
                 q.POSTAL_CODE_ShpTo__c = acc.Shipping_Postal_ZIP_Code__r.Name;
                 q.Ship_To_State__c = acc.Shipping_State__r.Name;
                 q.Ship_To_Country__c = acc.Shipping_Country__r.Name;
                 q.Ship_To_Global_Region__c = acc.Shipping_Region_Master__c;
                 q.Ship_To_Global_SubRegion__c = acc.Shipping_Sub_Region__c;
            }
            
            if(conToMap.containsKey(q.SHIP_TO__c)){
                q.SHIP_To_Contact_Name__c	 = conToMap.get(q.SHIP_TO__c).Id;
            }
            
            if(conToMap.containsKey(q.SOLD_TO__c)){
                q.Contact_Id__c = conToMap.get(q.SOLD_TO__c).Id;
            }
            
            if(ShipTo.containsKey(q.SOLD_TO__c)){
                Account acc = ShipTo.get(q.SOLD_TO__c);
                 q.ADDRESS_LINE_1__c = acc.ADDRESS_LINE_1__c;
                 q.ADDRESS_LINE_2__c = acc.ADDRESS_LINE_2__c;
                 q.ADDRESS_LINE_3__c = acc.ADDRESS_LINE_3__c;
                 q.City_Text__c = acc.Billing_City__r.Name;
                 q.POSTAL_CODE__c = acc.Billing_Postal_ZIP_Code__r.Name;
                 q.State_Text__c = acc.Billing_State__r.Name;
                 q.Country_Text__c = acc.Billing_Country__r.Name;
                 q.Global_Region__c = acc.Global_Region__c;
                 q.Global_SubRegion__c = acc.Global_SubRegion__c;
            }
        }
        }
    }
   /* 
    IF(trigger.isBefore && Trigger.isInsert){
        
        Map<Id, Account> ShipTo = new Map<Id, Account>();
        Map<Id, Contact> conToMap = new Map<Id, Contact>();
        set<Id> soldTo = new set<Id>();
        for (Contract qu : Trigger.new) {
            if(qu.SOLD_TO__c != null){
              soldTo.add(qu.SOLD_TO__c);  
            }
            
            if(qu.SHIP_TO__c != null){
              soldTo.add(qu.SHIP_TO__c);  
            }
            
        }
        
        if(soldTo.size() > 0){
        List<Account> accList= [SELECT Id, City__c, Global_SubRegion__c,Shipping_Address_Line_1__c,Shipping_Address_Line_2__c,Shipping_Address_Line_3__c,
                                Shipping_City__r.Name,Shipping_Postal_ZIP_Code__r.Name,
                                Shipping_Country__r.Name,Shipping_State__r.Name,Shipping_Region_Master__c,Shipping_Sub_Region__c,
                                Global_Region__c,
                                ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,Billing_City__r.Name,
                                Billing_Postal_ZIP_Code__r.Name,Billing_State__r.Name,Billing_Country__r.Name
                                FROM Account WHERE Id IN :soldTo];
        
        List<Contact> conList = [select Id,Name,AccountId from Contact where AccountId IN :soldTo]; 
        
        for(Contact con: conList){
            conToMap.put(con.AccountId,con);
        }
        
        for(Account acc: accList){
            ShipTo.put(acc.Id,acc);
        }
        
        for(Contract q : trigger.new){
            if(ShipTo.containsKey(q.SHIP_TO__c)){
                Account acc = ShipTo.get(q.SHIP_TO__c);
                 q.ADDRESS_LINE_ShipTo_1__c = acc.Shipping_Address_Line_1__c;
                 q.ADDRESS_LINE_ShipTo_2__c = acc.Shipping_Address_Line_2__c;
                 q.ADDRESS_LINE_ShipTo_3__c = acc.Shipping_Address_Line_3__c;
                 q.Ship_To_City__c = acc.Shipping_City__r.Name;
                 q.POSTAL_CODE_ShpTo__c = acc.Shipping_Postal_ZIP_Code__r.Name;
                 q.Ship_To_State__c = acc.Shipping_State__r.Name;
                 q.Ship_To_Country__c = acc.Shipping_Country__r.Name;
                 q.Ship_To_Global_Region__c = acc.Shipping_Region_Master__c;
                 q.Ship_To_Global_SubRegion__c = acc.Shipping_Sub_Region__c;
            }
            
            if(conToMap.containsKey(q.SHIP_TO__c)){
                q.SHIP_To_Contact_Name__c	 = conToMap.get(q.SHIP_TO__c).Id;
            }
            
            if(conToMap.containsKey(q.SOLD_TO__c)){
                q.Contact_Id__c = conToMap.get(q.SOLD_TO__c).Id;
            }
            
            if(ShipTo.containsKey(q.SOLD_TO__c)){
                Account acc = ShipTo.get(q.SOLD_TO__c);
                 q.ADDRESS_LINE_1__c = acc.ADDRESS_LINE_1__c;
                 q.ADDRESS_LINE_2__c = acc.ADDRESS_LINE_2__c;
                 q.ADDRESS_LINE_3__c = acc.ADDRESS_LINE_3__c;
                 q.City_Text__c = acc.Billing_City__r.Name;
                 q.POSTAL_CODE__c = acc.Billing_Postal_ZIP_Code__r.Name;
                 q.State_Text__c = acc.Billing_State__r.Name;
                 q.Country_Text__c = acc.Billing_Country__r.Name;
                 q.Global_Region__c = acc.Global_Region__c;
                 q.Global_SubRegion__c = acc.Global_SubRegion__c;
            }
        }
        }
    }
    */
    

   
}