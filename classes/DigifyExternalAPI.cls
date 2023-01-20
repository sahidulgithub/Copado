public class DigifyExternalAPI {

    @AuraEnabled(cacheable=true) 
    public static String getEmail(){   
        String email = UserInfo.getUserEmail();
        System.debug('Email: ' +email);
        return email;
    }
   
 @AuraEnabled(cacheable=true) 
 public static String getEmbeddedLink(){    
        String userEmail = UserInfo.getUserEmail();
        system.debug('Email:'+userEmail);    
        String result = '';
        String key = 'O4WklEkDp4';
        String secret = 'FXkTQXoV6U47rusHMVKgo0oEmjLp3rZGAqGBAAqm';
        Blob headerValue = Blob.valueOf(key + ':' + secret);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String JSONBODY = '{ "Guid": "c11be9f56a0244da9b3ff8238b3cffb7","FileName": "dummy2.pdf","Expiry": "off","StartDate": "","ExpiryDate": "","DestructSeconds": ,"Download": 0,"Print": -1,"TermsOfAccess": "","Watermark": true,"Watermark_text": "'+userEmail+'","Watermark_size": "",  "Watermark_color": "","ScreenShield": ""}';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://svc.digify.com/v1/file/settings');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');//;charset=UTF-8
        request.setHeader('Authorization', authorizationHeader);
        request.setBody(JSONBODY);
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            Map<String,object> results = (Map<String,object>)JSON.deserializeUntyped(response.getBody()); 
            system.debug('EmbedLink'+(String)results.get('EmbedLink'));
            result = (String)results.get('EmbedLink');           
        }else{
            result = 'error';
        }
        return result;
    } 
        
    }