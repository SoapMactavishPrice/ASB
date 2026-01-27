({
    // get Contact List from apex controller
    doInit : function(component, event, helper) {
        component.set("v.up", false);
        component.set("v.down", true);
        helper.getDetail(component);
        helper.initMethod(component);
        
    },
    
    
    handleParentCheckbox : function(component, event, helper) {
    const sourceCmp = event.getSource();
    if (!sourceCmp) return;

    const parentId = sourceCmp.get("v.value");
    const isChecked = sourceCmp.get("v.checked");

    let items = JSON.parse(JSON.stringify(component.get("v.QliItems") || []));

    if (!Array.isArray(items) || items.length === 0) return;

    // 🧼 Clean items to avoid Aura serialization errors
    items = items.filter(p => p).map(parent => {
        if (!Array.isArray(parent.Quote_Line_Options__r)) {
            parent.Quote_Line_Options__r = [];
        } else {
            parent.Quote_Line_Options__r = parent.Quote_Line_Options__r.filter(c => c);
        }
        return parent;
    });

    const pIndex = items.findIndex(item => item.Id === parentId);
    if (pIndex === -1) return;

    items[pIndex].isSelected = isChecked;
    items[pIndex].Quote_Line_Options__r.forEach(child => {
        child.isSelected = isChecked;
    });

    // ✅ Safe set after cleaning
    

    const selectedIds = [];
    items.forEach(parent => {
        if (parent.isSelected) selectedIds.push(parent.Id);
        parent.Quote_Line_Options__r.forEach(child => {
            if (child.isSelected) selectedIds.push(child.Id);
        });
    });

    component.set("v.selectedIds", selectedIds);
    component.set("v.isDeleteVisible", selectedIds.length > 0);
        
        try {
        console.log('About to set QliItems:', JSON.stringify(items));
        component.set("v.QliItems", items);
    } catch (e) {
        console.error('❌ component.set("v.QliItems", …) failed:', e);
        return; // bail early if this fails
    }
}
   ,
                handleChildCheckbox : function(component, event, helper) {
                    
                    let sourceCmp = event.getSource();
                    let fullId = sourceCmp.get("v.value");
                    let parentId = fullId.split('-')[0];
                    let valueId = fullId.split('-')[1];
                    
                    
                    let isChecked = sourceCmp.get("v.checked");
                    
                    console.log('vId-->'+valueId+'pId '+parentId+' isChecked '+isChecked);
                    let items = component.get("v.QliItems");
                    
                    
                    
                    let pIndex = items.findIndex(item => item.Id === parentId);
                    if (pIndex === -1) return;
                    
                    let cIndex = items[pIndex].Quote_Line_Options__r.findIndex(child => child.Id === valueId);
                    if (cIndex === -1) return;
                    
                    items[pIndex].Quote_Line_Options__r[cIndex].isSelected = isChecked;
                    
                    //let allSelected = items[pIndex].Quote_Line_Options__r.every(c => c.isSelected);
                    //items[pIndex].isSelected = allSelected;
                    
                    //component.set("v.QliItems", items);
                    
                    let selectedIds = [];
                    items.forEach(parent => {
                        if (parent.isSelected) selectedIds.push(parent.Id);
                        if (parent.Quote_Line_Options__r) {
                        parent.Quote_Line_Options__r.forEach(child => {
                        if (child.isSelected) selectedIds.push(child.Id);
                    });
                }
            });
            
            component.set("v.selectedIds", selectedIds); // store selected IDs
            console.log('Selected IDs:', selectedIds);
            component.set("v.selectedIds", selectedIds);
            component.set("v.isDeleteVisible", selectedIds.length > 0);
        }
        ,
            
            // handle global refresh event and re-init component
            onRefreshView: function(component, event, helper) {
                console.log('refreshed--summary');
                helper.getDetail(component);
                helper.initMethod(component);
                //$A.get('e.force:refreshView').fire();
            }
        ,
            handleDeleteSelected : function(component, event, helper) {
                let ids = component.get("v.selectedIds");
                if (!ids || ids.length === 0) {
                    $A.get("e.force:showToast").setParams({
                        title: "Warning",
                        message: "No records selected",
                        type: "warning"
                    }).fire();
                    return;
                }
                
                var action = component.get("c.deleteMultipleLineItems");
                action.setParams({ lineItemIds : ids });
                
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        var Wrapperdata = JSON.parse(response.getReturnValue());
                        
                        console.log('deleted result==>',Wrapperdata);
                        if(Wrapperdata.Status =='Success'){
                        $A.get("e.force:showToast").setParams({
                            title: "Success",
                            message: Wrapperdata.Message,
                            type: "success"
                        }).fire();
                        component.set("v.selectedIds", []);
                        helper.initMethod(component);
                        }else{
                             $A.get("e.force:showToast").setParams({
                            title: "Error",
                            message: Wrapperdata.Message,
                            type: "Error"
                        }).fire();
                        }
                    } else {
                        console.error(response.getError());
                    }
                });
                $A.enqueueAction(action);
                
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