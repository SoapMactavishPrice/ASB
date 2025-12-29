import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import getPricebooks from '@salesforce/apex/QuotePriceRecalculationController.getPricebooks';
import validateProductsInPricebook from '@salesforce/apex/QuotePriceRecalculationController.validateProductsInPricebook';
import recalculateQuotePrice from '@salesforce/apex/QuotePriceRecalculationController.recalculateQuotePrice';

export default class QuotePriceRecalculation extends NavigationMixin(LightningElement) {
    @api
    set recordId(value) {
        if (value) {
            this._recordId = value;
            console.log('QuoteId received:', value);
            this.loadPricebooks();
        }
    }
    get recordId() {
        return this._recordId;
    }

    @track pricebookOptions = [];
    @track selectedPricebookId = '';
    @track isLoading = false;
    @track showModal = true;
    @track errorMessage = '';

    // connectedCallback() {
    //     console.log('QuoteId received: ' + this.recordId);
    //     this.loadPricebooks();
    // }

    loadPricebooks() {
        this.isLoading = true;
        this.errorMessage = '';
        
        getPricebooks({ recordId: this.recordId })
            .then(result => {
                if (result && result.length > 0) {
                    this.pricebookOptions = result.map(item => ({
                        label: item.label,
                        value: item.value
                    }));
                } else {
                    this.errorMessage = 'No active pricebooks found for this subsidiary.';
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.errorMessage = error.body ? error.body.message : 'Error loading pricebooks';
                this.isLoading = false;
                this.showToast('Error', this.errorMessage, 'error');
            });
    }

    handlePricebookChange(event) {
        this.selectedPricebookId = event.detail.value;
        this.errorMessage = '';
    }

    handleCancel() {
        this.closeModal();
    }

    handleRecalculate() {
        if (!this.selectedPricebookId) {
            this.errorMessage = 'Please select a pricebook.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';

        validateProductsInPricebook({ 
            quoteId: this.recordId, 
            selectedPricebookId: this.selectedPricebookId 
        })
            .then(validationResult => {
                if (validationResult.success) {
                    return this.performRecalculation();
                } else {
                    this.errorMessage = validationResult.message;
                    this.isLoading = false;
                    this.showToast('Validation Error', validationResult.message, 'error');
                    throw new Error(validationResult.message);
                }
            })
            .catch(error => {
                this.isLoading = false;
                if (error.message !== this.errorMessage) {
                    this.errorMessage = error.body ? error.body.message : error.message;
                    this.showToast('Error', this.errorMessage, 'error');
                }
            });
    }

    performRecalculation() {
        recalculateQuotePrice({
            quoteId: this.recordId,
            selectedPricebookId: this.selectedPricebookId
        }).then(result => {
            this.isLoading = false;
            this.showToast('Success', result, 'success');
            this.closeModal();
            this.navigateToQuoteRecord();
        }).catch(error => {
            this.isLoading = false;
            this.errorMessage = error.body ? error.body.message : 'Error during price recalculation';
            this.showToast('Error', this.errorMessage, 'error');
        });
    }

    // Close the modal
    closeModal() {
        this.showModal = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // Navigate to Quote detail page
    navigateToQuoteRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Quote',
                actionName: 'view'
            }
        });
    }

    // Show toast notification
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // Getter for disabling OK button
    get isOkDisabled() {
        return !this.selectedPricebookId || this.isLoading;
    }

    // Getter for showing error message
    get hasError() {
        return this.errorMessage !== '';
    }
}