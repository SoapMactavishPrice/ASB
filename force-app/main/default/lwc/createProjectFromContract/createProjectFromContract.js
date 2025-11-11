import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from "lightning/actions";
import modal from '@salesforce/resourceUrl/modalwidth';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExistingProjectDetails from '@salesforce/apex/lwcProjectController.getExistingProjectDetails';
import LightningConfirm from 'lightning/confirm';

import SaveProjectDeatils from '@salesforce/apex/lwcProjectController.SaveProjectDeatils';



export default class CreateProjectFromContract extends NavigationMixin(LightningElement) {
    recordId;

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


    /**
    *
    * @param {*} event
    */
    async handleCancel() {

        const result = await LightningConfirm.open({
            message: this.WaringMessage,
            variant: 'header',
            label: 'Please Confirm',
            theme: 'Info',
        });
        console.log('result', result);

        // if (result) {
        //     this.isOpen = false;
        //     this.isOpenTable = true;
        // } else {
        //     this.isOpen = false;
        //     this.isOpenTable = false;
        //     this.closeAction();
        // }
    }



    getExistingProject() {
        console.log('adwwwqs');
        getExistingProjectDetails({ contractId: this.recordId }).then(result => {
            console.log(result);
            let errorMessage = 0;
            for (let key in result) {
                if (key != 'Warning' && key != 'data') {
                    console.log('current Key', key);
                    this.ShowToastMessage(key, result[key]);
                    errorMessage = Number(errorMessage) + 1;
                    this.isOpen = false;
                }
                else {
                    this.WaringMessage = result['Warning'];
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

    @track TotalProgram = 0;
    handlerowselected(event) {
        let index = this.showTableProjects.map(a => a.LineNumberId).indexOf(event.target.dataset.id);
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

    saveProjects() {
        SaveProjectDeatils({ ContractId: this.recordId, js: JSON.stringify(this.showTableProjects), TotalProgram : this.TotalProgram }).then(result => {
            console.log('OUTPUT : ',JSON.stringify(result));
            
            for (let key in result) {
                if (key == 'Success') {
                    this.ShowToastMessage(key, result[key]);
                    // this.closeAction();
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            objectApiName: 'Contract',
                            actionName: 'view',

                        }
                    });
                    this.goBackToRecord();
                } else {
                    this.ShowToastMessage(key, result[key]);
                }
            }
        })

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


    hideshowModal() {
        this.closeAction();
        this.showModal = false;
    }


    handleOk() {

        this.showModal = false;
        this.isOpen = true;
        this.isOpenTable = true;
    }

}