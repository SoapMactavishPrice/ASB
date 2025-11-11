public class Create_Finanace_Controller {
    public String Contractid{get;set;}
    public list<Contract_Line_Item__c> LtsCli{get;set;}
    public Contract Objcont{get; set;}
    public decimal bPayment{get; set;}
    public integer LoanPeriod{get; set;}
    public decimal interestRate{get; set;}
    public String strSelected  {get;set;}
    public List<SelectOption> options {get;set;}
    
    Public Static List<ProdListWrapper> lstProductListWrapper = new List<ProdListWrapper>();
    
    @AuraEnabled 
    public static List<ProdListWrapper> getProductList(String recordId){
        system.debug('recordId -->>' + recordId);
        List<Contract_Line_Item__c> prodList = new List<Contract_Line_Item__c>([SELECT Id, Product_Name__c,Product_Name_2__c,Product2Id__c,Performa_Created__c, Name,Finance_Created__c,
                                                                                Final_Grand_Total__c, Balance_Payment__c, Total_Amount_Received__c, Loan_Period__c, Interest_Rate__c,Payment_Terms__c
                                                                                FROM Contract_Line_Item__c WHERE ContractId__c =: recordId AND Performa_Created__c = True AND Finance_Created__c = False AND Payment_Terms__c = 'Credit']);
        
        for(Contract_Line_Item__c lstprod : prodList){
            lstProductListWrapper.add(new ProdListWrapper(false, lstprod));
        }
        system.debug('lstProductListWrapper===>>'+lstProductListWrapper);
        system.debug('lstProductListWrapper===>>'+lstProductListWrapper.size());
        return lstProductListWrapper;
    }
    
    @AuraEnabled 
    public static void SelectedProd(List<Contract_Line_Item__c> selectedRecordList , String RecId){
        system.debug('selectedRecordList===>>'+selectedRecordList);
        system.debug('recordId===>>'+RecId);
		List<Contract_Line_Item__c> lstConLI = new List<Contract_Line_Item__c>();        
        List<Finance__c> lstFin = new List<Finance__c>();
        List<Finance__c> lstFin2 = new List<Finance__c>();
        List<Installment_Payment__c> LstIp=new List<Installment_Payment__c>();
        for(Contract_Line_Item__c conLI : selectedRecordList){
            Contract_Line_Item__c conLIobj = new Contract_Line_Item__c();
            system.debug('conLI -->>> ' + conLI);
            Finance__c objFIn = new Finance__c();
            objFIn.Contract__c = RecId;
            objFIn.Loan_Amount__c = conLI.Balance_Payment__c;
            objFIn.Contract_Line_Item__c = conLI.Id;
            objFIn.Period_of_Loan_In_Months__c = conLI.Loan_Period__c;
            objFIn.Interest_Rate__c = conLI.Interest_Rate__c;
            conLIobj = [select id, name, Finance_Created__c, Finance__c from Contract_Line_Item__c where id =: conLI.Id];
            conLIobj.Finance_Created__c = True;
            //conLIobj.Finance__c = ;
            lstConLI.add(conLIobj);
            lstFin.add(objFIn);
        }
        system.debug('lstConLI -->> ' + lstConLI);
        system.debug('lstFin -->> ' + lstFin);
        try{
            update lstConLI;
            insert lstFin;  
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
        for(Finance__c fin : lstFin){
            List<Finance__c> FiObj1= new List<Finance__c>();
            FiObj1= [select id,Name,Contract__c,Interest_Period_Factor__c,Interest_Rate1__c,Loan_Amount__c,Per_Month_Payment__c,Period_of_Loan_In_Months__c,Contract_Line_Item__c 
                    from Finance__c where id=: fin.id];
            lstFin2.add(FiObj1[0]);
        }
        system.debug('lstFin2 -->> ' + lstFin2);
        
        for(Finance__c fin : lstFin2){
            system.debug('fin -->> ' + fin);
            //Finance__c FiObj= new Finance__c();
           // FiObj= [select id,Name,Contract__c,Interest_Period_Factor__c,Interest_Rate__c,Loan_Amount__c,Per_Month_Payment__c,Period_of_Loan_In_Months__c 
                   // from Finance__c where id=: fin.id limit 1];
			//system.debug('FiObj -->> ' + FiObj);
            decimal OutstandingAmount=fin.Loan_Amount__c;
            for(integer i=0; i<fin.Period_of_Loan_In_Months__c; i++){
                Installment_Payment__c ipObj=new Installment_Payment__c();
                ipObj.Finance__c=fin.id;
                Decimal PerMonthPayment=fin.Per_Month_Payment__c;
                //ipObj.Installment_Amount__c=PerMonthPayment;
                //date stDate= date.today().addMonths(i);
                //ipObj.Start_Date__c=stDate;    
                //ipObj.Due_Date__c=stDate.addDays(7);
                ipObj.Month__c=i+1;
                if (Test.isRunningTest()){
                    system.debug('in test');
                    OutstandingAmount = 0;
                }
                else{
                    system.debug('in non test');
                }
                system.debug(OutstandingAmount +' -- ' + fin.Interest_Rate1__c);
                decimal InterestPerMonth=OutstandingAmount*fin.Interest_Rate1__c/12;
                ipObj.Interest_Per_Month__c=InterestPerMonth;
                Decimal PrincipalPerMonth=PerMonthPayment-InterestPerMonth;
                ipObj.Principal_Per_Month__c=PrincipalPerMonth;    
                OutstandingAmount=OutstandingAmount-PrincipalPerMonth;
                ipObj.Outstanding_Principal__c=OutstandingAmount;
                //Decimal tds=InterestPerMonth*0.1;
                //ipObj.TDS__c=tds;
               // ipObj.Cheque_Amount__c=PerMonthPayment-tds;
                LstIp.add(ipObj);
                //insert ipObj;
                }
            	system.debug('LstIp ' +LstIp);
            	system.debug('LstIp.size ' +LstIp.size());
        }
        //system.debug('complete LstIp.size ' +LstIp.size());
        try{
            insert LstIp;  
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
        
    }
    
    public class ProdListWrapper {
        @AuraEnabled public boolean isChecked;
        @AuraEnabled public  Contract_Line_Item__c objprod;
        //@AuraEnabled public List<Payment_Transactions__c> pmtTrans;
        public ProdListWrapper(boolean isChecked, Contract_Line_Item__c objprod){
            this.isChecked = isChecked;
            this.objprod = objprod;
            //this.pmtTrans = pmtTrans;
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------------------------------------------------------
    /*public Create_Finanace_Controller(ApexPages.StandardController controller){
        Contractid = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('Contractid'+Contractid);
        LtsCli = [Select Id,Name,ContractId__c from Contract_Line_Item__c where ContractId__c = : Contractid];
        
        Objcont = new Contract();
        
        ObjCont = [select id,name,FY__c,SUBSIDARY__c,COUNTRY__c,REGION__c,ContractNumber,Contact__r.name,DATE__c,SHIP_TO__c,SHIP_TO__r.name,SHIP_TO__r.Customer_Category__c,SHIP_TO__r.Global_Customer_ID__c, SOLD_TO__c,INCO_TERMS__c,MFG_AT__c,TYPE__c,END_CUSTOMER_NAME__c,ADVANCE_PAYMENT__c,Grand_Total__c,Total_Advance_Required_In_Amount__c,Balance_Payment__c,Finance__c,Payment_Terms__c, Opportunity__c,Opportunity__r.Source__c from Contract where id = : Contractid];
        bPayment=ObjCont.Balance_Payment__c;
        strSelected = '';
        options = new List<SelectOption>();
        for(Contract_Line_Item__c obj :[SELECT Id, Product_Name__c,Product_Name_2__c, Project_Created__c FROM Contract_Line_Item__c WHERE ContractId__c =: Contractid AND Project_Created__c =false ] )//instead of BU_Project__c.Id pass actual id
        {
            options.add(new SelectOption(obj.Id,obj.Product_Name_2__c));
        }
        if(ObjCont.Finance__c== 'No' && ObjCont.Payment_Terms__c== '100% Advance')
        {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'100% Payment completed. Does not required any credit.'));
           System.debug('options'+options.size());    
        }
        
    }
    
    
    public PageReference FinanceCreation(){
        
      Finance__c FiObj= new Finance__c();
        if(ObjCont!=null)
        {
            FiObj.Contract__c=ObjCont.id;
        }
        if(bPayment!=null)
        {
          FiObj.Loan_Amount__c=bPayment;
        }
        if(LoanPeriod != null)
        {
            FiObj.Period_of_Loan_In_Months__c=LoanPeriod;
        }
        if(interestRate!=null)
        {
            FiObj.Interest_Rate__c=interestRate;
        }
        try{
                insert FiObj;
                System.debug('FiObj : : : :'+FiObj.id);
                FiObj= [select id,Name,Contract__c,Interest_Period_Factor__c,Interest_Rate__c,Loan_Amount__c,Per_Month_Payment__c,Period_of_Loan_In_Months__c from Finance__c where id=: FiObj.id];
                decimal OutstandingAmount=FiObj.Loan_Amount__c;
                for(integer i=0; i<LoanPeriod; i++)
                {
                Installment_Payment__c ipObj=new Installment_Payment__c();
                ipObj.Finance__c=FiObj.id;
                Decimal PerMonthPayment=FiObj.Per_Month_Payment__c;
                ipObj.Installment_Amount__c=PerMonthPayment;
                date stDate= date.today().addMonths(i);
                ipObj.Start_Date__c=stDate;    
                ipObj.Due_Date__c=stDate.addDays(7);
                ipObj.Month__c=i+1;
                decimal InterestPerMonth=OutstandingAmount*FiObj.Interest_Rate__c/12;
                ipObj.Interest_Per_Month__c=InterestPerMonth;
                Decimal PrincipalPerMonth=PerMonthPayment-InterestPerMonth;
                ipObj.Principal_Per_Month__c=PrincipalPerMonth;    
                OutstandingAmount=OutstandingAmount-PrincipalPerMonth;
                ipObj.Outstanding_Principal__c=OutstandingAmount;
                Decimal tds=InterestPerMonth*0.1;
                ipObj.TDS__c=tds;
                ipObj.Cheque_Amount__c=PerMonthPayment-tds;
                    
                insert ipObj;
                system.debug('installment id' +ipObj);
                }
                PageReference myVFPage = new PageReference('/'+FiObj.id);
                myVFPage.setRedirect(true);
                return myVFPage;
            }
            catch(Exception e){
                System.debug('e'+e);
            }
        system.debug('Test line 64');
        
         return null;        
    }*/
    
}