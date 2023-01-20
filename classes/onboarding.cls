public without sharing class onboarding {
    public onboarding() {

    }
    @AuraEnabled
    public static String getApplicant(id applicantId){
        // Query Applicant
        //string result='error'
        try {
            Applicant__c applicant = [SELECT Id, Name, FIrst_Name__c, Middle_Name__c, Last_Name__c, Email_Address__c, Check_Size__c, Contact__c, Stage__c, Typically_Invest__c FROM Applicant__c WHERE Id = :ApplicantId LIMIT 1];
            system.debug('Applicant data'+applicant);
            return JSON.serialize(applicant);

        } catch (Exception e) {
            return 'error';
        }
    }

    @AuraEnabled
    public static String updateApplicant(String  applicantData){
        string result='';
        Applicant__c applicant = (Applicant__c)System.JSON.deserializeStrict(applicantData, Applicant__c.Class);

        try{
            // Applicant__c applicanttoUpdate = [SELECT Id, Name, FIrst_Name__c, Middle_Name__c, Last_Name__c, Email_Address__c, Check_Size__c, Contact__c, Stage__c, Typically_Invest__c FROM Applicant__c WHERE Id = :applicant.id LIMIT 1];

            update applicant;
           return result ='Success';
        }
       catch(Exception e){
        return result ='Error';
       }

    }
    
}