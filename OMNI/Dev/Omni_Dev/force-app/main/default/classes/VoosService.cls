global with sharing class VoosService 
{       
	global static void criarTrechosVooDoLead(List<Id> vooIds)
	{
		service().criarTrechosVooDoLead(vooIds);
	}
	
	public static Map<Id, TempoMissaoContrato> getTempoMissaoContratoPorVoo(List<Voo__c> voos)
	{
		return service().getTempoMissaoContratoPorVoo(voos);
	}
    
    global static void countPassengers(List<Id> vooIds)
    {
        service().countPassengers(vooIds);
    }
    
    global static void undeleteVoos(Set<Id> voosId)
    {
        service().undeleteVoos(voosId);
    }

    @AuraEnabled
    global static List<Voo__c> criarVoosRetroativos(Map<Decimal, Voo__c> voosPorId, Map<Decimal, List<Trecho__c>> trechosPorVooId)
    {
        return service().criarVoosRetroativos(voosPorId, trechosPorVooId);
    }
        
    @AuraEnabled
    global static void deleteVoos(List<Voo__c> voos)
    {
        service().deleteVoos(voos);
    }
    
    @AuraEnabled
    global static List<Voo__c> cancelarRastreioVoos(List<Id> voosId)
    {
        return service().cancelarRastreioVoos(voosId);
    }
    
    @AuraEnabled
    global static List<Voo__c> rastrearVoos(List<Id> voosId)
    {
        return service().rastrearVoos(voosId);
    }
    
    @AuraEnabled
    global static List<Voo__c> getVoosRastreaveisHoje()
    {
        return service().getVoosRastreaveisHoje();
    }
    
    @AuraEnabled(cacheable=true)
    global static List<Voo__c> getVoosRotasRecentes()
    {        
    	return service().getVoosRotasRecentes();
    }
    
    @AuraEnabled(cacheable=false)
    global static List<Voo__c> getVoos(List<Id> voosId)
    {        
    	return service().getVoos(Utils.getSetIdsByListIds(voosId));
    }
    
    global static void recalculaMissao(List<Id> vooIds)
    {
        service().recalculaMissao(vooIds);
    }
    
    global static void adicionaVoosRevalidacao()
    {
        service().adicionaVoosRevalidacao();
    }

    @future
    global static void updateLogPendenteBySkytrac(Id vooId)
    {
        service().updateLogPendenteBySkytrac(vooId);
    }
    
    public static List<Id> setInteressadosFaturamento(Set<Id> voosIds)
    {
        return service().setInteressadosFaturamento(voosIds);
    }
    
    public static Map<Id, Set<Datetime>> getHorariosPorConta(List<Voo__c> voosList)
    {
        return service().getHorariosPorConta(voosList);
    }

    @AuraEnabled
    public static List<Voo__c> selectExecutadosWithOrWithoutContracts(List<Id> contractsId, List<Id> accountsId)
    {
        return service().selectExecutadosWithOrWithoutContracts(contractsId, accountsId);
    }
    
    public static List<String> enviarCartaoEmbarque(List<Id> voosIds) 
    {
        return service().enviarCartaoEmbarque(voosIds);
    }
    
	private static IVoosService service()
	{
		return (IVoosService) Application.Service.newInstance(IVoosService.class);
	}	
}