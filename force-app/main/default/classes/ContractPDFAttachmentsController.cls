public class ContractPDFAttachmentsController {
    
    Contract ObjContract = new Contract();
    public List<Attachment> lstAttachment {get;set;}
    
    public ContractPDFAttachmentsController(ApexPages.StandardController stdController)
    {
        ObjContract = (Contract)stdController.getRecord();
        List<Attachment> lstAtt = new List<Attachment>();
        List<Attachment> lstAttFinal = new List<Attachment>();
        
        Contract objQ = [select id, ContractNumber from Contract where id=:ObjContract.id];
        System.debug('objQ vishesh -->>>'+objQ);
        lstAtt = [select id, name, body, LastModifiedDate, Createddate , createdby.name,ParentId from Attachment where ParentId=:ObjContract.id ];
        System.debug('lstAtt'+lstAtt);
        if (lstAtt.size()>0 && lstAtt != null)
        {
            System.debug('lstAtt'+lstAtt);
            for (Attachment objAt : lstAtt)
                
            {
                System.debug('lstAtt'+lstAtt);
                if (objAt.name.contains(objQ.ContractNumber))
                {
                    
                    lstAttFinal.add(objAt);
                }
            }
        }
        System.debug('lstAtt'+lstAttFinal.size());
        if (lstAttFinal.Size()>0 && lstAttFinal !=null)
        {
            lstAttachment = lstAttFinal;
            System.debug('lstAttachment'+lstAttachment);
        }
    }
    
    
}