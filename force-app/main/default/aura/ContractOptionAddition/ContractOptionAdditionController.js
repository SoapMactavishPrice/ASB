({
    doInit: function(component, event, helper) {
        
        var recordId = component.get('v.recordId');
        
        if(recordId.Approval_Status_From_HOD__c!='Rejected'){
        var action = component.get("c.GetLineItemName");
        action.setParams
        ({  
            'Contract'  :  recordId   
        });
        var percent = component.find("PicklistId");
        var opts=[];
        action.setCallback(this, function(response) {
            var allValues = response.getReturnValue();
            console.log('allValues -- >> ' + JSON.stringify(allValues));
            component.set("v.PercentPick", allValues);
        });
        $A.enqueueAction(action);
        
        
       // helper.doInitHelper(component, event);
        helper.doInitHelperUserDetail(component, event, helper);
            
        }
        else{
            
             var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       title : 'Error',
                       message:'Process Cannot carry on,since status by HOD is REJECTED..',
                       duration:' 1000',
                       key: 'info_alt',
                       type: 'error',
                       mode: 'pester'
                   });
                   toastEvent.fire();
        }
        
    },
    
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllAccounts");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllAccounts = component.get("v.listOfAllAccounts");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllAccounts[i].isChecked = true;
                component.set("v.selectedCount", listOfAllAccounts.length);
            } else {
                listOfAllAccounts[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfAllAccounts", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
    
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
      //  alert('selectedRec : : '+selectedRec);
        var getSelectedNumber = component.get("v.selectedCount");
     //    alert('getSelectedNumber'+getSelectedNumber);
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
    },
    doFilter: function(component, event, helper) {  
        //calling helper  
        helper.FilterRecords(component);  
    },
    //  handlerCheckBoxFiletr : function(component,event,helper){
    
    //      helper.handlerCheckBoxFiletr(component,event,helper);
    //  },
    
    
    OnCheck:function(component,event,helper)
    {
        helper.HandlerOnChangeHelper(component,event,helper);
        
    },
    
    OnChangeDisc : function(component,event,helper){
       // alert('GETTING THERE');
        var value = event.getSource().get('v.value');
        var index = event.getSource().get('v.name');
      //  alert('value'+value);
      //  alert('value'+index);
        
        var OptionList = component.get("v.OptionList");
        console.log('OptionList'+JSON.stringify(OptionList));
        var dataList = OptionList[index];
        console.log('dataList'+JSON.stringify(dataList));
        var Listprice = '';
        var BasePrice = '';
        var Discount = '';
        if(dataList != null){
            var Listprice = '';
            if(dataList.Manual_Option_List_Price__c != null){
                Listprice =  dataList.Manual_Option_List_Price__c;
            }
            if(dataList.Manual_Option_List_Price__c != null){
                BasePrice =  dataList.Manual_Option_Base_Price__c;
            }
            if(dataList.Manual_Option_List_Price__c != null){
                Discount =  dataList.Discount__c;
            }
            
            console.log('Data'+Listprice +'rrrrrr'+BasePrice+'dfgxcbfgbbxgb'+Discount);
            
            if(Listprice != null && BasePrice != null && Discount != null){
                var amount = Listprice - (Listprice*(Discount/100));
                console.log('amount'+amount);
                if(amount <BasePrice){
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'type' : 'error',
                        'message' : 'You Can No Enter This Value Of Discount'
                    })
                    toastevent.fire();
                }
            }
        }
        
       // Console.log('action'+action);
        
    },
    
    
    
    getSelectedRecords: function(component, event, helper)
    {
        
        if (helper.validateAccountList(component, event)) {
            console.log('in if in submit');
            helper.saveAccountList(component, event);
        }
        
        
        
        
        var recordId = component.get('v.recordId');
        var checkCmp =   component.find("PicklistId").get("v.value");
        // console.log(component.find("PicklistId").get("v.Product2.Name"));
       // alert('recordId'+recordId);
       // alert('checkCmp'+checkCmp);
        var allRecords = component.get("v.listOfAllAccounts");
        console.log('allRecords ----->>> '+JSON.stringify(allRecords));
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].objLead);
            }
        }
      //  alert(JSON.stringify(selectedRecords));
        console.log('----->>> '+JSON.stringify(selectedRecords));
        
        //=====================================================================
        var SelectedLead = JSON.stringify(selectedRecords);
        var action = component.get("c.SelectedLead");
        action.setParams({  
            'selectedRecordList':selectedRecords ,
            'idCampaign' : recordId,
            'LineItemId' : checkCmp
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state');
            if(state == 'SUCCESS')
            {
                console.log('List Sent Successfully');
                $A.get('e.force:closeQuickAction').fire();
            }
        });
        $A.enqueueAction(action)   
        
        //==========================================================================
    },
    handleFieldFiler : function(component, event, helper)
    {
        helper.handleFieldFiler(component,event,helper);
    },
    
    handleClearFiler : function(component, event, helper)
    {
        helper.handleClearFiler(component, event, helper);
    },
    
    
    
    addRow: function(component, event, helper) {
        helper.addAccountRecord(component, event);
    },
    
    removeRow: function(component, event, helper) {
        //Get the account list
        var OptionList = component.get("v.OptionList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        OptionList.splice(index, 1);
        component.set("v.OptionList", OptionList);
    },
    
    save: function(component, event, helper) {
        if (helper.validateAccountList(component, event)) {
            helper.saveAccountList(component, event);
        }
    },
    OnBlured : function(component,event,helper){
       
       
        helper.OnBluredhelper(component,event,helper);
        
    },
    doOptionFilter : function(component, event, helper) { 
        console.log('In Do Option Filter');
        helper.FilterOptionRecords(component);  
    },
    
})