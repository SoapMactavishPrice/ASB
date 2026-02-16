global class ContractExpirationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date targetDate = Date.today().addDays(3);
        
        List<Contract> contractsToProcess = [
            SELECT Id, OwnerId, Expiration_Date__c, Name, Contract_No_Rev_No_Fx__c, Account.Name
            FROM Contract 
            WHERE Status = 'Released' 
            AND Expiration_Date__c = :targetDate
            AND Expiration_Date__c != null
        ];
        
        List<Task> tasksToInsert = new List<Task>();
        for (Contract c : contractsToProcess) {
            Task t = new Task(
                WhatId = c.Id,
                OwnerId = c.OwnerId,
                Subject = 'Contract : "' + (c.Name != null ? c.Name : '') + '" is expired in 3 days',
                Priority = 'High',
                Status = 'Open',
                ActivityDate = c.Expiration_Date__c,
                Account_Name__c = c.Account.Name,
                Contract_Name__c = c.Name,
                Contract_Number__c = c.Contract_No_Rev_No_Fx__c
            );
            tasksToInsert.add(t);
        }
        
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}