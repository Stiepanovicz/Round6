public with sharing class Medicoes extends fflib_SObjectDomain implements IMedicoes
{
    private List<Medicao__c> medicoesComContaAlterada = new List<Medicao__c>();
    
    public Medicoes(List<Medicao__c> sObjectList)
    {
        super(sObjectList);
    }
    
    public static IMedicoes newInstance(List<Medicao__c> sObjectList)
	{
		return (IMedicoes) Application.Domain.newInstance(sObjectList);
	}
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Medicoes(sObjectList);
        }
    }
 
    public void handleContaAlterada(Medicao__c medicao)
    {
        Map<Id, Medicao__c> oldMap = (Map<Id, Medicao__c>)Trigger.oldMap;
        if(medicao.Conta__c != oldMap.get(medicao.Id).Conta__c)
        {
            medicoesComContaAlterada.add(medicao);
        }
    }
    
    public override void onBeforeInsert()
    {        
        List<Account> contas = AccountsSelector.newInstance().selectAll();
        Map<Id, AccountNode> mapHierarquia = AccountsService.getHierarquiaContas(contas);
        for(Medicao__c medicao : (List<Medicao__c>)records)
        {
            if(medicao.Conta__c != null)
            {
                Account contaMedicao = new Account(Id = medicao.Conta__c);
                AccountNode node = AccountsService.getContaPaiMestre(mapHierarquia, contaMedicao);
                medicao.IdContaPai__c = node != null && node.accountItem != null ? node.accountItem.Id : null;
            }
        }
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
    {        
        for (Medicao__c medicao : (List<Medicao__c>)records)
        {
            handleContaAlterada(medicao);
        }
        if(medicoesComContaAlterada.size() > 0)
        {
            List<Account> contas = AccountsSelector.newInstance().selectAll();
            Map<Id, AccountNode> mapHierarquia = AccountsService.getHierarquiaContas(contas);
            for(Medicao__c medicao : medicoesComContaAlterada)
            {
                if(medicao.Conta__c != null)
                {
                    Account contaMedicao = new Account(Id = medicao.Conta__c);
                    AccountNode node = AccountsService.getContaPaiMestre(mapHierarquia, contaMedicao);
                    medicao.IdContaPai__c = node != null && node.accountItem != null ? node.accountItem.Id : null;
                }
                else
                {
                    medicao.IdContaPai__c = null;
                }
            }
        }
    }

    public override void handleAfterDelete() 
    {
    	/*if(Configuration.EnforcingTriggerCRUDSecurity && !SObjectDescribe.isDeletable())
    	   throw new DomainException('Permission to delete an ' + SObjectDescribe.getName() + ' denied.');*/
    	   
    	onAfterDelete();
    }
    
    public class MedicoesException extends Exception {}
}