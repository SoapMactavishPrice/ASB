import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getQuoteLineData from '@salesforce/apex/QuoteLineController.getQuoteLineData';
import saveQuoteLineData from '@salesforce/apex/QuoteLineController.saveQuoteLineData';

// Helper to format numbers with thousand separators
function formatNumberWithCommas(value) {
    if (value === null || value === undefined || value === '') {
        return '';
    }
    const num = typeof value === 'string' ? parseFloat(value) : value;
    if (isNaN(num)) {
        return '';
    }
    return num.toLocaleString('en-US');
}

// Helper to parse formatted numbers back to number
function parseFormattedNumber(value) {
    if (!value || value === '') {
        return null;
    }
    if (typeof value === 'number') {
        return value;
    }
    const cleaned = String(value).replace(/,/g, '');
    const parsed = parseFloat(cleaned);
    return isNaN(parsed) ? null : parsed;
}

// Helper to round to 2 decimal places
function roundToTwoDecimals(value) {
    if (value === null || value === undefined || value === '') {
        return null;
    }
    const num = typeof value === 'string' ? parseFloat(value) : value;
    if (isNaN(num)) {
        return null;
    }
    return Math.round(num * 100) / 100;
}

function roundToTwoDecimalsAndFormatInteger(value) {
    if (value === null || value === undefined || value === '') {
        return null;
    }
    const num = typeof value === 'string' ? parseFloat(value) : value;
    if (isNaN(num)) {
        return null;
    }
    return formatNumberWithCommas(Math.round(num * 100) / 100);
}

export default class QuoteLineTable extends NavigationMixin(LightningElement) {
    @api recordId;
    @track tableData = [];
    @track isLoading = false;
    @track showAdditionalColumns = false;
    originalData = [];

    get toggleIcon() {
        return this.showAdditionalColumns ? 'utility:chevronleft' : 'utility:chevronright';
    }

    get tableClasses() {
        let classes = 'slds-table slds-table_cell-buffer slds-table_bordered';
        if (this.showAdditionalColumns) {
            classes += ' slds-table_fixed-layout';
        } else {
            classes += ' slds-table_fixed-layout';
        }
        return classes;
    }

    handleToggleColumns() {
        this.showAdditionalColumns = !this.showAdditionalColumns;
    }

    setDisableFlags(row) {
        const isBlank = (v) =>
            v === null ||
            v === undefined ||
            v === 0 ||
            (typeof v === 'string' && v.trim() === '') ||
            (typeof v === 'number' && Number.isNaN(v));

        const hasDesired = !isBlank(row.desiredPrice);
        const hasPercent = !isBlank(row.discountPercent);
        const hasValue = !isBlank(row.discountValue);

        row.disableDiscounts = hasDesired;
        row.disableDesiredPrice = hasPercent || hasValue;
    }

    hasAnyPricingInputs(srNo) {
        return this.tableData.some(row => {
            if (row.srNo === srNo && (row.isLineItem || row.isOption)) {
                const isBlank = (v) =>
                    v === null ||
                    v === undefined ||
                    v === 0 ||
                    (typeof v === 'string' && v.trim() === '') ||
                    (typeof v === 'number' && Number.isNaN(v));
                
                const hasPercent = !isBlank(row.discountPercent);
                const hasValue = !isBlank(row.discountValue);
                const hasDesired = !isBlank(row.desiredPrice);
                
                return hasPercent || hasValue || hasDesired;
            }
            return false;
        });
    }

