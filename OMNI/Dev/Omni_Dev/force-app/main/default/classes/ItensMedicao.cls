public class ItensMedicao extends fflib_SObjectDomain implements IItensMedicao {
    
    private Id RECORD_TYPE_HORA_VOADA = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get(Label.DeveloperNameItemMedicaoHoraVoada).getRecordTypeId();
    private Id RECORD_TYPE_CORTE = Schema.SObjectType.ItemMedicao__c.getRecordTypeInfosByDeveloperName().get(Label.DeveloperNameItemMedicaoCorte).getRecordTypeId();
	
	private Boolean triggerValida = true;    
    
    public static IItensMedicao newInstance(List<ItemMedicao__c> sObjectList)
	{
		return (IItensMedicao) Application.Domain.newInstance(sObjectList);
	}
    
    /*todo domain possui o contrutor padrão com a lista de objetos*/
    public ItensMedicao(List<ItemMedicao__c> sObjectList)
	{
		// Domain classes are initialised with lists to enforce bulkification throughout
		super(sObjectList);
	}
    
    /*todo domain deve ter sua classe constructor*/
    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new ItensMedicao(sObjectList);
		}
	}
    
    public Map<Id, Map<Schema.SObjectField, Boolean>> getIschanged(Map<Id, ItemMedicao__c> oldMap, Map<Id, ItemMedicao__c> newMap)
    {
        Map<Id, Map<Schema.SObjectField, Boolean>> isChangedMap = new Map<Id, Map<Schema.SObjectField, Boolean>>();
        SObjectType vooType = Schema.getGlobalDescribe().get('ItemMedicao__c');
        Map<String,Schema.SObjectField> mfields = vooType.getDescribe().fields.getMap();
        
        for(Id itemId : newMap.keySet())
        {
            ItemMedicao__c newItem = newMap.get(itemId);
            ItemMedicao__c oldItem = oldMap.get(itemId);
            Map<Schema.SObjectField, Boolean> fieldChanges = new Map<Schema.SObjectField, Boolean>();
            for(String key : mfields.keyset())
            {
                Schema.SObjectField field = mfields.get(key);
                if(newItem.get(field) != oldItem.get(Field))
                {
                    fieldChanges.put(field, true);
                }
            }
            isChangedMap.put(itemId, fieldChanges);
        }
        return isChangedMap;
    }
    
    public override void onValidate()	
    {
       validaItensMedicao((List<ItemMedicao__c>)Trigger.new);
    }
    
    public override void onValidate(Map<Id,SObject> existingRecords)
    {
       validaItensMedicao((List<ItemMedicao__c>)Trigger.new);
    }
    
    public void validaItensMedicao(List<ItemMedicao__c> itensMedicaoList)
    {
        for(ItemMedicao__c item : itensMedicaoList)
        {
            if(item.DataConversao__c == null)
            {
                item.DataConversao__c.addError(Label.DataConversaoNulaItemMedicao);
                triggerValida = false;
            }
            if(item.ValorMoedaItemMedicao__c == null)
            {
                item.ValorMoedaItemMedicao__c.addError(Label.ValorMoedaItemMedicaoNulo);
                triggerValida = false;
            }
            if(item.MoedaItemMedicao__c == null)
            {
                item.MoedaItemMedicao__c.addError(Label.MoedaItemMedicaoNula);
                triggerValida = false;
            }
        }
    }

    public void substituiTempoVoosContratos(List<Voo__c> voosContratoDosItens, Map<Id, List<ItemMedicao__c>> itensPorIdVoo){
        Map<Id, TempoMissaoContrato> tempoMissaoContratoPorVoo = VoosService.getTempoMissaoContratoPorVoo(voosContratoDosItens);
        System.debug('tempoMissaoContratoPorVoo2: ' + tempoMissaoContratoPorVoo);
        for(Voo__c voo : voosContratoDosItens){
            List<ItemMedicao__c> itensVoo = itensPorIdVoo.get(voo.id);
            TempoMissaoContrato tempoMissao = tempoMissaoContratoPorVoo.get(voo.id);
            for(ItemMedicao__c item : itensVoo){
                if(item.recordtypeid == RECORD_TYPE_HORA_VOADA){
                    item.quantidade__c = tempoMissao.tempoVoado / 60;
                    System.debug('tempomissao ' + tempoMissao);
                    System.debug('tempomissao ' + item.quantidade__c);
                }else if(item.recordtypeid == RECORD_TYPE_CORTE){
                    item.quantidade__c = tempoMissao.tempoCortado / 60;
                }
            }
        }
    }
    
    public override void onBeforeInsert()
    {
        onValidate();
        if(triggerValida)
        {
            List<ItemMedicao__c> itensMedicaoList = (List<ItemMedicao__c>)Trigger.new;
            Set<Id> medicoesId = Utils.getSetIds(itensMedicaoList, 'Medicao__c');
            Map<Id, List<ItemMedicao__c>> itensPorIdVoo = getItensPorIdVoo(itensMedicaoList);
            if(itensPorIdVoo.keySet().size() > 0){
                List<Voo__c> voosContratoDosItens = new VoosSelector().selectByIdWithTrechosAndItensContrato(itensPorIdVoo.keySet());
                substituiTempoVoosContratos(voosContratoDosItens, itensPorIdVoo);

            }
            Map<Id, Medicao__c> medicoesRecalcular = new Map<Id, Medicao__c>(MedicoesSelector.newInstance().selectById(medicoesId));
            
            Set<String> identificadoresTaxa = getSetIdentificadorTaxa(itensMedicaoList, medicoesRecalcular);
            List<TaxaMoeda__c> taxas = TaxasMoedasSelector.newInstance().selectWithIdentificadorTaxa(identificadoresTaxa);
            Map<String, TaxaMoeda__c> moedaPorIdentificador = getMapMoedaPorIdentificador(taxas);
            
            for(ItemMedicao__c item : itensMedicaoList)
            {
                Medicao__c medicao = medicoesRecalcular.get(item.Medicao__c);
                
                if(medicao.MoedaMedicao__c != item.MoedaItemMedicao__c)
                {
                    String identificador = getIdentificadorTaxa(item, medicao);
                    TaxaMoeda__c taxa = moedaPorIdentificador.get(identificador);
                    if(taxa == null)
                    {
                        item.TaxaConversao__c.addError(Label.TaxaConversaoNaoEncontrada.replace('{data}', item.DataConversao__c.format()));
                        item.TaxaConversao__c = 0;
                        //throw new ItensMedicaoException(Label.TaxaConversaoNaoEncontrada.replace('{data}', item.DataConversao__c.format()));
                    }
                    else{
                        item.TaxaConversao__c = item.MoedaItemMedicao__c == taxa.MoedaOrigem__c ? taxa.TaxaConversao__c : 1/taxa.TaxaConversao__c;
                    }
                }
                else
                {
                    item.TaxaConversao__c = 1;
                }
                
                item.MoedaMedicao__c = medicao.MoedaMedicao__c;
                system.debug('item.ValorMoedaItemMedicao__c'+item.ValorMoedaItemMedicao__c);
                system.debug('item.TaxaConversao__c'+item.TaxaConversao__c);
                item.ValorMoedaMedicao__c = item.ValorMoedaItemMedicao__c*item.TaxaConversao__c;
                
                item.TotalMoedaItemMedicao__c = item.Quantidade__c*item.ValorMoedaItemMedicao__c;
                item.TotalMoedaMedicao__c = item.Quantidade__c*item.ValorMoedaMedicao__c;
            }
        }
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
    {
        onValidate();
        if(triggerValida)
        {
            Map<Id, ItemMedicao__c> oldItens = (Map<Id, ItemMedicao__c>)Trigger.oldMap;
            Map<Id, ItemMedicao__c> newItens = (Map<Id, ItemMedicao__c>)Trigger.newMap;
            Map<Id, Map<Schema.SObjectField, Boolean>> isChangedMap = getIschanged(oldItens, newItens);

            // Map<Id, List<ItemMedicao__c>> itensPorIdVoo = getItensPorIdVoo(itensMedicaoList);
            // if(itensPorIdVoo.keySet().size() > 0){
            //     List<Voo__c> voosContratoDosItens = new VoosSelector().selectByIdWithTrechosAndItensContrato(itensPorIdVoo.keySet());
            // }
            
            List<ItemMedicao__c> itensRecalcularTaxa = defineItensRecalcularTaxa(newItens.values(), isChangedMap);
            if(itensRecalcularTaxa.size() > 0)
            {
                Set<Id> medicoesId = Utils.getSetIds(itensRecalcularTaxa, 'Medicao__c');
                Map<Id, Medicao__c> medicoesRecalcular = new Map<Id, Medicao__c>(MedicoesSelector.newInstance().selectById(medicoesId));
                
                Set<String> identificadoresTaxa = getSetIdentificadorTaxa(itensRecalcularTaxa, medicoesRecalcular);
                List<TaxaMoeda__c> taxas = TaxasMoedasSelector.newInstance().selectWithIdentificadorTaxa(identificadoresTaxa);
                Map<String, TaxaMoeda__c> moedaPorIdentificador = getMapMoedaPorIdentificador(taxas);
                
                for(ItemMedicao__c item : itensRecalcularTaxa)
                {
                    Medicao__c medicao = medicoesRecalcular.get(item.Medicao__c);
                    
                    if(medicao.MoedaMedicao__c != item.MoedaItemMedicao__c)
                    {
                        String identificador = getIdentificadorTaxa(item, medicao);
                        TaxaMoeda__c taxa = moedaPorIdentificador.get(identificador);
                        if(taxa == null)
                        {
                            item.TaxaConversao__c.addError(Label.TaxaConversaoNaoEncontrada.replace('{data}', item.DataConversao__c.format()));
                            item.TaxaConversao__c = 0;
                            //throw new ItensMedicaoException(Label.TaxaConversaoNaoEncontrada.replace('{data}', item.DataConversao__c.format()));
                        }
                        else{
                            item.TaxaConversao__c = item.MoedaItemMedicao__c == taxa.MoedaOrigem__c ? taxa.TaxaConversao__c : 1/taxa.TaxaConversao__c;
                        }
                    }
                    else
                    {
                        item.TaxaConversao__c = 1;
                    }
                    
                    item.MoedaMedicao__c = medicao.MoedaMedicao__c;
                    item.ValorMoedaMedicao__c = item.ValorMoedaItemMedicao__c*item.TaxaConversao__c;
                    
                    Double descontoMoedaItem = item.ValorDesconto__c != null ? item.ValorDesconto__c : 0;
                    Double descontoMoedaMedicao = item.ValorDesconto__c != null ? item.ValorDesconto__c*item.TaxaConversao__c : 0;
                    
                    item.TotalMoedaItemMedicao__c = (item.Quantidade__c*item.ValorMoedaItemMedicao__c) - descontoMoedaItem;
                    item.TotalMoedaMedicao__c = (item.Quantidade__c*item.ValorMoedaMedicao__c) - descontoMoedaMedicao;
                }
            }
        }
    }
    
    public override void onAfterInsert()
    {
        List<ItemMedicao__c> itensMedicaoList = (List<ItemMedicao__c>)Trigger.new;
        Set<Id> medicoesId = Utils.getSetIds(itensMedicaoList, 'Medicao__c');
        
        List<Medicao__c> medicoesList = MedicoesSelector.newInstance().selectByIdWithItens(medicoesId);
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		medicoesList = setTotalMedicoes(medicoesList);
        uow.registerDirty(medicoesList);
        uow.commitWork();
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
        List<ItemMedicao__c> itensMedicaoList = (List<ItemMedicao__c>)Trigger.new;
        Set<Id> medicoesId = Utils.getSetIds(itensMedicaoList, 'Medicao__c');
        
        List<Medicao__c> medicoesList = MedicoesSelector.newInstance().selectByIdWithItens(medicoesId);
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		medicoesList = setTotalMedicoes(medicoesList);
        uow.registerDirty(medicoesList);
        uow.commitWork();
    }
        
    public override void onAfterDelete()
    {
        List<ItemMedicao__c> itensMedicaoList = (List<ItemMedicao__c>)Trigger.old;
        Set<Id> medicoesId = Utils.getSetIds(itensMedicaoList, 'Medicao__c');
        
        List<Medicao__c> medicoesList = MedicoesSelector.newInstance().selectByIdWithItens(medicoesId);
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		medicoesList = setTotalMedicoes(medicoesList);
        uow.registerDirty(medicoesList);
        uow.commitWork();
    }
    
    public List<Medicao__c> setTotalMedicoes(List<Medicao__c> medicoesList)
    {
        for(Medicao__c medicao : medicoesList)
        {
            Map<Id, Double> horaVoadaVoo = new Map<Id, Double>();
            Map<Id, Double> horaCorteVoo = new Map<Id, Double>();
            if(medicao.ItensMedicao__r == null)
            {
                medicao.TotalMoedaMedicao__c = 0;
                medicao.SomaHorasVoadas__c = 0;
                medicao.SomaHorasCorte__c = 0;
            }
            else
            {
                Double totalMoedaMedicao = 0;
                Double totalHorasVoadas = 0;
                Double totalHorasCorte = 0;
                for(ItemMedicao__c item : medicao.ItensMedicao__r)
                {
                    totalMoedaMedicao += item.TotalMoedaMedicao__c != null ? item.TotalMoedaMedicao__c : 0;
                    
                    if(item.RecordTypeId == RECORD_TYPE_HORA_VOADA)
                    {
                        if(!horaVoadaVoo.containsKey(item.Voo__c))
                        {
                            horaVoadaVoo.put(item.Voo__c, item.Quantidade__c);
                            totalHorasVoadas += item.Quantidade__c;
                        }
                    }
                    if(item.RecordTypeId == RECORD_TYPE_CORTE)
                    {
                        if(!horaCorteVoo.containsKey(item.Voo__c))
                        {
                            horaCorteVoo.put(item.Voo__c, item.Quantidade__c);
                            totalHorasCorte += item.Quantidade__c;
                        }
                    }
                }
                medicao.TotalMoedaMedicao__c = totalMoedaMedicao;
                medicao.SomaHorasVoadas__c = totalHorasVoadas;
                medicao.SomaHorasCorte__c = totalHorasCorte;
            }
        }
        return medicoesList;
    }
    
    public Map<String, TaxaMoeda__c> getMapMoedaPorIdentificador(List<TaxaMoeda__c> taxas)
    {
        Map<String, TaxaMoeda__c> moedaPorIdentificador = new Map<String,TaxaMoeda__c>();
        for(TaxaMoeda__c t : taxas)
        {
            moedaPorIdentificador.put(t.IdentificadorTaxa__c, t);
            moedaPorIdentificador.put(t.IdentificadorTaxaInvertido__c, t);
        }
        return moedaPorIdentificador;
    }
    
    public Set<String> getSetIdentificadorTaxa(List<ItemMedicao__c> itensMedicaoList, Map<Id, Medicao__c> mapMedicoes)
    {
        Set<String> setIdentificadoresTaxa = new Set<String>();
        for(ItemMedicao__c item : itensMedicaoList)
        {
            setIdentificadoresTaxa.add(getIdentificadorTaxa(item, mapMedicoes.get(item.Medicao__c)));
        }
        return setIdentificadoresTaxa;
    }
    
    public String getIdentificadorTaxa(ItemMedicao__c item, Medicao__c medicao)
    {
        Integer year = item.DataConversao__c.year();
        Integer month = item.DataConversao__c.month();
        Integer day = item.DataConversao__c.day();
        String dataConversao = year + '-' + (month > 9 ? ''+month : '0'+month) + '-' + (day > 9 ? ''+day : '0'+day);
        String moedaMedicao = (String)medicao.MoedaMedicao__c;
        String moedaItemMedicao = (String)item.MoedaItemMedicao__c;
        if(moedaMedicao == null)
        {
            throw new ItensMedicaoException('A moeda da medição não foi definida.');
        }
        if(moedaItemMedicao == null)
        {
            throw new ItensMedicaoException('A moeda do item da medição não foi definida.');
        }
        String identificadorTaxa = '' + moedaItemMedicao.substring(0,15) + moedaMedicao.substring(0,15) + dataConversao;
        return identificadorTaxa;
    }
    
    public String getIdentificadorTaxaInvertido(ItemMedicao__c item, Medicao__c medicao)
    {
        Integer year = item.DataConversao__c.year();
        Integer month = item.DataConversao__c.month();
        Integer day = item.DataConversao__c.day();
        String dataConversao = year + '-' + (month > 9 ? ''+month : '0'+month) + '-' + (day > 9 ? ''+day : '0'+day);
        String moedaMedicao = (String)medicao.MoedaMedicao__c;
        String moedaItemMedicao = (String)item.MoedaItemMedicao__c;
        if(moedaMedicao == null)
        {
            throw new ItensMedicaoException('A moeda da medição não foi definida.');
        }
        if(moedaItemMedicao == null)
        {
            throw new ItensMedicaoException('A moeda do item da medição não foi definida.');
        }
        String identificadorTaxa = '' + moedaMedicao.substring(0,15) + moedaItemMedicao.substring(0,15) + dataConversao;
        return identificadorTaxa;
    }

    public Map<Id, List<ItemMedicao__c>> getItensPorIdVoo(List<ItemMedicao__c> itensMedicao){
        Map<Id, List<ItemMedicao__c>> itensPorIdVoo = new Map<Id, List<ItemMedicao__c>>();
        for(ItemMedicao__c item : itensMedicao){
            if(item.voo__c != null){
                Boolean vooEstaNosItens = itensPorIdVoo.containsKey(item.voo__c);
                if(vooEstaNosItens){
                    List<ItemMedicao__c> itensComVoo = itensPorIdVoo.get(item.voo__c);
                    itensComVoo.add(item);
                    itensPorIdVoo.put(item.voo__c, itensComVoo);
                }else{
                    itensPorIdVoo.put(item.voo__c, new List<ItemMedicao__c>{item});
                }
            }
        }
        return itensPorIdVoo;
    }
    
    public List<ItemMedicao__c> defineItensRecalcularTaxa(List<ItemMedicao__c> itensMedicaoList, Map<Id, Map<Schema.SObjectField, Boolean>> isChangedMap)
    {
        List<ItemMedicao__c> itensRecalcularTaxa = new List<ItemMedicao__c>();
        for(ItemMedicao__c item : itensMedicaoList)
        {
            Map<Schema.SObjectField, Boolean> mapCamposAlterados = isChangedMap.get(item.Id);
            if(
                possuiCampoAlterado(CAMPOS_RECALCULAR_TAXA, mapCamposAlterados)
            )
            {
                itensRecalcularTaxa.add(item);
            }
        }
        return itensRecalcularTaxa;
    }
    
    public boolean possuiCampoAlterado(Set<Schema.SObjectField> setCampos, Map<Schema.SObjectField, Boolean> mapCamposAlterados)
    {
        for(Schema.SObjectField campo : setCampos)
        {
            if(mapCamposAlterados.containsKey(campo) && mapCamposAlterados.get(campo))
            {
                return true;
            }
        }
        return false;
    }
    
    public static FINAL Set<Schema.SObjectField> CAMPOS_RECALCULAR_TAXA = new Set<Schema.SObjectField>{
		ItemMedicao__c.MoedaMedicao__c,
        ItemMedicao__c.MoedaItemMedicao__c,
        ItemMedicao__c.DataConversao__c,
        ItemMedicao__c.TaxaConversao__c,
        ItemMedicao__c.Quantidade__c,
        ItemMedicao__c.ValorDesconto__c
    };
    
    public class ItensMedicaoException extends Exception {}
}