public class MedicoesSelector extends fflib_SObjectSelector 
implements IMedicoesSelector
{
    public static IMedicoesSelector newInstance()
    {
        return (IMedicoesSelector) Application.Selector.newInstance(Medicao__c.SObjectType);
    }
    
    public MedicoesSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public MedicoesSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>	
        {	SobjectType.Medicao__c.FieldSets.SelectFieldList	};
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> 
        {
            Medicao__c.Id,
            Medicao__c.Name
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return Medicao__c.sObjectType;
    }
    
    public List<Medicao__c> selectById(Set<ID> idSet)
    {
        return (List<Medicao__c>) selectSObjectsById(idSet);
    }
    
    public List<Medicao__c> selectByIdWithItens(Set<ID> idSet)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :idSet');
        
       	fflib_QueryFactory itensQuery = new ItensMedicaoSelector().addQueryFactorySubselect(query, 'ItensMedicao__r');
        
        return (List<Medicao__c>) Database.query(query.toSOQL());
    }
}