@isTest
public class MedicoesSelectorTest {

    @isTest
    public static void selectByIdTest()
    {
        TestUtil2.insereConfiguracoesPersonalizadas();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account conta = TestUtil2.createAccount('conta', true, uow);
        Medicao__c med = new Medicao__c();
        uow.registerRelationship(med, Medicao__c.Conta__c, conta);
        uow.registerNew(med);
        uow.commitWork();
        Test.startTest();
        List<Medicao__c> meds = MedicoesSelector.newInstance().selectById(new Set<Id>{med.Id});
        System.assertEquals(1, meds.size());
        meds = new MedicoesSelector(true).selectById(new Set<Id>{med.Id});
        Test.stopTest();
        System.assertEquals(1, meds.size());
    }
    
    @isTest
    public static void selectByIdWithItensTest()
    {
        TestUtil2.insereConfiguracoesPersonalizadas();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Account conta = TestUtil2.createAccount('conta', true, uow);
        Moeda__c novaMoeda = new Moeda__c(Name='Dólar', ISOCode__c='USD');
		uow.registerNew(novaMoeda);
        Medicao__c medicao = new Medicao__c();
        uow.registerRelationship(medicao, Medicao__c.MoedaMedicao__c, novaMoeda);
        uow.registerRelationship(medicao, Medicao__c.Conta__c, conta);
        uow.registerNew(medicao);
        
        
        ItemMedicao__c item = new ItemMedicao__c(
                        Quantidade__c = 2, 
                        ValorUnitario__c = 200,
                		DataConversao__c = System.today(),
                		ValorMoedaItemMedicao__c = 100,
                        RecordTypeId = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get('Customizado').getRecordTypeId()
                        );
        uow.registerRelationship(item, ItemMedicao__c.MoedaItemMedicao__c, novaMoeda);
        uow.registerNew(item, ItemMedicao__c.Medicao__c, medicao);
        
        uow.commitWork();
        system.debug('medicao'+medicao.MoedaMedicao__c);
        Test.startTest();
        List<Medicao__c> meds = MedicoesSelector.newInstance().selectByIdWithItens(new Set<Id>{medicao.Id});
        System.assertEquals(1, meds.size());
        System.assertEquals(1, meds[0].ItensMedicao__r.size());
        Test.stopTest();
    }
}