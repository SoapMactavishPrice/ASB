public class SaveContractAsPdf {
    
    public String AttachmentName        {get;set;}
    public Integer Increment            {get;set;}
    public String recordID;
    public Contract ObjContract         {get;set;}
    public Date TodayDate               {get;set;}
    public Account ObjAccount           {get;set;}
    public List<Contract_Line_Item__c> clineItm {get;set;}
    public User ObjUser                 {get;set;}
    public List<Attachment> allAttachmentParentContains {get;set;}
    public Boolean displayPopup         {get;set;}
    public String no2words              {get;set;}
    public Contract cobj;
    public Boolean showSaveContract     {get;set;}
    public String freight               {get;set;}
    public String insurance             {get;set;}
    public Boolean toshowSaveButton     {get;set;}
    public PageReference pdf            {get;set;}
    public String emailId               {get;set;}
    public String subject               {get;set;}
    public String body                  {get;set;}
    public String CC_Addresses          {get;set;}
    public String contractNo;
    public String accountName;
    public Contract_Template__c contractTemplate {get;set;}
    public List<Contract_Template_Line__c> terms      {get;set;}
    public List<Contract_Template_Line__c> gRemark    {get;set;}
    public List<Contract_Template_Line__c> gProvision {get;set;}
    public String ContractNumber        {get;set;}
    public String Contract_Number       {get;set;}
    public Boolean isModalOpen          {get;set;}
    public List<AdditionalDocWrapper> addDocs {get;set;}

    
    public String  address                       {get;set;}
    public String  TodayDate_string              {get;set;}
    public Decimal getWithoutTaxGrandValue       {get;set;}
    public String  getWithoutTaxGrandValueString {get;set;}
    public List<contractLineWrapper> contractLineList {get;set;}

    public SaveContractAsPdf(ApexPages.StandardController standardPageController) {
        showSaveContract       = false;
        isModalOpen            = false;
        getWithoutTaxGrandValue = 0;
        address                = '';
        addDocs                = new List<AdditionalDocWrapper>();
        contractLineList       = new List<contractLineWrapper>();

        recordID = ApexPages.CurrentPage().getParameters().get('Id');

        allAttachmentParentContains = [
            SELECT Id, Name, Body, BodyLength, ParentId, ContentType
            FROM Attachment
            WHERE ParentId = :recordID
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        cobj = [
            SELECT Insurance__c, Insurance_Picklist__c, Freight__c,
                   Freight_Pick__c, Status, Email__c
            FROM Contract
            WHERE Id = :recordID
        ];

        emailId = cobj.Email__c;

        if (cobj.Status == 'RELEASED'
            || cobj.Status == 'Waiting for Down/LC, PO is not issued'
            || cobj.Status == 'Work in Progress-Spec not finalized'
            || cobj.Status == 'Work in Progress'
            || cobj.Status == 'Cancelled') {
            showSaveContract = true;
        }

        freight   = (cobj.Freight_Pick__c    == 'By Seller') ? 'By Seller' : 'By Buyer';
        insurance = (cobj.Insurance_Picklist__c == 'By Seller') ? 'By Seller' : 'By Buyer';

        CreateContract_PDF();
    }

    public void CreateContract_PDF() {
        recordID = ApexPages.CurrentPage().getParameters().get('Id');

        Map<String, Schema.SObjectField> fieldMap =
            Contract.sObjectType.getDescribe().fields.getMap();
        List<String> lstFieldNames = new List<String>(fieldMap.keySet());
        ObjContract = Database.query(
            'SELECT ' + String.join(lstFieldNames, ',') +
            ', CreatedBy.Name, CreatedBy.Email, CreatedBy.Title ' +
            ', Quote__r.ADDRESS_LINE_1__c, Quote__r.ADDRESS_LINE_2__c, Quote__r.ADDRESS_LINE_3__c, ' +
            'Quote__r.CityCustom__c, Quote__r.StateCustom__c, Quote__r.POSTAL_CODE__c, Quote__r.CountryCustom__c ' +
            'FROM Contract WHERE Id = :RecordId LIMIT 1'
        );

        String pattern = '<a\\s+href[^>]+>([^<]+)</a>';
        Contract_Number = ObjContract.Contract_Nos__c != null
            ? ObjContract.Contract_Nos__c.replaceAll(pattern, '$1')
            : '';

        if (ObjContract.CurrencyIsoCode != null && ObjContract.StartDate != null) {
            TodayDate_string = CurrencyFormatter.MapValues(
                ObjContract.CurrencyIsoCode,
                Date.valueOf(ObjContract.StartDate)
            );
        } else {
            TodayDate_string = String.valueOf(ObjContract.StartDate);
        }

        TodayDate = System.today();

        address = '';
        if(string.isNotBlank(ObjContract.Quote__r.ADDRESS_LINE_1__c)) address +=ObjContract.Quote__r.ADDRESS_LINE_1__c+'<br/>';
        if(string.isNotBlank(ObjContract.Quote__r.ADDRESS_LINE_2__c)) address +=ObjContract.Quote__r.ADDRESS_LINE_2__c+'<br/>';
        if(string.isNotBlank(ObjContract.Quote__r.ADDRESS_LINE_3__c)) address +=ObjContract.Quote__r.ADDRESS_LINE_3__c+'<br/>';
        if(string.isNotBlank(ObjContract.Quote__r.CityCustom__c)) address +=ObjContract.Quote__r.CityCustom__c;
        if(string.isNotBlank(ObjContract.Quote__r.StateCustom__c)) address +=', '+ObjContract.Quote__r.StateCustom__c;
        if(string.isNotBlank(ObjContract.Quote__r.POSTAL_CODE__c)) address +=', '+ObjContract.Quote__r.POSTAL_CODE__c;
        if(string.isNotBlank(ObjContract.Quote__r.CountryCustom__c)) address +=', '+ObjContract.Quote__r.CountryCustom__c;

        String accountId  = ObjContract.AccountId;
        String ownerId    = ObjContract.OwnerId;

        ObjUser = [
            SELECT Id, Name, Email, Title, MobilePhone
            FROM User WHERE Id = :ownerId LIMIT 1
        ];

        ObjAccount = [
            SELECT Id, Name, Account_Business__c, Account_Type__c,
                   sales_Address__c, ADDRESS_LINE_1__c, ADDRESS_LINE_2__c,
                   ADDRESS_LINE_3__c, City__c, Country__c, Countries__c,
                   Country_Code__c, Customer_Category__c, Legal_Name__c,
                   ERP_ID__c, External_ID__c, FY__c, Global_Customer__c,
                   Global_Customer_ID__c, Global_Customer_Name__c, GSTIN_No__c,
                   sales_Industry__c, sales_No_of_Employees__c, PAN__c,
                   Party_Group_Name__c, Pin_Code__c, Prepared_By__c,
                   sales_Rating__c, SF_ID__c, State__c, States__c,
                   Subsidary__c, TIN__c
            FROM Account WHERE Id = :accountId
        ];

        clineItm = [
            SELECT Product2Id__c, Product2Id__r.Name, List_Price__c,
                   Is_Tax__c,
                   Quantity__c, Division__c, LineNumber__c,
                   Product_Name__c, Product_Name_2__c, Cancelled__c,
                   UOM__c, Ceiling_Total_Sales_Price__c,
                   Product_Description__c, Total_price__c,
                   Product_Type__c,          
                   Average_Sales_Price__c,   
                   Total_Sales_Price2__c,           
                   (SELECT Id, Name, Product_Name__c, Manual_Product_Name_c__c,
                           Discount__c, Final_Price__c, Manual_Option_Base_Price__c,
                           Description__c, Product_Description__c,
                           Select_Option__c, Quantity__c, Final_Sales_Price__c,
                           Price_Visible__c,
                           Unit_Sales_Price__c, Total_Sales_Price__c,
                           Name_Hide__c,  
                           Total_Quantity__c
                    FROM Contract_Line_Option__r
                    ORDER BY Select_Option__c)
            FROM Contract_Line_Item__c
            WHERE ContractId__c = :RecordId
              AND Cancelled__c != true
            ORDER BY LineNumber__c
        ];

        // ── NEW: Build contractLineList wrapper (mirrors prodLineList) ───────
        contractLineList       = new List<contractLineWrapper>();
        getWithoutTaxGrandValue = 0;

        for (Contract_Line_Item__c cl : clineItm) {

            contractLineWrapper clw = new contractLineWrapper();
            clw.Name              = cl.Product_Name__c;
            clw.Product_Type      = getPicklistLabel('Product_Type__c', cl.Product_Type__c);
            clw.Position_Number   = Integer.valueOf(cl.LineNumber__c);
            clw.Product_Description = cl.Product_Description__c;
            clw.Quantity          = Integer.valueOf(cl.Quantity__c);
            clw.UOM               = cl.UOM__c;
            clw.Is_Tax            = (cl.Is_Tax__c == true);
            clw.Visible_Option_Count = 0;
            clw.childProd         = new List<contractChildWrapper>();

            Decimal allOptTotalPrice = 0;
            Decimal allOptUnitPrice  = 0;
            for (Contract_Line_Option__c cloAll : cl.Contract_Line_Option__r) {
                allOptTotalPrice += (cloAll.Total_Sales_Price__c != null
                                        ? cloAll.Total_Sales_Price__c : 0);
                allOptUnitPrice  += (cloAll.Unit_Sales_Price__c  != null
                                        ? cloAll.Unit_Sales_Price__c  : 0);
            }

            Decimal runtimeTotal = (cl.Total_Sales_Price2__c != null
                                        ? cl.Total_Sales_Price2__c : 0) + allOptTotalPrice;
            Decimal runtimeUnit  = (cl.Average_Sales_Price__c != null
                                        ? cl.Average_Sales_Price__c : 0) + allOptUnitPrice;

            if (!clw.Is_Tax) getWithoutTaxGrandValue += runtimeTotal;

            clw.Total_Price_String = CurrencyFormatter.formatDouble(
                runtimeTotal, ObjContract.CurrencyIsoCode);
            clw.Unit_Price_String  = CurrencyFormatter.formatDouble(
                runtimeUnit, ObjContract.CurrencyIsoCode);

            Decimal checkedOptTotal = 0;
            Decimal checkedOptUnit  = 0;
            for (Contract_Line_Option__c clo : cl.Contract_Line_Option__r) {
                if (clo.Price_Visible__c) {
                    checkedOptTotal += (clo.Total_Sales_Price__c != null
                                            ? clo.Total_Sales_Price__c : 0);
                    checkedOptUnit  += (clo.Unit_Sales_Price__c  != null
                                            ? clo.Unit_Sales_Price__c  : 0);
                }

                if (String.isBlank(clo.Manual_Product_Name_c__c)
                        && String.isBlank(clo.Description__c)
                        && String.isBlank(clo.Product_Description__c)) continue;
                if (String.isNotBlank(clo.Manual_Product_Name_c__c)
                        && clo.Manual_Product_Name_c__c.startsWith('.')) continue;

                contractChildWrapper ccw = new contractChildWrapper();
                ccw.Manual_Product_Name = clo.Manual_Product_Name_c__c;
                ccw.Name_Hide   = (clo.Name_Hide__c == true);
                ccw.Pdf_Checked = (clo.Price_Visible__c == true);
                ccw.Quantity    = (clo.Total_Quantity__c == null)
                                    ? null
                                    : Integer.valueOf(clo.Total_Quantity__c);
                ccw.Unit_Price_String  = (clo.Unit_Sales_Price__c == null) ? null
                    : CurrencyFormatter.formatDouble(
                        clo.Unit_Sales_Price__c, ObjContract.CurrencyIsoCode);
                ccw.Total_Price_String = (clo.Total_Sales_Price__c == null) ? null
                    : CurrencyFormatter.formatDouble(
                        clo.Total_Sales_Price__c, ObjContract.CurrencyIsoCode);

                if (String.isNotBlank(clo.Product_Description__c)) {
                    String description = clo.Product_Description__c
                        .replace('<p>', '<span>')
                        .replace('</p>', '</span>');
                    ccw.Description = description;
                } else {
                    ccw.Description = null;
                }

                if (!ccw.Name_Hide) clw.Visible_Option_Count++;
                clw.childProd.add(ccw);
            }

            if (clw.Visible_Option_Count > 0) {
                clw.Option_Header = String.isNotBlank(clw.Product_Type)
                    ? clw.Product_Type + ' Option' : 'Option';
            }

            if (checkedOptTotal > 0) {
                clw.Total_Price_String = CurrencyFormatter.formatDouble(
                    runtimeTotal - checkedOptTotal, ObjContract.CurrencyIsoCode);
                clw.Unit_Price_String  = CurrencyFormatter.formatDouble(
                    runtimeUnit  - checkedOptUnit,  ObjContract.CurrencyIsoCode);
            }

            contractLineList.add(clw);
        }

        getWithoutTaxGrandValueString = CurrencyFormatter.formatDouble(
            getWithoutTaxGrandValue, ObjContract.CurrencyIsoCode);

        if (String.isNotBlank(ObjContract.Q_PrintShipping__c)) {
            ObjContract.Q_PrintShipping__c =
                ObjContract.Q_PrintShipping__c.replace(
                    'CurrencyIsoCode', ObjContract.CurrencyIsoCode);
        }

        Long longTotal = (Long) ObjContract.Grand_Total__c;
        if (ObjContract.Price_in_Word_Required__c == true && longTotal != null) {
            if (ObjContract.CurrencyIsoCode == 'INR') {
                no2words = ConvertCurrencyToWords.convert(longTotal) + ' Rupees Only.';
            } else {
                no2words = numToWords.convert(
                    Integer.valueOf(longTotal),
                    ObjContract.CurrencyIsoCode.toUpperCase());
            }
        } else {
            no2words = '';
        }

        terms      = new List<Contract_Template_Line__c>();
        gRemark    = new List<Contract_Template_Line__c>();
        gProvision = new List<Contract_Template_Line__c>();

        if (ObjContract.Contract_Template__c != null) {
            List<Contract_Template__c> tmplList = [
                SELECT Id, Active__c, CurrencyIsoCode, Introduction__c,
                       Label__c, Label_For_Colum_1__c, Label_For_Colum_2__c,
                       Label_For_Colum_3__c, Label_For_Colum_4__c, Label_For_Colum_5__c,
                       Label_for_Date__c, Label_for_Draft_Contract__c,
                       Label_for_General_Provision__c, Label_for_General_Remarks__c,
                       Label_for_Page_No__c, Label_for_Page_No_2__c,
                       Label_for_Price_in_Word__c,
                       Label_for_Product_table__c,
                       Label_For_Ref_No__c, Label_For_TO__c, Language__c,
                       Logo__c, OwnerId, Name, Salutation__c, Subsidiary__c,
                       Subsidiary__r.Factory_Location__c, Subsidiary__r.Name__c,
                       Header_Image__c,
                       Draft_Image__c,    
                       Section_4_Required__c, 
                       Section_5_Required__c, 
                       S4_Title__c,           
                       S5_Title__c            
                FROM Contract_Template__c
                WHERE Id = :ObjContract.Contract_Template__c
                  AND Active__c = true
                LIMIT 1
            ];

            if (!tmplList.isEmpty()) {
                contractTemplate = tmplList[0];

                terms = [
                    SELECT Id, Active__c, Content__c, Content_2__c,
                           Is_Terms_Condition__c, Label__c, Name,
                           Contract_Template__c, Sr_No__c,
                           (SELECT Id, Name, Dynamic_Field__c, Field_To_Replace__c
                            FROM Contract_Dynamic_Text__r WHERE Active__c = true)
                    FROM Contract_Template_Line__c
                    WHERE Contract_Template__c = :contractTemplate.Id
                      AND Active__c = true
                      AND Is_Terms_Condition__c = true
                    ORDER BY Sr_No__c
                ];

                gRemark = [
                    SELECT Id, Active__c, Content__c, Content_2__c,
                           Is_General_Remarks__c, Label__c, Name,
                           Contract_Template__c, Sr_No__c,
                           (SELECT Id, Name, Dynamic_Field__c, Field_To_Replace__c
                            FROM Contract_Dynamic_Text__r WHERE Active__c = true)
                    FROM Contract_Template_Line__c
                    WHERE Contract_Template__c = :contractTemplate.Id
                      AND Active__c = true
                      AND Is_General_Remarks__c = true
                    ORDER BY Sr_No__c
                ];

                gProvision = [
                    SELECT Id, Active__c, Content__c, Content_2__c,
                           Is_General_Provision__c, Label__c, Name,
                           Contract_Template__c, Sr_No__c,
                           (SELECT Id, Name, Dynamic_Field__c, Field_To_Replace__c
                            FROM Contract_Dynamic_Text__r WHERE Active__c = true)
                    FROM Contract_Template_Line__c
                    WHERE Contract_Template__c = :contractTemplate.Id
                      AND Active__c = true
                      AND Is_General_Provision__c = true
                    ORDER BY Sr_No__c
                ];

                Map<String, Object> amap =
                    (Map<String, Object>) JSON.deserializeUntyped(
                        JSON.serialize(ObjContract));

                if (terms.size()     > 0) terms      = getDynamicValue(terms, amap);
                if (gRemark.size()   > 0) gRemark    = getDynamicValue(gRemark, amap);
                if (gProvision.size()> 0) gProvision = getDynamicValue(gProvision, amap);
            }
        }
    }

    public class contractLineWrapper {
        public String  Name                  {get;set;}
        public String  Product_Type          {get;set;}
        public String  Option_Header         {get;set;}
        public Decimal Position_Number       {get;set;}
        public String  Product_Description   {get;set;}
        public Integer Quantity              {get;set;}
        public String  UOM                   {get;set;}
        public String  Unit_Price_String     {get;set;}
        public String  Total_Price_String    {get;set;}
        public Boolean Is_Tax                {get;set;}
        public Integer Visible_Option_Count  {get;set;}
        public List<contractChildWrapper> childProd {get;set;}
    }

    public class contractChildWrapper {
        public String  Description          {get;set;}
        public String  Manual_Product_Name  {get;set;}
        public Boolean Name_Hide            {get;set;}
        public Boolean Pdf_Checked          {get;set;}
        public Integer Quantity             {get;set;}
        public String  Unit_Price_String    {get;set;}
        public String  Total_Price_String   {get;set;}
    }

    private static String getPicklistLabel(String fieldApiName, String apiValue) {
        if (String.isBlank(apiValue)) return null;
        Map<String, Schema.SObjectField> fieldMap =
            Schema.SObjectType.Contract_Line_Item__c.fields.getMap();
        if (!fieldMap.containsKey(fieldApiName)) return null;
        for (Schema.PicklistEntry pe :
                fieldMap.get(fieldApiName).getDescribe().getPicklistValues()) {
            if (pe.getValue() == apiValue) return pe.getLabel();
        }
        return null;
    }

    public List<Contract_Template_Line__c> getDynamicValue(List<Contract_Template_Line__c> tList, map<String,Object> amap) {
        for(Contract_Template_Line__c t:tList)
        {
            for(Contract_Dynamic_Text__c Qd:t.Contract_Dynamic_Text__r)
            {
                
                if(amap.get(qd.Field_To_Replace__c) instanceof Integer)
                    t.Content__c=(t.Content__c).replace(qd.Dynamic_Field__c,String.valueOf(amap.get(qd.Field_To_Replace__c)));
                else                                     
                    t.Content__c=(t.Content__c).replace(qd.Dynamic_Field__c,(String)amap.get(qd.Field_To_Replace__c));
            }
        } 
        return tList;
    }

    public PageReference SaveToContract() {
        
        attachContract();                // Method call to attach pdf to Quote
        PageReference pageWhereWeWantToGo =new PageReference('/'+recordID);
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo; //send the User on their way
    }

    public void attachContract()
    {
        //generate and attach the PDF document
        PageReference pdfPage = Page.pdfPreviewContract; //create a page reference to our pdfPreview Visualforce page
        pdfPage.getParameters().put('id',recordID);
        Blob pdfBlob; //create a blob for the PDF content
        if (!Test.isRunningTest()) 
        {  //if we are not in testing context
            pdfBlob = pdfPage.getContent(); //generate the pdf blob
            System.debug('Reachin 1');
        }
        else { //otherwise, we are in testing context and getContent() gets funky so create the blob manually
            pdfBlob = Blob.valueOf('Some Text for a boring PDF file...');
            System.debug('Reachin ');
        }
        if(allAttachmentParentContains.size()==0)
        {
            AttachmentName = ObjContract.ContractNumber+'_V1';  
        }
        else
        {    
            string str = allAttachmentParentContains[0].Name;  
            List<String>splitAttachmentName = str.split('_V');
            str = splitAttachmentName[1];
            List<String>splitbyDot = str.split('\\.');
            str = splitbyDot[0];
            Increment = Integer.valueOf(str) ;
            Increment = Increment+1;
            AttachmentName = ObjContract.ContractNumber+'_V'+Increment;
        }
        Attachment attach = new Attachment(parentId = recordID, Name = AttachmentName+'.pdf', body = pdfBlob); //create the attachment object
        insert attach; //insert the attachment    
    }

    public PageReference SaveAndEmailContract()
    {
        
        attachContract();                    // Method call to attach pdf to Quote
        PageReference pageWhereWeWantToGo =new PageReference('/apex/EmailContract?id='+recordID);
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo; //send the User on their way
    }

    public PageReference Cancel()
    {
        PageReference pf = new PageReference('/'+recordID);
        return pf;
    }
    public void showPopup() {
        displayPopup = true;
    }
    
    public void showModal() {
        User_Setup__c u=[select id,name,Subsidiari__c from User_Setup__c where User__c=:userinfo.getUserId() limit 1];
        isModalOpen = true;
        addDocs = new List<AdditionalDocWrapper>();
        for(Additional_Document__c addDoc : [SELECT Id, Name FROM Additional_Document__c where Active__c = true
                                             and ((OwnerId =: ObjContract.OwnerId and Is_User_Specific__c=true) OR (Subsidiary__c=:u.Subsidiari__c))and Type__c = 'Contract']) {
                                                 addDocs.add(new AdditionalDocWrapper(addDoc));
                                             }
    }

    public PageReference saveAndSend() {
        if(emailId != null){
            
        Contract contractObj = [SELECT Id, Name, Contract_Nos__c From Contract Where id=: recordID];
        
        contractNo=contractObj.Contract_Nos__c;
        accountName=contractObj.Name;
        
        Attachment a;
        
        Set<Id> addDocIds = new Set<Id>();
        for(AdditionalDocWrapper addDoc : addDocs) {
            if(addDoc.isSelected)
                addDocIds.add(addDoc.addDoc.Id);
        }
        
        List<Id> docIds = new List<Id>();
        if(addDocIds.size() > 0) {
            for(ContentDocumentLink cdl : [select Id, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where LinkedEntityId in: addDocIds]) {
                docIds.add(cdl.ContentDocument.LatestPublishedVersionId);
            }
        }
        
        PageReference pdf;
        pdf = Page.PdfPreviewContract;
        pdf.getParameters().put('id',recordID);
        Blob pdfBody;
        if(!test.isRunningTest()){
            pdfBody = pdf.getContentAsPDF();
        }
        else
        {
            pdfBody = blob.valueof('TEST');
        }
        list<Attachment> at=[select id,name,body from Attachment where ParentId=:recordID];
        String name;
        if(at.size()!=0)
            name=accountName +'_V'+at.size()+'.pdf';
        else
        {
            name=accountName +'-'+ contractNo + '_V'+'.pdf'; // 'Quote Pdf.pdf';
        }
        
        Attachment attach = new Attachment();
        attach.ParentId =recordID;
        attach.name = name;
        attach.body = pdfBody ;
        System.debug('tId '+recordID);
        INSERT attach;
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();     
        email.setSubject(Subject);
        system.debug('emailId='+emailId);
        email.setToAddresses(new String[] {emailId});
        if(String.isNotBlank(CC_Addresses)){
            CC_Addresses = CC_Addresses.replaceAll('[;,:]', ',');
            Set<String> CCEmails = new Set<String>();
            for(String str : CC_Addresses.split(',')) {
                if(String.isNotBlank(str))
                    CCEmails.add(str);
            }
            email.setCcAddresses(new List<String>(CCEmails));
            System.debug(CC_Addresses);
        }
        email.setHtmlBody(body);
        
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(attach.Name);
        efa.setBody(attach.Body);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
        if(docIds.size() > 0) {
            email.setEntityAttachments(docIds);
        }
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }); 
        
        PageReference pageRef = new PageReference('/'+recordID);
        pageRef.setRedirect(true);
        return pageRef;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please fill the sender\'s Email Id'));
            return null;
        }
    }
    
    public void SaveValues() {
        isModalOpen = false;
        List<AdditionalDocWrapper>tempList=new List<AdditionalDocWrapper>();
        for(AdditionalDocWrapper addDoc : addDocs) {
            if(addDoc.isSelected)
                tempList.add(addDoc);
        }
        addDocs.clear();
        addDocs.addAll(tempList);
    }

    public void closePopup() {
        isModalOpen = false;
        addDocs.clear();
    }
    
    public PageReference save() {
         
        Contract contractObj = [SELECT Id, Name, Contract_Nos__c From Contract Where id=: recordID];
        
        contractNo=contractObj.Contract_Nos__c;
        accountName=contractObj.Name;
        try{
            Attachment a;
            PageReference pdf;
            pdf = Page.PdfPreviewContract;
            pdf.getParameters().put('id',recordID);
            Blob pdfBody;
            if(!test.isRunningTest()){
                pdfBody = pdf.getContentAsPDF();
            }
            else
            {
                pdfBody = blob.valueof('TEST');
            }
            list<Attachment> at=[select id,name,body from Attachment where ParentId=:recordID];
            system.debug('atttt'+at);
            String name;
            if(at.size()!=0)
            {
                  name=accountName +'_V'+at.size()+'.pdf';
            }
              
            else
            {
                name=accountName +'_V0'+'.pdf';
            }
            Attachment attach = new Attachment();
            attach.ParentId =recordID;
            attach.name = name;
            attach.body = pdfBody ;
            System.debug('tId '+recordID);
            INSERT attach;
            system.debug('attach'+attach);
        }
        catch(exception e){
            system.debug('SaveQuotePdf'+e);
        }
        
        PageReference pageRef = new PageReference('/'+recordID);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    
    class AdditionalDocWrapper {
        public Boolean isSelected {get; set;}
        public Additional_Document__c addDoc {get; set;}
        
        public AdditionalDocWrapper(Additional_Document__c p1) {
            isSelected = false;
            addDoc = p1;
        }
    }
}