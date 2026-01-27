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
                    for(var i = 0; i< oRes.length; ){
                        oRes[i].index = i;
                        i++;
                     }
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
        console.log('value',checkCmp);
         
          var recordId = component.get('v.recordId');
          var exchangeRate = component.get("c.getQuotationDetails");
          var eRate = '';
          var subMargin = '';
          var quoteMargin = '';
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
                quoteMargin = result.Additinal_Margin__c;   
                roundOfDigit = result.Subsidiary__r.Rounding_Off_Digits__c;
                m1 = result.Subsidiary__r.M1__c;
                d1 = result.Subsidiary__r.D1__c;
            }else{  
                console.log('something bad happend! ');  
            }  
        });  
        // put the action into queue for server call.   
        $A.enqueueAction(exchangeRate);

		console.log('recId',recordId);
        var action = component.get("c.WrapperproductFilter");
        action.setParams({ 
            'ProductId': checkCmp, 
            'RecId':  recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS"){
                component.set("v.bNoRecordsFound" , false);
                var oRes = response.getReturnValue();
                component.set("v.UnfilteredData",oRes);  
                component.set("v.data",oRes); 
                if(oRes.length > 0){
                    
                    for(var i = 0; i< oRes.length; ){
                        oRes[i].index = i;
                        i++;
                     }
					console.log('all Values are',JSON.stringify(oRes));
                    component.set('v.listOfAllAccounts', oRes);
                    component.set('v.lstLeadWrapperForFilter',oRes);
                    var allValues = oRes;
                    //console.log('data===!!!!>', allValues);
                    /*allValues.forEach(element => {
                        var tempUnitPrice = element.objLead.UnitPrice;
                        console.log('tempUnitPrice',tempUnitPrice);
                        console.log('subMargin',subMargin);
                        console.log('eRate', eRate);
                        console.log('quoteMargin', quoteMargin);
                    var priceInLCurrecncy= tempUnitPrice/eRate;
                    var ListPricetemp = priceInLCurrecncy * (1 / (subMargin * quoteMargin));
                    var Lprice = ListPricetemp * (m1 / d1);
                    console.log('Converted Price -->',Lprice);
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
                    //console.log('PaginationLst==> ',PaginationLst);

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
        console.log('id value of product : :  : ' + IndexData.objLead.Product2Id);
        window.arrProdId = [];
        //localStorage.setItem(IndexData.objLead.Product2Id, IndexData.objLead.Product2Id);
        arrProdId.push(IndexData.objLead.Product2Id);
       
        //console.log('localStorage >>>>>>>> ' + localStorage);
        var value = event.getSource().get('v.value');
        console.log('value'+value);
       // if(value < '23'){
        //    component.set("v.DiscountValue",false);
      //  }
        var UnitPricedata = '';
        window.BasePrice = '';
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
        //component.set("v.discountDescription", False);
        
        //var inputCmpo = component.find("inputCmpUnique");
        //inputCmp = Array.isArray(inputCmp) ? inputCmp[0].get("v.value") : inputCmp.get("v.value");
        //var value2 = inputCmpo.get("v.name");
        //console.log('value --->>>> ' + value2);
        //if (value2) {
           // inputCmp.set("v.errors", [{message:"Input not a number: " + value2}]);
       // }
        
        //-----------------------------------------------
        
        window.AfterDiscount =UnitPricedata-(UnitPricedata*(value/100));
            console.log('AfterDiscount::'+AfterDiscount);
        var x = IndexData.objLead.check;
            if(AfterDiscount <= BasePrice){
                try{
                    x = 'True';
                    console.log('IndexData.objLead.check ===>>> ' + IndexData.objLead.check);
                 var inputCmpo = component.find("CBid");
                    //inputCmpo = Array.isArray(inputCmpo) ? inputCmpo[0].get("v.value") : inputCmpo.get("v.value");
                   //inputCmpo.set("v.checked", "true"); 
                 console.log('inputCmpo ===>>> '+ inputCmpo);
                //var x = document.getElementById("inputCmpUnique").required = true; 
                //inputCmpo.set("v.errors", [{message:"fied is req...!!"}]);
                //component.set("v.discountDescription", "True");
                alert('Please fill up the decription for more discount');
                var toastevent = $A.get('e.force:showToast');
                toastevent.setParams({
                    'type' : 'error',
                    'message' : 'You Can Not Enter This Value Of Discount Or just Enter The Reason'
                })
                //toastevent.fire(); 
                }catch(ex){
                    console.log(ex);
                }
        
        
            }   
        
    },
    
    fun : function(component,event,helper){
        var x = document.getElementById("inputCmpUnique").required; 
        console.log(number);
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
        //component.set("v.totalPagesCount", Math.ceil(sObjectList.length / pageSize));
            //component.set("v.currentPage", 1);
        //component.set("v.totalRecordsCount", sObjectList.length);
        //component.set("v.endPage", Math.ceil(sObjectList.length / pageSize));
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
        console.log('Inside FilterRecords');
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
    
    
    FilterOptionRecords: function(component) {  
        //data showing in table  
     console.log('Inside FilterRecords');
     var data = component.get("v.data");  
     var allData = component.get("v.UnfilteredData");  
       console.log('allData ==>>' + JSON.stringify(allData));
     var searchKey = component.get("v.Optionfilter"); 
       console.log('searchKey ===>>> ' + searchKey);
     if(data!=undefined || data.length>0){  
         console.log('in if condition');
       //var filtereddata = allData.filter(word => (!searchKey) || word.objLead.Product2.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 */|| word.objLead.Product2.ProductCode.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 ||  word.objLead.Product2.Description.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
        //var filtereddata = data.filter(word => (!searchKey) || word.objLead.Product2.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 || word.objLead.Product2.ProductCode.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 || word.objLead.Product2.Description.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
        // var filtereddata2 = allData.filter(word => (!searchKey) || word.Product2.Product_Type__c.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
       var filtereddata = allData.filter(word => (!searchKey) || word.objLead.Product2.Name.toLowerCase().includes(searchKey.toLowerCase()) || word.objLead.Product2.ProductCode.toLowerCase().includes(searchKey.toLowerCase()) || word.objLead.Product2.Description.toLowerCase().includes(searchKey.toLowerCase()));

         
         console.log('**--> '+filtereddata.length);  
     }  
     // set new filtered array value to data showing in the table. 
     component.set("v.data", []);  
     component.set("v.data", filtereddata); 
     //component.set("v.PaginationList", filtereddata);
     var pageSize = component.get("v.pageSize");
        if(filtereddata.length == 0){
            component.set("v.currentPage", 0);
            component.set("v.totalPagesCount", (Math.ceil(filtereddata.length / pageSize))-1);
            component.set("v.totalRecordsCount", filtereddata.length);
            //component.set("v.endPage", Math.ceil(filtereddata.length / pageSize)); 
            
        } else{
            var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(filtereddata.length > i){
                            PaginationLst.push(filtereddata[i]);    
                       } 
              }
            component.set('v.PaginationList', PaginationLst);
            console.log('math--> ',filtereddata.length / pageSize);
            console.log('math ceil--> ',(Math.ceil(filtereddata.length / pageSize)));
            component.set("v.totalPagesCount", Math.ceil(filtereddata.length / pageSize));
            component.set("v.currentPage", 1);
            component.set("v.totalRecordsCount", filtereddata.length);
            //component.set("v.endPage", Math.ceil(filtereddata.length / pageSize)); 
        }
      
     
     //this.navigation1(component, event);
       //component.set("v.data", filtereddata2); 
     // check if searchKey is blank  
     if(searchKey==''){  
       // set unfiltered data to data in the table. 
       let tempData = component.get("v.UnfilteredData"); 
       var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(tempData.length > i){
                            PaginationLst.push(tempData[i]);    
                       } 
              }
         component.set("v.PaginationList",PaginationLst);  
         component.set("v.totalPagesCount", Math.ceil(tempData.length / pageSize));
         component.set("v.currentPage", 1);
         component.set("v.totalRecordsCount", tempData.length);
         component.set("v.data",component.get("v.UnfilteredData"));  
     }  
    },
    
    /* javaScript function for pagination */
    navigation1: function(component, event) {
        console.log('inside navigation');
        var sObjectList = component.get("v.PaginationList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        console.log('-->',Math.ceil(sObjectList.length / pageSize));
        
        
        component.set("v.endPage", Math.ceil(sObjectList.length / pageSize)); 
        /*if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            this.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            this.previous(component, event, sObjectList, end, start, pageSize);
        }*/
    },
    
    // serial number
    SelectedRecords:function(component,index){
    var fdata = component.get("v.PaginationList");
    var temp = component.get("v.tempSerialNumber");
    var staticLargerNumber = component.get("v.StatictempSerialNumber");
        if(fdata[index].isChecked){
            fdata[index].serialNumber=temp+10;
            console.log('current value',fdata[index].serialNumber);
			for(var i = 0; i< fdata.length; ){
                if(fdata[i].index > index && fdata[i].serialNumber > 0){
                    //fdata[i].serial_no= fdata[i].serial_no +10;
                }
                
                if(fdata[i].serialNumber > temp){
                    temp = fdata[i].serialNumber;
                }
                i++;
            }
            console.log('larger value is',temp);
            component.set("v.tempSerialNumber",temp);
        } if(!fdata[index].isChecked && fdata[index].serialNumber > 0 && fdata[index].serialNumber >  staticLargerNumber) {
            
            var run_num =  fdata[index].serialNumber;
            fdata[index].serial_no = 0;
            for(var i = 0; i< fdata.length;){
                 if(fdata[i].serialNumber > run_num){
                        fdata[i].serialNumber= fdata[i].serialNumber - 10;
                }
                i++;
            }
            component.set("v.tempSerialNumber",temp-10); 
        }
        component.set("v.PaginationList",fdata);
        //helper.handleFieldFiler(component,event,helper);
    
    
},
    
    // serial number
    SelectedRecordstoAll:function(component){
    var fdata = component.get("v.listOfAllAccounts");
    var temp = component.get("v.tempSerialNumber");
    console.log('serial number',tempSerialNumber);
    var staticLargerNumber = component.get("v.StatictempSerialNumber");
            for(var i = 0; i< fdata.length;){
                fdata[i].serialNumber=  temp+10;
                console.log('serial number '+i+'is'+fdata[i].serialNumber);
                if(fdata[i].serialNumber > temp){
                    temp = fdata[i].serialNumber;
                }
                i++;
         }
            
        component.set("v.tempSerialNumber",temp); 
        //component.set("v.listOfAllAccounts",fdata);
        //helper.handleFieldFiler(component,event,helper);
    
    
},
    
    handleFieldFiler : function(component, event, helper)
    {
        console.log('menthod call from Serial number');
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
        console.log('OptionList ===>>>' + JSON.stringify(OptionList));
        var recordId = component.get('v.recordId');
        var checkCmp =   component.find("PicklistId").get("v.value");
        //Add New Account Record
        OptionList.push({
            'sobjectType': 'Quote_Line_Options__c',
            'Manual_Product_Name__c': '',
            'Manula_Option_List_Price__c': '0',
            'Manual_Option_Base_Price__c': '0',
            'Price_Type__c': 1,
            'Discount__c': '0',
            'Mould_Cavity__c': '',
            'Quantity__c': 1,
            'Quote__c' : recordId,
            'Quote_Line_Item_Custom__c' : checkCmp,
            'Product_Type__c' :'',
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
    
   /* saveAccountList: function(component, event, helper) {
        console.log('call to save manul button',JSON.stringify(component.get("v.OptionList")));
        let varOptiponList = component.get("v.OptionList");
        console.log('call to save manul length-->',varOptiponList.length);
        let checkList = 0
        
         if(varOptiponList[i].Product_Type__c =='' || varOptiponList[i].Product_Type__c ==null|| varOptiponList[i].Product_Type__c ==undefined){
                checkList++;
             console.log('checkList-->',checkList);
                var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'title': 'error',
                        'type': 'error',
                        'message': 'Please Fill Product Type',
                        'mode': 'dismissible'
                    })
                    toastevent.fire();
                    //component.set("v.SaveHitManual", true);
                //component.set("v.loader", false);
            }

        window.setTimeout(
    $A.getCallback(function() {
		if(checkList ==0) {       
        var recordId = component.get('v.recordId');
        var action = component.get("c.SaveOptions");

        action.setParams({
            "recordId":recordId,
            "OptList": component.get("v.OptionList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.OptionList", []);
                console.log(' --------------------------------------->>>>>>>>  IN SUCCESS   <<<<<<<<<-----------------------------------');
                //alert('Account records saved successfully in it');
            }
        }); 
        $A.enqueueAction(action);
        }
          }), 
    1500 // Delay in milliseconds (e.g., 3000 = 3 seconds)
);
    },*/
    
    
    saveAccountList: function(component, event, helper) {
    let varOptionList = component.get("v.OptionList");
    console.log('Call to save manual button. Option list:', JSON.stringify(varOptionList));
    console.log('Option list length:', varOptionList.length);

    let checkList = 0;

    // Validation: Check if any Product_Type__c is missing
    for (let i = 0; i < varOptionList.length; i++) {
        let item = varOptionList[i];

        if (!item.Product_Type__c || item.Product_Type__c.trim() === '') {
            checkList++;
            console.warn('Missing Product_Type__c at index', i);

            // Show toast once and break loop
            let toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({
                'title': 'Error',
                'type': 'error',
                'message': 'Please fill in Product Type for all items.',
                'mode': 'dismissible'
            });
            toastEvent.fire();
            break; // Exit loop after first error
        }
    }

    // If all validations pass, save after 1.5 sec delay
    window.setTimeout(
        $A.getCallback(function() {
            if (checkList === 0) {
                let recordId = component.get('v.recordId');
                let action = component.get("c.SaveOptions");

                action.setParams({
                    "recordId": recordId,
                    "OptList": varOptionList
                });

                action.setCallback(this, function(response) {
                    let state = response.getState();
                    if (state === "SUCCESS") {
                        console.log('Save successful.');
                        component.set("v.OptionList", []);
                        // Optionally show success toast
                        let toastEvent = $A.get('e.force:showToast');
                        toastEvent.setParams({
                            'title': 'Success',
                            'type': 'success',
                            'message': 'Options saved successfully.',
                            'mode': 'dismissible'
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    $A.get('e.force:closeQuickAction').fire();
                    } else {
                        console.error('Save failed:', response.getError());
                    }
                });

                $A.enqueueAction(action);
            }
        }),
        1500 // 1.5 seconds delay
    );
}
,
    
    
    
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
        
        
    },*/
        
        /*handleClearFiler : function(component, event, helper)
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