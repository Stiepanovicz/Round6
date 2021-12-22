public interface IItensContrato {
    void validaColisaoVoosContratos(Map<Id,Contract> contratosMap, Map<Id, List<Voo__c>> voosPorPrefixo, Map<Id, List<ItemContrato__c>> itensPorPrefixo);
	Map<Id, List<ItemContrato__c>> getItensPorPrefixo(List<ItemContrato__c> itensList);
    Boolean existeVooConflitante(Contract contrato, List<Voo__c> voosList);
    void onValidate();
    void onValidate(Map<Id,SObject> existingRecords);
    boolean colideDataContrato(Date itemUmDataInicio, Date itemUmDataTermino, Date itemDoisDataInicio, Date itemDoisDataTermino);
    boolean colideDesativacao(Aeronave__c aeronave, List<Event> eventosDesativacao, List<ItemContrato__c> itensList);
}