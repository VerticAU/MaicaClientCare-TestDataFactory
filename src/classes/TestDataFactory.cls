public with sharing class TestDataFactory {

    private static final Map<Integer, Contact> CONTACTS = new Map<Integer, Contact>{
        0 => new Contact(FirstName = 'Luca', LastName = 'Milne', Email = 'luca.milne' + System.currentTimeMillis() + '@mailinator.com', Birthdate = Date.newInstance(1990, 1, 1)),
        1 => new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe' + System.currentTimeMillis() + '@mailinator.com', Birthdate = Date.newInstance(1991, 2, 2)),
        2 => new Contact(FirstName = 'Lyanna', LastName = 'Dyer', Email = 'lyanna.dyer' + System.currentTimeMillis() + '@mailinator.com', Birthdate = Date.newInstance(1992, 3, 3)),
        3 => new Contact(FirstName = 'Jagger', LastName = 'Carlson', Email = 'jagger' + System.currentTimeMillis() + '@mailinator.com', Birthdate = Date.newInstance(1993, 4, 4)),
        4 => new Contact(FirstName = 'Kali', LastName = 'Larsen', Email = 'laki.larsen' + System.currentTimeMillis() + '@mailinator.com', Birthdate = Date.newInstance(1994, 5, 5)),
        5 => new Contact(FirstName = 'Nicolas', LastName = 'Lang', Email = 'nicolas.lang' + System.currentTimeMillis() + '@mailinator.com', Birthdate = Date.newInstance(1995, 6, 6)),
        6 => new Contact(FirstName = 'Mario', LastName = 'Combs', Email = 'mario.combs' + System.currentTimeMillis() + '@mailinator.com', Birthdate = Date.newInstance(1996, 7, 7)),
        7 => new Contact(FirstName = 'Mark', LastName = 'May', Email = 'mark.may' + System.currentTimeMillis() + '@mailinator.com', Birthdate = Date.newInstance(1997, 8, 8)),
        8 => new Contact(FirstName = 'Adriana', LastName = 'White', Email = 'adriana.white' + System.currentTimeMillis() + '@mailinator.com', Birthdate = Date.newInstance(1998, 9, 9)),
        9 => new Contact(FirstName = 'Remy', LastName = 'Becker', Email = 'remy.becker' + System.currentTimeMillis() + '@mailinator.com', Birthdate = Date.newInstance(1999, 10, 10))
    };

    private Integer contactScope = 1;
    private Integer appointmentScope = 3;
    private Integer deliveryActivityScope = 2;

    public TestDataFactory() {
    }

    public TestDataFactory(Integer contactScope) {
        this.contactScope = contactScope;
    }

    public TestDataFactory(Integer contactScope, Integer appointmentScope) {
        this.contactScope = contactScope;
        this.appointmentScope = appointmentScope;
    }

    public TestDataFactory(Integer contactScope, Integer appointmentScope, Integer deliveryActivityScope) {
        this.contactScope = contactScope;
        this.appointmentScope = appointmentScope;
        this.deliveryActivityScope = deliveryActivityScope;
    }

    private UnitOfWork uow = new UnitOfWork(new List<SObjectType>{
        Account.SObjectType,
        Contact.SObjectType,
        maica_cc__Price_List__c.SObjectType,
        maica_cc__Funding__c.SObjectType,
        maica_cc__Service_Agreement__c.SObjectType,
        maica_cc__Appointment__c.SObjectType,
        maica_cc__Appointment_Service__c.SObjectType,
        maica_cc__Support_Category__c.SObjectType,
        maica_cc__Support_Item__c.SObjectType,
        maica_cc__Agreement_Item__c.SObjectType,
        maica_cc__Invoice__c.SObjectType,
        Funding_Program__c.SObjectType,
        Program_Period__c.SObjectType,
        maica_cc__Delivery_Activity__c.SObjectType,
        maica_cc__Invoice_Line_Item__c.SObjectType
    });

    public void createTestData() {
        Account serviceProvider = this.createAccount();
        this.uow.registerNew(serviceProvider);

        maica_cc__Price_List__c priceList = this.createPriceList();
        this.uow.registerNew(priceList);

        Funding_Program__c fundingProgram = this.createFundingProgram();
        this.uow.registerNew(fundingProgram);

        maica_cc__Funding__c ndisFundingVar = this.createFunding('NDIS', 'Agency Managed');
        this.uow.registerNew(ndisFundingVar);
        maica_cc__Funding__c hcpFundingVar = this.createFunding('Home Care Package', 'Home Care Package');
        this.uow.registerNew(hcpFundingVar);
        maica_cc__Funding__c haccFundingVar = this.createFunding('Block Funding', 'HACC');
        this.uow.registerNew(haccFundingVar);
        maica_cc__Funding__c chspFundingVar = this.createFunding('Block Funding', 'CHSP');
        this.uow.registerNew(chspFundingVar);

        List<Program_Period__c> programPeriods = new List<Program_Period__c>();
        for (Integer j = 0; j < this.appointmentScope; j++) {
            Program_Period__c reportingPeriodVar = this.createReportingPeriod(j);
            this.uow.registerNew(reportingPeriodVar);
            this.uow.registerRelationship(reportingPeriodVar, Program_Period__c.Funding_Program__c, fundingProgram);
            programPeriods.add(reportingPeriodVar);
        }

        maica_cc__Support_Category__c ndisSupportCategory = this.createSupportCategory(ndisFundingVar);
        this.uow.registerNew(ndisSupportCategory);
        maica_cc__Support_Category__c hcpSupportCategory = this.createSupportCategory(hcpFundingVar);
        this.uow.registerNew(hcpSupportCategory);
        maica_cc__Support_Category__c haccSupportCategory = this.createSupportCategory(haccFundingVar);
        this.uow.registerNew(haccSupportCategory);
        maica_cc__Support_Category__c chspSupportCategory = this.createSupportCategory(chspFundingVar);
        this.uow.registerNew(chspSupportCategory);

        for (Integer i = 0; i < this.contactScope; i++) {
            Account accountVar = this.createAccount();
            this.uow.registerNew(accountVar);

            Contact contactVar = this.createContact(i);
            this.uow.registerRelationship(contactVar, Contact.AccountId, accountVar);
            this.uow.registerNew(contactVar);

            this.createAppointmentChain(ndisFundingVar, ndisSupportCategory, priceList, contactVar, serviceProvider, programPeriods);
            this.createAppointmentChain(hcpFundingVar,hcpSupportCategory,  priceList, contactVar, serviceProvider, programPeriods);
            this.createAppointmentChain(haccFundingVar, haccSupportCategory, priceList, contactVar, serviceProvider, programPeriods);
            this.createAppointmentChain(chspFundingVar, chspSupportCategory, priceList, contactVar, serviceProvider, programPeriods);
        }

        this.uow.commitWork();

        Map<String, SObject> deliveryActivitiesMap = Utils.sObjects.getSObjectsByAnyFieldMap([SELECT Id, maica_cc__Support_Item__c FROM maica_cc__Delivery_Activity__c], maica_cc__Delivery_Activity__c.maica_cc__Support_Item__c);
        Map<String, SObject> ilisMap = Utils.sObjects.getSObjectsByAnyFieldMap([SELECT Id, maica_cc__Support_Item__c FROM maica_cc__Invoice_Line_Item__c], maica_cc__Invoice_Line_Item__c.maica_cc__Support_Item__c);
        for (String supportItemId : ilisMap.keySet()) {
            SObject deliveryActivityObj = (maica_cc__Delivery_Activity__c) deliveryActivitiesMap.get(supportItemId);
            if (deliveryActivityObj != null) {
                deliveryActivityObj.put('maica_cc__Invoice_Line_Item__c', ilisMap.get(supportItemId).Id);
                deliveryActivitiesMap.put(supportItemId, deliveryActivityObj);
            }
        }
        update deliveryActivitiesMap.values();
    }

    public Account createAccount() {
        return new Account(
            Name = 'Test Account' + System.currentTimeMillis());
    }

    public Contact createContact(Integer index) {
        return CONTACTS.get(index) ?? new Contact(
            FirstName = 'Test',
            LastName = 'Test' + index,
            Birthdate = Date.today().addYears(-index * 2),
            Email = 'Test_Test' + index + System.now().getTime() + '@mailinator.com');
    }

    public void createAppointmentChain(maica_cc__Funding__c fundingVar, maica_cc__Support_Category__c supportCategory, maica_cc__Price_List__c priceList, Contact contactVar, Account serviceProvider, List<Program_Period__c> programPeriods) {

        maica_cc__Service_Agreement__c serviceAgreement = this.createServiceAgreement(fundingVar);
        this.uow.registerNew(serviceAgreement);
        this.uow.registerRelationship(serviceAgreement, maica_cc__Service_Agreement__c.maica_cc__Funding__c, fundingVar);
        this.uow.registerRelationship(serviceAgreement, maica_cc__Service_Agreement__c.maica_cc__Price_List__c, priceList);
        this.uow.registerRelationship(serviceAgreement, maica_cc__Service_Agreement__c.maica_cc__Service_Provider__c, serviceProvider);
        this.uow.registerRelationship(serviceAgreement, maica_cc__Service_Agreement__c.maica_cc__Participant__c, contactVar);

        maica_cc__Invoice__c invoiceVar = this.createInvoice(fundingVar.Funding_Type__c);
        this.uow.registerNew(invoiceVar);
        this.uow.registerRelationship(invoiceVar, maica_cc__Invoice__c.maica_cc__Provider__c, serviceProvider);
        this.uow.registerRelationship(invoiceVar, maica_cc__Invoice__c.maica_cc__Participant__c, contactVar);

        maica_cc__Support_Item__c supportItem = this.createSupportItem(fundingVar);
        this.uow.registerNew(supportItem);
        maica_cc__Appointment_Service__c appointmentServiceVar = this.createAppointmentService();
        this.uow.registerNew(appointmentServiceVar);
        this.uow.registerRelationship(supportItem, maica_cc__Support_Item__c.maica_cc__Appointment_Service__c, appointmentServiceVar);
        this.uow.registerRelationship(supportItem, maica_cc__Support_Item__c.maica_cc__Support_Category__c, supportCategory);
        if ('NDIS'.equalsIgnoreCase(fundingVar.maica_cc__Funding_Source__c)) {
            this.uow.registerRelationship(supportItem, maica_cc__Support_Item__c.maica_cc__PACE_Support_Category__c, supportCategory);
        }

        for (Integer j = 0; j < this.appointmentScope; j++) {
            maica_cc__Appointment__c appointmentVar = this.createAppointment(j);
            this.uow.registerNew(appointmentVar);
            maica_cc__Agreement_Item__c agreementItem = this.createAgreementItem(fundingVar.Funding_Type__c, j);
            this.uow.registerNew(agreementItem);
            this.uow.registerRelationship(agreementItem, maica_cc__Agreement_Item__c.maica_cc__Service_Agreement__c, serviceAgreement);
            this.uow.registerRelationship(agreementItem, maica_cc__Agreement_Item__c.maica_cc__Support_Item__c, supportItem);

            for (Integer k = 0; k < this.deliveryActivityScope; k++) {
                maica_cc__Delivery_Activity__c deliveryActivity = this.createDeliveryActivity();
                this.uow.registerNew(deliveryActivity);
                this.uow.registerRelationship(deliveryActivity, maica_cc__Delivery_Activity__c.maica_cc__Agreement_Item__c, agreementItem);
                this.uow.registerRelationship(deliveryActivity, maica_cc__Delivery_Activity__c.maica_cc__Participant__c, contactVar);
                this.uow.registerRelationship(deliveryActivity, maica_cc__Delivery_Activity__c.maica_cc__Appointment__c, appointmentVar);
                this.uow.registerRelationship(deliveryActivity, maica_cc__Delivery_Activity__c.maica_cc__Appointment_Service__c, appointmentServiceVar);
                this.uow.registerRelationship(deliveryActivity, maica_cc__Delivery_Activity__c.maica_cc__Support_Item__c, supportItem);
                this.uow.registerRelationship(deliveryActivity, maica_cc__Delivery_Activity__c.Reporting_Period__c, programPeriods[j]);

                maica_cc__Invoice_Line_Item__c iliVar = this.createInvoiceLineItem(agreementItem.maica_cc__Rate__c);
                this.uow.registerNew(iliVar);
                this.uow.registerRelationship(iliVar, maica_cc__Invoice_Line_Item__c.maica_cc__Invoice__c, invoiceVar);
                this.uow.registerRelationship(iliVar, maica_cc__Invoice_Line_Item__c.maica_cc__Support_Item__c, supportItem);
                this.uow.registerRelationship(iliVar, maica_cc__Invoice_Line_Item__c.maica_cc__Agreement_Item__c, agreementItem);
                this.uow.registerRelationship(iliVar, maica_cc__Invoice_Line_Item__c.maica_cc__Delivery_Activity__c, deliveryActivity);
            }
        }
    }

    public maica_cc__Funding__c createFunding(String fundingSource, String fundingType) {
        return new maica_cc__Funding__c(
            maica_cc__Funding_Source__c = fundingSource,
            Funding_Type__c = fundingType
        );
    }

    public maica_cc__Price_List__c createPriceList() {
        return new maica_cc__Price_List__c(
            Name = 'Test Price List ' + System.currentTimeMillis(),
            maica_cc__Start_Date__c = System.today(),
            maica_cc__End_Date__c = System.today().addYears(1)
        );
    }

    public Funding_Program__c createFundingProgram() {
        return new Funding_Program__c(
            Name = 'Test Funding Program ' + System.currentTimeMillis(),
            Start_Date__c = System.today(),
            End_Date__c = System.today().addYears(1),
            Active__c = true
        );
    }

    public maica_cc__Service_Agreement__c createServiceAgreement(maica_cc__Funding__c fundingVar) {
        return new maica_cc__Service_Agreement__c(
            maica_cc__Start_Date__c = Date.today(),
            maica_cc__End_Date__c = Date.today().addYears(1),
            maica_cc__Funding_Source__c = fundingVar.maica_cc__Funding_Source__c,
            maica_cc__Funding_Type__c = 'Block Funding'.equalsIgnoreCase(fundingVar.maica_cc__Funding_Source__c) ? 'Other' : fundingVar.Funding_Type__c
        );
    }

    public maica_cc__Appointment__c createAppointment(Integer index) {
        Datetime datetimeVar = Datetime.now().addMonths(index).addHours(1);
        return new maica_cc__Appointment__c(
            Title__c = 'Test Appointment ' + index,
            maica_cc__Status__c = 'Scheduled',
            maica_cc__Actual_Start__c = datetimeVar,
            maica_cc__Actual_End__c = datetimeVar.addMonths(index + 1),
            maica_cc__Scheduled_Start__c = datetimeVar,
            maica_cc__Scheduled_End__c = datetimeVar.addMonths(index + 1)
        );
    }

    public maica_cc__Appointment_Service__c createAppointmentService() {
        return new maica_cc__Appointment_Service__c(
            Name = 'Test Appointment Service ' + System.currentTimeMillis()
        );
    }

    public maica_cc__Support_Category__c createSupportCategory(maica_cc__Funding__c fundingVar) {
        return new maica_cc__Support_Category__c(
            Name = 'Test Support Category ' + fundingVar.Funding_Type__c,
            maica_cc__Funding_Source__c = fundingVar.maica_cc__Funding_Source__c,
            maica_cc__Funding_Type__c = fundingVar.Funding_Type__c,
            maica_cc__Category_Number__c = generateRandomString(3),
            maica_cc__Support_Purpose__c = 'NDIS'.equalsIgnoreCase(fundingVar.maica_cc__Funding_Source__c) ? 'Core' :
                ('Home Care Package'.equalsIgnoreCase(fundingVar.maica_cc__Funding_Source__c) ? 'Billable Fee' : null)
        );
    }

    public maica_cc__Support_Item__c createSupportItem(maica_cc__Funding__c fundingVar) {
        return new maica_cc__Support_Item__c(
            Name = 'Test Support Item ' + fundingVar.Funding_Type__c,
            maica_cc__Funding_Source__c = fundingVar.maica_cc__Funding_Source__c,
            maica_cc__Support_Item_Number__c = generateRandomString(10),
            maica_cc__Quantity_Unit_Of_Measure__c = 'Each',
            maica_cc__Service_Time__c = 'Anytime',
            maica_cc__Service_Day__c = 'Anytime',
            maica_cc__Active__c = true,
            maica_cc__Timesheet_Activity__c = true
        );
    }

    public maica_cc__Agreement_Item__c createAgreementItem(String fundingType, Integer index) {
        return new maica_cc__Agreement_Item__c(
            maica_cc__Start_Date__c = System.today().addMonths(index),
            maica_cc__End_Date__c = System.today().addMonths(index + 1),
            maica_cc__Funding_Type__c = fundingType,
            maica_cc__Rate__c = Math.random() * 100.0
        );
    }

    public Program_Period__c createReportingPeriod(Integer index) {
        return new Program_Period__c(
            Period_Start_Date__c = System.today().addMonths(index),
            Period_End_Date__c = System.today().addMonths(index + 1),
            Period_Type__c = 'Reporting'
        );
    }

    public maica_cc__Invoice__c createInvoice(String fundingType) {
        return new maica_cc__Invoice__c(
            maica_cc__Funding_Type__c = fundingType
        );
    }

    public maica_cc__Delivery_Activity__c createDeliveryActivity() {
        return new maica_cc__Delivery_Activity__c(
            maica_cc__Status__c = 'Completed',
            maica_cc__Billing_Status__c = 'Generated',
            maica_cc__Billing_Date__c = Date.today(),
            maica_cc__Quantity__c = 1.0,
            maica_cc__Quantity_Delivered__c = 1.0
        );
    }

    public maica_cc__Invoice_Line_Item__c createInvoiceLineItem(Decimal rate) {
        return new maica_cc__Invoice_Line_Item__c(
            maica_cc__Quantity__c = 1.0,
            maica_cc__Unit_Price__c = rate,
            maica_cc__Claim_Status__c = 'Entered',
            maica_cc__Service_Date__c = Date.today()
        );
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public void deleteData() {
        delete [SELECT Id FROM maica_cc__Invoice_Line_Item__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT :(this.appointmentScope * this.deliveryActivityScope)];
        delete [SELECT Id FROM maica_cc__Delivery_Activity__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT :(this.appointmentScope * this.deliveryActivityScope)];
        delete [SELECT Id FROM Program_Period__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT :this.appointmentScope];
        delete [SELECT Id FROM Funding_Program__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT :this.appointmentScope];
        delete [SELECT Id FROM maica_cc__Invoice__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT :this.appointmentScope];
        delete [SELECT Id FROM maica_cc__Agreement_Item__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT :this.appointmentScope];
        delete [SELECT Id FROM maica_cc__Support_Item__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT :this.appointmentScope];
        delete [SELECT Id FROM maica_cc__Support_Category__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC] ;
        delete [SELECT Id FROM maica_cc__Appointment_Service__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC];
        delete [SELECT Id FROM maica_cc__Appointment__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT :this.appointmentScope];
        delete [SELECT Id FROM maica_cc__Service_Agreement__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC];
        delete [SELECT Id FROM maica_cc__Funding__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC];
        delete [SELECT Id FROM maica_cc__Price_List__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC];
        delete [SELECT Id FROM Contact WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT :this.contactScope];
    }

}