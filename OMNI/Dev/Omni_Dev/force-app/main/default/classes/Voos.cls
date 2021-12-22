public without sharing class Voos extends fflib_SObjectDomain implements IVoos
{
    public Map<Voo__c, List<Trecho__c>> mapVoos;
    //DeveloperName de Metadados para Integração
    public static FINAL String POST_VOO_STAR = 'PostVooStar';
    public static FINAL String RASCUNHO = 'Rascunho';
    public static FINAL String RESERVADO = 'Reservado';
    public static FINAL String CONFIRMADO = 'Confirmado';
    public static FINAL String ROTA = 'Rota';
    public static FINAL String CANCELADO = 'Cancelado';
    public static FINAL String EXECUTADO = 'Executado';
    public static FINAL String FATURAMENTO = 'Em Faturamento';
    public static FINAL String PRERESERVADO = 'Pré-reservado';
    public static FINAL String LOGPENDENTE = 'LogPendente';
    public static FINAL String FATURADO = 'Faturado';
    
    public static FINAL Set<Schema.SObjectField> FIELDS_IGNORE = new Set<Schema.SObjectField>{
		Voo__c.StatusRascunho__c,
        Voo__c.ChaveRota__c,
        Voo__c.Resumo__c,
        Voo__c.TempoCorte__c,
        Voo__c.TempoCortadoTexto__c,
        Voo__c.OrdemExecucaoUltimoTrecho__c,
        Voo__c.PrimeiroTrecho__c,
        Voo__c.QtdTrechosOrigemOffshore__c,
        Voo__c.QtdTrechos__c,
        Voo__c.TrechosNaoIniciados__c,
       	Voo__c.UltimoTrecho__c,
        Voo__c.Aprovadores__c,
        Voo__c.LastModifiedDate,
        Voo__c.SystemModstamp,
        Voo__c.HorarioVooReservado__c,
        Voo__c.HorarioVooReservado2__c,
        Voo__c.HorarioVooReservado3__c,
        Voo__c.IdContaPai__c
    };
        
    public Map<Id, Map<Schema.SObjectField, Boolean>> getIschanged(Map<Id, Voo__c> oldMap, Map<Id, Voo__c> newMap)
    {
        Map<Id, Map<Schema.SObjectField, Boolean>> isChangedMap = new Map<Id, Map<Schema.SObjectField, Boolean>>();
        SObjectType vooType = Schema.getGlobalDescribe().get('Voo__c');
        Map<String,Schema.SObjectField> mfields = vooType.getDescribe().fields.getMap();
        
        for(Id vooId : newMap.keySet())
        {
            Voo__c newVoo = newMap.get(vooId);
            Voo__c oldVoo = oldMap.get(vooId);
            Map<Schema.SObjectField, Boolean> fieldChanges = new Map<Schema.SObjectField, Boolean>();
            for(String key : mfields.keyset())
            {
                Schema.SObjectField field = mfields.get(key);
                if(newVoo.get(field) != oldVoo.get(Field))
                {
                    fieldChanges.put(field, true);
                }
            }
            isChangedMap.put(vooId, fieldChanges);
        }
        return isChangedMap;
    }
    
    public Boolean ignorarTriggerUpdate()
    {
        SObjectType vooType = Schema.getGlobalDescribe().get('Voo__c');
        Map<String,Schema.SObjectField> mfields = vooType.getDescribe().fields.getMap();
        for(Integer i = 0; i < Trigger.new.size(); i++)
        {
            Voo__c novoVoo = (Voo__c)Trigger.new[i];
            Voo__c oldVoo = (Voo__c)Trigger.old[i];
            for(String key : mfields.keyset())
            {
                Schema.SObjectField field = mfields.get(key);
                if(novoVoo.get(field) != oldVoo.get(Field) && !FIELDS_IGNORE.contains(field))
                {
                    return false;
                }
            }
        }
        return true;
    }
    
    public Voos(List<Voo__c> sObjectList)
    {
        super(sObjectList);
    }
    
    public static IVoos newInstance(List<Voo__c> sObjectList)
    {
        return (IVoos) Application.Domain.newInstance(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Voos(sObjectList);
        }
    }

    public void sendAndLog(String strJson)
    {
        if(!System.Test.isRunningTest())
        {
        	IntegracaoFuture.send(POST_VOO_STAR, strJson);
        }
    }
    
    public List<Voo__c> getVoosOrdenadosPorData()
    {
        List<Voo__c> voos = (List<Voo__c>)Records;
        Integer iterationSize = voos.size();
        Voo__c vooTemp = new Voo__c();
        
        for(integer i=0; i < iterationSize; i++){
            for(integer j=1; j < (iterationSize-i); j++){
                Datetime dataPrimeiroVoo = voos.get(j-1).DataVoo__c;
                Datetime dataSegundoVoo = voos.get(j).DataVoo__c;
                if(dataPrimeiroVoo > dataSegundoVoo){
                    vooTemp = voos[j-1];
                    voos[j-1] = voos[j];
                    voos[j] = vooTemp;
                }
            }
        }
        return voos;
    }

    
    public Map<Voo__c, List<Trecho__c>> loadMapTrechosPassageirosCargas(List<Voo__c> listVoos)
    {
        mapVoos = new Map<Voo__c, List<Trecho__c>>();
        
        List<Trecho__c> trechos = new TrechosSelector().selectByVooId(Utils.getSetIds(listVoos, 'Id'));
        
        for (Voo__c voo : listVoos) 
        {
            List<Trecho__c> trechosVoo = new List<Trecho__c>();
            for (Trecho__c trecho : trechos)
            {
                if (voo.Id.equals(trecho.Voo__c))
                {
                    trechosVoo.add(trecho);
                }
            }
            mapVoos.put(voo, trechosVoo);
        }
        return mapVoos;
    }
    
    public Map<Voo__c, List<Trecho__c>> loadMapTrechosPassageirosCargas()
    {
        mapVoos = new Map<Voo__c, List<Trecho__c>>();
        
        List<Trecho__c> trechos = new TrechosSelector().selectByVooId(Utils.getSetIds(Records, 'Id'));
        for (Voo__c voo : (List<Voo__c>)Records)
        {
            List<Trecho__c> trechosVoo = new List<Trecho__c>();
            for (Trecho__c trecho : trechos)
            {
                if (voo.Id.equals(trecho.Voo__c))
                {
                    trechosVoo.add(trecho);
                }
            }
            mapVoos.put(voo, trechosVoo);
        }
        return mapVoos;
    }
    
    public void criarTrechosParaVoosDoLead(fflib_ISObjectUnitOfWork uow)
    {
        for(Voo__c voo : (List<Voo__c>)Records)
        {
            criarTrechosVooLead(uow, voo);      
        }
    }
    
    public static void criarTrechosVooLead(fflib_ISObjectUnitOfWork uow, Voo__c voo)
    {
        Integer ordemExecucao = 10;
        criarTrecho(uow, voo.LeadGerouVoo__r.Origem__c, voo.LeadGerouVoo__r.Destino__c, voo, ordemExecucao, '');
        ordemExecucao += 10;
        for(Integer i = 2; i < 11; i++)
        {
            String campoOrigem = 'Destino' + (i-1) + '__c';
            String campoDestino = 'Destino' + i + '__c';
            Id destino = (Id) voo.LeadGerouVoo__r.get(campoDestino);
            
            if(destino != null)
            {
                if(i == 2)
                {
                    criarTrecho(uow, voo.LeadGerouVoo__r.Destino__c, (Id) destino, voo, ordemExecucao, '');
                }else
                {
                    criarTrecho(uow, (Id) voo.LeadGerouVoo__r.get(campoOrigem), (Id) destino, voo, ordemExecucao, '');
                }
                ordemExecucao += 10;
            }else{
                if(i == 2)
                {
                    criarTrecho(uow, voo.LeadGerouVoo__r.Destino__c, voo.LeadGerouVoo__r.Retorno__c, voo, ordemExecucao, '');
                }else
                {
                    criarTrecho(uow, (Id) voo.LeadGerouVoo__r.get(campoOrigem), voo.LeadGerouVoo__r.Retorno__c, voo, ordemExecucao, '');
                } 
                ordemExecucao += 10;
                break;
            }
        }
        if(voo.LeadGerouVoo__r.Origem__c != voo.LeadGerouVoo__r.Retorno__c)
        {
            criarTrecho(uow, (Id) voo.LeadGerouVoo__r.Retorno__c, (Id) voo.LeadGerouVoo__r.Origem__c, voo, ordemExecucao, 'Translado');
        }
    }
    
    @TestVisible
    static private  void criarTrecho(fflib_ISObjectUnitOfWork uow, Id origem, Id destino, Voo__c voo, Integer ordemExecucao, String tipo)
    {
        Trecho__c trecho = new Trecho__c(
            Origem__c = origem,
            Destino__c = destino,
            OrdemExecucao__c = ordemExecucao
        );
        if(!String.isBlank(tipo))
        {
            trecho.Tipo__c = tipo;
        }
        uow.registerNew(trecho, Trecho__c.Voo__c, voo);
    }
    
    private void integraStar()
    {
        if(!System.Test.isRunningTest())
        {
            List<Voo__c> voosToIntegrate = (List<Voo__c>)Utils.getRecordsToIntegrate(Records, 'Status__c');
            List<Voo__c> voosSemIgnorar = new List<Voo__c>();
            for(Voo__c voo : voosToIntegrate)
            {
                if(!voo.IgnorarTrigger__c)
                {
                    voosSemIgnorar.add(voo);
                }
            }
            if (voosToIntegrate.size() > 0)
            {
                sendAndLog(getJSON(loadMapTrechosPassageirosCargas(voosSemIgnorar)));            
            }
        }
    }
    
    private void writeVooJSON(JSONGenerator gen, Voo__c voo, List<Trecho__c> trechos, Aeronave__c aeronave)
    {
        gen.writeStartObject(); //Inicia dados do voo        
        gen.writeIdField('id', voo.Id);
        gen.writeStringField('flightType', 'Spot'); //Reavaliar
        gen.writeStringField('flightCode', voo.Name);
        gen.writeStringField('cliente', voo.Cliente__c);
        if (voo.DataVoo__c != null)
        {
            gen.writeDateTimeField('flightDate', Utils.getUTCDatetime(voo.DataVoo__c));
            gen.writeDateTimeField('etd', Utils.getUTCDatetime(voo.DataVoo__c));
            gen.writeDateTimeField('eta', Utils.getUTCDatetime(voo.DataVoo__c.addMinutes((Integer)voo.TempoMissao__c)));
        }
        //============================ aircraft ================================//
        AeronavesService.writeJson(gen, new List<Aeronave__c>{aeronave});
        //======================================================================//
        gen.writeStringField('status', voo.Status__c);
        gen.writeStringField('pilot', voo.Comandante__c != null ? voo.Comandante__c : '');   
        gen.writeStringField('coPilot', voo.Copiloto__c != null ? voo.Copiloto__c : '');
        gen.writeNumberField('flightBOW', voo.Payload__c != null ? voo.Payload__c : Decimal.valueOf(0));
        gen.writeNumberField('flightFuel', voo.PesoCombustivel__c != null ? voo.PesoCombustivel__c : Decimal.valueOf(0));
        gen.writeStringField('observation', voo.Observacoes__c != null ? voo.Observacoes__c : '');
        gen.writeDateTimeField('lastModifiedDate', Utils.getUTCDatetime(voo.LastModifiedDate));
        
        TrechosService.writeJSON(gen, trechos); //Inicia trechos
        
        gen.writeEndObject(); //Finaliza dados do voo
    }
    
    public String getJSON(Map<Voo__c, List<Trecho__c>> mapToJSON)
    {
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartArray(); //Inicia array de voos    
        
        Set<Id> setPrefixos = new Set<Id>();
        for(Voo__c voo: mapToJSON.keySet())
        {
            setPrefixos.add(voo.Prefixo__c);
        }
        
        Map<Id, Aeronave__c> aeronavesPorId = new Map<Id, Aeronave__c>(new AeronavesSelector().selectById(setPrefixos));
        
        for (Voo__c voo : mapToJSON.keySet())
        {
            List<Trecho__c> trechosVoo = mapToJSON.get(voo);
            if(trechosVoo.size() > 0)
            {
                writeVooJSON(gen, voo, mapToJSON.get(voo), aeronavesPorId.get(voo.Prefixo__c));
            }
        } 
        gen.writeEndArray(); //Finaliza array de voos
        
        return gen.getAsString();
    }
    
    public void setRouteFields(fflib_ISObjectUnitOfWork uow)
    {
        for(Voo__c voo : (List<Voo__c>)Records)
        {
            String rota = '';
            String rotaAbreviada = '';
            String chaveRota = '';
            
            if (voo.Trechos__r.size() > 0)
            {
                rota = voo.Trechos__r.get(0).Origem__r.Name;
                chaveRota = voo.Trechos__r.get(0).Origem__r.CodigoLocal__c;
                rotaAbreviada = voo.Trechos__r.get(0).Origem__r.CodigoLocal__c;
                for(Trecho__c trecho : voo.Trechos__r)
                {
                    rota += ' > ' + trecho.Destino__r.Name;
                    rotaAbreviada += ' > ' + trecho.Destino__r.CodigoLocal__c;
                    chaveRota += trecho.Destino__r.CodigoLocal__c;
                }
            }
            voo.Rota__c = rota;
            voo.RotaAbreviada__c = rotaAbreviada;
            voo.ChaveRota__c = chaveRota;
            uow.registerDirty(voo);
        }
    }
    
    public Map<Id, Account> retrieveAccountMapFromVooList(List<Voo__c> records) {
        Set<Id> accSetId = new Set<Id>();
        for(Voo__c voo : records) {
            if(voo.Cliente__c != null)
                accSetId.add(voo.Cliente__c);
        }
        
        Map<Id, Account> accMap = new Map<Id, Account>(AccountsSelector.newInstance().selectById(accSetId));
        return accMap;
    }
    
    public Set<Id> retrieveAeronaveSetIdFromRecords(List<Voo__c> records) {
        Set<Id> aeronaveSetId = new Set<Id>();
        for(Voo__c voo : records)
            aeronaveSetId.add(voo.Prefixo__c);
        return aeronaveSetId;
    }
    
    public Map<String, Aeronave__c> retrieveNameAeronaveMapFromAeronaveList(List<Aeronave__c> aeronaveList) {
        Map<String, Aeronave__c> nameAeronaveMap = new Map<String, Aeronave__c>();
        for(Aeronave__c aeronave : aeronaveList)
            nameAeronaveMap.put(aeronave.Name, aeronave);
        return nameAeronaveMap;
    }
    
    public Datetime retrieveSmallerDateFromRecords() {
        Integer tempoPlanejamentoPre = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPre__c);
        Datetime smallerDate = null;
        for(Voo__c voo : (List<Voo__c>) records) {
            if(smallerDate == null && voo.DataVoo__c != null) smallerDate = voo.DataVoo__c.addMinutes(-tempoPlanejamentoPre);
            else if(voo.DataVoo__c != null && voo.DataVoo__c < smallerDate) smallerDate = voo.DataVoo__c.addMinutes(-tempoPlanejamentoPre);
        }
        return smallerDate;
    }
    
    public Datetime retrieveBiggerDateFromRecords() {
        Integer tempoPlanejamentoPos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPos__c);
        Datetime biggerDate = null;
        for(Voo__c voo : (List<Voo__c>) records) {
            if(biggerDate == null && voo.DataVoo__c != null) biggerDate = voo.DataVoo__c.addMinutes(tempoPlanejamentoPos);
            else if(voo.DataVoo__c != null && voo.DataVoo__c > biggerDate) biggerDate = voo.DataVoo__c.addMinutes(tempoPlanejamentoPos);
        }
        return biggerDate;
    }
    
    public Map<Id, Calendar> retrieveCalendarMapByRecords(Set<String> aeronaveSetName, Map<Id, Aeronave__c> aeronaveMap)
    {
        Map<Id, Calendar> calendarMap = new Map<Id, Calendar>(CalendarsSelector.newInstance().selectCalendarsByPrefixsSetName(aeronaveSetName));
        return calendarMap;
    }
    
    public Calendar retrieveCalendarByVooAndCalendarMap(Voo__c voo, Map<Id, Aeronave__c> aeronaveMap, Map<Id, Calendar> calendarMap)
    {
        Calendar calendar = null;
        for(Calendar c : calendarMap.values()) {
            if(checkIfVooHasPrefixo(voo) && aeronaveMap.get(voo.Prefixo__c) != null && c.Name.equals(aeronaveMap.get(voo.Prefixo__c).Name))
            {
                calendar = c;
            }
        }
        return calendar;
    }
    
    public Boolean verifyExistingEventForVoo(Voo__c voo, List<Event> eventList)
    {
        Boolean exist = false;
        for(Event event : eventList) {
            if(voo.Id.equals(event.WhatId))
                exist = true;
        }
        return exist;
    }
    
    public Boolean checkIfVooStatusIsRascunho(Voo__c voo) {
        return String.isNotBlank(voo.Status__c) && voo.Status__c.equals(RASCUNHO);
    }
    
    public Boolean checkIfVooStatusIsPreReservado(Voo__c voo) {
        return String.isNotBlank(voo.Status__c) && voo.Status__c.equals(PRERESERVADO);
    }
    
    public Boolean checkIfVooStatusIsReservado(Voo__c voo) {
        return String.isNotBlank(voo.Status__c) && voo.Status__c.equals(RESERVADO);
    }
    
    public Boolean checkIfVooStatusIsConfirmado(Voo__c voo) {
        return String.isNotBlank(voo.Status__c) && voo.Status__c.equals(CONFIRMADO);
    }
    
    public Boolean checkIfVooStatusIsCancelado(Voo__c voo) {
        return String.isNotBlank(voo.Status__c) && voo.Status__c.equals(CANCELADO);
    }
    
    public Boolean checkIfVooStatusIsFaturamento(Voo__c voo) {
        return String.isNotBlank(voo.Status__c) && voo.Status__c.equals(FATURAMENTO);
    }
    
    public boolean checkIfVooCanCreateUpdateEvent(Voo__c voo)
    {
        Boolean valid = false;
        if(checkIfVooHasStatusToCreateUpdateEvent(voo) && checkIfVooHasPrefixo(voo)  && checkValidDateOfVoo(voo)) valid = true;
        return valid;
    }
    
    public Boolean checkIfVooHasPrefixo(Voo__c voo)
    {
        Boolean valid = false;
        if(String.isNotBlank(voo.Prefixo__c)) valid = true;
        else if(checkIfVooHasStatusToCreateUpdateEvent(voo)) voo.Prefixo__c.addError(Label.ErroPrefixoVazio);
        return valid;
    }
    
    public Boolean checkIfVooHasStatusReservadoConfirmado(Voo__c voo)
    {
        Boolean valid = false;
        if(checkIfVooStatusIsReservado(voo) || checkIfVooStatusIsConfirmado(voo)) valid = true;
        return valid;
    }
    
    public Boolean checkIfVooHasStatusToCreateUpdateEvent(Voo__c voo)
    {
        Boolean valid = false;
        if(checkIfVooStatusIsPreReservado(voo) || checkIfVooHasStatusReservadoConfirmado(voo)) valid = true;
        return valid;
    }
    
    public Boolean checkValidDateOfVoo(Voo__c voo)
    {
        Boolean valid = false;
        if(voo.DataVoo__c != null) valid = true;
        else if(checkIfVooHasStatusToCreateUpdateEvent(voo)) voo.DataVoo__c.addError(Label.ErroDataVazio);
        return valid;
    }
    
    public Boolean checkVooDataToValidPlanning(Voo__c voo, Voo__c vooOld)
    {
        Boolean valid = true;
        if((voo.Prefixo__c == vooOld.Prefixo__c &&
            voo.DataVoo__c == vooOld.DataVoo__c &&
            voo.TempoCorteCliente__c == vooOld.TempoCorteCliente__c &&
            
            // Se o Status mudar de Rascunho para Pré-Reservado, deve criar Eventos
            !((vooOld.Status__c.equals(RASCUNHO) && voo.Status__c.equals(PRERESERVADO)) ||
              // Se o Status mudar de Rascunho para Reservado, deve criar Eventos
              (vooOld.Status__c.equals(RASCUNHO) && voo.Status__c.equals(RESERVADO)) ||
              // Se o Status mudar de Pré-Reservado para Reservado, deve criar Eventos
              (vooOld.Status__c.equals(PRERESERVADO) && voo.Status__c.equals(RESERVADO))) &&
            
            // Se a Rota mudar, ou não possuir status para criar/atualizar evento, ou não possuir uma Data valida para o Voo
            voo.Rota__c == vooOld.Rota__c) ||
           !checkIfVooHasStatusToCreateUpdateEvent(voo) || !checkValidDateOfVoo(voo))
        {
            valid = false;
        }
        return valid;
    }
    
    public List<Voo__c> getVoosToPlan(Map<Id, sObject> existingRecords)
    {
        List<Voo__c> validVoos = new List<Voo__c>();
        for(Voo__c voo : (List<Voo__c>) records)
        {
            Voo__c vooOld = (Voo__c) existingRecords.get(voo.Id);
            Boolean valid = true;
            if((voo.Prefixo__c == vooOld.Prefixo__c &&
                voo.DataVoo__c == vooOld.DataVoo__c &&
                voo.TempoCorteCliente__c == vooOld.TempoCorteCliente__c &&
                
                // Se o Status mudar de Rascunho para Pré-Reservado, deve criar Eventos
                !((vooOld.Status__c.equals(RASCUNHO) && voo.Status__c.equals(PRERESERVADO)) ||
                  // Se o Status mudar de Rascunho para Reservado, deve criar Eventos
                  (vooOld.Status__c.equals(RASCUNHO) && voo.Status__c.equals(RESERVADO)) ||
                  // Se o Status mudar de Pré-Reservado para Reservado, deve criar Eventos
                  (vooOld.Status__c.equals(PRERESERVADO) && voo.Status__c.equals(RESERVADO))) &&
                
                // Se a Rota mudar, ou não possuir status para criar/atualizar evento, ou não possuir uma Data valida para o Voo
                voo.Rota__c == vooOld.Rota__c) ||
               !checkIfVooHasStatusToCreateUpdateEvent(voo) || !checkValidDateOfVoo(voo))
            {
                valid = false;
            }
            if(valid && checkIfVooHasPrefixo(voo)) validVoos.add(voo);
        }
        return validVoos;
    }
    
    public Boolean validateTempoPlanejamentoPre(Voo__c voo, List<Event> eventList, CalculoMissaoResult cmr, Map<String, Aeronave__c> aeronaveMapByName)
    {
        Boolean valid = true;
        Integer tempoPlanejamentoPre = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPre__c);
        
        if(cmr == null) voo.Missao__c.addError('Não foi possível calcular a missão');
        else {
            Datetime vooStartDate = Events.calculeDatetimeStartEvent(voo, cmr);
            for(Event event : eventList)
            {
                Boolean permissao = true;
                DateTime eventStartDateTime = event.StartDateTime;
                DateTime eventEndDateTime = event.EndDateTime;
                if(eventStartDateTime < vooStartDate && eventEndDateTime > vooStartDate.addMinutes(-tempoPlanejamentoPre) &&
                   !voo.Id.equals(event.WhatId) && voo.Prefixo__c.equals(aeronaveMapByName.get(event.OwnerName__c).Id)
                   && (String.isBlank(voo.VooPai__c) || (String.isNotBlank(voo.VooPai__c) && !voo.VooPai__c.equals(event.WhatId))))
                {
                    permissao = false;
                    valid = permissao;
                }
                
                if(!permissao) 
                {
                    String corpo = '';
                    corpo += '\n<p> vooStartDate ' + vooStartDate;
                    corpo += '\n</p><p> eventStartDate ' + eventStartDateTime;
                    corpo += '\n</p><p> eventEndDate ' + eventEndDateTime;
                    corpo += '\n</p><p> event.WhatId ' + event.WhatId;
                    corpo += '\n</p><p> voo.Id ' + voo.Id;
                    corpo += '\n</p><p> voo.Prefixo__c ' + voo.Prefixo__c;
                    corpo += '\n</p><p> event.OwnerName__c ' + event.OwnerName__c;
                    corpo += '\n</p><p> aeronaveMapByName.get(event.OwnerName__c).Id ' + aeronaveMapByName.get(event.OwnerName__c).Id;
                    corpo += '\n</p><p> voo.VooPai__c ' + voo.VooPai__c;
                    
                    corpo += '\n</p><p>****************************** \n \n ';
                    for(Voo__c v : (List<Voo__c>)records)
                    {
                        corpo += '\n</p><p> Data Voo \n \n ' + v.DataVoo__c;
                        corpo += '\n</p><p> Prefixo \n \n ' + v.Prefixo__c;
                        corpo += '\n</p><p> Voo \n \n ' + JSON.serialize(v);
                    }
                    //corpo += '\n calculosPorVoo: \n \n ' + JSON.serialize(calculosPorVoo);
                    //corpo += '\n ultimaPagina: \n \n ' + JSON.serialize(ultimaPagina);
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSaveAsActivity(false);
                    mail.setHtmlBody(corpo);
                    List<String> mails = new List<String>();
                    mails.add('hugo@cbcloud.com.br');
                    mail.setToAddresses(mails);
                    mail.setSubject('Notificação de erro do pre-reserva');                
                    mail.setOrgWideEmailAddressId(ConfiguracoesGerais__c.getOrgDefaults().idRemetentePesquisaSatisfacao__c);
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                    voo.Prefixo__c.addError(Label.ErroTempoPlanejamentoPre);
                }
            }
        }
        return valid;
    }
    
    public Boolean validatePlanejamentoMeio(Voo__c voo, List<Event> eventList, CalculoMissaoResult cmr, Map<String, Aeronave__c> aeronaveMapByName)
    {
        Boolean valid = true;
        if(cmr != null) {
            Datetime vooStartDate = Events.calculeDatetimeStartEvent(voo, cmr);
            Datetime vooEndDate = Events.calculeDatetimeEndEvent(voo, cmr);
            
            for(Event event : eventList)
            {
                Boolean permissao = true;
                DateTime eventStartDate = event.StartDateTime;
                DateTime eventEndDate = event.EndDateTime;
                if(((eventStartDate <= vooStartDate && vooEndDate <= eventEndDate) ||
                    (vooStartDate <= eventStartDate && eventEndDate <= vooEndDate))
                   && !voo.Id.equals(event.WhatId) && voo.Prefixo__c.equals(aeronaveMapByName.get(event.OwnerName__c).Id)
                   && (String.isBlank(voo.VooPai__c) || (String.isNotBlank(voo.VooPai__c) && !voo.VooPai__c.equals(event.WhatId))))
                {
                    permissao = false;
                    valid = permissao;
                }
	                
                if(!permissao) {
                    String corpo = '';
                    corpo += '\n<p> vooStartDate ' + vooStartDate;
                    corpo += '\n</p><p> vooEndDate ' + vooEndDate;
                    corpo += '\n</p><p> eventStartDate ' + eventStartDate;
                    corpo += '\n</p><p> eventEndDate ' + eventEndDate;
                    corpo += '\n</p><p> event.WhatId ' + event.WhatId;
                    corpo += '\n</p><p> voo.Id ' + voo.Id;
                    corpo += '\n</p><p> voo.Prefixo__c ' + voo.Prefixo__c;
                    corpo += '\n</p><p> event.OwnerName__c ' + event.OwnerName__c;
                    corpo += '\n</p><p> aeronaveMapByName.get(event.OwnerName__c).Id ' + aeronaveMapByName.get(event.OwnerName__c).Id;
                    corpo += '\n</p><p> voo.VooPai__c ' + voo.VooPai__c;

                    corpo += '\n</p><p>****************************** \n \n ';
                    for(Voo__c v : (List<Voo__c>)records)
                    {
                        corpo += '\n</p><p> Data Voo \n \n ' + v.DataVoo__c;
                        corpo += '\n</p><p> Prefixo \n \n ' + v.Prefixo__c;
                        corpo += '\n</p><p> Voo \n \n ' + JSON.serialize(v);
                    }
                    //corpo += '\n calculosPorVoo: \n \n ' + JSON.serialize(calculosPorVoo);
                    //corpo += '\n ultimaPagina: \n \n ' + JSON.serialize(ultimaPagina);
                        
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSaveAsActivity(false);
                    mail.setHtmlBody(corpo);
                    List<String> mails = new List<String>();
                    mails.add('hugo@cbcloud.com.br');
                    mail.setToAddresses(mails);
                    mail.setSubject('Notificação de erro do pre-reserva');                
                    mail.setOrgWideEmailAddressId(ConfiguracoesGerais__c.getOrgDefaults().idRemetentePesquisaSatisfacao__c);
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                    voo.Prefixo__c.addError(Label.ErroVooDentroPeriodo);
                }
            }
        } else if(!checkIfVooHasPrefixo(voo))
        {
            valid = false;
            voo.Prefixo__c.addError(Label.ErroPrefixoVazio);
        } else if(cmr == null)
        {
            valid = false;
            voo.Missao__c.addError('Validar Meio: Não foi criado um CMR');
        }
        return valid;
    }
    
    public Boolean validateTempoPlanejamentoPos
        (Voo__c voo, List<Event> eventList, CalculoMissaoResult cmr, Map<String, Aeronave__c> aeronaveMapByName)
    {
        Boolean valid = true;
        if(cmr != null)
        {
            Integer tempoPlanejamentoPos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPos__c);
            Datetime vooStartDate = Events.calculeDatetimeStartEvent(voo, cmr);
            Datetime vooEndDate = Events.calculeDatetimeEndEvent(voo, cmr);
            
            for(Event event : eventList)
            {
                Boolean permissao = true;
                DateTime eventStartDate = event.StartDateTime;
                DateTime eventEndDate = event.EndDateTime;
                
                if(vooStartDate < eventStartDate && vooEndDate.addMinutes(tempoPlanejamentoPos) > eventStartDate &&vooEndDate < eventEndDate
                   && !voo.Id.equals(event.WhatId) && voo.Prefixo__c.equals(aeronaveMapByName.get(event.OwnerName__c).Id)
                   && (String.isBlank(voo.VooPai__c) || (String.isNotBlank(voo.VooPai__c) && !voo.VooPai__c.equals(event.WhatId))))
                {
                    permissao = false;
                    valid = permissao;
                }
                
                if(!permissao) 
                {
                    String corpo = '';
                    corpo += '\n<p> vooStartDate ' + vooStartDate;
                    corpo += '\n</p><p> vooEndDate ' + vooEndDate;
                    corpo += '\n</p><p> eventStartDate ' + eventStartDate;
                    corpo += '\n</p><p> eventEndDate ' + eventEndDate;
                    corpo += '\n</p><p> event.WhatId ' + event.WhatId;
                    corpo += '\n</p><p> voo.Id ' + voo.Id;
                    corpo += '\n</p><p> voo.Prefixo__c ' + voo.Prefixo__c;
                    corpo += '\n</p><p> event.OwnerName__c ' + event.OwnerName__c;
                    corpo += '\n</p><p> aeronaveMapByName.get(event.OwnerName__c).Id ' + aeronaveMapByName.get(event.OwnerName__c).Id;
                    corpo += '\n</p><p> voo.VooPai__c ' + voo.VooPai__c;
                    
                    corpo += '\n</p><p>****************************** \n \n ';
                    for(Voo__c v : (List<Voo__c>)records)
                    {
                        corpo += '\n</p><p> Data Voo \n \n ' + v.DataVoo__c;
                        corpo += '\n</p><p> Prefixo \n \n ' + v.Prefixo__c;
                        corpo += '\n</p><p> Voo \n \n ' + JSON.serialize(v);
                    }
                    //corpo += '\n calculosPorVoo: \n \n ' + JSON.serialize(calculosPorVoo);
                    //corpo += '\n ultimaPagina: \n \n ' + JSON.serialize(ultimaPagina);
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSaveAsActivity(false);
                    mail.setHtmlBody(corpo);
                    List<String> mails = new List<String>();
                    mails.add('hugo@cbcloud.com.br');
                    mail.setToAddresses(mails);
                    mail.setSubject('Notificação de erro do pre-reserva');                
                    mail.setOrgWideEmailAddressId(ConfiguracoesGerais__c.getOrgDefaults().idRemetentePesquisaSatisfacao__c);
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                    voo.Prefixo__c.addError(Label.ErroTempoPlanejamentoPos);
                }
            }
        } else if(cmr == null)
        {
            valid = false;
            voo.Missao__c.addError('Validar Pós: Não foi criado um CMR');
        }
        return valid;
    }
    
    public Boolean validateManutencao(Voo__c voo, List<Event> eventList, CalculoMissaoResult cmr, fflib_ISObjectUnitOfWork uow)
    {
        Boolean valid = true;
        if(checkValidDateOfVoo(voo))
        {
            Integer tempoPlanejamentoPre = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPre__c);
            Integer tempoPlanejamentoPos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPos__c);
            Datetime vooStart = Events.calculeDatetimeStartEvent(voo, cmr).addMinutes(-tempoPlanejamentoPre);
            Datetime vooEnd = null;
            Datetime horaAtual = Datetime.now();
            
            if(cmr != null)
            {
                vooEnd = Events.calculeDatetimeEndEvent(voo, cmr).addMinutes(tempoPlanejamentoPos);
                
                for(Event event : eventList)
                {
                    Boolean permissao = true;
                    Datetime eventStart = null;
                    Datetime eventEnd = null;
                    if(String.isNotBlank(voo.Prefixo__c) && voo.Prefixo__c.equals(event.WhatId) &&
                       !event.Cancelado__c)
                    {
                        eventStart = event.StartDateTime;
                        eventEnd = event.EndDateTime;
                        if(eventStart <= horaAtual && horaAtual < eventEnd &&
                           eventStart < vooStart && vooStart < eventEnd)
                        {
                            permissao = false;
                            valid = permissao;
                            voo.Prefixo__c.addError(Label.ErroEventoManutencaoJaIniciado);
                        } else if(Events.newInstance(new List<Event>())
                                  .validateIfDateOfEventEntersInDateOfAnotherEvent(vooStart, vooEnd, eventStart, eventEnd))
                        {
                            if(event.Urgencia__c.equals(Label.ManutencaoUrgenciaAlta))
                            {
                                permissao = false;
                                valid = permissao;
                                voo.Prefixo__c.addError(Label.ErroManutencao);
                            } else if(checkIfVooHasStatusReservadoConfirmado(voo))
                            {
                                event.Cancelado__c = true;
                                uow.registerDirty(event);
                            }
                        }
                    }
                    if(!permissao) break;
                }
            } else if(!checkIfVooHasPrefixo(voo))
            {
                valid = false;
                voo.Prefixo__c.addError(Label.ErroPrefixoVazio);
            } else if(cmr == null)
            {
                valid = false;
                voo.Missao__c.addError('Validar Meio: CMR não foi definido para esse Voo. Fale com um administrador');
            }
        }
        return valid;
    }
    
    public void createEventRelatedToVoo
        (Voo__c voo, CalculoMissaoResult cmr, Map<Id, Aeronave__c> aeronaveMap, Map<Id, Calendar> calendarMap, Map<Id, Account> accountMap, fflib_ISObjectUnitOfWork uow)
    {
        Calendar calendar = retrieveCalendarByVooAndCalendarMap(voo, aeronaveMap, calendarMap);
        if(calendar != null) {
            EventsService.createEvent(voo, calendar, cmr, accountMap.get(voo.Cliente__c), aeronaveMap.get(voo.Prefixo__c), uow);
        } else if(checkIfVooHasPrefixo(voo)) {
            voo.Prefixo__c.addError(Label.PrefixoNaoPossuiCalendario);
        }
    }
    
    public Event retrieveEventToHandle(Id vooId, List<Event> eventList)
    {
        Integer i = 0;
        while (i < eventList.size())
        {
            if(String.isNotBlank(vooId) && vooId.equals(eventList.get(i).WhatId))  //Id do voo = WhatId do evento
            { 
                return eventList.get(i);
            } 
            i++;
        }
        return null;
    }
    
    public Boolean validateTempoPlanejamento(Voo__c voo, List<Event> eventList, CalculoMissaoResult cmr, Map<String, Aeronave__c> aeronaveMapByName)
    {
        Boolean valid = false;
        if(!String.isBlank(voo.Prefixo__c)){
            if(this.validatePlanejamentoMeio(voo, eventList, cmr, aeronaveMapByName) &&
               this.validateTempoPlanejamentoPre(voo, eventList, cmr, aeronaveMapByName) &&
               this.validateTempoPlanejamentoPos(voo, eventList, cmr, aeronaveMapByName))
            {
                valid = true;
            }
        }
        return valid;
    }
    
    public void validateExistingRecordsTempoPlanejamentoAndCreateUpdateRelatedEvent
        (Voo__c voo, List<Event> entreVoosPreEventList, List<Event> eventList, List<Event> entreVoosPosEventList,
        CalculoMissaoResult cmr, Map<Id,SObject> existingRecords, Map<Id, Aeronave__c> aeronaveMap,
        Map<Id, Calendar> calendarMap, Map<Id, Account> accountMap, fflib_ISObjectUnitOfWork uow)
    {
        if(!checkIfVooHasPrefixo(voo) && checkIfVooHasPrefixo((Voo__c) existingRecords.get(voo.Id)))
        {
            EventsService.deleteEventRelatedToVoo(voo, entreVoosPreEventList, eventList, entreVoosPosEventList, uow);
        } else if(validateTempoPlanejamento(voo, eventList, cmr, retrieveNameAeronaveMapFromAeronaveList(aeronaveMap.values())))
        {
            EventsService.deleteEventRelatedToVoo(voo, entreVoosPreEventList, eventList, entreVoosPosEventList, uow);
            
            Datetime umaSemanaAFrente = System.now().addDays(7); //campo para comparar a antecedência de uma semana
            if (voo.TrocaTurma__c == true &&  voo.DataVoo__c > umaSemanaAFrente)
            {
                //Comportamento adicionado para o caso previsto na story 191
                //Pela não definição de cálculo de missão e por do sol no momento de desenvolvimento,
                //crio os eventos até às 20h do dia do voo. 
                //O voos não estão de subscrevendo nos tempo dos cálculos de missão, mas os eventos de voo 
                //ainda estão permitindo subscrição
                Datetime fimVoo = Datetime.newInstance(voo.DataVoo__c.date(), time.newInstance(20, 0, 0, 0));
                Long tempoVoo = (fimVoo.getTime() - voo.DataVoo__c.getTime()) / 1000 / 60;
                cmr.tempoMissao = tempoVoo;
            }
            createEventRelatedToVoo(voo, cmr, aeronaveMap, calendarMap, accountMap, uow);
        }
    }
    
    public void updateTrechosBycmrMap
        (Map<Id, SObject> existingRecords, Map<Id, Voo__c> mapVooComTrecho, Map<Id, CalculoMissaoResult> mapVooViavelCMR, fflib_ISObjectUnitOfWork uow)
    {
        for(Voo__c voo : (List<Voo__c>) records)
        {
            List<Trecho__c> trajeto = mapVooComTrecho.get(voo.Id).Trechos__r;
            CalculoMissaoResult cmr = mapVooViavelCMR.get(voo.Id);
            if(checkVooDataToValidPlanning(voo, (Voo__c) existingRecords.get(voo.Id)) && String.isNotBlank(voo.Prefixo__c) && voo.DataVoo__c != null &&
               cmr != null)
            {
                List<FlightLeg> flighLegs = cmr.trechos;
                
                if(flighLegs != null && trajeto != null && trajeto.size() > 0 && flighLegs.size() > 0)
                {
                    Decimal tempoTransladoIda = (cmr.tempoTransladoIda != null ? cmr.tempoTransladoIda : 0);
                    if(trajeto != null && trajeto.size() > 0 && trajeto[0].Tipo__c == 'Translado')
                    {
                        if(cmr != null && cmr.trechos != null && cmr.trechos.size() > 0 && cmr.trechos[0].tempoMissao != null)
                        {
                            tempoTransladoIda = cmr.trechos[0].tempoMissao;
                        }
                    }
                    Boolean temTransladoIda = (tempoTransladoIda > 0 ? true : false);
                    for(Integer index = 0; index < trajeto.size(); index++)
                    {
                        updateTrechoBycmr(voo, trajeto[index], flighLegs[index], tempoTransladoIda, uow);
                    }
                } else if(cmr != null && trajeto != null && trajeto.size() > 0 && (cmr.trechos == null || trajeto.size() != cmr.trechos.size())) {
                    //System.debug('CMR Size: ' + (cmr != null ? cmr.trechos.size() + '' : 'Nulo (0)') + '\nTrajeto Size: ' + trajeto.size());
                    /*System.debug(
                        'CMR: ' + cmr +
                        '\nTrechos Size: ' + trajeto.size() +
                        '\nFlightleg Size: ' + (cmr.trechos != null ? String.valueOf(cmr.trechos.size()) : String.valueOf(cmr.trechos)) +
                        '\nupdateTrechosBycmrMap');*/
                    /*throw new CalloutException(
                        'CMR: ' + cmr +
                        '\nTrechos Size: ' + trajeto.size() +
                        '\nFlightleg Size: ' + (cmr.trechos != null ? String.valueOf(cmr.trechos.size()) : String.valueOf(cmr.trechos)) +
                        '\nupdateTrechosBycmrMap');*/
                }
            }
        }
    }
    
    public void updateTrechoBycmr(Voo__c voo, Trecho__c trecho, FlightLeg flightLeg, Decimal tempoTransladoIda, fflib_ISObjectUnitOfWork uow)
    {
        trecho.TempoDecorrido__c = flightLeg.tempoDecorrido;
        trecho.TempoCruzeiro__c = flightLeg.tempoCruzeiro;
        trecho.TempoSolo__c = flightLeg.tempoSolo;
        trecho.TempoMissao__c = flightLeg.tempoMissao;
        trecho.DisponibilidadePeso__c = flightLeg.DisponibilidadePeso;
        trecho.PrevisaoDecolagem__c = voo.DataVoo__c.addMinutes(Integer.valueOf(flightLeg.tempoDecorrido - tempoTransladoIda));
        uow.registerDirty(trecho);
    }
    
    public List<Voo__c> getCanceledVoosOrUpdatedToRascunho(Map<Id, sObject> existingRecords) 
    {
        List<Voo__c> voosToDeleteEvent = new List<Voo__c>();
        for(Voo__c voo : (List<Voo__c>) records)
        {
            Voo__c vooOld = (Voo__c) existingRecords.get(voo.Id);
            if((!vooOld.Status__c.equals(CANCELADO) && voo.Status__c.equals(CANCELADO)) ||
               (!vooOld.Status__c.equals(RASCUNHO) && voo.Status__c.equals(RASCUNHO)))
            {
                voosToDeleteEvent.add(voo);
            }
        }
        return voosToDeleteEvent;
    }
    
    public CalculoMissaoResult createCMRByMissao(Missao__c missao)
    {
        CalculoMissaoResult cmr = new CalculoMissaoResult();
        cmr.tempoTransladoIda = missao.TempoTransladoIda__c;
        cmr.tempoTransladoRetorno = missao.TempoTransladoRetorno__c;
        cmr.tempoCruzeiro = missao.TempoCruzeiro__c;
        cmr.tempoSolo = missao.TempoSolo__c;
        cmr.tempoMissao = missao.TempoMissao__c;
        return cmr;
    }
    
    public List<Voo__C> getVoosWithTempoMissaoUpdated
        (Map<Id, sObject> existingRecords, Map<Id, Missao__c> missoesMap, Map<Id, Aeronave__c> aeronaveMap, Map<Id, Calendar> calendarMap, Map<Id, Account> accountMap)
    {
        List<Voo__c> voosTempoMissaoUpdated = new List<Voo__c> ();
        for(Voo__c voo : (List<Voo__c>) records)
        {
            Voo__c vooOld = (Voo__c) existingRecords.get(voo.Id);
            Missao__c missao = missoesMap.get(voo.Missao__c);
            
            if(!checkVooDataToValidPlanning(voo, vooOld) && voo.Missao__c != null &&
               (voo.TempoMissao__c != null && voo.TempoMissao__c > 0) && voo.TempoMissao__c != vooOld.TempoMissao__c && voo.Missao__c == vooOld.Missao__c &&
               missao != null && checkIfVooCanCreateUpdateEvent(voo))
            {
                voosTempoMissaoUpdated.add(voo);
            } else if(String.isNotBlank(voo.Missao__c) && (voo.TempoMissao__c == null || voo.TempoMissao__c <= 0) && checkIfVooCanCreateUpdateEvent(voo))
            {
                voo.TempoMissao__c.addError(Label.ErroTempoMissaoVazio);
            }
        }
        return voosTempoMissaoUpdated;
    }
    
    public void createEventWithNewTempoMissaoOfVoo
        (Voo__c voo, Missao__c missao, Calendar calendar, Account cliente, Aeronave__c aeronave, Set<Event> eventsSet, fflib_ISObjectUnitOfWork uow)
    {
        if(missao.TempoMissao__c != voo.TempoMissao__c)
        {
            missao.TempoMissao__c = voo.TempoMissao__c;
            uow.registerDirty(missao);
        }
        
        CalculoMissaoResult cmr = createCMRByMissao(missao);
        
        EventsService.deleteEventRelatedToVoo(voo, eventsSet, uow);
        EventsService.createEvent(voo, calendar, cmr, cliente, aeronave, uow);
    }
    
    public void handleEventsOnBeforeDelete(List<Voo__c> voos, fflib_ISObjectUnitOfWork uow)
    {
        Set<Id> aeronaveSetId = this.retrieveAeronaveSetIdFromRecords(voos);
        List<Aeronave__c> aeronaveList = AeronavesSelector.newInstance().selectById(aeronaveSetId);
        
        Integer IntervaloEmDiasBuscaEventos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().IntervaloEmDiasBuscaEventos__c);
        Datetime smallerDate = retrieveSmallerDateFromRecords();
        smallerDate = smallerDate != null ? Datetime.newInstance(smallerDate.date(), Time.newInstance(0, 0, 0, 0)).addDays(-IntervaloEmDiasBuscaEventos) : null;
        Datetime biggerDate = retrieveBiggerDateFromRecords();
        biggerDate = biggerDate != null ? Datetime.newInstance(biggerDate.date(), Time.newInstance(23, 59, 0, 0)).addDays(IntervaloEmDiasBuscaEventos) : null;
        
        Set<String> aeronaveSetName = Utils.getSetOfField((List<SObject>) aeronaveList, 'Name');
        Set<String> whatIds = (Set<String>)Utils.getSetOfField(records, 'Id');
        // Todos Eventos por Nome de Calendário e id de Voo
        Map<Id, Event> eventMap = new Map<Id, Event>(EventsSelector.newInstance().selectEventsByOwnerNameOrWhatId(
            aeronaveSetName, whatIds, smallerDate, biggerDate));
        // Separar os eventos por tipo de registro
        Events eventsDomain = new Events(eventMap.values());
        List<Event> entreVoosPreEventList = eventsDomain.getEntreVoos(Label.Pre);
        List<Event> eventVooList = eventsDomain.getVoo();
        List<Event> entreVoosPosEventList = eventsDomain.getEntreVoos(Label.Pos);
        
        for(Voo__c voo : voos)
        {
            //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ Deletar Eventos Relacionados ao Voo ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
            if(!this.verifyExistingEventForVoo(voo, eventVooList)) {
                EventsService.deleteEventRelatedToVoo(voo, entreVoosPreEventList, eventVooList, entreVoosPosEventList, uow);
            }
            //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
        }
    }
    
    public override void handleAfterDelete() 
    {
    	/*if(Configuration.EnforcingTriggerCRUDSecurity && !SObjectDescribe.isDeletable())
    	   throw new DomainException('Permission to delete an ' + SObjectDescribe.getName() + ' denied.');*/
    	   
    	onAfterDelete();
    }
    
    @TestVisible
    private Boolean checkIfVooFinalizou(Voo__c voo, Map<Id,SObject> existingRecords)
    {
        if (voo.Status__c.equals(EXECUTADO))
        {
            String statusAntigo = (String)existingRecords.get(voo.Id).get('Status__c');
            
            return !statusAntigo.equals(EXECUTADO);
        }
        
        return false;
    }
    
    
    private void handleSkytrac(fflib_ISObjectUnitOfWork uow, Voo__c newVoo, Voo__c oldVoo)
    {
        if 
            (
                newVoo.DataVoo__c != oldVoo.DataVoo__c ||
                newVoo.TempoMissao__c != oldVoo.TempoMissao__c ||
                newVoo.AtrasoTotalMinutos__c != oldVoo.AtrasoTotalMinutos__c
            )
        {
            try
            {
                System.abortJob(newVoo.CronTriggerId__c);
            }
            catch (System.StringException e)
            {
                System.debug(LoggingLevel.WARN, 'Tentativa de cancelar agendamento de notificação do voo ' + newVoo.Name + ' falhou (' + newVoo.CronTriggerId__c + '): ' + e.getMessage());
            }
            catch (Exception e)
            {
                newVoo.addError(e.getMessage());
            }
            finally
            {
                if (ConfiguracoesIntegracaoSkyTrac__c.getOrgDefaults().Executar__c)
                {
                    scheduleNotificacaoSkytrac(uow, newVoo);   
                }
            }
        }
    }
    
    
    public void scheduleNotificacaoSkytrac(fflib_ISObjectUnitOfWork uow, Voo__c newVoo)
    {
        /*String name = NotificacaoFimRastreioSchedulable.class.getName() + '-' + newVoo.Name;
        String cronString = Utils.getCronString(newVoo.DataFimRastreamentoVoo__c);
        NotificacaoFimRastreioSchedulable notificacao = new NotificacaoFimRastreioSchedulable(newVoo);
        
        try       
        {
            Voo__c vooAux = newVoo.clone(true);
            vooAux.CronTriggerId__c = Utils.schedule(name, cronString, notificacao);
            uow.registerDirty(vooAux); 
        }
        catch (Utils.SchedulableException e)
        {
            System.debug(LoggingLevel.WARN, 'Tentativa de agendamento de notificação do voo ' + newVoo.Name + ' falhou: ' + e.getMessage());
        }*/
    }
    //UTILIZADO PELO SKYTRAC, NÃO UTILIZEM SE NÃO TIVER CERTEZA DO QUE TÁ FAZENDO
    public void updateLogPendenteBySkytrac(fflib_ISObjectUnitOfWork uow)
    {
        for (Voo__c voo : (List<Voo__c>)records)
        {
            if (!voo.Status__c.equals(EXECUTADO))
            {
                voo.Status__c = LOGPENDENTE;
                voo.CronTriggerId__c = '';
                uow.registerDirty(voo);                
            }
        }        
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {  
        if(!ignorarTriggerUpdate())
        {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
            for (Voo__c voo : (List<Voo__c>)records)
            {
                Voo__c oldVoo = (Voo__c)existingRecords.get(voo.Id);
                handleSkytrac(uow, voo, oldVoo);
            }
            
            uow.commitWork();
            integraStar();
        }
    }
    
    private Boolean checkStatusDiferente(Voo__c voo, Voo__c oldVoo)
    {
        if (voo == null || oldVoo == null)
        {
            throw new VooException('Algum dos voos passados no parâmetro está nulo: [Voo -> ' + voo + '] [oldVoo -> ' + oldVoo + ']');
        }
        
        return !voo.Status__c.equals(oldVoo.Status__c);        
    }
    
    private void updateFields(Voo__c vooToUpdate, Voo__c oldVoo)
    {
        if (checkStatusDiferente(vooToUpdate, oldVoo) && checkIfVooStatusIsReservado(vooToUpdate))
        {
            vooToUpdate.HorarioVooReservado2__c = Utils.getDatetimeGmt(System.now());
        }        
    }
    
    private CalculoMissaoResult getCMR(Voo__c voo, Aeronave__c aeronave, List<Local__c> trajeto)
    {    
        /*System.debug('trajeto é...');
        for (Local__c local : trajeto)
        {
            System.debug('local: ' + local);
            System.debug('local: ' + local.Name);
        }*/
        
        CalculoMissaoResult cmr = new CalculoMissaoResult();
        if (voo != null && aeronave != null && trajeto != null && trajeto.size() > 0 && voo.DataVoo__c != null)
        {
            cmr.ExecutarCalculoMissao(aeronave, trajeto, voo.DataVoo__c.date());            
        }
        
        return cmr;
    }
    
    private Boolean checkCriaCalculoMissaoResult(Voo__c voo, Voo__c oldVoo)
    {
        if (voo.Prefixo__c == null || voo.DataVoo__c == null)
        {
            return false;
        }
        else if 
            (
                (oldVoo.Status__c.equals(RASCUNHO) && 
                (voo.Status__c.equals(PRERESERVADO) || voo.Status__c.equals(RESERVADO))) ||
                (oldVoo.Status__c.equals(PRERESERVADO) && voo.Status__c.equals(RESERVADO))
            )
        {
            return true;
        }
        else if (voo.Status__c.equals(PRERESERVADO) || voo.Status__c.equals(RESERVADO) || voo.Status__c.equals(CONFIRMADO))
        {
            if 
                (
                    voo.Prefixo__c != oldVoo.Prefixo__c || //prefixo mudou
                    voo.DataVoo__c != oldVoo.DataVoo__c || //data mudou
                    voo.TempoCorteCliente__c != oldVoo.TempoCorteCliente__c || //corte mudou  
                    voo.Rota__c != oldVoo.Rota__c //rota mudou
                )
            {
                return true;
            }
        }
        
        return false;
    }
    
    public override void onBeforeInsert()
    {
        List<Voo__c> voosComConta = new List<Voo__c>();
        for(Voo__c voo : (List<Voo__c>)records)
        {
            if(voo.Cliente__c != null)
            {
                voosComConta.add(voo);
            }
        }
        if(voosComConta.size() > 0)
        {
            List<Account> contas = AccountsSelector.newInstance().selectAll();
            Map<Id, AccountNode> mapHierarquia = AccountsService.getHierarquiaContas(contas);
            for(Voo__c voo : voosComConta)
            {
                AccountNode node = AccountsService.getContaPaiMestre(mapHierarquia, new Account(Id=voo.Cliente__c));
                voo.IdContaPai__c = node.accountItem.Id;
            }
        }
    }
    
    public void validaUpdate(Map<Id, Map<Schema.SObjectField, Boolean>> isChangedMap, List<Voo__c> voosList)
    {
        for(Voo__c voo : voosList)
        {
            Map<Schema.SObjectField, Boolean> changed = isChangedMap.get(voo.Id);
            Id userId = UserInfo.getUserId();
            Boolean usuarioPodeEditar = userId == '0053i000001flipAAA' || userId == '0053i000002gaeHAAQ';
            if((voo.Status__c == FATURAMENTO || voo.Status__c == FATURADO) && changed.values().size() > 1 && !usuarioPodeEditar)
            {
                voo.addError('Um voo no status ' + voo.Status__c + ' não pode ser editado');
            }
        }
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
    {
        Boolean ignorarTrigger = false;
        Map<Id, Voo__c> oldVoos = (Map<Id, Voo__c>)Trigger.oldMap;
        Map<Id, Voo__c> newVoos = (Map<Id, Voo__c>)Trigger.newMap;
        List<Voo__c> voosUpdateContaPai = new List<Voo__c>();
        
        for(Voo__c voo : (List<Voo__c>)records)
        {
            if(voo.IgnorarTrigger__c)
            {
                ignorarTrigger = true;
                break;
            }
            if(oldVoos.get(voo.Id).Cliente__c != newVoos.get(voo.Id).Cliente__c)
            {
                voosUpdateContaPai.add(voo);
            }
            if((oldVoos.get(voo.Id).Status__c != newVoos.get(voo.Id).Status__c) && newVoos.get(voo.Id).Status__c == CANCELADO)
            {
                voo.Skytrac__c = false;
            }
        }
        
        if(!ignorarTrigger && !ignorarTriggerUpdate())
        {
            Map<Id, Map<Schema.SObjectField, Boolean>> isChangedMap = getIschanged(oldVoos, newVoos);
        	validaUpdate(isChangedMap, (List<Voo__c>)records);
            
            System.debug('Voos - Before Update');
            
            if(voosUpdateContaPai.size() > 0)
            {
                List<Account> contas = AccountsSelector.newInstance().selectAll();
                Map<Id, AccountNode> mapHierarquia = AccountsService.getHierarquiaContas(contas);
                for(Voo__c voo : voosUpdateContaPai)
                {
                    AccountNode node = AccountsService.getContaPaiMestre(mapHierarquia, new Account(Id=voo.Cliente__c));
                    voo.IdContaPai__c = node.accountItem.Id;
                }
            }
            
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            //Carrega dados de aeronaves
            Set<Id> aeronavesIds = new Set<Id>();
            aeronavesIds.addAll(Utils.getSetIds(records, 'Prefixo__c'));
            aeronavesIds.addAll(Utils.getSetIds(existingRecords.values(), 'Prefixo__c'));
            Map<Id, Aeronave__c> aeronaveMap = new Map<Id, Aeronave__c>(AeronavesSelector.newInstance().selectAeronaveAndModelo(aeronavesIds));
            Map<String, Aeronave__c> nameAeronaveMap = this.retrieveNameAeronaveMapFromAeronaveList(aeronaveMap.values());
            //Carrega voos com trechos
            Map<Id, Voo__c> mapVooComTrecho = new Map<Id, Voo__c>(VoosSelector.newInstance().selectWithTrechosById(Utils.getSetIds(records, 'Id')));        
            Map<Id, CalculoMissaoResult> mapVooViavelCMR = new Map<Id, CalculoMissaoResult>();
            
            Map<Voo__c, Map<Schema.SObjectField, List<String>>> mapVooErrors = new Map<Voo__c, Map<Schema.SObjectField, List<String>>>();
            
            List<Voo__c> voosParaDefinirBaseResponsavelLog = new List<Voo__c>();
            
            for (Voo__c voo : (List<Voo__c>)records)
            {
                Voo__c oldVoo = (Voo__c)existingRecords.get(voo.Id);
                
                if(!voo.EnviouLogsVoo__c && voo.Status__c.equals(EXECUTADO) && !oldVoo.Status__c.equals(EXECUTADO) && !oldVoo.Status__c.equals(FATURAMENTO) && !oldVoo.Status__c.equals(FATURADO))
                {
                    voosParaDefinirBaseResponsavelLog.add(mapVooComTrecho.get(voo.Id));
                }
    
                //Atualização de campos
                
                updateFields(voo, oldVoo); 
                if (checkCriaCalculoMissaoResult(voo, oldVoo) && mapVooComTrecho.get(voo.Id) != null && mapVooComTrecho.get(voo.Id).Trechos__r.size() > 0)
                {
                    Aeronave__c aeronave = aeronaveMap.get(voo.Prefixo__c);
                    List<Local__c> trajeto = Trechos.newInstance(mapVooComTrecho.get(voo.Id).Trechos__r).getTrajeto();
                    //Criação de CMR
                    CalculoMissaoResult cmr = getCMR(voo, aeronave, trajeto);
                    //setCMRErrors(voo, cmr, mapVooErrors.get(voo));
                    
                    //verificação de viabilidade de peso, combustível e horário de decolagem
                    system.debug('Criou cálculo e ele é ' + (cmr.viabilidade ? 'viável' : 'não viável'));
                    if (cmr != null && cmr.viabilidade)
                    {
                        if (voo.QtdTrechosOrigemOffshore__c > 0 && cmr.hrMaximoDecolagem != null && voo.DataVoo__c > cmr.hrMaximoDecolagem && !voo.MEDVAC__c)
                        {
                            //TODO: Renato e Fernando: setar erro bonitinho
                            voo.addError(
                                Label.ErroOrigemOffShoreUltrapassaHorarioMaximoDecolagem.replace('@horariomaximo', cmr.hrMaximoDecolagem.format('kk:mm:ss'))
                            );
                        }
                        else
                        {
                            //se o voo é viável, insere o cmr no map de voos viaveis
                            //TODO: Renato e Fernando: utilizar esse map para criar missões
                            mapVooViavelCMR.put(voo.Id, cmr);
                        }
                    }
                    else if (cmr != null && !cmr.viabilidade)
                    {                    
                        //TODO: Renato e Fernando: setar erro bonitinho
                        voo.addError('Voo inviável por motivos de peso ou combustível');
                    }                                 
                } 
                else
                {
                    //setErrors(voo, mapVooErrors);
                }
            }
            
            
            for (Voo__c voo : (List<Voo__c>)records)
            {  
                for (Voo__c vooToCompare : (List<Voo__c>)records)
                {
                    Boolean valid = null;
                    //SE AMBOS OS VOOS NÃO ESTÃO EM RASCUNHO OU CANCELADO
                    if (voo != vooToCompare && !voo.Status__c.equals(RASCUNHO) && !voo.Status__c.equals(CANCELADO) && !vooToCompare.Status__c.equals(RASCUNHO) && !vooToCompare.Status__c.equals(CANCELADO))
                    {
                        //SE É A MESMA AERONAVE
                        if (voo.Prefixo__c.equals(vooToCompare.Prefixo__c))
                        {
                            CalculoMissaoResult cmrVoo = mapVooViavelCMR.get(voo.Id);
                            CalculoMissaoResult cmrVooToCompare = mapVooViavelCMR.get(vooToCompare.Id);
                            if (cmrVoo != null && cmrVooToCompare != null)
                            {
                                if (colideHorario(voo, cmrVoo, vooToCompare, cmrVooToCompare))
                                {
                                    valid = false;
                                    voo.addError(Label.ErroHorarioConflitanteEntreVoos);
                                } else {
                                    valid = true;
                                }
                            } 
                        }
                    }
                }
            }
            
            // ################################# Handle Events on Before Update #################################
            Map<Id, Calendar> calendarMap = this.retrieveCalendarMapByRecords(nameAeronaveMap.keySet(), aeronaveMap);
            Map<Id, Account> accountMap = this.retrieveAccountMapFromVooList((List<Voo__c>) records);
            //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
            Set<Id> missoesSetId = Utils.getSetIds(records, 'Missao__c');
            Map<Id, Missao__c> missoesMap = new Map<Id, Missao__c>(MissoesSelector.newInstance().selectById(missoesSetId));
            //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ Condição para busca de Eventos ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
            Boolean buscarEventos = false;
            List<Event> entreVoosPreEventList = new List<Event>();
            List<Event> eventVooList = new List<Event>();
            List<Event> entreVoosPosEventList = new List<Event>();
            List<Event> eventManutencaoList = new List<Event>();
            Set<Event> eventSet = new Set<Event> ();
            
            List<Voo__c> voosToPlan = getVoosToPlan(existingRecords);
            List<Voo__c> voosToDeleteEvents = getCanceledVoosOrUpdatedToRascunho(existingRecords);
            List<Voo__c> voosWithTempoMissaoUpdated = getVoosWithTempoMissaoUpdated(existingRecords, missoesMap, aeronaveMap, calendarMap, accountMap);
            // Só entra se tiver condição de verificar se invade oturos eventos como entre voos e manutenções de alta prioridade
            // Ou se for deletar eventos de Voos Cancelados e Rascunho
            buscarEventos = (voosToPlan.size() > 0 || voosToDeleteEvents.size() > 0 || voosWithTempoMissaoUpdated.size() > 0);
            if(buscarEventos)
            {
                System.debug('Buscou eventos');
                Integer IntervaloEmDiasBuscaEventos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().IntervaloEmDiasBuscaEventos__c);
                Datetime smallerDate = retrieveSmallerDateFromRecords();
                smallerDate = smallerDate != null ? Datetime.newInstance(smallerDate.date(), Time.newInstance(0, 0, 0, 0)).addDays(-IntervaloEmDiasBuscaEventos) : null;
                Datetime biggerDate = retrieveBiggerDateFromRecords();
                biggerDate = biggerDate != null ? Datetime.newInstance(biggerDate.date(), Time.newInstance(23, 59, 0, 0)).addDays(IntervaloEmDiasBuscaEventos) : null;
                
                Set<String> whatIds = (Set<String>)Utils.getSetOfField(records, 'Id');
                // Todos Eventos por Nome de Calendário e id de Voo
                Map<Id, Event> eventMap = new Map<Id, Event>(EventsSelector.newInstance().selectEventsByOwnerNameOrWhatId(
                    nameAeronaveMap.keySet(), whatIds, smallerDate, biggerDate));
                // Separar os eventos por tipo de registro
                Events eventsDomain = new Events(eventMap.values());
                entreVoosPreEventList.addAll(eventsDomain.getEntreVoos(Label.Pre));
                eventVooList.addAll(eventsDomain.getVoo());
                entreVoosPosEventList.addAll(eventsDomain.getEntreVoos(Label.Pos));
                eventManutencaoList.addAll(eventsDomain.getManutencao());
                // Criar um set de eventos apenas de entre voos e voos
                eventSet.addAll(eventsDomain.groupEventsList(new List<List<Event>> {entreVoosPreEventList, eventVooList, entreVoosPosEventList}));
            }
            
            //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ Deleção de Eventos ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
            EventsService.deleteEventRelatedToVoos(voosToDeleteEvents, eventSet, uow);
            //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
            
            for (Voo__c voo : voosToPlan)
            {
                System.debug('Possui voos para planejar');
                CalculoMissaoResult cmr = mapVooViavelCMR.get(voo.Id);
                //▬▬▬▬▬ Validação de Planejamento/Manutenção, Criação/Atualização de Eventos Relacionados ao Voo ▬▬▬▬▬▬
                if(cmr != null && validateManutencao(voo, eventManutencaoList, cmr, uow))
                {
                    Voo__c vooComTrechos = mapVooComTrecho.get(voo.Id);
                    vooComTrechos.DataVoo__c = voo.DataVoo__c;
                    vooComTrechos.Prefixo__c = voo.Prefixo__c;
                    validateExistingRecordsTempoPlanejamentoAndCreateUpdateRelatedEvent(
                        vooComTrechos, entreVoosPreEventList, eventVooList, entreVoosPosEventList, cmr,
                        existingRecords, aeronaveMap, calendarMap, accountMap, uow);
                }
            }
            
            //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ Tempo de Missão Alterado Atualiza Eventos ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
            for(Voo__c voo : voosWithTempoMissaoUpdated)
            {
                System.debug('Possui voos com tempo de missão atualizado');
                Voo__c vooComTrechos = mapVooComTrecho.get(voo.Id);
                vooComTrechos.DataVoo__c = voo.DataVoo__c;
                vooComTrechos.Prefixo__c = voo.Prefixo__c;
                createEventWithNewTempoMissaoOfVoo
                    (vooComTrechos, missoesMap.get(voo.Missao__c), retrieveCalendarByVooAndCalendarMap(voo, aeronaveMap, calendarMap),
                     accountMap.get(voo.Cliente__c), aeronaveMap.get(voo.Prefixo__c), eventSet, uow);
            }
            
            //setErrors(mapVooErrors);
            
            Map<Id, Missao__c> mapVooMissao = MissoesService.criarMissoes(uow, mapVooViavelCMR);
            
            for (Voo__c voo : (List<Voo__c>)records)
            {
                gerenciarMissao(voo, mapVooMissao, uow);
            }
            
            updateTrechosBycmrMap(existingRecords, mapVooComTrecho, mapVooViavelCMR, uow);
            
            if(voosParaDefinirBaseResponsavelLog.size() > 0)
            {
                defineBaseResponsavelLog(voosParaDefinirBaseResponsavelLog, (Map<Id, Voo__c>)Trigger.newMap);
            }
            
            uow.commitWork();
        }
    }
    
    public void updateVoosComBaseResponsavel(List<Voo__c> voosList, String baseResponsavel, Map<Id, Voo__c> mapVoosTrigger)
    {
        for(Voo__c voo : voosList)
        {
            mapVoosTrigger.get(voo.Id).BaseResponsavelLog__c = baseResponsavel;
            mapVoosTrigger.get(voo.Id).EnviouLogsVoo__c = true;
        }
    }
    
    public void defineBaseResponsavelLog(List<Voo__c> voosList, Map<Id, Voo__c> mapVoosTrigger)
    {
        Map<String, List<Voo__c>> voosPorBaseRetorno = getVoosByCodigoBaseRetorno(voosList);
        VoosPorBaseResponsavel voosPorBase = getVoosPorBaseResponsavel(voosPorBaseRetorno);
        if(voosPorBase.sbjr.size() > 0)
        {
            updateVoosComBaseResponsavel(voosPorBase.sbjr, 'SBJR', mapVoosTrigger);
            for(Voo__c voo : voosPorBase.sbjr)
            {
                Map<String, Object> params = new Map<String, Object>();
            	params.put('recordId', voo.Id);
                params.put('CoordenacaoResponsavel', 'SBJR');
                Flow.Interview.EnviaLogsVooConcluido enviaLogsFlow = new Flow.Interview.EnviaLogsVooConcluido(params);
            	enviaLogsFlow.start();
            }
        }
        if(voosPorBase.sbme.size() > 0)
        {
            updateVoosComBaseResponsavel(voosPorBase.sbme, 'SBME', mapVoosTrigger);
            for(Voo__c voo : voosPorBase.sbme)
            {
                Map<String, Object> params = new Map<String, Object>();
            	params.put('recordId', voo.Id);
                params.put('CoordenacaoResponsavel', 'SBME');
                Flow.Interview.EnviaLogsVooConcluido enviaLogsFlow = new Flow.Interview.EnviaLogsVooConcluido(params);
            	enviaLogsFlow.start();
            }
        }
    }
    
    public Map<String, List<Voo__c>> getVoosByCodigoBaseRetorno(List<Voo__c> voosList)
    {
        Map<String, List<Voo__c>> voosPorBaseRetorno = new Map<String, List<Voo__c>>();
        for(Voo__c voo : voosList)
        {
            List<Trecho__c> trechosList = voo.Trechos__r;
            if(trechosList == null || trechosList.size() < 1)
            {
				throw new VooException('O voo de id ' + voo.Id + ' não possui trechos');
            }
            Integer indexUltimoTrecho = trechosList.size()-1;
            String ultimaBase = trechosList[indexUltimoTrecho].CodigoDestino__c;
            
            List<Voo__c> voosComBase = voosPorBaseRetorno.containsKey(ultimaBase) ? voosPorBaseRetorno.get(ultimaBase) : new List<Voo__c>();
            voosComBase.add(voo);
            voosPorBaseRetorno.put(ultimaBase, voosComBase);
        }
        return voosPorBaseRetorno;
    }
    
    public VoosPorBaseResponsavel getVoosPorBaseResponsavel(Map<String, List<Voo__c>> voosPorBaseRetorno)
    {
        VoosPorBaseResponsavel voosPorBase = new VoosPorBaseResponsavel();
        for(String codigoBase : voosPorBaseRetorno.keySet())
        {
            List<Voo__c> voosBase = voosPorBaseRetorno.get(codigoBase);
            if(codigoBase.equals('SBJR'))
            {
                voosPorBase.sbjr.addAll(voosBase);
            }
            else
            {
                voosPorBase.sbme.addAll(voosBase);
            }
        }
        return voosPorBase;
    }

    
    /*
    private void setErrors(Map<Voo__c, Map<Schema.SObjectField, List<String>>> mapVooErrors)
    {
        for(Voo__c voo : mapVooErrors.keyset())
        {
            for(Schema.SObjectField field : mapVooErrors.get(voo).keyset()) {
                for(String msg : mapVooErrors.get(voo).get(field))
                {
                   addError(voo, field, msg);
                }
            }
        }
    }
    
    private void addError(Voo__c voo, Schema.SObjectField field, String msg)
    {
        if(field == Voo__c.DataVoo__c)
        {
            voo.DataVoo__c.addError(msg);
        } else if(field == Voo__c.Prefixo__c) {
            voo.Prefixo__c.addError(msg);
        }
    }
    
    private void setError(Map<Schema.SObjectField, List<String>> mapVooErrors, Schema.SObjectField field, String msg)
    {
        if (mapVooErrors.get(field) == null)
        {
            mapVooErrors.put(field, new List<String>());
        }
        
        mapVooErrors.get(field).add(msg);
    }
    
    public void setErrors(Voo__c voo, Map<Voo__c, Map<Schema.SObjectField, List<String>>> mapVooErrors)
    {
        if (mapVooErrors.get(voo) == null)
        {
            mapVooErrors.put(voo, new Map<Schema.SObjectField, List<String>>());
        }
        
        setPrefixoErrors(voo, mapVooErrors.get(voo));
        setDataVooErrors(voo, mapVooErrors.get(voo));        
    }
    
    private void setPrefixoErrors(Voo__c voo, Map<Schema.SObjectField, List<String>> mapFieldErrors)
    {
        if (String.isBlank(voo.Prefixo__c) && (voo.Status__c.equals('Pré-Reservado') || voo.Status__c.equals('Reservado') || voo.Status__c.equals('Confirmado')))
        {
            //setError(mapFieldErrors, Voo__c.Prefixo__c, 'Selecione um prefixo');
        }
    }
    
    private void setDataVooErrors(Voo__c voo, Map<Schema.SObjectField, List<String>> mapFieldErrors)
    {
        if (voo.DataVoo__c == null)
        {
            //setError(mapFieldErrors, Voo__c.DataVoo__c, 'Selecione uma data');
        }
    }
    
    private void setCMRErrors(Voo__c voo, CalculoMissaoResult cmr, Map<Schema.SObjectField, List<String>> mapFieldErrors)
    {
        if(cmr != null)
        {
			//System.debug(cmr);
            if(cmr.Viabilidade != null && !cmr.Viabilidade)
            {
                setError(mapFieldErrors, Voo__c.Missao__c, 'Voo inviável por motivos de peso ou combustível');
            }
            if(voo.QtdTrechosOrigemOffshore__c > 0 && cmr.hrMaximoDecolagem != null && voo.DataVoo__c >= cmr.hrMaximoDecolagem)
            {
                setError(mapFieldErrors, Voo__c.DataVoo__c,
                         Label.ErroOrigemOffShoreUltrapassaHorarioMaximoDecolagem.replace(
                             '@horariomaximo', String.valueOf(cmr.hrMaximoDecolagem.time()).replace('.000Z', '')
                         ));
            }
        }
    }*/
    
    private void gerenciarMissao(Voo__c voo, Map<Id, Missao__c> mapVooMissao, fflib_ISObjectUnitOfWork uow)
    {
        Missao__c missao = mapVooMissao.get(voo.Id);
        if (missao != null)
        {
            Missao__c oldMissao = voo.Missao__c != null ? new Missao__c(Id=voo.Missao__c) : null;
            if (oldMissao != null)
            {
                uow.registerDeleted(oldMissao);
            }
            uow.registerRelationship(voo, Voo__c.Missao__c, missao);
            voo.TempoMissao__c = missao.TempoMissao__c;
        }
    }
    
    private Boolean colideHorario(Voo__c voo, CalculoMissaoResult cmrVoo, Voo__c vooToCompare, CalculoMissaoResult cmrVooToCompare)
    {
        Integer tempoPlanejamentoPre = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPre__c);
        Integer tempoPlanejamentoPos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPos__c);
        
        Datetime vooStart = Events.calculeDatetimeStartEvent(voo, cmrVoo);
        Datetime vooEnd = Events.calculeDatetimeEndEvent(voo, cmrVoo);
        
        Datetime vooToCompareStart = Events.calculeDatetimeStartEvent(vooToCompare, cmrVooToCompare);
        Datetime vooToCompareEnd = Events.calculeDatetimeEndEvent(vooToCompare, cmrVooToCompare);
        
        IEvents events = Events.newInstance(new List<Event>());
        Boolean enterInAnotherEvent = events.validateIfDateOfEventEntersInDateOfAnotherEvent(vooStart, vooEnd, vooToCompareStart, vooToCompareEnd);
        return enterInAnotherEvent;
    }
    
    public override void onBeforeDelete()
    {
        //System.debug('Voos - Before Delete');
        
        List<Voo__c> voosDeletar = validaDelecao((List<Voo__c>)Records);
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        handleEventsOnBeforeDelete(voosDeletar, uow);
        
        uow.commitWork();
    }
    
    @TestVisible
    public static List<Voo__c> validaDelecao(List<Voo__c> voos)
    {
        Boolean podeDeletarVooStatusAvancado = FeatureManagement.checkPermission('AdminDeletaVoo');
        List<Voo__c> voosParaDeletar = new List<Voo__c>();
        if(!podeDeletarVooStatusAvancado)
        {
            List<StatusBloqueioDelecaoVoo__mdt> statusBloqueados = StatusBloqueioDelecaoVooSelector.newInstance().selectAll();
            Set<String> setStatusBloqueados = Utils.getSetOfField(statusBloqueados, 'DeveloperName');
            Map<String, String> devNameToLabel = Utils.getMapDevLabelFromPicklist(Voo__c.Status__c.getDescribe());      
            
            for(Voo__c voo : voos)
            {
                if(setStatusBloqueados.contains(voo.Status__c.replaceAll(' ', '')))
                {
                    String statusLabel = devNameToLabel.get(voo.Status__c);
                    voo.addError(Label.NaoPodeDeletarVooStatus.replace('#statusLabel#', statusLabel));
                }
                else
                {
                    voosParaDeletar.add(voo);
                }
            }
        }else
        {
            voosParaDeletar.addAll(voos);
        }
        return voosParaDeletar;
    }
    
    public void handleAprovacaoDiaVoo(fflib_ISObjectUnitOfWork uow)
    {
        for(Voo__c voo : (List<Voo__c>)records)
        {
            for(Trecho__c trecho : voo.trechos__r)
            {
                if(trecho.TemLocalMovel__c == true)
                {
                    voo.AprovacaoDiaVoo__c = 'Pendente';
                    uow.registerDirty(voo);
                }
            }
        }
    }
    
    public Map<Id, List<Voo__c>> getVoosPorPrefixo()
    {
        Map<Id, List<Voo__c>> voosPorPrefixo = new Map<Id, List<Voo__c>>();
        for(Voo__c v : (List<Voo__c>)records)
        {
            if(voosPorPrefixo.containsKey(v.Prefixo__c))
            {
                List<Voo__c> itens = voosPorPrefixo.get(v.Prefixo__c);
                itens.add(v);
                voosPorPrefixo.put(v.Prefixo__C, itens);
            }
            else
            {
                List<Voo__c> itens = new List<Voo__c>();
                itens.add(v);
                voosPorPrefixo.put(v.Prefixo__c, itens);
            }
        }
        return voosPorPrefixo;
    }

    public class VooException extends Exception {}
    
}