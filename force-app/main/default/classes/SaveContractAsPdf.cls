/********* Edited By - Nitish Kumar *********/
/********* Date      - 05 June, 2021 ********/
/********* Date      - 15 June, 2021 ********/

public class SaveContractAsPdf {
    public String AttachmentName{get;set;}
    public integer Increment{get;set;}
    public string recordID;
    Public Contract ObjContract{get;set;}
    public Date TodayDate{get;set;}
    public Account ObjAccount{get;set;}
    public List<Contract_Line_Item__c> clineItm {get;set;}    
    public User ObjUser{get;set;}
    public  List<Attachment> allAttachmentParentContains{ get; set; }
    public boolean displayPopup {get;set;}
    public String no2words {get;set;}
    public Contract  cobj;
    public Boolean showSaveContract{get;set;}
    public String freight {get; set;}
    public String insurance {get; set;}
    Public Boolean toshowSaveButton{get;set;}
    public Boolean createNew {get; set;}
    public PageReference pdf {get; set;}
    public String emailId {get; set;}
    public String subject {get; set;}
    public String body {get; set;}
    public string CC_Addresses{get; set;}
    public string contractNo;
    public String accountName;
    public Contract_Template__c contractTemplate{get; set;}
    public List<Contract_Template_Line__c> terms{get; set;}
    public List<Contract_Template_Line__c> gRemark{get; set;}
    public List<Contract_Template_Line__c> gProvision{get; set;}    
    
    
    public String ContractNumber{get; set;}
    public String Contract_Number{get; set;}
    
    public Boolean isModalOpen {get; set;}
    public List<AdditionalDocWrapper> addDocs {get; set;}
    
