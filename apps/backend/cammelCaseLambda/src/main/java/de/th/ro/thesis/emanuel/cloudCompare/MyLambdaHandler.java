package de.th.ro.thesis.emanuel.cloudCompare;

import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.Context;
import com.th.ro.emanuel.thesis.camelcase.CamelCaseConverter;

/**
 * Hello world!
 *
 */
public class MyLambdaHandler implements RequestHandler<String, String> {
    @Override
    public String handleRequest(String input, Context context) {
        return convertCammelCase(input);
    }

    public static String convertCammelCase(String input) {
        // Your logic to convert to camel case
        return CamelCaseConverter.toCamelCase(input);
    }
}
