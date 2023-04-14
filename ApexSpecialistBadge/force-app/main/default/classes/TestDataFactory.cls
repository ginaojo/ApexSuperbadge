@isTest
public class TestDataFactory {
    public static Vehicle__c getVehicles(String vecName) {
        Vehicle__c vec = new Vehicle__c(Name=vecName);
        insert vec;
        return vec;
    }
    
    public static List<Case> getMaintenanceRequests(Integer numCases, String caseType, Id vehicle) {
        List<Case> cases = new List<Case>();
        for (Integer i=0;i<numCases;i++) {
            cases.add(new Case(Subject='Test Case'+i, Type=caseType, Vehicle__c=vehicle));
        }
        insert cases;
        return cases;
    }
    
    public static List<Product2> getProducts(Integer numProducts) {
        List<Product2> products = new List<Product2>();
        for (Integer i=0;i<numProducts;i++) {
            products.add(new Product2(Name='Test Product'+i,Maintenance_Cycle__c=i+3, Replacement_Part__c=true));
        }
        insert products;
        return products;
    }
    
    public static void getMaintenanceReqWithProducts(Integer numProducts, String caseType) {
        Vehicle__c vechicle = getVehicles('Test Vehicle');
        List<Case> aCase = getMaintenanceRequests(1,caseType,vechicle.Id);
        List<Product2> products = getProducts(numProducts);
        List<Equipment_Maintenance_Item__c> equipmentItems = new List<Equipment_Maintenance_Item__c>();
        for (Product2 prod : products) {
            equipmentItems.add(new Equipment_Maintenance_Item__c(Equipment__c=prod.Id,Maintenance_Request__c=aCase[0].Id));
        }
        insert equipmentItems;
    }
    

}