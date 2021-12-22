@IsTest
public class VoosServiceTest {
    
    @testSetup
    public static void testSetup()
    {
        TestUtil2.insereConfiguracoesPersonalizadas();
    }
    
    @IsTest
    public static void getTempoMissaoContratoDecolagemPousoIntegralTest(){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.today()+1, false, uow);
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
        
        uow.commitWork();
        
        Voo__c vooComTempos = [SELECT Id, (SELECT Id,Ligado__c,Decolagem__c,Pouso__c,Cut__c FROM Trechos__r ORDER BY OrdemExecucao__c ) FROM Voo__c];
        
        VoosServiceImpl service = new VoosServiceImpl();
        TempoMissaoContrato tempo = service.getTempoMissaoContratoDecolagemPousoIntegral(vooComTempos);
        System.assertEquals(0, tempo.tempoCortado);
        System.assertEquals(90, tempo.tempoVoado);
    }
    
    @IsTest
    public static void getTempoMissaoContratoAcionamentoCorteTest(){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.today()+1, false, uow);
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
        
        
        Contract contrato = new Contract(AccountId=voo.Cliente__c,TipoHoraFaturamento__c ='Acionamento-Corte',MinutosDesconsiderarCorte__c = 30, StartDate=System.today().addDays(1), EndDate=System.today().addDays(10));
        uow.registerNew(contrato);
        ItemContrato__c ic = new ItemContrato__c(Aeronave__c=voo.Prefixo__c, ValorHora__c=1000);
        uow.registerNew(ic, ItemContrato__c.Contrato__c, contrato);
        uow.commitWork();
        
        vooComTrechos.ItemContrato__c = ic.Id;
        update vooComTrechos;

        Voo__c vooComTempos = [SELECT Id, itemContrato__r.Contrato__r.TipoHoraFaturamento__c,itemContrato__r.contrato__r.minutosDesconsiderarCorte__c, (SELECT Id,Ligado__c,Decolagem__c,Pouso__c,Cut__c FROM Trechos__r ORDER BY OrdemExecucao__c ) FROM Voo__c where id = :vooComTrechos.id];

        VoosServiceImpl service = new VoosServiceImpl();
        TempoMissaoContrato tempo = service.getTempoMissaoContratoAcionamentoCorte(vooComTempos);

        System.assertEquals(30, tempo.tempoCortado);
        System.assertEquals(120, tempo.tempoVoado);
    }
    
    @IsTest
    public static void getTempoMissaoContratoPorVooTest(){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.today()+1, false, uow);
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
        
        
        Contract contrato = new Contract(AccountId=voo.Cliente__c,TipoHoraFaturamento__c ='Acionamento-Corte',MinutosDesconsiderarCorte__c = 30, StartDate=System.today().addDays(1), EndDate=System.today().addDays(10));
        uow.registerNew(contrato);
        ItemContrato__c ic = new ItemContrato__c(Aeronave__c=voo.Prefixo__c, ValorHora__c=1000);
        uow.registerNew(ic, ItemContrato__c.Contrato__c, contrato);
        uow.commitWork();
        
        vooComTrechos.ItemContrato__c = ic.Id;
        update vooComTrechos;

        Voo__c vooComTempos = [SELECT Id, itemContrato__r.Contrato__r.TipoHoraFaturamento__c,itemContrato__r.contrato__r.minutosDesconsiderarCorte__c, (SELECT Id,Ligado__c,Decolagem__c,Pouso__c,Cut__c FROM Trechos__r ORDER BY OrdemExecucao__c ) FROM Voo__c where id = :vooComTrechos.id];

        Map<Id, TempoMissaoContrato> tempos = VoosService.getTempoMissaoContratoPorVoo(new List<Voo__c>{vooComTempos});
		TempoMissaoContrato tempo = tempos.get(vooComTempos.Id);
        System.assertEquals(30, tempo.tempoCortado);
        System.assertEquals(120, tempo.tempoVoado);
    }
    
    @IsTest
    public static void getTempoMissaoContratoDecolagemPousoNavegacaoTest(){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.today()+1, false, uow);
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
        
        uow.commitWork();
        
        Voo__c vooComTempos = [SELECT Id, (SELECT Id,Ligado__c,Decolagem__c,Pouso__c,Cut__c FROM Trechos__r ORDER BY OrdemExecucao__c ) FROM Voo__c];
        
        VoosServiceImpl service = new VoosServiceImpl();
        TempoMissaoContrato tempo = service.getTempoMissaoContratoDecolagemPousoNavegacao(vooComTempos);
        System.assertEquals(0, tempo.tempoCortado);
        System.assertEquals(80, tempo.tempoVoado);
    }
    
    @isTest
    public static void criarVoosRetroativosTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.now()+1, false, uow);
        uow.commitWork();
        List<Voo__c> voosList = VoosSelector.newInstance().selectWithTrechosById(new Set<Id>{voo.Id});
        Voo__c voo2 = voosList[0].clone();
        List<Trecho__c> trechosClone = new List<Trecho__c>();
        for(Trecho__c t : voo2.trechos__r)
        {
            Trecho__c trechoClone = t.clone();
            trechoClone.Voo__c = null;
            trechosClone.add(trechoClone);
        }
        Test.startTest();
        Map<Decimal, Voo__c> voosPorId = new Map<Decimal, Voo__c>{1 => voo2};
        Map<Decimal, List<Trecho__c>> trechosPorVooId = new  Map<Decimal, List<Trecho__c>>{1 => trechosClone};
        List<Voo__c> voosCriados = VoosService.criarVoosRetroativos(voosPorId, trechosPorVooId);
        
        System.assertEquals(1, voosCriados.size());
        Test.stopTest();
    }
    
    @isTest
    public static void getVoosRastreaveisHoje()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime dataVoo = Datetime.newInstance(System.today(), Time.newInstance(23,0,0,0));
        Voo__c voo = TestUtil2.criarVooRascunho(dataVoo, false, uow);
        uow.commitWork();
        Test.startTest();
        List<Voo__c> voosRastrear = VoosService.getVoosRastreaveisHoje();
        System.assert(voosRastrear.size() == 0);
        voo.Status__c = 'Confirmado';
        update voo;
        voosRastrear = VoosService.getVoosRastreaveisHoje();
        System.assert(voosRastrear.size() == 1);
        Test.stopTest();
    }
    
    @isTest
    public static void rastrearVoos()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime dataVoo = Datetime.newInstance(System.today(), Time.newInstance(23,0,0,0));
        Voo__c voo = TestUtil2.criarVooRascunho(dataVoo, false, uow);
        uow.commitWork();
        Test.startTest();
        voo.Status__c = 'Confirmado';
        update voo;
        System.assert(voo.Skytrac__c == false);
        List<Voo__c> voosRastrear = VoosService.rastrearVoos(new List<Id>{voo.Id});
        System.assert(voosRastrear.size() == 1);
        System.assert(voosRastrear[0].Id == voo.Id);
        System.assert(voosRastrear[0].Skytrac__c == true);
        Test.stopTest();
    }
    
    @isTest
    public static void cancelarRastreioVoos()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime dataVoo = Datetime.newInstance(System.today(), Time.newInstance(23,0,0,0));
        Voo__c voo = TestUtil2.criarVooRascunho(dataVoo, false, uow);
        uow.commitWork();
        Test.startTest();
        voo.Status__c = 'Confirmado';
        update voo;
        List<Voo__c> voosRastrear = VoosService.rastrearVoos(new List<Id>{voo.Id});
        System.assert(voosRastrear[0].Skytrac__c == true);
        System.assert(voosRastrear.size() == 1);
        List<Voo__c> voosCancelarRastreio = VoosService.cancelarRastreioVoos(new List<Id>{voosRastrear[0].Id});
        System.assert(voosCancelarRastreio[0].Skytrac__c == false);
        System.assert(voosCancelarRastreio[0].Id == voosRastrear[0].Id);
        System.assert(voosCancelarRastreio.size() == 1);
        Test.stopTest();
    }
    
    @isTest
    public static void getHorariosPorConta()
    {
        Id conta0 = fflib_IDGenerator.generate(Account.SObjectType);
        Id conta1 = fflib_IDGenerator.generate(Account.SObjectType);
        Time hora = Time.newInstance(12, 0, 0, 0);
        Datetime data0 = Datetime.newInstance(Date.newInstance(2020, 07, 03), hora);
        Datetime data1 = Datetime.newInstance(Date.newInstance(2020, 07, 04), hora);
        Datetime data2 = Datetime.newInstance(Date.newInstance(2020, 07, 05), hora);
        Voo__c voo0 = new Voo__c(DataVoo__c = data0, Cliente__c = conta0);
        Voo__c voo1 = new Voo__c(DataVoo__c = data1, Cliente__c = conta0);
        Voo__c voo2 = new Voo__c(DataVoo__c = data1, Cliente__c = conta0);
        Voo__c voo3 = new Voo__c(DataVoo__c = data0, Cliente__c = conta1);
        List<Voo__c> voosList = new List<Voo__c>{voo0, voo1, voo2, voo3};
            
        Map<Id, Set<Datetime>> horariosPorConta = VoosService.getHorariosPorConta(voosList);
        
        System.assertEquals(2, horariosPorConta.get(conta0).size());
        System.assertEquals(1, horariosPorConta.get(conta1).size());
    }
    
    @IsTest
    public static void undeleteVoosTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime dataVoo = Datetime.newInstance(System.today()+10, Time.newInstance(12, 00, 00, 00));
        Voo__c voo = TestUtil2.criarVooRascunho(dataVoo, false, uow);
        uow.commitWork();
        delete voo;
        Test.startTest();
        List<Voo__c> voosDeletados = VoosSelector.newInstance().selectDeletedById(new Set<Id>{voo.Id});
        System.assertEquals(1, voosDeletados.size());
        VoosService.undeleteVoos(new Set<Id>{voo.Id});
        voosDeletados = VoosSelector.newInstance().selectDeletedById(new Set<Id>{voo.Id});
        System.assertEquals(0, voosDeletados.size());
        Test.stopTest();
    }
    
    @IsTest
    public static void deleteVoosTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime dataVoo = Datetime.newInstance(System.today()+10, Time.newInstance(12, 00, 00, 00));
        Voo__c voo = TestUtil2.criarVooRascunho(dataVoo, false, uow);
        uow.commitWork();
        voo.Status__c = Voos.PRERESERVADO;
        update voo;
        Test.startTest();
        List<Voo__c> voosCadastrados = [SELECT Id FROM Voo__c];
        System.assertEquals(1, voosCadastrados.size());
        VoosService.deleteVoos(new List<Voo__c>{voo});
        voosCadastrados = [SELECT Id FROM Voo__c];
        System.assertEquals(0, voosCadastrados.size());
        Test.stopTest();
    }
    /*
    @isTest
    public static void criarTrechosVooDoLeadTest()
    {
        TestUtil.insereConstantesLead();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Local__c> locais = TestUtil2.criarOrigemDestino(uow);
        Lead l = new Lead(
            LastName = 'LeadLastName',
            Company = 'Company',
            Email = 'lead@email.com',
            Status = 'Novo',
            DataVoo__c = System.now()+10
        );
        Aerovia__c aerovia = TestUtil2.criarAerovia(locais[0], locais[1], 'Bidirecional', uow);
        List<Account> conta = TestUtil.criarContas(uow, 1);
        uow.registerRelationship(l, Lead.Origem__c, locais.get(0));
        uow.registerRelationship(l, Lead.Destino__c, locais.get(1));
        uow.registerRelationship(l, Lead.Retorno__c, locais.get(0));
        uow.registerNew(l);
        uow.commitWork();
        
        Test.startTest();
        fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();
        Voo__c voo = new Voo__c();
        uow2.registerRelationship(voo, Voo__c.LeadGerouVoo__c, l);
        uow2.registerNew(voo, Voo__c.Cliente__c, conta.get(0));
        uow2.commitWork();
        system.debug([select id from voo__c]);
        system.debug([select id from trecho__c]);
        List<Trecho__c> trechos = [SELECT Id, Origem__c, Destino__c from Trecho__c WHERE Voo__c = :voo.Id ORDER BY OrdemExecucao__c];
        System.assertEquals(2, trechos.size());
        
        System.assertEquals(locais.get(0).Id, trechos.get(0).Origem__c);
        System.assertEquals(locais.get(1).Id, trechos.get(0).Destino__c);
        
        System.assertEquals(locais.get(1).Id, trechos.get(1).Origem__c);
        System.assertEquals(locais.get(0).Id, trechos.get(1).Destino__c);
        Test.stopTest();
    }
    */

    @IsTest
    public static void getVoosRotasRecentesTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.today()+10, false, uow);
        uow.commitWork();
        Test.startTest();
        List<Voo__c> voosRotasRecentes = VoosService.getVoosRotasRecentes();
        Test.stopTest();

        System.assertEquals(1, voosRotasRecentes.size());
    }
    
    @IsTest
    public static void getVoosTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.today()+10, false, uow);
        uow.commitWork();
        Test.startTest();
        List<Voo__c> voos = VoosService.getVoos(new List<Id>{voo.Id});
        Test.stopTest();

        System.assertEquals(1, voos.size());
    }
    
    
    
    @isTest
    public static void countPassengersTest()
    {
        TestUtil.create1Voo2Locais2Trechos2Passageiros();
        List<Voo__c> getIdVoo = [select id from voo__c];
        Test.startTest();
        CountPassengersInvocable.countPassengers(new List<Id>{getIdVoo.get(0).Id});
        List<Voo__c> voos = VoosSelector.newInstance().selectById( new Set<Id>{getIdVoo.get(0).Id} );
        Test.stopTest();
        System.assertEquals(2, voos.get(0).totalPassageiros__c);
    }
    
    //TODO: Tá bugado :(
    //ARRUMEI NA RecalculaMissaoInvocableTest, to comentando aqui...
    /*@isTest
    public static void recalculaMissaoTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.today()+10, false, uow);
        uow.commitWork();
        voo.Status__c = 'Pré-reservado';
        update voo;
        Test.startTest();
        voo = [SELECT Id, Missao__c from Voo__c LIMIT 1];
        Id primeiraMissao = voo.Missao__c;
        VoosService.recalculaMissao(new List<Id>{voo.Id});
        Voo__c voo2 = [SELECT Id, Missao__c from Voo__c LIMIT 1];
        Id segundaMissao = voo2.Missao__c;
        Test.stopTest();
        System.assertNotEquals(primeiraMissao, segundaMissao);
    }*/
    
    @isTest
    public static void adicionaVoosRevalidacaoTest(){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(); 
        Voo__c voo = TestUtil2.criarVooRascunho(system.now().addDays(1), false, uow);
        uow.commitWork();
        Test.startTest();
        voo.Status__c = Voos.CONFIRMADO;
        update voo;
        List<Local__c> locais = [select id, tipo__c from local__c limit 1];
        locais[0].tipo__c = 'Offshore';
        locais[0].categoria__c = 'Sísmica';
        update locais;
        List<Voo__c> resultado = [select id from voo__c where AprovacaoDiaVoo__c = 'Pendente'];
        system.assertEquals(0, resultado.size());
        VoosService.adicionaVoosRevalidacao();
        resultado = [select id from voo__c where AprovacaoDiaVoo__c = 'Pendente'];
        system.assertEquals(1, resultado.size());
        Test.stopTest();
    }
    
    @isTest
    public static void setInteressadosFaturamentoTest()
    {
        TestUtil.create1Voo2Locais2Trechos2Passageiros();
        List<Voo__c> getIdVoo = [select id from voo__c];
        Test.startTest();
        List<Id> voos = VoosService.setInteressadosFaturamento(new Set<Id>{getIdVoo[0].Id});
        List<Voo__c> listVoo = [select id, faturamentoinformado__c from voo__c limit 1];
        Test.stopTest();
        System.assert(listVoo[0].faturamentoinformado__c);
    }
    
    @isTest
    public static void selectExecutadosWithOrWithoutContractsTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime diavoo = Datetime.newInstance((Date.today()).addDays(1) , time.newInstance(13, 0, 0, 0));
        List<Voo__c> voosRascunho = TestUtil2.criar2VooRascunho(diavoo, false, uow);
        
        Account conta = TestUtil2.createAccount('Mais uma conta aí', true, uow);
        Contract contrato = new Contract(StartDate = Date.today(), EndDate = Date.today().addDays(1));
        uow.registerNew(contrato, Contract.AccountId, conta);
        
        ItemContrato__c item = new ItemContrato__c(ValorHora__c = 1000);
        uow.registerNew(item, ItemContrato__c.Contrato__c, contrato);
        
        uow.commitWork();
        item.Aeronave__c = voosRascunho[0].Prefixo__c;
        update item;
        Test.startTest();
        for(Voo__c voo : voosRascunho)
        {
            voo.Status__c = Voos.EXECUTADO;
        }
        voosRascunho[0].ItemContrato__c = item.Id;
        system.debug('voos rascunho prefixo + ' + voosRascunho[0].Prefixo__c);
        system.debug('itemContrato prefixo + ' + item.Aeronave__c);
        update voosRascunho;
            
        List<Voo__c> voosSemContrato = VoosService.selectExecutadosWithOrWithoutContracts(new List<Id>{}, new List<Id>{voosRascunho[1].Cliente__c});
        List<Voo__c> voosComContrato = VoosService.selectExecutadosWithOrWithoutContracts(new List<Id>{contrato.Id}, new List<Id>{voosRascunho[1].Cliente__c});
        
        System.assertEquals(1, voosSemContrato.size());
        System.assertEquals(2, voosComContrato.size());
		Test.stopTest();
    }
    
    @isTest
    public static void enviaCartaoEmbarqueTest()
    {
        TestUtil.create1Voo2Locais2Trechos2Passageiros();
        List<Voo__c> getIdVoo = [select id from voo__c];
        Test.startTest();
        EnviaCartaoEmbarqueInvocable.enviaCartao(new List<Id>{getIdVoo.get(0).Id});
        Test.stopTest();
    }
}