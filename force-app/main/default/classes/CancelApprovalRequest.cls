public with sharing class CancelApprovalRequest {

    private Contract contract;
    public String contractNumber { get; set; }
    public Boolean showPopup { get; set; }

    public CancelApprovalRequest(ApexPages.StandardController controller) {
        showPopup = true; 
        String currentId = ApexPages.currentPage().getParameters().get('id');
        system.debug('currentId'+currentId);
        contract = [SELECT Id, ContractNumber,Is_DTA_Contract__c,RecordTypeId, Status, Approver_User__c FROM Contract WHERE Id = :currentId]; 
        contractNumber = contract.ContractNumber;
    }
    public PageReference cancelreq() {
        contract.Status = 'Created';
        map<string,string> recMap = assignRecordTypecls.getRecordTypeList('Contract');
        if(!contract.Is_DTA_Contract__c){
            
            contract.RecordTypeId = recMap.get('Blank Contract');
        }else if(contract.Is_DTA_Contract__c){
            contract.RecordTypeId = recMap.get('Blank Contract(DTA)') ;
        }
        contract.Approval_Status__c = 'Cancelled';

        try {
            update contract;
            
            sendEmailToApprover(contract.Approver_User__c, contract.Id);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while cancelling approval: ' + e.getMessage()));
            return null;
        }
        
        showPopup = false;
        return new PageReference('/' + contract.Id);
    }

    public PageReference CloseModal() {
        showPopup = false;
        return new PageReference('/' + contract.Id);
    }

   /* private void sendEmailToApprover(Id approverId, Id recordId) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { approverId });
        mail.setSubject('Approval Request Cancelled');
        mail.setPlainTextBody('The approval request for Contract Number ' + contractNumber + ' has been cancelled by the user.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } */
    
    private void sendEmailToApprover(Id approverId, Id recordId) {
    Contract contractWithRevNo = [SELECT Id, Contract_No_Rev_No__c, ContractNumber FROM Contract WHERE Id = :recordId];
    String contractNumberWithRevNo = contractWithRevNo.Contract_No_Rev_No__c;
    String contractId = contractWithRevNo.Id;
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new String[] { approverId });
    mail.setSubject('Approval Request Cancelled');
    
    String contractLink = URL.getOrgDomainURL().toExternalForm() + '/lightning/r/Contract/' + contractId + '/view';
	String contractHyperlink = '<a href="' + contractLink + '">' + contractWithRevNo.ContractNumber + '</a>';

    System.debug('Contract Link: ' + contractLink);
    System.debug('contractHyperlink: ' + contractHyperlink);

    mail.setHtmlBody('The approval request for Contract No - Rev No ' + contractHyperlink + ' has been cancelled by the user.');
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}