public class CompletarResultadosController {
    
    @AuraEnabled
    public static Wrapper getApostadores(){
        Wrapper result = new Wrapper();
        
        try{
            result.apostadores = [
                SELECT ID, Name
                FROM Contact
                WHERE LastName != 'Apostador'
            ];
        }catch(Exception e){
            result.hasError = true;
            result.errors.add(e.getMessage());
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Wrapper getFecha(){
        Wrapper result = new Wrapper();
        
        try{
            result.fecha = [
                SELECT ID
                FROM Fecha__c
                WHERE Estado__c = 'Pendiente'
            ];
        }catch(Exception e){
            result.hasError = true;
            result.errors.add(e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    public static boolean checkPredicciones(Fecha__c fecha, String apostadorId){
        system.debug('checkPredicciones(): ' + ' ' + fecha + ' ' + apostadorId);
        if(0 != [
            SELECT COUNT()
            FROM Prediccion_de_Partido__c
            WHERE Apuesta__r.Fecha__c = :fecha.Id
            AND Apuesta__r.Participacion_Prore__r.Contact__c = :apostadorId
        ]){
            return true;
        }
        
        return false;
    }
    
    @AuraEnabled
    public static Wrapper getPartidos2(Fecha__c fecha, String apostadorId){
        system.debug('getPartidos2(): ' + ' ' + fecha + ' ' + apostadorId);
        Wrapper result = new Wrapper();
        
        try{
            
            boolean prediccionesCompletas = checkPredicciones(fecha, apostadorId);
            system.debug('prediccionesCompletas: ' + prediccionesCompletas);
            if(prediccionesCompletas){
                result.predicciones = [
                    SELECT Apuesta__c,
                    Partido__r.Local__r.Name, 
                    Partido__r.Visitante__r.Name,
                    Goles_Local__c,
                    Goles_Visitante__c
                    FROM Prediccion_de_Partido__c
                    WHERE Apuesta__r.Fecha__c = :fecha.Id
                    AND Apuesta__r.Participacion_Prore__r.Contact__c = :apostadorId
                ];
                result.editarPredicciones = true;
            }else{
                result.partidos = [
                    SELECT Name,
                    Local__c, 
                    Local__r.Name, 
                    Visitante__c, 
                    Visitante__r.Name, 
                    Fecha__c,
                    Fecha__r.Name,
                    Fecha__r.Torneo__r.Name,
                    Goles_Visitante__c,
                    Goles_Local__c
                    FROM Partido__c
                    WHERE Fecha__c = :fecha.Id
                ];
            }
            
        }catch(Exception e){
            result.hasError = true;
            result.errors.add(e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Wrapper saveApuesta3(String apostadorId, List<Partido__c> partidos, List<Prediccion_de_Partido__c> prediccionesEditadas){
        system.debug('saveApuesta: ' + apostadorId + ' ' + partidos + ' ' + prediccionesEditadas);
        Wrapper result = new Wrapper();
        
        try{
            
            if(partidos != null){
                result = checkPartidos(partidos);
                if(result.hasError){
                    return result;
                }
            }
            
            if(prediccionesEditadas != null){
                result = checkPrediccionesEditadas(prediccionesEditadas);
                if(result.hasError){
                    return result;
                }
            }
            
            if(prediccionesEditadas != null && !prediccionesEditadas.isEmpty()){
                database.update(prediccionesEditadas);
                result.idApuesta = prediccionesEditadas[0].Apuesta__c;
            }else{
                Participacion_Prore__c participacion;
                result = checkParticipacion1(apostadorId, partidos);
                if(result.hasError){
                    return result;
                }else if(!result.nuevaParticipacion){
                    participacion = [
                        SELECT ID
                        FROM Participacion_Prore__c
                        WHERE Id = :result.idParticipacion
                    ];
                }else if(result.nuevaParticipacion){
                    participacion = new Participacion_Prore__c();
                    participacion.Name = partidos[0].Fecha__r.Torneo__r.Name;
                    participacion.Prore__c = [
                        SELECT ID
                        FROM Prore__c
                        WHERE Torneo__c = :partidos[0].Fecha__r.Torneo__c
                    ].Id;
                    participacion.Contact__c = apostadorId;
                    database.insert(participacion); 
                }
                
                Apuesta__c apuesta = new Apuesta__c();
                apuesta.Name = partidos[0].Fecha__r.Torneo__r.Name + ' - ' + partidos[0].Fecha__r.Name;
                apuesta.Participacion_Prore__c = participacion.Id;
                apuesta.Fecha__c = partidos[0].Fecha__c;
                database.insert(apuesta);
                
                result.idApuesta = apuesta.Id;
                
                List<Prediccion_de_Partido__c> predicciones = new List<Prediccion_de_Partido__c>();
                for(Partido__c partido : partidos){
                    Prediccion_de_Partido__c prediccion = new Prediccion_de_Partido__c();
                    prediccion.Name = partido.Name;
                    prediccion.Apuesta__c = apuesta.Id;
                    prediccion.Partido__c = partido.Id;
                    prediccion.Goles_Local__c = partido.Goles_Local__c;
                    prediccion.Goles_Visitante__c = partido.Goles_Visitante__c;
                    predicciones.add(prediccion);
                }
                database.insert(predicciones);
            }
            
        }catch(Exception e){
            result.hasError = true;
            result.errors.add(e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Wrapper checkParticipacion1(String apostadorId, List<Partido__c> partidos){
        Wrapper result = new Wrapper();
        
        try{
            List<Participacion_Prore__c> participacion = [
                SELECT ID
                FROM Participacion_Prore__c
                WHERE Prore__r.Torneo__c = :partidos[0].Fecha__r.Torneo__c
                AND Contact__c = :apostadorId
            ];
            
            if(participacion.isEmpty()){
                result.nuevaParticipacion = true;
            }else{
                result.idParticipacion = participacion[0].Id;
            }
        }catch(Exception e){
            result.hasError = true;
            result.errors.add(e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Wrapper checkPartidos(List<Partido__c> partidos){
        Wrapper result = new Wrapper();
        
        try{
            boolean hasError = false;
            for(Partido__c partido : partidos){
                if(partido.Goles_Local__c == null || partido.Goles_Visitante__c == null){
                    hasError = true;
                    break;
                }
            }
            
            if(hasError){
                result.hasError = true;
                result.errors.add('Completa todos los resultados ameu');
            }
        }catch(Exception e){
            result.hasError = true;
            result.errors.add(e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Wrapper checkPrediccionesEditadas(List<Prediccion_de_Partido__c> predicciones){
        Wrapper result = new Wrapper();
        
        try{
            boolean hasError = false;
            for(Prediccion_de_Partido__c prediccion : predicciones){
                if(prediccion.Goles_Local__c == null || prediccion.Goles_Visitante__c == null){
                    hasError = true;
                    break;
                }
            }
            
            if(hasError){
                result.hasError = true;
                result.errors.add('Completa todos los resultados ameu');
            }
        }catch(Exception e){
            result.hasError = true;
            result.errors.add(e.getMessage() + ' ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    public class Wrapper{
        
        public Wrapper(){
            this.hasError = false;
            this.errors = new List<String>();
            this.nuevaParticipacion = false;
            this.predicciones = new List<Prediccion_de_Partido__c>();
            this.editarPredicciones = false;
        }
        
        @AuraEnabled
        public boolean hasError {get;set;}
        
        @AuraEnabled
        public List<String> errors {get;set;}
        
        @AuraEnabled
        public List<Partido__c> partidos {get;set;}
        
        @AuraEnabled
        public List<Prediccion_de_Partido__c> predicciones {get;set;}
        
        @AuraEnabled
        public List<Contact> apostadores {get;set;}
        
        @AuraEnabled
        public Id idApuesta {get;set;}
        
        @AuraEnabled
        public boolean nuevaParticipacion {get;set;}
        
        @AuraEnabled
        public Id idParticipacion {get;set;}
        
        @AuraEnabled
        public Fecha__c fecha {get;set;}
        
        @AuraEnabled
        public boolean editarPredicciones {get;set;}
        
    }
    
}