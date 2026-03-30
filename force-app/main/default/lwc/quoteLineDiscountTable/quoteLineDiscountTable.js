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
    const rounded = Math.round(num * 100) / 100;
    return rounded === 0 ? null : rounded.toFixed(2);
}

function roundToWholeNumber(value) {
    if (value === null || value === undefined || value === '') {
        return null;
    }
    const num = typeof value === 'string' ? parseFloat(value) : value;
    if (isNaN(num)) {
        return null;
    }
    const rounded = Math.ceil(num * 100) / 100;
    return rounded === 0 ? null : rounded.toFixed(0);
}

function roundToTwoDecimalsAndFormatInteger(value) {
    if (value === null || value === undefined || value === '') {
        return null;
    }
    const num = typeof value === 'string' ? parseFloat(value) : value;
    if (isNaN(num)) {
        return null;
    }
    const rounded = Math.round(num * 100) / 100;
    return rounded === 0 ? null : formatNumberWithCommas(rounded);
}

function roundToWholeNumberAndFormatInteger(value) {
    if (value === null || value === undefined || value === '') {
        return null;
    }
    const num = typeof value === 'string' ? parseFloat(value) : value;
    if (isNaN(num)) {
        return null;
    }
    const rounded = Math.ceil(num * 100) / 100;
    return rounded === 0 ? null : formatNumberWithCommas(rounded.toFixed(0));
}

function calculatePercentage(percent, value) {
    if (percent && value) {
        return (percent / 100) * value;
    }
}

export default class QuoteLineTable extends NavigationMixin(LightningElement) {
    @api recordId;
    @track tableData = [];
    @track isLoading = false;
    @track showAdditionalColumns = false;
    @track quoteName = '';
    @track quoteCurrency = '';
    originalData = [];
    shouldScrollRightOnExpand = false;

    get quoteNameHeader() {
        return `Quote: ${this.quoteName}    |    Currency: ${this.quoteCurrency}`;
    }

    get toggleIcon() {
        return this.showAdditionalColumns ? 'utility:chevronleft' : 'utility:chevronright';
    }

    get tableClasses() {
        let classes = 'slds-table slds-table_cell-buffer slds-table_bordered slds-table_fixed-layout';
        if (this.showAdditionalColumns) {
            classes += ' expanded';
        }
        return classes;
    }

    handleToggleColumns() {
        this.showAdditionalColumns = !this.showAdditionalColumns;
        this.shouldScrollRightOnExpand = this.showAdditionalColumns;
    }

