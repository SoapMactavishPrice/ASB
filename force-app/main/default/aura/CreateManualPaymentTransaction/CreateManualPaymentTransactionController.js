({
    passToChildMethod : function(component, event, helper) {
        console.log('in child JS');
        component.set("v.contractID", event.getParam("passval"));
        helper.addAccountRecord1(component, event);
        //var contId = component.get("v.contractID");
        //console.log('contId----->>> '+JSON.stringify(event.getParam("passval")));
        //alert('Parent-2:::passToChildMethod ');
    },
    
    OnCheck : function(component, event, helper) {
        var checkCmp = event.getSource().get("v.value");
        console.log('checkCmp ===>>>' + checkCmp);
        if(checkCmp == 'Block Payment'){
            console.log('set in block true');
            component.set("v.transaction", 'false');
            component.set("v.blockPayment", 'true');
            //component.set("v.isNull", 'false');
        }
        if(checkCmp == 'Create Transactions'){
            console.log('set transaction true');
            component.set("v.blockPayment", 'false');
            component.set("v.transaction", 'true');
            //component.set("v.isNull", 'false');
        }
    },
    
    removeRow: function(component, event, helper) {
        //Get the account list
        var OptionList = component.get("v.ContractList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        OptionList.splice(index, 1);
        component.set("v.ContractList", OptionList);
    },
    
    blockPay :  function(component, event, helper) {
		var rid = component.get("v.recordId");
        var amount = component.find("inputOne").get("v.value"); 
        var rsn = component.find("inputTwo").get("v.value"); 
        console.log('amt ---->>> ' + amount);
        console.log('reason ---->>> ' + rsn);
        console.log('rid ---->>> ' + rid);    
        var action = component.get("c.blockPayment");
        action.setParams({  
            'recordId' : rid,
            'amt' : amount,
            'reason' : rsn,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state -->> '+state);
            if(state == 'SUCCESS')
            {
                console.log('List Sent Successfully');
                $A.get('e.force:refreshView').fire();
                $A.get('e.force:closeQuickAction').fire();
            }
            else if(state === "ERROR"){
                console.log('error1');
                component.set("v.messageType", 'error' );
                var errors1 = response.getError();
                if (errors1 && errors1[0] && errors1[0].message) {
                    console.log('error --->>> ' + errors1[0].message);
                }
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.message",errors[0].message );//Fetching Custom Message.
                        component.set("v.show","true" );
                    }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        });
        $A.enqueueAction(action)
    },
    
	getSelectedRecords : function(component, event, helper) {
		var rid = component.get("v.recordId");
        /*var amount = component.find("inputOne").get("v.value"); 
        var rsn = component.find("inputTwo").get("v.value"); 
        console.log('amt ---->>> ' + amount);
        console.log('reason ---->>> ' + rsn);*/
        console.log('rid ---->>> ' + rid);
        var allRecords = component.get("v.ContractList");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i]) {
                selectedRecords.push(allRecords[i]);
            }
        }
        console.log('selectedrecords --->>> '+JSON.stringify(selectedRecords));
        //var SelectedLead = JSON.stringify(selectedRecords);
       
        var action = component.get("c.makeTrans");
        action.setParams({  
            'selectedRecordList':selectedRecords ,
            'recordId' : rid,
            //'amt' : amount,
            //'reason' : rsn,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state -->> '+state);
            if(state == 'SUCCESS')
            {
                console.log('List Sent Successfully');
                $A.get('e.force:refreshView').fire();
                $A.get('e.force:closeQuickAction').fire();
            }
            else if(state === "ERROR"){
                console.log('error1');
                component.set("v.messageType", 'error' );
                var errors1 = response.getError();
                if (errors1 && errors1[0] && errors1[0].message) {
                    console.log('error --->>> ' + errors1[0].message);
                }
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.message",errors[0].message );//Fetching Custom Message.
                        component.set("v.show","true" );
                    }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        });
        $A.enqueueAction(action)
	}
})