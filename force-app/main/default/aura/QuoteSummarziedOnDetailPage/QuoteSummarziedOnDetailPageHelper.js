({
    getDetail : function(component){
        var artId = component.get("v.recordId");
        var action = component.get("c.getQuoteDetail");
        action.setParams({
            'QuotationID':artId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var Wrapperdata = response.getReturnValue();
            console.log('Wrapperdata',Wrapperdata.Is_DTA_Quote__c);
            if (Wrapperdata.Is_DTA_Quote__c){
                component.set("v.isDTA",true);
            }else{
                component.set("v.isDTA",false);
            }
            
            if (Wrapperdata.Status =='CREATED'){
                component.set("v.isSelectVisible",true);
                component.set("v.colspan",3);
            }else{
                component.set("v.isSelectVisible",false);
                component.set("v.colspan",2);
            }

            // Set Grand Total fields from Quote object
            component.set("v.totalQuantity", Wrapperdata.Grand_Total_Quantity__c || 0);
            component.set("v.totalTP", Wrapperdata.Quote_Total_Base_Price__c || 0);
            component.set("v.totalListPrice2", Wrapperdata.Quote_Total_List_Price__c || 0);
            component.set("v.totalDiscountValue", Wrapperdata.Quote_Total_Discount_Value__c || 0);
            component.set("v.totalSalesPrice", Wrapperdata.Quote_Totoal__c || 0);
            component.set("v.salesMargin", Wrapperdata.Sales_Margin__c || 0);
            component.set("v.CurrencyIsoCode", Wrapperdata.CurrencyIsoCode);
        });
        $A.enqueueAction(action);
    },

    initMethod: function(component) {
        var artId = component.get("v.recordId");
        var action = component.get("c.FetchdataWrapper");

        action.setParams({
            'QuotationID': artId,
            'orderby': 'asc'
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var Wrapperdata = response.getReturnValue();

                if (Wrapperdata && Wrapperdata.length > 0) {
                    component.set("v.LineItemPresent", true);
                    component.set("v.LineItemNotPresent", false);

                    Wrapperdata.forEach(item => {
                        item.isSelected = false;

                        // Use pre-calculated sub-total fields from QLI
                        item.sub_TotalQuantity__c = item.Quantity__c || 0;
                        item.sub_totalTP__c = item.Total_Base_Price_including_Options__c || 0;
                        item.sub_totalListPrice2__c = item.Total_List_Price__c || 0;
                        item.sub_totalDiscountValue__c = item.Total_Discount_Value_including_options__c || 0;
                        item.sub_totalSalesPrice = item.Total_Sales_Price_including_Options__c || 0;
                        item.subMargin = item.Sales_Margin_including_Options__c || 0;
                        item.isLineItem = !!(item.Quote_Line_Options__r && item.Quote_Line_Options__r.length > 0);

                        // Process child options
                        if (item.Quote_Line_Options__r && item.Quote_Line_Options__r.length > 0) {
                            item.Quote_Line_Options__r.forEach(qlo => {
                                qlo.isSelected = false;
                                qlo.vCheckId = item.Id + '-' + qlo.Id;
                            });
                        }
                    });

                    component.set("v.QliItems", Wrapperdata);
                    console.log('All data-->', JSON.stringify(Wrapperdata));
                    this.sortData(component, 'Sr_No__c', 'asc');

                } else {
                    component.set("v.LineItemPresent", false);
                    component.set("v.LineItemNotPresent", true);
                }
            } else {
                console.error('Error in FetchdataWrapper:', response.getError());
            }
        });

        component.set("v.isDeleteVisible", false);
        $A.enqueueAction(action);
    },

    exportCSVcaller: function(component){
        var artId = component.get("v.recordId");
        var action = component.get("c.exportCSV");
        action.setParams({
            'qId': artId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var toastevent = $A.get('e.force:showToast');
                toastevent.setParams({
                    'title'   : 'Success',
                    'type'    : 'Success',
                    'message' : 'Export download successfully.',
                    'mode'    : 'dismissible'
                });
                toastevent.fire();
                $A.get('e.force:refreshView').fire();
            }
            component.set("v.loader", false);
        });
        $A.enqueueAction(action);
    },

    sortData: function(cmp, fieldName, sortDirection) {
        var data = cmp.get("v.QliItems");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.QliItems", data);
    },

    sortBy: function(field, reverse) {
        var key = function(x) { return x[field]; };
        reverse = !reverse ? 1 : -1;
        return function(a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        };
    }
})