public with sharing class Accounts extends fflib_SObjectDomain implements IAccounts
{
    public static FINAL String COMPLETADA = 'Completada';
    private List<Account> contasComContaPai = new List<Account>();
    
    public Accounts(List<Account> sObjectList)
    {
        super(sObjectList);
    }
    
    /*public static IAccounts newInstance(List<Account> sObjectList)
	{
		return (IAccounts) Application.Domain.newInstance(sObjectList);
	}*/
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Accounts(sObjectList);
        }
    }
    
    private void handleTask(Account acc, List<Task> tasks)
    {
        for (Task taskToHandle : tasks)
        {
            if (taskToHandle.WhoId.equals(acc.LeadId__c))
            {
                taskToHandle.Status = COMPLETADA;                
            }
        }
    }
    
    /*
    public void updateContasSchedulable(List<Account> contas)
    {
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addSeconds(5);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        
		String jsonContas = JSON.serialize(contas);
        System.schedule(AtualizaAccountsSchedulable.class.getName() + '-' + now.format(), cronString, new AtualizaAccountsSchedulable(jsonContas));
    }
    
    @future
    public static void updateContasFuture(String contasJSON)
    {
        List<Account> contas = (List<Account>)JSON.deserialize(contasJSON, List<Account>.class);
        update contas;
    }*/
        
    public override void onAfterInsert()
    {
        Set<Id> leadsIds = Utils.getSetIds(records, 'LeadId__c');
        List<Task> tasksToClose = [SELECT Id, WhoId FROM Task WHERE WhoId IN :leadsIds];
        
        for (Account acc : (List<Account>)records)
        {
            handleTask(acc, tasksToClose);
            handleContaPai(acc);
        }
        if(contasComContaPai.size() > 0)
        {
            List<Account> contas = AccountsSelector.newInstance().selectAll();
            List<Account> contasUpdate = new List<Account>();
            Map<Id, AccountNode> mapHierarquia = AccountsService.getHierarquiaContas(contas);
            for(Account conta : contasComContaPai)
            {
                AccountNode node = AccountsService.getContaPaiMestre(mapHierarquia, conta);
                Account novaConta = conta.clone();
                novaConta.Id = conta.Id;
                novaConta.IdContaPai__c = node.accountItem.Id;
                contasUpdate.add(novaConta);
            }
            update contasUpdate;
        }
        update tasksToClose;
    }
 
    public void handleContaPai(Account conta)
    {
        if(conta.ParentId != null)
        {
            contasComContaPai.add(conta);
        }
    }
    
    public override void onValidate(Map<Id,SObject> existingRecords)
    {
        for (Account acc : (List<Account>)records)
        {
            validaInscricaoEstadual(acc);
        }        
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
        Map<Id, Account> oldAccounts = (Map<Id, Account>)Trigger.oldMap;
        Map<Id, Account> newAccounts = (Map<Id, Account>)Trigger.newMap;
        
        for(Account conta : (List<Account>)Records)
        {          	
            if(oldAccounts.get(conta.Id).ParentId != newAccounts.get(conta.Id).ParentId)
            {
                contasComContaPai.add(conta);
            }
        }
        
        if(contasComContaPai.size() > 0)
        {
            List<Account> contas = AccountsSelector.newInstance().selectAll();
            List<Account> contasUpdate = new List<Account>();
            Map<Id, AccountNode> mapHierarquia = AccountsService.getHierarquiaContas(contas);
            for(Account conta : contasComContaPai)
            {
                AccountNode node = AccountsService.getContaPaiMestre(mapHierarquia, conta);
                Account novaConta = conta.clone();
                novaConta.Id = conta.Id;
                novaConta.IdContaPai__c = node.accountItem.Id;
                contasUpdate.add(novaConta);
            }
            update contasUpdate;
        }
    }
    
        
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
    {        
        for(Account conta : (List<Account>)Records)
        { 
            if(conta.PrimeiroUpdate__c)
            {
                conta.PrimeiroUpdate__c = false;
                conta.SegundoUpdate__c = true;
            }else if(conta.SegundoUpdate__c)
            {
                conta.SegundoUpdate__c = false;
            }else
            {
                conta.BypassValidationRules__c = false;
            }
        }
    }
    
    private void validaInscricaoEstadual(Account acc)
    {
        if (String.isNotBlank(acc.ShippingState))
        {
            try
            {
                Estado e = Utils.getEstado(acc.ShippingState);
                if ( !((ValidadorIEFactory.newInstance(e)).execute(acc.InscricaoEstadual__c)) )
                {
                    acc.InscricaoEstadual__c.addError(Label.InscricaoEstadualInvalida);
                }  
            }
            catch (ValidadorIE.ValidadorException ve)
            {
                acc.InscricaoEstadual__c.addError(ve.getMessage());
            }
            catch (Exception e)
            {
                acc.ShippingState.addError(Label.PreenchaValorValido);
            }
        }
    }    
    
    public class EstadoInexistenteException extends Exception {}
}