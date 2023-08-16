package com.th.ro.emanuel.thesis.camelcase;



import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
import com.th.ro.emanuel.thesis.camelcase.CamelCaseConverter;
public class CamelCaseConverterTest {

    @Test
    public void testBasicString() {
        String input = "hello world";
        String expected = "helloWorld";
        String actual = CamelCaseConverter.toCamelCase(input);
        assertEquals(expected, actual);
    }

    @Test
    public void testStringWithSpecialChars() {
        String input = "hello-world_test";
        String expected = "helloWorldTest";
        String actual = CamelCaseConverter.toCamelCase(input);
        assertEquals(expected, actual);
    }

    @Test
    public void testStringWithSpacesAndSpecialChars() {
        String input = "hello - world_test";
        String expected = "helloWorldTest";
        String actual = CamelCaseConverter.toCamelCase(input);
        assertEquals(expected, actual);
    }

    @Test
    public void testStringWithNumbers() {
        String input = "hello123 world456";
        String expected = "hello123World456";
        String actual = CamelCaseConverter.toCamelCase(input);
        assertEquals(expected, actual);
    }

    // Add more tests as needed
}
