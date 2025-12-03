Quote PDF Template System Documentation
Overview
This system generates dynamic PDF quotes in Salesforce using a three-tier template structure: Quote Templates, Template Lines, and Dynamic Text replacements. The system supports multiple sections, customizable content, and dynamic field substitution.

Core Components
1. Quote_Template__c (Master Template)
The master configuration object that defines the overall structure and appearance of the quote PDF.
Key Fields & Usage

Quote Template Fields:

Layout Control Fields:
Cover Page Required - Shows/hides the cover page
Section 2 Required - Controls introductory section visibility
Section 4 Required - Controls general remarks section visibility
Section 5 Required - Controls general provisions section visibility
Footer Image Required - Enables footer image display
Footer Text Required? - Enables footer text display

Section Titles:
S2_Title - Title for Section 2 (Introduction)
S3_title - Title for Section 3 (Scope of Supply)
S4_Title - Title for Section 4 (General Remarks)
S5_Title - Title for Section 5 (General Provisions)

Labels & Text:

'Label For Colum 1' through 'Label For Colum 5' - Column headers for product table
Label For Ref No - Reference number label
Label for Date - Date label
Label For TO - "To" label
Label For Quotation No - Quotation number label
Label for Price in Word - Price in words label
Salutation - Greeting text (e.g., "Dear")
S2_Introduction - Introductory paragraph content
Manufacture Place - Manufacturing location text
'ISO Code Label' & 'ISO Code Text' - ISO certification display

Branding Assets:

Cover Page - Cover page image URL
Header Image - Header image for released quotes
Draft Image - Header image for draft quotes
Footer Image - Footer image URL
Logo - Company logo URL
Footer Text - Rich text footer content

Signature Control:

'ASB Sign Section2' through 'ASB Sign Section5' - Show ASB signature in each section
'Customer Sign Section2' through 'Customer Sign Section5' - Show customer signature area in each section

Other:

Company Name Label - Company name label
Sales Engineer Label - Sales engineer label
Quotation No Label - Quotation number label on cover
Quotation Date Label - Quotation date label on cover
Subsidiary - Lookup to subsidiary


2. Quote_Template_Line__c (Content Sections)
Defines the actual content blocks for different sections of the quote. Each line represents a paragraph or content block.
Key Fields & Usage
Content Fields:

Content 2 - Primary content field - Rich text that appears in the PDF
Label - Optional label/heading for the content block
Sr No - Sort order number

Section Type Flags:

Section 2 - Marks this line as Terms & Conditions content
Section 4 - Marks this line as General Remarks content
Section 5 - Marks this line as General Provisions content

Relationships:

Quote_Template__c - Lookup to parent Quote_Template__c
Child relationship: Quote_Dynamic_Text__r - Related dynamic text replacements

3. Quote_Dynamic_Text__c (Dynamic Field Replacement)
Enables merge field functionality by replacing placeholder text with actual Quote field values.
Key Fields & Usage

Dynamic Field - Placeholder text to find (e.g., "{{QUOTE_NUMBER}}")
Field To Replace - Actual Quote field API name (e.g., "Quote_Number__c")
Quote_Template_Line__c - Parent Template Line
Active - Only active replacements are processed

#### Example Use Case

**Template Line Content:**
```
Payment Terms: {{ADVANCE_PERCENTAGE}}% advance with order
Delivery: {{DELIVERY_DAYS}} days from receipt of advance
```

**Dynamic Text Records:**
| Dynamic_Field__c       | Field_To_Replace__c   |
|------------------------|-----------------------|
| {{ADVANCE_PERCENTAGE}} | Advance_Percentage__c |
| {{DELIVERY_DAYS}}      | Delivery_Days__c      |

**Quote Data:**
- Advance_Percentage__c = 30
- Delivery_Days__c = 45

**Final Output:**
```
Payment Terms: 30% advance with order
Delivery: 45 days from receipt of advance
```

---

## PDF Section Breakdown

### Page 1: Cover Page
- **Controlled by:** `Cover Page Required`
- **Uses:** `Cover Page` - (image), company name, quote number, date, sales engineer

### Page 2: Introduction & Terms
- **Controlled by:** `Section 2 Required`
- **Uses:** 
  - `S2_Title` - Section title
  - `S2_Introduction` - Intro paragraph
  - `terms` list (Quote_Template_Line__c where Is_Terms_Condition__c = true)
  - Signature fields: `ASB Sign Section2`, `Customer Sign Section2`

### Page 3: Scope of Supply (Product Table)
- **Always shown**
- **Uses:**
  - `S3_title` - Section title
  - `Label For Colum 1` through `Label For Colum 5` - Table headers
  - `Manufacture Place` - Manufacturing location
  - Product line items from Quote_Line_Item_Custom__c
  - Signature fields: `ASB Sign Section3`, `Customer Sign Section3`

### Page 4: General Remarks
- **Controlled by:** `Section 4 Required`
- **Uses:**
  - `S4_Title` - Section title
  - `gRemark` list (Quote_Template_Line__c where Is_General_Remarks__c = true)
  - Signature fields: `ASB Sign Section4`, `Customer Sign Section4`

### Page 5: General Provisions
- **Controlled by:** `Section 5 Required`
- **Uses:**
  - `S5_Title` - Section title
  - `gProvision` list (Quote_Template_Line__c where Is_General_Provision__c = true)
  - Signature fields: `ASB Sign Section5`, `Customer Sign Section5`

### Footer (All Pages)
- **Uses:**
  - `Footer Image` (if `Footer Image Required` = true)
  - `Footer Text` (if `Footer Text Required?` = true)
  - `ISO Code Label` & `ISO Code Text`
  - Sales engineer info
  - Page numbers

---