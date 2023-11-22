package com.th.ro.emanuel.thesis.checkprime;

public class PrimeChecker {

    public static boolean checkIfPrimeNumber(long number) {
        if (number <= 1) {
            return false; // Numbers less than or equal to 1 are not prime
        }

        for (long i = 2; i <= Math.sqrt(number); i++) {
            if (number % i == 0) {
                return false; // Number is not prime if it's divisible by any number other than 1 and itself
            }
        }

        return true; // Number is prime
    }
}
