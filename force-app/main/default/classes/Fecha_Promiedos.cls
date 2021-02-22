/*
* header test
*/

public class Fecha_Promiedos {
    
    public class Pa {
        public String id {get;set;} 
        public String li {get;set;} 
        public String ti {get;set;} 
        public String ca {get;set;} 
        public String st {get;set;} 
        public String r1 {get;set;} //goles local
        public String r2 {get;set;} //goles visitante
        public String g1 {get;set;} 
        public String g2 {get;set;} 
        public String roj1 {get;set;} 
        public String roj2 {get;set;} 
        public String forma {get;set;} 
        public String pe {get;set;} 
        public String tvgol {get;set;} 
        public String cvid {get;set;} 
        
        public Pa(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'li') {
                            li = parser.getText();
                        } else if (text == 'ti') {
                            ti = parser.getText();
                        } else if (text == 'ca') {
                            ca = parser.getText();
                        } else if (text == 'st') {
                            st = parser.getText();
                        } else if (text == 'r1') {
                            r1 = parser.getText();
                        } else if (text == 'r2') {
                            r2 = parser.getText();
                        } else if (text == 'g1') {
                            g1 = parser.getText();
                        } else if (text == 'g2') {
                            g2 = parser.getText();
                        } else if (text == 'roj1') {
                            roj1 = parser.getText();
                        } else if (text == 'roj2') {
                            roj2 = parser.getText();
                        } else if (text == 'forma') {
                            forma = parser.getText();
                        } else if (text == 'pe') {
                            pe = parser.getText();
                        } else if (text == 'tvgol') {
                            tvgol = parser.getText();
                        } else if (text == 'cvid') {
                            cvid = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Pa consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public List<Pa> pa {get;set;} 
    
    public Fecha_Promiedos(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'pa') {
                        pa = arrayOfPa(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'Fecha_Promiedos consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    
    public static Fecha_Promiedos parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new Fecha_Promiedos(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                    depth++;
                } else if (curr == System.JSONToken.END_OBJECT ||
                           curr == System.JSONToken.END_ARRAY) {
                               depth--;
                           }
        } while (depth > 0 && parser.nextToken() != null);
    }
    
    
    
    
    private static List<Pa> arrayOfPa(System.JSONParser p) {
        List<Pa> res = new List<Pa>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Pa(p));
        }
        return res;
    }
    
    
}