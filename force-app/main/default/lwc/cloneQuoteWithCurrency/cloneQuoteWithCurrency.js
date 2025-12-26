import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getAvailableCurrencies from '@salesforce/apex/CloneQuoteCurrencyController.getAvailableCurrencies';
import cloneQuoteWithNewCurrency from '@salesforce/apex/CloneQuoteCurrencyController.cloneQuoteWithNewCurrency';

import QUOTE_CURRENCY_FIELD from '@salesforce/schema/Quote.CurrencyIsoCode';
import QUOTE_NAME_FIELD from '@salesforce/schema/Quote.Name';
import QUOTE_HAS_MANUAL_FIELD from '@salesforce/schema/Quote.Has_Manual_Item_or_Option__c';
import QUOTE_OPPORTUNITY_ID from '@salesforce/schema/Quote.OpportunityId';
import OPPORTUNITY_NAME_FIELD from '@salesforce/schema/Opportunity.Name';

export default class CloneQuoteWithCurrency extends NavigationMixin(LightningElement) {
    @api recordId;
    @track currencyOptions = [];
    @track selectedCurrency = '';
    @track exchangeRate = '1';
    @track opportunityName = '';
    @track quoteName = '';
    @track isLoading = false;
    @track isExchangeRateDisabled = true;
    currentQuoteCurrency = '';
    currentOpportunityId = '';

    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: [QUOTE_CURRENCY_FIELD, QUOTE_NAME_FIELD, QUOTE_HAS_MANUAL_FIELD, QUOTE_OPPORTUNITY_ID] 
    })
    wiredQuote({ error, data }) {
        if (data) {
            this.currentQuoteCurrency = getFieldValue(data, QUOTE_CURRENCY_FIELD);
            this.quoteName = getFieldValue(data, QUOTE_NAME_FIELD);
            this.currentOpportunityId = getFieldValue(data, QUOTE_OPPORTUNITY_ID);
            
            // Check if exchange rate should be enabled
            const hasManualItemOrOption = getFieldValue(data, QUOTE_HAS_MANUAL_FIELD);
            this.isExchangeRateDisabled = !hasManualItemOrOption;
            
            this.loadCurrencies();
        } else if (error) {
            this.showToast('Error', 'Failed to load Quote details', 'error');
        }
    }

    @wire(getRecord, {
        recordId: '$currentOpportunityId',
        fields: [OPPORTUNITY_NAME_FIELD]
    })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.opportunityName = getFieldValue(data, OPPORTUNITY_NAME_FIELD);
        } else if (error) {
            console.error('Failed to load Opportunity name', error);
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
    }

    handleOpportunityNameChange(event) {
        this.opportunityName = event.detail.value;
    }

    handleQuoteNameChange(event) {
        this.quoteName = event.detail.value;
    }

    handleExchangeRateChange(event) {
        this.exchangeRate = event.detail.value;
    }

    get isSaveDisabled() {
        return !this.selectedCurrency || !this.opportunityName || !this.quoteName || !this.exchangeRate || this.isLoading;
    }

    get calculatedResult() {
        const rate = parseFloat(this.exchangeRate) || 1;
        return (1000 * rate).toFixed(2);
    }

    handleSave() {
        if (!this.selectedCurrency) {
            this.showToast('Warning', 'Please select a currency', 'warning');
            return;
        }
        if (!this.opportunityName) {
            this.showToast('Warning', 'Please enter an Opportunity Name', 'warning');
            return;
        }
        if (!this.quoteName) {
            this.showToast('Warning', 'Please enter a Quote Name', 'warning');
            return;
        }
        if (!this.exchangeRate) {
            this.showToast('Warning', 'Please enter an Exchange Rate', 'warning');
            return;
        }

        this.isLoading = true;
        cloneQuoteWithNewCurrency({
            sourceQuoteId: this.recordId,
            newCurrency: this.selectedCurrency,
            exchangeRate: this.exchangeRate,
            opportunityName: this.opportunityName,
            quoteName: this.quoteName
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