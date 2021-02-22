public class PartidoTriggerHelper {
    public static void actualizarPartidos(List<Partido__c> partidos){
        
        List<Equipo__c> equipos = [
            SELECT ID, Name
            FROM Equipo__c
        ];
        
        Fecha__c fecha = [
            SELECT ID, Name, Torneo__r.Name
            FROM Fecha__c
            WHERE Estado__c = 'Pendiente'
        ];
        
        for(Partido__c partido : partidos){
            
            //Asignar Equipos
            for(Equipo__c equipo : equipos){    
                if(equipo.Name == partido.Home__c){
                    partido.Local__c = equipo.Id;
                }
                
                if(equipo.Name == partido.Away__c){
                    partido.Visitante__c = equipo.Id;
                }
            }
            
            //Asignar Fecha
            partido.Fecha__c = fecha.Id;
            
            //Nombre
            partido.Name = fecha.Torneo__r.Name + ' ' + fecha.Name + ' : ' + partido.Home__c + ' vs ' + partido.Away__c;
            
            //External ID
            partido.External_Id__c = fecha.Id + '|' + partido.Local__r.Name + '|' + partido.Visitante__r.Name; 
        }
        
    }
}