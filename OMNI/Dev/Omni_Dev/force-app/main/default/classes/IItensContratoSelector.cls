public interface IItensContratoSelector {
	List<ItemContrato__c> selectWithAeronavesAndBetweenDates(Set<Id> idSet, Date menorData, Date maiorData);
    List<ItemContrato__c> selectWithAeronavesAfterToday(Set<Id> idSet);
    List<ItemContrato__c> selectWithAeronavesAndBetweenDates(Set<Id> idSet, Date menorData, Date maiorData, Boolean ativo);
    List<ItemContrato__c> selectWithAeronavesAfterToday(Set<Id> idSet, Boolean ativo);
    List<ItemContrato__c> selectWithValores(Set<Id> idSet);
    List<ItemContrato__c> selectFromContractWithValores(Set<Id> idSet);
}