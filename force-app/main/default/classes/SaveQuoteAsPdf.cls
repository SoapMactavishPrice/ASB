/*
* Controller class for Creating Quote pdf when we click on Create Pdf Button
created by- Kartik Bindal
*/
/********* Edited By - Nitish Kumar *********/
/********* Date 	 - 05 June, 2021 ********/
public class SaveQuoteAsPdf {
    public String AttachmentName{get;set;}
    public integer Increment{get;set;}
    public string recordID;
    public string barcode{get;set;}
    public Decimal getWithoutTaxGrandValue{get;set;}
    public string getWithoutTaxGrandValueString{get;set;}
    public string Grand_Total_c_string{get;set;}
    
    public Integer isTaxCounter{get;set;} 
    Public Quote ObjQuote{get;set;}
    public Date TodayDate{get;set;}
    public string TodayDate_string{get;set;}
    public Account ObjAccount{get;set;}
    public List<Quote_Line_Item_Custom__c> QlineItm {get;set;}
    public List<parentProductWrapper> prodLineList {get;set;}
    public Boolean showOptionsModal {get; set;} // to render options selection modal
    public User ObjUser{get;set;}
    public  List<Attachment> allAttachmentParentContains{ get; set; }
    public boolean displayPopup {get;set;}
    public String no2words {get;set;}
    public Quote qobj ;
    public Boolean showSaveQuote{get;set;}
    public String freight {get; set;}
    public String insurance {get; set;}
    Public Boolean toshowSaveButton{get;set;}
    public Boolean createNew {get; set;}
    public PageReference pdf {get; set;}
    public String emailId {get; set;}
    public String subject {get; set;}
    public String body {get; set;}
    public string CC_Addresses{get; set;}
    public string quoteNo;
    public String accountName;
    public Quote_Template__c quoteTemplate{get; set;}
    public List<Quote_Template_Line__c> terms{get; set;}
    public List<Quote_Template_Line__c> gRemark{get; set;}
    public List<Quote_Template_Line__c> gProvision{get; set;}
    public List<NotesAndAttcahmentDocWrapper> noteslist{get;set;}
    
    public String QuoteNumber{get; set;}
    public string address{get; set;}
    public Boolean isModalOpen {get; set;}
    public List<AdditionalDocWrapper> addDocs {get; set;}
    public User_Setup__c ObjUserSetup{get;set;}

    
    
    public SaveQuoteAsPdf(ApexPages.StandardController standardPageController) {
        showSaveQuote= false;
        getWithoutTaxGrandValue = 0;
        isTaxCounter = 0;
        isModalOpen = false;
        barcode = '';
        addDocs = new List<AdditionalDocWrapper>();
        prodLineList = new List<parentProductWrapper>();
        noteslist = new List<NotesAndAttcahmentDocWrapper>();
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        if(recordID==null){
            recordId='0Q0H1000000BaspKAC';
        }

        System.debug('RecordId'+RecordId);

        // this.updateQuoteOptions();
        
        address = '';
        allAttachmentParentContains=[select id,Name,Body,BodyLength,parentId,contentType
                                     from attachment where parentId=:recordID order by CreatedDate DESC limit 1];       
        system.debug('My Fetched Attachment'+allAttachmentParentContains);
        qobj = [Select Id, Status,Is_DTA_Quote__c, Contact_Email__c, Freight__c,Advance_Percentage__c,Quote_No__c,Insurance__c, OwnerId from quote where id =: recordID ];
        QuoteNumber = qobj.Quote_No__c.substringAfter('>');
        QuoteNumber = QuoteNumber.substringBefore('<');
        emailId = qobj.Contact_Email__c;
        //system.debug('object' +qobj);
        if(qobj.Status == 'RELEASED' || qobj.Status == 'CLOSE - REVISED'|| 
           qobj.Status == 'CLOSE - SC CREATED' || qobj.Status == 'DISCARD/VOID'|| qobj.Status == 'CLOSE - LOST' ){
            showSaveQuote=true;
        }
        //system.debug('showSaveQuote  >>  '+showSaveQuote +' Is_DTA_Quote__c '+ qobj.Is_DTA_Quote__c);
        if(qobj.Insurance__c == 'By Seller')
            insurance = 'By Seller';
        else insurance = 'By Buyer';
        
        if(qobj.Freight__c == 'By Seller')
            freight = 'By Seller';
        else freight = 'By Buyer';
        
        // Quote objQuote = (Quote)stdController.getRecord();
        //    RecordId = objQuote.Id;
        //    QlineItm = new List<QuoteLineItem>();
        // CreateQuote2();
        showOptionsModal = true;
    // show options modal on page load if there are options available
    }
    
    public void add(){
        
    }
    
