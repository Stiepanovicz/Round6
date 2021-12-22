public class ItensMedicaoSelector extends fflib_SObjectSelector 
implements IItensMedicaoSelector
{
    public static IItensMedicaoSelector newInstance()
    {
        return (IItensMedicaoSelector) Application.Selector.newInstance(ItemMedicao__c.SObjectType);
    }
    
    public ItensMedicaoSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>	
        {	SobjectType.ItemMedicao__c.FieldSets.SelectFieldList	};
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> 
        {
            ItemMedicao__c.Id,
            ItemMedicao__c.Name
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return ItemMedicao__c.sObjectType;
    }
    
    public List<ItemMedicao__c> selectById(Set<ID> idSet)
    {
        return (List<ItemMedicao__c>) selectSObjectsById(idSet);
    }
    
    public List<ItemMedicao__c> selectByMedicaoId(Set<Id> idSet)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Medicao__c IN :idSet');        
        return (List<ItemMedicao__c>) Database.query(query.toSOQL());
    }
    
    public List<ItemMedicao__c> selectByMedicaoIdWithVooRelated(Set<Id> idSet)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Medicao__c IN :idSet AND Voo__c != null');        
        return (List<ItemMedicao__c>) Database.query(query.toSOQL());
    }
        
}