    renderedCallback() {
        if (!this.shouldScrollRightOnExpand) {
            return;
        }

        const container = this.template.querySelector('.table-container');
        if (container) {
            container.scrollLeft = container.scrollWidth;
            this.shouldScrollRightOnExpand = false;
        }
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

                if (!isBlank(item.Desired_Price_Subtotal__c)) {
                    console.log('Desired Price Subtotal is not blank, returning false');
                    return false;
                }

                if (
                    !isBlank(item.Discount__c) ||
                    !isBlank(item.Discount_in_Value__c) ||
                    !isBlank(item.Desired_Price__c)
                ) {
                    console.log('Line item has pricing inputs, returning true');
                    return true;
                }

                if (Array.isArray(item.Quote_Line_Options__r)) {
                    for (let option of item.Quote_Line_Options__r) {
                        if (
                            !isBlank(option.Discount__c) ||
                            !isBlank(option.Discount_in_Value__c) ||
                            !isBlank(option.Desired_Price__c)
                        ) {
                            console.log('Option has pricing inputs, returning true');
                            return true;
                        }
                    }
                }
            }
        }
        console.log('No pricing inputs found for line item and options, returning false');
        return false;
    }

    
    @wire(getQuoteLineData, { quoteId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            this.processData(data.lineItems);
            this.quoteName = data.quoteName;
            this.quoteCurrency = data.quoteCurrency;
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    // ─── NEW HELPER ────────────────────────────────────────────────────────────
    // Computes "Sub Total Discount % = X%" using the formula:
    //   subtotalTotalDiscountInValue / subtotalTotalListPrice * 100
    computeSubtotalDiscountText(totalDiscountInValue, totalListPrice) {
        const discount = parseFormattedNumber(totalDiscountInValue) || 0;
        const listPrice = parseFormattedNumber(totalListPrice) || 0;

        if (listPrice === 0 || discount === 0) {
            return '';
        }

        const pct = (discount / listPrice) * 100;
        return `Sub Total Discount % = ${this.formatPercentValue(pct)}%`;
    }
    // ───────────────────────────────────────────────────────────────────────────

    processData(lineItems) {
        let rows = [];
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
                totalTransferPrice: roundToTwoDecimalsAndFormatInteger(item.Total_Global_Price_Item__c),
                unitListPrice: roundToTwoDecimalsAndFormatInteger(item.List_Price__c),
                totalListPrice: roundToTwoDecimalsAndFormatInteger(item.Total_List_Price2__c),
                discountPercent: roundToTwoDecimals(item.Discount__c),
                discountValue: item.Discount_in_Value__c === 0 ? null : item.Discount_in_Value__c,
                desiredPrice: roundToTwoDecimals(item.Desired_Price__c),
                desiredPriceSubtotal: roundToTwoDecimals(item.Desired_Price_Subtotal__c),
                discountAllowed: roundToTwoDecimals(item.Discount_Allowed_New__c),
                maxDiscountAllowed: roundToTwoDecimals(item.P_D3__c),
                totalDiscountInValue: roundToTwoDecimals(item.Discount_Value__c),
                totalDiscountInValueFormatted: roundToTwoDecimalsAndFormatInteger(item.Discount_Value__c),
                salesPrice: roundToTwoDecimals(item.Average_Sales_Price__c),
                salesPriceFormatted: roundToTwoDecimalsAndFormatInteger(item.Average_Sales_Price__c),
                totalSalesPrice: roundToTwoDecimals(item.Sales_Price__c),
                totalSalesPriceFormatted: roundToTwoDecimalsAndFormatInteger(item.Sales_Price__c),
                salesMargin: roundToTwoDecimals(item.Sales_Margin__c),
                m1: roundToTwoDecimals(item.P_M1__c),
                m2: roundToTwoDecimals(item.P_M2__c),
                m3: roundToTwoDecimals(item.P_M3__c),
                m4: roundToTwoDecimals(item.P_M4__c),
                roundingOffDigits: item.Rounding_Off_Digits__c,
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
                showClearButton: true,
                copyToOptions: false,
                disableDiscounts: hasDesiredPriceSubtotal,
                disableDesiredPrice: hasDesiredPriceSubtotal
            };
            if (!hasDesiredPriceSubtotal) {
                this.setDisableFlags(lineRow);
            }
            rows.push(lineRow);
            
            // Calculate subtotal values at runtime
            let subtotalTransferPrice = parseFormattedNumber(lineRow.totalTransferPrice) || 0;
            let subtotalListPrice = parseFormattedNumber(lineRow.totalListPrice) || 0;
            let subtotalDiscountInValue = parseFormattedNumber(lineRow.totalDiscountInValue) || 0;
            let subtotalSalesPrice = parseFormattedNumber(lineRow.totalSalesPrice) || 0;
            
            if (item.Quote_Line_Options__r) {
                item.Quote_Line_Options__r.forEach(option => {
                    let totalQuantity = option.Total_Quantity__c;
                    let parentQuantity = item.Quantity__c;
                    const optRow = {
                        id: option.Id,
                        type: 'option',
                        parentId: item.Id,
                        srNo: item.Sr_No__c,
                        optNo: option.Serial_Number__c,
                        name: option.Manual_Product_Name__c,
                        unitTransferPrice: roundToTwoDecimalsAndFormatInteger(option.Manual_Option_Base_Price__c),
                        quantity: option.Quantity__c,
                        totalQuantity: totalQuantity,
                        totalTransferPrice: roundToTwoDecimalsAndFormatInteger(option.Total_Transfer_Price__c),
                        unitListPrice: roundToTwoDecimalsAndFormatInteger(option.Manula_Option_List_Price__c),
                        totalListPrice: roundToTwoDecimalsAndFormatInteger(option.Total_List_Price__c),
                        discountPercent: roundToTwoDecimals(option.Discount__c),
                        discountValue: option.Discount_in_Value__c === 0 ? null : option.Discount_in_Value__c,
                        desiredPrice: roundToTwoDecimals(option.Desired_Price__c),
                        desiredPriceSubtotal: null,
                        discountAllowed: roundToTwoDecimals(option.Discount_Allowed_New__c),
                        maxDiscountAllowed: roundToTwoDecimals(option.P_D3__c),
                        totalDiscountInValue: roundToTwoDecimals(option.Discount_Amount__c),
                        totalDiscountInValueFormatted: roundToTwoDecimalsAndFormatInteger(option.Discount_Amount__c),
                        salesPrice: roundToTwoDecimals(option.Unit_Sales_Price__c),
                        salesPriceFormatted: roundToTwoDecimalsAndFormatInteger(option.Unit_Sales_Price__c),
                        totalSalesPrice: roundToTwoDecimals(option.Total_Sales_Price__c),
                        totalSalesPriceFormatted: roundToTwoDecimalsAndFormatInteger(option.Total_Sales_Price__c),
                        salesMargin: roundToTwoDecimals(option.Sales_Margin__c),
                        m1: roundToTwoDecimals(option.P_M1__c),
                        m2: roundToTwoDecimals(option.P_M2__c),
                        m3: roundToTwoDecimals(option.P_M3__c),
                        m4: roundToTwoDecimals(option.P_M4__c),
                        roundingOffDigits: option.Rounding_Off_Digits__c,
                        parentQuantity: parentQuantity,
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
                        showClearButton: false,
                        copyToOptions: false,
                        disableDiscounts: hasDesiredPriceSubtotal,
                        disableDesiredPrice: hasDesiredPriceSubtotal
                    };
                    if (!hasDesiredPriceSubtotal) {
                        this.setDisableFlags(optRow);
                    }
                    rows.push(optRow);
                    
                    // Add option values to subtotal
                    subtotalTransferPrice += parseFormattedNumber(optRow.totalTransferPrice) || 0;
                    subtotalListPrice += parseFormattedNumber(optRow.totalListPrice) || 0;
                    subtotalDiscountInValue += parseFormattedNumber(optRow.totalDiscountInValue) || 0;
                    subtotalSalesPrice += parseFormattedNumber(optRow.totalSalesPrice) || 0;
                });
            }
            
            // Calculate subtotal sales margin
            let subtotalSalesMargin = 0;
            if (subtotalSalesPrice === 0) {
                subtotalSalesMargin = '-';
            } else {
                let margin = (subtotalSalesPrice - subtotalTransferPrice) / subtotalSalesPrice;
                if (subtotalSalesPrice < 0) {
                    margin = -margin;
                }
                margin *= 100;
                subtotalSalesMargin = roundToTwoDecimals(margin);
            }

            // ─── CHANGED: compute subtotal discount % dynamically instead of
            //              reading the stale server field ────────────────────────
            const dynamicSubtotalDiscountText = (subtotalListPrice !== 0 && subtotalDiscountInValue !== 0)
                ? `Sub Total Discount % = ${this.formatPercentValue((subtotalDiscountInValue / subtotalListPrice) * 100)}%`
                : '';
            // ────────────────────────────────────────────────────────────────────

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
                totalTransferPrice: roundToTwoDecimalsAndFormatInteger(subtotalTransferPrice),
                unitListPrice: '',
                totalListPrice: roundToTwoDecimalsAndFormatInteger(subtotalListPrice),
                discountPercent: '',
                discountValue: '',
                desiredPrice: '',
                subtotalDiscountPercent: this.formatPercentValue(
                    subtotalListPrice !== 0 ? (subtotalDiscountInValue / subtotalListPrice) * 100 : 0
                ),
                subtotalDiscountText: dynamicSubtotalDiscountText,  // ← CHANGED
                desiredPriceSubtotal: roundToTwoDecimals(item.Desired_Price_Subtotal__c),
                discountAllowed: '',
                maxDiscountAllowed: '',
                totalDiscountInValue: roundToTwoDecimals(subtotalDiscountInValue),
                totalDiscountInValueFormatted: roundToTwoDecimalsAndFormatInteger(subtotalDiscountInValue),
                salesPrice: '',
                salesPriceFormatted: '',
                totalSalesPrice: roundToWholeNumber(subtotalSalesPrice),
                totalSalesPriceFormatted: roundToWholeNumberAndFormatInteger(subtotalSalesPrice),
                salesMargin: subtotalSalesMargin,
                m1: '',
                m2: '',
                m3: '',
                m4: '',
                roundingOffDigits: '',
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
                showClearButton: false,
                copyToOptions: false,
                disableDesiredPriceSubtotal: this.hasAnyPricingInputsForItems(lineItems, item.Sr_No__c)
            });
        });
        
        // Calculate grand total values at runtime
        let grandTotalTransferPrice = 0;
        let grandTotalListPrice = 0;
        let grandTotalDiscountInValue = 0;
        let grandTotalSalesPrice = 0;
        
        rows.forEach(row => {
            if (row.isSubtotal) {
                grandTotalTransferPrice += parseFormattedNumber(row.totalTransferPrice) || 0;
                grandTotalListPrice += parseFormattedNumber(row.totalListPrice) || 0;
                grandTotalDiscountInValue += parseFormattedNumber(row.totalDiscountInValue) || 0;
                grandTotalSalesPrice += parseFormattedNumber(row.totalSalesPrice) || 0;
            }
        });
        
        // Calculate grand sales margin
        let grandSalesMargin = 0;
        if (grandTotalSalesPrice === 0) {
            grandSalesMargin = '-';
        } else {
            let margin = (grandTotalSalesPrice - grandTotalTransferPrice) / grandTotalSalesPrice;
            if (grandTotalSalesPrice < 0) {
                margin = -margin;
            }
            margin *= 100;
            grandSalesMargin = roundToTwoDecimals(margin);
        }

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
            subtotalDiscountPercent: '',
            subtotalDiscountText: '',
            desiredPriceSubtotal: '',
            discountAllowed: '',
            maxDiscountAllowed: '',
            totalDiscountInValue: roundToTwoDecimals(grandTotalDiscountInValue),
            totalDiscountInValueFormatted: roundToTwoDecimalsAndFormatInteger(grandTotalDiscountInValue),
            salesPrice: '',
            salesPriceFormatted: '',
            totalSalesPrice: roundToTwoDecimals(grandTotalSalesPrice),
            totalSalesPriceFormatted: roundToTwoDecimalsAndFormatInteger(grandTotalSalesPrice),
            salesMargin: grandSalesMargin,
            m1: '',
            m2: '',
            m3: '',
            m4: '',
            roundingOffDigits: '',
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
            showClearButton: false,
            copyToOptions: false
        });
        
        this.tableData = rows;
        this.originalData = JSON.parse(JSON.stringify(rows));
    }

    handleClearDiscounts(event) {
        const lineItemId = event.target.dataset.id;
        
        const lineItemIndex = this.tableData.findIndex(row => row.id === lineItemId);
        if (lineItemIndex !== -1) {
            const lineItem = this.tableData[lineItemIndex];
            
            lineItem.discountPercent = null;
            lineItem.discountValue = null;
            lineItem.desiredPrice = null;
            this.setDisableFlags(lineItem);
            this.calculateDiscounts(lineItemIndex);
            
            for (let i = 0; i < this.tableData.length; i++) {
                const row = this.tableData[i];
                if (row.isOption && row.parentId === lineItemId) {
                    row.discountPercent = null;
                    row.discountValue = null;
                    row.desiredPrice = null;
                    this.setDisableFlags(row);
                    this.calculateDiscounts(i);
                }
            }
            
            const subtotalIndex = this.tableData.findIndex(r => 
                r.srNo === lineItem.srNo && r.isSubtotal
            );
            if (subtotalIndex !== -1) {
                this.tableData[subtotalIndex].disableDesiredPriceSubtotal = false;
                this.calculateSubtotalDiscounts(subtotalIndex);
            }
        }
        
        this.tableData = [...this.tableData];
    }

    handleCopyCheckboxChange(event) {
        const lineItemId = event.target.dataset.id;
        console.log('Copy Checkbox Clicked for Line Item ID:', lineItemId);
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
                            this.setDisableFlags(row);
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
            value = parsedValue;
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
        const totalQuantity = row.totalQuantity || 1;
        let calculatedDiscount = 0;

        if (row.desiredPrice !== null && row.desiredPrice !== undefined && row.desiredPrice !== 0) {
            calculatedDiscount = totalListPrice - row.desiredPrice;
            row.totalDiscountInValue = roundToTwoDecimals(calculatedDiscount);
            row.totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(calculatedDiscount);
        } else {
            const discountPercent = row.discountPercent || 0;
            const discountValue = row.discountValue || 0;
            
            calculatedDiscount = (totalListPrice * discountPercent / 100) + discountValue;
            row.totalDiscountInValue = roundToTwoDecimals(calculatedDiscount);
            row.totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(calculatedDiscount);
        }

        const salesPrice = totalQuantity !== 0 ? (totalListPrice - row.totalDiscountInValue) / totalQuantity : 0;
        row.salesPrice = roundToTwoDecimals(salesPrice);
        row.salesPriceFormatted = roundToTwoDecimalsAndFormatInteger(salesPrice);
        
        const totalSalesPrice = salesPrice * totalQuantity;
        row.totalSalesPrice = roundToTwoDecimals(totalSalesPrice);
        row.totalSalesPriceFormatted = roundToTwoDecimalsAndFormatInteger(totalSalesPrice);
        
        if (totalSalesPrice === 0) {
            row.salesMargin = '-';
        } else {
            let margin = (totalSalesPrice - totalTransferPrice) / totalSalesPrice;
            if (totalSalesPrice < 0) {
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
            // ── DPS ENTERED ──────────────────────────────────────────────────────────
            const desiredPriceSubtotal = row.desiredPriceSubtotal;
            const calculatedDiscount = totalListPrice - desiredPriceSubtotal;
            row.totalDiscountInValue = roundToTwoDecimals(calculatedDiscount);
            row.totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(calculatedDiscount);

            // ─── CHANGED: update subtotal discount % text ──────────────────────────
            row.subtotalDiscountText = this.computeSubtotalDiscountText(calculatedDiscount, totalListPrice);
            // ───────────────────────────────────────────────────────────────────────

            const lineItemIndex = this.tableData.findIndex(r => r.id === row.parentId && r.isLineItem);
            if (lineItemIndex !== -1) {
                const parent = this.tableData[lineItemIndex];
                parent.desiredPriceSubtotal = desiredPriceSubtotal;
                parent.disableDiscounts = true;
                parent.disableDesiredPrice = true;

                const optionIndices = [];
                for (let i = 0; i < this.tableData.length; i++) {
                    const opt = this.tableData[i];
                    if (opt.isOption && opt.parentId === parent.id) {
                        opt.disableDiscounts = true;
                        opt.disableDesiredPrice = true;
                        optionIndices.push(i);
                    }
                }

                const allIndices = [lineItemIndex, ...optionIndices];
                let remaining = desiredPriceSubtotal;

                for (let j = 0; j < allIndices.length; j++) {
                    const r = this.tableData[allIndices[j]];
                    r.discountPercent = null;
                    r.discountValue = null;

                    if (j < allIndices.length - 1) {
                        const rowListPrice = parseFormattedNumber(r.totalListPrice) || 0;
                        const proportional = totalListPrice !== 0
                            ? (rowListPrice / totalListPrice) * desiredPriceSubtotal
                            : 0;
                        r.desiredPrice = Math.round(proportional * 100) / 100;
                        remaining = Math.round((remaining - r.desiredPrice) * 100) / 100;
                    } else {
                        r.desiredPrice = remaining;
                    }
                }

                for (const idx of allIndices) {
                    this.calculateDiscounts(idx);
                }
            }
        } else {
            // ── DPS CLEARED ───────────────────────────────────────────────────────────
            const lineItemIndex = this.tableData.findIndex(r => r.id === row.parentId && r.isLineItem);
            if (lineItemIndex !== -1) {
                const parent = this.tableData[lineItemIndex];
                parent.desiredPriceSubtotal = null;
                parent.desiredPrice = null;
                parent.discountPercent = null;
                parent.discountValue = null;
                this.setDisableFlags(parent);
                this.calculateDiscounts(lineItemIndex);

                for (let i = 0; i < this.tableData.length; i++) {
                    const opt = this.tableData[i];
                    if (opt.isOption && opt.parentId === parent.id) {
                        opt.desiredPrice = null;
                        opt.discountPercent = null;
                        opt.discountValue = null;
                        this.setDisableFlags(opt);
                        this.calculateDiscounts(i);
                    }
                }
            }

            // Re-aggregate subtotal discount from item + options
            const relatedRows = this.tableData.filter(r =>
                r.srNo === row.srNo && (r.isLineItem || r.isOption)
            );
            let totalDiscountInValue = 0;
            relatedRows.forEach(r => {
                totalDiscountInValue += parseFormattedNumber(r.totalDiscountInValue) || 0;
            });
            row.totalDiscountInValue = roundToTwoDecimals(totalDiscountInValue);
            row.totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(totalDiscountInValue);

            // ─── CHANGED: update subtotal discount % text ──────────────────────────
            row.subtotalDiscountText = this.computeSubtotalDiscountText(totalDiscountInValue, totalListPrice);
            // ───────────────────────────────────────────────────────────────────────
        }
        
        // Calculate totalSalesPrice and salesMargin for subtotal row
        const totalTransferPrice = parseFormattedNumber(row.totalTransferPrice) || 0;
        const totalSalesPrice = totalListPrice - row.totalDiscountInValue;
        row.totalSalesPrice = roundToTwoDecimals(totalSalesPrice);
        row.totalSalesPriceFormatted = roundToTwoDecimalsAndFormatInteger(totalSalesPrice);
        
        if (totalSalesPrice === 0) {
            row.salesMargin = '-';
        } else {
            let margin = (totalSalesPrice - totalTransferPrice) / totalSalesPrice;
            if (totalSalesPrice < 0) {
                margin = -margin;
            }
            margin *= 100;
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
            let totalTransferPrice = 0;
            let totalListPrice = 0;
            let totalDiscountInValue = 0;
            let totalSalesPrice = 0;
            
            relatedRows.forEach(r => {
                totalTransferPrice += parseFormattedNumber(r.totalTransferPrice) || 0;
                totalListPrice += parseFormattedNumber(r.totalListPrice) || 0;
                totalDiscountInValue += parseFormattedNumber(r.totalDiscountInValue) || 0;
                totalSalesPrice += parseFormattedNumber(r.totalSalesPrice) || 0;
            });
            
            this.tableData[subtotalIndex].totalTransferPrice = roundToTwoDecimalsAndFormatInteger(totalTransferPrice);
            this.tableData[subtotalIndex].totalListPrice = roundToTwoDecimalsAndFormatInteger(totalListPrice);
            this.tableData[subtotalIndex].totalDiscountInValue = roundToTwoDecimals(totalDiscountInValue);
            this.tableData[subtotalIndex].totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(totalDiscountInValue);
            
            const subtotalRow = this.tableData[subtotalIndex];
            
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

            // ─── CHANGED: recompute subtotal discount % text after every aggregation ──
            subtotalRow.subtotalDiscountText = this.computeSubtotalDiscountText(
                totalDiscountInValue,
                totalListPrice
            );
            // ─────────────────────────────────────────────────────────────────────────
        }
        
        this.updateGrandTotal();
    }
    
    updateGrandTotal() {
        const grandTotalIndex = this.tableData.findIndex(r => r.isGrandTotal);
        
        if (grandTotalIndex !== -1) {
            let grandTotalTransferPrice = 0;
            let grandTotalListPrice = 0;
            let grandTotalDiscountInValue = 0;
            let grandTotalSalesPrice = 0;
            
            this.tableData.forEach(row => {
                if (row.isSubtotal) {
                    grandTotalTransferPrice += parseFormattedNumber(row.totalTransferPrice) || 0;
                    grandTotalListPrice += parseFormattedNumber(row.totalListPrice) || 0;
                    grandTotalDiscountInValue += parseFormattedNumber(row.totalDiscountInValue) || 0;
                    grandTotalSalesPrice += parseFormattedNumber(row.totalSalesPrice) || 0;
                }
            });
            
            this.tableData[grandTotalIndex].totalTransferPrice = roundToTwoDecimalsAndFormatInteger(grandTotalTransferPrice);
            this.tableData[grandTotalIndex].totalListPrice = roundToTwoDecimalsAndFormatInteger(grandTotalListPrice);
            this.tableData[grandTotalIndex].totalDiscountInValue = roundToTwoDecimals(grandTotalDiscountInValue);
            this.tableData[grandTotalIndex].totalDiscountInValueFormatted = roundToTwoDecimalsAndFormatInteger(grandTotalDiscountInValue);
            
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

    getExceededMaxDiscountMessage() {
        const eligibleRows = this.tableData.filter(row => row.isLineItem || row.isOption);

        for (const row of eligibleRows) {
            const totalDiscountInValue = parseFormattedNumber(row.totalDiscountInValue) || 0;
            const totalSalesPrice = parseFormattedNumber(row.totalSalesPrice) || 0;
            const maxDiscountAllowed = parseFormattedNumber(row.maxDiscountAllowed);

            if (maxDiscountAllowed === null || maxDiscountAllowed === undefined || totalSalesPrice <= 0) {
                continue;
            }

            const totalDiscountPercentage = (totalDiscountInValue / totalSalesPrice) * 100;

            if (totalDiscountPercentage > maxDiscountAllowed) {
                return `You are not allowed to Provide More Discount than P-D3 = ${this.formatPercentValue(maxDiscountAllowed)}%`;
            }
        }

        return null;
    }

    formatPercentValue(value) {
        if (value === null || value === undefined || value === '') {
            return '';
        }

        const numericValue = Number(value);
        if (Number.isNaN(numericValue)) {
            return '';
        }

        return Number.isInteger(numericValue) ? String(numericValue) : numericValue.toFixed(2).replace(/\.?0+$/, '');
    }
    
    handleSave() {
        const exceededMaxDiscountMessage = this.getExceededMaxDiscountMessage();
        if (exceededMaxDiscountMessage) {
            this.showToast('Error', exceededMaxDiscountMessage, 'error');
            return;
        }

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