@isTest
public class PromiedosAPITest {
    
    public static Fecha__c fecha {get;set;}
	
    @testSetup
    static void setup(){
    	
        Torneo__c torneo = new Torneo__c();
        torneo.Name = 'test';
        database.insert(torneo);
        
        fecha = new Fecha__c();
        fecha.Name = 'test';
        fecha.Torneo__c = torneo.Id;
        fecha.Numero__c = 1;
        database.insert(fecha);
        
    }
    
    @isTest
    static void testSuccess(){
        
		Test.setMock(HttpCalloutMock.class, new PromiedosAPIMock(true));
        
        PromiedosAPI.Wrapper response;
        Test.startTest();
        PromiedosAPI api = new PromiedosAPI(fecha);
        response = api.getResponse();
        Test.stopTest();
        
        system.assertEquals(false,response.hasError,'No deberia haber fallado');
    }
    
    @isTest
    static void testFailure(){
        
		Test.setMock(HttpCalloutMock.class, new PromiedosAPIMock(false));
        
        PromiedosAPI.Wrapper response;
        Test.startTest();
        PromiedosAPI api = new PromiedosAPI(fecha);
        response = api.getResponse();
        Test.stopTest();
        
        system.assertEquals(true,response.hasError,'Deberia haber fallado');
    }
        
}