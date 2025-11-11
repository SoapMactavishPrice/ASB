import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from "lightning/actions";
import modalWithReOpen from '@salesforce/resourceUrl/modalWithReOpen';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProjectDetail from '@salesforce/apex/ReOpenQuoteFromContract.getProjectDetail';
import LightningAlert from 'lightning/alert';
import saveCanceledProject from '@salesforce/apex/ReOpenQuoteFromContract.saveCanceledProject';

export default class LwcReOpenQuote extends NavigationMixin(LightningElement) {
    @track isOpen = true;
    @track isConfirm = true;

    recordId;
    @track isCancel = false;





    get options() {
        return [
            { label: 'Cancelled', value: 'Cancelled' },
            { label: 'Amendment', value: 'Amendment' },
        ];
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
        console.log(this.recordId + ' in 0000000');
    }


    @track showSpinner = false;
    connectedCallback() {
        loadStyle(this, modalWithReOpen)
            .then(() => {
                console.log('Styles loaded successfully');
            })
            .catch(error => {
                console.error('Error loading styles', error);
            });

        console.log('-->', this.recordId);
        this.getDetail();

    }

    @track allProject = 0;

    @track wrapList = [];
    getDetail() {
        getProjectDetail({ CurrentId: this.recordId }).then(result => {
            let data = JSON.parse(result);
            let i = 0;
            data.forEach(element => {
                element.index = i++;
                if (element.p_projNum == null) {
                    this.allProject++;
                    this.saveDisabled = true;
                    this.CancelDisabled = false;
                }
                this.wrapList.push(element);
            });

        })
    }
    @track OpenPopUp = false;
    @track projectNumber = '';
    @track indexToBeCancel;
    OpenPopUpCall(bcheck, index, projectNumber) {
        if (bcheck) {
            this.OpenPopUp = true;
            this.indexToBeCancel = index;
            this.projectNumber = projectNumber;
        } else {
            this.OpenPopUp = false;
        }

    }


    handleOk() {
        this.OpenPopUp = false;
        this.saveDisabled = false;
        this.CancelDisabled = false;
        this.wrapList[this.indexToBeCancel].p_CancelType = 'Cancelled';
        this.count = this.count +1;
    }

    hideshowModal() {
        this.OpenPopUp = false;
        this.saveDisabled = true;
        this.CancelDisabled = false;
        this.wrapList[this.indexToBeCancel].p_CancelType = '';
    }
    @track saveDisabled = false;
    @track CancelDisabled = false;

    @track count = 0;


    

    handleConfirmChange(event) {
        this.OpenPopUp = false;
        this.indexToBeCancel = null;
        this.projectNumber = null;
        this.isCancel = false;

        if (event.target.value == 'Cancelled') {
            
            
            if(this.wrapList[event.target.dataset.index].p_Phase =='Close'){
                //this.ShowToastMessage('Error', `You cannot select 'Canceled' because the Project Management $this.wrapList[event.target.dataset.index].p_ProjectName is already Closed!`);
            this.ShowToastMessage(
    'Error',
    `You cannot select 'Canceled' because the Project Management ${this.wrapList[event.target.dataset.index].p_projNum} is already Closed!`,
    'error'
);
event.target.value = null;
            
            }else {
                this.wrapList[event.target.dataset.index].p_OpenConfirm = true;
            console.log('OUTPUT : -->',this.wrapList[event.target.dataset.index].p_Phase);
            let index = event.target.dataset.index;
            let p_OpenConfirm = this.wrapList[event.target.dataset.index].p_OpenConfirm;
            let prName = this.wrapList[event.target.dataset.index].p_projNum;
            this.OpenPopUpCall(p_OpenConfirm, index, prName);
            this.saveDisabled = true;
            
            this.CancelDisabled = true;
            }

            
        } else if (event.target.value !== 'Cancelled') {
            this.wrapList[event.target.dataset.index].p_OpenConfirm = false;
            this.wrapList[event.target.dataset.index].p_CancelType = event.target.value;
            this.saveDisabled = false;
            this.CancelDisabled = false;
            if(this.count > 0)
                this.count = this.count -1;
        }
    }

    // Show alert message

    async handleAlertClick() {
        await LightningAlert.open({
            message: 'Yes --> Cancelled all project  cannot be retrieved back. Are you sure you want to continue?',
            theme: 'info', // Info theme for informational message
            label: 'Info!', // Header text
            dismissible: true
        });

         // Optionally check if the alert was dismissed, if needed
    }


@track closeConfirm = false;
closeConfirmModal(){
    this.closeConfirm = false;
}

CancelAll() {
    this.closeConfirm= true;
     for (let ele of this.wrapList) {
            ele.p_CancelType = '';
            this.isCancel = false;  // Indicate that cancellation is applied
        }
}

// Handle the CancelAll operation
CancelAllProceed() {
    
    this.isCancel = false;
console.log('OUTPUT : ',this.isCancel);
    // Check how many have valid p_projNum
    const validItems = this.wrapList.filter(
        ele => ele.p_projNum !== '' && ele.p_projNum !== null && ele.p_projNum !== undefined
    );
console.log('OUTPUT : validItems',validItems.length);
    if (validItems.length === 0) {
        // All are blank/null/undefined
        alert("No projects with a valid Project Number found to cancel.");
        return;
    }

    // At least one is valid – proceed with cancel
    for (let ele of validItems) {
        ele.p_CancelType = 'Amendment';
        this.isCancel = true;
        
    }

    setTimeout(()=>{
    this.closeConfirm = false;
    //this.this.closeConfirm = false; = false;
    },500)
}



checkAllAreAcanclled(){
   return this.wrapList.every(item => item.p_CancelType =='Cancelled');
}
    saveProjects() {
        let validate = true;
        for (let ele of this.wrapList) {  
            if(ele.p_projNum != '' && ele.p_projNum !=null && ele.p_projNum !=undefined){
             if (ele.p_CancelType == '' || ele.p_CancelType ==null ) {
                console.log('Validation failed for Project:', ele.p_ProjectName);
                validate = false;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: `Please select status for the Project Name ${ele.p_ProjectName}`,
                    variant: 'error',
                });
                this.dispatchEvent(evt);  // Show the toast message
                break;
               }
            }
        }

        console.log('OUTPUT : validate',validate,'cancel -->',this.isCancel);
        if(validate){
        this.showSpinner = true;
        this.isCancel = this.checkAllAreAcanclled();
        saveCanceledProject({ contractId: this.recordId, js: JSON.stringify(this.wrapList),isCancel :this.isCancel}).then(result => {
            this.showSpinner = false;
            for (let key in result) {
                if (key == 'Id') {
                    this.ShowToastMessage('Success', 'Quote Reopen Successfully !');
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result[key],
                            objectApiName: 'Quote',
                            actionName: 'view',

                        }
                    });
                    this.closeAction();
                } else {
                    this.ShowToastMessage(key, result[key]);
                }
            }
        })
        }
    }



    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());

    }

    ShowToastMessage(variant, msg) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: variant,
                message: msg,
                variant: variant,
            }),
        );
    }
}