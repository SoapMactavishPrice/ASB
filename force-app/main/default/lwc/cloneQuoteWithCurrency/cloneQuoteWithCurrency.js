import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getAvailableCurrencies from '@salesforce/apex/CloneQuoteCurrencyController.getAvailableCurrencies';
import cloneQuoteWithNewCurrency from '@salesforce/apex/CloneQuoteCurrencyController.cloneQuoteWithNewCurrency';

import QUOTE_CURRENCY_FIELD from '@salesforce/schema/Quote.CurrencyIsoCode';
import QUOTE_NAME_FIELD from '@salesforce/schema/Quote.Name';

export default class CloneQuoteWithCurrency extends NavigationMixin(LightningElement) {
    @api recordId;
    @track currencyOptions = [];
    @track selectedCurrency = '';
    @track exchangeRate = '';
    @track isLoading = false;
    currentQuoteCurrency = '';

    @wire(getRecord, { recordId: '$recordId', fields: [QUOTE_CURRENCY_FIELD, QUOTE_NAME_FIELD] })
    wiredQuote({ error, data }) {
        if (data) {
            this.currentQuoteCurrency = getFieldValue(data, QUOTE_CURRENCY_FIELD);
            this.loadCurrencies();
        } else if (error) {
            this.showToast('Error', 'Failed to load Quote details', 'error');
        }
    }

    loadCurrencies() {
        this.isLoading = true;
        getAvailableCurrencies({ currentCurrency: this.currentQuoteCurrency })
            .then(result => {
                this.currencyOptions = result.map(curr => ({
                    label: `${curr.isoCode} - ${curr.isoCode}`,
                    value: curr.isoCode
                }));
                this.isLoading = false;
            })
            .catch(error => {
                this.showToast('Error', 'Failed to load currencies: ' + this.getErrorMessage(error), 'error');
                this.isLoading = false;
            });
    }

    handleCurrencyChange(event) {
        this.selectedCurrency = event.detail.value;
        // Get exchange rate for selected currency
        getAvailableCurrencies({ currentCurrency: this.currentQuoteCurrency })
            .then(result => {
                const selectedCurr = result.find(c => c.isoCode === this.selectedCurrency);
                if (selectedCurr) {
                    this.exchangeRate = selectedCurr.conversionRate.toString();
                }
            })
            .catch(error => {
                console.error('Error fetching exchange rate:', error);
            });
    }

    get isSaveDisabled() {
        return !this.selectedCurrency || this.isLoading;
    }

    handleSave() {
        if (!this.selectedCurrency) {
            this.showToast('Warning', 'Please select a currency', 'warning');
            return;
        }

        this.isLoading = true;
        cloneQuoteWithNewCurrency({
            sourceQuoteId: this.recordId,
            newCurrency: this.selectedCurrency,
            exchangeRate: this.exchangeRate
        })
            .then(result => {
                this.isLoading = false;
                if (result.success) {
                    this.showToast('Success', 'Quote created successfully in ' + this.selectedCurrency, 'success');
                    // Navigate to the new quote
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.newQuoteId,
                            objectApiName: 'Quote',
                            actionName: 'view'
                        }
                    });
                } else {
                    this.showToast('Error', result.message || 'Failed to create quote', 'error');
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', 'Failed to create quote: ' + this.getErrorMessage(error), 'error');
            });
    }

    handleCancel() {
        // Navigate back to the quote record
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Quote',
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }

    getErrorMessage(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.message) {
            return error.message;
        } else if (typeof error === 'string') {
            return error;
        }
        return 'Unknown error occurred';
    }
}