@isTest
private class MaintenanceRequestHelperTest {
    // implement scheduled code here
    @isTest
    private static void positiveCreateMaintenanceReq() {
        TestDataFactory.getMaintenanceReqWithProducts(1,'Repair');
        List<Case> testCases = [SELECT Id, Status, Type, Subject, Date_Due__c, Date_Reported__c, Vehicle__c, (SELECT Id, Equipment__c,Maintenance_Request__c FROM Equipment_Maintenance_Items__r) FROM Case Where Status !='Closed'];

        Test.startTest();
        testCases[0].Status = 'Closed';
        update testCases;
        Test.stopTest();

        List<Case> cases = [SELECT Id, Status, Type, Subject, Date_Due__c, Date_Reported__c, Vehicle__c, (SELECT Id, Equipment__c,Maintenance_Request__c FROM Equipment_Maintenance_Items__r) FROM Case Where Status !='Closed'];
        System.assertEquals(1, cases.size(),'List size does not match');
        System.assertEquals(Date.Today(),cases[0].Date_Reported__c, 'Dates to don match');
        System.assertEquals('Routine Maintenance', cases[0].Type,'Type is not routine maintenance');
        System.assert(cases[0].Subject !=null, 'Subject is null');
        System.assertEquals(Date.Today().addDays(3), cases[0].Date_Due__c,'Due date does not match');
        System.assertEquals(testCases[0].Vehicle__c, cases[0].Vehicle__c,'The vehicle does not match');
        System.assertEquals(testCases[0].Equipment_Maintenance_Items__r[0].Equipment__c, cases[0].Equipment_Maintenance_Items__r[0].Equipment__c,'The equipment does not match');
    }
    @isTest
    private static void negativeCreateMaintenanceReq() {
        TestDataFactory.getMaintenanceReqWithProducts(1,'Electrical');
        List<Case> testCases = [SELECT Id, Status, Type, Subject, Date_Due__c, Date_Reported__c, Vehicle__c, (SELECT Id, Equipment__c,Maintenance_Request__c FROM Equipment_Maintenance_Items__r) FROM Case Where Status !='Closed'];
    
        Test.startTest();
        testCases[0].Status = 'Closed';
        update testCases;
        Test.stopTest();

        List<Case> cases = [SELECT Id, Status, Type, Subject, Date_Due__c, Date_Reported__c, Vehicle__c, (SELECT Id, Equipment__c,Maintenance_Request__c FROM Equipment_Maintenance_Items__r) FROM Case Where Status !='Closed'];
        System.assertEquals(0, cases.size(),'List size does not match');
    }
    @isTest
    private static void positiveNoEquipmentItems() {
        Vehicle__c vechicle = TestDataFactory.getVehicles('Camper');
        List<Case> testCases = TestDataFactory.getMaintenanceRequests(1,'Repair',vechicle.Id);
        TestDataFactory.getProducts(1);
        
        Test.startTest();
        testCases[0].Status = 'Closed';
        update testCases;
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
    private static void negativeNoEquipmentItems() {  
        Vehicle__c vechicle = TestDataFactory.getVehicles('Camper');
        List<Case> testCases = TestDataFactory.getMaintenanceRequests(1,'Electrical',vechicle.Id);
        TestDataFactory.getProducts(1);

        Test.startTest();
        testCases[0].Status = 'Closed';
        update testCases;
        Test.stopTest();

        List<Case> cases = [SELECT Id, Status, Type, Subject, Date_Due__c, Date_Reported__c, Vehicle__c, (SELECT Id, Equipment__c,Maintenance_Request__c FROM Equipment_Maintenance_Items__r) FROM Case Where Status !='Closed'];
        System.assertEquals(0, cases.size(),'List size does not match');
    }
    @isTest
    private static void positiveBulkCreateMaintenanceReq() {
        Vehicle__c vechicle = TestDataFactory.getVehicles('Camper');
        List<Case> cases = TestDataFactory.getMaintenanceRequests(300, 'Repair', vechicle.Id);
        List<Product2> products = TestDataFactory.getProducts(10);
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
        System.assertEquals(Date.Today().addDays(3), newCases[0].Date_Due__c);
        
        List<Vehicle__c> vehicleLinks = [SELECT Id, (SELECT Id FROM Cases__r) FROM Vehicle__c];
        System.assertEquals(600,vehicleLinks[0].Cases__r.size());

        List<Product2> productLinks = [SELECT Id, (SELECT Id FROM Equipment_Maintenance_Items__r) FROM Product2];
        System.assertEquals(600,productLinks[0].Equipment_Maintenance_Items__r.size());
    }
}