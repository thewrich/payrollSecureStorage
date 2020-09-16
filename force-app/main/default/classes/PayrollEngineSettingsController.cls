/*
    Purpose:
       The controller for the PayrollEngineSettings page. It enables an admin to create and update the Payroll
       Engine settings.

    Author:     William Rich
    Contact:    william@sunrisehcm.com
    Created:    8/7/2020
    Modified:   9/16/2020 (Secure Storage of Password/API-Key)
*/
public with sharing class PayrollEngineSettingsController {
    private static final String LOG_PREFIX = 'PayrollEngineSettingsController: '; 

    @TestVisible private class PESettings {
        public String apiKey;
        public String baseURL;
        public String companyShortName;
        public String password;
        public String username;

        public PESettings(SRISE__Payroll_Engine_Settings__mdt payrollEngineSettings) {
            this.apiKey = payrollEngineSettings.SRISE__APIKey__c;
            this.baseURL = payrollEngineSettings.SRISE__BaseURL__c;
            this.companyShortName = payrollEngineSettings.SRISE__CompanyShortName__c;
            this.password = payrollEngineSettings.SRISE__Password__c;
            this.username = payrollEngineSettings.SRISE__Username__c;
        }
    }

    @AuraEnabled(cacheable=false)
    public static String getPayrollEngineSettings() {
        List<SRISE__Payroll_Engine_Settings__mdt> settingsList = [
            select 
                SRISE__APIKey__c,
                SRISE__BaseURL__c,
                SRISE__CompanyShortName__c,
                SRISE__Password__c,
                SRISE__Username__c
            from SRISE__Payroll_Engine_Settings__mdt
        ];
        System.debug(LOG_PREFIX + 'settingsList size = ' + settingsList.size());

        SRISE__Payroll_Engine_Settings__mdt payrollEngineSettings;
        if (settingsList.isEmpty()) {
            payrollEngineSettings = new SRISE__Payroll_Engine_Settings__mdt(DeveloperName = 'PayrollEngineSettings');
        }
        else {
            payrollEngineSettings = settingsList.get(0);
        }

        PESettings peSettings = new PESettings(payrollEngineSettings);
        return JSON.serialize(peSettings);
    }

    @AuraEnabled(cacheable=false)
    public static String savePayrollEngineSettings(String jsonSettings) {
        System.debug(LOG_PREFIX + 'savePayrollEngineSettings ' + jsonSettings);

        Metadata.CustomMetadata peSettings = createCustomMetadata(jsonSettings);
        Metadata.DeployContainer container = new Metadata.DeployContainer();
        container.addMetadata(peSettings);
        if (!Test.isRunningTest()) Id asyncResultId = Metadata.Operations.enqueueDeployment(container, new PayrollEngineSettingsCallback());
        return '';
    }

    public static Metadata.CustomMetadata createCustomMetadata(String jsonSettings) {
        PESettings newPESettings = (PESettings) JSON.deserializeStrict(jsonSettings, PESettings.class);
        Metadata.CustomMetadata peSettings = new Metadata.CustomMetadata();
        peSettings.fullName = 'SRISE__Payroll_Engine_Settings.PayrollEngineSettings';
        peSettings.label = 'PayrollEngineSettings';
        peSettings.protected_x = true;
        peSettings.values.add(newField('SRISE__APIKey__c', newPESettings.apiKey));
        peSettings.values.add(newField('SRISE__BaseURL__c', newPESettings.baseURL));
        peSettings.values.add(newField('SRISE__CompanyShortName__c', newPESettings.companyShortName));
        peSettings.values.add(newField('SRISE__Password__c', newPESettings.password));
        peSettings.values.add(newField('SRISE__Username__c', newPESettings.username));
        return peSettings;
    }

    private static Metadata.CustomMetadataValue newField(String fieldName, String fieldValue) {
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = fieldName;
        customField.value = fieldValue;
        return customField;
    }
}