public with sharing class QuoteRecallApprovalInvocable {

    public class Request {
        @InvocableVariable(required=true)
        public Id recordId;
    }

    @InvocableMethod(label='Recall Quote Approval')
    public static void recallQuoteApproval(List<Request> requests) {
        for (Request reqInput : requests) {
            List<ProcessInstanceWorkitem> workItems = [
                SELECT Id
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstance.TargetObjectId = :reqInput.recordId
                AND ProcessInstance.Status = 'Pending'
                LIMIT 1
            ];

            if (!workItems.isEmpty()) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItems[0].Id);
                req.setAction('Removed');
                Approval.process(req);
            }
        }
    }
}