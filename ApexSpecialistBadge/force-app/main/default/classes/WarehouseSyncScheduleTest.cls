@isTest
private class WarehouseSyncScheduleTest {
    // implement scheduled code here
    @isTest
    private static void testWarehouseSyncSchedule() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String cRONEXP = '0 0 1 * * ?';

        Test.startTest();
        String jobID = System.schedule('TestWarehouseSyncSchedule', CRONEXP, new WarehouseSyncSchedule());
        CronTrigger job = [SELECT Id, TimesTriggered FROM CronTrigger WHERE Id = :jobID];
        System.assert(job.Id != null);
        Test.stopTest();

    }
}