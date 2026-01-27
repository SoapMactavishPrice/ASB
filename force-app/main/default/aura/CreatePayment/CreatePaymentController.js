({
    
    //Shubham
     doInit1 : function(component, event, helper) {
        console.log(' --->>> in doinit1');
        var CLI=[];
    for (var idx=0; idx<5; idx++) {
        CLI.push({sobjectType:'Contract_Line_Item__c'});
    }
    component.set('v.CLI', CLI); 
         
        var rid = component.get("v.recordId");
        var action = component.get("c.fatchContractLineItem"); 
        action.setParams({key : rid});
        action.setCallback(this, function(data){

            component.set("v.ContractLineItem",data.getReturnValue());
            console.log('----->', data.getReturnValue());

        });       

        $A.enqueueAction(action);
        helper.addAccountRecord1(component, event, helper);

                },
    
    //Shubham end
    
    doInit: function(component, event, helper) {
       	var rid = component.get('v.recordId');
        console.log('rid ===>>> +++' + rid);
        var action = component.get('c.fetchExpdate'); 
        var ContractDeatails = component.get("c.fetchContractDetails");
        action.setParams({key : rid});
        
        ContractDeatails.setParams({key : rid});
        ContractDeatails.setCallback(this,function(response){  
        var state = response.getState();  
        if(state == 'SUCCESS'){  
            var result = response.getReturnValue();  
            component.set("v.ContCurrency",result.CurrencyIsoCode);
            console.log('v.ContCurrency -> ',component.get("v.ContCurrency"));
        }else{
            console.log('something bad happend! ');  
        }
    });   
    $A.enqueueAction(ContractDeatails);
        
        action.setCallback(this, function(data){
			var recordList = data.getReturnValue();
                console.log("recordList----> " + JSON.stringify(recordList));
            if(!recordList){
                console.log('in if recordList ===>>> ' + recordList);
                //component.set("v.status",true);
            }
            

        });       
        console.log('--->>>> in doinit');
        
        helper.doInitHelper(component, event);
        helper.doInitHelperUserDetail(component, event, helper);
        $A.enqueueAction(action);
    },
    
    onFocOut : function(component,event,helper){
        var AmountRecived = component.find("inputFour").get("v.value");
        if(AmountRecived != null){
            component.find("inputEight").set("v.value", AmountRecived);
        }
    },
    
    /*changeCurrency : function(component,event,helper){
        var curr = component.find("inputSix").get("v.value");
        if(curr != null){
            component.find("inputSeven").set("v.value", curr);
        }
    },*/
    
    CurrencyExchange: function(component,event,helper){
        //alert('Reaching Exchange');
        var ExchangeRate = component.find("inputFive").get("v.value"); 
        var currency = component.find("inputSix").get("v.value"); 
        var localcurrency = component.find("inputSeven").get("v.value");
        var AmountRecived = component.find("inputFour").get("v.value");
        var AmountUsd = AmountRecived / ExchangeRate;
        //  alert('AmountUsd'+AmountUsd);
        //  alert('currency'+currency);
        //  alert('localcurrency'+localcurrency);
        //  alert('AmountRecived'+AmountRecived);
        console.log('currency ' +currency);
        console.log('localcurrency ' + localcurrency);
        if(currency == 'INR' && localcurrency =='INR'){
            component.find("inputEight").set("v.value", AmountRecived);
        }
        if(currency == 'USD' && localcurrency =='USD'){
            component.find("inputEight").set("v.value", AmountRecived);
        }
        if(currency == 'INR' && localcurrency =='USD'){
            console.log('INR to USD');
            var AmountUsd = AmountRecived / ExchangeRate;
            component.find("inputEight").set("v.value", AmountUsd);
        }
        if(currency == 'USD' && localcurrency =='INR'){
            console.log('USD to INR');
            var AmountINR = (AmountRecived*ExchangeRate);
            //alert('AmountINR'+AmountINR);
            component.find("inputEight").set("v.value", AmountINR);
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
            if(dataList.Manula_Option_List_Price__c != null){
                Listprice =  dataList.Manula_Option_List_Price__c;
            }
            if(dataList.Manula_Option_List_Price__c != null){
                BasePrice =  dataList.Manual_Option_Base_Price__c;
            }
            if(dataList.Manula_Option_List_Price__c != null){
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
        var Cheque = component.find("inputTwo").get("v.value");
        var ModeOfPayment = component.find("inputOne").get("v.value");
        var Datedata = component.find("inputThre").get("v.value");
        var Amountrecieved = component.find("inputFour").get("v.value");
        var ExchangeRate = component.find("inputFive").get("v.value");
        var Currency = component.get("v.ContCurrency");
        var LocalCurrency = component.find("inputSeven").get("v.value");
        var AmountLocalCurrency = component.find("inputEight").get("v.value");
        var InvoiceNumber = component.find("inputNine").get("v.value");
        var InvoiceDate = component.find("inputTen").get("v.value");
        var PaymentType = component.find("inputEleven").get("v.value");
        var recordId = component.get('v.recordId');
        var allRecords = component.get("v.ContractList");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i]) {
                selectedRecords.push(allRecords[i]);
            }
        }
        //alert('Cheque = = = '+Cheque+'==='+ModeOfPayment+'==='+Datedata+'===='+Amountrecieved);
        //  alert(JSON.stringify(selectedRecords));
        console.log('selectedrecords --->>> '+JSON.stringify(selectedRecords));
        
        //=====================================================================
        var SelectedLead = JSON.stringify(selectedRecords);
       
        var action = component.get("c.SelectedLead");
        action.setParams({  
            'selectedRecordList':selectedRecords ,
            'contractId' : recordId,
            'PaymentMode' : ModeOfPayment,
            'Cheque' : Cheque,
            'Datedata' : Datedata,
            'Amountrecieved' : Amountrecieved,
            'ExchangeRate' : ExchangeRate,
            'Cur' : Currency,
            'LocalCurrency' : LocalCurrency,
            'AmountLocalCurrency' : AmountLocalCurrency,
            'InvoiceNumber' : InvoiceNumber, 
            'InvoiceDate' : InvoiceDate,
            'PaymentType' : PaymentType,

            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state');
            if(state == 'SUCCESS')
            {
                console.log('List Sent Successfully');
                var homeEvt = $A.get("e.force:navigateToObjectHome");
                homeEvt.setParams({
                    "scope": "Payment__c"
                });
                homeEvt.fire();
                $A.get('e.force:closeQuickAction').fire();
            }
            else if(state === "ERROR"){
                console.log('error1');
                component.set("v.messageType", 'error' );
                var errors = action.getError();
                if (errors) {
                if (errors[0] && errors[0].message) {
                component.set("v.message",errors[0].message );//Fetching Custom Message.
                               }
                            }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
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
    
     addRow1: function(component, event, helper) {
         console.log('in add row');
        helper.addAccountRecord1(component, event);
    },
    
    passToChildMethod : function(component, event, helper) {
        console.log('in child JS');
        component.set("v.contractID", event.getParam("passval"));
        helper.addAccountRecord1(component, event);
        //var contId = component.get("v.contractID");
        //console.log('contId----->>> '+JSON.stringify(event.getParam("passval")));
        //alert('Parent-2:::passToChildMethod ');
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
    
    save: function(component, event, helper) {
        if (helper.validateAccountList(component, event)) {
            helper.saveAccountList(component, event);
        }
    },
    OnBlured : function(component,event,helper){
       
       
        helper.OnBluredhelper(component,event,helper);
        
    },
    
    handleSuccess : function(component, event, helper) {  
         console.log('in handlesuccess');
        var eventFields = event.getParam("fields");
        //var params = event.getParams();  
        //var contractVar = component.find("contractID").get("v.value");
        //console.log('in contractID -->>  ' + contractVar);
        alert(params.response.id);  
          
    }  
    
})