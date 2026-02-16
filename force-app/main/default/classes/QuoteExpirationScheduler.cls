global class QuoteExpirationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date targetDate = Date.today().addDays(3);
        
        List<Quote> quotesToProcess = [
            SELECT Id, OwnerId, ExpirationDate, Name, Quote_No_Rev_No_Fx__c, Account.Name
            FROM Quote 
            WHERE Status = 'Released' 
            AND ExpirationDate = :targetDate
            AND ExpirationDate != null
        ];
        
        List<Task> tasksToInsert = new List<Task>();
        for (Quote q : quotesToProcess) {
            Task t = new Task(
                WhatId = q.Id,
                OwnerId = q.OwnerId,
                Subject = 'Quote : "' + (q.Name != null ? q.Name : '') + '" is expired in 3 days',
                Priority = 'High',
                Status = 'Open',
                ActivityDate = q.ExpirationDate,
                Account_Name__c = q.Account.Name,
                Quote_Name__c = q.Name,
                Quote_Number__c = q.Quote_No_Rev_No_Fx__c
                
            );
            tasksToInsert.add(t);
        }
        
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}