global with sharing class ItensMedicaoService 
{		
    @AuraEnabled(cacheable=true)
    global static List<ItemMedicao__c> getItensMedicaoByMedicaoId(List<Id> medicoesId)
    {
		return service().getItensMedicaoByMedicaoId(medicoesId);
    }
    
    @AuraEnabled(cacheable=true)
    global static List<TipoRegistroItemMedicao__mdt> selectAll()
    {
		return service().selectAll();
    }
    
    public static List<Id> getVooIdsToInteressados(List<Id> medicoesId)
    {
        return service().getVooIdsToInteressados(medicoesId);
    }
    
    private static IItensMedicaoService service()
    {
        return (IItensMedicaoService) Application.Service.newInstance(IItensMedicaoService.class);
    }
}