public class CreatePaymentManual {
    Public static Id CampaignId;
    // Public Static List<LeadListWrapper> lstLeadListWrapper = new List<LeadListWrapper>();
    Public Static List<LeadListWrapper> lstProductListWrapper = new List<LeadListWrapper>();
    public  Static List<QuoteLineItem> ObjQLI = new List<QuoteLineItem>();
    //   public Static Groups__c objOfCampaign;
    
    
    // Shubham
    @AuraEnabled
    public static Boolean fetchExpdate(string key){
        system.debug('key ==>> ' + key);
        list<Contract> contList = [select id , name, ExpirationDate__c from Contract where id =: key];
        system.debug('contList ==>>>> ' + contList);
        if(contList[0].ExpirationDate__c > System.today()){
            system.debug('in true');
            return true; 
        }
        else{
            return false;
        }
        
    }
    
     // Vikram
    @AuraEnabled
    public static Contract fetchContractDetails(string key){
        Contract contDetails = [select id, name, CurrencyIsoCode from Contract where id =: key];
        system.debug('contDetails ==>>>> ' + contDetails);
        return contDetails;
    }
    
    @AuraEnabled
    public static list<Contract_Line_Item__c> fatchContractLineItem(String key){
        list<Contract_Line_Item__c> CLIList= [select id, Name,ContractId__c,ContractId__r.ContractNumber,Total_Price__c,
                                              Product2Id__c,Product2Id__r.Name,Description__c,ContractId__r.Name,
                                              Amount_Allocated__c, Advance_Amount_Required__c, Total_Amount_Received__c,
                                              Balance_Payment__c, Product_Name_2__c, Final_Grand_Total__c from Contract_Line_Item__c
                                              where ContractId__c=: key];
        system.debug('fatchContractLineItem -->> ' + CLIList);
        return CLIList;
        
    }
    //Shubham End
    
    
    @AuraEnabled 
    public static List<LeadListWrapper> fetchProductWrapper(String Campaign){ 
        CampaignId= Campaign;
        System.debug('CampaignId'+CampaignId);
        
        
        for(Contract_Line_Item__c lstpbe :[select id,contractid__c, Name,ContractId__r.Name,Total_Price__c,
                                           Advance_Required_In_Amount__c,Total_Amount_Received__c,Balance_Payment__c,
                                           Product2Id__c,Product2Id__r.Name,Description__c,Amount_Allocated__c
                                           from Contract_Line_Item__c where ContractId__c=: CampaignId])
        {
            lstProductListWrapper.add(new LeadListWrapper(false,lstpbe));
        } 
        System.debug('lstProductListWrapper'+lstProductListWrapper);
        //  System.debug('CampaignId'+CampaignId);
        return lstProductListWrapper; 
    }
    
    @AuraEnabled
    public static user fetchUser(){
        User u = [select id,Name,Level__c from User where id =: userInfo.getUserId()];
        return u;
    }
    
    @AuraEnabled 
    Public static void blockPayment(String recordId, Decimal amt, String reason){
        System.debug('reason===> '+reason);
        System.debug('amt===> '+amt);
        System.debug('recordId===> '+recordId);
        List<Payment__c> payObj = new List<Payment__c>();
        payObj = [Select id, Mode_Of_Payment__c, Balance_for_allocation__c, Payment_Block__c, Payment_Block_Reason__c from Payment__c where Id=:recordId];
        System.debug('input'+payObj[0].Balance_for_allocation__c);
        if(amt > payObj[0].Balance_for_allocation__c){
            string errorMessage = 'Error: Blocked Amount should be less than Balance for allocation.';
            AuraHandledException auraEx1 = new AuraHandledException(errorMessage);
            auraEx1.setMessage(errorMessage);
            throw auraEx1;
        }
        system.debug('payObj[0].Balance_for_allocation__c -->> ' + payObj[0].Balance_for_allocation__c);
        System.debug('payObj===> '+payObj);
        if(amt != Null){
            if(payObj[0].Payment_Block__c == Null){
                payObj[0].Payment_Block__c = amt;
            }else{
                payObj[0].Payment_Block__c = payObj[0].Payment_Block__c + amt;
            }
        }
        if(reason != Null){
            if(payObj[0].Payment_Block_Reason__c == Null){
                payObj[0].Payment_Block_Reason__c = reason;
            }else{
                payObj[0].Payment_Block_Reason__c = payObj[0].Payment_Block_Reason__c + ' , ' + reason;
            }
        }
        System.debug('payObj===> '+payObj);
        try{
            update payObj;
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        } 
    }
    
