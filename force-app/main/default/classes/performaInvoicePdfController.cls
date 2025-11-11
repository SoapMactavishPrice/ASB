public class performaInvoicePdfController {
    
    public String InvoiceId{get;set;}
    public Performa_Invoice__c ObjInvoice{get;set;}
    public Bank_Detail__c bankDetails{get;set;}
    public Contract ObjContract{get;set;}
    public String Check{get;set;}
    public String Check2{get;set;}
    public String Check3{get;set;}
    public boolean displayPopup {get;set;}
    public decimal gtPay {get; set;}
    public decimal igst {get; set;}
    public decimal tcsAmt {get; set;}
    public decimal cgst {get; set;}
    public decimal sgst {get; set;}
    public decimal grandTotal {get; set;}
    public decimal subTotal_3 {get; set;}
    public decimal subTotal_1 {get; set;}
    public decimal shipCharges {get; set;}
    public decimal packingCharges {get; set;}
    public decimal insuranceCharges {get; set;}
    public decimal subTotal_2 {get; set;}
    public  List<Attachment> allAttachmentParentContains{ get; set; }
    public String AttachmentName{get;set;}
    public integer Increment{get;set;}
    public String no2words {get;set;}
    Public List<Contract_Line_Option__c> ObjCLO{get;set;}
    Public List<Performa_Invoice_Line_Item__c> lstINVLI{get;set;}
    Public String OptionName{get;set;}
    Public  Decimal ValIgstTax {get;set;}
    Public  Decimal ValCgstTax {get;set;}
    Public  Decimal ValSgstTax {get;set;}
    Public  Decimal TotalValue {get;set;}
    Public  Decimal Balance {get;set;}
    Public user Objuser{get;set;}
    Public  String Invoicename {get;set;}
    public Decimal FreightCost{get;set;}
    public Boolean ShowFreight{get;set;}
    public Boolean DontShowFreight{get;set;}
    public String emailId {get; set;}
    public String subject {get; set;}
    public String body {get; set;}
    public string CC_Addresses{get; set;}
    public String accountName;
    public Decimal ProgCount {get; set;}
    public Performa_Invoice_Template__c invoiceTemplate{get; set;}
    public List<Performa_Invoice_Template_Line__c> terms{get; set;}
    public List<Performa_Invoice_Template_Line__c> gProvision{get; set;}
    
    
    public performaInvoicePdfController(ApexPages.StandardController controller){
        ShowFreight = false;
        DontShowFreight = false;
        InvoiceId =  ApexPages.CurrentPage().getparameters().get('id');
        System.debug('InvoiceId'+InvoiceId);
        
        
        allAttachmentParentContains=[select id,Name,Body,BodyLength,parentId,contentType
                                     from attachment where parentId=:InvoiceId order by CreatedDate DESC limit 1];       
        system.debug('My Fetched Attachment'+allAttachmentParentContains);
        // Performa_Invoice__c ObjInvoice = new Performa_Invoice__c();
        Map<String, Schema.SObjectField> fieldMap = Performa_Invoice__c.sObjectType.getDescribe().fields.getMap();
        list<String> lstFieldNames = new List<String>(fieldMap.keySet());
        ObjInvoice=Database.query('SELECT ' + String.join(lstFieldNames, ',') + ',Contact__r.Name,Ship_To_Party__r.Name,Product__r.Model__c,Product__r.Description,Contract__r.ContractNumber,Subsidiary__r.GST_Number__c,Account__r.name,Account__r.Legal_Name__c,CreatedBy.Name, Contact__r.Owner.Email,CreatedBy.title from Performa_Invoice__c Where id =:InvoiceId limit 1');
       /* ObjInvoice = [Select Advance_Recieved__c,Balance_Remaining__c,Base_Price__c,Base_price_Formulae__c,Contract__c,Customer_GST_No__c,Name,Transaction_Date__c,Account__r.name,Ship_To_Party_GST_No__c,
                      Product__c,Sub_Total__c,Tax_Value__c,Total__c,Transient_Insurance_Charge__c,Type_Of_Tax__c,Value_of_Tax__c,Is_IGST__c,IGST_Tax_Value__c,Account__c,Ship_To_Party__c,Contact__c,Contact__r.Name,
                      Is_CGST__c,CGST_tax_value__c,Is_SGST__c,SGST_Tax_Value__c,createdBY.name,CreatedDate,ADDRESS_LINE_1__c,ADDRESS_LINE_2__c,ADDRESS_LINE_3__c,City__c,Ship_To_Party__r.Name,
                      Ship_to_City__c,Ship_to_address_line_1__c,Ship_to_address_line_2__c,Ship_to_address_line_3__c,Ship_to_State__c,State__c,Country__c,Ship_to_country__c,Salutations__c,
                      Product__r.Model__c,Product__r.Description,Contract__r.ContractNumber,Contract_Creation_Date__c,Contract_Revision_No__c,Total_Payment_Received__c,Freight_Amount__c,
                      Contact__r.Owner.Email, CurrencyIsoCode, Performa_Invoice_Template__c, Subsidiary__c, Subsidiary__r.GST_Number__c
                      from Performa_Invoice__c where id =:InvoiceId];*/
        System.debug('ObjInvoice ===>>>> '+ObjInvoice);
        bankDetails =[SELECT Active__c, Bank_A_C_No__c, Name, Bank_Name__c, Beneficiary__c, IFSC_CODE__c, Location__c, Pincode__c, 
                     Subsidiary_Master__c FROM Bank_Detail__c WHERE Subsidiary_Master__c =: ObjInvoice.Subsidiary__c AND Active__c=true ];
        emailId = ObjInvoice.Contact__r.Owner.Email;
        if(objinvoice.Freight_Amount__c != null && objinvoice.Freight_Amount__c >0){
            ShowFreight = true;
            shipCharges = objinvoice.Freight_Amount__c;
        }else{
            DontShowFreight = true;
            shipCharges = 0;
        }
        Invoicename = ObjInvoice.name;
        subTotal_1 = 0;
        //shipCharges = 0;
        insuranceCharges = 0;
        packingCharges = 0;
        subTotal_2 = 0;
        subTotal_3 = 0;
        tcsAmt = 0;
        sgst = 0;
        cgst = 0;
        igst = 0;
        gtPay = 0;
        grandTotal = 0;
        lstINVLI = [Select id,Invoice_Amount__c,Performa_Invoice__c,Product_Description__c,Quantity__c,UOM__c, Ceiling_Total_Sales_Price__c,Shipping_charges__c,Insurance_Charges__c,Packing_Charges__c,
                    IGST_Amount__c,CGST_Amount__c,SGST_Amount__c, TCS_Amount__c,IGST__c, CGST__c, SGST__c, TCS__c from Performa_Invoice_Line_Item__c where Performa_Invoice__c =: InvoiceId];
        system.debug('lstINVLI ===>>> ' + lstINVLI);
        
        ProgCount=lstINVLI.size();
        if(ProgCount == 0){
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please add items in the Performa Invoice Line Items');
        ApexPages.addMessage(msg);
    }
        
        for(Performa_Invoice_Line_Item__c invLI : lstINVLI){
            packingCharges = packingCharges + invLI.Packing_Charges__c;
            insuranceCharges = insuranceCharges + invLI.Insurance_Charges__c;
            shipCharges = shipCharges + invLI.Shipping_charges__c;
            subTotal_1 = subTotal_1 + invLI.Invoice_Amount__c;
            sgst = sgst + invLI.SGST_Amount__c;
            cgst = cgst + invLI.CGST_Amount__c;
            igst = igst + invLI.IGST_Amount__c;
            tcsAmt = tcsAmt + invLI.TCS_Amount__c;
        }
        subTotal_2 = packingCharges + insuranceCharges + shipCharges + subTotal_1;
        subTotal_3 = subTotal_2 + igst + cgst + sgst;
        grandTotal = subTotal_3 + tcsAmt;
        gtPay = grandTotal;//grandTotal - ObjInvoice.Total_Payment_Received__c;
        NumberTOWordConvertion  w1 = new NumberTOWordConvertion();
        no2words=w1.getNumberTOWordConvertion(gtPay);
        System.debug('Invoicename  ==>>>  '+Invoicename);
        Check = 'none';
        Check2 = 'none';
        Check3 = 'none';
        
        
        if(ObjInvoice.Is_IGST__c == true){
            Check = 'visible';
        }
        
        if(ObjInvoice.Is_CGST__c == true){
            Check2 = 'visible';
        }
        if(ObjInvoice.Is_SGST__c == true){
            Check3 = 'visible';
        }
        
        system.debug('in check');
        
        
        String userId = UserInfo.getUserId();
        // user Objuser = new User();
        objuser = [Select id,name,Signature_Image__c,Title from user where id = : userId];
        
        invoiceTemplate = [SELECT id, Active__c, Label__c, Label_For_Bank_A_C_No__c, Label_For_Bank_Name__c, Label_For_Beneficiary__c,
                           Label_For_Column_1__c, Label_For_Column_2__c, Label_For_Column_3__c, Label_For_Column_4__c, Label_For_Column_5__c,Label_For_Column_6__c,
                           Label_For_Contact_Name__c, Label_For_Contract__c, Label_For_Contract_Creation_Date__c, Label_For_Contract_Revision__c,
                           Label_For_GST_No__c, Label_For_IFSC_Code__c, Label_For_Proforma_Invoice_No__c, Label_for_Transaction_Date__c	,
                           Logo__c, Name, Salutation__c, Subsidiary__c,Label_For_General_Conditions__c, Label_For_General_Provisions__c,
                           Label_For_Consignee__c, Subsidiary__r.Factory_Location__c, Subsidiary__r.Name__c
                           FROM Performa_Invoice_Template__c WHERE ID =:ObjInvoice.Performa_Invoice_Template__c and Active__c=true];
        					
        terms = [SELECT id, Active__c, Content__c, Label__c, Sr_No__c, Is_Terms_Condition__c
                 FROM Performa_Invoice_Template_Line__c 
                 WHERE Performa_Invoice_Template__c =:invoiceTemplate.id 
                 AND Active__c=true AND Is_Terms_Condition__c=true order By Sr_No__c];
        
        gProvision = [SELECT id, Active__c, Content__c, Label__c, Sr_No__c, Is_General_Provision__c
                      FROM Performa_Invoice_Template_Line__c 
                      WHERE Performa_Invoice_Template__c =:invoiceTemplate.id 
                      AND Active__c=true AND Is_General_Provision__c=true order By Sr_No__c];
    }
    
    public void showPopup() {
        displayPopup = true;
    }
    
    public PageReference SaveToQuote() {
        
        attachQuote();                // Method call to attach pdf to Quote
        PageReference pageWhereWeWantToGo =new PageReference('/'+InvoiceId);
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo; //send the User on their way
    }
    
        public PageReference SaveAndEmailQuote(){
        attachQuote();                    // Method call to attach pdf to Quote
        PageReference pageWhereWeWantToGo =new PageReference('/apex/EmailInvoice?id='+InvoiceId);
        pageWhereWeWantToGo.setRedirect(true);
        return pageWhereWeWantToGo; //send the User on their way
    }
    
    public void attachQuote(){
        //generate and attach the PDF document
        PageReference pdfPage = Page.PerformaInvoicePdf; //create a page reference to our pdfPreview Visualforce page
        System.debug('Reach');
        pdfPage.getParameters().put('id',InvoiceId);
        System.debug('Reach');
        Blob pdfBlob; //create a blob for the PDF content
        System.debug('Reach'+pdfPage);
        if (!Test.isRunningTest()) 
        {  //if we are not in testing context
            System.debug('Reach');
            pdfBlob = pdfPage.getContent(); //generate the pdf blob
            System.debug('Reachin 1');
        }
        else { //otherwise, we are in testing context and getContent() gets funky so create the blob manually
            pdfBlob = Blob.valueOf('Some Text for a boring PDF file...');
            System.debug('Reachin ');
        }
        if(allAttachmentParentContains.size()==0)
        {
            AttachmentName = ObjInvoice.Name+'_V1';  
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
            AttachmentName = ObjInvoice.Name+'_V'+Increment;
        }
        Attachment attach = new Attachment(parentId = InvoiceId, Name = AttachmentName+'.pdf', body = pdfBlob); //create the attachment object
        insert attach; //insert the attachment    
    }
    

    
        public PageReference save() {
        Performa_Invoice__c ObjInvoice = [SELECT Id, Name From Performa_Invoice__c Where id=: InvoiceId];
        accountName = ObjInvoice.Name;
        try{
            Attachment a;
            PageReference pdf;
            pdf = Page.PerformaInvoicePdf;
            pdf.getParameters().put('id',InvoiceId);
            Blob pdfBody;
            if(!test.isRunningTest()){
                pdfBody = pdf.getContentAsPDF();
            }
            else
            {
                pdfBody = blob.valueof('TEST');
            }
            list<Attachment> at=[select id,name,body from Attachment where ParentId=:InvoiceId];
            system.debug('atttt'+at);
            String name;
            if(at.size()!=0)
                name=accountName +'_V'+at.size()+'.pdf';
            else
            {
                name=accountName +'_V'+'.pdf';
            }
            Attachment attach = new Attachment();
            attach.ParentId =InvoiceId;
            attach.name = name;
            attach.body = pdfBody ;
            System.debug('tId '+InvoiceId);
            INSERT attach;
            system.debug('attach'+attach);
        }
        catch(exception e){
            system.debug('SavePerformaInvoicePdf'+e);
        }
        
        PageReference pageRef = new PageReference('/'+InvoiceId);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    public PageReference saveAndSend() {
        Performa_Invoice__c ObjInvoice = [SELECT Id, Name From Performa_Invoice__c Where id=: InvoiceId];
        
        accountName=ObjInvoice.Name;
        
        Attachment a;
                
        PageReference pdf;
        pdf = Page.PerformaInvoicePdf;
        pdf.getParameters().put('id',InvoiceId);
        Blob pdfBody;
        if(!test.isRunningTest()){
            pdfBody = pdf.getContentAsPDF();
        }
        else
        {
            pdfBody = blob.valueof('TEST');
        }
        list<Attachment> at=[select id,name,body from Attachment where ParentId=:InvoiceId];
        String name;
        if(at.size()!=0)
            name=accountName +'_V'+at.size()+'.pdf';
        else
        {
            name=accountName +'_V'+'.pdf';
        }
        
        Attachment attach = new Attachment();
        attach.ParentId =InvoiceId;
        attach.name = name;
        attach.body = pdfBody ;
        System.debug('tId '+InvoiceId);
        INSERT attach;
        
        System.debug('tId '+attach.body);
        
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
        system.debug('email'+email);
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }); 
        
        PageReference pageRef = new PageReference('/'+InvoiceId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference Cancel(){
        PageReference pf = new PageReference('/'+InvoiceId);
        return pf;
    }
    
}