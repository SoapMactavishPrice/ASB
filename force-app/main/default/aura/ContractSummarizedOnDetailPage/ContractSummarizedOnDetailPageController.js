({
    // get Contact List from apex controller
    doInit : function(component, event, helper) {
        component.set("v.up", false);
        component.set("v.down", true);
        helper.getDetail(component);
		helper.initMethod(component);
        
    },
    
    // handle global refresh event and re-init component
    onRefreshView: function(component, event, helper) {
        console.log('refreshed--summary');
        helper.getDetail(component);
        helper.initMethod(component);
        //$A.get('e.force:refreshView').fire();
    }
    ,
    handleExportClick: function(component, event, helper){
    console.log('export Js');
    component.set("v.loader",true);
    helper.exportCSVcaller(component);
        
},
   topToBottom:function(component,event,helper){
       console.log('inside up');
       var fieldName = 'Sr_No__c';
       var sortDirection = 'asc';
       component.set("v.up", false);
       component.set("v.down", true);
       helper.sortData(component, fieldName, sortDirection);

    },
    
    bottomToTop:function(component,event,helper){
        console.log('inside up');
       var fieldName = 'Sr_No__c';
       var sortDirection = 'Desc';
        component.set("v.up", true);
        component.set("v.down", false);
       helper.sortData(component, fieldName, sortDirection);
    }
    

})