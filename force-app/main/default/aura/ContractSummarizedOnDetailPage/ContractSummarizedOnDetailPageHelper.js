({
    getDetail : function(component){
        var artId = component.get("v.recordId");
        var action = component.get("c.getContractDetail");
        action.setParams({
            'ContractID': artId
        });

        action.setCallback(this, function(response){
            var Wrapperdata = response.getReturnValue();
            console.log('Wrapperdata', JSON.stringify(Wrapperdata));

            let salesMargin = parseFloat(Wrapperdata.Sales_Margin_Percent__c).toFixed(2) || 0;
            component.set("v.salesMargin", salesMargin);
            component.set("v.isDTA", !!Wrapperdata.Is_DTA_Contract__c);
        });
        $A.enqueueAction(action);
    },

    initMethod : function(component) {
        var artId = component.get("v.recordId");
        var action = component.get("c.FetchdataWrapper");
        action.setParams({
            'ContractID': artId,
            'orderby': 'asc'
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            var Wrapperdata = response.getReturnValue();
            console.log('KB : : ' + JSON.stringify(Wrapperdata));

            if (state === "SUCCESS") {
                if (Wrapperdata && Wrapperdata.length > 0) {
                    component.set("v.LineItemPresent", true);
                    component.set("v.LineItemNotPresent", false);

                    let tempCurrencyIsoCode = null;

                    let totalQuantity = 0;
                    let totalTP = 0;
                    let totalListPrice2 = 0;
                    let totalDiscountValue = 0;
                    let totalSalesPrice = 0;
                    let totalUnitTP = 0;
                    let totalUnitListPrice = 0;
                    let totalUnitSalesPrice = 0;

                    Wrapperdata.forEach(item => {
                        tempCurrencyIsoCode = item.CurrencyIsoCode;

                        let subTotalQuantity = item.Quantity__c || 0;
                        let subTotalTP = item.Total_Global_Price_Item__c || 0;
                        let subTotalListPrice2 = item.Total_List_Price3__c || 0;
                        let subTotalDiscountValue = item.Discount_Value__c || 0;
                        let subTotalSalesPrice = item.Total_Sales_Price2__c || 0;

                        let subUnitTP = item.Base_Price_Line_Item__c || 0;
                        let subUnitListPrice = item.List_Price__c || 0;
                        let subUnitSalesPrice = item.Average_Sales_Price__c || 0;

                        if (item.Contract_Line_Option__r && item.Contract_Line_Option__r.length > 0) {
                            item.Contract_Line_Option__r.forEach(qlo => {
                                subTotalTP += qlo.Total_Transfer_Price__c || 0;
                                subTotalListPrice2 += qlo.Total_List_Price__c || 0;
                                subTotalDiscountValue += qlo.Discount_Amount__c || 0;
                                subTotalSalesPrice += qlo.Total_Sales_Price__c || 0;

                                subUnitTP += qlo.Manual_Option_Base_Price__c || 0;
                                subUnitListPrice += qlo.Manual_Option_List_Price__c || 0;
                                subUnitSalesPrice += qlo.Unit_Sales_Price__c || 0;
                            });
                        }

                        item.sub_TotalQuantity__c = parseFloat(subTotalQuantity);
                        item.sub_totalTP__c = parseFloat(subTotalTP).toFixed(2);
                        item.sub_totalListPrice2__c = parseFloat(subTotalListPrice2).toFixed(2);
                        item.sub_totalDiscountValue__c = parseFloat(subTotalDiscountValue).toFixed(2);
                        item.sub_totalSalesPrice = Math.round(parseFloat(subTotalSalesPrice)).toFixed(0);
                        item.sub_unitTP = parseFloat(subUnitTP).toFixed(2);
                        item.sub_unitListPrice = parseFloat(subUnitListPrice).toFixed(2);
                        item.sub_unitSalesPrice = parseFloat(subUnitSalesPrice).toFixed(2);
                        item.isLineItem = !!(item.Contract_Line_Option__r && item.Contract_Line_Option__r.length > 0);

                        let subMargin = 0;
                        if (subTotalSalesPrice !== 0) {
                            subMargin = ((subTotalSalesPrice - subTotalTP) / subTotalSalesPrice) * 100;
                        }
                        item.subMargin = subMargin.toFixed(2);

                        totalQuantity += subTotalQuantity;
                        totalTP += subTotalTP;
                        totalListPrice2 += subTotalListPrice2;
                        totalDiscountValue += subTotalDiscountValue;
                        totalSalesPrice += subTotalSalesPrice;
                        totalUnitTP += subUnitTP;
                        totalUnitListPrice += subUnitListPrice;
                        totalUnitSalesPrice += subUnitSalesPrice;
                    });

                    component.set("v.totalQuantity", parseFloat(totalQuantity));
                    component.set("v.totalTP", parseFloat(totalTP).toFixed(2));
                    component.set("v.totalListPrice2", parseFloat(totalListPrice2).toFixed(2));
                    component.set("v.totalDiscountValue", parseFloat(totalDiscountValue).toFixed(2));
                    component.set("v.totalSalesPrice", parseFloat(totalSalesPrice).toFixed(2));
                    component.set("v.CurrencyIsoCode", tempCurrencyIsoCode);
                    component.set("v.totalUnitTP", totalUnitTP.toFixed(2));
                    component.set("v.totalUnitListPrice", totalUnitListPrice.toFixed(2));
                    component.set("v.totalUnitSalesPrice", totalUnitSalesPrice.toFixed(2));

                    let grandMargin = 0;
                    if (totalSalesPrice !== 0) {
                        grandMargin = ((totalSalesPrice - totalTP) / totalSalesPrice) * 100;
                    }
                    component.set("v.salesMargin", grandMargin.toFixed(2));

                    component.set("v.QliItems", Wrapperdata);
                    this.sortData(component, 'Sr_No__c', 'asc');
                } else {
                    component.set("v.LineItemPresent", false);
                    component.set("v.LineItemNotPresent", true);
                }
            } else {
                console.log('KB error : : ');
            }
        });

        $A.enqueueAction(action);
    },

    exportCSVcaller: function(component){
        var artId = component.get("v.recordId");
        var action = component.get("c.exportCSV");
        action.setParams({
            'cId': artId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state===>>>' + state);
            if(state === 'SUCCESS') {
                var toastevent = $A.get('e.force:showToast');
                toastevent.setParams({
                    'title' : 'Success',
                    'type' : 'Success',
                    'message' : 'Export download successfully.',
                    'mode' : 'dismissible'
                });
                toastevent.fire();
                $A.get('e.force:refreshView').fire();
                console.log('List Sent Successfully');
            }
            component.set("v.loader", false);
        });
        $A.enqueueAction(action);
    },

    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.QliItems");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.QliItems", data);
    },

    sortBy: function (field, reverse) {
        var key = function(x) { return x[field]; };
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        };
    }
})