    hasAnyPricingInputsForItems(items, srNo) {
        const isBlank = (v) =>
            v === null ||
            v === undefined ||
            v === 0 ||
            (typeof v === 'string' && v.trim() === '') ||
            (typeof v === 'number' && Number.isNaN(v));

        for (let item of items) {
            if (item.Sr_No__c === srNo) {
                const lineHasPercent = !isBlank(item.Discount__c);
                const lineHasValue = !isBlank(item.Discount_in_Value__c);
                const lineHasDesired = !isBlank(item.Desired_Price__c);
                
                if (lineHasPercent || lineHasValue || lineHasDesired) {
                    return true;
                }

                if (item.Quote_Line_Options__r) {
                    for (let option of item.Quote_Line_Options__r) {
                        const optHasPercent = !isBlank(option.Discount__c);
                        const optHasValue = !isBlank(option.Discount_in_Value__c);
                        const optHasDesired = !isBlank(option.Desired_Price__c);
                        
                        if (optHasPercent || optHasValue || optHasDesired) {
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }
    
    @wire(getQuoteLineData, { quoteId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            this.processData(data.lineItems);
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    processData(lineItems) {
        let rows = [];
        let grandTotalDiscount = 0;
        lineItems.forEach(item => {
            const hasDesiredPriceSubtotal = item.Desired_Price_Subtotal__c !== null && 
                                           item.Desired_Price_Subtotal__c !== undefined && 
                                           item.Desired_Price_Subtotal__c !== 0;
            
            const lineRow = {
                id: item.Id,
                type: 'lineItem',
                srNo: item.Sr_No__c,
                optNo: '',
                name: item.Product_Name__c,
                unitTransferPrice: roundToTwoDecimalsAndFormatInteger(item.Base_Price__c),
                quantity: item.Quantity__c,
                totalQuantity: item.Quantity__c,
                totalTransferPrice: roundToTwoDecimalsAndFormatInteger(item.Total_Base_Price__c),
                unitListPrice: roundToTwoDecimalsAndFormatInteger(item.List_Price__c),
                totalListPrice: roundToTwoDecimalsAndFormatInteger(item.Total_List_Price2__c),
                discountPercent: roundToTwoDecimals(item.Discount__c),
                discountValue: roundToTwoDecimals(item.Discount_in_Value__c),
                desiredPrice: roundToTwoDecimals(item.Desired_Price__c),
                desiredPriceSubtotal: roundToTwoDecimals(item.Desired_Price_Subtotal__c),
                discountAllowed: roundToTwoDecimals(item.Discount_Allowed_New__c),
                totalDiscountInValue: roundToTwoDecimals(item.Discount_Value__c),
                totalDiscountInValueFormatted: roundToTwoDecimalsAndFormatInteger(item.Discount_Value__c),
                salesPrice: roundToTwoDecimals(item.Average_Sales_Price__c),
                salesPriceFormatted: roundToTwoDecimalsAndFormatInteger(item.Average_Sales_Price__c),
                totalSalesPrice: roundToTwoDecimals(item.Sales_Price__c),
                totalSalesPriceFormatted: roundToTwoDecimalsAndFormatInteger(item.Sales_Price__c),
                salesMargin: roundToTwoDecimals(item.Sales_Margin__c),
                m1: roundToTwoDecimals(item.M1__c),
                m2: roundToTwoDecimals(item.M2__c),
                m3: roundToTwoDecimals(item.M3__c),
                parentQuantity: 0,
                isEditable: true,
                isLineItem: true,
                isOption: false,
                isSubtotal: false,
                isGrandTotal: false,
                displayPDFName: true,
                displayPDFAmount: true,
                showDiscountInputs: true,
                showDesiredPriceSubtotal: false,
                showCheckboxes: false,
                showCopyCheckbox: true,
                copyToOptions: false,
                disableDiscounts: hasDesiredPriceSubtotal,
                disableDesiredPrice: hasDesiredPriceSubtotal
            };
            if (!hasDesiredPriceSubtotal) {
                this.setDisableFlags(lineRow);
            }
            rows.push(lineRow);
            let subtotalDiscountInValue = lineRow.totalDiscountInValue || 0;
            if (item.Quote_Line_Options__r) {
                item.Quote_Line_Options__r.forEach(option => {
                    const optRow = {
                        id: option.Id,
                        type: 'option',
                        parentId: item.Id,
                        srNo: item.Sr_No__c,
                        optNo: option.Serial_Number__c,
                        name: option.Manual_Product_Name__c,
                        unitTransferPrice: 0,
                        quantity: option.Quantity__c,
                        totalQuantity: option.Quantity__c,
                        totalTransferPrice: roundToTwoDecimalsAndFormatInteger(option.Base_price_Total__c),
                        unitListPrice: roundToTwoDecimalsAndFormatInteger(option.Manula_Option_List_Price__c),
                        totalListPrice: roundToTwoDecimalsAndFormatInteger(option.Total_Option_List_Price__c),
                        discountPercent: roundToTwoDecimals(option.Discount__c),
                        discountValue: roundToTwoDecimals(option.Discount_in_Value__c),
                        desiredPrice: roundToTwoDecimals(option.Desired_Price__c),
                        desiredPriceSubtotal: null,
                        discountAllowed: roundToTwoDecimals(option.Discount_Allowed_New__c),
                        totalDiscountInValue: roundToTwoDecimals(option.Discount_Value__c * item.Quantity__c),
                        totalDiscountInValueFormatted: roundToTwoDecimalsAndFormatInteger(option.Discount_Value__c * item.Quantity__c),
                        salesPrice: roundToTwoDecimals(option.Average_Sales_Price__c),
                        salesPriceFormatted: roundToTwoDecimalsAndFormatInteger(option.Average_Sales_Price__c),
                        totalSalesPrice: roundToTwoDecimals(option.Final_Sales_Price__c),
                        totalSalesPriceFormatted: roundToTwoDecimalsAndFormatInteger(option.Final_Sales_Price__c),
                        salesMargin: roundToTwoDecimals(option.Sales_Margin__c),
                        m1: roundToTwoDecimals(option.P_M1__c),
                        m2: roundToTwoDecimals(option.P_M2__c),
                        m3: roundToTwoDecimals(option.P_M3__c),
                        parentQuantity: item.Quantity__c,
                        isEditable: true,
                        isLineItem: false,
                        isOption: true,
                        isSubtotal: false,
                        isGrandTotal: false,
                        displayPDFName: option.Display_PDF_Name__c,
                        displayPDFAmount: option.Display_PDF_Amount__c,
                        showDiscountInputs: true,
                        showDesiredPriceSubtotal: false,
                        showCheckboxes: true,
                        showCopyCheckbox: false,
                        copyToOptions: false,
                        disableDiscounts: hasDesiredPriceSubtotal,
                        disableDesiredPrice: hasDesiredPriceSubtotal
                    };
                    if (!hasDesiredPriceSubtotal) {
                        this.setDisableFlags(optRow);
                    }
                    rows.push(optRow);
                    subtotalDiscountInValue += optRow.totalDiscountInValue || 0;
                });
            }

            if (lineRow.desiredPriceSubtotal && lineRow.desiredPriceSubtotal > 0) {
                subtotalDiscountInValue = item.Total_List_Price__c - lineRow.desiredPriceSubtotal;
            }
            grandTotalDiscount += subtotalDiscountInValue;

            rows.push({
                id: item.Id + '_subtotal',
                type: 'subtotal',
                parentId: item.Id,
                srNo: item.Sr_No__c,
                optNo: '',
                name: '',
                unitTransferPrice: '',
                quantity: '',
                totalQuantity: '',
                totalTransferPrice: roundToTwoDecimalsAndFormatInteger(item.Total_Base_Price_including_Options__c),
                unitListPrice: '',
                totalListPrice: roundToTwoDecimalsAndFormatInteger(item.Total_List_Price__c),
                discountPercent: '',
                discountValue: '',
                desiredPrice: '',
                desiredPriceSubtotal: roundToTwoDecimals(item.Desired_Price_Subtotal__c),
                discountAllowed: '',
                totalDiscountInValue: roundToTwoDecimals(subtotalDiscountInValue),
                totalDiscountInValueFormatted: roundToTwoDecimalsAndFormatInteger(subtotalDiscountInValue),
                salesPrice: '',
                salesPriceFormatted: '',
                totalSalesPrice: roundToTwoDecimals(item.Total_Sales_Price_including_Options__c),
                totalSalesPriceFormatted: roundToTwoDecimalsAndFormatInteger(item.Total_Sales_Price_including_Options__c),
                salesMargin: roundToTwoDecimals(item.Sales_Margin_including_Options__c),
                m1: '',
                m2: '',
                m3: '',
                isEditable: false,
                isLineItem: false,
                isOption: false,
                isSubtotal: true,
                isGrandTotal: false,
                displayPDFName: false,
                displayPDFAmount: false,
                showDiscountInputs: false,
                showDesiredPriceSubtotal: true,
                showCheckboxes: false,
                showCopyCheckbox: false,
                copyToOptions: false,
                disableDesiredPriceSubtotal: this.hasAnyPricingInputsForItems(lineItems, item.Sr_No__c)
            });
        });
        
        let grandTotalTransferPrice = 0;
        let grandTotalListPrice = 0;
        let grandTotalDiscountInValue = grandTotalDiscount;
        let grandTotalSalesPrice = 0;
        let grandSalesMargin = 0;
        
        lineItems.forEach(item => {
            if (item.Quote__r) {
                if (item.Quote__r.Quote_Total_Base_Price__c) {
                    grandTotalTransferPrice = item.Quote__r.Quote_Total_Base_Price__c;
                }
                if (item.Quote__r.Quote_Total_List_Price__c) {
                    grandTotalListPrice = item.Quote__r.Quote_Total_List_Price__c;
                }
                if (item.Quote__r.Quote_Totoal__c) {
                    grandTotalSalesPrice = item.Quote__r.Quote_Totoal__c;
                }
                if (item.Quote__r.Sales_Margin__c) {
                    grandSalesMargin = item.Quote__r.Sales_Margin__c;
                }
            }
        });
        
        rows.push({
            id: 'grandtotal',
            type: 'grandtotal',
            srNo: '',
            optNo: '',
            name: '',
            unitTransferPrice: '',
            quantity: '',
            totalQuantity: '',
            totalTransferPrice: roundToTwoDecimalsAndFormatInteger(grandTotalTransferPrice),
            unitListPrice: '',
            totalListPrice: roundToTwoDecimalsAndFormatInteger(grandTotalListPrice),
            discountPercent: '',
            discountValue: '',
            desiredPrice: '',
            desiredPriceSubtotal: '',
            discountAllowed: '',
            totalDiscountInValue: roundToTwoDecimals(grandTotalDiscountInValue),
            totalDiscountInValueFormatted: roundToTwoDecimalsAndFormatInteger(grandTotalDiscountInValue),
            salesPrice: '',
            salesPriceFormatted: '',
            totalSalesPrice: roundToTwoDecimals(grandTotalSalesPrice),
            totalSalesPriceFormatted: roundToTwoDecimalsAndFormatInteger(grandTotalSalesPrice),
            salesMargin: roundToTwoDecimals(grandSalesMargin),
            m1: '',
            m2: '',
            m3: '',
            isEditable: false,
            isLineItem: false,
            isOption: false,
            isSubtotal: false,
            isGrandTotal: true,
            displayPDFName: false,
            displayPDFAmount: false,
            showDiscountInputs: false,
            showDesiredPriceSubtotal: false,
            showCheckboxes: false,
            showCopyCheckbox: false,
            copyToOptions: false
        });
        
        this.tableData = rows;
        this.originalData = JSON.parse(JSON.stringify(rows));
    }

    handleCopyCheckboxChange(event) {
        const lineItemId = event.target.dataset.id;
        
        const lineItemIndex = this.tableData.findIndex(row => row.id === lineItemId);
        if (lineItemIndex !== -1) {
            const lineItem = this.tableData[lineItemIndex];
            
            if (lineItem.discountPercent !== null && lineItem.discountPercent !== undefined) {
                const discountPercent = lineItem.discountPercent;
                
                for (let i = 0; i < this.tableData.length; i++) {
                    const row = this.tableData[i];
                    if (!row.disableDiscounts) {
                        if (row.isOption && row.parentId === lineItemId) {
                            row.discountPercent = discountPercent;
                            // row.discountValue = null;
                            // row.desiredPrice = null;
                            // this.setDisableFlags(row);
                            this.calculateDiscounts(i);
                        }
                    }
                }
            }
        }
        
        this.tableData = [...this.tableData];
    }
    
    handleInputChange(event) {
        const rowId = event.target.dataset.id;
        const field = event.target.dataset.field;
        let value = event.target.value;

        if (
            field === 'discountPercent' ||
            field === 'discountValue' ||
            field === 'desiredPrice' ||
            field === 'desiredPriceSubtotal'
        ) {
            const raw = typeof value === 'string' ? value.trim() : value;
            const parsedValue = raw !== '' && raw !== null && raw !== undefined ? parseFormattedNumber(raw) : null;
            value = roundToTwoDecimals(parsedValue);
        }

        const rowIndex = this.tableData.findIndex((row) => row.id === rowId);
        if (rowIndex !== -1) {
            const row = this.tableData[rowIndex];

            if (field === 'desiredPrice') {
                row.desiredPrice = value;
                if (value !== null) {
                    row.discountPercent = null;
                    row.discountValue = null;
                }
            } else if (field === 'discountPercent') {
                row.discountPercent = value;
                if (value !== null) {
                    row.desiredPrice = null;
                }
                
                // If this is a line item and copy checkbox is checked, copy to options
                if (row.isLineItem && row.copyToOptions) {
                    for (let i = 0; i < this.tableData.length; i++) {
                        const optRow = this.tableData[i];
                        if (optRow.isOption && optRow.parentId === rowId) {
                            optRow.discountPercent = value;
                            optRow.discountValue = null;
                            optRow.desiredPrice = null;
                            this.setDisableFlags(optRow);
                            this.calculateDiscounts(i);
                        }
                    }
                }
            } else if (field === 'discountValue') {
                row.discountValue = value;
                if (value !== null) {
                    row.desiredPrice = null;
                }
            } else if (field === 'desiredPriceSubtotal') {
                row.desiredPriceSubtotal = value;

                if (value !== null) {
                    row.discountPercent = null;
                    row.discountValue = null;
                    row.desiredPrice = null;
                }
            } else {
                row[field] = value;
            }

            this.setDisableFlags(row);

            if (row.isLineItem || row.isOption) {
                const subtotalIndex = this.tableData.findIndex(r => 
                    r.srNo === row.srNo && r.isSubtotal
                );
                if (subtotalIndex !== -1) {
                    const hasPricingInputs = this.hasAnyPricingInputs(row.srNo);
                    this.tableData[subtotalIndex].disableDesiredPriceSubtotal = hasPricingInputs;
                }
            }

            if (row.isSubtotal) {
                const parentIndex = this.tableData.findIndex(r => r.id === row.parentId && r.isLineItem);
                if (parentIndex !== -1) {
                    const parent = this.tableData[parentIndex];
                    const subtotalEntered = row.desiredPriceSubtotal !== null && row.desiredPriceSubtotal !== 0;

                    if (subtotalEntered) {
                        parent.discountPercent = null;
                        parent.discountValue = null;
                        parent.desiredPrice = null;
                        parent.disableDiscounts = true;
                        parent.disableDesiredPrice = true;

                        for (let i = 0; i < this.tableData.length; i++) {
                            const r = this.tableData[i];
                            if (r.isOption && r.parentId === parent.id) {
                                r.discountPercent = null;
                                r.discountValue = null;
                                r.desiredPrice = null;
                                r.disableDiscounts = true;
                                r.disableDesiredPrice = true;
                            }
                        }
                    } else {
                        this.setDisableFlags(parent);
                        for (let i = 0; i < this.tableData.length; i++) {
                            const r = this.tableData[i];
                            if (r.isOption && r.parentId === parent.id) {
                                this.setDisableFlags(r);
                            }
                        }
                    }
                }
            }

            if (row.isLineItem || row.isOption) {
                this.calculateDiscounts(rowIndex);
            }

            if (row.isSubtotal) {
                this.calculateSubtotalDiscounts(rowIndex);
            }
        }
    }
    
    calculateDiscounts(rowIndex) {
        const row = this.tableData[rowIndex];
        const totalListPrice = parseFormattedNumber(row.totalListPrice) || 0;
        const totalTransferPrice = parseFormattedNumber(row.totalTransferPrice) || 0;
        const totalQuantity = row.parentQuantity || 1;
        let calculatedDiscount = 0;
        
        if (row.desiredPrice !== null && row.desiredPrice !== undefined && row.desiredPrice !== 0) {
            calculatedDiscount = totalListPrice - row.desiredPrice;
            row.totalDiscountInValue = roundToTwoDecimals(calculatedDiscount);
            row.totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(calculatedDiscount);
            row.discountPercent = null;
            row.discountValue = null;
        } else if (
            row.discountPercent !== null && row.discountPercent !== undefined && row.discountPercent !== 0 &&
            row.discountValue !== null && row.discountValue !== undefined && row.discountValue !== 0
        ) {
            const discountFromPercent = (totalListPrice * row.discountPercent) / 100;
            calculatedDiscount = discountFromPercent + row.discountValue;
            row.totalDiscountInValue = roundToTwoDecimals(calculatedDiscount);
            row.totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(calculatedDiscount);
        } else if (row.discountPercent !== null && row.discountPercent !== undefined && row.discountPercent !== 0) {
            calculatedDiscount = (totalListPrice * row.discountPercent) / 100;
            row.totalDiscountInValue = roundToTwoDecimals(calculatedDiscount);
            row.totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(calculatedDiscount);
        } else if (row.discountValue !== null && row.discountValue !== undefined && row.discountValue !== 0) {
            calculatedDiscount = row.discountValue;
            row.totalDiscountInValue = roundToTwoDecimals(calculatedDiscount);
            row.totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(calculatedDiscount);
        } else {
            row.totalDiscountInValue = 0;
            row.totalDiscountInValueFormatted = '0';
        }

        // Calculate salesPrice, totalSalesPrice, and salesMargin
        const salesPrice = totalQuantity !== 0 ? (totalListPrice-row.totalDiscountInValue) / totalQuantity : 0;
        row.salesPrice = roundToTwoDecimals(salesPrice);
        row.salesPriceFormatted = roundToTwoDecimalsAndFormatInteger(salesPrice);
        
        const totalSalesPrice = salesPrice * totalQuantity;
        row.totalSalesPrice = roundToTwoDecimals(totalSalesPrice);
        row.totalSalesPriceFormatted = roundToTwoDecimalsAndFormatInteger(totalSalesPrice);
        
        if (totalSalesPrice === 0) {
            row.salesMargin = '-';
        } else {
            let margin = (salesPrice - totalTransferPrice) / salesPrice;
            if (salesPrice < 0) {
                margin = -margin;
            }
            margin *= 100;
            row.salesMargin = roundToTwoDecimals(margin);
        }
        
        if (row.isLineItem || row.isOption) {
            this.updateSubtotal(row.srNo);
        }
        
        this.tableData = [...this.tableData];
    }
    
    calculateSubtotalDiscounts(rowIndex) {
        const row = this.tableData[rowIndex];
        const totalListPrice = parseFormattedNumber(row.totalListPrice) || 0;
        
        if (row.desiredPriceSubtotal !== null && row.desiredPriceSubtotal !== undefined && row.desiredPriceSubtotal !== 0) {
            const calculatedDiscount = totalListPrice - row.desiredPriceSubtotal;
            row.totalDiscountInValue = roundToTwoDecimals(calculatedDiscount);
            row.totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(calculatedDiscount);
            
            const lineItemIndex = this.tableData.findIndex(r => r.id === row.parentId && r.isLineItem);
            if (lineItemIndex !== -1) {
                const parent = this.tableData[lineItemIndex];
                parent.desiredPriceSubtotal = row.desiredPriceSubtotal;

                parent.disableDiscounts = true;
                parent.disableDesiredPrice = true;

                for (let i = 0; i < this.tableData.length; i++) {
                    const opt = this.tableData[i];
                    if (opt.isOption && opt.parentId === parent.id) {
                        opt.disableDiscounts = true;
                        opt.disableDesiredPrice = true;
                    }
                }
            }
        } else {
            const relatedRows = this.tableData.filter(r => 
                r.srNo === row.srNo && (r.isLineItem || r.isOption)
            );
            
            let totalDiscountInValue = 0;
            relatedRows.forEach(r => {
                totalDiscountInValue += r.totalDiscountInValue || 0;
            });
            
            row.totalDiscountInValue = roundToTwoDecimals(totalDiscountInValue);
            row.totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(totalDiscountInValue);
            
            const lineItemIndex = this.tableData.findIndex(r => r.id === row.parentId && r.isLineItem);
            if (lineItemIndex !== -1) {
                const parent = this.tableData[lineItemIndex];
                parent.desiredPriceSubtotal = null;
                this.setDisableFlags(parent);
                
                for (let i = 0; i < this.tableData.length; i++) {
                    const opt = this.tableData[i];
                    if (opt.isOption && opt.parentId === parent.id) {
                        this.setDisableFlags(opt);
                    }
                }
            }
        }
        
        // Calculate totalSalesPrice and salesMargin for subtotal
        const totalTransferPrice = parseFormattedNumber(row.totalTransferPrice) || 0;
        const totalSalesPrice = totalListPrice - row.totalDiscountInValue;
        row.totalSalesPrice = roundToTwoDecimals(totalSalesPrice);
        row.totalSalesPriceFormatted = roundToTwoDecimalsAndFormatInteger(totalSalesPrice);
        
        // Calculate salesMargin for subtotal
        if (totalSalesPrice === 0) {
            row.salesMargin = '-';
        } else {
            let margin = (totalSalesPrice - totalTransferPrice) / totalSalesPrice;
            if (totalSalesPrice < 0) {
                margin = -margin;
            }
            row.salesMargin = roundToTwoDecimals(margin);
        }
        
        this.updateGrandTotal();
        
        this.tableData = [...this.tableData];
    }
    
    updateSubtotal(srNo) {
        const relatedRows = this.tableData.filter(r => 
            r.srNo === srNo && (r.isLineItem || r.isOption)
        );
        
        const subtotalIndex = this.tableData.findIndex(r => 
            r.srNo === srNo && r.isSubtotal
        );
        
        if (subtotalIndex !== -1) {
            let totalDiscountInValue = 0;
            relatedRows.forEach(r => {
                totalDiscountInValue += r.totalDiscountInValue || 0;
            });
            
            this.tableData[subtotalIndex].totalDiscountInValue = roundToTwoDecimals(totalDiscountInValue);
            this.tableData[subtotalIndex].totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(totalDiscountInValue);
            
            // Recalculate subtotal's totalSalesPrice and salesMargin
            const subtotalRow = this.tableData[subtotalIndex];
            const totalListPrice = parseFormattedNumber(subtotalRow.totalListPrice) || 0;
            const totalTransferPrice = parseFormattedNumber(subtotalRow.totalTransferPrice) || 0;
            const totalSalesPrice = totalListPrice - subtotalRow.totalDiscountInValue;
            
            subtotalRow.totalSalesPrice = roundToTwoDecimals(totalSalesPrice);
            subtotalRow.totalSalesPriceFormatted = roundToTwoDecimalsAndFormatInteger(totalSalesPrice);
            
            if (totalSalesPrice === 0) {
                subtotalRow.salesMargin = '-';
            } else {
                let margin = (totalSalesPrice - totalTransferPrice) / totalSalesPrice;
                if (totalSalesPrice < 0) {
                    margin = -margin;
                }
                margin *= 100;
                subtotalRow.salesMargin = roundToTwoDecimals(margin);
            }
        }
        
        this.updateGrandTotal();
    }
    
    updateGrandTotal() {
        const grandTotalIndex = this.tableData.findIndex(r => r.isGrandTotal);
        
        if (grandTotalIndex !== -1) {
            let grandTotalDiscountInValue = 0;
            let grandTotalListPrice = 0;
            let grandTotalTransferPrice = 0;
            
            this.tableData.forEach(row => {
                if (row.isSubtotal) {
                    grandTotalDiscountInValue += row.totalDiscountInValue || 0;
                    grandTotalListPrice += parseFormattedNumber(row.totalListPrice) || 0;
                    grandTotalTransferPrice += parseFormattedNumber(row.totalTransferPrice) || 0;
                }
            });
            
            this.tableData[grandTotalIndex].totalDiscountInValue = roundToTwoDecimals(grandTotalDiscountInValue);
            this.tableData[grandTotalIndex].totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(grandTotalDiscountInValue);
            
            // Calculate grand total's totalSalesPrice and salesMargin
            const grandTotalSalesPrice = grandTotalListPrice - grandTotalDiscountInValue;
            this.tableData[grandTotalIndex].totalSalesPrice = roundToTwoDecimals(grandTotalSalesPrice);
            this.tableData[grandTotalIndex].totalSalesPriceFormatted = roundToTwoDecimalsAndFormatInteger(grandTotalSalesPrice);
            
            if (grandTotalSalesPrice === 0) {
                this.tableData[grandTotalIndex].salesMargin = '-';
            } else {
                let margin = (grandTotalSalesPrice - grandTotalTransferPrice) / grandTotalSalesPrice;
                if (grandTotalSalesPrice < 0) {
                    margin = -margin;
                }
                margin *= 100;
                this.tableData[grandTotalIndex].salesMargin = roundToTwoDecimals(margin);
            }
        }
    }
    
    handleCheckboxChange(event) {
        const rowId = event.target.dataset.id;
        const field = event.target.dataset.field;
        const value = event.target.checked;
        
        const rowIndex = this.tableData.findIndex(row => row.id === rowId);
        if (rowIndex !== -1) {
            this.tableData[rowIndex][field] = value;
        }
    }
    
    handleSave() {
        this.isLoading = true;
        
        const lineItemsToUpdate = [];
        const optionsToUpdate = [];
        
        this.tableData.forEach(row => {
            if (row.isLineItem) {
                lineItemsToUpdate.push({
                    Id: row.id,
                    Discount__c: row.discountPercent,
                    Discount_in_Value__c: row.discountValue,
                    Desired_Price__c: row.desiredPrice,
                    Desired_Price_Subtotal__c: row.desiredPriceSubtotal
                });
            } else if (row.isOption) {
                optionsToUpdate.push({
                    Id: row.id,
                    Discount__c: row.discountPercent,
                    Discount_in_Value__c: row.discountValue,
                    Desired_Price__c: row.desiredPrice
                });
            }
        });
        
        saveQuoteLineData({
            lineItemsJson: JSON.stringify(lineItemsToUpdate),
            optionsJson: JSON.stringify(optionsToUpdate)
        })
        .then(result => {
            if (result.success) {
                this.showToast('Success', result.message, 'success');
                this.navigateToQuote();
            } else {
                throw new Error(result.message);
            }
        })
        .then(data => {
            if (data) {
                this.processData(data.lineItems);
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.showToast('Error', error.body?.message || error.message, 'error');
            this.isLoading = false;
        });
    }

    formatNumber(value) {
        if (value === null || value === undefined || value === '') {
            return '';
        }

        let num = Number(value);
        num = Number(num.toFixed(2));
        return num.toLocaleString('en-IN');
    }

    navigateToQuote() {
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
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}