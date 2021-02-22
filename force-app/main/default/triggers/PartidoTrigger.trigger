trigger PartidoTrigger on Partido__c (before insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            //PartidoTriggerHelper.actualizarPartidos(Trigger.new);
        }
    }
}