    @AuraEnabled 
    Public static void makeTrans(List<Contract_Line_Item__c> selectedRecordList, String recordId){ 
        System.debug('recordId===> '+recordId);
        System.debug('selectedRecordList===> '+selectedRecordList);
        Boolean doInsert = True;
        //System.debug('recordId===> '+reason);
        //System.debug('amt===> '+amt);
        //Boolean isPaymentBlocked = False;
        List<Payment__c> payObj = new List<Payment__c>();
        payObj = [Select id,CurrencyIsoCode, Mode_Of_Payment__c,Contract__c, Balance_for_allocation__c, Payment_Block__c,Payment_Date__c  from Payment__c where Id=:recordId];
        System.debug('payObj===> '+payObj);
        Decimal blockAmount;
        if(payObj[0].Payment_Block__c != Null){
            blockAmount = payObj[0].Payment_Block__c;
            system.debug('blockAmount --->>>' + blockAmount);
        }
        else{
            blockAmount = 0;
        }
        //blockAmount += amt;
        
        Double amount = 0;
        if(selectedRecordList != null){
            for(Contract_Line_Item__c Wrp1 : selectedRecordList){
                system.debug('total amount CLI' +Wrp1.Total_List_Price__c);
                if(Wrp1.Amount_Allocated__c!=null){
                    amount += Wrp1.Amount_Allocated__c;
                }
            }
            system.debug('amount -->> ' + amount);
            if(amount > payObj[0].Balance_for_allocation__c)
            {
                string errorMessage = 'Error: Allocated Amount should be less than Balance for allocation.';
                AuraHandledException auraEx1 = new AuraHandledException(errorMessage);
                auraEx1.setMessage(errorMessage);
                throw auraEx1;
            }
        }
        List<Payment_Transaction__c> LstPmt = new List<Payment_Transaction__c>();
        /*if(amt != Null){
            isPaymentBlocked = True;
            Payment_Transaction__c pro = new Payment_Transaction__c();
            pro.Payment__c = recordId;
            pro.Payment_Blocked__c = amt;
            pro.Payment_Block_Reason__c = reason;
            LstPmt.add(pro);
        }*/
        
        if(selectedRecordList != null){
            for(Contract_Line_Item__c Wrp1 : selectedRecordList){
                System.debug('reached ' + Wrp1);
                Payment_Transaction__c pro = new Payment_Transaction__c();
                pro.CurrencyIsoCode=payObj[0].CurrencyIsoCode;
                pro.Contract__c = payObj[0].Contract__c;
                pro.Payment__c = recordId;
                //pro.Payment_Blocked__c = amt;
                //pro.Payment_Block_Reason__c = reason;
                if(Wrp1.Product2Id__c != null){
                    System.debug('Product2Id__c ' + Wrp1.Product2Id__c);
                    String str=Wrp1.Product2Id__c;
                    /*String strr;
                     if(str.contains('\"')){
                        system.debug('in if contains /');
                        strr=str.replace('\"','');
                    }*/
                    String strr=str.replace('\"','');
                    System.debug('strr ' + strr);
                    Id idval = Id.valueOf(strr);
                    pro.Product__c = idval;
                    pro.Product_Name__c = Wrp1.Product_Name_1__c;             
                }
                else{
                    pro.Product_Name__c = Wrp1.Product_Name_1__c;
                }
                //if(Wrp1.id__c != null){
                System.debug('id__c ' + Wrp1.id__c);
                String str=Wrp1.id__c;
                /*String strr;
                     if(str.contains('\"')){
                        system.debug('in if contains /');
                        strr=str.replace('\"','');
                    }*/
                String strr=str.replace('\"','');
                System.debug('strr ' + strr);
                Id idval1 = Id.valueOf(strr);
                pro.Contract_Line_Item__c = idval1;
                //}
                if(Wrp1.ContractId__c != null){
                    System.debug('ContractId__c ' + Wrp1.ContractId__c);
                    String str1=Wrp1.ContractId__c;
                    /*String strr1;
                     if(str1.contains('\"')){
                        system.debug('in if contains /');
                        strr1=str1.replace('\"','');
                    }*/
                    String strr1=str1.replace('\"','');
                    System.debug('strr ' + strr1);
                    Id idval11 = Id.valueOf(strr1);
                    Contract conObj = new Contract();
                    conObj = [select id, name, ExpirationDate__c from Contract where id =: idval11];
                    if(conObj.ExpirationDate__c < system.today()){
                        doInsert = false;
                    }else{
                        pro.Contract__c = idval11;
                    }
                    
                }
                pro.Date__c = payObj[0].Payment_Date__c;
                pro.Mode_Of_Payment__c = payObj[0].Mode_Of_Payment__c;
                //pro.Transaction_Id__c = Cheque;
                system.debug('Wrp1.Amount_Allocated__c --->>> ' + Wrp1.Amount_Allocated__c);
                if(Wrp1.Amount_Allocated__c != null){
                    pro.Amount_Allocated__c = Wrp1.Amount_Allocated__c;
                    LstPmt.add(pro);
                }
                //LstPmt.add(pro);
            }
        }
        payObj[0].Payment_Block__c = blockAmount;
        if(!doInsert){
            string errorMessage = 'Error: Contract is Already Expired.';
            AuraHandledException auraEx = new AuraHandledException(errorMessage);
            auraEx.setMessage(errorMessage);
            throw auraEx;
        }else{
            try{
                System.debug('LstPmt'+LstPmt.size());
                System.debug('payObj'+payObj);
                insert LstPmt;  
                update payObj;
            }catch(Exception e){
                system.debug('Exception'+e.getMessage());
            }
        }
    }
    
