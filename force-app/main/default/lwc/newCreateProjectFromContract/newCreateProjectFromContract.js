import { LightningElement ,track,api,wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from "lightning/actions";
import modal from '@salesforce/resourceUrl/modalwidth';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import getExistingProjectDetails from '@salesforce/apex/new_lwcProjectController.getExistingProjectDetails';

import SaveProjectDeatils from '@salesforce/apex/new_lwcProjectController.SaveProjectDeatils';
import createUniqueNo from '@salesforce/apex/new_lwcProjectController.createUniqueNo';

export default class NewCreateProjectFromContract extends NavigationMixin(LightningElement) {

    recordId;
    @track showSpinner = false;
    @track isCreateProjectUniqueNo = false;

    @track showModal = false;

    @track isOpen = false;
    @track WaringMessage = '';
    @track isOpenTable = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
        console.log(this.recordId + ' in 0000000');
    }


    @track showTableProjects = [];
    connectedCallback() {
        loadStyle(this, modal);
        this.getExistingProject();
    }

    getExistingProject() {
        console.log('adwwwqs');
        getExistingProjectDetails({ contractId: this.recordId }).then(result => {
            console.log('result--->>>',JSON.stringify(result));
            let errorMessage = 0;
            for (let key in result) {
                if (key == 'Information') {
                    console.log('current Key', key);
                    this.ShowToastMessage(key, result[key]);
                    errorMessage = Number(errorMessage) + 1;
                    this.isOpen = false;
                }else
                if (key == 'UniquePM') {
                    this.WaringMessage = 'Please create a unique project number by clicking the button/link below.';
                    this.isCreateProjectUniqueNo = true;
                     this.isOpen = false;
                    this.isOpenTable = false;
                    this.showModal = false;
                }
                else {
                    this.WaringMessage = result['Warning'];
                    this.isCreateProjectUniqueNo = false;
                    
                    let data = JSON.parse(result['data']);
                    for(let i = 0; i< data.length; i++){

                    }

                    this.showTableProjects = JSON.parse(result['data']);

                    this.TotalProgram = this.showTableProjects.length;
                    this.isOpen = false;
                    this.isOpenTable = false;
                    this.showModal = true;
                    ///this.handleCancel();
                }

            }

            if (Number(errorMessage) > 0) {
                //this.goBackToRecord();
            }
        })
    }


    goBackToRecord() {
        this.isOpen = false;
        if (!this.isOpen) {
            setTimeout(() => {
                window.location.reload();
            }, 100);
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__recordPage',
            //     attributes: {
            //         recordId: this.recordId,
            //         objectApiName: 'Contract',
            //         actionName: 'view',

            //     }
            // });
        }
    }



    async handleCancel() {

        const result = await LightningConfirm.open({
            message: this.WaringMessage,
            variant: 'header',
            label: 'Please Confirm',
            theme: 'Info',
        });
        console.log('result', result);

    }

    hideshowModal() {
        this.closeAction();
        this.showModal = false;
    }


    handleProjectUniqueNo(){
        createUniqueNo({conId:this.recordId}).then(result=>
        {
            console.log('OUTPUT : ',JSON.stringify(result));
                if (result.Status =='Success') {
                    this.ShowToastMessage('Success',result.Message );
                }else{
                    this.ShowToastMessage('Error',result.Message );
                }
            

        })

    }

    handleOk() {

        this.showModal = false;
        this.isOpen = true;
        this.isOpenTable = true;
    }

    @track TotalProgram = 0;
    handlerowselected(event) {
        console.log('id-->',event.target.dataset.id);
        
        let index = this.showTableProjects.map(a => a.LineNumberIdClone).indexOf(event.target.dataset.id);
        console.log('index-->',index);
        this.showTableProjects[index].isSelect = event.target.checked;
        if (this.showTableProjects[index].isSelect) {
            this.TotalProgram++;
        } else if (!this.showTableProjects[index].isSelect) {
            this.TotalProgram--;
        }
        this.saveDisabledMethod(this.TotalProgram);

    }


    @track saveDisabled = false;
    saveDisabledMethod(TotalProgram1) {
        console.log('TotalProgram', TotalProgram1);
        console.log('TotalProgram', this.TotalProgram);
        if (Number(this.TotalProgram) > 0) {
            this.saveDisabled = false;
        } else {
            this.saveDisabled = true;
        }
    }

    onDataChange(event){
        let index = this.showTableProjects.map(a => a.LineNumberIdClone).indexOf(event.target.dataset.id);
        let label = event.target.dataset.label;
        
        this.showTableProjects[index][label] = event.target.value;
    }


     handleDateBRChange(event) {
        this.saveDisabled = false;
        const input = event.target;
        const label = input.dataset.label;
        const value = input.value;

        let index = this.showTableProjects.map(a => a.LineNumberIdClone).indexOf(event.target.dataset.id);

        if (label === "ExpectedSalesMonth" || label === "YourPOIssueDate") {
            const enteredDate = new Date(value);
            const today = new Date();
            today.setHours(0, 0, 0, 0); // Ignore time

            let errorMessage = "";
            if (enteredDate < today) {
                errorMessage = "Date should be today or a future date.";
                this.saveDisabled = true;
            }

            input.setCustomValidity(errorMessage);
            input.reportValidity();

            // Optionally update the value in caseFields
 //           const index = parseInt(input.dataset.index, 10);
//                        const caseIndex = this.caseFields.findIndex(addr => addr.index === index);
            if (this.showTableProjects && this.showTableProjects[index]) {
                this.showTableProjects[index][label] = value;
            }
        }
    }


    saveProjects() {
    let varCheck = true;

    // Loop through each project in showTableProjects
    for (let pro of this.showTableProjects) {

        // Skip disabled projects
        if (!pro.isDisabled && pro.isSelect){

            // Check for Expected Sales Month
            if (!pro.ExpectedSalesMonth) {
                varCheck = false;
                this.ShowToastMessage1('Error', 'Please Fill Expected Sales Month -> ' + pro.proName);
            }

            // Check for Your PO Number
            if (!pro.YourPONumber) {
                varCheck = false;
                this.ShowToastMessage1('Error', 'Please Fill Your PO Number -> ' + pro.proName);
            }

            // Check for Your PO Issue Date
            if (!pro.YourPOIssueDate) {
                varCheck = false;
                this.ShowToastMessage1('Error', 'Please Fill Your PO Issue Date -> ' + pro.proName);
            }
        }
    }

    // Delay to allow all toasts to render before submitting (optional)
    setTimeout(() => {

        if (varCheck) {
            this.showSpinner = true;

            SaveProjectDeatils({
                ContractId: this.recordId,
                js: JSON.stringify(this.showTableProjects),
                TotalProgram: this.TotalProgram
            })
            .then(result => {
                console.log('OUTPUT:', JSON.stringify(result));

                for (let key in result) {
                    if (key === 'Success') {
                        this.ShowToastMessage(key, result[key]);

                        // Navigate to the Contract record
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordId,
                                objectApiName: 'Contract',
                                actionName: 'view'
                            }
                        });

                        this.goBackToRecord();
                        this.showSpinner = false;

                    } else {
                        // Show error toast if not "Success"
                        this.showSpinner = false;
                        this.ShowToastMessage(key, result[key]);
                    }
                }
            })
            .catch(error => {
                this.showSpinner = false;
                console.error('SaveProjectDeatils error:', error);
                this.ShowToastMessage('Error', 'An error occurred while saving project details.');
            });
        }

    }, 500); // Reduced delay from 1000ms to 500ms unless longer delay is necessary
}

ShowToastMessage1(variant, msg) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: variant,
                message: msg,
                variant: variant,
            }),
        );
       
    }


    ShowToastMessage(variant, msg) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: variant,
                message: msg,
                variant: variant,
            }),
        );
        this.closeAction();
        if (!this.isOpen) {
            //this.goBackToRecord();
        }
    }



    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());

    }
}