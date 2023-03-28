@isTest
private class MaintenanceRequestHelperTest {
    // implement scheduled code here
    @isTest
    private static void positiveCreateMaintenanceReq() {
        Vehicle__c vechicle = new Vehicle__c(Name='Camper');
        insert vechicle;
        Case aCase = new Case(Subject='Test Case', Type='Repair', Vehicle__c=vechicle.Id);
        insert aCase;
        Product2 product = new Product2(Name='Test Product',Maintenance_Cycle__c=3, Replacement_Part__c=true); 
        insert product;
        Equipment_Maintenance_Item__c equipmentMainItem = new Equipment_Maintenance_Item__c(Equipment__c=product.Id,Maintenance_Request__c=aCase.Id);
        insert equipmentMainItem;

        Test.startTest();
        aCase.Status = 'Closed';
        update aCase;
        Test.stopTest();

        List<Case> cases = [SELECT Id, Status, Type, Subject, Date_Due__c, Date_Reported__c, Vehicle__c, (SELECT Id, Equipment__c,Maintenance_Request__c FROM Equipment_Maintenance_Items__r) FROM Case Where Status !='Closed'];
        System.assertEquals(1, cases.size(),'List size does not match');
        System.assertEquals(Date.Today(),cases[0].Date_Reported__c);
        System.assertEquals('Routine Maintenance', cases[0].Type);
        System.assert(cases[0].Subject !='');
        System.assertEquals(Date.Today().addDays(3), cases[0].Date_Due__c);
        System.assertEquals(vechicle.Id, cases[0].Vehicle__c);
        System.assertEquals(product.Id, cases[0].Equipment_Maintenance_Items__r[0].Equipment__c);
    }
}