public interface IItensMedicaoService 
{
	List<ItemMedicao__c> getItensMedicaoByMedicaoId(List<Id> medicoesId);
    List<TipoRegistroItemMedicao__mdt> selectAll();
    List<Id> getVooIdsToInteressados(List<Id> medicoesId);
}