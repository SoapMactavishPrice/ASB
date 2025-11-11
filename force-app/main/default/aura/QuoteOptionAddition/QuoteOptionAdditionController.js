({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get("c.GetLineItemName");
        var exchangeRate = component.get("c.getQuotationDetails");
        var QtyRestricted = '';
        component.set('v.tempSerialNumber',0);
        component.set('v.StatictempSerialNumber',0);
        //component.set("v.isManual",false);
        //component.set("v.isProduct__c",false);
        
        action.setParams
        ({  
            'Quote'  :  recordId   
        });
        exchangeRate.setParams({  
            'RecId' : recordId
        });
        exchangeRate.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();  
                QtyRestricted = result.Subsidiary__r.Option_Quantity_Restricted__c;
                component.set("v.QtyRestricted",QtyRestricted);
                console.log('QtyRestricted 1 -> ',component.get("v.QtyRestricted"));
            }else{  
                console.log('something bad happend! ');  
            }  
        });   
        $A.enqueueAction(exchangeRate);

        var percent = component.find("PicklistId");
        var opts=[];
        action.setCallback(this, function(response) {
            var allValues = response.getReturnValue();
            console.log('allValues -- >> ' + JSON.stringify(allValues));
            component.set("v.PercentPick", allValues);
        });
        $A.enqueueAction(action);
        
        var pickvar2 = component.get("c.getPickListValuesIntoListv2"); 
        pickvar2.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var list = response.getReturnValue();
                console.log('list are'+ list);
                component.set("v.picvaluev2", list);
                console.log('picvalue are'+ component.get("v.picvaluev2"));
            }
            else if(state === 'ERROR'){
                //var list = response.getReturnValue();
                //component.set("v.picvalue", list);
                alert('ERROR OCCURED.');
            }
        })
        
        
        $A.enqueueAction(pickvar2);
        
       // helper.doInitHelper(component, event);
        helper.doInitHelperUserDetail(component, event, helper);
        
    },
    
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.data");
        console.log('Naviagtion length ',sObjectList.length);
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
        console.log('select all check boxxes');
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
                listOfAllAccounts[i].serialNumber = listOfAllAccounts[i].serialNumber +10;
                component.set("v.selectedCount", listOfAllAccounts.length);
            } else {
                listOfAllAccounts[i].isChecked = false;
                listOfAllAccounts[i].serialNumber = 0;
                component.set("v.selectedCount", 0);
                
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
                //helper.SelectedRecords(component,i);
            } else {
                PaginationList[i].isChecked = false;
                //helper.SelectedRecords(component,i);
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
      var index = event.getSource().get("v.name"); 
        
        var getSelectedNumber = component.get("v.selectedCount");
     //    alert('getSelectedNumber'+getSelectedNumber);
        if (selectedRec == true) {
            getSelectedNumber++;
            helper.SelectedRecords(component,index);
        } else {
            getSelectedNumber--;
            helper.SelectedRecords(component,index);
            component.find("selectAllId").set("v.value", false);
        }
        console.log('getSelectedNumber ====>>>>' + getSelectedNumber);
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
    },
    doFilter: function(component, event, helper) {  
        //calling helper  
        console.log('In Do Filter');
        helper.FilterRecords(component);  
    },
    //  handlerCheckBoxFiletr : function(component,event,helper){
    
    //      helper.handlerCheckBoxFiletr(component,event,helper);
    //  },
    
    OnProdTypeSelectv2 : function(component,event,helper){
        var index = event.getSource().get("v.name"); 
        var allRecords = component.get("v.OptionList");
        var selectedRec = event.getSource().get("v.value");
        console.log('index',index,selectedRec);
        //if(selectedRec == true){
            allRecords[index].Product_Type__c = selectedRec;            
        //}
          console.log('record Type-->',allRecords[index]);
        component.set("v.OptionList",allRecords);
       // component.set("v.currentProdType",event.getSource().get("v.value"));  
    },
   
    
    
    OnCheck:function(component,event,helper)
    {
        var tempChk = component.get("v.PercentPick");
        console.log('value',tempChk);
        var checkCmp = event.getSource().get("v.value");
        console.log('value',checkCmp);
        for(var i = 0; i< tempChk.length; i++){
            if(tempChk[i].Id == checkCmp && tempChk[i].Is_Manual__c == false){
               helper.HandlerOnChangeHelper(component,event,helper);
               component.set("v.isManual",true);
                component.set("v.isProduct__c",true);
            }else if(tempChk[i].Id == checkCmp && tempChk[i].Is_Manual__c == true){
              component.set("v.isManual",true);
              component.set("v.isProduct__c",false);
            }
        }
        
        
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
        
        if (helper.validateAccountList(component, event)) {
            console.log('in if in submit');
            console.log('in if in submit', component);
            helper.saveAccountList(component, event);
        }
        
        
        
        
        var recordId = component.get('v.recordId');
        var checkCmp =   component.find("PicklistId").get("v.value");
        // console.log(component.find("PicklistId").get("v.Product2.Name"));
       // alert('recordId'+recordId);
       // alert('checkCmp'+checkCmp);
        var allRecords = component.get("v.listOfAllAccounts");
        var pagelist = component.get("v.PaginationList");
        console.log('allRecords =================================>>>>> ' + JSON.stringify(allRecords));
       
        //====================================================================================
        //Check Discount here
        
        var UserData = component.get('v.userInfo');
        var ListData = component.get('v.PaginationList'); 
        console.log('ListData : : '+JSON.stringify(ListData));
        console.log('userInfo : : '+JSON.stringify(UserData));
        var goAhead = true;
        
        var UserLevel = UserData.Level__c;
        console.log('UserLevel : : '+UserLevel);
        if(UserLevel == 'L1'){
            window.DiscPrice = 20;
            //console.log('DiscPrice::'+window.DiscPrice); 
        }
         if(UserLevel == 'L2'){
            window.DiscPrice = 23;
            //console.log('DiscPrice::'+window.DiscPrice); 
        }
         if(UserLevel == 'L3'){
            window.DiscPrice = 25;
            //console.log('DiscPrice::'+window.DiscPrice); 
        }
        
        
        //====================================================================================
        var theMap = component.get("v.theMap");
        //console.log(window.arrProdId);
        var selectedRecords = [];
        var selectedRecordsDesc = [];
        console.log('QtyRestricted 2 ----> ',component.get("v.QtyRestricted"));
        
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked ) {
                console.log('allRecords[i].objLead.Quantity__c --->',allRecords[i].objLead.Quantity__c,allRecords[i].objLead.Product_Type__c);
                console.log('product2 ====>>>' + JSON.stringify(allRecords[i]));
                console.log('typeof ====>>>' + JSON.stringify(allRecords[i].objLead.Product2.Discount_Level_1__c));
                if(UserLevel == 'L2' && allRecords[i].objLead.Discount_Level_2__c > allRecords[i].objLead.Product2.Discount_Level_2__c && (allRecords[i].objLead.desc == '' || allRecords[i].objLead.desc == undefined) ){
                    console.log('in level 2 in if');
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'type' : 'error',
                        'message' : 'You have to enter the desc for -->> ' + allRecords[i].objLead.Product2.Name
                    })
                    toastevent.fire();
                    goAhead = false;
                }
                else if(UserLevel == 'L1' && allRecords[i].objLead.Discount__c > allRecords[i].objLead.Product2.Discount_Level_1__c && (allRecords[i].objLead.desc == '' || allRecords[i].objLead.desc == undefined) ){
                    console.log('in level 1 in if');
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'type' : 'error',
                        'message' : 'You have to enter the desc for -->> ' + allRecords[i].objLead.Product2.Name
                    })
                    toastevent.fire();
                    goAhead = false;
                }
                else if(UserLevel == 'L3' && allRecords[i].objLead.Discount_Level_3__c > allRecords[i].objLead.Product2.Discount_Level_3__c && (allRecords[i].objLead.desc == '' || allRecords[i].objLead.desc == undefined) ){
                    console.log('in level 3 in if');
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'type' : 'error',
                        'message' : 'You have to enter the description for -->> ' + allRecords[i].objLead.Product2.Name
                    })
                    toastevent.fire();
                    goAhead = false;
                }else if(($A.util.isEmpty(allRecords[i].objLead.Quantity__c)) || (allRecords[i].objLead.Quantity__c == 0) || (allRecords[i].objLead.Quantity__c > component.get("v.QtyRestricted"))){
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'type' : 'error',
                        'message' : 'Quantity should be less than or equal to the Restricted Quantity.'
                    })
                    toastevent.fire();
                    goAhead = false;
                }
                else{
                    console.log('in else');
                    console.log('allRecords[i].objLead.Product2Id ====>>>> ' + allRecords[i].objLead.Product2Id);
                    console.log('allRecords[i].objLead.desc =====>>>>> ' + allRecords[i].objLead.desc);
                   	theMap[allRecords[i].objLead.Product2Id]=allRecords[i].objLead.desc;
                    //selectedRecords.push(allRecords[i]);
                    selectedRecordsDesc.push(allRecords[i].objLead.Product2Id +' - ' + allRecords[i].objLead.desc);
                    selectedRecords.push(allRecords[i].objLead);
                }
            }
        }
      //  alert(JSON.stringify(selectedRecords));
        console.log('selectedRecordsDesc ===>>>> ' + JSON.stringify(selectedRecordsDesc));
        console.log(' ====>>>>> selctedRecords ' + JSON.stringify(selectedRecords));
        
        //=====================================================================
        //goAhead = false;
        if(goAhead){
            console.log('in goAhead');
            var SelectedLead = JSON.stringify(selectedRecords);
            var action = component.get("c.SelectedLead");
            action.setParams({  
                'selectedRecordList':JSON.stringify(selectedRecords),
                'idCampaign' : recordId,
                'LineItemId' : checkCmp,
                'selectedRecordsDescList':JSON.stringify(selectedRecordsDesc),
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('state');
                if(state == 'SUCCESS')
                {
                    console.log('List Sent Successfully');
                     $A.get('e.force:refreshView').fire();
                    $A.get('e.force:closeQuickAction').fire();
                }
            });
            let varOptionList = component.get("v.OptionList");
            if(varOptionList.length > 0){
             save();
            }
            
            $A.enqueueAction(action)   
        }
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
    
    focus : function(component,event,helper){
        var inputCmpo = component.find("inputCmp");
        //inputCmp = Array.isArray(inputCmp) ? inputCmp[0].get("v.value") : inputCmp.get("v.value");
        var value2 = inputCmpo.get("v.name");
        console.log('value --->>>> ' + value2);
    },
    doOptionFilter : function(component, event, helper) { 
        console.log('In Do Option Filter');
        helper.FilterOptionRecords(component);  
    },
    
})