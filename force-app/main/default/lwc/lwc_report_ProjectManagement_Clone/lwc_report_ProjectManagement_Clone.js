import { LightningElement,api,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';


export default class Lwc_report_ProjectManagement_Clone extends LightningElement {

    @api recordId; // Record ID passed from the first component

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state) {
            this.recordId = currentPageReference.state.recordId || this.recordId; // Get the recordId from the URL
            console.log('Received recordId:', this.recordId);
        }
    }
}