    public PageReference save() {
        Quote quo11= [SELECT Id, Name, Quote_No__c, Account.Name From Quote Where id=: recordID];
        quoteNo = quo11.Quote_No__c;
        accountName=quo11.Name;
        try{
            Attachment a;
            PageReference pdf;
            pdf = Page.pdfPreview;
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
                name=accountName +'_V'+at.size()+'.pdf';
            else
            {
                name=accountName +'-'+ quoteNo + '_V'+'.pdf'; // 'Quote Pdf.pdf';
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
    
    public PageReference saveAndSendcall() {
        if(emailId != null){
            //emailId = 'balram@finessedirect.com';
            Quote quo11 = [SELECT Id, Name, Quote_No__c From Quote Where id=: recordID];
            
            quoteNo=quo11.Quote_No__c;
            accountName=quo11.Name;
            
            Attachment a;
            
            Set<Id> addDocIds = new Set<Id>();
            for(AdditionalDocWrapper addDoc : addDocs) {
                if(addDoc.isSelected)
                    addDocIds.add(addDoc.addDoc.Id);
            }
            
            List<Id> docIds = new List<Id>();
            if(addDocIds.size() > 0 ) {
                for(ContentDocumentLink cdl : [select Id, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where LinkedEntityId in: addDocIds]) {
                    docIds.add(cdl.ContentDocument.LatestPublishedVersionId);
                }
            }
            
            set<Id> NoteId = new set<Id>();
            for(NotesAndAttcahmentDocWrapper nodDoc : noteslist) {
                if(nodDoc.isSelected){
                    NoteId.add(nodDoc.Id);
                }
            }
            List<Id> notesIds = new List<Id>();
            system.debug('NoteId'+NoteId);
            if(NoteId.size() > 0 ) {
                for(ContentDocumentLink cdl : [select Id, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where Id in: NoteId]) {
                    notesIds.add(cdl.ContentDocument.LatestPublishedVersionId);
                }
            }
            
            PageReference pdf;
            pdf = Page.pdfPreview;
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
                name=accountName +'-'+ quoteNo + '_V'+'.pdf'; // 'Quote Pdf.pdf';
            }
            
            Attachment attach = new Attachment();
            attach.ParentId =recordID;
            attach.name = name;
            attach.body = pdfBody ;
            System.debug('tId '+recordID);
            INSERT attach;
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();     
            email.setSubject(Subject);
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
            system.debug('notesIds'+notesIds);
            if(notesIds.size() > 0){
                email.setEntityAttachments(notesIds);
            }
            System.debug(emailId);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }); 
            
            PageReference pageRef = new PageReference('/'+recordID);
            pageRef.setRedirect(true);
            return pageRef;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please fill the sender\'s Email Id'));
            return null;
        }
    }
    
    public void CreateQuote(){
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        System.debug('RecordId'+RecordId);
        if(recordID==null){
            recordId='0Q0H1000000BaspKAC';
        }
            
        Map<String, Schema.SObjectField> fieldMap = Quote.sObjectType.getDescribe().fields.getMap();
        list<String> lstFieldNames = new List<String>(fieldMap.keySet());
        ObjQuote=Database.query('SELECT ' + String.join(lstFieldNames, ',') + ',CreatedBy.Name, CreatedBy.Email,CreatedBy.title,Owner.Name, Owner.Email,Owner.title from Quote Where id=:RecordId limit 1');
        
        System.debug('ObjQuote : : '+ObjQuote);
        if(objQuote.Status == 'RELEASED' || objquote.Status =='UNDER NEGOTIATION - COOL' || objquote.Status =='UNDER NEGOTIATION - HOT' ||
           objquote.Status =='WAITING FOR SC/DRG APPROVAL/CLARIFICATION' || objquote.Status =='CLOSE - REVISIED' || objquote.Status =='CLOSE - SC CREATED'){
               toshowSaveButton = true;
           }else{
               toshowSaveButton = false;   
           }
        
        //User us = [SELECT Id,Name, DefaultCurrencyIsoCode FROM User where Id= : Userinfo.getUserId()];
        if(ObjQuote.CurrencyIsoCode != null && ObjQuote.Quote_Release_Date__c != null){
            TodayDate_string = CurrencyFormatter.MapValues(ObjQuote.CurrencyIsoCode,date.valueOf(ObjQuote.Quote_Release_Date__c));
        }else{
            TodayDate_string = string.valueOf(ObjQuote.Quote_Release_Date__c);
        }
        
        string barcodeText ='';
        
        if(string.isBlank(ObjQuote.Quote_Number1__c)){
         barcodeText =  ObjQuote.QuoteNumber;
        } else if(string.isNotBlank(ObjQuote.Quote_Number1__c)){
            barcodeText += ObjQuote.Quote_Number1__c;
            if(ObjQuote.QU_REVISION_NUMBER__c =='000' || ObjQuote.QU_REVISION_NUMBER__c ==''){
                barcodeText += '';
            }
            else{
                barcodeText += '-'+ObjQuote.QU_REVISION_NUMBER__c;
            }
        }
        
        
        //generate barcode
        if(string.isNotBlank(barcodeText)){
            barcode = 'https://barcode.tec-it.com/barcode.ashx?data='+barcodeText+'&code=Code128&translate-esc=on';
        }
        
        address = '';
        if(string.isNotBlank(ObjQuote.ADDRESS_LINE_1__c)) address +=ObjQuote.ADDRESS_LINE_1__c+'<br/>';
        if(string.isNotBlank(ObjQuote.ADDRESS_LINE_2__c)) address +=ObjQuote.ADDRESS_LINE_2__c+'<br/>';
        if(string.isNotBlank(ObjQuote.ADDRESS_LINE_3__c)) address +=ObjQuote.ADDRESS_LINE_3__c+'<br/>';
        if(string.isNotBlank(ObjQuote.CityCustom__c)) address +=ObjQuote.CityCustom__c;
        if(string.isNotBlank(ObjQuote.StateCustom__c)) address +=', '+ObjQuote.StateCustom__c;
        if(string.isNotBlank(ObjQuote.POSTAL_CODE__c)) address +=', '+ObjQuote.POSTAL_CODE__c;
        if(string.isNotBlank(ObjQuote.CountryCustom__c)) address +=', '+ObjQuote.CountryCustom__c;
        
        TodayDate = System.today();
        System.debug('TodayDate : : '+TodayDate);
        String AccountId = ObjQuote.AccountId;
        String OwnerName = ObjQuote.CreatedBy.Name;
        system.debug('ObjUser ---> ' + OwnerName+' id   ' + ObjQuote.CreatedById);
        
        
        ObjUser = [select id,name,email, title, MobilePhone from User where Id =: ObjQuote.OwnerId Limit 1];
        
        ObjUserSetup=[select id, Signature_Image__c from User_Setup__c where User__c=:ObjQuote.OwnerId limit 1];
        //imageSignature = u.Signature_Image__c;
        
        ObjAccount = [Select id,name,Account_Business__c,Account_Type__c,sales_Address__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,City__c,Country__c,
                      Countries__c,Country_Code__c,Customer_Category__c,ERP_ID__c,External_ID__c,FY__c,Global_Customer__c,Global_Customer_ID__c,Global_Customer_Name__c,
                      GSTIN_No__c,sales_Industry__c,sales_No_of_Employees__c,PAN__c,Legal_Name__c,Party_Group_Name__c,Pin_Code__c,Prepared_By__c,sales_Rating__c/*,Region__c*/, SF_ID__c,
                      State__c,States__c,Subsidary__c,TIN__c
                      from Account where id = : AccountId];
        System.debug('ObjAccount : : '+ ObjAccount);
        QlineItm = new List<Quote_Line_Item_Custom__c>(); 
    QlineItm = [select Product__c, Product__r.Name,List_Price__c,Is_Tax__c,Name,Quantity__c,Division__c,Is_Manual__c,Total_List_Price__c,Total_Sales_Price__c,UOM__c,Ceiling_Total_Sales_Price__c,Product_Name__c,Line_Item_Id__c,Product_Code__c,Manual_Product_Code__c,Overall_Discount__c,Product_Description__c,
            (select Id, Name,Product_Name__c,Manual_Product_Name__c,Discount__c,Final_Price__c,Manual_Option_Base_Price__c,Description__c, Select_Option__c, Quantity__c, Sales_Price__c, Pdf_Checked__c, Product__r.Name from Quote_Line_Options__r ORDER BY Pdf_Sort__c) 
            from Quote_Line_Item_Custom__c where Quote__c = :RecordId and Quantity__c >:0  Order BY Sr_No__c];  
        System.debug('QlineItm'+QlineItm);
        
    List<Quote_Line_Item_Custom__c> QlineItm1 = [select Product__c,Is_Tax__c, Product__r.Name,List_Price__c,Name,Quantity__c,Is_Manual__c,Division__c,Total_List_Price__c,Total_Sales_Price__c,UOM__c,Ceiling_Total_Sales_Price__c,Product_Name__c,Line_Item_Id__c,Product_Code__c,Manual_Product_Code__c,Overall_Discount__c,Product_Description__c,
                             (select Id, Name,Product_Name__c,Manual_Product_Name__c,Discount__c,Final_Price__c,Manual_Option_Base_Price__c,Description__c, Select_Option__c, Quantity__c, Sales_Price__c, Pdf_Checked__c, Product__r.Name from Quote_Line_Options__r ORDER BY Pdf_Sort__c) 
                             from Quote_Line_Item_Custom__c  where Quote__c = :RecordId and  Quantity__c >:0 Order BY Sr_No__c]; 
        
        prodLineList = new List<parentProductWrapper>();
        getWithoutTaxGrandValue = 0;
        for(Quote_Line_Item_Custom__c ql : QlineItm1){
            parentProductWrapper pli = new parentProductWrapper();
            pli.Name = ql.Product_Name__c;
            pli.Product_Name = ql.Product_Name__c;
            pli.isstartWith_a = false;
            pli.isstartWith_Hash = false;
            pli.Is_Tax = ql.Is_Tax__c;
            if(ql.Is_Tax__c){
                isTaxCounter=isTaxCounter+1;
            }
            if(!ql.Is_Tax__c){
                if(ql.Ceiling_Total_Sales_Price__c != null){
                    getWithoutTaxGrandValue += ql.Ceiling_Total_Sales_Price__c;
                }
            }
            
            if(ql.Is_Manual__c){  
                pli.Line_Item_Id = ql.Manual_Product_Code__c;
            }
            else{
                 pli.Line_Item_Id = ql.Product_Code__c;
            }
            
           if(string.isNotBlank(ql.Product_Description__c)){
                   if(ql.Product_Description__c.contains('<p>') || ql.Product_Description__c.contains('</p>')){
                     // ql.Product_Description__c=   ql.Product_Description__c.replace('<p>','<span>');
                     // ql.Product_Description__c=  ql.Product_Description__c.replace('</p>','</span>');
                    }
            
            //if(string.isNotBlank(ql.Product_Description__c) && ql.Product_Description__c.startsWith('@')){
            if(string.isNotBlank(ql.Product_Description__c) && (ql.Product_Description__c.contains('>@') || ql.Product_Description__c.startsWith('@'))) {
              
                pli.isstartWith_a = true;
                pli.isstartWith_Hash = false;
                //pli.Product_Description = ql.Product_Description__c.replace('@','');
                pli.totalValue = ql.Ceiling_Total_Sales_Price__c / ql.Quantity__c;
            }
            else if(string.isNotBlank(ql.Product_Description__c) && (ql.Product_Description__c.contains('>#')  || ql.Product_Description__c.startsWith('#'))){
            //else if(string.isNotBlank(ql.Product_Description__c) && ql.Product_Description__c.startsWith('#')){
                pli.isstartWith_Hash = true;
                pli.isstartWith_a = false;
                pli.Product_Description = ql.Product_Description__c.replace('#','');
                pli.totalValue = ql.Ceiling_Total_Sales_Price__c;
                
            } 
            else{
                pli.Product_Description = ql.Product_Description__c;
                if(ql.Ceiling_Total_Sales_Price__c != null){
                    pli.totalValue = ql.Ceiling_Total_Sales_Price__c / ql.Quantity__c  ;
                }
            }
           }
            
            pli.Ceiling_Total_Sales_Price = ql.Ceiling_Total_Sales_Price__c;
            system.debug('Ceiling_Total_Sales_Price__c'+ql.Ceiling_Total_Sales_Price__c);
            if(ql.Ceiling_Total_Sales_Price__c != null){
                pli.Ceiling_Total_Sales_Pricestring = CurrencyFormatter.formatDouble(ql.Ceiling_Total_Sales_Price__c ,ObjQuote.CurrencyIsoCode);
            //if(ql.List_Price__c != null)
                pli.totalValueString = CurrencyFormatter.formatDouble(ql.Ceiling_Total_Sales_Price__c / ql.Quantity__c ,ObjQuote.CurrencyIsoCode);
            }
            pli.Quantity = Integer.valueOf(ql.Quantity__c);
            pli.UOM =  ql.UOM__c;
            
            pli.childProd = new List<childProductWrapper>();
            // keep the source Quote Line Item Id for reference
            pli.QuoteLineId = ql.Id;
            for(Quote_Line_Options__c qpl : ql.Quote_Line_Options__r){
                if (qpl.Pdf_Checked__c) {
                    getWithoutTaxGrandValue += qpl.Sales_Price__c;
                } 
                if(qpl.Manual_Product_Name__c != null){
                    if(!qpl.Manual_Product_Name__c.startsWith('.')){
                        childProductWrapper chl = new childProductWrapper();
                        chl.Manual_Product_Name = qpl.Manual_Product_Name__c;
                        chl.isstartWith_a = false;
                        chl.isstartWith_Hash = false;
                        // option metadata
                        chl.OptionId = qpl.Id;
                        chl.Pdf_Checked = (qpl.Pdf_Checked__c == true);
                        chl.Quantity = (qpl.Quantity__c == null) ? null : Integer.valueOf(qpl.Quantity__c);
                        chl.Sales_Price = CurrencyFormatter.formatDouble(qpl.Sales_Price__c, ObjQuote.CurrencyIsoCode);
                        // map manual/base price if present
                        chl.Manual_Option_List_Price = CurrencyFormatter.formatDouble(qpl.Manual_Option_Base_Price__c, ObjQuote.CurrencyIsoCode);

                        if(string.isNotBlank(qpl.Description__c)){
                            if(qpl.Description__c.contains('<p>') || qpl.Description__c.contains('</p>')){
                                qpl.Description__c = qpl.Description__c.replace('<p>','<span>');
                                qpl.Description__c = qpl.Description__c.replace('</p>','</span>');
                            }
                            if(qpl.Description__c.contains('>@') || qpl.Description__c.startsWith('@')){
                                chl.isstartWith_a = true;
                                chl.isstartWith_Hash = false;
                                chl.Description = qpl.Description__c;
                                pli.isstartWith_a = true;
                            } else if(string.isNotBlank(qpl.Description__c) && (qpl.Description__c.contains('>#') || qpl.Description__c.startsWith('#'))){
                                chl.isstartWith_Hash = true;
                                chl.isstartWith_a = false;
                                chl.Description = qpl.Description__c;
                            } else{
                                chl.Description = qpl.Description__c;
                            }
                        }
                        pli.childProd.add(chl);
                    }
                }
            }
            prodLineList.add(pli);
            
        }
        
        getWithoutTaxGrandValuestring =CurrencyFormatter.formatDouble(getWithoutTaxGrandValue ,ObjQuote.CurrencyIsoCode);
        
        system.debug('grand value-->'+getWithoutTaxGrandValuestring);
        system.debug('prodLineList'+prodLineList);
        
        
        //CurrencyToWords w1 = new CurrencyToWords();
        //NumberTOWordConvertion  w1 = new NumberTOWordConvertion();
        ConvertCurrencyToWords w1 = new ConvertCurrencyToWords();
        //no2words=ConvertCurrencyToWords.english_number(ObjQuote.Quote_Total_Summary_of_Sales_Price__c);// getNumberTOWordConvertion(ObjQuote.Total_Price_Ceiling__c);
        
        
        Grand_Total_c_string = CurrencyFormatter.formatDouble(ObjQuote.Grand_Total__c, ObjQuote.CurrencyIsoCode);   
        Long longTotalAmount = (Long) ObjQuote.Grand_Total__c;
        if(ObjQuote.Price_in_Word_Required__c == true){
            if(ObjQuote.CurrencyIsoCode == 'INR'){
                no2words=(ConvertCurrencyToWords.convert(longTotalAmount)) + ' Rupees Only.';
            }else{
                no2words=numToWords.convert(Integer.valueOf(longTotalAmount),(ObjQuote.CurrencyIsoCode).toUpperCase());
            }
             
        }else{
            no2words='';
        }
        
        quoteTemplate = [SELECT id,Show_Ex_Works__c,Active__c, CurrencyIsoCode, Introduction__c, Label__c, Label_For_Colum_1__c, Label_For_Colum_2__c, Label_For_Colum_3__c, 
                         Label_For_Colum_4__c, Label_For_Colum_5__c, Label_for_Date__c, Label_for_Draft_Quote__c, Label_for_General_Provision__c,
                         Label_for_General_Remarks__c, Label_for_Page_No__c, Label_for_Page_No_2__c, Label_for_Price_in_Word__c, Label_for_Product_table__c,
                         Label_For_Ref_No__c, Label_For_TO__c, Language__c, Logo__c, OwnerId, Name, Salutation__c, Subsidiary__c,
                         Subsidiary__r.Factory_Location__c, Subsidiary__r.Name__c, ISO_Code_Label__c, ISO_Code_Text__c,
                         Company_Name_Label__c, Sales_Engineer_Label__c, Quotation_No_Label__c, Quotation_Date_Label__c, Cover_Page__c,
                         ASB_Sign_Section2__c, ASB_Sign_Section3__c, ASB_Sign_Section4__c, ASB_Sign_Section5__c, Cover_Page_Required__c,
                         Customer_Sign_Section2__c, Customer_Sign_Section3__c, Customer_Sign_Section4__c, Customer_Sign_Section5__c, Footer_Image__c,
                         Header_Image__c, Section_2_Required__c, Section_4_Required__c, Section_5_Required__c, Footer_Image_Required__c, Footer_Text__c, Footer_Text_Required__c,
                         S2_Introduction__c,S2_Title__c,S3_title__c,S4_Title__c,S5_Title__c, Draft_Image__c, Label_For_Quotation_No__c,Manufacture_Place__c	
                         FROM Quote_Template__c WHERE ID =:ObjQuote.Quote_Template__c and Active__c=true];
        
        system.debug('ObjQuote.Quote_Template__'+ObjQuote.Quote_Template__c);
        system.debug('quoteTemplate.id'+quoteTemplate.id);
        terms = [SELECT id, Active__c, Content__c,Content_2__c, Is_Terms_Condition__c, Label__c, Name, Quote_Template__c, Sr_No__c,(select id,name,Dynamic_Field__c,Field_To_Replace__c from Quote_Dynamic_Text__r where Active__c=true)
                 FROM Quote_Template_Line__c WHERE Quote_Template__c =:quoteTemplate.id and Active__c=true and Is_Terms_Condition__c=true order By Sr_No__c];
        gRemark = [SELECT id, Active__c, Content__c,Content_2__c, Is_General_Remarks__c, Label__c, Name, Quote_Template__c, Sr_No__c,(select id,name,Dynamic_Field__c,Field_To_Replace__c from Quote_Dynamic_Text__r where Active__c=true)
                   FROM Quote_Template_Line__c WHERE Quote_Template__c =:quoteTemplate.id and Active__c=true and Is_General_Remarks__c=true order By Sr_No__c];
        gProvision = [SELECT id, Active__c, Content__c, Content_2__c,Is_General_Provision__c, Label__c, Name, Quote_Template__c, Sr_No__c,(select id,name,Dynamic_Field__c,Field_To_Replace__c from Quote_Dynamic_Text__r where Active__c=true)
                      FROM Quote_Template_Line__c WHERE Quote_Template__c =:quoteTemplate.id and Active__c=true and Is_General_Provision__c=true order By Sr_No__c];
        
        map<String,Object> amap=(Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ObjQuote));
        if(terms.size() > 0){
            terms=getDynamicValue(terms,amap);
        }
        
        
        for(Quote_Template_Line__c qtp  : gRemark){
            if(qtp.Label__c == 'SCOPE OF SUPPLY'){
                system.debug('inside label'+qtp.Label__c);
                qtp.Label__c = '<b>'+qtp.Label__c+'</b>';
                system.debug('inside label'+qtp.Label__c);
            }
        } 
        
        gRemark=getDynamicValue(gRemark,amap);
        gProvision=getDynamicValue(gProvision,amap); 
        this.updateOptions();
    }

    public void CreateQuote2(){
        recordID =  ApexPages.CurrentPage().getparameters().get('Id');
        System.debug('RecordId'+RecordId);
        if(recordID==null){
            recordId='0Q0H1000000BaspKAC';
        }

        // this.updateOptions();
            
        Map<String, Schema.SObjectField> fieldMap = Quote.sObjectType.getDescribe().fields.getMap();
        list<String> lstFieldNames = new List<String>(fieldMap.keySet());
        ObjQuote=Database.query('SELECT ' + String.join(lstFieldNames, ',') + ',CreatedBy.Name, CreatedBy.Email,CreatedBy.title,Owner.Name, Owner.Email,Owner.title from Quote Where id=:RecordId limit 1');
        
        System.debug('ObjQuote : : '+ObjQuote);
        if(objQuote.Status == 'RELEASED' || objquote.Status =='UNDER NEGOTIATION - COOL' || objquote.Status =='UNDER NEGOTIATION - HOT' ||
           objquote.Status =='WAITING FOR SC/DRG APPROVAL/CLARIFICATION' || objquote.Status =='CLOSE - REVISIED' || objquote.Status =='CLOSE - SC CREATED'){
               toshowSaveButton = true;
           }else{
               toshowSaveButton = false;   
           }
        
        //User us = [SELECT Id,Name, DefaultCurrencyIsoCode FROM User where Id= : Userinfo.getUserId()];
        if(ObjQuote.CurrencyIsoCode != null && ObjQuote.Quote_Release_Date__c != null){
            TodayDate_string = CurrencyFormatter.MapValues(ObjQuote.CurrencyIsoCode,date.valueOf(ObjQuote.Quote_Release_Date__c));
        }else{
            TodayDate_string = string.valueOf(ObjQuote.Quote_Release_Date__c);
        }
        
        string barcodeText ='';
        
        if(string.isBlank(ObjQuote.Quote_Number1__c)){
         barcodeText =  ObjQuote.QuoteNumber;
        } else if(string.isNotBlank(ObjQuote.Quote_Number1__c)){
            barcodeText += ObjQuote.Quote_Number1__c;
            if(ObjQuote.QU_REVISION_NUMBER__c =='000' || ObjQuote.QU_REVISION_NUMBER__c ==''){
                barcodeText += '';
            }
            else{
                barcodeText += '-'+ObjQuote.QU_REVISION_NUMBER__c;
            }
        }
        
        
        //generate barcode
        if(string.isNotBlank(barcodeText)){
            barcode = 'https://barcode.tec-it.com/barcode.ashx?data='+barcodeText+'&code=Code128&translate-esc=on';
        }
        
        address = '';
        if(string.isNotBlank(ObjQuote.ADDRESS_LINE_1__c)) address +=ObjQuote.ADDRESS_LINE_1__c+'<br/>';
        if(string.isNotBlank(ObjQuote.ADDRESS_LINE_2__c)) address +=ObjQuote.ADDRESS_LINE_2__c+'<br/>';
        if(string.isNotBlank(ObjQuote.ADDRESS_LINE_3__c)) address +=ObjQuote.ADDRESS_LINE_3__c+'<br/>';
        if(string.isNotBlank(ObjQuote.CityCustom__c)) address +=ObjQuote.CityCustom__c;
        if(string.isNotBlank(ObjQuote.StateCustom__c)) address +=', '+ObjQuote.StateCustom__c;
        if(string.isNotBlank(ObjQuote.POSTAL_CODE__c)) address +=', '+ObjQuote.POSTAL_CODE__c;
        if(string.isNotBlank(ObjQuote.CountryCustom__c)) address +=', '+ObjQuote.CountryCustom__c;
        
        TodayDate = System.today();
        System.debug('TodayDate : : '+TodayDate);
        String AccountId = ObjQuote.AccountId;
        String OwnerName = ObjQuote.CreatedBy.Name;
        system.debug('ObjUser ---> ' + OwnerName+' id   ' + ObjQuote.CreatedById);
        
        
        ObjUser = [select id,name,email, title, MobilePhone from User where Id =: ObjQuote.OwnerId Limit 1];
        
        ObjUserSetup=[select id, Signature_Image__c from User_Setup__c where User__c=:ObjQuote.OwnerId limit 1];
        //imageSignature = u.Signature_Image__c;
        
        ObjAccount = [Select id,name,Account_Business__c,Account_Type__c,sales_Address__c,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,City__c,Country__c,
                      Countries__c,Country_Code__c,Customer_Category__c,ERP_ID__c,External_ID__c,FY__c,Global_Customer__c,Global_Customer_ID__c,Global_Customer_Name__c,
                      GSTIN_No__c,sales_Industry__c,sales_No_of_Employees__c,PAN__c,Legal_Name__c,Party_Group_Name__c,Pin_Code__c,Prepared_By__c,sales_Rating__c/*,Region__c*/, SF_ID__c,
                      State__c,States__c,Subsidary__c,TIN__c
                      from Account where id = : AccountId];
        System.debug('ObjAccount : : '+ ObjAccount);
        QlineItm = new List<Quote_Line_Item_Custom__c>(); 
    QlineItm = [select Product__c, Product__r.Name,List_Price__c,Is_Tax__c,Name,Quantity__c,Division__c,Is_Manual__c,Total_List_Price__c,Total_Sales_Price__c,UOM__c,Ceiling_Total_Sales_Price__c,Product_Name__c,Line_Item_Id__c,Product_Code__c,Manual_Product_Code__c,Overall_Discount__c,Product_Description__c,
            (select Id, Name,Product_Name__c,Manual_Product_Name__c,Discount__c,Final_Price__c,Manual_Option_Base_Price__c,Description__c, Select_Option__c, Quantity__c, Sales_Price__c, Pdf_Checked__c, Product__r.Name from Quote_Line_Options__r ORDER BY Pdf_Sort__c) 
            from Quote_Line_Item_Custom__c where Quote__c = :RecordId and Quantity__c >:0  Order BY Sr_No__c];  
        System.debug('QlineItm'+QlineItm);
        
    List<Quote_Line_Item_Custom__c> QlineItm1 = [select Product__c,Is_Tax__c, Product__r.Name,List_Price__c,Name,Quantity__c,Is_Manual__c,Division__c,Total_List_Price__c,Total_Sales_Price__c,UOM__c,Ceiling_Total_Sales_Price__c,Product_Name__c,Line_Item_Id__c,Product_Code__c,Manual_Product_Code__c,Overall_Discount__c,Product_Description__c,
                             (select Id, Name,Product_Name__c,Manual_Product_Name__c,Discount__c,Final_Price__c,Manual_Option_Base_Price__c,Description__c, Select_Option__c, Quantity__c, Sales_Price__c, Pdf_Checked__c, Product__r.Name from Quote_Line_Options__r ORDER BY Pdf_Sort__c) 
                             from Quote_Line_Item_Custom__c  where Quote__c = :RecordId and  Quantity__c >:0 Order BY Sr_No__c]; 
        
        prodLineList = new List<parentProductWrapper>();
        getWithoutTaxGrandValue = 0;
        for(Quote_Line_Item_Custom__c ql : QlineItm1){
            parentProductWrapper pli = new parentProductWrapper();
            pli.Name = ql.Product_Name__c;
            pli.Product_Name = ql.Product_Name__c;
            pli.isstartWith_a = false;
            pli.isstartWith_Hash = false;
            pli.Is_Tax = ql.Is_Tax__c;
            if(ql.Is_Tax__c){
                isTaxCounter=isTaxCounter+1;
            }
            if(!ql.Is_Tax__c){
                if(ql.Ceiling_Total_Sales_Price__c != null){
                    getWithoutTaxGrandValue += ql.Ceiling_Total_Sales_Price__c;
                }
            }
            
            if(ql.Is_Manual__c){  
                pli.Line_Item_Id = ql.Manual_Product_Code__c;
            }
            else{
                 pli.Line_Item_Id = ql.Product_Code__c;
            }
            
           if(string.isNotBlank(ql.Product_Description__c)){
                   if(ql.Product_Description__c.contains('<p>') || ql.Product_Description__c.contains('</p>')){
                     // ql.Product_Description__c=   ql.Product_Description__c.replace('<p>','<span>');
                     // ql.Product_Description__c=  ql.Product_Description__c.replace('</p>','</span>');
                    }
            
            //if(string.isNotBlank(ql.Product_Description__c) && ql.Product_Description__c.startsWith('@')){
            if(string.isNotBlank(ql.Product_Description__c) && (ql.Product_Description__c.contains('>@') || ql.Product_Description__c.startsWith('@'))) {
              
                pli.isstartWith_a = true;
                pli.isstartWith_Hash = false;
                //pli.Product_Description = ql.Product_Description__c.replace('@','');
                pli.totalValue = ql.Ceiling_Total_Sales_Price__c / ql.Quantity__c;
            }
            else if(string.isNotBlank(ql.Product_Description__c) && (ql.Product_Description__c.contains('>#')  || ql.Product_Description__c.startsWith('#'))){
            //else if(string.isNotBlank(ql.Product_Description__c) && ql.Product_Description__c.startsWith('#')){
                pli.isstartWith_Hash = true;
                pli.isstartWith_a = false;
                pli.Product_Description = ql.Product_Description__c.replace('#','');
                pli.totalValue = ql.Ceiling_Total_Sales_Price__c;
                
            } 
            else{
                pli.Product_Description = ql.Product_Description__c;
                if(ql.Ceiling_Total_Sales_Price__c != null){
                    pli.totalValue = ql.Ceiling_Total_Sales_Price__c / ql.Quantity__c  ;
                }
            }
           }
            
            pli.Ceiling_Total_Sales_Price = ql.Ceiling_Total_Sales_Price__c;
            system.debug('Ceiling_Total_Sales_Price__c'+ql.Ceiling_Total_Sales_Price__c);
            if(ql.Ceiling_Total_Sales_Price__c != null){
                pli.Ceiling_Total_Sales_Pricestring = CurrencyFormatter.formatDouble(ql.Ceiling_Total_Sales_Price__c ,ObjQuote.CurrencyIsoCode);
            //if(ql.List_Price__c != null)
                pli.totalValueString = CurrencyFormatter.formatDouble(ql.Ceiling_Total_Sales_Price__c / ql.Quantity__c ,ObjQuote.CurrencyIsoCode);
            }
            pli.Quantity = Integer.valueOf(ql.Quantity__c);
            pli.UOM =  ql.UOM__c;
            
            pli.childProd = new List<childProductWrapper>();
            // keep the source Quote Line Item Id for reference
            pli.QuoteLineId = ql.Id;
            for(Quote_Line_Options__c qpl : ql.Quote_Line_Options__r){
                if (qpl.Pdf_Checked__c) {
                    getWithoutTaxGrandValue += qpl.Sales_Price__c;
                } 
                if(qpl.Manual_Product_Name__c != null){
                    if(!qpl.Manual_Product_Name__c.startsWith('.')){
                        childProductWrapper chl = new childProductWrapper();
                        chl.Manual_Product_Name = qpl.Manual_Product_Name__c;
                        chl.isstartWith_a = false;
                        chl.isstartWith_Hash = false;
                        // option metadata
                        chl.OptionId = qpl.Id;
                        chl.Pdf_Checked = (qpl.Pdf_Checked__c == true);
                        chl.Quantity = (qpl.Quantity__c == null) ? null : Integer.valueOf(qpl.Quantity__c);
                        chl.Sales_Price = CurrencyFormatter.formatDouble(qpl.Sales_Price__c, ObjQuote.CurrencyIsoCode);
                        // map manual/base price if present
                        chl.Manual_Option_List_Price = CurrencyFormatter.formatDouble(qpl.Manual_Option_Base_Price__c, ObjQuote.CurrencyIsoCode);

                        if(string.isNotBlank(qpl.Description__c)){
                            if(qpl.Description__c.contains('<p>') || qpl.Description__c.contains('</p>')){
                                qpl.Description__c = qpl.Description__c.replace('<p>','<span>');
                                qpl.Description__c = qpl.Description__c.replace('</p>','</span>');
                            }
                            if(qpl.Description__c.contains('>@') || qpl.Description__c.startsWith('@')){
                                chl.isstartWith_a = true;
                                chl.isstartWith_Hash = false;
                                chl.Description = qpl.Description__c;
                                pli.isstartWith_a = true;
                            } else if(string.isNotBlank(qpl.Description__c) && (qpl.Description__c.contains('>#') || qpl.Description__c.startsWith('#'))){
                                chl.isstartWith_Hash = true;
                                chl.isstartWith_a = false;
                                chl.Description = qpl.Description__c;
                            } else{
                                chl.Description = qpl.Description__c;
                            }
                        }
                        pli.childProd.add(chl);
                    }
                }
            }
            prodLineList.add(pli);
            
        }
        
        getWithoutTaxGrandValuestring =CurrencyFormatter.formatDouble(getWithoutTaxGrandValue ,ObjQuote.CurrencyIsoCode);
        
        system.debug('grand value-->'+getWithoutTaxGrandValuestring);
        system.debug('prodLineList'+prodLineList);
        
        
        //CurrencyToWords w1 = new CurrencyToWords();
        //NumberTOWordConvertion  w1 = new NumberTOWordConvertion();
        ConvertCurrencyToWords w1 = new ConvertCurrencyToWords();
        //no2words=ConvertCurrencyToWords.english_number(ObjQuote.Quote_Total_Summary_of_Sales_Price__c);// getNumberTOWordConvertion(ObjQuote.Total_Price_Ceiling__c);
        
        
        Grand_Total_c_string = CurrencyFormatter.formatDouble(ObjQuote.Grand_Total__c, ObjQuote.CurrencyIsoCode);   
        Long longTotalAmount = (Long) ObjQuote.Grand_Total__c;
        if(ObjQuote.Price_in_Word_Required__c == true){
            if(ObjQuote.CurrencyIsoCode == 'INR'){
                no2words=(ConvertCurrencyToWords.convert(longTotalAmount)) + ' Rupees Only.';
            }else{
                no2words=numToWords.convert(Integer.valueOf(longTotalAmount),(ObjQuote.CurrencyIsoCode).toUpperCase());
            }
             
        }else{
            no2words='';
        }
        
        quoteTemplate = [SELECT id,Show_Ex_Works__c,Active__c, CurrencyIsoCode, Introduction__c, Label__c, Label_For_Colum_1__c, Label_For_Colum_2__c, Label_For_Colum_3__c, 
                         Label_For_Colum_4__c, Label_For_Colum_5__c, Label_for_Date__c, Label_for_Draft_Quote__c, Label_for_General_Provision__c,
                         Label_for_General_Remarks__c, Label_for_Page_No__c, Label_for_Page_No_2__c, Label_for_Price_in_Word__c, Label_for_Product_table__c,
                         Label_For_Ref_No__c, Label_For_TO__c, Language__c, Logo__c, OwnerId, Name, Salutation__c, Subsidiary__c,
                         Subsidiary__r.Factory_Location__c, Subsidiary__r.Name__c, ISO_Code_Label__c, ISO_Code_Text__c,
                         Company_Name_Label__c, Sales_Engineer_Label__c, Quotation_No_Label__c, Quotation_Date_Label__c, Cover_Page__c,
                         ASB_Sign_Section2__c, ASB_Sign_Section3__c, ASB_Sign_Section4__c, ASB_Sign_Section5__c, Cover_Page_Required__c,
                         Customer_Sign_Section2__c, Customer_Sign_Section3__c, Customer_Sign_Section4__c, Customer_Sign_Section5__c, Footer_Image__c,
                         Header_Image__c, Section_2_Required__c, Section_4_Required__c, Section_5_Required__c, Footer_Image_Required__c, Footer_Text__c, Footer_Text_Required__c,
                         S2_Introduction__c,S2_Title__c,S3_title__c,S4_Title__c,S5_Title__c, Draft_Image__c, Label_For_Quotation_No__c,Manufacture_Place__c	
                         FROM Quote_Template__c WHERE ID =:ObjQuote.Quote_Template__c and Active__c=true];
        
        system.debug('ObjQuote.Quote_Template__'+ObjQuote.Quote_Template__c);
        system.debug('quoteTemplate.id'+quoteTemplate.id);
        terms = [SELECT id, Active__c, Content__c,Content_2__c, Is_Terms_Condition__c, Label__c, Name, Quote_Template__c, Sr_No__c,(select id,name,Dynamic_Field__c,Field_To_Replace__c from Quote_Dynamic_Text__r where Active__c=true)
                 FROM Quote_Template_Line__c WHERE Quote_Template__c =:quoteTemplate.id and Active__c=true and Is_Terms_Condition__c=true order By Sr_No__c];
        gRemark = [SELECT id, Active__c, Content__c,Content_2__c, Is_General_Remarks__c, Label__c, Name, Quote_Template__c, Sr_No__c,(select id,name,Dynamic_Field__c,Field_To_Replace__c from Quote_Dynamic_Text__r where Active__c=true)
                   FROM Quote_Template_Line__c WHERE Quote_Template__c =:quoteTemplate.id and Active__c=true and Is_General_Remarks__c=true order By Sr_No__c];
        gProvision = [SELECT id, Active__c, Content__c, Content_2__c,Is_General_Provision__c, Label__c, Name, Quote_Template__c, Sr_No__c,(select id,name,Dynamic_Field__c,Field_To_Replace__c from Quote_Dynamic_Text__r where Active__c=true)
                      FROM Quote_Template_Line__c WHERE Quote_Template__c =:quoteTemplate.id and Active__c=true and Is_General_Provision__c=true order By Sr_No__c];
        
        map<String,Object> amap=(Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ObjQuote));
        if(terms.size() > 0){
            terms=getDynamicValue(terms,amap);
        }
        
        
        for(Quote_Template_Line__c qtp  : gRemark){
            if(qtp.Label__c == 'SCOPE OF SUPPLY'){
                system.debug('inside label'+qtp.Label__c);
                qtp.Label__c = '<b>'+qtp.Label__c+'</b>';
                system.debug('inside label'+qtp.Label__c);
            }
        } 
        
        gRemark=getDynamicValue(gRemark,amap);
        gProvision=getDynamicValue(gProvision,amap); 
    }
    
    public List<Quote_Template_Line__c> getDynamicValue(List<Quote_Template_Line__c> tList, map<String,Object> amap)
    {
        try{
            for(Quote_Template_Line__c t:tList)
            {
                
                for(Quote_Dynamic_Text__c Qd:t.Quote_Dynamic_Text__r)
                {
                    
                    if(amap.get(qd.Field_To_Replace__c) instanceof Integer)
                        t.Content_2__c=(t.Content_2__c).replace(qd.Dynamic_Field__c,String.valueOf(amap.get(qd.Field_To_Replace__c)));
                    else                                     
                    {
                        if(amap.get(qd.Field_To_Replace__c)!=null)
                            t.Content_2__c=(t.Content_2__c).replace(qd.Dynamic_Field__c,(String)amap.get(qd.Field_To_Replace__c));
                        else
                            t.Content_2__c=(t.Content_2__c).replace(qd.Dynamic_Field__c,'');   
                    }
                }
                
            } 
            return tList; 
        }catch(exception e){
            System.debug(e.getMessage());
            return null;
        }
        
    }
    
    public PageReference SaveToQuote() {
        
        attachQuote();                // Method call to attach pdf to Quote
        PageReference pageWhereWeWantToGo =new PageReference('/'+recordID);
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo; //send the User on their way
    }
    
    public void attachQuote(){
        //generate and attach the PDF document
        PageReference pdfPage = Page.pdfPreview; //create a page reference to our pdfPreview Visualforce page
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
            AttachmentName = ObjQuote.Name+'_V1';  
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
            AttachmentName = ObjQuote.Name+'_V'+Increment;
        }
        Attachment attach = new Attachment(parentId = recordID, Name = AttachmentName+'.pdf', body = pdfBlob); //create the attachment object
        insert attach; //insert the attachment    
    }
    
    public PageReference SaveAndEmailQuote(){
        attachQuote();                    // Method call to attach pdf to Quote
        PageReference pageWhereWeWantToGo =new PageReference('/apex/EmailQuote?id='+recordID);
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo; //send the User on their way
    }
    
    public PageReference Cancel(){
        PageReference pf = new PageReference('/'+recordID);
        return pf;
    }
    
    public void showModal() {
        User_Setup__c u=[select id,name,Subsidiari__c, Signature_Image__c from User_Setup__c where User__c=:userinfo.getUserId() limit 1];
        //imageSignature = u.Signature_Image__c;
        isModalOpen = true;
        addDocs = new List<AdditionalDocWrapper>();
        system.debug('qobj.OwnerId'+qobj.OwnerId);
        system.debug('qobj.OwnerId'+u.Subsidiari__c);
        for(Additional_Document__c addDoc : [SELECT Id, Name FROM Additional_Document__c where Active__c = true
                                             and ((OwnerId =: qobj.OwnerId and Is_User_Specific__c=true) or (Subsidiary__c=:u.Subsidiari__c))and Type__c = 'Quote']) {
                                                 addDocs.add(new AdditionalDocWrapper(addDoc));
                                             }
        system.debug('addDocs'+addDocs.size());
        
        List<ContentDocumentLink> contentDoc= [SELECT Id, ContentDocument.Title from ContentDocumentLink where LinkedEntityId = :recordID];
        if(contentDoc.size() > 0){
            for(ContentDocumentLink cli : contentDoc){
                NotesAndAttcahmentDocWrapper note = new NotesAndAttcahmentDocWrapper();
                note.isSelected = false;
                note.Id = cli.Id;
                note.Name =  cli.ContentDocument.Title;
                noteslist.add(note);
            }
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
    
    class AdditionalDocWrapper {
        public Boolean isSelected {get; set;}
        public Additional_Document__c addDoc {get; set;}
        
        public AdditionalDocWrapper(Additional_Document__c p1) {
            isSelected = false;
            addDoc = p1;
        }
    }
    
    class NotesAndAttcahmentDocWrapper {
        public Boolean isSelected {get; set;}
        public Id Id {get; set;}
        public string Name{get; set;}
    }
    
    
    class parentProductWrapper{
        public Boolean isSelected {get; set;}
        public Boolean isstartWith_Hash {get; set;}
        public Boolean isstartWith_a {get; set;}
        public string Name {get;set;}
        public string Line_Item_Id {get;set;}
        public Id QuoteLineId {get; set;} // Id of the Quote Line Item
        public string UOM {get;set;}
        public string Product_Name {get;set;}
        public string Product_Description {get;set;}
        public decimal Ceiling_Total_Sales_Price {get;set;}
        public string Ceiling_Total_Sales_Pricestring {get;set;}
        public Integer Quantity {get;set;}
        public boolean Is_Tax{get;set;}
        public decimal totalValue {get;set;}
        public string totalValueString {get;set;}
        public  List<childProductWrapper> childProd {get;set;}
    }
    
    class childProductWrapper{
        public string Description {get;set;}
        public Boolean isstartWith_Hash {get; set;}
        public Boolean isstartWith_a {get; set;}
        public string Manual_Product_Name {get;set;}
        public Id OptionId {get; set;}
        public Boolean Pdf_Checked {get; set;}
        public Integer Quantity {get; set;}
        public String Manual_Option_List_Price {get; set;}
        public String Sales_Price {get; set;}
        
    }

    // open the options modal from SaveQuoteAsPdf page
    public void openOptionsModal(){
        showOptionsModal = true;
    }

    // Save selected options and set Pdf_Checked__c = true for selected options
    public PageReference saveOptions(){
        List<Quote_Line_Options__c> optsToUpdate = new List<Quote_Line_Options__c>();
        for(parentProductWrapper p : prodLineList){
            if(p.childProd != null){
                for(childProductWrapper c : p.childProd){
                    if(c.Pdf_Checked && c.OptionId != null){
                        Quote_Line_Options__c qlo = new Quote_Line_Options__c(Id = c.OptionId);
                        qlo.Pdf_Checked__c = true;
                        optsToUpdate.add(qlo);
                    }
                }
            }
        }
        if(!optsToUpdate.isEmpty()){
            try{
                update optsToUpdate;
                // Datetime runTime = Datetime.now().addMinutes(1); // Schedule to run after 1 minute
                // String jobName = 'UpdateQuoteOptionJob_' + recordId + '_' + System.currentTimeMillis();
                
                // System.schedule(jobName, getCronForTime(runTime), new UpdateQuoteOptionJob(recordId));
                // System.debug('Scheduled UpdateQuoteOptionJob to run at: ' + runTime);
            }catch(Exception e){
                System.debug('Error updating Pdf_Checked__c on options: '+e.getMessage());
            }
        }
        showOptionsModal = false;
        return null;
    }

    private static String getCronForTime(Datetime dt) {
        return String.format('{0} {1} {2} {3} {4} ? {5}',
            new List<Object>{dt.second(), dt.minute(), dt.hour(), dt.day(), dt.month(), dt.year()});
    }

    public void closeOptions(){
        showOptionsModal = false;
    }

    public void updateOptions() {
        List<Quote_Line_Options__c> quoteLineOptions = [
            SELECT Id, Pdf_Checked__c 
            FROM Quote_Line_Options__c 
            WHERE Quote__c = :this.recordID
        ];
        System.debug('Fetched Quote_Line_Options__c records: ' + quoteLineOptions);
        System.debug('Total records fetched: ' + quoteLineOptions.size());

        if (!quoteLineOptions.isEmpty()) {
            System.debug('Records found. Updating Pdf_Checked__c to false...');
            for (Quote_Line_Options__c qlo : quoteLineOptions) {
                System.debug('Before update -> Id: ' + qlo.Id + ', Pdf_Checked__c: ' + qlo.Pdf_Checked__c);
                qlo.Pdf_Checked__c = false;
                System.debug('After update -> Id: ' + qlo.Id + ', Pdf_Checked__c: ' + qlo.Pdf_Checked__c);
            }
        } else {
            System.debug('No Quote_Line_Options__c records found for Id: ' + recordID);
        }

        update quoteLineOptions;
        System.debug('Update completed for records: ' + quoteLineOptions);
    }
    
    
    
    
    
}