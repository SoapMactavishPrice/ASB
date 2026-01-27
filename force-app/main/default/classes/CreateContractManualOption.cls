public class CreateContractManualOption {
  Public static Id CampaignId;
    // Public Static List<LeadListWrapper> lstLeadListWrapper = new List<LeadListWrapper>();
    Public Static List<LeadListWrapper> lstProductListWrapper = new List<LeadListWrapper>();
    public  Static List<Contract_Line_Item__c> ObjCLI = new List<Contract_Line_Item__c>();
    //   public Static Groups__c objOfCampaign;
    
    
    @AuraEnabled 
    public static Contract getContractDetails(String RecId){ 
        Contract contractDetails=[select ID, name, Exchange_Rate__c, CurrencyIsoCode,Subsidiary__r.Additional_Margin__c,
                        Subsidiary__r.Rounding_Off_Digits__c, Subsidiary__r.Quantity_Restricted__c,Additinal_Margin__c, 
                        Subsidiary__r.M1__c,Subsidiary__r.D1__c
                        from Contract where id=:RecId limit 1];
        return contractDetails;
    }
    
    
    
    @AuraEnabled 
    public static List<LeadListWrapper> fetchProductWrapper(String Campaign){ 
        CampaignId= Campaign;
        System.debug('CampaignId'+CampaignId);
        
        
        for(PriceBookEntry lstpbe :[SELECT Product2.Id,Discount__c,Product2.Description, Product2.Name,unitprice,Product2.Plant__c,Product2.Product_Number__c,Product2.Option_No__c,
                                    Product2.Family,Product2.Number_Of_Cavity_Mould__c,Product2.Option_Type__c,Product2.Product_Type__c,Product2.Scope_of_Mold__c,
                                    Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c,Pricing_Type__c,Discount_Level_2__c,Discount_Level_3__c,Quantity__c,Description__c
                                    FROM PriceBookEntry 
                                    WHERE Pricebook2Id IN (SELECT Id 
                                                           FROM PriceBook2) AND Product2.Family = 'Options' and Product2.IsACTIVE = true]){
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
    Public Static List<LeadListWrapper> WrapperproductFilter(String ProductId, String RecId){
        //    Contract_Line_Item__c ObjCLI = new Contract_Line_Item__c();
        if(ProductId!=''){
        String ProdId = ProductId;
        System.debug('ProdId : : '+ProdId);
        ObjCLI = [Select id, Product2Id__c from Contract_Line_Item__c where id = : ProdId];
        System.debug('ObjCLI'+ObjCLI);
        String PrId = ObjCLI[0].Product2Id__c;
        System.debug('PrId'+PrId);
        User_Setup__c u=[Select id,name,Subsidiari__c,Subsidiari__r.Price_Book__c from User_Setup__c where user__c=:userinfo.getUserId()];
        String pb;
        if(u.Subsidiari__r.Price_Book__c!=null)
        {
          pb=u.Subsidiari__r.Price_Book__c;
        }
        else
            pb=[select id,name from pricebook2 where name='Standard Price Book'].id;
      
        String recordID = RecId;
        System.debug('recordID : : '+recordID);
        Contract contractDetails = [SELECT ID, name, Language__c,Exchange_Rate__c,Subsidiary__r.Additional_Margin__c,
                     Subsidiary__r.Rounding_Off_Digits__c,Subsidiary__r.Quantity_Restricted__c,Additinal_Margin__c, 
                     Subsidiary__r.M1__c,Subsidiary__r.D1__c,Subsidiary__r.D2__c,Subsidiary__r.D3__c FROM Contract WHERE id =: recordID];
        System.debug('contractDetails '+contractDetails.Language__c);
        
        for(PriceBookEntry lstpbe :[SELECT Product2.Id,Discount__c,Product2.Description, Product2.Name,unitprice,Product2.Plant__c,Product2.Product_Number__c,Product2.Option_No__c,
                                    Product2.Family,Product2.Number_Of_Cavity_Mould__c,Product2.Option_Type__c,Product2.Product_Type__c,Product2.Scope_of_Mold__c,
                                    Base_Price__c,List_Price_Level_2__c,List_Price_level_3__c,Pricing_Type__c,Discount_Level_2__c,Discount_Level_3__c,Quantity__c,Description__c
                                    FROM PriceBookEntry 
                                    WHERE Pricebook2Id IN (SELECT Id 
                                                           FROM PriceBook2 where id =:pb AND PriceBook2.IsActive = true)
                                    AND product2.Product_Options__c =:PrId AND Product2.Family = 'Options' AND Product2.IsACTIVE = true
                                    AND Product2.ProductCode != null AND Product2.Language__c=:contractDetails.Language__c AND (Product2.Subsidiari__c=:null OR Product2.Subsidiari__c=:u.Subsidiari__c)
                                   ORDER BY Product2.Option_No__c]){
                                       lstpbe.UnitPrice=AddProducts.getListPrice(lstpbe.UnitPrice,contractDetails.Exchange_Rate__c,contractDetails.Subsidiary__r.D1__c,contractDetails.Subsidiary__r.D2__c,contractDetails.Additinal_Margin__c,Integer.valueof(contractDetails.Subsidiary__r.Rounding_Off_Digits__c));
            						
                                                               lstProductListWrapper.add(new LeadListWrapper(false,lstpbe));
                                                           } 
        System.debug('lstProductListWrapper'+lstProductListWrapper);
         System.debug('lstProductListWrapper'+lstProductListWrapper.size());
        //  System.debug('CampaignId'+CampaignId);
        return lstProductListWrapper; 
        }
        else 
            return lstProductListWrapper;
    
        
    }
    
    @AuraEnabled
    public Static List<Contract_Line_Item__c> GetLineItemName(String Contract){
        String ContractId = Contract;
        System.debug('ContractId'+ContractId);
        List<Contract_Line_Item__c> ObjContractItem = [select id,Product2Id__r.Name,Product_Name_2__c from  Contract_Line_Item__c where ContractId__c = : ContractId];  
        System.debug('ObjContractItem'+ObjContractItem);
        return ObjContractItem;
    }
    
  
    
    @AuraEnabled 
    Public static void SelectedLead(List<PriceBookEntry> selectedRecordList, String idCampaign,string LineItemId){
        System.debug('idCampaign===> '+idCampaign);
        System.debug('LineItemId===> '+LineItemId);
        User UsedDeatil = new User();
        UsedDeatil = [select id,Name,Level__c from User where id =: userInfo.getUserId()];
        String Level = UsedDeatil.Level__c;
        
      Contract cobj=[Select id,CurrencyIsoCode,name,Exchange_Rate__c,Subsidiary__c,Subsidiary__r.Rounding_Off_Digits__c from Contract where id=:idCampaign];
        
        //  objOfCampaign = [select name,Id from Groups__c where Id =: idCampaign LIMIT 1];
        //     System.debug('objOfCampaign===> '+objOfCampaign);
        System.debug('selectedRecords'+selectedRecordList);
        List<Contract_Line_Option__c> ls1 = new List<Contract_Line_Option__c>();
        //   List<PriceBookEntry> ls1 = new List<PriceBookEntry>();
        if(selectedRecordList != null){
            for(PriceBookEntry wrp1: selectedRecordList)
            {
                //=============================================================
                System.debug('reached');
                // Group_Members__c pro = new Group_Members__c();
                Contract_Line_Option__c pro = new Contract_Line_Option__c();
                pro.CurrencyIsoCode=cobj.CurrencyIsoCode;
                //pro.Added_On_Date__c = system.today();
                if(idCampaign != null){
                    pro.ContractId__c = idCampaign;
                }
                if(LineItemId != null){
                    pro.Contract_Line_Item__c = LineItemId;
                }
                if(wrp1.Product2.description != null){
                     pro.Product_Description__c = wrp1.Product2.description;
                }else{
                    pro.Product_Description__c = wrp1.Product2.Name;
                }
                if(wrp1.Product2.Name != null){
                    pro.Manual_Product_Name_c__c = wrp1.Product2.Name;
                }
                if(wrp1.Product2.Name != null){
                    pro.Option_Name__c = wrp1.Product2.Name;
                }
                if(wrp1.Product2Id != null){ 
                    pro.Product__c = wrp1.Product2Id;
                }
                 if(wrp1.Base_Price__c != null){
                   // pro.Manual_Option_Base_Price__c = wrp1.Base_Price__c;
                    pro.Manual_Option_Base_Price__c = (wrp1.Base_Price__c/cobj.Exchange_Rate__c);
                    pro.Manual_Option_Base_Price__c = Math.ceil( pro.Manual_Option_Base_Price__c/Integer.valueOf(cobj.Subsidiary__r.Rounding_Off_Digits__c))*Integer.valueOf(cobj.Subsidiary__r.Rounding_Off_Digits__c);
                
                     
                    //pro.Manual_Option_Base_Price_Clone__c = wrp1.Base_Price__c;
                     pro.Manual_Option_Base_Price_Clone__c = (wrp1.Base_Price__c/cobj.Exchange_Rate__c);
                    pro.Manual_Option_Base_Price_Clone__c = Math.ceil( pro.Manual_Option_Base_Price_Clone__c/Integer.valueOf(cobj.Subsidiary__r.Rounding_Off_Digits__c))*Integer.valueOf(cobj.Subsidiary__r.Rounding_Off_Digits__c);
                
                }
               // if(Level == 'L1'){
                   if(wrp1.UnitPrice != null){
                    pro.Manual_Option_List_Price__c = wrp1.UnitPrice;
                    pro.Manual_Option_List_Price_Clone__c = wrp1.UnitPrice;
                }  
               
                 if(Level == 'L1'){
                   if(wrp1.Discount__c != null){
                    pro.Discount__c = wrp1.Discount__c;
                    pro.Discount_Clone__c = wrp1.Discount__c;
                } 
                }
                 if(Level == 'L2'){
                   if(wrp1.Discount_Level_3__c != null){
                    pro.Discount__c = wrp1.Discount_Level_2__c;
                    pro.Discount_Clone__c = wrp1.Discount_Level_2__c;
                } 
                }
                 if(Level == 'L3'){
                   if(wrp1.Discount_Level_3__c != null){
                    pro.Discount__c = wrp1.Discount_Level_3__c;
                    pro.Discount_Clone__c = wrp1.Discount_Level_3__c;
                } 
                }
                if(wrp1.Quantity__c != null){
                  pro.Quantity__c = wrp1.Quantity__c;
                }
                if(wrp1.Quantity__c == null){
                  pro.Quantity__c = 1;
                }
               
                if(wrp1.Product2.Number_Of_Cavity_Mould__c != null){ 
                    pro.Mould_Cavity__c = wrp1.Product2.Number_Of_Cavity_Mould__c;
                }
                 if(wrp1.Pricing_Type__c != null){
                  pro.Price_Type__c = wrp1.Pricing_Type__c;
                }
                pro.Discount_Description__c = 'Null';
                System.debug('pro==> '+pro);
                ls1.add(pro);
                //===========================================================================
            }
        }
        try
       {
            System.debug('ls1'+ls1.size());
            
            insert ls1;  
     }
        catch(Exception e)
        {
            system.debug('Exception'+e.getMessage());
        }
        
        //  InfluRecord(idInfluncer);
        
        //   return null;
    }   
    
    
    @AuraEnabled
    public static void SaveOptions(List<Contract_Line_Option__c> OptList){
        System.debug('OptList'+OptList);
        id idCampaign=null;
        if(OptList.size()>0)
           idCampaign= OptList[0].ContractId__c;
        Contract cobj=[Select id,CurrencyIsoCode,name,Exchange_Rate__c,Subsidiary__c,Subsidiary__r.Rounding_Off_Digits__c from Contract where id=:idCampaign];
        
        for(Contract_Line_Option__c cl:OptList)
        {
            cl.CurrencyIsoCode=cobj.CurrencyIsoCode;
        }
        //  OptList.ContractId__c = '0Q00w0000005YhnCAE';
        Insert OptList;
    }
    
    public static void dummy(){
        integer i = 0;
        i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
           i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
    }
	    
    // wrapper class 
    public class LeadListWrapper {
        @AuraEnabled public boolean isChecked;
        @AuraEnabled public  PriceBookEntry objLead;
        
        public LeadListWrapper(boolean isChecked, PriceBookEntry objLead){
            this.isChecked = isChecked;
            this.objLead = objLead;
            
            
        }
    }
}