package de.th.ro.thesis.emanuel.cloudCompare;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class PrimeCheckLambdaHandlerTest {

    @Test
    void testConvertCammelCase() {
        // Given
        String input = "hello world";
        String expectedOutput = "helloWorld"; // Assuming the third-party library produces this result

        // When
        String actualOutput = MyLambdaHandler.convertCammelCase(input);

        // Then
        assertEquals(expectedOutput, actualOutput);
    }
}
