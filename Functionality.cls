/*
   Functionality - check if functionality is enabled
   if Functionality.isVariableBillingEnabled() = true 
   if Functionality.isCancelBeforeLiveFees() = true 
*/
public without sharing class Functionality {
   
    public static Boolean isVariableBillingEnabled(){
        String variableBilling = 'Variable_Billing';
        List<Functionality__mdt> functionalityList;
        //defaults to disabled
        Boolean isVarBilling = false;
        //should only return one record
        functionalityList = [select Id, DeveloperName, isEnabled__c from Functionality__mdt 
                            where DeveloperName = :variableBilling];
        
        if(functionalityList != null && !functionalityList.isEmpty())    
            isVarBilling = functionalityList[0].isEnabled__c;
        return isVarBilling;
    }
    
    public static Boolean isCancelBeforeLiveFees(){
        String cancelBeforeLiveFees = 'Cancel_Before_Live_Fees';
        List<Functionality__mdt> functionalityList;
        //defaults to disabled
        Boolean isCancelBeforeLive = false;
        //should only return one record
        functionalityList = [select Id, DeveloperName, isEnabled__c from Functionality__mdt 
                            where DeveloperName = :cancelBeforeLiveFees];
        
        if(functionalityList != null && !functionalityList.isEmpty())    
            isCancelBeforeLive = functionalityList[0].isEnabled__c;
        return isCancelBeforeLive;
    }
    
}
