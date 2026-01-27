({
    // get Contact List from apex controller
    doInit : function(component, event, helper) {
        var pickvar = component.get("c.getPickListValuesIntoList"); 
        pickvar.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var list = response.getReturnValue();
                console.log('list are'+ list);
                component.set("v.picvalue", list);
                console.log('picvalue are'+ component.get("v.picvalue"));
            }
            else if(state === 'ERROR'){
                //var list = response.getReturnValue();
                //component.set("v.picvalue", list);
                alert('ERROR OCCURED.');
            }
        })
        
        
        $A.enqueueAction(pickvar);
        helper.doInit(component);
    },
    
    OnCurrencySelect : function(component,event,helper){
        component.set("v.currentProdType",event.getSource().get("v.value"));  
        console.log('new   '+component.get("v.currentProdType"));
    },
    
    // check for duplicates
    checkForDuplicates: function(component, event, helper) {
        helper.checkDuplicates(component);
    },
    
    // create blank quote
    createBlankQuote: function(component, event, helper) {
        helper.blankQuote(component);	        
    },
    
    // clone from a quote
    createCloneQuote: function(component, event, helper) {
        //alert('here');
        helper.cloneQuotes(component);
    },
    
    // import quotes from csv
    importQuotesFromCSV: function(component, event, helper) {
        helper.quotesFromCSV(component);
    },
    
    onvaluechange:function(component, event, helper){
        var selectedQuotes = event.getParam("value");
        
        if (selectedQuotes && selectedQuotes.length > 0) {
            var selectedQuoteId = selectedQuotes[0]; // Assuming single-select
            //helper.fetchSoldAndShipTo(component, selectedQuoteId);
        } else {
            component.set("v.soldTo", '');
            component.set("v.shipTo", '');
        }
    },
    handleSoldToChange: function(component, event, helper) {
        var newValue = event.getSource().get("v.value");
        console.log("SOLD_TO__c changed to:", newValue);
        
        // Update an attribute, fire an event, or do something with the new value
        component.set("v.soldTo", newValue);
    }
    ,
    handleShipToChange: function(component, event, helper) {
        var newValue = event.getSource().get("v.value");
        console.log("SOLD_TO__c changed to:", newValue);
        
        // Update an attribute, fire an event, or do something with the new value
        component.set("v.shipTo", newValue);
    }
    ,
    handleSelectedCloneQuote : function(component, event, helper) {
        var selected = event.getParam("selectedValue");
        var quoteId = selected.split('-')[0];
        
        console.log('selected value-->',selected);
        setTimeout(function() {
            //helper.fetchSoldAndShipTo(component, event,quoteId);
        }, 200)
        //console.log("Selected Quote in parent: ", selected);
    }
    ,
    
    
})