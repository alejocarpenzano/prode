public class PromiedosAPI {
    
    public Fecha__c fecha {get;set;}
    public Wrapper response {get;set;}
    
    //PromiedosAPI api = new PromiedosAPI([SELECT ID, Numero__c, Torneo__r.Name FROM Fecha__c LIMIT 1]);
    
    public PromiedosAPI(Fecha__c fecha){
        this.fecha = fecha;
        doCallout(fecha);
    }
    
    public void doCallout(Fecha__c fecha){
        processResponse(setUpAndCallout(fecha));
    }
    
    public HttpResponse setUpAndCallout(Fecha__c fecha){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://promiedos-scrapping.herokuapp.com/api/round/' + String.valueOf(fecha.Numero__c));
        return h.send(req);
    }
    
    public void processResponse(HttpResponse res){
        system.debug('processResponse: ' + res.getBody());
        this.response = new Wrapper();
        this.response.fecha = this.fecha;
        
        try{
            if(res.getStatusCode() == 200){
                
                Map<String, Id> equiposMap = getEquiposMap();
                for(String key : equiposMap.keySet()){
                    system.debug('key: ' + key + ' ' + 'value: ' + equiposMap.get(key));
                }
                
                List<PromiedosAPIResponse> partidosAPI = PromiedosAPIResponse.parse(res.getBody());
                system.debug('partidosAPI: ' + partidosAPI);
                
                for(PromiedosAPIResponse partidoAPI : partidosAPI){
                    Partido__c partido = new Partido__c();
                    
                    partido.Name = this.fecha.Torneo__r.Name + ' | ' + 'Fecha: ' + this.fecha.Numero__c + ' : ' + partidoAPI.home + ' vs ' + partidoAPI.visitor;
                    
                    partido.Fecha__c = this.fecha.Id;
                    
                    partido.Local__c = equiposMap.get(partidoAPI.home);
                    partido.Goles_Local__c = partidoAPI.homeResult;
                    
                    partido.Visitante__c = equiposMap.get(partidoAPI.visitor);
                    partido.Goles_Visitante__c = partidoAPI.visitorResult;
                    
                    partido.External_ID__c = this.response.Fecha.Id + ';' + partidoAPI.id;
                    
                    system.debug(partido.Local__c + ' ' + 
                                 partido.Goles_Local__c + ' - ' + 
                                 partido.Goles_Visitante__c + ' ' + 
                                 partido.Visitante__c + ' <--> ' + 
                                 partido.External_ID__c);
                    
                    this.response.partidos.add(partido);
                }
                upsert this.response.partidos External_ID__c;
            }else{
                this.response.hasError = true;
            }
        }catch(Exception e){
            system.debug(e.getMessage() + ' ' + e.getCause() + ' ' + e.getStackTraceString());
            this.response.hasError = true;
            this.response.errors.add(e.getMessage() + ' ' + e.getCause() + ' ' + e.getStackTraceString());
        }
    }
    
    public Map<String, Id> getEquiposMap(){
        Map<String, Id> response = new Map<String, Id>();
        for(Equipo__c equipo : [
            SELECT ID, Name
            FROM Equipo__c
        ]){
       		response.put(equipo.Name, equipo.Id);
        }
        return response;
    }
    
    public Wrapper getResponse(){
        return this.response;
    }
    
    Public class Wrapper{
        public Wrapper(){
            this.hasError = false;
            this.errors = new List<String>();
            this.partidos = new List<Partido__c>();
        }
        
        public boolean hasError {get;set;}
        public List<String> errors {get;set;}
        
        public Fecha__c fecha {get;set;}
        public List<Partido__c> partidos {get;set;}
    }
}