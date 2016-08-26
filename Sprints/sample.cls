/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/

/* **************************************************************************************************
* Class Name : OnBoardFormControllerExtTest
* Created By : Purushothaman Annamalai
* Created Date : 5/17/2016
* Author : MST
* Description : This class will cover the code coverage for 'OnBoardFormControllerExt' class.
*********************************************************************************************************/

@isTest
private class OnBoardFormControllerExt_Test {
    
    // Below testSetup method used to insert necessary data's. 
    @testSetup static void loadData(){
        
        // Insert Account record with "PartnerMarket" record type.
        SmartFactory.overrideFieldsMap.put('Account', new Map<String,String>{'Name' => 'G/O Digital, Phoenix AZ', 'RecordTypeId'=>RecordTypeCache.getRecordType('Account','PartnerMarket').Id}); 
        Account acc = (Account)SmartFactory.createSObject('Account');
        insert acc;
        
        // Insert Contact record with "Affiliated" record type.
        SmartFactory.overrideFieldsMap.put('Contact', new Map<String,String>{'LastName'=>'Contact', 'FirstName'=>'Test', 'RecordTypeId'=>RecordTypeCache.getRecordType('Contact','Affiliated').Id}); 
        
        Contact cntWithAcc = (Contact)SmartFactory.createSObject('Contact');
        cntWithAcc.AccountId = acc.id;
        cntWithAcc.Web_Submitter__c = true;
        cntWithAcc.Phone = '(602) 111-2223 x34432';
        cntWithAcc.Email = 'cnttest@gmail.com';
        insert cntWithAcc;
        
        // Insert Contact without Account.
        Contact cntWithoutAcc = (Contact)SmartFactory.createSObject('Contact');
        cntWithoutAcc.AccountId = null;
        cntWithoutAcc.Web_Submitter__c = true;
        cntWithoutAcc.Phone = '(603) 111-2223 x34432';
        cntWithoutAcc.Email = 'cnttest1@gmail.com';
        insert cntWithoutAcc;
    }
    
    private static OnBoardFormControllerExt initOnBoardController(){
        //Setting Page Parameters
        PageReference pageRef = Page.OnBoardForm;
        Test.setCurrentPage(pageRef);
        
        OnBoardFormModel__c onBoardModel = new OnBoardFormModel__c();
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(onBoardModel);
        OnBoardFormControllerExt onBoardFormExtension = new OnBoardFormControllerExt(stdController);
        return onBoardFormExtension;
    }
    
    // Scenario: Check Sales Rep availability by providing valid search parameter. 
    static testMethod void searchContactScenario_1() {
        
        List<Contact> cntList = [SELECT Id, Name FROM Contact];
        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = cntList[0].Id;
        fixedSearchResults[1] = cntList[1].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.searchString = 'Test Contact';
        onBoardFormExtension.searchContacts();
        
        // Assert the returned contact's list size.
        System.assertEquals(2, onBoardFormExtension.contactList.size());
    }
    
    // Scenario: Check Sales Rep availability without providing search parameter.
    static testMethod void searchContactScenario_2() {
        
        List<Contact> cntList = [SELECT Id, Name FROM Contact];
        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = cntList[0].Id;
        fixedSearchResults[1] = cntList[1].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.searchString = null;
        onBoardFormExtension.searchContacts();
        
        // Assert the returned contact's list size and error message.
        System.assertEquals(0, onBoardFormExtension.contactList.size());
        System.assertEquals(onBoardFormExtension.errNoSearchValue,onBoardFormExtension.errorMessage);
    }
    
    // Scenario: Check Sales Rep availability without providing minimum search parameter.
    static testMethod void searchContactScenario_3() {
        
        List<Contact> cntList = [SELECT Id, Name FROM Contact];
        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = cntList[0].Id;
        fixedSearchResults[1] = cntList[1].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.searchString = 's';
        onBoardFormExtension.searchContacts();
        
        // Assert the returned contact's list size and error message.
        System.assertEquals(0, onBoardFormExtension.contactList.size());
        System.assertEquals(onBoardFormExtension.errSearchValue2char,onBoardFormExtension.errorMessage);
    }
    
