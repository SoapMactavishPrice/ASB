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

            component.set("v.totalQuantity", Wrapperdata.Grand_Total_Item_Quantity__c || 0);
            component.set("v.totalTP", Wrapperdata.Total_Base_Price__c || 0);
            component.set("v.totalListPrice2", Wrapperdata.Contract_Total_List_Price__c || 0);
            component.set("v.totalDiscountValue", Wrapperdata.Contract_Total_Discount_Value__c || 0);
            component.set("v.totalSalesPrice", Wrapperdata.Contract_Total_Sales_price__c || 0);
            component.set("v.salesMargin", Wrapperdata.Sales_Margin_Percent__c || 0);
            component.set("v.CurrencyIsoCode", Wrapperdata.CurrencyIsoCode);
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

                    Wrapperdata.forEach(item => {
                        item.isLineItem = !!(item.Contract_Line_Option__r && item.Contract_Line_Option__r.length > 0);
                    });

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
