({
	doInit : function(component, event, helper) {
		var rid = component.get("v.recordId")
		var action = component.get("c.getProductList"); 
        action.setParams({  
            'recordId' : rid,
        });
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();  
                //component.set("v.UnfilteredData",result);  
                console.log('result --->>> '+JSON.stringify(result));  
                component.set("v.data",result);  
            }else{  
                console.log('something bad happend! '); 
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log('error --->>> ' + errors[0].message);
                }
            }  
        });  
        // put the action into queue for server call.  
        $A.enqueueAction(action);
	},
    
    checkboxSelect : function(component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        
        var getSelectedNumber = component.get("v.selectedCount");
        //alert('getSelectedNumber : : '+getSelectedNumber);
        if (selectedRec == true) {
            //alert('selectedRec : : '+selectedRec);
            getSelectedNumber++;
        } else {
            //alert('selectedRec : : '+selectedRec);
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        console.log('getSelectedNumber ====>>>>' + getSelectedNumber);
        component.set("v.selectedCount", getSelectedNumber);
    },
    
    doSave : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        //var prd = component.find("inputOne").get("v.value"); 
        //var rate = component.find("inputTwo").get("v.value"); 
        var allRecords = component.get("v.data");
        //console.log('prd -->> ' + prd);
        //console.log('rate -->> ' + rate);
        console.log('allRecords =================================>>>>> ' + JSON.stringify(allRecords));
        
        //console.log(window.arrProdId);
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].objprod);
            }
        }
        
        var action = component.get("c.SelectedProd");
        console.log('selectedRecords =================================>>>>> '+JSON.stringify(selectedRecords));
        action.setParams({  
            'selectedRecordList':selectedRecords ,
            'RecId' : recordId,
            //'period':prd ,
            //'rate' : rate,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state===>>>' + state);
            if(state == 'SUCCESS')
            {
                var toastevent = $A.get('e.force:showToast');
                toastevent.setParams({
                    'title' : 'Success',
                    'type' : 'Success',
                    'message' : 'Finance is Created',
                    'mode' : 'dismissible'
                })
                toastevent.fire();
                $A.get('e.force:refreshView').fire();
                console.log('List Sent Successfully');
                $A.get('e.force:closeQuickAction').fire();
            }else{  
                console.log('something bad happend! '); 
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log('error --->>> ' + errors[0].message);
                }
            }  
            
        });
        $A.enqueueAction(action)   
    },
    
    Onclose : function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    }
    
})