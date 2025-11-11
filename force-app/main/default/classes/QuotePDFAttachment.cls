public class QuotePDFAttachment {
    
    Quote objQuote = new Quote();
    public List<Attachment> lstAttachment {get;set;}
    
    public QuotePDFAttachment(ApexPages.StandardController stdController)
    {
        objQuote = (Quote)stdController.getRecord();
        List<Attachment> lstAtt = new List<Attachment>();
        List<Attachment> lstAttFinal = new List<Attachment>();
        
        Quote objQ = [select id, name from Quote where id=:objQuote.id];
        lstAtt = [select id, name, body, LastModifiedDate, Createddate , createdby.name,ParentId from Attachment where ParentId=:objQuote.id ];
        if (lstAtt.size()>0 && lstAtt != null)
        {
            for (Attachment objAt : lstAtt)
            {
                if (objAt.Name.contains(objQ.name))
                {
                    lstAttFinal.add(objAt);
                }
            }
        }
        if (lstAttFinal.Size()>0 && lstAttFinal !=null)
        {
            lstAttachment = lstAttFinal;
        }
    }
	
}