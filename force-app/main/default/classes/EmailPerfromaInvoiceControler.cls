public class EmailPerfromaInvoiceControler {
    public String Subject{set;get;}
    public string Body{get;set;}
    public string CC{get;set;}
    public boolean check1{get;set;}
    public boolean check2{get;set;}
    public boolean checkABM{get;set;}
    public boolean checkTech{get;set;}
    public boolean rendABM{get;set;}
    public boolean rendTech{get;set;}
    public string ABMName{get;set;}
    public string TechnicalName{get;set;}
    Public Performa_Invoice__c Invoicerecord{get;set;}
    Public Id InvoiceId{get;set;} 
    public  List<Attachment> allAttachmentParentContains{ get; set; }
    public contact con{get;set;}
    Public List<User> user{get;set;}
    public List <wrapper>lstOfAttachment{get;set;}
    User us1;
    User us2;
    //======================Constructor===================================
    public EmailPerfromaInvoiceControler(ApexPages.StandardController standardPageController)
    { 
        user = new List<User>();
        lstOfAttachment= new List <wrapper>();
        this.Invoicerecord = (Performa_Invoice__c)standardPageController.getRecord(); //instantiate the sales_Quote__c object for the current record
        InvoiceId=Invoicerecord.Id;
        System.debug('InvoiceId====== vishesh'+InvoiceId);
        
        allAttachmentParentContains=[select id,Name,Body,BodyLength,parentId,contentType,CreatedDate from attachment where parentId=:InvoiceId];       
        
        if(allAttachmentParentContains.size()>0 && allAttachmentParentContains!=null)
        {
            for(Attachment attach:allAttachmentParentContains)
            {
                lstOfAttachment.add(new wrapper(attach));   
            }
        }
        system.debug(lstOfAttachment);
    }
    //==================================Constructor End=============================================  
    public PageReference cancel()
    {
        PageReference pf = new PageReference('/'+InvoiceId);
        return pf;  
    }
    
    //This Method is used to send Quote
    public PageReference sendQuote()
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.Emailfileattachment> lstEmailAttachment = new List<Messaging.Emailfileattachment>();
        if(Invoicerecord.Contact__c!=null)
        {
            con = [select Id,Email from Contact where Id=:Invoicerecord.Contact__c];
            if(con.Email!=null)
            {
                mail.setToAddresses(new string[] {con.Email});
            }
            else
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please Choose Contact which has valid email address'));
                return null;
            }
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please Choose any Contact'));
            return null;   
        }
        
        mail.setSubject(Subject);
        String[] CCadd ;
        if(CC != null && CC != '')
            CCadd = CC.split('\\,');
        // String[] CCadd = new String[];
        //  List<String>CCadd = new List<String>();
        
        if(CCadd!=null && CCadd.size()>0) {
            mail.setCcAddresses(CCadd); 
        }      
        
        System.debug('CCadd-'+CCadd);
        mail.setPlainTextBody(Body);
        //=======================================Attach pdf to email========================================================
        if(lstOfAttachment.size()>0 && lstOfAttachment!=null)
        {
            for(wrapper wrp : lstOfAttachment)
            {
                if(wrp.check==true)
                {
                    Messaging.Emailfileattachment attachmentToSend = new Messaging.Emailfileattachment();
                    attachmentToSend.setFileName(wrp.QuoteAttachment.Name);
                    attachmentToSend.setBody(wrp.QuoteAttachment.Body);
                    lstEmailAttachment.add(attachmentToSend);
                }
            }
        }
        if(lstEmailAttachment.size()>0 && lstEmailAttachment!=null)
        {
            system.debug('lstEmailAttachment:'+lstEmailAttachment);
            mail.setFileAttachments(lstEmailAttachment);
        }
        
        //==================================================================================================================
        
        if(lstEmailAttachment.size()>0 && lstEmailAttachment!=null)
        { system.debug('lstEmailAttachment'+lstEmailAttachment);
         try
         {
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }
         catch(Exception e)
         {
             system.debug('Exception in sending Performa_Invoice__c:'+e);   
         }
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please Select atleast One Attachment'));
        }
        PageReference pf = new PageReference('/'+InvoiceId);
        return pf;  
    }
    
    // wrapper class
    public class wrapper
    {
        public Boolean check{get;set;}
        public Attachment QuoteAttachment{get;set;}
        public wrapper(Attachment QuoteAttachment)
        {
            this.QuoteAttachment=QuoteAttachment;
            this.check=false;
        }
    }
    
}