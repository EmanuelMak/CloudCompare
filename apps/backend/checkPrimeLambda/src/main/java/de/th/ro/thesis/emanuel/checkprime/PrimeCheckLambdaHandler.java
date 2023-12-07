package de.th.ro.thesis.emanuel.checkprime;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.th.ro.emanuel.thesis.checkprime.PrimeChecker;

public class PrimeCheckLambdaHandler implements RequestHandler<Map<String, Object>, PrimeCheckResponse> {

    private static final String DB_HOST = System.getenv("DB_HOST");
    private static final String DB_USER = System.getenv("DB_USER");
    private static final String DB_PASSWORD = System.getenv("DB_PASSWORD");
    private static final String DB_NAME = System.getenv("DB_NAME");
    private static final String DB_URL = "jdbc:postgresql://" + System.getenv("DB_HOST") + ":5432/" + System.getenv("DB_NAME") + "?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory";
    @Override
    public PrimeCheckResponse handleRequest(Map<String, Object> event, Context context) {
        System.out.println("Received event: " + event);
        Map<String, String> queryStringParameters = (Map<String, String>) event.get("queryStringParameters");
        if (queryStringParameters == null || !queryStringParameters.containsKey("number")) {
            return new PrimeCheckResponse("Parameter 'number' is required.");
        }

        String numberStr = queryStringParameters.get("number");
        long parsedValue = 0;
        try {
            parsedValue = Long.parseLong(numberStr);
        } catch (NumberFormatException e) {
            return new PrimeCheckResponse( "Invalid format for number. Must be a number.");
        }

        Long number = parsedValue;
        System.out.println("Attempting to connect to the database");
        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            System.out.println("Database connection established");
            boolean isPrime = checkAndSavePrime(number, connection);

            List<Long> allPrimes = getAllPrimes(connection);

            return new PrimeCheckResponse(isPrime, allPrimes);
        } catch (SQLException e) {
            System.out.println("DB_URL1: " + DB_URL);
            System.out.println("DB_USER: " + DB_USER);
            System.out.println("DB_PASSWORD: " + DB_PASSWORD);
            throw new RuntimeException("Database connection failed", e);
        }
    }

    private boolean checkAndSavePrime(long number, Connection connection) throws SQLException {
        String selectQuery = "SELECT is_prime FROM checkt_numbers WHERE number = ?";
        try (PreparedStatement selectStmt = connection.prepareStatement(selectQuery)) {
            selectStmt.setLong(1, number);
            ResultSet rs = selectStmt.executeQuery();

            if (rs.next()) {
                return rs.getBoolean("is_prime");
            } else {
                boolean isPrime = PrimeChecker.checkIfPrimeNumber(number);
                String insertQuery = "INSERT INTO checkt_numbers (number, is_prime) VALUES (?, ?)";
                try (PreparedStatement insertStmt = connection.prepareStatement(insertQuery)) {
                    insertStmt.setLong(1, number);
                    insertStmt.setBoolean(2, isPrime);
                    insertStmt.executeUpdate();
                }
                return isPrime;
            }
        }
    }

    private List<Long> getAllPrimes(Connection connection) throws SQLException {
        List<Long> primes = new ArrayList<>();
        String query = "SELECT number FROM checkt_numbers WHERE is_prime = TRUE";
        try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                primes.add(rs.getLong("number"));
            }
        }
        return primes;
    }
}

class PrimeCheckResponse {
    private boolean isPrime;
    private List<Long> allPrimes;
    private String message;

    public PrimeCheckResponse(boolean isPrime, List<Long> allPrimes) {
        this.isPrime = isPrime;
        this.allPrimes = allPrimes;
    }

    public PrimeCheckResponse(String message) {
        this.message = message;
    }


    public boolean getIsPrime() {
        return isPrime;
    }
    public List<Long> getAllPrimes() {
        return allPrimes;
    }
    public void setIsPrime(boolean isPrime) {
        this.isPrime = isPrime;
    }
    public void setAllPrimes(List<Long> allPrimes) {
        this.allPrimes = allPrimes;
    }
}
