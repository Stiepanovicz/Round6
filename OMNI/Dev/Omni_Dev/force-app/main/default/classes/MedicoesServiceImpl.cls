public class MedicoesServiceImpl implements IMedicoesService {

    private Id RECORD_TYPE_PRODUTO = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get(Label.DeveloperNameItemMedicaoProduto).getRecordTypeId();
    private Id RECORD_TYPE_HORA_VOADA = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get(Label.DeveloperNameItemMedicaoHoraVoada).getRecordTypeId();
    private Id RECORD_TYPE_CORTE = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get(Label.DeveloperNameItemMedicaoCorte).getRecordTypeId();
    
    public Medicao__c criarMedicao(
        Medicao__c medicao, 
        List<Id> contratosSelecionados, 
        List<Id> produtosSelecionados, 
        Map<Id, Double> mapQuantidadeProduto, 
        List<Id> voosSelecionados
    )
    {
        try
        {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            Boolean consultarDataVoos = medicao.UtilizarDataVooConversao__c != null ? medicao.UtilizarDataVooConversao__c : false;
            if(contratosSelecionados.size() > 0){
                medicao.Contrato__c = contratosSelecionados[0];
            }
            List<Account> accountList = AccountsSelector.newInstance().selectById(new Set<Id>{medicao.Conta__c});
            if(accountList.size() != 1)
            {
                throw new MedicoesServiceException('Uma conta deve ser definida para a medição.');
            }
            Account contaMedicao = accountList[0];
            if(contaMedicao.MoedaMedicao__c == null)
            {
                throw new MedicoesServiceException('A conta selecionada não possui uma moeda definida para a medição.');
            }
            medicao.MoedaMedicao__c = contaMedicao.MoedaMedicao__c;
            
            List<Voo__c> voosList = VoosSelector.newInstance().selectById(Utils.getSetIdsByListIds(voosSelecionados));
            
            Set<Id> itensContratos = new Set<Id>();
            Map<Id, Id> itensContratoVoos = new Map<Id, Id>();
            for(Voo__c voo : voosList)
            {
                if(voo.ItemContrato__c != null)
                {
                    itensContratos.add(voo.ItemContrato__c);
                    itensContratoVoos.put(voo.Id, voo.ItemContrato__c);
                }
            }

			Moeda__c dolar;            
            if(itensContratoVoos.values().size() != voosList.size())
            {
                dolar = MoedasSelector.newInstance().selectDolar();
                if(dolar == null)
                {
                    throw new MedicoesServiceException('Não encontramos a moeda Dólar cadastrada.');
                }
            }
            
            for(Id produtoSelecionado : produtosSelecionados)
            {
                itensContratos.add(produtoSelecionado);
            }
            
            Map<Id, ItemContrato__c> itensContratoMap = new Map<Id, ItemContrato__c>(ItensContratoSelector.newInstance().selectWithValores(itensContratos));
            
            for(Id produtoSelecionado : produtosSelecionados)
            {
                ItemContrato__c item = itensContratoMap.get(produtoSelecionado);
                if(item == null)
                {
                    throw new MedicoesServiceException('Item do contrato com id '+ produtoSelecionado + ' não encontrado.');
                }
                if(item.Valores__r == null || item.Valores__r.size() == 0)
                {
                    throw new MedicoesServiceException(item.Produto__r.Name + ' não possui valores definidos.');
                }
                for(Valor__c valor : item.Valores__r)
                {
                    Double quantidade = mapQuantidadeProduto.get(produtoSelecionado);
                    if(quantidade == null)
                    {
                        throw new MedicoesServiceException('Produto com id '+ produtoSelecionado + ' não possui quantidade definida.');
                    }
                    ItemMedicao__c itemMedicao = new ItemMedicao__c(Quantidade__c = quantidade, RecordTypeId=RECORD_TYPE_PRODUTO);
                    itemMedicao.MoedaItemMedicao__c = valor.Moeda__c;
                    itemMedicao.ValorMoedaItemMedicao__c = valor.Valor__c;
                    itemMedicao.DataConversao__c = medicao.DataConversao__c;
                    itemMedicao.Produto__c = item.Produto__c;
                    uow.registerNew(itemMedicao, ItemMedicao__c.Medicao__c, medicao);
                }
                
            }
            
            for(Voo__c voo : voosList)
            {
                if(voo.ItemContrato__c != null)
                {
                    ItemContrato__c item = itensContratoMap.get(voo.ItemContrato__c);
                    
                    if(item == null)
                    {
                        throw new MedicoesServiceException('Voo com item do contrado de id '+ voo.ItemContrato__c + ' não encontrado.');
                    }
                    if(item.Valores__r == null || item.Valores__r.size() == 0)
                    {
                        throw new MedicoesServiceException('Voo com item do contrado de id '+ voo.ItemContrato__c + ' não possui valores definidos.');
                    }
                    for(Valor__c valor : item.Valores__r)
                    {
                        Double quantidade = voo.TempoVoado__c/60;
                        ItemMedicao__c itemMedicao = new ItemMedicao__c(Quantidade__c = quantidade, RecordTypeId=RECORD_TYPE_HORA_VOADA);
                        itemMedicao.MoedaItemMedicao__c = valor.Moeda__c;
                        itemMedicao.ValorMoedaItemMedicao__c = valor.Valor__c;
                        itemMedicao.DataConversao__c = (consultarDataVoos != null && consultarDataVoos) ? voo.DataVoo__c.date() : medicao.DataConversao__c;
                        itemMedicao.Voo__c = voo.Id;
                        uow.registerNew(itemMedicao, ItemMedicao__c.Medicao__c, medicao);
                        
                        if(voo.TempoCorte__c != null && voo.TempoCorte__c > 0)
                        {
                            Double quantidadeCorte = voo.TempoCorte__c/60;
                            ItemMedicao__c itemMedicaoCorte = new ItemMedicao__c(Quantidade__c = quantidadeCorte, RecordTypeId=RECORD_TYPE_CORTE);
                            itemMedicaoCorte.MoedaItemMedicao__c = valor.Moeda__c;
                            Double horaCorte = ((item.HoraCorte__c != null) ? item.HoraCorte__c/100 : 0);
                            itemMedicaoCorte.ValorMoedaItemMedicao__c = valor.Valor__c*horaCorte;
                            itemMedicaoCorte.DataConversao__c = (consultarDataVoos != null && consultarDataVoos) ? voo.DataVoo__c.date() : medicao.DataConversao__c;
                            itemMedicaoCorte.Voo__c = voo.Id;
                            uow.registerNew(itemMedicaoCorte, ItemMedicao__c.Medicao__c, medicao);
                        }
                    }
                }
                else
                {
                    Double quantidade = voo.TempoVoado__c/60;
                    ItemMedicao__c itemMedicao = new ItemMedicao__c(Quantidade__c = quantidade, RecordTypeId=RECORD_TYPE_HORA_VOADA);
                    itemMedicao.MoedaItemMedicao__c = dolar.Id;
                    itemMedicao.ValorMoedaItemMedicao__c = voo.ValorHoraVoada__c;
                    itemMedicao.DataConversao__c = (consultarDataVoos != null && consultarDataVoos) ? voo.DataVoo__c.date() : medicao.DataConversao__c;
                    itemMedicao.Voo__c = voo.Id;
                    uow.registerNew(itemMedicao, ItemMedicao__c.Medicao__c, medicao);
                    
                    if(voo.TempoCorte__c != null && voo.TempoCorte__c > 0)
                    {
                        Double quantidadeCorte = voo.TempoCorte__c/60;
                        ItemMedicao__c itemMedicaoCorte = new ItemMedicao__c(Quantidade__c = quantidadeCorte, RecordTypeId=RECORD_TYPE_CORTE);
                        itemMedicaoCorte.MoedaItemMedicao__c = dolar.Id;
                        itemMedicaoCorte.ValorMoedaItemMedicao__c = voo.ValorHoraCorte__c;
                        itemMedicaoCorte.DataConversao__c = (consultarDataVoos != null && consultarDataVoos) ? voo.DataVoo__c.date() : medicao.DataConversao__c;
                        itemMedicaoCorte.Voo__c = voo.Id;
                        uow.registerNew(itemMedicaoCorte, ItemMedicao__c.Medicao__c, medicao);
                    }
                }
            }
            
            uow.registerNew(medicao);
            uow.commitWork();
            return medicao;
        }
        catch (DMLException e) {
           List<String> messages = e.getDmlMessage(0).split(':');
           throw new MedicoesServiceException(messages.size() > 3 ? messages[3] : e.getDmlMessage(0));
        }
        catch(Exception ex)
        {
            throw new MedicoesServiceException(ex.getMessage());
        }
    }
    
    public class MedicoesServiceException extends Exception {}
}