@isTest
public class ItensMedicaoTest {
    
    @isTest
    public static void criarMedicaoProdutoTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Moeda__c dolar = new Moeda__c(Name='Dólar', ISOCode__c='USD');
        Moeda__c real = new Moeda__c(Name='Real', ISOCode__c='BRL');
        uow.registerNew(dolar);
        uow.registerNew(real);
        TaxaMoeda__c taxa = new TaxaMoeda__c(Data__c = System.today(), TaxaConversao__c = 6);
        uow.registerRelationship(taxa, TaxaMoeda__c.MoedaOrigem__c, dolar);
        uow.registerRelationship(taxa, TaxaMoeda__c.MoedaDestino__c, real);
        uow.registerNew(taxa);
        
        Account conta = TestUtil2.createAccount('conta', true, uow);
        uow.registerRelationship(conta, Account.MoedaMedicao__c, real);
        Product2 produto = TestUtil2.createProduct('Fixo Mensal', 'Médio', uow);
        Date inicio = Date.newInstance(2020, 07, 02);
        Date meio = Date.newInstance(2020, 07, 04);
        Date fim = Date.newInstance(2020, 07, 06);
        
        TestUtil2.insereConfiguracoesPersonalizadas();
       	
        Contract contrato = new Contract(StartDate = inicio, EndDate = fim, TipoHoraFaturamento__c = 'Acionamento-Corte');
        uow.registerNew(contrato, Contract.AccountId, conta);
        
        ItemContrato__c item = new ItemContrato__c();
        uow.registerNew(item, ItemContrato__c.Contrato__c, contrato);
        uow.registerRelationship(item, ItemContrato__c.Produto__c, produto);
        
        
        
        Valor__c valor = new Valor__c(Valor__c=100);
        uow.registerRelationship(valor, Valor__c.Moeda__c, dolar);
        uow.registerRelationship(valor, Valor__c.ItemContrato__c, item);
        uow.registerNew(valor);
        
        uow.commitWork();
        
        ConfiguracoesGerais__c cg = ConfiguracoesGerais__c.getOrgDefaults();        
        Id tipoAeronaveId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Aeronave'].Id;
        cg.IdItemContratoTipoAeronave__c = tipoAeronaveId;
        update cg;
        Test.startTest();
        
        Medicao__c medicao = new Medicao__c(Conta__c = conta.Id, Descricao__c = 'Descrição', DataConversao__c = System.today());
        medicao = MedicoesService.criarMedicao(
            medicao, 
            new List<Id>{contrato.Id}, 
            new List<Id>{item.Id}, 
            new Map<Id, Double>{item.Id => 1}, 
            new List<Id>{}
        );
        Medicao__c medicaoCriada = [SELECT Id, TotalMoedaMedicao__c FROM Medicao__c LIMIT 1];
        System.assertEquals(600, medicaoCriada.TotalMoedaMedicao__c);
        ItemMedicao__c itemCriado = [SELECT Id,ValorMoedaMedicao__c FROM ItemMedicao__c LIMIT 1];
        System.assertEquals(600, itemCriado.ValorMoedaMedicao__c);
        
        itemCriado.MoedaItemMedicao__c = real.id;
        update itemCriado;
        
        medicaoCriada = [SELECT Id, TotalMoedaMedicao__c FROM Medicao__c LIMIT 1];
        System.assertEquals(100, medicaoCriada.TotalMoedaMedicao__c);
        itemCriado = [SELECT Id,ValorMoedaMedicao__c FROM ItemMedicao__c LIMIT 1];
        System.assertEquals(100, itemCriado.ValorMoedaMedicao__c);
        
        delete itemCriado;
        
        medicaoCriada = [SELECT Id, TotalMoedaMedicao__c FROM Medicao__c LIMIT 1];
        System.assertEquals(0, medicaoCriada.TotalMoedaMedicao__c);
        
        Test.stopTest();

    }

    @isTest
    public static void validaItensMedicaoTest1()
    {
        try
        {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            Account conta = TestUtil2.createAccount('Conta', true, uow);
            Medicao__c medicao = new Medicao__c();
            uow.registerNew(medicao, Medicao__c.Conta__c, conta);
            ItemMedicao__c item = new ItemMedicao__c(
                        Quantidade__c = 2, 
                        ValorUnitario__c = 200,
                        RecordTypeId = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get('Customizado').getRecordTypeId()
                        );
            uow.registerNew(item, ItemMedicao__c.Medicao__c, medicao);
            uow.commitWork();
        }
        catch(Exception ex)
        {
            System.assert(ex.getMessage().contains(Label.DataConversaoNulaItemMedicao));
        }
    }
    
    @isTest
    public static void validaItensMedicaoTest2()
    {
        try
        {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            Account conta = TestUtil2.createAccount('Conta', true, uow);
            Medicao__c medicao = new Medicao__c();
            uow.registerNew(medicao, Medicao__c.Conta__c, conta);
            ItemMedicao__c item = new ItemMedicao__c(
                        Quantidade__c = 2, 
                        ValorUnitario__c = 200,
                		DataConversao__c = System.today(),
                        RecordTypeId = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get('Customizado').getRecordTypeId()
                        );
            uow.registerNew(item, ItemMedicao__c.Medicao__c, medicao);
            uow.commitWork();
        }
        catch(Exception ex)
        {
            System.assert(ex.getMessage().contains(Label.ValorMoedaItemMedicaoNulo));
        }
    }
    
    @isTest
    public static void validaItensMedicaoTest3()
    {
        try
        {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            Account conta = TestUtil2.createAccount('Conta', true, uow);
            Medicao__c medicao = new Medicao__c();
            uow.registerNew(medicao, Medicao__c.Conta__c, conta);
            ItemMedicao__c item = new ItemMedicao__c(
                        Quantidade__c = 2, 
                        ValorUnitario__c = 200,
                		DataConversao__c = System.today(),
                		ValorMoedaItemMedicao__c = 100,
                        RecordTypeId = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get('Customizado').getRecordTypeId()
                        );
            uow.registerNew(item, ItemMedicao__c.Medicao__c, medicao);
            uow.commitWork();
        }
        catch(Exception ex)
        {
            System.assert(ex.getMessage().contains(Label.MoedaItemMedicaoNula));
        }
    }
}