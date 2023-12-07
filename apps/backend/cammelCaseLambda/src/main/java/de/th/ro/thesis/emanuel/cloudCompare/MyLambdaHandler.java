package de.th.ro.thesis.emanuel.cloudCompare;

import java.util.Collections;
import java.util.Map;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.th.ro.emanuel.thesis.camelcase.CamelCaseConverter;
import de.th.ro.thesis.emanuel.cloudCompare.ApiGatewayResponse;
import com.google.gson.Gson;
/**
 * Hello world!
 *
 */
public class MyLambdaHandler implements RequestHandler<Map<String, Object>, ApiGatewayResponse> {
    @Override
    public ApiGatewayResponse handleRequest(Map<String, Object> event, Context context) {
        System.out.println("Received event: " + event);
        Map<String, String> queryParams = (Map<String, String>) event.get("queryStringParameters");
        if (queryParams == null || !queryParams.containsKey("text")) {
            throw new RuntimeException( "Input parameter text is required");
        }
        String input = queryParams.get("text");
        return new ApiGatewayResponse(
            200, // HTTP status code
            Collections.singletonMap("Content-Type", "application/json"), // headers
            new Gson().toJson(convertCammelCase(input)) // body
        );
    }

    public static String convertCammelCase(String input) {
        // Your logic to convert to camel case
        return CamelCaseConverter.toCamelCase(input);
    }
}
