@isTest
public class MedicoesServiceTest {
    
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
        Test.stopTest();
        medicao = [SELECT id, TotalMoedaMedicao__c from Medicao__c LIMIT 1];
        System.assert(medicao != null);
        //System.assert(medicao.TotalMoedaMedicao__c == 600);
    }
    
    @isTest
    public static void criarMedicaoVooContratoTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.today()+1, true, uow);
       	voo.TempoVoado__c = 120;
        voo.TempoCorte__c = 30;
        uow.commitWork();
        
        uow = Application.UnitOfWork.newInstance();
        
        Voo__c vooComTrechos = [SELECT Id, (SELECT Id FROM Trechos__r ORDER BY OrdemExecucao__c ) FROM Voo__c];
        List<Trecho__c> trechosVoo = vooComTrechos.trechos__r;
        Trecho__c trecho1 = trechosVoo[0];
        Trecho__c trecho2 = trechosVoo[1];
        Datetime agora = System.now();
        trecho1.ligado__c = agora;
        trecho1.Decolagem__c = agora.addMinutes(10);
        trecho1.Pouso__c = trecho1.Decolagem__c.addMinutes(40);
        trecho1.Cut__c = trecho1.Pouso__c.addMinutes(10);
        
        trecho2.ligado__c = trecho1.Cut__c.addMinutes(60);
        trecho2.Decolagem__c = trecho2.ligado__c.addMinutes(10);
        trecho2.Pouso__c = trecho2.Decolagem__c.addMinutes(40);
        trecho2.Cut__c = trecho2.Pouso__c.addMinutes(10);
        
        uow.registerDirty(trecho1);
        uow.registerDirty(trecho2);
        
        Account conta = [SELECT Id FROM Account LIMIT 1];
        //Aeronave__c aeronave = [SELECT Id FROM Aeronave__c LIMIT 1];
        Date inicio = Date.newInstance(2020, 07, 02);
        Date fim = Date.newInstance(2020, 07, 04);
        Contract contrato = new Contract(StartDate = inicio, EndDate = fim, AccountId = conta.Id, TipoHoraFaturamento__c = 'Acionamento-Corte', MinutosDesconsiderarCorte__c = 30);
        uow.registerNew(contrato);
        ItemContrato__c item = new ItemContrato__c(Aeronave__c = voo.Prefixo__c, HoraCorte__c = 100);
        uow.registerNew(item, ItemContrato__c.Contrato__c, contrato);
        
        Moeda__c moeda = new Moeda__c(Name='Dólar', ISOCode__c='USD');
        uow.registerNew(moeda);
        
        uow.registerRelationship(conta, Account.MoedaMedicao__c, moeda);
        uow.registerDirty(conta);
            
        Valor__c valor = new Valor__c(Valor__c=100);
        uow.registerRelationship(valor, Valor__c.Moeda__c, moeda);
        uow.registerRelationship(valor, Valor__c.ItemContrato__c, item);
        uow.registerNew(valor);
        
        voo.Status__c = Voos.EXECUTADO;
        uow.registerRelationship(voo, Voo__c.ItemContrato__c, item);
        uow.registerDirty(voo);
        
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
            new List<Id>{}, 
            new Map<Id, Double>{}, 
            new List<Id>{voo.Id}
        );
        Test.stopTest();
        medicao = [SELECT id, TotalMoedaMedicao__c from Medicao__c LIMIT 1];
        System.debug(medicao.TotalMoedaMedicao__c);
        System.assert(medicao != null);
        //System.assert(medicao.TotalMoedaMedicao__c == 250);
    }
    
    
    @isTest
    public static void criarMedicaoVooSemContratoTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.today()+1, true, uow);
       	voo.TempoVoado__c = 60;
        voo.TempoCorte__c = 30;
        voo.ValorHoraVoada__c = 100;
        voo.ValorHoraCorte__c = 10;
        uow.commitWork();
        
        uow = Application.UnitOfWork.newInstance();
        
        Moeda__c moeda = new Moeda__c(Name='Dólar', ISOCode__c='USD');
        uow.registerNew(moeda);
        
        Account conta = [SELECT Id FROM Account LIMIT 1];
        uow.registerRelationship(conta, Account.MoedaMedicao__c, moeda);
        uow.registerDirty(conta);

        
        voo.Status__c = Voos.EXECUTADO;
        uow.registerDirty(voo);
        
        uow.commitWork();
        
        ConfiguracoesGerais__c cg = ConfiguracoesGerais__c.getOrgDefaults();        
        Id tipoAeronaveId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Aeronave'].Id;
        cg.IdItemContratoTipoAeronave__c = tipoAeronaveId;
        update cg;
        
        Test.startTest();
        Medicao__c medicao = new Medicao__c(Conta__c = conta.Id, Descricao__c = 'Descrição', DataConversao__c = System.today());
        medicao = MedicoesService.criarMedicao(
            medicao, 
            new List<Id>{}, 
            new List<Id>{}, 
            new Map<Id, Double>{}, 
            new List<Id>{voo.Id}
        );
        Test.stopTest();
        medicao = [SELECT id, TotalMoedaMedicao__c from Medicao__c LIMIT 1];
        System.assert(medicao.TotalMoedaMedicao__c == 105);
    }
    
}