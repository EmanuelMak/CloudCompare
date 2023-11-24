package de.th.ro.thesis.emanuel.checkprime;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import de.th.ro.thesis.emanuel.checkprime.entitys.ChecktNumber;
import de.th.ro.thesis.emanuel.checkprime.repositorys.ChecktNumberRepository;
import com.th.ro.emanuel.thesis.checkprime.PrimeChecker;

import java.util.List;
import java.util.Optional;

public class PrimeCheckLambdaHandler implements RequestHandler<Long, PrimeCheckResponse> {

    private final ChecktNumberRepository checktNumberRepository;

    // Constructor for the repository
    public PrimeCheckLambdaHandler(ChecktNumberRepository checktNumberRepository) {
        this.checktNumberRepository = checktNumberRepository;
    }

    @Override
    public PrimeCheckResponse handleRequest(Long number, Context context) {
        // Check if the number is prime and save to DB
        boolean isPrime = checkAndSavePrime(number);

        // Get all prime numbers from DB
        List<ChecktNumber> allPrimes = checktNumberRepository.findByIsPrime(true);

        // Create and return the response
        return new PrimeCheckResponse(isPrime, allPrimes);
    }

    private boolean checkAndSavePrime(long number) {
        Optional<ChecktNumber> checktNumberOpt = this.checktNumberRepository.findById(number);
        if (checktNumberOpt.isPresent()) {
            return checktNumberOpt.get().isPrime();
        } else {
            boolean isPrime = PrimeChecker.checkIfPrimeNumber(number);
            this.checktNumberRepository.save(new ChecktNumber(number, isPrime));
            return isPrime;
        }
    }
}

// Response class
class PrimeCheckResponse {
    private boolean isPrime;
    private List<ChecktNumber> allPrimes;

    // Constructor, getters, and setters
    // Constructor
    public PrimeCheckResponse(boolean isPrime, List<ChecktNumber> allPrimes) {
        this.isPrime = isPrime;
        this.allPrimes = allPrimes;
    }
    protected PrimeCheckResponse() {}
}
