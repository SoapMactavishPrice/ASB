import { LightningElement, api, track } from 'lwc';
import updateQuoteAddress from '@salesforce/apex/UpdateQuote.updateQuoteAddress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UpdateAddressOnAccount extends LightningElement {
    @api recordId; // Account ID passed automatically to the LWC on the record page
    @track addressLine1; // The address entered by the user

    // Handler to capture the input value
    handleAddressChange(event) {
        this.addressLine1 = event.target.value;
    }

    // Handler to invoke the Apex method to update related Quotes
    handleUpdateAddress() {
        if (this.addressLine1) {
            updateQuoteAddress({ accountId: this.recordId, newAddressLine1: this.addressLine1 })
                .then(() => {
                    this.showToast('Success', 'Address updated on related quotes successfully!', 'success');
                })
                .catch((error) => {
                    this.showToast('Error', error.body.message, 'error');
                });
        } else {
            this.showToast('Error', 'Please enter an address.', 'error');
        }
    }

    // Helper function to show toast messages
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}