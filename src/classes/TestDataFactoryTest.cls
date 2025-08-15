@IsTest
private class TestDataFactoryTest {
    @IsTest
    static void testBehaviorWithoutParams() {
        new TestDataFactory().createTestData();
        Assert.areEqual(12, [SELECT COUNT() FROM maica_cc__Invoice_Line_Item__c]);
        Assert.areEqual(1, [SELECT COUNT() FROM Contact]);
    }

    static void testBehaviorWith1Param() {
        new TestDataFactory(2).createTestData();
        Assert.areEqual(24, [SELECT COUNT() FROM maica_cc__Invoice_Line_Item__c]);
        Assert.areEqual(2, [SELECT COUNT() FROM Contact]);
    }

    static void testBehaviorWith2Params() {
        new TestDataFactory(2, 4).createTestData();
        Assert.areEqual(32, [SELECT COUNT() FROM maica_cc__Invoice_Line_Item__c]);
        Assert.areEqual(2, [SELECT COUNT() FROM Contact]);
    }
}