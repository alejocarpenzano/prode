({
    doInit : function(component, event, helper) {
        console.info('doInit()');
        var action = component.get("c.getApostadores");
        component.set('v.isLoading', true);
        action.setCallback(this, function(response){
            component.set('v.isLoading', false);
            var state = response.getState();
            var result = response.getReturnValue();
            console.log(result);
            if (state === "SUCCESS") {
                if(!result.hasError){
                    console.log(result.apostadores);
                    component.set('v.apostadores', result.apostadores);
                    this.getFecha(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },
    getFecha : function(component, event, helper) {
        console.info('getFecha()');
        var action = component.get("c.getFecha");
        component.set('v.isLoading', true);
        action.setCallback(this, function(response){
            component.set('v.isLoading', false);
            var state = response.getState();
            var result = response.getReturnValue();
            console.log(result);
            if (state === "SUCCESS") {
                if(!result.hasError){
                    component.set('v.fecha', result.fecha);
                    console.log('fecha: ', result.fecha);
                }
            }
        });
        $A.enqueueAction(action);
    },
    doHandleChangeApostador: function(component, event, helper){
        console.info('doHandleChangeApostador()');
        var action = component.get("c.getPartidos2");
        action.setParams({
            'fecha': component.get('v.fecha'),
            'apostadorId': component.get('v.apostadorId')
        });
        component.set('v.isLoading', true);
        action.setCallback(this, function(response){
            component.set('v.isLoading', false);
            var state = response.getState();
            var result = response.getReturnValue();
            console.log(result);
            if (state === "SUCCESS") {
                if(!result.hasError){
                    component.set('v.partidos', result.partidos);
                    component.set('v.showPanel', true);
                    component.set('v.editarPredicciones', result.editarPredicciones);
                    component.set('v.predicciones', result.predicciones);
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleSave: function(component, event, helper){
        console.info('handleSave()');
        console.log(JSON.stringify(component.get('v.apostadorId')));
        console.log(JSON.stringify(component.get('v.partidos')));
        var action = component.get("c.saveApuesta3");
        action.setParams({
            'apostadorId': component.get('v.apostadorId'),
            'partidos': component.get('v.partidos'),
            'prediccionesEditadas': component.get('v.predicciones')
        });
        component.set('v.isLoading', true);
        action.setCallback(this, function(response){
            component.set('v.isLoading', false);
            var state = response.getState();
            var result = response.getReturnValue();
            console.log(result);
            if (state === "SUCCESS") {
                if(!result.hasError){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Completaste el Prore Correctamente!"
                    });
                    toastEvent.fire();
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result.idApuesta
                    });
                    navEvt.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": result.errors[0]
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})