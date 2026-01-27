({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event){
        var recordId = component.get('v.recordId');
        var action = component.get("c.fetchProductWrapper");
        action.setParams
        ({  
            'Campaign'  :  recordId   
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                    component.set('v.listOfAllAccounts', oRes);
                    component.set('v.lstLeadWrapperForFilter', oRes);
                    console.log('oRes  '+JSON.stringify(oRes));
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllAccounts").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));    
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            
            else{
                alert('Error...');
            }
        });
        $A.enqueueAction(action);  
    },
    
    //---------------------------------------------------------------------------------------------------------------------------------------
    HandlerOnChangeHelper: function(component,event,helper){
        //  alert('rEaching');
        var checkCmp = event.getSource().get("v.value");

        var recordId = component.get('v.recordId');
        var exchangeRate = component.get("c.getContractDetails");
          var eRate = '';
          var subMargin = '';
          var contractMargin = '';
          var roundOfDigit = '';
          var m1 = '';
          var d1 = '';
          exchangeRate.setParams({  
            'RecId' : recordId
        });

        exchangeRate.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue(); 
                component.set("v.currencyCode",result.CurrencyIsoCode);
                eRate = result.Exchange_Rate__c;
                subMargin = result.Subsidiary__r.Additional_Margin__c; 
                contractMargin = result.Additinal_Margin__c;   
                roundOfDigit = result.Subsidiary__r.Rounding_Off_Digits__c;
                m1 = result.Subsidiary__r.M1__c;
                d1 = result.Subsidiary__r.D1__c;
            }else{  
                console.log('something bad happend! ');  
            }  
        });  
        // put the action into queue for server call.   
        $A.enqueueAction(exchangeRate);

        var action = component.get("c.WrapperproductFilter");

        action.setParams({ 
            'ProductId': checkCmp,
            'RecId':  recordId
        });
        // action.setParams({ 'ProductId': checkCmp});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS"){
                component.set("v.bNoRecordsFound" , false);
                var oRes = response.getReturnValue();
                component.set("v.UnfilteredData",oRes);  
                component.set("v.data",oRes); 
                console.log('oRes==> ',oRes);
                if(oRes.length > 0){
                     component.set('v.listOfAllAccounts', oRes);
                    component.set('v.lstLeadWrapperForFilter',oRes);
                    console.log('oRes  '+JSON.stringify(oRes));
                    console.log(response.getReturnValue());
                    var allValues = oRes;
                    console.log('data===!!!!>', allValues);
                    /*allValues.forEach(element => {
                        var tempUnitPrice = element.objLead.UnitPrice;
                        console.log('tempUnitPrice',tempUnitPrice);
                        console.log('subMargin',subMargin);
                        console.log('eRate', eRate);
                        console.log('contractMargin', contractMargin);
                    var priceInLCurrecncy= tempUnitPrice /eRate;
                    var ListPricetemp = priceInLCurrecncy * (1 / (subMargin * contractMargin));
                    var Lprice = ListPricetemp * (m1 / d1);
                    console.log('Converted Price -->',Lprice);
                    // var roundOfLprice = ((Math.round(Lprice / roundOfDigit ) * roundOfDigit)+parseInt(roundOfDigit));
                    var roundOfLprice = ((Math.ceil(Lprice / roundOfDigit ) * roundOfDigit));
                    element.objLead.UnitPrice=roundOfLprice;
                    });*/

                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllAccounts").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
                    
                    
                  //  component.set('v.PaginationList',oRes);
                  //  var DataList = JSON.stringify(oRes);
                    
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            } 
            else{
                alert('Error...');  
            }
        });
        
        $A.enqueueAction(action); 
        
        
    },
    doInitHelperUserDetail : function(component, event, helper){
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set('v.userInfo', storeResponse);
             }
            
            console.log('storeResponse : : '+JSON.stringify(storeResponse));
            //  var userDate = '';
            //  component.set("")
        });
        $A.enqueueAction(action);
    } , 
    
    
    //=====================================================================================================
    OnBluredhelper : function(component,event,helper){
        var UserData = component.get('v.userInfo');
        var ListData = component.get('v.PaginationList'); 
        console.log('ListData : : '+JSON.stringify(ListData));
        console.log('userInfo : : '+JSON.stringify(UserData));
        
        var UserLevel = UserData.Level__c;
        console.log('UserLevel : : '+UserLevel);
        var index = event.getSource().get('v.name');
        var IndexData = ListData[index];
        console.log('IndexData : : '+JSON.stringify(IndexData));
        var value = event.getSource().get('v.value');
        console.log('value'+value);
       // if(value < '23'){
        //    component.set("v.DiscountValue",false);
      //  }
        console.log('value'+value);
        var UnitPricedata = '';
        var BasePrice = '';
        if(UserLevel == 'L1'){
            UnitPricedata = IndexData.objLead.UnitPrice;
            BasePrice = IndexData.objLead.Base_Price__c;
            console.log('BasePrice::'+BasePrice); 
        }
         if(UserLevel == 'L2'){
            UnitPricedata = IndexData.objLead.List_Price_Level_2__c;
            BasePrice = IndexData.objLead.Base_Price__c;
            console.log('BasePrice::'+BasePrice); 
        }
         if(UserLevel == 'L3'){
            UnitPricedata = IndexData.objLead.List_Price_Level_3__c;
            BasePrice = IndexData.objLead.Base_Price__c;
            console.log('BasePrice::'+BasePrice); 
        }
        console.log('UnitPricedata : : '+UnitPricedata);
        console.log('BasePrice : : '+BasePrice);
        
        var AfterDiscount =UnitPricedata-(UnitPricedata*(value/100));
            console.log('AfterDiscount::'+AfterDiscount);
            if(AfterDiscount <= BasePrice){
                var toastevent = $A.get('e.force:showToast');
                toastevent.setParams({
                    'type' : 'error',
                    'message' : 'You Can No Enter This Value Of Discount Or just Enter The Reason'
                })
                toastevent.fire(); 
        
        
            }   
        
    },
    
    
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    
    FilterRecords: function(component) {  
        //data showing in table  
        var data = component.get("v.lstProductListWrapper");  
        // all data featched from apex when component loaded  
        var allData = component.get("v.UnfilteredData");  
        //Search tems  
        var searchKey = component.get("v.filter");  
        // check is data is not undefined and its lenght is greater than 0  
        if(data != undefined && data.length>0){  
            // filter method create a new array tha pass the test (provided as function)  
            var filtereddata = allData.filter(word => (!searchKey) || word.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);  
            console.log('** '+filtereddata);  
        }  
        // set new filtered array value to data showing in the table.  
        component.set("v.data", filtereddata);  
        // check if searchKey is blank  
        if(searchKey==''){  
            // set unfiltered data to data in the table.  
            component.set("v.data",component.get("v.UnfilteredData"));  
        }  
    },
    
    
    
    handleFieldFiler : function(component, event, helper)
    {
        var textToFilter = component.get('v.textToFilter');
        console.log('textToFilter : '+textToFilter);   
        var selectedField = component.get('v.selectedField');
        console.log('selectedField   : '+selectedField);
        var listOfAllAccounts = component.get('v.listOfAllAccounts');
        
        var lstFilterRecord = listOfAllAccounts.filter((eachWrapRecord) => {
            if(eachWrapRecord.objLead[selectedField] == textToFilter )
            return eachWrapRecord;
            
        });
        
        console.log('lstFilterRecord  '+JSON.stringify(lstFilterRecord));
        
        
        component.set('v.PaginationList',lstFilterRecord);        
        
    },
    
    addAccountRecord: function(component, event) {
        //get the account List from component  
        var OptionList = component.get("v.OptionList");
        var recordId = component.get('v.recordId');
        var checkCmp =   component.find("PicklistId").get("v.value");
        //Add New Account Record
        OptionList.push({
            'sobjectType': 'Contract_Line_Option__c',
            'Manual_Product_Name_c__c': '',
            'Manual_Option_List_Price__c': '',
            'Manual_Option_Base_Price__c': '',
            'Price_Type__c': '1',
            'Discount__c': '',
            'Mould_Cavity__c': '',
            'Quantity__c': '1',
            'ContractId__c' : recordId,
            'Contract_Line_Item__c' : checkCmp,
            'Select_Option__c': true,
            'Discount_Description__c':'',
        });
        component.set("v.OptionList", OptionList);
    },
    
    validateAccountList: function(component, event) {
     //   alert('Reached ..... Validated.....');
        //Validate all account records
        var isValid = true;
        var OptionList = component.get("v.OptionList");
        for (var i = 0; i < OptionList.length; i++) {
            if (OptionList[i].Name == '') {
                isValid = false;
                alert('Account Name cannot be blank on row number ' + (i + 1));
            }
        }
        return isValid;
    },
    
    saveAccountList: function(component, event, helper) {
     //    alert('Reached ..... Saving UnderWork.....');
        //Call Apex class and pass account list parameters
        var action = component.get("c.SaveOptions");
      //   alert('Reached ..... Saving .....');
        action.setParams({
            "OptList": component.get("v.OptionList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.OptionList", []);
                alert('Option Saved Successfully.');
            }
        }); 
        $A.enqueueAction(action);
    },

    FilterOptionRecords: function(component) {  
        //data showing in table  
        console.log('Inside FilterRecords');
        var data = component.get("v.data");  
     // all data featched from apex when component loaded  
     var allData = component.get("v.UnfilteredData");  
       console.log('allData ==>>' + JSON.stringify(allData));
     //Search tems  
     var searchKey = component.get("v.Optionfilter"); 
       console.log('searchKey ===>>> ' + searchKey);
     // check is data is not undefined and its lenght is greater than 0  
     if(data!=undefined || data.length>0){  
         console.log('in if condition');
       // filter method create a new array tha pass the test (provided as function)  
       var filtereddata = allData.filter(word => (!searchKey) || word.objLead.Product2.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
        // var filtereddata2 = allData.filter(word => (!searchKey) || word.Product2.Product_Type__c.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
       console.log('** '+JSON.stringify(filtereddata));  
     }  
     // set new filtered array value to data showing in the table.  
     component.set("v.data", filtereddata); 
     component.set("v.PaginationList", filtereddata);
       //component.set("v.data", filtereddata2); 
     // check if searchKey is blank  
     if(searchKey==''){  
       // set unfiltered data to data in the table.  
       component.set("v.data",component.get("v.UnfilteredData"));  
     }  
    },
    
    
    /*   handlerCheckBoxFiletr:function(component,event,helper){
        console.log('Reached 1');
        var checkCmp = component.find("checkbox1");
        console.log("value : " + checkCmp.get("v.value")) 
        var checkCmp1 = component.find("checkbox2");
        console.log("value : " + checkCmp1.get("v.value"))
        var checkCmp2 = component.find("checkbox3");
        console.log("value : " + checkCmp2.get("v.value"))
        var checkCmp2 = component.find("checkbox4");
        console.log("value : " + checkCmp3.get("v.value"))
        
        var ListWhereClause ='';
        console.log('ListWhereClause111'+ListWhereClause);
        if(checkCmp = true){
            console.log('Reached 2');
            var myEle1 = component.get("v.myAttribute");
            console.log(myEle1);
            
        }
        if(checkCmp1 = true){
            console.log('Reached 2');
            var myEle2 = component.get("v.myAttribute1");
            console.log(myEle2);
            
        }
        if(checkCmp2 = true){
            console.log('Reached 2');
            var myEle3 = component.get("v.myAttribute2");
            console.log(myEle3);
            
        }
        if(checkCmp3 = true){
            console.log('Reached 2');
            var myEle3 = component.get("v.myAttribute2");
            console.log(myEle3);
            
        }
        
        console.log('#####KB#####'+myEle1+'   '+myEle2+'    '+myEle3);
        
        var action = component.get("c.WrapperFilter");
        
        action.setParams({ 'FirstName': myEle1,
                          'Family' :myEle2 ,
                          'Code' :myEle3,
                          
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                    // component.set('v.listOfAllAccounts', oRes);
                    component.set('v.lstLeadWrapperForFilter',oRes);
                    console.log('oRes  '+JSON.stringify(oRes));
                    console.log(response.getReturnValue());
                    console.log('oRes  '+JSON.stringify(oRes));
                    
                    
                    component.set('v.PaginationList',oRes);
                }
            }
            else{
                alert('Error...');  
            }
        });
        
        $A.enqueueAction(action); 
        
        
    },
        
        handleClearFiler : function(component, event, helper)
{
    var listOfAllAccounts = component.get('v.listOfAllAccounts');
    component.set('v.PaginationList',listOfAllAccounts);
    var pageSize = component.get("v.pageSize");
    var totalRecordsList = oRes;
    var totalLength = totalRecordsList.length ;
    component.set("v.totalRecordsCount", totalLength);
    component.set("v.startPage",0);
    component.set("v.endPage",pageSize-1);
    
    var PaginationLst = [];
    for(var i=0; i < pageSize; i++){
        if(component.get("v.listOfAllAccounts").length > i){
            PaginationLst.push(oRes[i]);    
        } 
    }
    component.set('v.PaginationList', PaginationLst);
    component.set("v.selectedCount" , 0);
    //use Math.ceil() to Round a number upward to its nearest integer
    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
} */
})