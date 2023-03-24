public with sharing class MaintenanceRequestHelper {

public static void updateWorkOrders(List<Case> cases) {
    // TODO: Complete the method to update workorders
    List<Case> closedCases = [Select Id, Vehicle__c,ContactId,AccountId, Priority, (SELECT Id, Equipment__c, Maintenance_Request__c, Quantity__c FROM Equipment_Maintenance_Items__r) FROM Case Where (Type='Repair' OR Type='Routine Maintenance') AND Status='Closed' AND Id IN :cases];
    List<Case> routMainCases = new List<Case>();
    List<Equipment_Maintenance_Item__c> equipItems = new List<Equipment_Maintenance_Item__c>();
    Map<Id,List<Equipment_Maintenance_Item__c>> casesAndEquipment = new Map<Id,List<Equipment_Maintenance_Item__c>>();
    for (Case closedCase : closedCases) {
        Case newCase = closedCase.clone(false,true);
        newCase.Type = 'Routine Maintenance';
        newCase.Subject = 'Routine Maintenance Follow-Up';
        newCase.Date_Reported__c = Date.today();
        routMainCases.add(newCase);
        casesAndEquipment.put(closedCase.Id,closedCase.Equipment_Maintenance_Items__r.deepClone(false,false,false));
    } 
    insert routMainCases;
    List<Equipment_Maintenance_Item__c> equipmentLinks = new List<Equipment_Maintenance_Item__c>();
    for (Case cas : routMainCases) {
        Id originalCaseId = cas.getCloneSourceId();
        if (casesAndEquipment.get(originalCaseId).size() != 0) {
            for (Equipment_Maintenance_Item__c equip : casesAndEquipment.get(originalCaseId)) {
                equip.Maintenance_Request__c = cas.Id;
                equipmentLinks.add(equip);
            }
        }
    }
    insert equipmentLinks;
    }
}        
