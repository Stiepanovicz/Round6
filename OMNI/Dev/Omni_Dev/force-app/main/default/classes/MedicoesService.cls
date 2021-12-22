global with sharing class MedicoesService 
{		            
    @AuraEnabled
    public static Medicao__c criarMedicao(
        Medicao__c medicao, 
        List<Id> contratosSelecionados, 
        List<Id> produtosSelecionados, 
        Map<Id, Double> mapQuantidadeProduto, 
        List<Id> voosSelecionados
    )
    {
       	return service().criarMedicao(medicao, contratosSelecionados, produtosSelecionados, mapQuantidadeProduto, voosSelecionados);
    }
    
    private static IMedicoesService service()
    {
        return (IMedicoesService) Application.Service.newInstance(IMedicoesService.class);
    }	
}