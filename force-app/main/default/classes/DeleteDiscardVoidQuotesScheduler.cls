public class DeleteDiscardVoidQuotesScheduler implements Schedulable {
    
    private static final String[] NOTIFY_TO = Label.Quote_Deletion_Email_Recipients.replace(' ', '').split(','); //To trim the spaces
    
    public void execute(SchedulableContext sc) {
        
        List<Quote> quotesToDelete = new List<Quote>();
        
        
        String soql = 
            'SELECT Id, Name, Status, CreatedDate, Owner.Name, PREPARED_BY__r.Name, Subsidiary__r.Name ' +
            'FROM Quote ' +
            'WHERE Status = \'DISCARD/VOID\' ';
        
        if (!Test.isRunningTest()) {
            soql += 'AND CreatedDate < LAST_N_DAYS:45 ';
        }
        
        soql += 'ORDER BY CreatedDate ASC';
        
        quotesToDelete = Database.query(soql);
        
        
        
        if (quotesToDelete.isEmpty()) return;
        
        String csv = 'Name,Id,CreatedDate,Status,Owner,Prepared By,Subsidiary\n';
        for (Quote q : quotesToDelete) {
            csv += '"' + q.Name.replace('"','""')                            + '",' +
                '"' + q.Id                                               + '",' +
                '"' + q.CreatedDate.format()                             + '",' +
                '"' + q.Status                                           + '",' +
                '"' + q.Owner.Name                                       + '",' +
                '"' + (q.PREPARED_BY__r != null ? q.PREPARED_BY__r.Name : '') + '",' +
                '"' + (q.Subsidiary__r  != null ? q.Subsidiary__r.Name  : '') + '"\n';
        }
        
        Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
        att.setFileName('QuotesDeleted.csv');
        att.setBody(Blob.valueOf(csv));
        att.setContentType('text/csv');
        
        Integer total = quotesToDelete.size();
        String monthStr = DateTime.now().format('MMMM yyyy'); // e.g., "July 2025"
        String deletionDate = Date.today().format();          // e.g., "2025-07-14"
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(NOTIFY_TO);
        mail.setSubject('⚠️ Scheduled Quote Deletion – ' + DateTime.now().format('yyyy-MM-dd HH:mm'));
        mail.setHtmlBody(
            'Dear Team,<br><br>' +
            'Please find below the summary of Quotes deleted as part of the scheduled automation:<br><br>' +
            '<b>Total Number of Quotes Deleted:</b> ' + total + '<br>' +
            '<b>Month of Deletion:</b> ' + monthStr + '<br>' +
            '<b>Date of Deletion:</b> ' + deletionDate + '<br><br>' +
            'All details of the deleted Quotes are included in the attached file.<br><br>' +
            '<b>Note:</b> This automated job is scheduled to run every <b>30 days</b>. It deletes Quotes that are older than <b>45 days</b> (based on Created Date) and have the status <b>Discard/Void</b>.<br><br>' +
            'Best regards,<br>' +
            'ASB - Salesforce Automation'
        );
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { att });
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        Database.delete(quotesToDelete, false); // partial success allowed
    }
}