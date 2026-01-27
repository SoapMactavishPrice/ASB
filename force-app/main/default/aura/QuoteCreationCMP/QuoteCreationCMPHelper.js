({
    // helper for setting up the component at init
    doInit: function (component) {
        // $A.get("e.force:closeQuickAction").fire();
        var artId = component.get("v.recordId");
        var action = component.get("c.IntialDataFetch");
        action.setParams({
            'RecId': artId
        });
          action.setCallback(this, function (response) {
            var state = response.getState();
            var Wrapdata = response.getReturnValue();
            console.log('response : : ' + response.getReturnValue());
            console.log('KB : : ' + JSON.stringify(Wrapdata));
            //console.log('get Data' + Wrapperdata.cRate);
            //console.log('Conversion Error Is ' + Wrapperdata.Error);
            //console.log('Conversion Data Is ' + Wrapperdata.data);
            //console.log('checkPermission ', Wrapdata.data.checkPermission);
            
            //component.set("v.AllowQuoteToCreate", Wrapperdata.data.checkPermission);
            
            if(Wrapdata.Error !=null){
                $A.get("e.force:closeQuickAction").fire();
                console.log('Contact Error');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": Wrapdata.Error,
                });
                toastEvent.fire();
            }
            else if(Wrapdata.data.checkPermission ==  false){
                $A.get("e.force:closeQuickAction").fire();
                console.log('KB error : : ');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": 'You are not allowed to create Quotation in this region.'
                });
                toastEvent.fire();
            }
            else{
               var temp = Wrapdata.data;
                console.log('else ',temp.checkPermission);
				component.set("v.AllowQuoteToCreate", temp.checkPermission);

            if (state === "SUCCESS" && temp.checkPermission == true) {
                
                // $A.get("e.force:lightningQuickAction").fire();
                if (temp != null && temp != undefined) {
                    console.log('Wrapperdata == = = = ' + temp);
                    component.set("v.QuoteConversionRate", temp.cRate);
                    
                    component.set("v.OpptyName", temp.objopty.Name);
                    console.log('opportunity name  == = = = ' , JSON.stringify(temp.objopty));
                    component.set("v.OpptyCurrencyCode", temp.objopty.CurrencyIsoCode);
                    console.log('v.OpptyCurrencyCode'+temp.objopty.CurrencyIsoCode);
                    // console.log('Wrapperdata.objopty.Name ==>' + Wrapperdata.objopty.Name);
                    component.set("v.AccountName", temp.objopty.Account.Name);
                    console.log('Wrapperdata ==>' + temp.objopty.Subsidiary__r.Allow_Exchange_Rate_Modification__c);
                    component.set("v.AllowExchangeRate", temp.objopty.Subsidiary__r.Allow_Exchange_Rate_Modification__c);
                    component.set("v.AllowAdditionalMargin", temp.objopty.Subsidiary__r.Allow_Quote_Margin_Modification__c);
                    component.set("v.displayExchangeRate", temp.objopty.Subsidiary__r.Display_Exchange_Rate_Modification__c);
                    component.set("v.displayAdditionalMargin", temp.objopty.Subsidiary__r.Display_Quote_Margin_Modification__c);
                    
                    component.set("v.AddionalMargin", temp.AddionalMargin);
                    
                    component.set("v.soldTo", temp.objopty.AccountId);
                    component.set("v.shipTo", temp.objopty.AccountId);
                    //console.log('Wrapperdata.objopty.Account.Name ===>' + Wrapperdata.objopty.Account.Name);
                    //console.log('Size of wrapper ===> ' + Wrapperdata.lstQt.length);
                    /*for(var i = 0; i < Wrapperdata.lstQt.length; i++){
                        console.log('Account Name ===> ' + Wrapperdata.lstQt[i].Account.Name);
                    }*/

                    
                    var cloneQuoteOptions = [];
                    for (var i = 0; i < temp.lstQt.length; i++) {
                        console.log(i+'  --i -->'+temp.lstQt[i].Id+'-' + temp.lstQt[i].Quote_Number__c  + '-' + temp.lstQt[i].QU_REVISION_NUMBER__c+ '-' + temp.lstQt[i].Account.Name);
                        cloneQuoteOptions.push({
                            label: temp.lstQt[i].Quote_Number__c  + '-' + temp.lstQt[i].QU_REVISION_NUMBER__c+ '-' + temp.lstQt[i].Account.Name,
                            value: temp.lstQt[i].Id + '-' + temp.lstQt[i].Name+'-'+temp.lstQt[i].Quote_Number__c+ '-' +temp.lstQt[i].QU_REVISION_NUMBER__c
                        })
                    }

                    component.set("v.LstExistingQuotes", temp.lstQt);
                    component.set("v.cloneQuoteOptions", cloneQuoteOptions);

                    console.log('CLone Options ===>' + JSON.stringify(cloneQuoteOptions));
                }

            }
                else {
                $A.get("e.force:closeQuickAction").fire();
                console.log('KB error : : ');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": 'You are not allowed to create Quotation in this region.'
                });
                toastEvent.fire();
            }
            }
        });
        $A.enqueueAction(action);
    },

    // helper for checking for duplicates
    checkDuplicates: function (component) {
        component.set('v.showSpinner', true);
        var recId = component.get("v.recordId");
        var qtNameToCheck = component.find("qtName").get("v.value");
        var lstQuotes = component.get("v.LstExistingQuotes");
        console.log('lstQuotes --> ', lstQuotes);
        var action = component.get('c.CheckQuoteTemplate');
        action.setCallback(this, function (response) {
            console.log('verify msg-->',response.getReturnValue());
            if (response.getReturnValue() == true) {
                component.set('v.showSpinner', false);
                var toastevent = $A.get('e.force:showToast');
                toastevent.setParams({
                    'title': 'error',
                    'type': 'error',
                    'message': 'Please check Quote Template on Subsidary Master.',
                    'mode': 'dismissible'
                })
                toastevent.fire();
                component.set("v.SaveHit",true);
            }else{
                if (qtNameToCheck != null && qtNameToCheck != undefined && qtNameToCheck != '') {
                        var lstMatchingQuotes = lstQuotes.filter(function (eachQuote) {
                            return eachQuote.Name == qtNameToCheck
                        });
                        console.log('lstMatchingQuotes',lstMatchingQuotes);
                        console.log(lstMatchingQuotes.length);
                        if (lstMatchingQuotes.length > 0) {
                            component.set('v.isQuoteVerified', false);
                            component.set('v.showSpinner', false);
                            component.find('notifLib').showToast({
                                "variant": "error",
                                "title": "Duplicate Found!",
                                "message": "A Quote with this Name already exists."
                            });
                        } else {
                            component.set('v.showSpinner', false);
                            component.set('v.isQuoteVerified', true);
                            component.find('notifLib').showToast({
                                "variant": "success",
                                "title": "Verified!",
                            });
                        }
    
                    } else {
                        component.set('v.showSpinner', false);
                        component.find('notifLib').showToast({
                            "variant": "error",
                            "title": "Invalid/Blank Quote Name!",
                        });
                    }
            }
            });
            $A.enqueueAction(action); 
    },

    // helper for creating a blank quote
    blankQuote: function (component) {
        component.set('v.showSpinner', true);
        var recordId = component.get("v.recordId"); //Oppty Id
        var cRate = component.get("v.QuoteConversionRate");
        var cRate = component.get("v.QuoteConversionRate");
        var qtNameToCheck = component.find("qtName").get("v.value");
        var navService = component.find("navService");
        var addionalMargin = component.get("v.AddionalMargin");
        var currentProdType2 = component.get("v.currentProdType");
        
        
        console.log('addionalMargin --->', addionalMargin);
        if (qtNameToCheck != null && qtNameToCheck != undefined && qtNameToCheck != '') {
            var action = component.get('c.createBlankQuoteController');
            action.setParams({
                "QuoteName": qtNameToCheck,
                "recordId": recordId,
                "currencyName":currentProdType2,
                "cRate": cRate,
                "QuoteAdditionalMargin": addionalMargin
            });
            action.setCallback(this, function (response) {
                var err = response.getError();
                //console.log('err[0].message '+response.getError()+'-->'+err[0].message );
                //console.log('response.getState()'+response.getState());
                //console.log('error message is'+JSON.Serailize(response.getError()));
                if (response.getState() == 'SUCCESS') {
                    var quoteCreatedId = response.getReturnValue();
                    component.set('v.showSpinner', false);
                    var pageRef = {
                        type: "standard__recordPage",
                        attributes: {
                            recordId: quoteCreatedId,
                            objectApiName: "Quote",
                            actionName: "view"
                        },
                    };
                    
                    navService.navigate(pageRef);
                }
                else if (err[0].message == 'true') {
                    component.set('v.showSpinner', false);
                    var toastevent = $A.get('e.force:showToast');
                    toastevent.setParams({
                        'title': 'error',
                        'type': 'error',
                        'message': err[0].message,
                        'mode': 'dismissible',
                    })
                    toastevent.fire();
                    // component.set("v.SaveHit",true);
                } else {
                    component.set('v.showSpinner', false);
                    component.find('notifLib').showToast({
                        "variant": "error",
                        "title": "Something went wrong!",
                        "message": err[0].message,
                    });
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set('v.showSpinner', false);
            component.find('notifLib').showToast({
                "variant": "error",
                "title": "Invalid/Blank Quote Name!",
            });
        }
    },

    // helper for cloning quotes
    cloneQuotes: function (component) {
        //alert('true');
        component.set('v.showSpinner', true);
        var selectedQuoteToClone = component.get('v.selectedCloneQuote').split('-')[0];
        //alert('selectedQuoteToClone = ='+selectedQuoteToClone);
        var qtNameToCheck = component.find('cloneQtName').get('v.value');
        var soldTo = component.get('v.soldTo');
        var shipTo = component.get('v.shipTo');
        
        console.log('soldTo--->',soldTo +' shipTo '+shipTo );
        //alert('qtNameToCheck = ='+qtNameToCheck);
        var navService = component.find("navService");
        //alert('navService = ='+navService);
        var recordId = component.get("v.recordId");
        //alert('recId = ='+recId);
        var currentProdType1 = component.get("v.currentProdType");
        var lstQuotes = component.get("v.LstExistingQuotes");
        var cRate = component.get("v.QuoteConversionRate");
        var addionalMargin = component.get("v.AddionalMargin");
        console.log('addionalMargin ===>', addionalMargin);
        //alert('lstQuotes = ='+lstQuotes);

        
        if ((soldTo == '' || soldTo == null)) {
            component.set('v.isQuoteVerified', false);
                component.set('v.showSpinner', false);
                component.find('notifLib').showToast({
                    "variant": "error",
                    "title": "Error",
                    "message": "Please Fill Sold To."
                });
        
        }else
            if ((shipTo == '' || shipTo == null)) {
                component.set('v.isQuoteVerified', false);
                component.set('v.showSpinner', false);
                component.find('notifLib').showToast({
                    "variant": "error",
                    "title": "error",
                    "message": "Please Fill Ship To."
                });
        
        }else 
        if (qtNameToCheck != null && qtNameToCheck != undefined && qtNameToCheck != '') {
            //alert('1');
            var lstMatchingQuotes = lstQuotes.filter(function (eachQuote) {
                //alert('2');
                return eachQuote.Name == qtNameToCheck
            });

            console.log(lstMatchingQuotes.length);
            if (lstMatchingQuotes.length > 0) {
                //alert('reaching');
                component.set('v.isQuoteVerified', false);
                component.set('v.showSpinner', false);
                component.find('notifLib').showToast({
                    "variant": "error",
                    "title": "Duplicate Found!",
                    "message": "A Quote with this Name already exists."
                });
            } 
            else {
                //alert('sjdfvbfzdivhbsfv hb');
                console.log('cloningQuote--!');
                var action = component.get('c.cloneExistingQuote');
                console.log('settingCloned--!');
                action.setParams({
                    "quoteToClone": selectedQuoteToClone,
                    "clonedQuoteName": qtNameToCheck,
                    "currencyName":currentProdType1,
                    "recordId": recordId,
                    "cRate": cRate,
                    "QuoteAdditionalMargin": addionalMargin,
                    "soldTo":soldTo,
                     "shipTo":shipTo,
                });
                console.log('callingCloned--!');
                action.setCallback(this, function (response) {
                    
                    var quoteCreatedId = response.getReturnValue();
                    
                    console.log('calledCloned--!',quoteCreatedId,response.getState());
                    if (response.getState() == 'SUCCESS') {
                        
                        component.set('v.showSpinner', false);
                        if(quoteCreatedId.Id !=null){
                            
                				window.setTimeout(
                             $A.getCallback(function() {
                            
                          
           
                            console.log('quoteCreated-->', quoteCreatedId.Id);
                            var pageRef = {
                                type: "standard__recordPage",
                                attributes: {
                                    recordId: quoteCreatedId.Id,
                                    objectApiName: "Quote",
                                    actionName: "view"
                                },
                            };
                            component.find('notifLib').showToast({
                                "variant": "success",
                                "title": "Cloning Success.",
                                "message": "Quote has been cloned successfully!"
                            });
                            navService.navigate(pageRef);
                                 }), 10
                         );
                            this.openConfirm();
                         
                        
                        }
                        else {
                        console.log('inside else',quoteCreatedId.error);
                        component.set('v.showSpinner', false);
                        component.find('notifLib').showToast({
                            "variant": "error",
                            "title": "Something went wrong!",
                            "message": quoteCreatedId.error, 
                        });
                    }
                        
                    } 
                    else {
                        console.log('inside else',quoteCreatedId.error);
                        component.set('v.showSpinner', false);
                        component.find('notifLib').showToast({
                            "variant": "error",
                            "title": "Something went wrong!",
                            "message": quoteCreatedId.error, 
                        });
                    }
                });
                $A.enqueueAction(action);
            }

        } else {
            component.set('v.showSpinner', false);
            component.find('notifLib').showToast({
                "variant": "error",
                "title": "Invalid/Blank Quote Name!",
            });
        }
    },
    
    getAddress:function(param){
        console.log('confirmation call',param)
    },
    
  
    openConfirm: function() {
        console.log('confirmation call')
        this.LightningAlert.open({
            message: 'This quote is cloned. Old price is shown. Kindly press RECALCULATE button to get latest price',
            theme: 'info',
            label: 'Please Confirm',
        }).then(function(result) {
            // result is true if clicked "OK"
            // result is false if clicked "Cancel"
            console.log('confirm result is', result);
        });
    },
            
        

    // helper for reading CSV and creating Quotes
    quotesFromCSV: function (component) {
        component.set('v.showSpinner', true);
        var recordId = component.get('v.recordId');
        var file = component.find('csvToImport').get('v.files')[0];

        var reader = new FileReader();
        reader.readAsText(file, "UTF-8");
        reader.onload = function (evt) {
            console.log("EVT FN");
            var csv = evt.target.result;
            console.log('csvAsString-->', JSON.stringify(csv));

            var action = component.get('c.importQuoteFromCSV');
            action.setParams({
                csvFileBody: csv,
                recordId: recordId
            });
            action.setCallback(this, function (res) {
                if (res.getState() == 'SUCCESS') {
                    console.log('res--->', res.getReturnValue());
                    if (res.getReturnValue() == true) {
                        component.set('v.showSpinner', false);
                        component.find('notifLib').showToast({
                            "variant": "success",
                            "title": "Quotes created Successfully!",
                        });
                    } else {
                        component.set('v.showSpinner', false);
                        component.find('notifLib').showToast({
                            "variant": "error",
                            "title": "Quotes couldn't be created!",
                        });
                    }
                } else {
                    component.set('v.showSpinner', false);
                    component.find('notifLib').showToast({
                        "variant": "error",
                        "title": "Quotes couldn't be created!",
                    });
                }
            });
            $A.enqueueAction(action);


        }
        reader.onerror = function (evt) {
            component.set('v.showSpinner', false);
            component.find('notifLib').showToast({
                "variant": "error",
                "title": "Error reading the CSV File!",
            });
        }

    },
    
   /*fetchSoldAndShipTo : function(component,param,quoteId) {
    console.log('quoteId -->', component.get("v.soldTo");
       
       component.set("v.soldTo", result['Sold_To__c']);
   },*/
       //component.set("v.shipTo", result['Sold_To__c']);

    /*setTimeout(function() {
    console.log("Calling Apex now...");

    var action = component.get("c.getSoldAndShipTo1");
    action.setParams({
        quoteId: quoteId
    });

    action.setCallback(this, function(response) {
        var state = response.getState();
        console.log("Apex call state:", state);

        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            console.log('Apex result:', JSON.stringify(result));

            component.set("v.soldTo", result['Sold_To__c']);
            component.set("v.shipTo", result['Ship_To__c']);
        } else {
            console.error("Error fetching SoldTo/ShipTo:", response.getError());
        }
    });

    $A.enqueueAction(action);
}, 200);
},*/


})