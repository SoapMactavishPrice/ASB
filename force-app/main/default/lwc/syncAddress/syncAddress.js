import { LightningElement, api, track, wire } from 'lwc';
import updateQuoteAddress from '@salesforce/apex/UpdateQuote.updateQuoteAddress';
import updateContractAddress from '@salesforce/apex/UpdateQuote.updateContractAddress';
import { CloseActionScreenEvent } from "lightning/actions";

import getAccountAddress from '@salesforce/apex/UpdateQuote.getAccountAddress';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';


export default class UpdateQuoteAddressButton extends LightningElement {
    // @track notSHow = false;
    @api recordId;
    @track currentPageRef;
    @track IsQuoteUpdate = false;
    @track IsContractUpdate = false;
    @track IsPMUpdate = false;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        // If currentPageReference exists, set the recordId
        if (currentPageReference) {
            this.currentPageRef = currentPageReference;
            // The recordId parameter comes from the URL of the page
            this.recordId = currentPageReference.state.recordId;
            console.log('Record Id from CurrentPageReference:', this.recordId);
        }
    }



    @track recordData;

    // @wire(getAccountAddress, { Id: '$recordId' })
    // wiredAccount({ error, data }) {
    //     if (data) {
    //         console.log('data----', data);
    //         this.recordData = JSON.parse(data);
    //         this.handleClick();
    //     } else if (error) {
    //         console.log('error----', error);
    //     }
    // }



    connectedCallback() {
        console.log('Record Id hello:', this.recordId); // Debugging recordId here
        this.getAddressData();
    }

    getAddressData(){
        //console.log('call from connetedCallBack : hello--> ',this.recordId);
        getAccountAddress({Id:this.recordId}).then(result=>{
          //  console.log('OUTPUT : ',result);
            this.recordData = JSON.parse(result);
            this.handleClick();
        })
    }

    handleClick() {
        console.log('quote   ->:', this.recordId);  // Debugging before sending to Apex
        updateQuoteAddress({ accountId: this.recordId, JS: JSON.stringify(this.recordData) })
            .then(result => {
                let data = JSON.parse(result);
                data.forEach(currentItem => {

                    if (currentItem.status) {
                        this.showSuccessToast(currentItem.Variant, currentItem.Variant, currentItem.message);
                        this.handleContractClick();
                    } else {
                        this.showSuccessToast(currentItem.Variant, currentItem.Variant, currentItem.message);
                    }
                });

            })
            .catch(error => {
                this.showErrorToast(error.body.message);
            });
    }


    handleContractClick() {
        console.log('go for contract:', this.recordId);  // Debugging before sending to Apex
        updateContractAddress({ accountId: this.recordId, JS: JSON.stringify(this.recordData) })
            .then(result => {
                let data = JSON.parse(result);
                data.forEach(currentItem => {

                    if (currentItem.status) {
                        this.showSuccessToast(currentItem.Variant, currentItem.Variant, currentItem.message);
                    } else {
                        this.showSuccessToast(currentItem.Variant, currentItem.Variant, currentItem.message);
                    }
                    this.closeAction();
                    setTimeout(() => {
            window.location.reload();
        }, 2000);

                });

            })
            .catch(error => {
                this.showErrorToast(error.body.message);
            });
    }

    showSuccessToast(title, vari, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: vari,
        });
        this.dispatchEvent(evt);
    }

    closeAction() {
       // 
        this.dispatchEvent(new CloseActionScreenEvent());

    }
}