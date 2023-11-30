package de.th.ro.thesis.emanuel.cloudCompare;

import java.util.Map;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.th.ro.emanuel.thesis.camelcase.CamelCaseConverter;

/**
 * Hello world!
 *
 */
public class MyLambdaHandler implements RequestHandler<Map<String, Object>, String> {
    @Override
    public String handleRequest(Map<String, Object> event, Context context) {
        Map<String, String> queryParams = (Map<String, String>) event.get("queryStringParameters");
        if (queryParams == null || !queryParams.containsKey("text")) {
            return "Input parameter text is required";
        }
        String input = queryParams.get("text");
        return convertCammelCase(input);
    }

    public static String convertCammelCase(String input) {
        // Your logic to convert to camel case
        return CamelCaseConverter.toCamelCase(input);
    }
}
