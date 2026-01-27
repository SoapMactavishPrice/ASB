({
    doInit: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get("c.getProductList");
        action.setParams({
            'RecId': recordId
        });

        component.set('v.manualndex', -1);

        var exchangeRate = component.get("c.getQuotationDetails");

        var eRate = '';
        var subMargin = '';
        var quoteMargin = '';
        var roundOfDigit = '';
        var QtyRestricted = '';
        var m1 = '';
        var d1 = '';
        action.setParams({
            'RecId': recordId
        });
        exchangeRate.setParams({
            'RecId': recordId
        });

        console.log("iddddd:>>", recordId);

        exchangeRate.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.currencyCode", result.CurrencyIsoCode);
                eRate = result.Exchange_Rate__c;
                component.set("v.IsTaxableDisable", result.Is_Taxable__c);

                subMargin = result.Subsidiary__r.Additional_Margin__c;
                quoteMargin = result.Additinal_Margin__c;
                roundOfDigit = result.Subsidiary__r.Rounding_Off_Digits__c;
                QtyRestricted = result.Subsidiary__r.Quantity_Restricted__c;
                m1 = result.Subsidiary__r.M1__c;
                d1 = result.Subsidiary__r.D1__c;
                component.set("v.QtyRestricted", QtyRestricted);
                component.set('v.tempSerialNumber', result.Max_Serial_Number__c);
                component.set('v.StatictempSerialNumber', result.Max_Serial_Number__c);
                console.log('QtyRestricted 1 -> ', component.get("v.QtyRestricted"));
            } else {
                console.log('something bad happend! ');
            }
        });
        $A.enqueueAction(exchangeRate);

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();

                for (var i = 0; i < result.length;) {
                    result[i].index = i;
                    i++;
                }

                component.set("v.UnfilteredData", result);
                component.set("v.data", result);
                component.set("v.dataFound", true);
                component.set("v.dataNotFound", false);
                component.set("v.loader", false);
            } else {
                console.log('something bad happend! ');
            }
        });
        $A.enqueueAction(action);

        var pickvar = component.get("c.getPickListValuesIntoList");
        pickvar.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var list = response.getReturnValue();
                console.log('list are' + list);
                component.set("v.picvalue", list);
                console.log('picvalue are' + component.get("v.picvalue"));
            }
            else if (state === 'ERROR') {
                //var list = response.getReturnValue();
                //component.set("v.picvalue", list);
                alert('ERROR OCCURED.');
            }
        })
        $A.enqueueAction(pickvar);


        var pickvar2 = component.get("c.getPickListValuesIntoListv2");
        pickvar2.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var list = response.getReturnValue();
                console.log('list are' + list);
                component.set("v.picvaluev2", list);
                console.log('picvalue are' + component.get("v.picvaluev2"));
            }
            else if (state === 'ERROR') {
                //var list = response.getReturnValue();
                //component.set("v.picvalue", list);
                alert('ERROR OCCURED.');
            }
        })


        $A.enqueueAction(pickvar2);
    },

    OnProdTypeSelect: function (component, event, helper) {
        component.set("v.currentProdType", event.getSource().get("v.value"));
        console.log('new   ' + component.get("v.currentProdType"));
    },


    OnProdTypeSelectv2: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        var allRecords = component.get("v.ProdList");
        var selectedRec = event.getSource().get("v.value");
        console.log('index', index, selectedRec);
        //if(selectedRec == true){
        allRecords[index].Product_Type__c = selectedRec;
        //}
        console.log('record Type-->', allRecords[index]);
        component.set("v.ProdList", allRecords);
        // component.set("v.currentProdType",event.getSource().get("v.value"));  
    },



    OnCheck: function (component, event, helper) {
        var checkCmp = event.getSource().get("v.value");
        console.log('record Type' + checkCmp);

        if (checkCmp == 'In Built Products') {
            var dt = component.get("v.data");
            var totalLength = dt.length;
            console.log('data' + dt.length);
            var pageSize = component.get("v.pageSize");
            console.log('pageSize' + pageSize);
            component.set("v.startPage", 0);
            component.set("v.endPage", pageSize - 1);

            var PaginationLst = [];
            for (var i = 0; i < pageSize; i++) {
                if (dt.length > i) {
                    PaginationLst.push(dt[i]);
                }
            }
            console.log('PaginationLst', PaginationLst.length);
            component.set('v.PaginationList', PaginationLst);
            component.set("v.selectedCount", 0);
            component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
            component.set("v.dataFound", true);
            component.set("v.dataNotFound", false);

            console.log('set in built true');
            component.set("v.manualProd", 'false');
            component.set("v.inBuiltProd", 'true');
            component.set("v.isNull", 'false');
        }
        if (checkCmp == 'Manual Products') {
            console.log('set man true');
            component.set("v.inBuiltProd", 'false');
            component.set("v.manualProd", 'true');
            component.set("v.isNull", 'false');
        }
    },

    checkboxSelect: function (component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        console.log('index', event.getSource().get("v.name"));
        var getSelectedNumber = component.get("v.selectedCount");

        var index = event.getSource().get("v.name");

        if (selectedRec == true) {
            getSelectedNumber++;

            //helper.SelectedRecords(component,index);
        } else {
            getSelectedNumber--;
            //component.find("selectAllId").set("v.value", false);
            //  helper.SelectedRecords(component,index);
        }
        console.log('getSelectedNumber ====>>>>' + getSelectedNumber);
        component.set("v.selectedCount", getSelectedNumber);



    },

    navigation: function (component, event, helper) {
        var sObjectList = component.get("v.data");
        console.log('Naviagtion length ', sObjectList.length);
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        console.log('whichBtn', whichBtn);
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

    doFilter: function (component, event, helper) {
        console.log('In Do Filter');
        helper.FilterRecords(component);
    },

    doSave: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var allRecords = component.get("v.data");
        component.set("v.loader", true);
        component.set("v.SaveHit", false);
        var selectedRecords = [];
        var quantityList = [];
        let isValid = true;
        var SelectedSerialNumber = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                console.log('QtyRestricted 2 ->', component.get("v.QtyRestricted"));
                if (($A.util.isEmpty(allRecords[i].quantity)) || (allRecords[i].quantity == 0) || (allRecords[i].quantity > component.get("v.QtyRestricted"))) {
                    isValid = false;
                    console.log('isValid = ' + isValid);
                    component.set("v.loader", false);
                    break;
                } else {
                    quantityList.push(allRecords[i].quantity);
                    selectedRecords.push(allRecords[i].objprod);

                }
                SelectedSerialNumber.push(allRecords[i]);
            }/*else{
                allRecords[i].quantity = 1; 
            }*/
        }
        console.log('isValid = ' + isValid);

        if (isValid) {
            component.set("v.loader", false);
            var CheckDateAction = component.get("c.checkDate");
            var oppResult;
            CheckDateAction.setParams({
                'RecId': recordId
            });
            CheckDateAction.setCallback(this, function (response) {
                var state = response.getState();
                if (state == 'SUCCESS') {
                    oppResult = response.getReturnValue();
                } else {
                    console.log('something bad happend! ');
                }
                if (oppResult) {
                    var action = component.get("c.SelectedProd");
                    action.setParams({
                        'selectedRecordList': selectedRecords,
                        'RecId': recordId,
                        'quantityList': quantityList,
                        'js': JSON.stringify(SelectedSerialNumber)
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        var err = response.getError();
                        //console.log('err==> ',err[0].message);
                        console.log('state===>>>' + state);

                        if (state == 'SUCCESS') {
                            var toastevent = $A.get('e.force:showToast');
                            toastevent.setParams({
                                'title': 'Success',
                                'type': 'Success',
                                'message': 'Custom Quote Line Item Is Created',
                                'mode': 'dismissible'
                            })
                            toastevent.fire();
                            $A.get('e.force:closeQuickAction').fire();
                            $A.get('e.force:refreshView').fire();
                            console.log('List Sent Successfully');
                        }
                        else if (err[0].message == 'Price Error') {
                            var toastevent = $A.get('e.force:showToast');
                            toastevent.setParams({
                                'title': 'error',
                                'type': 'error',
                                'message': 'The Sales Price You Entered Is Less Then The Base Price.',
                                'mode': 'dismissible'
                            })
                            toastevent.fire();
                            component.set("v.SaveHit", true);
                        } else if (err[0].message == 'Closed Lost Error') {
                            var toastevent = $A.get('e.force:showToast');
                            toastevent.setParams({
                                'title': 'error',
                                'type': 'error',
                                'message': 'You are not allowed to change Closed Lost Opportunity.',
                                'mode': 'dismissible'
                            })
                            toastevent.fire();
                            component.set("v.SaveHit", true);
                        } else {
                            var toastevent = $A.get('e.force:showToast');
                            toastevent.setParams({
                                'title': 'error',
                                'type': 'error',
                                'message': err[0].message,
                                'mode': 'dismissible'
                            })
                            toastevent.fire();
                            component.set("v.SaveHit", true);
                        }
                    });
                    $A.enqueueAction(action)
                } else {
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'title': 'error',
                        'type': 'error',
                        'message': 'Opportunity close date cannot be the past date',
                        'mode': 'dismissible'
                    })
                    toastevent.fire();
                    component.set("v.SaveHit", true);
                }
            });
            $A.enqueueAction(CheckDateAction);
        } else {
            console.log('Error Inside IsValid Else Condition');
            var toastevent = $A.get('e.force:showToast');
            toastevent.setParams({
                'title': 'error',
                'type': 'error',
                'message': 'Quantity should be equal to or less than Restricted Quantity.',
                'mode': 'dismissible'
            })
            toastevent.fire();
            component.set("v.SaveHit", true);
            component.set("v.loader", false);
        }
    },

    checkboxSelectOnTaxable: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        var allRecords = component.get("v.ProdList");
        var selectedRec = event.getSource().get("v.value");
        console.log('index', index);
        if (selectedRec == true) {
            allRecords[index].Is_Tax__c = true;
        }

        component.set("v.ProdList", allRecords);
    }

    , doSaveManual: function (component, event, helper) {
        component.set("v.loader", true);
        component.set("v.SaveHitManual", false);
        var recordId = component.get('v.recordId');
        var allRecords = component.get("v.ProdList");
        var allProductData = JSON.parse(JSON.stringify(allRecords));
        let checkList = 0;
        console.log('checkList==>')
        for (let i = 0; i < allProductData.length; i++) {
            var basePrice = allProductData[i].Base_Price__c;
            var listPrice = allProductData[i].List_Price__c;
            if (parseInt(listPrice) < parseInt(basePrice)) {
                //checkList++;
            }
            
            
            if(allProductData[i].Product_Type__c =='' || allProductData[i].Product_Type__c ==null|| allProductData[i].Product_Type__c ==undefined){
                checkList++;
                var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'title': 'error',
                        'type': 'error',
                        'message': 'Please Fill Product Type',
                        'mode': 'dismissible'
                    })
                    toastevent.fire();
                    component.set("v.SaveHitManual", true);
                component.set("v.loader", false);
            }
        }
        console.log('checkList==>', checkList);
        window.setTimeout(
    $A.getCallback(function() {
        if (checkList === 0) {
            component.set("v.loader", true);
            console.log('allRecords =================================>>>>> ' + JSON.stringify(allRecords));
            var action = component.get("c.enterManualProd");
            action.setParams({
                'selectedRecordList': allRecords,
                'RecId': recordId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                var err = response.getError();
                console.log('state===>>>' + state);
                if (state == 'SUCCESS') {
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'title': 'Success',
                        'type': 'Success',
                        'message': 'Custom Quote Line Item Is Created',
                        'mode': 'dismissible'
                    })
                    toastevent.fire();
                    $A.get('e.force:refreshView').fire();
                    console.log('List Sent Successfully');
                    $A.get('e.force:closeQuickAction').fire();
                }
                else if (err[0].message == 'Price Error') {
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'title': 'error',
                        'type': 'error',
                        'message': 'The Sales Price You Entered Is Less Then The Base Price.',
                        'mode': 'dismissible'
                    })
                    toastevent.fire();
                    component.set("v.SaveHitManual", true);
                } else if (err[0].message == 'Closed Lost Error') {
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'title': 'error',
                        'type': 'error',
                        'message': 'You are not allowed to change Closed Lost Opportunity.',
                        'mode': 'dismissible'
                    })
                    toastevent.fire();
                    component.set("v.SaveHitManual", true);
                } else {
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'title': 'error',
                        'type': 'error',
                        'message': 'Internal Error',
                        'mode': 'dismissible'
                    })
                    toastevent.fire();
                    component.set("v.SaveHitManual", true);
                    console.log('There was a problem : ' + json.stringify(response.getError()));
                }
            });
            $A.enqueueAction(action)
        } 
         }), 
    1500 // Delay in milliseconds (e.g., 3000 = 3 seconds)
);
        /*else {
            var toastevent = $A.get('e.force:showToast');
            toastevent.setParams({
                'title': 'error',
                'type': 'error',
                'message': 'Please check List Price should be greater than Base Price',
                'mode': 'dismissible'
            })
            toastevent.fire();
            component.set("v.SaveHitManual", true);
        }*/
    },


    addRow: function (component, event, helper) {
        var OptionList = component.get("v.ProdList");
        console.log('OptionList ===>>>' + JSON.stringify(OptionList));
        var recordId = component.get('v.recordId');
        var temp = component.get('v.tempSerialNumber');
        var idex = component.get('v.manualndex');

        OptionList.push({
            'sobjectType': 'Quote_Line_Item_Custom__c',
            'sr_No__c': temp + 10,
            'idex': idex + 1,
            'Product_Name__c': '',
            // 'Product_Type__c' : '',
            'Base_Price__c': '',
            'List_Price__c': '',
            // 'Scope_of_mould__c': '',
            // 'Discount__c': '',
            // 'Cavity__c': '',
            'Quantity__c': 1,
            'Is_Tax__c': false,
            'Quote__c': recordId,
            'Product_Type__c': '',
            'Is_Manual__c': true,
            'Product_Description__c': '',
        });
        component.set('v.manualndex', idex + 1);
        component.set('v.tempSerialNumber', temp + 10);
        component.set("v.ProdList", OptionList);
        /*if(OptionList.length > 0){
        for(var i = 0; i<OptionList.length; i++){
            if(OptionList[i].idex > index && OptionList[i].sr_No__c > 0){
                OptionList[i].sr_No__c = OptionList[i].sr_No__c +10;
                OptionList[i].idex = OptionList[i].idex +1;
            }
          }
             component.set("v.ProdList", OptionList);
        }
       */


    },

    removeRow: function (component, event, helper) {
        //Get the account list
        var OptionList = component.get("v.ProdList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        console.log('index ===>>> ' + index);

        var idex = component.get('v.manualndex');
        component.set('v.manualndex', idex - 1);
        var temp = component.get('v.tempSerialNumber');
        component.set('v.tempSerialNumber', temp - 10);
        OptionList[index].sr_No__c = OptionList[index].sr_No__c - 10;
        //component.set("v.ProdList", OptionList);
        if (OptionList.length > 0) {
            for (var i = 0; i < OptionList.length; i++) {
                console.log(' prod index' + index);
                console.log('line item index ' + OptionList[i].idex);
                if (OptionList[i].idex > index && OptionList[i].sr_No__c > 0) {
                    OptionList[i].sr_No__c = OptionList[i].sr_No__c - 10;
                    OptionList[i].idex = OptionList[i].idex - 1;
                }
            }

        }
        OptionList.splice(index, 1);
        component.set("v.ProdList", OptionList);
    },

    Onclose: function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})