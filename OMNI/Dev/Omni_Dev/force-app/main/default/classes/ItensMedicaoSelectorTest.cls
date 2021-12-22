@isTest
public class ItensMedicaoSelectorTest {
    
    @TestSetup
    public static void setup(){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Moeda__c moedaOrigem = new Moeda__c(Name='Dólar',ISOCode__c='USD');
        Moeda__c moedaDestino = new Moeda__c(Name='Real',ISOCode__c='BRL');
        Date data = System.today();
        
        uow.registerNew(moedaOrigem);
        uow.registerNew(moedaDestino);
        
        TaxaMoeda__c dolarReal = new TaxaMoeda__c(Data__c=data, TaxaConversao__c=9);
        uow.registerRelationship(dolarReal, TaxaMoeda__c.MoedaOrigem__c, moedaOrigem);
        uow.registerRelationship(dolarReal, TaxaMoeda__c.MoedaDestino__c, moedaDestino);
        uow.registerNew(dolarReal);
        uow.commitWork();
    }

    @isTest
    public static void selectByMedicaoIdTest(){
        
        Moeda__c moeda = [SELECT Id FROM Moeda__c LIMIT 1];
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Integer numContas = 1;
        List<Account> contas = TestUtil.criarContas(uow, numContas);
        Account conta = contas[0];
        Medicao__c medicao = new Medicao__c(MoedaMedicao__c = moeda.id);
        uow.registerNew(medicao, Medicao__c.Conta__c, conta);
        ItemMedicao__c item = new ItemMedicao__c(
            		Quantidade__c = 2, 
            		ValorUnitario__c = 200, 
            		MoedaMedicao__c = moeda.id,
            		MoedaItemMedicao__c = moeda.id,
            		ValorMoedaItemMedicao__c = 200,
            		DataConversao__c = System.today(),
        			RecordTypeId = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get('Customizado').getRecordTypeId()
        			);
        uow.registerNew(item, ItemMedicao__c.Medicao__c, medicao);
        uow.commitWork();
        
        Test.startTest();
        List<ItemMedicao__c> itens = ItensMedicaoSelector.newInstance().selectByMedicaoId(new Set<Id>{medicao.Id});
        System.assert(itens.size() == 1);
        Test.stopTest();
    }
    
    @isTest
    public static void selectByIdTest(){
        Moeda__c moeda = [SELECT Id FROM Moeda__c LIMIT 1];
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Integer numContas = 1;
        List<Account> contas = TestUtil.criarContas(uow, numContas);
        Account conta = contas[0];
        Medicao__c medicao = new Medicao__c(MoedaMedicao__c = moeda.id);
        uow.registerNew(medicao, Medicao__c.Conta__c, conta);
        ItemMedicao__c item = new ItemMedicao__c(
            		Quantidade__c = 2, 
            		ValorUnitario__c = 200,
            		MoedaMedicao__c = moeda.id,
            		MoedaItemMedicao__c = moeda.id,
            		ValorMoedaItemMedicao__c = 200,
            		DataConversao__c = System.today(),
        			RecordTypeId = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get('Customizado').getRecordTypeId()
        			);
        uow.registerNew(item, ItemMedicao__c.Medicao__c, medicao);
        uow.commitWork();
        
        Test.startTest();
        List<ItemMedicao__c> itens = ItensMedicaoSelector.newInstance().selectById(new Set<Id>{item.Id});
        System.assert(itens.size() == 1);
        Test.stopTest();
    }
    
    @isTest
    public static void selectByMedicaoIdWithVooRelatedTest(){
        Moeda__c moeda = [SELECT Id FROM Moeda__c LIMIT 1];
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Integer numContas = 1;
        List<Account> contas = TestUtil.criarContas(uow, numContas);
        Account conta = contas[0];
        Medicao__c medicao = new Medicao__c(MoedaMedicao__c = moeda.id);
        uow.registerNew(medicao, Medicao__c.Conta__c, conta);
        ItemMedicao__c item = new ItemMedicao__c(
            		Quantidade__c = 2, 
            		ValorUnitario__c = 200, 
            		MoedaMedicao__c = moeda.id,
            		MoedaItemMedicao__c = moeda.id,
            		ValorMoedaItemMedicao__c = 200,
            		DataConversao__c = System.today(),
        			RecordTypeId = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get('Customizado').getRecordTypeId()
        			);
        uow.registerNew(item, ItemMedicao__c.Medicao__c, medicao);
        uow.commitWork();
        
        Test.startTest();
        List<ItemMedicao__c> itens = ItensMedicaoSelector.newInstance().selectByMedicaoIdWithVooRelated(new Set<Id>{medicao.Id});
        System.assert(itens.size() == 0);
        Test.stopTest();
    }
}