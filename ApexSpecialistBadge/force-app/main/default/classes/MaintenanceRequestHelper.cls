public with sharing class MaintenanceRequestHelper {

public static void updateWorkOrders(List<Case> newCases, List<Case> oldCases, Map<Id,Case> newMap, Map<Id,Case> oldMap) {
    List<Case> casesToProcess = new List<Case>();
    for (Case singleCase : newCases) {
        String oldStatus = oldMap.get(singleCase.Id).Status;
        if (oldStatus != 'Closed' && singleCase.Status == 'Closed') {
            casesToProcess.add(singleCase);
        }    
    }
    cloneMaintenanceRequests(casesToProcess);
    // TODO: Complete the method to update workorders
    }

    public static void cloneMaintenanceRequests(List<Case> cases) {
        List<Case> closedCases = [Select Id, Vehicle__c,ContactId,AccountId, Priority, (SELECT Id, Equipment__c, Maintenance_Request__c, Quantity__c,Equipment__r.Maintenance_Cycle__c  FROM Equipment_Maintenance_Items__r) FROM Case Where (Type='Repair' OR Type='Routine Maintenance') AND Status='Closed' AND Id IN :cases];
        List<Case> routMainCases = new List<Case>();
        List<Equipment_Maintenance_Item__c> equipItems = new List<Equipment_Maintenance_Item__c>();
        Map<Id,List<Equipment_Maintenance_Item__c>> casesAndEquipment = new Map<Id,List<Equipment_Maintenance_Item__c>>();
        for (Case closedCase : closedCases) {
            Case newCase = closedCase.clone(false,true);
            newCase.Type = 'Routine Maintenance';
            newCase.Subject = 'Routine Maintenance Follow-Up';
            newCase.Date_Reported__c = Date.today();
            Integer shortestcycle = getShortestMaintenceCycle(closedCase.Equipment_Maintenance_Items__r);
            if (shortestcycle != null ) {
                newCase.Date_Due__c = Date.today().addDays(shortestcycle);
            }
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
    public static Integer getShortestMaintenceCycle(List<Equipment_Maintenance_Item__c> equipmentItems) {
        List<Integer> cycle = new List<Integer>();
        
        if (equipmentItems.size() > 1) {
            for (Equipment_Maintenance_Item__c equipment : equipmentItems) {
                cycle.add(Integer.valueOf(equipment.Equipment__r.Maintenance_Cycle__c));
            }
            cycle.sort();
            Integer shortestCycle = cycle[0];
            return shortestCycle;
        } else if (equipmentItems.size() == 1 ) {
            Integer shortestCycle = Integer.valueOf(equipmentItems[0].Equipment__r.Maintenance_Cycle__c);
            return shortestCycle;
        } else {
            return null;
        }
    }
}        
