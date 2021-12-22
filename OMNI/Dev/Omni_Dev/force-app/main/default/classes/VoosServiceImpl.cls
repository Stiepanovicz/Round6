public class VoosServiceImpl implements IVoosService {
    public Map<Id, TempoMissaoContrato> getTempoMissaoContratoPorVoo(
        List<Voo__c> voos
    ) {
        Map<Id, TempoMissaoContrato> tempoMissaoContratoPorVoo = new Map<Id, TempoMissaoContrato>();
        for (Voo__c voo : voos) {
            TempoMissaoContrato tempoMissao = handleTipoHoraFaturamento(voo);
            tempoMissaoContratoPorVoo.put(voo.id, tempoMissao);
        }
        return tempoMissaoContratoPorVoo;
    }
    
    public void validaContratoVooPossuiTipoHoraFaturamento(Voo__c voo) {
        Boolean possuiTipoHoraFaturamento =
            voo.itemContrato__c != null &&
            voo.itemContrato__r.Contrato__c != null &&
            voo.itemContrato__r.Contrato__r.TipoHoraFaturamento__c != null;
        if (!possuiTipoHoraFaturamento) {
            throw new VoosServiceException(
                'Contrato sem tipo de hora de Faturamento definido.'
            );
        }
    }
    
    public TempoMissaoContrato handleTipoHoraFaturamento(Voo__c voo) {
        validaContratoVooPossuiTipoHoraFaturamento(voo);
        String tipoHoraFaturamento = voo.itemContrato__r.Contrato__r.TipoHoraFaturamento__c;
        if (tipoHoraFaturamento == 'Decolagem-Pouso Integral') {
            return getTempoMissaoContratoDecolagemPousoIntegral(voo);
        }
        if (tipoHoraFaturamento == 'Acionamento-Corte') {
            return getTempoMissaoContratoAcionamentoCorte(voo);
        }
        if (tipoHoraFaturamento == 'Decolagem-Pouso Navegação') {
            return getTempoMissaoContratoDecolagemPousoNavegacao(voo);
        }
        throw new VoosServiceException('Tipo de faturamento não encontrado');
    }
    
    public TempoMissaoContrato getTempoMissaoContratoDecolagemPousoIntegral(
        Voo__c voo
    ) {
        TempoMissaoContrato tempoMissao = new TempoMissaoContrato();
        tempoMissao.tempoCortado = 0;
        Decimal tempoVoado = 0;
        for (Integer i = 0; i < voo.trechos__r.size(); i++) {
            Trecho__c trecho = voo.trechos__r[i];
            tempoVoado +=
                (trecho.pouso__c.getTime() - trecho.decolagem__c.getTime()) / 60000;
            
            // dps do primeiro trecho e considera o intervalo de decolagem com o pouso anterior
            if (i > 0) {
                tempoVoado +=
                    (trecho.decolagem__c.getTime() -
                     voo.trechos__r[i - 1].pouso__c.getTime()) / 60000;
           }
        }
        tempoMissao.tempoVoado = tempoVoado;
        return tempoMissao;
    }
    
    public TempoMissaoContrato getTempoMissaoContratoAcionamentoCorte(
        Voo__c voo
    ) {
        TempoMissaoContrato tempoMissao = new TempoMissaoContrato();
        Decimal tempoCortado = 0;
        Decimal tempoVoado = 0;
        for (Integer i = 0; i < voo.trechos__r.size(); i++) {
            Trecho__c trecho = voo.trechos__r[i];
            tempoVoado +=
                (trecho.pouso__c.getTime() - trecho.decolagem__c.getTime()) / 60000;
            
            if (i == 0) {
                tempoVoado +=
                    (trecho.decolagem__c.getTime() - trecho.ligado__c.getTime()) / 60000;
            }
            
            // dps do primeiro trecho e o trecho passado não teve corte
            
            if (i > 0 && voo.trechos__r[i - 1].cut__c == null) {
                tempoVoado +=
                    (trecho.decolagem__c.getTime() -
                     voo.trechos__r[i - 1].pouso__c.getTime()) / 60000;
            } else if (i > 0 && voo.trechos__r[i - 1].cut__c != null) {
                tempoCortado +=
                    (trecho.ligado__c.getTime() -
                     voo.trechos__r[i - 1].cut__c.getTime()) / 60000;
                tempoVoado +=
                    (voo.trechos__r[i - 1].cut__c.getTime() -
                     voo.trechos__r[i - 1].pouso__c.getTime()) / 60000;
                tempoVoado +=
                    (trecho.decolagem__c.getTime() - trecho.ligado__c.getTime()) / 60000;
            }
            
            // ultimo trecho
            if (i == (voo.trechos__r.size() - 1)) {
                tempoVoado +=
                    (trecho.cut__c.getTime() - trecho.pouso__c.getTime()) / 60000;
            }
        }
        Decimal paraDesconsiderarCorte = voo.itemContrato__r.contrato__r.minutosDesconsiderarCorte__c !=
            null
            ? voo.itemContrato__r.contrato__r.minutosDesconsiderarCorte__c
            : 0;
        System.debug('paraDesconsiderarCorte: ' + paraDesconsiderarCorte);
        System.debug('tempoCortado: '+ tempoCortado);
        tempoMissao.tempoCortado = tempoCortado > paraDesconsiderarCorte
            ? tempoCortado - paraDesconsiderarCorte
            : 0;
        tempoMissao.tempoVoado = tempoVoado;
        return tempoMissao;
    }
    
    public TempoMissaoContrato getTempoMissaoContratoDecolagemPousoNavegacao(
        Voo__c voo
    ) {
        TempoMissaoContrato tempoMissao = new TempoMissaoContrato();
        Decimal tempoVoado = 0;
        for (Trecho__c trecho : voo.trechos__r) {
            tempoVoado +=
                (trecho.pouso__c.getTime() - trecho.decolagem__c.getTime()) / 60000;
        }
        tempoMissao.tempoVoado = tempoVoado;
        tempoMissao.tempoCortado = 0;
        return tempoMissao;
    }
    
    public List<Voo__c> criarVoosRetroativos(
        Map<Decimal, Voo__c> voosPorId,
        Map<Decimal, List<Trecho__c>> trechosPorVooId
    ) {
        List<Voo__c> voosList = new List<Voo__c>();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Decimal key : voosPorId.keySet()) {
            Voo__c voo = voosPorId.get(key);
            voo.IgnorarTrigger__c = true;
            voo.Status__c = Voos.EXECUTADO;
            voosList.add(voo);
            uow.registerNew(voo);
            
            List<Trecho__c> trechosVoo = trechosPorVooId.get(key);
            for (Integer i = 0; i < trechosVoo.size(); i++) {
                Trecho__c trecho = trechosVoo[i];
                trecho.OrdemExecucao__c = 10 * (i + 1);
                trecho.Status__c = Trechos.FINALIZADO;
                uow.registerNew(trecho, Trecho__c.Voo__c, voo);
            }
        }
        uow.commitWork();
        return voosList;
    }
    
    public List<Voo__c> getVoosRastreaveisHoje() {
        Date hoje = System.today();
        Time hora = Time.newInstance(0, 0, 0, 0);
        Datetime menorData = Datetime.newInstance(hoje, hora);
        Datetime maiorData = Datetime.newInstance(hoje.addDays(1), hora);
        return VoosSelector.newInstance()
            .selectRastreaveisBetweenDates(menorData, maiorData);
    }
    
    public List<Voo__c> rastrearVoos(List<Id> voosId) {
        List<Voo__c> voosParaRastrear = VoosSelector.newInstance()
            .selectById(Utils.getSetIdsByListIds(voosId));
        Set<Id> prefixos = new Set<Id>();
        for (Voo__c voo : voosParaRastrear) {
            if (prefixos.contains(voo.Prefixo__c)) {
                throw new VoosServiceException(
                    'Não é possível rastrear mais de um voo com o mesmo prefixo.'
                );
            } else {
                prefixos.add(voo.Prefixo__c);
            }
        }
        List<Voo__c> voosComSkytrac = VoosSelector.newInstance()
            .selectSkytracByPrefixo(prefixos);
        if (voosComSkytrac.size() > 0) {
            String msg = 'Já existem voos sendo rastreados com o prefixo: ';
            for (Voo__c voo : voosComSkytrac) {
                msg += voo.Prefixo__r.Name + '; ';
            }
            throw new VoosServiceException(msg);
        }
        List<Voo__c> voosParaAtualizar = new List<Voo__c>();
        for (Voo__c voo : voosParaRastrear) {
            if (!voo.Skytrac__c) {
                voo.Skytrac__c = true;
                voo.DataInicioRastreamentoSkytracOriginal__c = System.now();
                voo.DataInicioRastreamentoVooSkytrac__c = System.now();
                voosParaAtualizar.add(voo);
            }
        }
        if (voosParaAtualizar.size() > 0)
            update voosParaAtualizar;
        return getVoosRastreaveisHoje();
    }
    
    public List<Voo__c> cancelarRastreioVoos(List<Id> voosId) {
        List<Voo__c> voos = new List<Voo__c>();
        for (Id vooId : voosId) {
            voos.add(new Voo__c(Id = vooId, Skytrac__c = false));
        }
        update voos;
        return getVoosRastreaveisHoje();
    }
    
    public void criarTrechosVooDoLead(List<Id> vooIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        IVoosSelector voosSelector = VoosSelector.newInstance();
        IVoos voos = Voos.newInstance(
            voosSelector.selectByIdWithLead(new Set<Id>(vooIds))
        );
        voos.criarTrechosParaVoosDoLead(uow);
        uow.commitWork();
    }
    
    public List<Voo__c> getVoos(Set<Id> voosId) {
        return VoosSelector.newInstance().selectWithTrechosById(voosId);
    }
    
    public Map<Id, Set<Datetime>> getHorariosPorConta(List<Voo__c> voosList) {
        Map<Id, Set<Datetime>> horariosPorConta = new Map<Id, Set<Datetime>>();
        for (Voo__c voo : voosList) {
            Set<Datetime> horarios = horariosPorConta.containsKey(voo.Cliente__c)
                ? horariosPorConta.get(voo.Cliente__c)
                : new Set<Datetime>();
            horarios.add(voo.DataVoo__c);
            horariosPorConta.put(voo.Cliente__c, horarios);
        }
        return horariosPorConta;
    }
    
    public void undeleteVoos(Set<Id> voosId) {
        List<Voo__c> voosDeletados = VoosSelector.newInstance()
            .selectDeletedById(voosId);
        undelete voosDeletados;
    }
    
    public void deleteVoos(List<Voo__c> voosList) {
        List<Voo__c> voosSolicitados = VoosSelector.newInstance()
            .selectById(Utils.getSetIds(voosList, 'Id'));
        List<Voo__c> voosPreReservados = new List<Voo__c>();
        for (Voo__c voo : voosSolicitados) {
            if (voo.Status__c == Voos.PRERESERVADO) {
                voosPrereservados.add(voo);
            }
        }
        delete voosPreReservados;
    }
    
    public List<Voo__c> getVoosRotasRecentes() {
        List<Voo__c> voosRecentes = VoosSelector.newInstance()
            .selectRecentsWithTrechos();
        Map<String, Voo__c> mapRotaVoo = new Map<String, Voo__c>();
        Integer numMaxRotas = Integer.valueOf(
            ConfiguracoesTelaCustomizada__c.getOrgDefaults().NumeroRotasRecentes__c
        );
        
        if (voosRecentes.size() > 0) {
            Integer i = 0;
            do {
                mapRotaVoo.put(voosRecentes.get(i).Rota__c, voosRecentes.get(i));
                i++;
            } while (mapRotaVoo.size() < numMaxRotas && i < voosRecentes.size());
        }
        
        return mapRotaVoo.values();
    }
    
    public static void countPassengers(List<Id> vooIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Passageiro__c> passageiros = PassageiroSelector.getPassageirosToSurveyBySetVoosIds(
            Utils.getSetIdsByListIds(vooIds)
        );
        Map<Id, Set<Id>> contatosPorVoo = new Map<Id, Set<Id>>();
        for (Passageiro__c pass : passageiros) {
            if (!contatosPorVoo.containsKey(pass.IdVoo__c)) {
                contatosPorVoo.put(pass.IdVoo__c, new Set<Id>{ pass.Contato__c });
            } else {
                Set<Id> contatosDoVoo = contatosPorVoo.get(pass.IdVoo__c);
                contatosDoVoo.add(pass.Contato__c);
                contatosPorVoo.put(pass.IdVoo__c, contatosDoVoo);
            }
        }
        
        for (Id vooId : contatosPorVoo.keySet()) {
            Set<Id> quantidade = contatosPorVoo.get(vooId);
            Integer numeroContatos = quantidade.size();
            Voo__c novo = new Voo__c();
            novo.Id = vooId;
            novo.TotalPassageiros__c = numeroContatos;
            uow.registerDirty(novo);
        }
        uow.commitWork();
    }
    
    //Método feito para uso em registro único via Flow
    public static void recalculaMissao(List<Id> voosIds) {
        if (voosIds.size() == 1) {
            List<Voo__c> voos = VoosSelector.newInstance()
                .selectWithTrechosById(Utils.getSetIdsByListIds(voosIds));
            Voo__c voo = voos.size() > 0 ? voos.get(0) : null;
            
            if (voo != null) {
                List<Local__c> locaisCalculo = new List<Local__c>();
                locaisCalculo.add(voo.trechos__r[0].Origem__r);
                for (Trecho__c trecho : voo.trechos__r) {
                    locaisCalculo.add(trecho.Destino__r);
                }
                Map<id, CalculoMissaoResult> cmrMap = CalculoMissaoHelper.CalcularMissoes(
                    locaisCalculo,
                    Date.newinstance(
                        voo.DataVoo__c.year(),
                        voo.DataVoo__c.month(),
                        voo.DataVoo__c.day()
                    ),
                    new List<Aeronave__c>{ voo.Prefixo__r }
                );
                
                Missao__c missaoNova = Utils.createMissao(cmrMap.get(voo.Prefixo__c));
                
                fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
                uow.registerNew(missaoNova);
                uow.registerRelationship(voo, Voo__c.Missao__c, missaoNova);
                uow.registerRelationship(missaoNova, Missao__c.Voo__c, voo);
                voo.AprovacaoCalculoMissao__c = 'Pendente';
                uow.registerDirty(voo);
                
                uow.commitWork();
            }
        } else {
            throw new QtdVoosException(
                'Para esse método funcionar, forneça 1 e somente 1 Id.'
            );
        }
    }
    
    public static void adicionaVoosRevalidacao() {
        List<Voo__c> voosList = VoosSelector.newInstance()
            .getVoosAmanhaByStatus(Voos.CONFIRMADO);
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voos.newInstance(voosList).handleAprovacaoDiaVoo(uow);
        uow.commitWork();
    }
    
    public static void updateLogPendenteBySkytrac(Id vooId) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Voos.newInstance(
            VoosSelector.newInstance().selectById(new Set<Id>{ vooId })
        )
            .updateLogPendenteBySkytrac(uow);
        
        uow.commitWork();
    }
    
    public static List<Id> setInteressadosFaturamento(Set<Id> voosIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Id> voosToSend = new List<Id>();
        List<Voo__c> voos = VoosSelector.newInstance()
            .selectByIdToInteressadosFaturamento(voosIds);
        for (Voo__c voo : voos) {
            if (voo.FaturamentoInformado__c == false) {
                voo.FaturamentoInformado__c = true;
                voosToSend.add(voo.Id);
                uow.registerDirty(voo);
            }
        }
        uow.commitWork();
        return voosToSend;
    }
    
    public List<Voo__c> selectExecutadosWithOrWithoutContracts(
        List<Id> contractsId,
        List<Id> accountsId
    ) {
        return VoosSelector.newInstance()
            .selectExecutadosWithOrWithoutContracts(
                Utils.getSetIdsByListIds(contractsId),
                Utils.getSetIdsByListIds(accountsId)
            );
    }
    
    //Método feito para uso em registro único via Flow
    public static List<String> enviarCartaoEmbarque(List<Id> voosIds) {
        List<String> result = new List<String>();
        Id templateId = ConfiguracoesGerais__c.getOrgDefaults().IdTemplateEmailCartaoEmbarque__c;
        
        if (voosIds.size() == 1) {
            List<Passageiro__c> passageiros = [Select Id, Contato__c, IdVoo__c, EmailEnviado__c 
                                               From Passageiro__c 
                                               Where IdVoo__c = :voosIds.get(0) 
                                               And EmailEnviado__c = false];
            
            Set<Id> contatosEnviados = new Set<Id>();
            List<Passageiro__c> passageirosToUpdate = new List<Passageiro__c>();
            List<SendEmailHtmlFlowService.EmailSender> emails = new List<SendEmailHtmlFlowService.EmailSender>();
            if(!passageiros.isEmpty()) {
                for(Passageiro__c ps :passageiros) {
                    if(!contatosEnviados.contains(ps.Contato__c)) {
                        contatosEnviados.add(ps.Contato__c);
                        ps.EmailEnviado__c = true;
                        passageirosToUpdate.add(ps);
                        
                        SendEmailHtmlFlowService.EmailSender em = new SendEmailHtmlFlowService.EmailSender();
                        em.remetente = 'Omni';
                        em.recordId = voosIds.get(0);
                        em.templateId = templateId;
                        em.contactId = ps.Contato__c;
                        emails.add(em);
                    }
                }
                if(!passageirosToUpdate.isEmpty()) {
                    update passageirosToUpdate;
                }
                if (!Test.isRunningTest() && !emails.isEmpty()) {
                  	SendEmailHtmlService.sendEmail(emails);  
                }
                result.add('Emails enviados com sucesso!');
                return result;
            } else {
                System.debug(LoggingLevel.INFO, 'Sem passageiros no voo');
                result.add('Sem passageiros no voo');
                return result;
            }           
        } else {
            throw new QtdVoosException('Para esse método funcionar, forneça 1 e somente 1 Id.');
        }
    }
    
    private class VoosServiceException extends Exception {
    }
    private class QtdVoosException extends Exception {
    }
}