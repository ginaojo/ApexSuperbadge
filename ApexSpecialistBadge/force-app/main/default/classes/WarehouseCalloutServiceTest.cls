@IsTest
private class WarehouseCalloutServiceTest {
    // implement your mock callout test here
    @isTest
    private static void testWarehouseCallout() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Product2 firstProduct = new Product2(Name='Generator 1000 kW',Maintenance_Cycle__c=120,Warehouse_SKU__c='100003');
        Product2 secondProduct = new Product2(Name='Cooling Fan',Maintenance_Cycle__c=0,Warehouse_SKU__c='100004');
        insert firstProduct;
        insert secondProduct;

        Test.startTest();
        System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();

        List<Product2> products = [SELECT Id, Name FROM Product2];
        System.assertEquals(4,products.size());
    }
}