    // Scenario: Contacts has been listed and verify default option loaded as "Choose One".
    static testMethod void selectSalesRepScenario_1() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.contactName = onBoardFormExtension.strChoseOne;
        onBoardFormExtension.getContact();
        System.assertEquals(onBoardFormExtension.boolShowContacts,false);
    }
    
    // Scenario: Choosing contacts are "Not in List" from the returned contact search list.
    static testMethod void selectSalesRepScenario_2() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.contactName = onBoardFormExtension.strNotInList;
        onBoardFormExtension.getContact();
        System.assertEquals(onBoardFormExtension.Message, 'Sales Rep will be saved with the following information');
        System.assertEquals(onBoardFormExtension.boolShowContacts,true);
    }
    
    // Scenario: Selecting any one of the contact from the returnd contact search list.
    static testMethod void selectSalesRepScenario_3() {
        List<Contact> cntList = [SELECT Id, Name FROM Contact];
        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = cntList[0].Id;
        fixedSearchResults[1] = cntList[1].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.searchString = 'Test';
        onBoardFormExtension.searchContacts();
        onBoardFormExtension.contactName = 'Test Contact';
        onBoardFormExtension.getContact();
        System.assertEquals(onBoardFormExtension.Message, 'Sales Rep will be saved with Selected Media Partner. If you need to create new Sales Rep select \'Not In List\'');
    }
    
    // Scenario: Verify default business hours has been assigned, while checking closed option for the day.
    static testMethod void defaultBusinessHoursTest() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Sunday_Closed__c = true;
        onBoardFormExtension.webOnBoardFormModel.Monday_Closed__c = true;
        onBoardFormExtension.webOnBoardFormModel.Tuesday_Closed__c = true;
        onBoardFormExtension.webOnBoardFormModel.Wednesday_Closed__c = true;
        onBoardFormExtension.webOnBoardFormModel.Thursday_Closed__c = true;
        onBoardFormExtension.webOnBoardFormModel.Friday_Closed__c = true;
        onBoardFormExtension.webOnBoardFormModel.Saturday_Closed__c = true;
        onBoardFormExtension.setdefaultbusinesshoursmins();
    }
    
    // Scenario: Verify default business hours has been reset, if Current Customer checkbox is enabled.
    static testMethod void resetDefaultBusinessHoursTest() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Current_Customer__c = false;
        onBoardFormExtension.resetDefaultBusinessHours();
    }
    
    // Scenario: Calculate SEO formula budget and verify budget value is not null.
    static testMethod void calculateSEOBudgetTestScenario_1() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Brand_Building__c = true;
        onBoardFormExtension.webOnBoardFormModel.SEO_Package__c = 'Tier 1';
        onBoardFormExtension.seoFormulaBudget();
    }
    
    // Scenario: Calculate SEO formula budget and verify budget value is null.
    static testMethod void calculateSEOBudgetTestScenario_2() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Brand_Building__c = true;
        onBoardFormExtension.webOnBoardFormModel.SEO_Package__c = 'xxxyyy';
        onBoardFormExtension.seoFormulaBudget();
    }
    
    // Scenario: Initialize attachment variables and assert variable values are not null.
    static testMethod void verifyAttachmentVariablesIsNotNull() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        System.assert(onBoardFormExtension.logoUploadAttachment != null);
        System.assert(onBoardFormExtension.imagesCreativeFileAttachment != null);
        System.assert(onBoardFormExtension.contractFileAttachment != null);
        System.assert(onBoardFormExtension.DatabaselistFileAttachment != null);
        System.assert(onBoardFormExtension.LiabilityFormFileAttachment != null);
        System.assert(onBoardFormExtension.AssetImageLogo1FileAttachment != null);
        System.assert(onBoardFormExtension.AssetImageLogo2FileAttachment != null);
        System.assert(onBoardFormExtension.AssetImageLogo3FileAttachment != null);
        System.assert(onBoardFormExtension.AssetImageLogo4FileAttachment != null);
        System.assert(onBoardFormExtension.LocationsUploadAttachment != null);
        System.assert(onBoardFormExtension.EventCalendarUploadAttachment != null);
        System.assert(onBoardFormExtension.ProductsServicesUploadAttachment != null);
    }
    
    // Scenario: Verify picklist values are loaded in page and assert the size of each selectoption list.
    static testMethod void selectOptionsTest() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        System.assertEquals(2, onBoardFormExtension.reportingDashboardOptions.size());
        System.assertEquals(2, onBoardFormExtension.yesNoOptions.size());
        System.assertEquals(3, onBoardFormExtension.getMediaPartnerList().size());
        System.assertEquals(2, onBoardFormExtension.AdvertiserIndustry.size());
        System.assertEquals(1,  onBoardFormExtension.AdvertiserIndustryFocus.size());
    }
    
    // Scenario: Calculate targetted email html fee amount without providing Email Creative Option.
    static testMethod void calculateHtmlEmailFeeScenario_1() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Targeted_Email__c = true;
        onBoardFormExtension.targettedEmailHtmlFee();
    }
    
    // Scenario: Calculate targetted email html fee amount by providing different type of Email Creative Option.
    static testMethod void calculateHtmlEmailFeeScenario_2() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Targeted_Email__c = true;
        onBoardFormExtension.webOnBoardFormModel.Quantity_of_Email_Blasts_per_60_Days__c = '10';
        
        onBoardFormExtension.webOnBoardFormModel.TargetedEmail_CreativeOption__c = 'G/O Digital Design';
        onBoardFormExtension.targettedEmailHtmlFee();
        
        onBoardFormExtension.webOnBoardFormModel.TargetedEmail_CreativeOption__c = 'Client Provided HTML';
        onBoardFormExtension.targettedEmailHtmlFee();
        
        onBoardFormExtension.webOnBoardFormModel.TargetedEmail_CreativeOption__c = 'Client Provided Non-HTML';
        onBoardFormExtension.targettedEmailHtmlFee();
        
        onBoardFormExtension.webOnBoardFormModel.TargetedEmail_CreativeOption__c = 'Automotive Template';
        onBoardFormExtension.targettedEmailHtmlFee();
    }
    
    // Scenario: Calculate social budget without providing Social Option.
    static testMethod void calculateSocialBudgetScenario_1() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.setSocialBudget();
    }
    
    // Scenario: Calculate social budget by providing valid Social Option.
    static testMethod void calculateSocialBudgetScenario_2() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Social_Media_Management__c = true;
        onBoardFormExtension.webOnBoardFormModel.Social_Option__c = 'Social Mgmt - Launch';
        onBoardFormExtension.setSocialBudget();
    }
    
    // Scenario: Calculate social budget by providing invalid Social Option.
    static testMethod void calculateSocialBudgetScenario_3() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Social_Media_Management__c = true;
        onBoardFormExtension.webOnBoardFormModel.Social_Option__c = 'Custom Social Package';
        onBoardFormExtension.setSocialBudget();
    }
    
    // Scenario: Calculate total budget amount by providing invalid Site Budget.
    static testMethod void calculateTotalBudgetScenario_1() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.GOO_Retargeting__c = true;
        onBoardFormExtension.siteBudget = '5test';
        onBoardFormExtension.totalBudgetCalculate();
    }
    
    // Scenario: Calculate total budget amount by providing valid Site Budget and Search Budget values.
    static testMethod void calculateTotalBudgetScenario_2() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.GOO_Retargeting__c = true;
        
        onBoardFormExtension.siteBudget = '5';
        onBoardFormExtension.searchBudget = '5';
        onBoardFormExtension.totalBudgetCalculate();
    }
    
    // Scenario: Calculate total budget amount by providing Site Budget as Null and valid Search Budget values.
    static testMethod void calculateTotalBudgetScenario_3() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.GOO_Retargeting__c = true;
        
        onBoardFormExtension.siteBudget = null;
        onBoardFormExtension.searchBudget = '5';
        onBoardFormExtension.totalBudgetCalculate();     
    }
    
    // Scenario: Calculate total budget amount by providing valid Site Budget and Search Budget value as Null.
    static testMethod void calculateTotalBudgetScenario_4() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.GOO_Retargeting__c = true;
        
        onBoardFormExtension.siteBudget = '5';
        onBoardFormExtension.searchBudget = null;
        onBoardFormExtension.totalBudgetCalculate();
    }
    
    // Scenario: Calculate total budget amount with Site Budget and Search Budget values as Null.
    static testMethod void calculateTotalBudgetScenario_5() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.GOO_Retargeting__c = true;
        
        onBoardFormExtension.siteBudget = null;
        onBoardFormExtension.searchBudget = null;
        onBoardFormExtension.totalBudgetCalculate();
    }
    
    // Scenario: Verify Target Geographical Location based on the PPC Budget Amount.
    static testMethod void checkPPCBudgetAmount() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        
        onBoardFormExtension.webOnBoardFormModel.PPC__c = true;
        onBoardFormExtension.ppcBudgetAmountEntered();
        System.assertEquals(true, onBoardFormExtension.ppcTargetGeoPickListDisabled);
        
        onBoardFormExtension.webOnBoardFormModel.PPC_Budget__c = 3000;
        onBoardFormExtension.ppcBudgetAmountEntered();
        System.assertEquals(false, onBoardFormExtension.ppcTargetGeoPickListDisabled);
    }
    
    // Scenario: Verify target email formula budget amount, when quantity of Email Blasts per 60 Days is 1 day.
    static testMethod void targetEmailFormulaBudgetQuantityOneCheck() {
        setEmailBlastQuantity('1');
    }
    
    // Scenario: Verify target email formula budget amount, when quantity of Email Blasts per 60 Days is 4 days.
    static testMethod void targetEmailFormulaBudgetQuantityFourCheck() {
        setEmailBlastQuantity('4');
    }
    
    // Scenario: Verify target email formula budget amount, when quantity of Email Blasts per 60 Days is 6 days.
    static testMethod void targetEmailFormulaBudgetQuantitySixCheck() {
        setEmailBlastQuantity('6');
    }
    
    // Scenario: Verify target email formula budget amount, when quantity of Email Blasts per 60 Days is 12 days.
    static testMethod void targetEmailFormulaBudgetQuantityTwelveCheck() {
        setEmailBlastQuantity('12');
    }
    
    private static void setEmailBlastQuantity(String quantity) {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Targeted_Email__c = true;
        onBoardFormExtension.webOnBoardFormModel.Quantity_of_Email_Blasts_per_60_Days__c = quantity;
        onBoardFormExtension.webOnBoardFormModel.TargetedEmail_BlastReminder__c = Integer.valueOf(quantity);
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 11000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 20000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 40000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 60000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 80000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 11000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 110000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 135000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 260000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 510000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 1100000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 1600000;
        onBoardFormExtension.targettedEmailFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Recipients_per_Blast__c = 2100000;
        onBoardFormExtension.targettedEmailFormulaBudget();
    }
    
    // Scenario: Calculate LCP budget amount without lead capture page option.
    static testMethod void calculateLCPBudgetScenario_1() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Lead_Capture_Pages__c = true;
        onBoardFormExtension.setLCPFormulaBudget();
    }
    
    // Scenario: Calculate LCP budget amount with differnt lead capture page option.
    static testMethod void calculateLCPBudgetScenario_2() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Lead_Capture_Pages__c = true;
        
        onBoardFormExtension.webOnBoardFormModel.Lead_Capture_Page_Option__c = 'Premium';
        onBoardFormExtension.setLCPFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Lead_Capture_Page_Option__c = 'Signature';
        onBoardFormExtension.setLCPFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Lead_Capture_Page_Option__c = 'Single';
        onBoardFormExtension.setLCPFormulaBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Lead_Capture_Page_Option__c = 'Others';
        onBoardFormExtension.setLCPFormulaBudget();
    }
    
    // Scenario: Calculate Website Budget and Quote without Website option.
    static testMethod void calculateWebsiteQuoteScenario_1() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Websites__c = true;
        onBoardFormExtension.SetWebSiteBudgetAndQuote();
    }
    
    // Scenario: Calculate Website Budget and Quote with different types of Website option.
    static testMethod void calculateWebsiteQuoteScenario_2() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Websites__c = true;
        
        onBoardFormExtension.webOnBoardFormModel.Website_Option__c = 'Start Template (5 Page Website)';
        onBoardFormExtension.SetWebSiteBudgetAndQuote();
        
        onBoardFormExtension.webOnBoardFormModel.Website_Option__c = 'Professional Template (15 Page Website)';
        onBoardFormExtension.SetWebSiteBudgetAndQuote();
        
        onBoardFormExtension.webOnBoardFormModel.Website_Option__c = 'Mobile Only';
        onBoardFormExtension.SetWebSiteBudgetAndQuote();
        
        onBoardFormExtension.webOnBoardFormModel.Website_Option__c = 'Custom Website';
        onBoardFormExtension.SetWebSiteBudgetAndQuote();
        
        onBoardFormExtension.webOnBoardFormModel.Website_Option__c = 'Website Maintenance';
        onBoardFormExtension.SetWebSiteBudgetAndQuote();
        
        onBoardFormExtension.webOnBoardFormModel.Website_Option__c = 'Others';
        onBoardFormExtension.SetWebSiteBudgetAndQuote();
    }
    
    // Scenario: Change website access to null, when SEO Done Prior as "No"
    static testMethod void resetWebsiteAccessTest() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Was_SEO_Done_Prior__c = 'No';
        onBoardFormExtension.resetWebsiteAccess();
    }
    
    // Scenario: Render boolean condition based on SEO Package.
    static testMethod void seoFormulaBudgetDisabledTest() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        
        onBoardFormExtension.webOnBoardFormModel.SEO_Package__c = 'Custom';
        System.assertEquals(true, onBoardFormExtension.seoFormulaBudgetDisabled);
        
        onBoardFormExtension.webOnBoardFormModel.SEO_Package__c = 'Other';
        System.assertEquals(false, onBoardFormExtension.seoFormulaBudgetDisabled);
    }
    
    // Scenario: Verify contract file attachment is required in order to submit the form.
    static testMethod void makeContractRequiredScenario_1() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        System.assertEquals(true, onBoardFormExtension.isContractRequired);
        
        onBoardFormExtension.makeContractRequired();
        System.assertEquals(true, onBoardFormExtension.isContractRequired);
    }
    
    // Scenario: Verify contract file attachment is not required in order to submit the form.
    static testMethod void makeContractRequiredScenario_2() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.getMediaPartnerList();
        System.assertEquals(true, onBoardFormExtension.isContractRequired);
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        onBoardFormExtension.webOnBoardFormModel.Media_Partner__c = acc.Id;
        onBoardFormExtension.makeContractRequired();
        System.assertEquals(false, onBoardFormExtension.isContractRequired);
    } 
    
    // Scenario: Calculate managed email budget without providing number of email subscribers.
    static testMethod void calculateManagedEmailBudgetScenario_1() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Managed_Email__c = true;
        onBoardFormExtension.setManagedEmailBudget();
    }
    
    // Scenario: Calculate managed email budget by providing different range of email subscribers.
    static testMethod void calculateManagedEmailBudgetScenario_2() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Managed_Email__c = true;
        
        onBoardFormExtension.webOnBoardFormModel.Email_Subscribers__c = '0-499';
        onBoardFormExtension.setManagedEmailBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Subscribers__c = '500-2,499';
        onBoardFormExtension.setManagedEmailBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Subscribers__c = '2,500-4,999';
        onBoardFormExtension.setManagedEmailBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Subscribers__c = '5,000-9,999';
        onBoardFormExtension.setManagedEmailBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Subscribers__c = '10,000-15,000';
        onBoardFormExtension.setManagedEmailBudget();
        
        onBoardFormExtension.webOnBoardFormModel.Email_Subscribers__c = '55';
        onBoardFormExtension.setManagedEmailBudget();
    }
    
    // Scenario: Calculate Local Place Reputation budget amount without providing Number Of Locations.
    static testMethod void calculateLPRBudgetScenario_1() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Local_Places_Reputation__c = true;
        onBoardFormExtension.setLPRBudgetFormula();
    }
    
    // Scenario: Calculate Local Place Reputation budget amount by providing different values for Number Of Locations.
    static testMethod void calculateLPRBudgetScenario_2() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.webOnBoardFormModel.Local_Places_Reputation__c = true;
        
        onBoardFormExtension.webOnBoardFormModel.Number_of_Locations__c = 8;
        onBoardFormExtension.setLPRBudgetFormula();
        
        onBoardFormExtension.webOnBoardFormModel.Number_of_Locations__c = 18;
        onBoardFormExtension.setLPRBudgetFormula();
        
        onBoardFormExtension.webOnBoardFormModel.Number_of_Locations__c = 51;
        onBoardFormExtension.setLPRBudgetFormula();
    }
    
    // Scenario: Provide invalid details in the form and validate the error messages.
    static testMethod void saveOnBoardFormWithErrorTest() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError1 = hasErrorCheck('Please Choose Sales Rep');
        System.assertEquals(true, hasError1);
        
        Contact cnt = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test@gmi.com');
        onBoardFormExtension.contactName = 'Not In List';
        onBoardFormExtension.getContact();
        onBoardFormExtension.newContact = cnt;
        
        onBoardFormExtension.webOnBoardFormModel.Websites__c = true;
        onBoardFormExtension.webOnBoardFormModel.Website_Option__c = 'Custom Website';
        onBoardFormExtension.webOnBoardFormModel.Website_Quote_Cost_Custom__c = 4000;
        
        onBoardFormExtension.webOnBoardFormModel.Social_Media_Management__c = true;
        onBoardFormExtension.webOnBoardFormModel.Social_Option__c = 'Custom Social Package';
        onBoardFormExtension.webOnBoardFormModel.Audit__c = null;
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError2 = hasErrorCheck('Phone number required');
        System.assertEquals(true, hasError2);
        
        Boolean hasError3 = hasErrorCheck('Advertiser Industry: You must select a value');
        System.assertEquals(true, hasError3);
        
        Boolean hasError4 = hasErrorCheck('Advertiser Primary Focus: You must select a value');
        System.assertEquals(true, hasError4);
        
        Boolean hasError5 = hasErrorCheck('Contract Information, Contract: You must upload a file');
        System.assertEquals(true, hasError5);
        
        onBoardFormExtension.webOnBoardFormModel.Social_Media_Management__c = true;
        onBoardFormExtension.webOnBoardFormModel.Social_Option__c = 'Custom Social Package';
        onBoardFormExtension.webOnBoardFormModel.Audit__c = 'Yes';
        onBoardFormExtension.webOnBoardFormModel.Social_Budget__c = 2300;
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError6 = hasErrorCheck('Social Option: You cannot select (Custom Social Package) without Audit Url in Contract Information');
        System.assertEquals(true, hasError6);
        
        onBoardFormExtension.webOnBoardFormModel.Social_Media_Management__c = true;
        onBoardFormExtension.webOnBoardFormModel.Social_Option__c = 'Social Mgmt - Reach Ad Spend';
        onBoardFormExtension.webOnBoardFormModel.Audit__c = 'Yes';
        onBoardFormExtension.webOnBoardFormModel.Social_Budget__c = 0;
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError7 = hasErrorCheck('Social Budget: You must enter minimum $1');
        System.assertEquals(true, hasError7);
        
        onBoardFormExtension.webOnBoardFormModel.Social_Advertising__c = true;
        onBoardFormExtension.webOnBoardFormModel.Social_Ads_Budget_Month__c = 5;
        onBoardFormExtension.webOnBoardFormModel.Social_Ads_Package__c = 'Start';
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError8 = hasErrorCheck('Social Ads Budget/Month: You must enter minimum $500');
        System.assertEquals(true, hasError8);
        
        onBoardFormExtension.webOnBoardFormModel.Social_Ads_Budget_Month__c = 1000;
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError9 = hasErrorCheck('Social Ads Budget/Month(Start): You must enter $500, $650, $750');
        System.assertEquals(true, hasError9);
        
        onBoardFormExtension.webOnBoardFormModel.Social_Ads_Budget_Month__c = 2002;
        onBoardFormExtension.webOnBoardFormModel.Social_Ads_Package__c = 'Climb';
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError10 = hasErrorCheck('Social Ads Budget/Month(Climb): You must enter between $750, and $1999');
        System.assertEquals(true, hasError10);
        
        onBoardFormExtension.webOnBoardFormModel.Social_Ads_Budget_Month__c = 8000;
        onBoardFormExtension.webOnBoardFormModel.Social_Ads_Package__c = 'Build';
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError11= hasErrorCheck('Social Ads Budget/Month(Build): You must enter between $2000, and $7499');
        System.assertEquals(true, hasError11);
        
        onBoardFormExtension.webOnBoardFormModel.Social_Ads_Budget_Month__c = 5000;
        onBoardFormExtension.webOnBoardFormModel.Social_Ads_Package__c = 'Grow';
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError12 = hasErrorCheck('Social Ads Budget/Month(Grow): You must enter $7500 or above');
        System.assertEquals(true, hasError12);
        
        onBoardFormExtension.webOnBoardFormModel.SEO__c = true;
        onBoardFormExtension.webOnBoardFormModel.SEO_Package__c = 'National/Custom Quote SEO Package';
        onBoardFormExtension.webOnBoardFormModel.Audit__c = null;
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError13 = hasErrorCheck('SEO Package: You cannot select <National/Custom Quote SEO Package> without Audit Url in Contract Information');
        System.assertEquals(true, hasError13);
        
        onBoardFormExtension.webOnBoardFormModel.Audit__c = 'Yes';
        onBoardFormExtension.webOnBoardFormModel.SEO_Budget__c = 500;
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError14 = hasErrorCheck('SEO Budget/Mth: You must enter minimum $7700');
        System.assertEquals(true, hasError14);
        
        onBoardFormExtension.webOnBoardFormModel.Local_Places_Reputation__c = true;
        onBoardFormExtension.webOnBoardFormModel.Number_of_Locations__c = 0;
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError15 = hasErrorCheck('Maps & Reputation, Number of Locations: You must enter minimum 1 or above');
        System.assertEquals(true, hasError15);
        
        onBoardFormExtension.webOnBoardFormModel.PPC__c = true;
        onBoardFormExtension.webOnBoardFormModel.Contract_Length_Months_PPC__c = '1';
        onBoardFormExtension.saveOnBoardForm();
        
        Boolean hasError16 = hasErrorCheck('Rate Request ID : You must enter a value');
        System.assertEquals(true, hasError16);
        
        Boolean hasError17 = hasErrorCheck('Notes - PPC : You must enter a value');
        System.assertEquals(true, hasError17);
        
        onBoardFormExtension.webOnBoardFormModel.GOO_Retargeting__c = true;
        onBoardFormExtension.webOnBoardFormModel.Ad_Creative_Type__c = 'ddd';
        onBoardFormExtension.siteBudget = '3a';
        onBoardFormExtension.searchBudget = '3a';
        onBoardFormExtension.webOnBoardFormModel.Number_of_Locations__c = 5;
        onBoardFormExtension.saveOnBoardForm();
    } 
    
    private static boolean hasErrorCheck(String errMsg) {
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        
        // Check that the error message you are expecting is in pageMessages
        Boolean messageFound = false;
        for(ApexPages.Message message : pageMessages) {
            if(message.getDetail().contains(errMsg) || message.getSummary().contains(errMsg)) {
                messageFound = true;        
            }
        }
        return messageFound;
    }
    
    // Scenario: Provide all necessary and valid details in order to submit the form successfully.
    static testMethod void saveOnBoardFormWithoutErrorTest() {
        OnBoardFormControllerExt onBoardFormExtension = initonBoardController();
        
        Contact cnt = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test@gmi.com', Phone = '(602) 111-2223 x34432');
        onBoardFormExtension.contactName = 'Not In List';
        onBoardFormExtension.getContact();
        
        onBoardFormExtension.newContact = cnt;
        onBoardFormExtension.webOnBoardFormModel.Current_Customer__c = true;
        System.assertNotEquals(null, onBoardFormExtension.contractFileAttachment);
        
        onBoardFormExtension.includeClientInfo = 'true';
        onBoardFormExtension.getMediaPartnerList();
        onBoardFormExtension.makeContractRequired();
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        onBoardFormExtension.webOnBoardFormModel.Media_Partner__c = acc.Id;
        onBoardFormExtension.makeContractRequired();
        onBoardFormExtension.saveOnBoardForm();
        System.assertEquals(false, onBoardFormExtension.isContractRequired);
        
        onBoardFormExtension.webOnBoardFormModel.Advertiser_Contact_Phone__c = '999 999-9999';
        onBoardFormExtension.saveOnBoardForm();
        
        onBoardFormExtension.webOnBoardFormModel.Advertiser_Contact_Phone__c = '(999) 999-9999';
        onBoardFormExtension.saveOnBoardForm();
        
        onBoardFormExtension.webOnBoardFormModel.Advertiser_Company_Name__c = 'Test';
        onBoardFormExtension.webOnBoardFormModel.Advertiser_Contact_First_Name__c = 'Test FirstName';
        onBoardFormExtension.webOnBoardFormModel.Advertiser_Contact_Last_Name__c = 'Test LastName';
        onBoardFormExtension.webOnBoardFormModel.Advertiser_Email_Address__c = 'test@mail.com';
        onBoardFormExtension.webOnBoardFormModel.Managed_Email__c = true;
        onBoardFormExtension.webOnBoardFormModel.Social_Media_Management__c = true;
        onBoardFormExtension.saveOnBoardForm();
        
        List<OnBoardFormModel__c> onBoardFormList = [SELECT Id, Name FROM OnBoardFormModel__c];
        
        // Verify OnboardFormModel record has been inserted succesfully.
        System.assertEquals(1, onBoardFormList.size());
    }
    
}