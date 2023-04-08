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
        System.assert(cases[0].Subject !=null);
        System.assertEquals(Date.Today().addDays(3), cases[0].Date_Due__c);
        System.assertEquals(vechicle.Id, cases[0].Vehicle__c);
        System.assertEquals(product.Id, cases[0].Equipment_Maintenance_Items__r[0].Equipment__c);
    }
    @isTest
    private static void negativeCreateMaintenanceReq() {
        Vehicle__c vechicle = new Vehicle__c(Name='Camper');
        insert vechicle;
        Case aCase = new Case(Subject='Test Case', Type='Electrical', Vehicle__c=vechicle.Id);
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
        System.assertEquals(0, cases.size(),'List size does not match');
    }
    @isTest
    private static void positiveNoEquipmentItems() {
        Vehicle__c vechicle = new Vehicle__c(Name='Camper');
        insert vechicle;
        Case aCase = new Case(Subject='Test Case', Type='Repair', Vehicle__c=vechicle.Id);
        insert aCase;
        Product2 product = new Product2(Name='Test Product',Maintenance_Cycle__c=3, Replacement_Part__c=true); 
        insert product;

        Test.startTest();
        aCase.Status = 'Closed';
        update aCase;
        Test.stopTest();

        List<Case> cases = [SELECT Id, Status, Type, Subject, Date_Due__c, Date_Reported__c, Vehicle__c, (SELECT Id, Equipment__c,Maintenance_Request__c FROM Equipment_Maintenance_Items__r) FROM Case Where Status !='Closed'];
        System.assertEquals(1, cases.size(),'List size does not match');
        System.assertEquals(Date.Today(),cases[0].Date_Reported__c);
        System.assertEquals('Routine Maintenance', cases[0].Type);
        System.assert(cases[0].Subject !=null);
        System.assertEquals(null, cases[0].Date_Due__c);
        System.assertEquals(0,cases[0].Equipment_Maintenance_Items__r.size());
    }
    @isTest
    private static void positiveBulkCreateMaintenanceReq() {
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        List<Case> cases = new List<Case>();
        for (Integer i=0;i<300;i++) {
            vehicles.add(new Vehicle__c(Name='Camper'+i));
        }
        insert vehicles;
        for (Vehicle__c vehicle : vehicles) {
            cases.add(new Case(Subject='Test Case', Type='Repair', Vehicle__c=vehicle.Id));
        }
        insert cases;
        List<Product2> products = new List<Product2>();
        for (Integer i=5;i<10;i++) {
            products.add(new Product2(Name='Test Product',Maintenance_Cycle__c=i, Replacement_Part__c=true));
        }
        insert products;
        List<Equipment_Maintenance_Item__c> equipmentMaintenaceItems = new List<Equipment_Maintenance_Item__c>();
        for (Case aCase : cases) {
            for (Product2 product : products) {
                equipmentMaintenaceItems.add(new Equipment_Maintenance_Item__c(Equipment__c=product.Id,Maintenance_Request__c=aCase.Id));
            }
        }
        insert equipmentMaintenaceItems;

        Test.startTest();
        for (Case request : cases) {
            request.Status = 'Closed';
        }
        update cases;
        Test.stopTest();

        List<Case> newCases = [SELECT Id, Status, Type, Subject, Date_Due__c, Date_Reported__c, Vehicle__c FROM Case Where Status !='Closed'];
        System.assertEquals(300, newCases.size());
        System.assertEquals(Date.Today(),newCases[0].Date_Reported__c);
        System.assertEquals('Routine Maintenance', newCases[0].Type);
        System.assert(newCases[0].Subject != null);
        System.assertEquals(Date.Today().addDays(5), newCases[0].Date_Due__c);
        
        List<Vehicle__c> vehicleLinks = [SELECT Id, (SELECT Id FROM Cases__r) FROM Vehicle__c];
        System.assertEquals(2,vehicleLinks[0].Cases__r.size());

        List<Product2> productLinks = [SELECT Id, (SELECT Id FROM Equipment_Maintenance_Items__r) FROM Product2];
        System.assertEquals(600,productLinks[0].Equipment_Maintenance_Items__r.size());
    }
}