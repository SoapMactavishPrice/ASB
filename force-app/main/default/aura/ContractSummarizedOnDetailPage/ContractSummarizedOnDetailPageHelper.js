({
     getDetail : function(component){
        var artId = component.get("v.recordId");
        var action = component.get("c.getContractDetail");
        action.setParams({
            'ContractID':artId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var Wrapperdata = response.getReturnValue();
            console.log('Wrapperdata',JSON.stringify(Wrapperdata));
           	
            let salesMargin = parseFloat(Wrapperdata.Sales_Margin_Percent__c).toFixed(2) || 0;
            component.set("v.salesMargin",salesMargin);   
            if (Wrapperdata.Is_DTA_Contract__c){
                 component.set("v.isDTA",true);   
            }else{
                component.set("v.isDTA",false);   
            }
        });
        $A.enqueueAction(action);
    },
    
	initMethod : function(component) {
        var artId = component.get("v.recordId");
        // alert('Record Id'+artId);
        var action = component.get("c.FetchdataWrapper");
        action.setParams({
            'ContractID':artId,
            'orderby':'asc'
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            // alert(state);
            var ixe = 0;
            var Wrapperdata = response.getReturnValue();
            console.log('KB : : '+JSON.stringify(Wrapperdata));
           /* for(var i = 0; i< Wrapperdata.length;i++){
                Wrapperdata[i].uriString = 'https://nisseiasb--buat.sandbox.lightning.force.com/lightning/r/Quote_Line_Item_Custom__c/'+Wrapperdata[i].Id+'/view';
                
                if(Wrapperdata[0].Quote_Line_Options__r.length > 0) {
                    console.log('counter ',ixe++);
                    var temp = Wrapperdata[0].Quote_Line_Options__r;
                    for(var j = 0; j<temp.length;j++){
                        console.log('Average Discount',temp[i].Average_Discount_Value__c+'   sales Price'+temp[i].Average_Sales_Price__c+' margin'+temp[i].Average_Sales_Margin__c);
}
                }
               
               
            }*/
            if (state == "SUCCESS"){
                if(Wrapperdata != null && Wrapperdata.length>0 && Wrapperdata != undefined){
                    component.set("v.LineItemPresent",true);
                    component.set("v.LineItemNotPresent",false);  
                    
                                    
                let temp_CurrencyIsoCode = null;

                    let  totalBasicPrice = 0;
                    let  totalListPrice = 0;
                    let totalQuantity = 0;
                    let totalAvgDiscount = 0;
                    let totalFinalSales = 0;
                    let totalSalesPrice = 0;
                    let discount_total = 0;
                    let subMargin = 0;
                    
                    
                    Wrapperdata.forEach(item => {
                    temp_CurrencyIsoCode = item.CurrencyIsoCode;
                    let sub_totalBasicPrice = 0;
                        let sub_totalListPrice = 0;
                    let sub_totalQuantity = 0;
                    let sub_totalAvgDiscount = 0;
                    let sub_totalFinalSales = 0;
                    let sub_totalSalesPrice = 0;
                    let discount_total = 0;

                    // Parent Line Item values
                    sub_totalBasicPrice += item.Base_Price_Line_Item__c || 0;
                       sub_totalListPrice +=item.List_Price__c || 0;
                    sub_totalQuantity += item.Quantity__c || 0;
                    sub_totalAvgDiscount += item.Average_Discount_Value__c || 0;
                    sub_totalFinalSales += item.Average_Sales_Price__c || 0;
                    sub_totalSalesPrice += item.Total_Sales_Price2__c || 0;
                    discount_total += item.Discount_in_Value_Percent__c || 0;
					subMargin = item.Sales_Margin_including_Options__c || 0;
                        
                    // Child Option Values
                    if (item.Contract_Line_Option__r && item.Contract_Line_Option__r.length > 0) {
                        item.Contract_Line_Option__r.forEach(qlo => {
                            sub_totalBasicPrice += qlo.Manual_Option_Base_Price__c || 0 ;//: (item.List_Price__c || 0);
                             sub_totalListPrice += qlo.Manual_Option_List_Price__c || 0; //  qlo.Manula_Option_List_Price__c || 0;
                            //sub_totalQuantity += qlo.Quantity__c || 0;
                            sub_totalAvgDiscount += qlo.Average_Discount_Value__c || 0;
                            sub_totalFinalSales += qlo.Average_Sales_Price__c || 0;
                            sub_totalSalesPrice += qlo.Final_Sales_Price__c || 0;
                            discount_total += qlo.Discount_in_Value_Percent__c || 0;
                        });
                    }

                    // Save subtotal (fixed to 2 decimal places) to each item
                    item.sub_TotalBasicPrice__c = parseFloat(sub_totalBasicPrice).toFixed(2);
                    item.sub_totalListPrice__c = parseFloat(sub_totalListPrice).toFixed(2);
                    item.sub_TotalQuantity__c = parseFloat(sub_totalQuantity); 
                    item.sub_TotalAvgDiscount__c = parseFloat(sub_totalAvgDiscount).toFixed(2);
                    item.sub_TotalFinalSales__c = parseFloat(sub_totalFinalSales).toFixed(2);
                    item.sub_totalSalesPrice = parseFloat(sub_totalSalesPrice).toFixed(2);
                    item.discount_total__c = parseFloat(discount_total).toFixed(2);
                    item.isLineItem = !!(item.Contract_Line_Option__r && item.Contract_Line_Option__r.length > 0);
					item.subMargin = parseFloat(subMargin).toFixed(2);
                        
                    // Add to grand totals
                    totalBasicPrice += sub_totalBasicPrice;
                    totalListPrice += sub_totalListPrice;
                    totalQuantity += sub_totalQuantity;
                    totalAvgDiscount += sub_totalAvgDiscount;
                    totalFinalSales += sub_totalFinalSales;
                    totalSalesPrice += sub_totalSalesPrice;
                });

                // ✅ Set Grand Totals in Component
                component.set("v.totalBasicPrice", parseFloat(totalBasicPrice).toFixed(2));
                component.set("v.totalListPrice", parseFloat(totalListPrice).toFixed(2));
                component.set("v.totalQuantity", totalQuantity);
                component.set("v.totalAvgDiscount", parseFloat(totalAvgDiscount).toFixed(2));
                component.set("v.totalFinalSales", parseFloat(totalFinalSales).toFixed(2));
                component.set("v.totalSalesPrice", parseFloat(totalSalesPrice).toFixed(2));
                component.set("v.CurrencyIsoCode", temp_CurrencyIsoCode);

            
            
                    component.set("v.QliItems",Wrapperdata); 
                    this.sortData(component, 'Sr_No__c', 'asc');
                }else{
                    component.set("v.LineItemPresent",false);
                    component.set("v.LineItemNotPresent",true);   
                }
            }else{
                console.log('KB error : : ');  
            }
        });
        $A.enqueueAction(action);
	},
    
    exportCSVcaller: function(component){
        var artId = component.get("v.recordId");
        var lineLIst = component.get("v.QliItems");
        console.log('JOSN-->'+JSON.stringify(lineLIst));
        var action = component.get("c.exportCSV");
        action.setParams({
            'cId':artId
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