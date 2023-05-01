public with sharing class weatherWidgetController {

    @AuraEnabled 
    public static Map<String, Object> getWeatherDetails(String input, Id recordId){
        Map<String, Object> result = new Map<String, Object>();
        String url = 'https://api.openweathermap.org/data/2.5/forecast?q=' + input + '&units=metric' + getKey();
        String response = getResponse(url);
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Object> forecasts = (List<Object>) jsonResponse.get('list');
        if (forecasts.size() > 0) {
            Map<String, Object> tomorrowForecast = (Map<String, Object>) forecasts[7]; // Tomorrow's weather forecast
            Map<String, Object> main = (Map<String, Object>) tomorrowForecast.get('main');
            Double temperature = (Double) main.get('temp');
            Integer roundedTemp = (Integer) Math.round(temperature);
            List<Object> weather = (List<Object>) tomorrowForecast.get('weather');
            Map<String, Object> weatherInfo = (Map<String, Object>) weather[0];
            result.put('temperature', roundedTemp);
            result.put('description', weatherInfo.get('description'));

            // Update the Account record with the temperature
            Account acc = [SELECT Id, Number_of_Degrees__c FROM Account WHERE Id = :recordId];
            acc.Number_of_Degrees__c = roundedTemp;
            update acc;
        }
        return result;
    }

   

    public static String getResponse(String strUrl){
        Http h  = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strUrl);
        req.setTimeout(120000);
        res = h.send(req);
        String responseBody = res.getBody();
        return responseBody;
   }

   

   public static String getKey(){
    String key = '55cdfffd9a497e0ceb696883c45f26e3'; 
    String output = '&appid=' + key;
    return output;
   }
}