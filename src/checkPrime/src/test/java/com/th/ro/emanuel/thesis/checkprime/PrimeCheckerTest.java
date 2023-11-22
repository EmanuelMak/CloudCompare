package com.th.ro.emanuel.thesis.checkprime;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.Test;

import com.th.ro.emanuel.thesis.checkprime.PrimeChecker;

public class PrimeCheckerTest {

    @Test
    public void testPrimeNumber() {
        assertTrue(PrimeChecker.checkIfPrimeNumber(2), "2 should be prime");
        assertTrue(PrimeChecker.checkIfPrimeNumber(3), "3 should be prime");
        assertTrue(PrimeChecker.checkIfPrimeNumber(17), "17 should be prime");
    }

    @Test
    public void testNonPrimeNumber() {
        assertFalse(PrimeChecker.checkIfPrimeNumber(1), "1 should not be prime");
        assertFalse(PrimeChecker.checkIfPrimeNumber(4), "4 should not be prime");
        assertFalse(PrimeChecker.checkIfPrimeNumber(15), "15 should not be prime");
    }

    @Test
    public void testNegativeNumber() {
        assertFalse(PrimeChecker.checkIfPrimeNumber(-5), "Negative numbers should not be prime");
    }

    @Test
    public void testLargePrimeNumber() {
        assertTrue(PrimeChecker.checkIfPrimeNumber(2147483647), "2147483647 should be prime (it's the largest int prime)");
    }

    @Test
    public void testLargeNonPrimeNumber() {
        assertFalse(PrimeChecker.checkIfPrimeNumber(2147483648L), "2147483648 should not be prime");
    }

    // Add more tests as needed
}
