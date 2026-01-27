public class CreateQuotetriggerHandler {
    Public String opptyId {
        get;
        set;
    }
    Public String AccountId {
        get;
        set;
    }
    Public String ContactId {
        get;
        set;
    }
    public Quote ObjQuote {
        get;
        set;
    }
    Public Opportunity ObjOppty {
        get;
        set;
    }
    Public Account ObjAccount {
        get;
        set;
    }
    
    public Map<Id,Contact> conMap {
        get;
        set;
    }
    Public List<Contact> ObjContact {
        get;
        set;
    }
    public List < Quote > ObjListQuote {
        get;
        set;
    }
    
    public void QuoteUpdate(String QuoteId) {
        System.debug('QuoteId : : ' + QuoteId);
        ObjQuote = [select id, Quote_Number__c, Name, QuoteNumber, Contact__c, designation__c, OpportunityId, AccountId, ACCOUNT_BUSINESS__c, ACCOUNT_TYPE__c,
                    ADDRESS_LINE_1__c, ADDRESS_LINE_2__c, ADDRESS_LINE_3__c, QU_REVISION_NUMBER__c, ExpirationDate, Application__c, Zero_Cooling__c,
                    ADVANCE_PAYMENT__c, CITY__c, CLOSE_LOST_REASON__c, COUNTRY__c, COUNTRY_CODE__c, DATE__c, END_CUSTOMER_NAME__c, FUNCTION__c, INCO_TERMS__c,
                    MFG_AT__c, POSTAL_CODE__c, PREPARED_BY__c, PROBABILITY__c, QUOTATION_ADDRESSED_TO__c, QUOTATION_CREATE__c, Class__c,
                    /*REGION__c,*/ SHIP_TO__c, SOLD_TO__c, STATE__c, SUBSIDARY__c, TYPE__c, VALIDITY__c, VALITY_DATE__c,SHIP_To_Contact_Name__c from Quote where id =: QuoteId limit 1
                   ];
        
        System.debug('ObjQuote :: Kb' + ObjQuote.QU_REVISION_NUMBER__c);
        
        opptyId = ObjQuote.OpportunityId;
        ObjOppty = [select id, AccountId, sales_Any_Customized_Requirement__c, APPLICATION__c, APPROXIMATE_AMOUNT__c, AUTO_NUMBER_ASSIGNED__c, Budget_Confirmed__c, Class__c,
                    COMMENT__c, DETAILS__c, Discovery_Completed__c, Drawing_Request__c, ERP_ID__c, FEASIBILITY_STUDY__c, Feasibilty_Study_Result__c, Global_Customer_Id__c,Contact__c ,
                    Global_Customer_Name__c, Loss_Reason__c, Opportunity_Number__c, Opportunity_Number1__c, Parent_Account_Id__c, FY__c, MFG_AT__c, Zero_Cooling__c, Amount,
                    Parent_Company_Name__c, Prepared_By__c, Probability__c, Request_Date__c, ROI_Analysis_Completed__c, Source__c, STUDY_REQUEST_DATE__c, Subsidaries__c, Quote_Amount__c
                    From Opportunity where id =: opptyId limit 1
                   ];
        System.debug('ObjOppty : : :' + ObjOppty);
        
        AccountId = ObjQuote.AccountId;
        //ContactId = ObjQuote.Conc;
        
        ObjAccount = [select id, name, Account_Business__c, Account_Type__c, sales_Address__c, ADDRESS_LINE_1__c, ADDRESS_LINE_2__c, ADDRESS_LINE_3__c, City__c, Type,
                      Country__c, Countries__c, Country_Code__c, Customer_Category__c, ERP_ID__c, External_ID__c, Global_Customer__c, Global_Customer_ID__c, GSTIN_No__c,
                      sales_Industry__c, sales_No_of_Employees__c, PAN__c, ParentId, Party_Group_Name__c, Pin_Code__c, Prepared_By__c, sales_Rating__c, /*Region__c*/Region1__c, City_Text__c,
                      SF_ID__c, State__c, States__c, Subsidary__c, TIN__c, BillingCountry, BillingState, BillingCity, BillingPostalCode, ShippingCountry, ShippingState, ShippingCity, ShippingPostalCode, Billing_City__r.name, Billing_Country__r.name, Billing_State__r.name, Shipping_Address_Line_1__c, Shipping_Address_Line_2__c, Shipping_Address_Line_3__c,
                      Shipping_City__r.name, Shipping_Country__r.name, Shipping_Postal_Code__c, Shipping_State__r.name,Shipping_Postal_ZIP_Code__r.name,Billing_Postal_ZIP_Code__r.name from Account where id =: AccountId limit 1
                     ];
        
        System.debug('ObjAccount : : :' + ObjAccount.Region1__c);
        
        if (AccountId != null) {
            System.debug('AccountId' + AccountId);
            conMap = new Map<Id,Contact>();
            try {
                ObjContact = [Select id, name, phone, email, fax, Designation__c from Contact where Accountid =: AccountId];
                //added by rishikesh Korade 23 Jan 2024
                for(Contact con : ObjContact){
                    conMap.put(con.Id,con);
                }
            } catch (Exception ex) {
                ObjContact = null;
                
            }
        }
        System.debug('ObjContact : : :' + ObjContact);
        
        String QuoteName = ObjQuote.Quote_Number__c;
        
        ObjListQuote = [Select Id, name, Quote_Number__c from Quote Where Quote_Number__c =: QuoteName AND opportunityId =: opptyId];
        System.debug('ObjListQuote ' + ObjListQuote.size());
        Integer count = ObjListQuote.size();
        System.debug('count' + count);
        ObjOppty.Quote_Amount__c = 0;
        ObjQuote.VALIDITY__c = 30;
        if (ObjOppty.FY__c != '' && ObjOppty.FY__c != null) {
            ObjQuote.FY__c = ObjOppty.FY__c;
        }
        
        
        if (ObjOppty.APPLICATION__c != '' && ObjOppty.APPLICATION__c != null && ObjQuote.QU_REVISION_NUMBER__c == null) {
            ObjQuote.Application__c = ObjOppty.APPLICATION__c;
        }
        
        if (ObjOppty.MFG_AT__c != '' && ObjOppty.MFG_AT__c != null && ObjQuote.QU_REVISION_NUMBER__c == null) {
            ObjQuote.MFG_AT__c = ObjOppty.MFG_AT__c;
        }
        if (ObjOppty.Class__c != '' && ObjOppty.Class__c != null && ObjQuote.QU_REVISION_NUMBER__c == null) {
            ObjQuote.Class__c = ObjOppty.Class__c;
        }
        if (ObjOppty.Zero_Cooling__c != '' && ObjOppty.Zero_Cooling__c != null && ObjQuote.QU_REVISION_NUMBER__c == null) {
            ObjQuote.Zero_Cooling__c = ObjOppty.Zero_Cooling__c;
        }
        
        /*if (ObjAccount.Billing_Country__c != null) {
            ObjQuote.CountryCustom__c = ObjAccount.Billing_Country__r.name;
        }
        if (ObjAccount.Billing_State__c != null) {
            ObjQuote.StateCustom__c = ObjAccount.Billing_State__r.name;
        }
        if (ObjAccount.Billing_City__c != null) {
            ObjQuote.CityCustom__c = ObjAccount.Billing_City__r.name;
        }
        */
        
        /*if (ObjAccount.Shipping_Country__c != null) {
            ObjQuote.Ship_To_Country__c = ObjAccount.Shipping_Country__r.name;
        }
        if (ObjAccount.Shipping_State__c != null) {
            ObjQuote.Ship_To_State__c = ObjAccount.Shipping_State__r.name;
        }
        if (ObjAccount.Shipping_City__c != null) {
            ObjQuote.Ship_To_City__c = ObjAccount.Shipping_City__r.name;
        }
        if (ObjAccount.Shipping_Address_Line_1__c != null) {
            ObjQuote.SHIP_TO_ADDRESS_LINE_1__c = ObjAccount.Shipping_Address_Line_1__c;
        }
        if (ObjAccount.Shipping_Address_Line_2__c != null) {
            ObjQuote.SHIP_TO_ADDRESS_LINE_2__c = ObjAccount.Shipping_Address_Line_2__c;
        }
        if (ObjAccount.Shipping_Address_Line_3__c != null) {
            ObjQuote.SHIP_TO_ADDRESS_LINE_3__c = ObjAccount.Shipping_Address_Line_3__c;
        }
        if (ObjAccount.Shipping_Postal_ZIP_Code__c != null) {
            ObjQuote.SHIP_TO_POSTAL_CODE__c = ObjAccount.Shipping_Postal_ZIP_Code__r.name;
        }
        */
        if (ObjAccount.BillingCountry != '' && ObjAccount.BillingCountry != null) {
            ObjQuote.BillingCountry = ObjAccount.BillingCountry;
        }
        if (ObjAccount.BillingState != '' && ObjAccount.BillingState != null) {
            ObjQuote.BillingState = ObjAccount.BillingState;
        }
        if (ObjAccount.BillingCity != '' && ObjAccount.BillingCity != null) {
            ObjQuote.BillingCity = ObjAccount.BillingCity;
        }
        if (ObjAccount.BillingPostalCode != '' && ObjAccount.BillingPostalCode != null) {
            ObjQuote.BillingPostalCode = ObjAccount.Billing_Postal_ZIP_Code__r.name;
        }
        if (ObjAccount.ShippingCountry != '' && ObjAccount.ShippingCountry != null) {
            ObjQuote.ShippingCountry = ObjAccount.ShippingCountry;
        }
        if (ObjAccount.ShippingState != '' && ObjAccount.ShippingState != null) {
            ObjQuote.ShippingState = ObjAccount.ShippingState;
        }
        if (ObjAccount.ShippingCity != '' && ObjAccount.ShippingCity != null) {
            ObjQuote.ShippingCity = ObjAccount.ShippingCity;
        }
        if (ObjAccount.ShippingPostalCode != '' && ObjAccount.ShippingPostalCode != null) {
            ObjQuote.ShippingPostalCode = ObjAccount.ShippingPostalCode;
        }
        
        if (ObjOppty.Subsidaries__c != '' && ObjOppty.Subsidaries__c != null) {
            ObjQuote.SUBSIDARY__c = ObjOppty.Subsidaries__c;
        }
        
        if (ObjOppty.Probability__c != '' && ObjOppty.Probability__c != null) {
            ObjQuote.Probability__c = ObjOppty.Probability__c;
        }
        /*if (AccountId != '' && AccountId != null) {
            ObjQuote.SOLD_TO__c = AccountId;
        }
        if (AccountId != '' && AccountId != null) {
            ObjQuote.SHIP_TO__c = AccountId;
        }*/
       /* if (ObjOppty.Contact__c != '' && ObjOppty.Contact__c != null) {
            ObjQuote.SHIP_To_Contact_Name__c = ObjOppty.Contact__c;
        } */
        /*if (ObjContact != null) {
            if (ObjContact.id != null) {
                ObjQuote.ContactId = ObjContact.id;
                ObjQuote.Contact__c = ObjContact.id;
                ObjQuote.QUOTATION_ADDRESSED_TO__c = ObjContact.id;
            }
            if (ObjContact.phone != '' && ObjContact.phone != null) {
                ObjQuote.Phone = ObjContact.phone;
            }
            
            if (ObjContact.email != '' && ObjContact.email != null) {
                ObjQuote.Email = ObjContact.email;
            }
            if (ObjContact.fax != '' && ObjContact.fax != null) {
                ObjQuote.fax = ObjContact.fax;
            }
        }*/
        
         //added by rishikesh Korade 23 Jan 2024
        if (conMap.containskey(ObjOppty.Contact__c)) {
                ObjQuote.ContactId = conMap.get(ObjOppty.Contact__c).id;
                ObjQuote.Contact__c = conMap.get(ObjOppty.Contact__c).id;
                ObjQuote.QUOTATION_ADDRESSED_TO__c = conMap.get(ObjOppty.Contact__c).id;
            //}
            if (conMap.get(ObjOppty.Contact__c).phone != '' && conMap.get(ObjOppty.Contact__c).phone != null) {
                ObjQuote.Phone = conMap.get(ObjOppty.Contact__c).phone;
            }
            
            if (conMap.get(ObjOppty.Contact__c).email != '' && conMap.get(ObjOppty.Contact__c).email != null) {
                ObjQuote.Email = conMap.get(ObjOppty.Contact__c).email;
            }
            if (conMap.get(ObjOppty.Contact__c).fax != '' && conMap.get(ObjOppty.Contact__c).fax != null) {
                ObjQuote.fax = conMap.get(ObjOppty.Contact__c).fax;
            }
    }
        
       /* if (ObjAccount.ADDRESS_LINE_1__c != '' && ObjAccount.ADDRESS_LINE_1__c != null) {
            ObjQuote.ADDRESS_LINE_1__c = ObjAccount.ADDRESS_LINE_1__c;
        }
        if (ObjAccount.ADDRESS_LINE_2__c != '' && ObjAccount.ADDRESS_LINE_2__c != null) {
            ObjQuote.ADDRESS_LINE_2__c = ObjAccount.ADDRESS_LINE_2__c;
        }
        if (ObjAccount.ADDRESS_LINE_3__c != '' && ObjAccount.ADDRESS_LINE_3__c != null) {
            ObjQuote.ADDRESS_LINE_3__c = ObjAccount.ADDRESS_LINE_3__c;
        }
        
        if (ObjAccount.Billing_Postal_ZIP_Code__c != null) {
            ObjQuote.POSTAL_CODE__c = ObjAccount.Billing_Postal_ZIP_Code__r.Name;
        }*/
        /*if (ObjAccount.Region__c != '' && ObjAccount.Region__c != null) {
            system.debug('ObjAccount.Region__c'+ObjAccount.Region__c);
            ObjQuote.REGION__c = ObjAccount.Region__c;
        }*/
        
        
        if (ObjAccount.Country_Code__c != '' && ObjAccount.Country_Code__c != null) {
            ObjQuote.COUNTRY_CODE__c = ObjAccount.Country_Code__c;
        }
        
        if (ObjAccount.Account_Business__c != '' && ObjAccount.Account_Business__c != null) {
            ObjQuote.ACCOUNT_BUSINESS__c = ObjAccount.Account_Business__c;
        }
        if (ObjAccount.Account_Type__c != '' && ObjAccount.Account_Type__c != null) {
            ObjQuote.ACCOUNT_TYPE__c = ObjAccount.ACCOUNT_TYPE__c;
        }
        if (ObjAccount.type != '' && ObjAccount.type != null) {
            ObjQuote.TYPE__c = ObjAccount.type;
        }
        if (ObjAccount.Subsidary__c != '' && ObjAccount.Subsidary__c != null) {
            ObjQuote.SUBSIDARY__c = ObjAccount.Subsidary__c;
        }
        
        //System.debug('ObjQuote.QU_REVISION_NUMBER__c'+ObjQuote.QU_REVISION_NUMBER__c);
        ObjQuote.DATE__c = date.today();
        ObjQuote.ADVANCE_PAYMENT__c = 'YES';
        if(string.isBlank(ObjQuote.INCO_TERMS__c)){
            ObjQuote.INCO_TERMS__c = 'EXW';
        }
        
        //Date dToday = system.today();
        ObjQuote.ExpirationDate = System.today() + 45;
        system.debug('ObjQuote'+ObjQuote.POSTAL_CODE__c);
        update ObjQuote;
        
        update ObjOppty;
        
    }
    
    
    
    
    //Update Discount on Quote Line Item when Updated on Quote
    public static Boolean isUpdateQLIDiscountRun = false;
    public static void updateQLIDiscount(Map < id, Quote > oldQuoteObjMap, List < Quote > quoteObjList) {
        
        if (!isUpdateQLIDiscountRun) {
            Set < Id > quoteIdSet = new Set < Id > ();
            
            for (Quote quoteObj: quoteObjList) {
                if (quoteObj.Discount__c != oldQuoteObjMap.get(quoteObj.Id).Discount__c && (quoteObj.status=='Draft'|| quoteObj.status=='CREATED'
                                                                                            ||quoteObj.status=='UNDER NEGOTIATION - COOL'||quoteObj.status=='UNDER NEGOTIATION - HOT'))
                    quoteIdSet.add(quoteObj.Id);
            } 
            
            if (!quoteIdSet.isEmpty()) {
                
                List < Quote_Line_Item_Custom__c > qliObjList = [Select Id, Quote__r.Discount__c
                                                                 FROM Quote_Line_Item_Custom__c
                                                                 WHERE Quote__c IN: quoteIdSet
                                                                ];
                
                if (!qliObjList.isEmpty()) {
                    
                    for (Quote_Line_Item_Custom__c qliObj: qliObjList) {
                        qliObj.Discount_Earlier__c = qliObj.Quote__r.Discount__c;
                        qliObj.Discount__c = qliObj.Quote__r.Discount__c;
                    }
                    try {
                        update qliObjList;
                        isUpdateQLIDiscountRun=true;
                   } catch (exception e) {
                        
                    }
                }
            }
        }
    }
    
    
    //Update Discount on Quote Line Item when Updated on Quote
    public static Boolean isUpdateQLODiscountRun = false; //To Stop the recursion
    public static void updateQLODiscount(Map < id, Quote > oldQuoteObjMap, List < Quote > quoteObjList) {
        
        if (!isUpdateQLODiscountRun) {
            Set < Id > quoteIdSet = new Set < Id > ();
            
            for (Quote quoteObj: quoteObjList) {
                system.debug('quoteObj.Discount__c'+quoteObj.Discount__c);
                system.debug('quoteObj. status'+quoteObj.status);
                system.debug('quoteObj.Discount__c'+oldQuoteObjMap.get(quoteObj.Id).Discount__c);
                if (quoteObj.Discount__c != oldQuoteObjMap.get(quoteObj.Id).Discount__c && (quoteObj.status=='Draft'|| quoteObj.status=='CREATED'||quoteObj.status=='UNDER NEGOTIATION - COOL'||quoteObj.status=='UNDER NEGOTIATION - HOT'))
                    quoteIdSet.add(quoteObj.Id);
            }
            
            if (!quoteIdSet.isEmpty()) {
                
                List < Quote_Line_Options__c > qliObjList = [Select Id, Quote__r.Discount__c
                                                             FROM Quote_Line_Options__c
                                                             WHERE Quote__c IN: quoteIdSet
                                                            ];
                if (!qliObjList.isEmpty()) {
                    
                    for (Quote_Line_Options__c qliObj: qliObjList) {
                        qliObj.Discount__c = qliObj.Quote__r.Discount__c;
                        qliObj.Discount_Earlier__c = qliObj.Quote__r.Discount__c;
                    }
                    try {
                        update qliObjList;
                        isUpdateQLODiscountRun=true;
                    } catch (exception e) {
                        
                    }
                }
            }
            
        }
    }
    
    @future
    public static void updateQuote(List<id> qIds)
    {
       List<Quote> qList=[select id,name,Skip_Status_Validation__c from Quote where id in:qIds];
        for(Quote q: qList)
        {
            q.Skip_Status_Validation__c=false;
        }
        
        update qList;
    }
    
}