    public SaveContractAsPdf(ApexPages.StandardController standardPageController) {
        showSaveContract= false;
        isModalOpen = false;
        addDocs = new List<AdditionalDocWrapper>();
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        allAttachmentParentContains=[select id,Name,Body,BodyLength,parentId,contentType
                                     from attachment where parentId=:recordID order by CreatedDate DESC limit 1];       
        system.debug('My Fetched Attachment'+allAttachmentParentContains);
        // Quote objQuote = (Quote)stdController.getRecord();
        //    RecordId = objQuote.Id;
        //    clineItm = new List<QuoteLineItem>();
        cobj = [Select Insurance__c, Insurance_Picklist__c, Freight__c, Freight_Pick__c, Status,Email__c 
                from Contract where id =: recordID ];
        system.debug('cobj ===> ' + cobj);
        
         emailId = cobj.Email__c ;
        if(cobj.Status == 'RELEASED' || cobj.Status == 'Waiting for Down/LC, PO is not issued' || cobj.Status == 'Work in Progress-Spec not finalized' || cobj.Status == 'Work in Progress'|| cobj.Status == 'Cancelled'){
            showSaveContract=true;
        }
        if(cobj.Freight_Pick__c == 'By Seller')
            freight = 'By Seller';
        else freight = 'By Buyer';
        
        if(cobj.Insurance_Picklist__c == 'By Seller')
            insurance = 'By Seller';
        else insurance = 'By Buyer';
        
        CreateContract_PDF();  
        
    }
    public void CreateContract_PDF(){
        
        
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        System.debug('RecordId'+RecordId);
        Map<String, Schema.SObjectField> fieldMap = Contract.sObjectType.getDescribe().fields.getMap();
        list<String> lstFieldNames = new List<String>(fieldMap.keySet());
        ObjContract=Database.query('SELECT ' + String.join(lstFieldNames, ',') + ',CreatedBy.Name, CreatedBy.Email,CreatedBy.title from Contract Where id =:RecordId limit 1');
        /*ObjContract = [Select id,Accountid,Barcode__c,ActivatedDate,BillingAddress,EndDate,Name,ContractNumber,Ownerid,StartDate,ContractTerm,Machine_Delivery__c,Document_Name__c
,Description,Pricebook2id,ShippingAddress,Status,SUBSIDARY__c,Subtotal__c,IsSyncing__c,Tax__c,Total_price__c,TYPE__c,Mould_Delivery__c,
ACCOUNT_BUSINESS__c,ACCOUNT_TYPE__c,AdditionalAddress__c,AdditionalName__c,ADDRESS_LINE_1__c,VALIDITY__c,VALITY_DATE__c,Advance_Required__c,
ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,ADVANCE_PAYMENT__c,BillingName__c,Cancelled_Reason__c,CITY__c,CLOSE_LOST_REASON__c,Country_Text__c,
Contact__r.name,Contact_Id__c,ContractId__c,COUNTRY__c,COUNTRY_CODE__c,Advance_Percentage__c,DATE__c,Designation__c,Discount1__c,Discount_RollUp__c,City_Text__c,
Email__c,END_CUSTOMER_NAME__c,ExpirationDate__c,Fax__c,FUNCTION__c,Grand_Total__c,INCO_TERMS__c,LineItemCount__c,MFG_AT__c,State_Text__c,
Opportunity__c,OwnerId__c,Phone__c,POSTAL_CODE__c,PREPARED_BY__c,PROBABILITY__c,QUOTATION_ADDRESSED_TO__c,QUOTATION_CREATE__c,
QU_REVISION_NUMBER__c,REGION__c,Shipping_And_Handling__c,SHIP_TO__c,ShippingName__c,SOLD_TO__c,STATE__c,Status__c,Revision_Number__c,
Insurance_Picklist__c,Freight_Pick__c,Insurance_Amount__c,Freight_Amount1__c,CreatedBy.Name, CreatedBy.Email

from Contract Where id =:RecordId limit 1];
*/
        String pattern = '<a\\s+href[^>]+>([^<]+)</a>';
        Contract_Number = (ObjContract.Contract_Nos__c).replaceAll(pattern, '$1');
        
        /*if(ObjContract.Document_Name__c == Null && ObjContract.Document_Name__c == ''){
ObjContract.Document_Name__c = 'SALES CONTRACT';
}*/
        TodayDate = System.today();
        System.debug('TodayDate : : '+TodayDate);
        String AccountId = ObjContract.AccountId;
        String OwnerName = ObjContract.OwnerId;
        
        
        NumberTOWordConvertion  w1 = new NumberTOWordConvertion();
        no2words=w1.getNumberTOWordConvertion(ObjContract.Grand_Total__c);
        
        ObjUser = [select id,name,email,title,Signature_Image__c from User where id = : OwnerName];
        
        
        ObjAccount = [Select id,name,Account_Business__c,Account_Type__c,sales_Address__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,City__c,Country__c,Billing_City__r.Name,
                      Countries__c,Country_Code__c,Customer_Category__c,Legal_Name__c,ERP_ID__c,External_ID__c,FY__c,Global_Customer__c,Global_Customer_ID__c,Global_Customer_Name__c,Billing_Country__r.Name,
                      GSTIN_No__c,sales_Industry__c,sales_No_of_Employees__c,PAN__c,Party_Group_Name__c,Pin_Code__c,Prepared_By__c,sales_Rating__c/*,Region__c*/, SF_ID__c,Billing_State__r.Name,
                      State__c,States__c,Subsidary__c,TIN__c
                      from Account where id = : AccountId];
        
        System.debug('ObjAccount : : '+ ObjAccount);
        clineItm = new List<Contract_Line_Item__c>(); 
        clineItm = [select Product2Id__c, Product2Id__r.Name , List_Price__c, Quantity__c  ,Division__c,LineNumber__c,Product_Name__c,Product_Name_2__c,Cancelled__c,UOM__c,Ceiling_Total_Sales_Price__c,Product_Description__c,
                    Total_price__c,Name, (select Name,Discount__c,Final_Price__c,Manual_Option_Base_Price__c,Manual_Product_Name_c__c,Cancelled__c, Select_Option__c,Product__r.Name,Option_Name__c,Product_Description__c
                                          from Contract_Line_Option__r where Cancelled__c != true ORDER BY Select_Option__c)
                    from Contract_Line_Item__c 
                    where ContractId__c = :RecordId AND Cancelled__c != true]; 
        System.debug('clineItm : : '+ clineItm.size());
        
        
        contractTemplate = [SELECT id, Active__c, CurrencyIsoCode, Introduction__c, Label__c, Label_For_Colum_1__c, Label_For_Colum_2__c, Label_For_Colum_3__c, 
                            Label_For_Colum_4__c, Label_For_Colum_5__c, Label_for_Date__c, Label_for_Draft_Contract__c, Label_for_General_Provision__c,
                            Label_for_General_Remarks__c, Label_for_Page_No__c, Label_for_Page_No_2__c, Label_for_Price_in_Word__c, Label_for_Product_table__c,
                            Label_For_Ref_No__c, Label_For_TO__c, Language__c, Logo__c, OwnerId, Name, Salutation__c, Subsidiary__c,
                            Subsidiary__r.Factory_Location__c, Subsidiary__r.Name__c
                            FROM Contract_Template__c WHERE ID =:ObjContract.Contract_Template__c and Active__c=true];
        
        terms = [SELECT id, Active__c, Content__c, Is_Terms_Condition__c, Label__c, Name, Contract_Template__c, Sr_No__c,(select id,name,Dynamic_Field__c,Field_To_Replace__c from Contract_Dynamic_Text__r where Active__c=true)
                 FROM Contract_Template_Line__c WHERE Contract_Template__c =:contractTemplate.id and Active__c=true and Is_Terms_Condition__c=true order By Sr_No__c];
        gRemark = [SELECT id, Active__c, Content__c, Is_General_Remarks__c, Label__c, Name, Contract_Template__c, Sr_No__c,(select id,name,Dynamic_Field__c,Field_To_Replace__c from Contract_Dynamic_Text__r where Active__c=true)
                   FROM Contract_Template_Line__c WHERE Contract_Template__c =:contractTemplate.id and Active__c=true and Is_General_Remarks__c=true order By Sr_No__c];
        gProvision = [SELECT id, Active__c, Content__c, Is_General_Provision__c, Label__c, Name, Contract_Template__c, Sr_No__c,(select id,name,Dynamic_Field__c,Field_To_Replace__c from Contract_Dynamic_Text__r where Active__c=true)
                      FROM Contract_Template_Line__c WHERE Contract_Template__c =:contractTemplate.id and Active__c=true and Is_General_Provision__c=true order By Sr_No__c];
        
        map<String,Object> amap=(Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ObjContract));
        terms=getDynamicValue(terms,amap);
        gRemark=getDynamicValue(gRemark,amap);
        gProvision=getDynamicValue(gProvision,amap);
    }
    
    public List<Contract_Template_Line__c> getDynamicValue(List<Contract_Template_Line__c> tList, map<String,Object> amap)
    {
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
         
       // Quote quo11= [SELECT Id, Name, Quote_No__c, Account.Name From Quote Where id=: recordID];
       // quoteNo = quo11.Quote_No__c;
        //accountName=quo11.Name;
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
                //name=accountName +'-'+ contractNo + '_V'+'.pdf'; // 'Contract Pdf.pdf';
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