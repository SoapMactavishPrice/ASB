import { LightningElement, api, wire } from 'lwc';
import updateQuoteAddress from '@salesforce/apex/UpdateQuote.updateQuoteAddress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UpdateQuoteAddressButton extends LightningElement {
    @api recordId; // Account record Id
    addressLine1;

    handleAddressChange(event) {
        this.addressLine1 = event.target.value;
    }

    handleUpdate() {
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

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}