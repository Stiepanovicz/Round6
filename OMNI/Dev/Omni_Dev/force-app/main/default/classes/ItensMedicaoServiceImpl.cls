public class ItensMedicaoServiceImpl implements IItensMedicaoService{
	
    public static List<ItemMedicao__c> getItensMedicaoByMedicaoId(List<Id> medicoesId)
    {
        Set<Id> medicoesSet = Utils.getSetIdsByListIds(medicoesId);
        return ItensMedicaoSelector.newInstance().selectByMedicaoId(medicoesSet);
    }
    
    public static List<TipoRegistroItemMedicao__mdt> selectAll()
    {
        return TipoRegistroItemMedicaoSelector.newInstance().selectAll();
    }
    
    public static List<Id> getVooIdsToInteressados(List<Id> medicoesId)
    {
        Set<Id> medicoesSet = Utils.getSetIdsByListIds(medicoesId);
        Set<Id> voosDosItensIds = Utils.getSetIds(ItensMedicaoSelector.newInstance().selectByMedicaoIdWithVooRelated(medicoesSet), 'Voo__c');
        List<Id> voosToSend = VoosService.setInteressadosFaturamento(voosDosItensIds);
        
        return voosToSend;
    }
}