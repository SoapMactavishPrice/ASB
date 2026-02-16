public class QuoteContractExpirationDateSetter {
    
    public static void handleBeforeUpdate(List<Task> newTasks, Map<Id, Task> oldTaskMap) {
        for (Task newTask : newTasks) {
            Task oldTask = oldTaskMap.get(newTask.Id);
            
            // When checkbox becomes TRUE, set Status to Completed
            if (newTask.Set_To_Next_30_Days__c == true &&
                oldTask.Set_To_Next_30_Days__c != true &&
                newTask.WhatId != null &&
                newTask.ActivityDate != null) {
                
                newTask.Status = 'Completed';
            }
        }
    }
    
    public static void handleAfterUpdate(List<Task> newTasks, Map<Id, Task> oldTaskMap) {
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        Map<Id, Date> taskDates = new Map<Id, Date>();
        
        // Collect for parent updates (Status already set in before)
        for (Task newTask : newTasks) {
            Task oldTask = oldTaskMap.get(newTask.Id);
            
            if (newTask.Set_To_Next_30_Days__c == true &&
                oldTask.Set_To_Next_30_Days__c != true &&
                newTask.Status == 'Completed' &&  // Confirm it was set
                newTask.WhatId != null &&
                newTask.ActivityDate != null) {
                
                String whatPrefix = String.valueOf(newTask.WhatId).left(3);
                if (whatPrefix == '0Q0') {
                    quoteIds.add(newTask.WhatId);
                } else if (whatPrefix == '800') {
                    contractIds.add(newTask.WhatId);
                }
                taskDates.put(newTask.WhatId, newTask.ActivityDate);
            }
        }
        
        // Update Quotes
        if (!quoteIds.isEmpty()) {
            List<Quote> quotesToUpdate = [
                SELECT Id, ExpirationDate FROM Quote 
                WHERE Id IN :quoteIds FOR UPDATE
            ];
            for (Quote q : quotesToUpdate) {
                if (taskDates.containsKey(q.Id)) {
                    q.ExpirationDate = taskDates.get(q.Id).addDays(30);
                }
            }
            update quotesToUpdate;
        }
        
        // Update Contracts
        if (!contractIds.isEmpty()) {
            List<Contract> contractsToUpdate = [
                SELECT Id, Expiration_Date__c FROM Contract 
                WHERE Id IN :contractIds FOR UPDATE
            ];
            for (Contract c : contractsToUpdate) {
                if (taskDates.containsKey(c.Id)) {
                    c.Expiration_Date__c = taskDates.get(c.Id).addDays(30);
                }
            }
            update contractsToUpdate;
        }
    }
}