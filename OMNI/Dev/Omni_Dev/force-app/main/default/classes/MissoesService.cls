global with sharing class MissoesService 
{    
    public static Map<Id, Missao__c> criarMissoes(fflib_ISObjectUnitOfWork uow, Map<Id, CalculoMissaoResult> mapVooCMR)
    {
        return service().criarMissoes(uow, mapVooCMR);
    }
    
    public static void calculaEnvia(List<Id> leadIds)
    {
        service().calculaEnvia(leadIds);
    }
    
    private static IMissoesService service()
    {
        return (IMissoesService) Application.Service.newInstance(IMissoesService.class);
    }
}