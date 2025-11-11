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
            let salesMargin = parseFloat(Wrapperdata.Sales_Margin__c).toFixed(2) || 0;
            component.set("v.salesMargin",salesMargin);   
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

                    let  totalBasicPrice = 0;
                    let  totalListPrice = 0;
                    let totalQuantity = 0;
                    let totalAvgDiscount = 0;
                    let totalFinalSales = 0;
                    let totalSalesPrice = 0;
                    let discount_total = 0;

                Wrapperdata.forEach(item => {
                    item.isSelected = false;
                    temp_CurrencyIsoCode = item.CurrencyIsoCode;
                    let sub_totalBasicPrice = 0;
                     let sub_totalListPrice = 0;
                    let sub_totalQuantity = 0;
                    let sub_totalAvgDiscount = 0;
                    let sub_totalFinalSales = 0;
                    let sub_totalSalesPrice = 0;
                    let discount_total = 0;
                    let subMargin = 0;

                    // Parent level subtotal calculation
                    //if (item.isDTA) {
                        sub_totalBasicPrice += item.Base_Price__c || 0;
                    //} else {
                        sub_totalListPrice += item.List_Price__c || 0;
                    //}

                    sub_totalQuantity += item.Quantity__c || 0;
                    sub_totalAvgDiscount += item.Average_Discount_Value__c || 0;
                    sub_totalFinalSales += item.Average_Sales_Price__c || 0;
                    sub_totalSalesPrice += item.Sales_Price__c || 0;
                    discount_total += item.Discount_in_Value_Percent__c || 0;
                    subMargin = item.Sales_Margin_including_Options__c || 0;

                    // Add to grand total
                                    
                    // Child level subtotal calculation
                    if (item.Quote_Line_Options__r && item.Quote_Line_Options__r.length > 0) {
                        item.Quote_Line_Options__r.forEach(qlo => {
                    qlo.isSelected = false;
                    qlo.vCheckId = item.Id+'-'+qlo.Id;
                            sub_totalBasicPrice +=  qlo.Manual_Option_Base_Price__c || 0;
                            sub_totalListPrice += qlo.Manula_Option_List_Price__c || 0;// qlo.Manula_Option_List_Price__c || 0;
                            //sub_totalQuantity += qlo.Quantity__c || 0;
                            sub_totalAvgDiscount += qlo.Average_Discount_Value__c || 0;
                            sub_totalFinalSales += qlo.Final_Sales_Price__c || 0;
                            sub_totalSalesPrice += qlo.Sales_Price__c || 0;
                            discount_total += qlo.Discount_in_Value_Percent__c || 0;
                        });
                    }

                    // Store subtotals with fixed decimals
                    item.sub_TotalBasicPrice__c = parseFloat(sub_totalBasicPrice).toFixed(2);
                    item.sub_totalListPrice__c = parseFloat(sub_totalListPrice).toFixed(2);
                    item.sub_TotalQuantity__c = parseFloat(sub_totalQuantity);
                    item.sub_TotalAvgDiscount__c = parseFloat(sub_totalAvgDiscount).toFixed(2);
                    item.sub_TotalFinalSales__c = parseFloat(sub_totalFinalSales).toFixed(2);
                    item.sub_totalSalesPrice = parseFloat(sub_totalSalesPrice).toFixed(2);
                    item.discount_total__c = parseFloat(discount_total).toFixed(2);
                    item.isLineItem = !!(item.Quote_Line_Options__r && item.Quote_Line_Options__r.length > 0);
                    item.subMargin = parseFloat(subMargin).toFixed(2);
                    totalBasicPrice += sub_totalBasicPrice;
                    totalListPrice += sub_totalListPrice;
                    totalQuantity += sub_totalQuantity;
                    totalAvgDiscount += sub_totalAvgDiscount;
                    totalFinalSales += sub_totalFinalSales;
                    totalSalesPrice += sub_totalSalesPrice;

                });
                    component.set("v.totalBasicPrice", parseFloat(totalBasicPrice).toFixed(2));
                    component.set("v.totalListPrice", parseFloat(totalListPrice).toFixed(2));
                    component.set("v.totalQuantity", parseFloat(totalQuantity));
                    component.set("v.totalAvgDiscount", parseFloat(totalAvgDiscount).toFixed(2));
                    component.set("v.totalFinalSales", parseFloat(totalFinalSales).toFixed(2));
                    component.set("v.totalSalesPrice", parseFloat(totalSalesPrice).toFixed(2));
                    component.set("v.CurrencyIsoCode", temp_CurrencyIsoCode);
                    
                    component.set("v.QliItems", Wrapperdata);
                    console.log('All data-->',JSON.stringify(Wrapperdata));
                this.sortData(component, 'Sr_No__c', 'asc');

            } else {
                component.set("v.LineItemPresent", false);
                component.set("v.LineItemNotPresent", true);
            }
        } else {
            console.error('Error in FetchdataWrapper:', response.getError());
        }
    });

                    component.set("v.isDeleteVisible",false);   
    $A.enqueueAction(action);
}
,
    
    exportCSVcaller: function(component){
        var artId = component.get("v.recordId");
        var lineLIst = component.get("v.QliItems");
        console.log('JOSN-->'+JSON.stringify(lineLIst));
        var action = component.get("c.exportCSV");
        action.setParams({
            'qId':artId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var err = response.getError();
            //console.log('err==> ',err[0].message);
            console.log('state===>>>' + state);
            if(state == 'SUCCESS')
            {
                var toastevent = $A.get('e.force:showToast');
                toastevent.setParams({
                    'title' : 'Success',
                    'type' : 'Success',
                    'message' : 'Export download successfully.',
                    'mode' : 'dismissible'
                })
                toastevent.fire();
                $A.get('e.force:refreshView').fire();
                console.log('List Sent Successfully');
            }
            component.set("v.loader",false);
        });
        $A.enqueueAction(action);
    }
,
    sortData: function (cmp, fieldName, sortDirection) {
        var fname = fieldName;
        var data = cmp.get("v.QliItems");
        var reverse = sortDirection !== 'asc';
        
        data.sort(this.sortBy(fieldName, reverse));
        
        cmp.set("v.QliItems", data);
        /*if(reverse){
            component.set("v.up", false);
            component.set("v.down", true);
        }else if(!reverse){
            component.set("v.up", true);
            component.set("v.down", false);
        }*/
       //this.setPaginateData(cmp);
   },
       
       sortBy: function (field, reverse) {
           var key = function(x) {return x[field]};
           console.log('reverse',reverse);
           reverse = !reverse ? 1 : -1;
           
           return function (a, b) {
               return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
           }
       },
})