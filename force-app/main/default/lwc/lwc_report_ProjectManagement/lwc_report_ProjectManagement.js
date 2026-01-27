import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProjectManagementDail from '@salesforce/apex/Lwc_report_ProjectManagementController.getProjectManagementDail'
const COLS = [
    { label: 'Project No*', fieldName: 'pNo', type: 'url', typeAttributes: { label: { fieldName: 'Name' } } },
    { label: 'Contract No - Rev No*', fieldName: 'contractId', type: 'url', typeAttributes: { label: { fieldName: 'Contract_No_Rev_No_NEW' } } },
    { label: 'Phase', fieldName: 'Phase'},
    { label: 'Product Type', fieldName: 'Product_Type', type: 'text' },
    { label: 'Product', fieldName: 'Product' },
    { label: 'Ceiling Unit Sales Price', fieldName: 'Total_Sales_Price', type: 'currency', cellAttributes: { alignment: 'left'} },
    { label: 'Serial Number', fieldName: 'MATERIAL_CODE', cellAttributes: { alignment: 'left' }}

];


export default class Lwc_report_ProjectManagement extends LightningElement {

    @api recordId;  // Access recordId passed from the record page

    

    // Lifecycle hook to ensure recordId is ready
    connectedCallback() {
        console.log('Record ID:', this.recordId);
        if (!this.recordId) {
          
            this.recordId='a0VH1000005swmIMAQ';
        } else {
            console.error('recordId is undefined');
        }
    }

        @track sortedDirection = 'asc'; // Default sort direction
     andleSort(event) {
        const { fieldName, sortDirection } = event.detail;

        // Check if the column has been sorted before
        const isAsc = this.sortedBy === fieldName && this.sortedDirection === 'asc';
        
        // If already sorted ascending, toggle to descending, otherwise set to ascending
        this.sortedDirection = isAsc ? 'desc' : 'asc';
        // Clone the data and sort
        const cloneData = [...this.ShowTableData];
        cloneData.sort(this.sortData(fieldName, this.sortedDirection));
        this.ShowTableData = cloneData;
    }

    sortData(fieldName, sortDirection) {
        const reverse = sortDirection === 'asc' ? 1 : -1;
        return (a, b) => {
            let valueA = a[fieldName] ? a[fieldName] : '';
            let valueB = b[fieldName] ? b[fieldName] : '';
            return reverse * ((valueA > valueB) - (valueB > valueA));
        };
    }

    



    @track showSpinner = false;
    
    cols = COLS;

    @track ShowTableData = [];
    @track openModel = false;

    getDatails() {
        console.log('recorId-d-abc->', this.recordId);
        this.showSpinner = true;

        getProjectManagementDail({ pId: this.recordId }).then(result => {
            if (result != null) {
                this.openModel = true;
                this.ShowTableData = JSON.parse(result);
            } else {
                this.closeAction('Other Project Management not found', 'error', 'error');

            }
            setTimeout(() => {
                this.showSpinner = false;
            }, 1000);
        })

    }

    closePdfPreviewModal() {
        this.openModel = false;
    }

    closeAction(msg, variant, title) {

        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
        }));

        this.dispatchEvent(new RefreshEvent());
        //this.goBackToRecord();
    }

}