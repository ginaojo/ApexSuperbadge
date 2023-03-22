public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> cases) {
        // TODO: Complete the method to update workorders
        List<Case> closedCases = [Select Id, Vehicle__c FROM Case Where (Type='Repair' OR Type='Routine Maintenance') AND Status='Closed' AND Id IN :cases];
        List<Case> routMainCases = new List<Case>();
        for (Case closedCase : closedCases) {
            Case newCase = new Case();
            newCase.Type = 'Routine Maintenance';
            newCase.Vehicle__c = closedCase.Vehicle__c;
            newCase.Subject = 'Routine Maintenance Follow-Up';
            newCase.Date_Reported__c = Date.today();
            routMainCases.add(newCase);

        }
        insert routMainCases;
    }        
    
}