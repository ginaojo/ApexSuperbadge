public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public void execute(QueueableContext context) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody()); 
        List<Product2> productList = new List<Product2>();
        for (Object prod : results) {
            Map<String,Object> productEntry = (Map<String,Object>) prod;
            Product2 productUpdate = new Product2();
            productUpdate.Replacement_Part__c = true;
            productUpdate.Cost__c = (Decimal) productEntry.get('cost');
            productUpdate.Current_Inventory__c = (Integer) productEntry.get('quantity');
            productUpdate.Lifespan_Months__c = (Integer) productEntry.get('lifespan');
            productUpdate.Maintenance_Cycle__c = (Integer) productEntry.get('maintenanceperiod');
            productUpdate.Name = (String) productEntry.get('name');
            productUpdate.Warehouse_SKU__c = (String) productEntry.get('sku');
            productList.add(productUpdate);
        }
        upsert productList Warehouse_SKU__c;
    }
}