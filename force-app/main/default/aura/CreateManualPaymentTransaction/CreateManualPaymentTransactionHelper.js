({
	addAccountRecord1: function(component, event, helper) {
        console.log('in add row helper');
        var ContractList = component.get("v.ContractList");
        var Ctrid = component.get("v.contractID");
        var action = component.get("c.fatchContractLineItem"); 
        action.setParams({key : Ctrid});
        console.log('Ctrid --->>>  ' + Ctrid);
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state -->> ' + state);
            if(state === "SUCCESS"){
                component.set("v.ContractList",response.getReturnValue());
                console.log('ContractList ==---->>>  ' + JSON.stringify(response.getReturnValue()));
                var st = [];
                st = response.getReturnValue();
                console.log('st --->>>> ' + st);
                var i;
                for (i = 0; i < response.getReturnValue().length; i++) {
                    console.log('loop ===== ====+++ '+JSON.stringify(response.getReturnValue()[i].Product2Id__c));
                    if(JSON.stringify(response.getReturnValue()[i].Product2Id__c) != undefined){
                        console.log('-------------  in if ---------------------');
                        ContractList.push({
                            'sobjectType': 'Contract_Line_Item__c',
                            'Contract_Name__c' : JSON.stringify(response.getReturnValue()[i].Name),
                            'Product_Name_1__c' : JSON.stringify(response.getReturnValue()[i].Product2Id__r.Name),
                            'Product2Id__c': JSON.stringify(response.getReturnValue()[i].Product2Id__c),
                            'ContractId__c': JSON.stringify(response.getReturnValue()[i].ContractId__c),
                            'id__c': JSON.stringify(response.getReturnValue()[i].Id),
                            'ContractNumber': JSON.stringify(response.getReturnValue()[i].ContractId__r.ContractNumber),
                            'Total_List_Price__c': JSON.stringify(response.getReturnValue()[i].Total_Price__c),
                            'Advance_Amount_Required__c': JSON.stringify(response.getReturnValue()[i].Advance_Amount_Required__c),
                            'Total_Amount_Received__c': JSON.stringify(response.getReturnValue()[i].Total_Amount_Received__c),
                            'Balance_Payment__c' : JSON.stringify(response.getReturnValue()[i].Balance_Payment__c),
                            'Amount_Allocated__c' : '',
                        });
                    }
                    else{
                        console.log('-------------  in else ---------------------');
                         ContractList.push({
                            'sobjectType': 'Contract_Line_Item__c',
                             'Product_Name_1__c' : JSON.stringify(response.getReturnValue()[i].Product_Name_2__c),
                            'Contract_Name__c' : JSON.stringify(response.getReturnValue()[i].Name),
                            'id__c': JSON.stringify(response.getReturnValue()[i].Id),
                            'ContractId__c': JSON.stringify(response.getReturnValue()[i].ContractId__c),
                            'ContractNumber': JSON.stringify(response.getReturnValue()[i].ContractId__r.ContractNumber),
                            'Total_List_Price__c': JSON.stringify(response.getReturnValue()[i].Total_Price__c),
                            'Advance_Amount_Required__c': JSON.stringify(response.getReturnValue()[i].Advance_Amount_Required__c),
                            'Total_Amount_Received__c': JSON.stringify(response.getReturnValue()[i].Total_Amount_Received__c),
                            'Balance_Payment__c' : JSON.stringify(response.getReturnValue()[i].Balance_Payment__c),
                            'Amount_Allocated__c' : '',
                        });
                    }
                    
                    component.set("v.ContractList", ContractList)
                }
            }
        }); 
       
        $A.enqueueAction(action);
    }
    
    
})