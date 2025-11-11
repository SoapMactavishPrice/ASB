({  
   FilterRecords: function(component) {  
     //data showing in table  
     var data = component.get("v.data");
     //var data2 = component.get("v.data");
     
     var allData = component.get("v.UnfilteredData");  
     var searchKey = component.get("v.filter"); 
     var currentProdType = component.get("v.currentProdType"); 
     
     var pageSize = component.get("v.pageSize");
     let filtereddata;
       if(allData!=undefined || allData.length>0){  
         if(currentProdType == null && searchKey !=undefined){
             filtereddata = null;
             console.log('in if condition 1');
           filtereddata = allData.filter(word => (!searchKey) || word.objprod.Product2.ProductCode.toLowerCase().includes(searchKey.toLowerCase()) || word.objprod.Product2.Name.toLowerCase().includes(searchKey.toLowerCase()) || word.objprod.Product2.Description.toLowerCase().includes(searchKey.toLowerCase()) );
         }else if(searchKey !=undefined && currentProdType != null){
             console.log('in if condition 2');
             filtereddata = null;
             filtereddata = allData.filter(word => ((!searchKey) || word.objprod.Product2.ProductCode.toLowerCase().includes(searchKey.toLowerCase())  || word.objprod.Product2.Name.toLowerCase().includes(searchKey.toLowerCase()) || word.objprod.Product2.Description.toLowerCase().includes(searchKey.toLowerCase()) ) &&  word.objprod.Product2.Product_Type__c.toLowerCase().includes(currentProdType.toLowerCase()));
         }else if(searchKey !=undefined && currentProdType == null){
             console.log('in if condition 3');
             filtereddata = null;
             filtereddata = allData.filter(word => (!searchKey) || word.objprod.Product2.ProductCode.toLowerCase().includes(searchKey.toLowerCase())  || word.objprod.Product2.Name.toLowerCase().includes(searchKey.toLowerCase()) || word.objprod.Product2.Description.toLowerCase().includes(searchKey.toLowerCase()));
         
         }
             else if(searchKey==undefined){
             filtereddata = null;
             console.log('in if condition 4');
             filtereddata = allData.filter(word => (!currentProdType) || word.objprod.Product2.Product_Type__c.toLowerCase().includes(currentProdType.toLowerCase()));
         }
       //var filtereddata = allData.filter(word => ((!searchKey) || word.objprod.Product2.ProductCode.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 || word.objprod.Product2.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1 || word.objprod.Product2.Description.toLowerCase().indexOf(searchKey.toLowerCase()) > -1) &&  word.objprod.Product2.Product_Type__c.toLowerCase().indexOf(currentProdType.toLowerCase()) > -1);
       console.log('** ',filtereddata.length);  
     } 
       for (let i = 0; i < filtereddata.length; i++) {
           if(filtereddata[i].isChecked){
               filtereddata[i].quantity = filtereddata[i].quantity;
           }else if(!filtereddata[i].isChecked){
               filtereddata[i].quantity = 1;
           }
       }
     console.log('data'+filtereddata.length);
     if(currentProdType != null  || searchKey !=''){
       	if(filtereddata.length > 0){ 
         component.set("v.data", []);  
         component.set("v.data", filtereddata); 
         var Paginationlist = [];
                    for(var i=0; i < pageSize; i++){
                        if(filtereddata.length > i){
                            Paginationlist.push(filtereddata[i]);    
                       } 
            }
            component.set('v.PaginationList', Paginationlist);
            component.set("v.totalPagesCount", Math.ceil(filtereddata.length / pageSize));
            component.set("v.currentPage", 1);
            component.set("v.totalRecordsCount", filtereddata.length);
           component.set("v.dataFound",true);
         component.set("v.dataNotFound",false);
     }else if(filtereddata.length == 0){
         component.set("v.dataFound",false);
         component.set("v.dataNotFound",true);
         console.log('data not found',component.get("v.dataNotFound"));
         
        }
      }
       else if(currentProdType == null && (searchKey ==undefined || searchKey =='')){
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
    
    SelectedRecords:function(component,index){
    console.log('find selected');
     
    var fdata = component.get("v.data");
    var temp = component.get("v.tempSerialNumber");
    var staticLargerNumber = component.get("v.StatictempSerialNumber");
    console.log('temp',temp);
      
        if(fdata[index].isChecked){
            fdata[index].serial_no=temp+10;
            //component.set("v.tempSerialNumber",temp+10);
            //var tempData =var temp = component.get("v.tempSerialNumber");; 
            for(var i = 0; i< fdata.length; ){
                console.log('index',fdata[i].index);
                console.log('current index',index);
                if(fdata[i].index > index && fdata[i].serial_no > 0){
                    //fdata[i].serial_no= fdata[i].serial_no +10;
                }
                
                if(fdata[i].serial_no > temp){
                    temp = fdata[i].serial_no;
                }
                
                i++;
                
            }
            console.log('larger value is',temp);
            component.set("v.tempSerialNumber",temp);
        } if(!fdata[index].isChecked && fdata[index].serial_no > 0 && fdata[index].serial_no >  staticLargerNumber) {
            
            var run_num =  fdata[index].serial_no;
            fdata[index].serial_no = 0;
            for(var i = 0; i< fdata.length;){
                 if(fdata[i].serial_no > run_num){
                        fdata[i].serial_no= fdata[i].serial_no - 10;
                }
                i++;
            }
            component.set("v.tempSerialNumber",temp-10); 
        }
        component.set("v.data",fdata);
    
    
},
 
    
    next : function(component,event,sObjectList,end,start,pageSize){
        var currentData = [];
        var counter = 0;
        component.set('v.PaginationList', []);   
        for(var i = end + 1; i < end + pageSize + 1; i++){
            console.log('temp',sObjectList[i]);
            if(sObjectList.length > i){ 
                currentData.push(sObjectList[i]);
                /*if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }*/
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', currentData);   
    }
    ,
    
    previous : function(component,event,sObjectList,end,start,pageSize){
        var currentData = [];
        var counter = 0;
        component.set('v.PaginationList', []); 
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                currentData.push(sObjectList[i]);
                /*if(component.find("selectAllId").get("v.value")){
                    currentData.push(sObjectList[i]);
                }else{
                     
                }*/
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        
        component.set('v.PaginationList', currentData);
    }
 })