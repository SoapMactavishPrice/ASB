import { LightningElement, api, track } from 'lwc';

export default class CustomLayoutQLO extends LightningElement 
{
   
   @api recordId;
   @api objectApiName = 'Contract_Line_Option__c';
        fields = [ 
                    'Manual_Option_Base_Price__c', 'Total_Base_Price__c', 'Total_Transfer_Price__c','Manual_Option_List_Price__c', 'List_Price_Total2__c', 'Total_List_Price__c', 
                    'Average_Discount_Value__c', 'Discount_Value__c', 'Total_Discount_Value__c', 
                    'Average_Sales_Price__c', 'Price__c','Total_Sales_Price__c', 'Sales_Margin_Percent__c','Discount_Allowed_New__c','Discount_in_Value_Percent__c'
                 ];

      // Toggle the section
                 
    @api label = 'Price Information Of Option';
    @track isOpen = true;
    sectionId = 'pricing-section';

    get sectionClass() {
        return 'slds-section ' + (this.isOpen ? 'slds-is-open' : 'slds-is-closed');
    }

    get chevronIconName() {
        return this.isOpen ? 'utility:chevrondown' : 'utility:chevronright';
    }

    toggleSection() {
        this.isOpen = !this.isOpen;
    }
    
}