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

                    let temp_CurrencyIsoCode = null;

                    // ── Grand Total accumulators ──────────────────────────────────────────
                    let totalQuantity        = 0;  // items only (options excluded per spec)
                    let totalSalesPrice      = 0;  // item Sales_Price__c + option Total_Sales_Price__c

                    // NEW grand total accumulators mapped from QuoteLineController
                    let totalTP              = 0;  // item Total_Global_Price_Item__c + option Total_Transfer_Price__c
                    let totalListPrice2      = 0;  // item Total_List_Price2__c + option Total_List_Price__c
                    let totalDiscountValue   = 0;  // item Discount_Value__c + option Discount_Amount__c

                    let totalUnitTP = 0;
                    let totalUnitListPrice = 0;
                    let totalUnitSalesPrice = 0;

                    Wrapperdata.forEach(item => {
                        item.isSelected = false;
                        temp_CurrencyIsoCode = item.CurrencyIsoCode;

                        // ── Sub-Total accumulators for this line item ─────────────────────
                        let sub_TotalQuantity     = item.Quantity__c || 0; // item qty only
                        let sub_totalSalesPrice   = item.Sales_Price__c || 0;

                        // NEW sub-total fields
                        let sub_totalTP           = item.Total_Global_Price_Item__c || 0;
                        let sub_totalListPrice2   = item.Total_List_Price2__c || 0;
                        let sub_totalDiscountValue = item.Discount_Value__c || 0;

                        let sub_unitTP = item.Base_Price__c || 0;
                        let sub_unitListPrice = item.List_Price__c || 0;
                        let sub_unitSalesPrice = item.Average_Sales_Price__c || 0;


                        // ── Add child (option) values to sub-totals ───────────────────────
                        if (item.Quote_Line_Options__r && item.Quote_Line_Options__r.length > 0) {
                            item.Quote_Line_Options__r.forEach(qlo => {
                                qlo.isSelected = false;
                                qlo.vCheckId = item.Id + '-' + qlo.Id;

                                // NEW: option fields from QuoteLineController
                                sub_totalTP           += qlo.Total_Transfer_Price__c  || 0;
                                sub_totalListPrice2   += qlo.Total_List_Price__c       || 0; // option Total_List_Price__c
                                sub_totalDiscountValue += qlo.Discount_Amount__c       || 0; // option Discount_Amount__c
                                sub_totalSalesPrice   += qlo.Total_Sales_Price__c     || 0; // option Total_Sales_Price__c
                                // NOTE: option Qty is NOT added to sub_TotalQuantity (items only per spec)

                                sub_unitTP += qlo.Manual_Option_Base_Price__c || 0;
                                sub_unitListPrice += qlo.Manula_Option_List_Price__c || 0;
                                sub_unitSalesPrice += qlo.Unit_Sales_Price__c || 0;
                            });
                        }

                        // ── Store sub-total properties on the item object ─────────────────
                        item.sub_TotalQuantity__c      = parseFloat(sub_TotalQuantity);
                        item.sub_totalTP__c            = parseFloat(sub_totalTP).toFixed(2);
                        item.sub_totalListPrice2__c    = parseFloat(sub_totalListPrice2).toFixed(2);
                        item.sub_totalDiscountValue__c = parseFloat(sub_totalDiscountValue).toFixed(2);
                        item.sub_totalSalesPrice       = Math.round(parseFloat(sub_totalSalesPrice)).toFixed(0);
                        let subMargin = 0;

                        if (sub_totalSalesPrice !== 0) {

                            subMargin =
                                ((sub_totalSalesPrice - sub_totalTP)
                                /
                                sub_totalSalesPrice)
                                * 100;

                        }

                        item.subMargin = subMargin.toFixed(2);
                        item.isLineItem                = !!(item.Quote_Line_Options__r && item.Quote_Line_Options__r.length > 0);

                        item.sub_unitTP = parseFloat(sub_unitTP).toFixed(2);
                        item.sub_unitListPrice = parseFloat(sub_unitListPrice).toFixed(2);
                        item.sub_unitSalesPrice = parseFloat(sub_unitSalesPrice).toFixed(2);

                        // ── Accumulate into grand totals ──────────────────────────────────
                        totalQuantity      += sub_TotalQuantity;
                        totalTP            += sub_totalTP;
                        totalListPrice2    += sub_totalListPrice2;
                        totalDiscountValue += sub_totalDiscountValue;
                        totalSalesPrice    += parseFloat(item.sub_totalSalesPrice);

                        totalUnitTP += sub_unitTP;
                        totalUnitListPrice += sub_unitListPrice;
                        totalUnitSalesPrice += sub_unitSalesPrice;
                    });

                    // ── Set grand total component attributes ──────────────────────────────
                    component.set("v.totalQuantity",      parseFloat(totalQuantity));
                    component.set("v.totalTP",            parseFloat(totalTP).toFixed(2));
                    component.set("v.totalListPrice2",    parseFloat(totalListPrice2).toFixed(2));
                    component.set("v.totalDiscountValue", parseFloat(totalDiscountValue).toFixed(2));
                    component.set("v.totalSalesPrice",    parseFloat(totalSalesPrice).toFixed(2));
                    component.set("v.CurrencyIsoCode",    temp_CurrencyIsoCode);
                    component.set("v.totalUnitTP", totalUnitTP.toFixed(2));
                    component.set("v.totalUnitListPrice", totalUnitListPrice.toFixed(2));
                    component.set("v.totalUnitSalesPrice", totalUnitSalesPrice.toFixed(2));
                    let grandMargin = 0;

                    if (totalSalesPrice !== 0) {

                        grandMargin =
                            ((totalSalesPrice - totalTP)
                            /
                            totalSalesPrice)
                            * 100;

                    }

                    component.set("v.salesMargin", grandMargin.toFixed(2));
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
            var err   = response.getError();
            console.log('state===>>>' + state);
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
                console.log('List Sent Successfully');
            }
            component.set("v.loader", false);
        });
        $A.enqueueAction(action);
    },

    sortData: function(cmp, fieldName, sortDirection) {
        var data    = cmp.get("v.QliItems");
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