    @AuraEnabled 
    Public static void SelectedLead(String contractId, List<Contract_Line_Item__c> selectedRecordList, String PaymentMode,String Cheque,Date Datedata,Decimal Amountrecieved, Decimal ExchangeRate, string Cur, string LocalCurrency, Decimal AmountLocalCurrency, String InvoiceNumber, Date InvoiceDate, String PaymentType){
        System.debug('Cur===> '+Cur);
        System.debug('PaymentMode===> '+PaymentMode);
        System.debug('selectedRecordList===> '+selectedRecordList);
        System.debug('Cheque===> '+Cheque);
        System.debug('Datedata===> '+Datedata);
        System.debug('Amountrecieved===> '+Amountrecieved);
        System.debug('InvoiceNumber===> '+InvoiceNumber);
        System.debug('InvoiceDate===> '+InvoiceDate);
        System.debug('PaymentType===> '+PaymentType);
        Decimal TotalAllocation=0;
        Boolean doInsert = true;
        Contract thisContract = [SELECT Id, Name,CurrencyIsoCode, AccountID, Subsidiary__c FROM Contract WHERE Id = :contractId];
        Fiscal_Year_Master__c thisFY = [SELECT Id, Name, Active__c FROM Fiscal_Year_Master__c WHERE Active__c = true];
        if(selectedRecordList != null){
            for(Contract_Line_Item__c Wrp1 : selectedRecordList){
                system.debug('total amount CLI' +Wrp1.Total_List_Price__c);
                if(Wrp1.Amount_Allocated__c>Wrp1.Total_Price__c)
                {
                    string errorMessage = 'Error: Allocated Amount should be less than CLI Total amount.';
                    AuraHandledException auraEx1 = new AuraHandledException(errorMessage);
                    auraEx1.setMessage(errorMessage);
                    throw auraEx1;
                }
                if(Wrp1.Amount_Allocated__c != null){
                    TotalAllocation +=Wrp1.Amount_Allocated__c;
                }
            }
        }
        
        
        Payment__c ObjPayment = new Payment__c();
        ObjPayment.Contract__c = thisContract.Id;
        ObjPayment.Account__c = thisContract.AccountID;
        ObjPayment.Subsidiary__c = thisContract.Subsidiary__c;
        ObjPayment.FY__c = thisFY.Id;
        ObjPayment.Mode_Of_Payment__c = PaymentMode;
        ObjPayment.Payment_Date__c = Datedata;
        ObjPayment.Cheque_Transaction_Number__c = Cheque;
        ObjPayment.Total_Payment__c =Amountrecieved;
        ObjPayment.Exchange_Rate__c =ExchangeRate;
        ObjPayment.CurrencyIsoCode =thisContract.CurrencyIsoCode;
        ObjPayment.Local_CUR__c =LocalCurrency+'  - Indian Rupee';
        ObjPayment.Invoice_Number__c =  InvoiceNumber;
        ObjPayment.Invoice_Date__c = InvoiceDate;
        ObjPayment.Payment_Type__c = PaymentType;
        if(Cur.contains('USD')){
            ObjPayment.Amount_In_Local_CUR_1__c ='USD '+AmountLocalCurrency;
            ObjPayment.Total_Payment_1__c ='USD '+Amountrecieved;
        }
        else{
            ObjPayment.Amount_In_Local_CUR_1__c ='INR '+AmountLocalCurrency;
            ObjPayment.Total_Payment_1__c ='INR '+Amountrecieved;
        } 
        
        ObjPayment.Amount_In_Local_CUR__c =AmountLocalCurrency;
        System.debug('TotalAllocation'+TotalAllocation);
         System.debug('AmountLocalCurrency'+AmountLocalCurrency);
        
        if(TotalAllocation >= 0){
            if(TotalAllocation>AmountLocalCurrency)
        {
            string errorMessage = 'Error: Allocated Amount should be less than received amount.';
            AuraHandledException auraEx = new AuraHandledException(errorMessage);
            auraEx.setMessage(errorMessage);
            throw auraEx;
        }
        else {
            insert ObjPayment;
        }
        }else{
            string errorMessage = 'Error: Allocated Amount should not be negative.';
            AuraHandledException auraEx = new AuraHandledException(errorMessage);
            auraEx.setMessage(errorMessage);
            throw auraEx;
        }
        
        String Paymentid =ObjPayment.id;
        
        List<Payment_Transaction__c> LstPmt = new List<Payment_Transaction__c>();
        if(selectedRecordList != null){
            for(Contract_Line_Item__c Wrp1 : selectedRecordList){
                System.debug('reached ' + Wrp1);
                Payment_Transaction__c pro = new Payment_Transaction__c();
                pro.CurrencyIsoCode=thisContract.CurrencyIsoCode;
                pro.Payment__c = Paymentid;
                if(Wrp1.Product2Id__c != null){
                    System.debug('Product2Id__c ' + Wrp1.Product2Id__c);
                    String str=Wrp1.Product2Id__c;
                    String strr=str.replace('\"','');
                    System.debug('strr ' + strr);
                    Id idval = Id.valueOf(strr);
                    pro.Product__c = idval;
                    pro.Product_Name__c = Wrp1.Product_Name_1__c;             
                }
                else{
                    pro.Product_Name__c = Wrp1.Product_Name_1__c;
                }
                //if(Wrp1.id__c != null){
                System.debug('id__c ' + Wrp1.id__c);
                String str=Wrp1.id__c;
                String strr=str.replace('\"','');
                System.debug('strr ' + strr);
                Id idval1 = Id.valueOf(strr);
                pro.Contract_Line_Item__c = idval1;
                //}
                if(Wrp1.ContractId__c != null){
                    System.debug('ContractId__c ' + Wrp1.ContractId__c);
                    String str1=Wrp1.ContractId__c;
                    String strr1=str1.replace('\"','');
                    System.debug('strr ' + strr1);
                    Id idval11 = Id.valueOf(strr1);
                    Contract conObj = new Contract();
                    conObj = [select id, name, ExpirationDate__c from Contract where id =: idval11];
                    if(conObj.ExpirationDate__c < system.today()){
                        //doInsert = false;
                        doInsert = true;
                    }else{
                        pro.Contract__c = idval11;
                    }
                }
                pro.Mode_Of_Payment__c = PaymentMode;
                pro.Date__c = Datedata;
                pro.Transaction_Id__c = Cheque;
                system.debug('Wrp1.Amount_Allocated__c --->>> ' + Wrp1.Amount_Allocated__c);
                if(Wrp1.Amount_Allocated__c != null){
                    pro.Amount_Allocated__c = Wrp1.Amount_Allocated__c;
                    LstPmt.add(pro);
                }
                //LstPmt.add(pro);
            }
        }
        if(!doInsert){
            string errorMessage = 'Error: Contract is Already Expired.';
            AuraHandledException auraEx = new AuraHandledException(errorMessage);
            auraEx.setMessage(errorMessage);
            throw auraEx;
        }else{
            try{
                System.debug('LstPmt'+LstPmt.size());
                insert LstPmt;  
            }catch(Exception e){
                system.debug('Exception'+e.getMessage());
                if(e.getMessage().Contains('Allocated amount'))
                {
                string errorMessage = 'Allocated Amount Should not be More than Balance Amount.';
            	AuraHandledException auraEx = new AuraHandledException(errorMessage);
            	auraEx.setMessage(errorMessage);
                    throw auraEx;
                }
            }
            
        }
    }
    
    
    
    
    // wrapper class 
    public class LeadListWrapper {
        @AuraEnabled public boolean isChecked;
        @AuraEnabled public  Contract_Line_Item__c objLead;
        
        public LeadListWrapper(boolean isChecked, Contract_Line_Item__c objLead){
            this.isChecked = isChecked;
            this.objLead = objLead;
            
            
        }
    }
}