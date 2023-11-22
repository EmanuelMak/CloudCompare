package de.th.ro.thesis.emanuel.checkprime.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;
import de.th.ro.thesis.emanuel.checkprime.entitys.ChecktNumber; // Adjust the path as necessary
import de.th.ro.thesis.emanuel.checkprime.repositorys.ChecktNumberRepository; // Adjust the path as necessary
import com.th.ro.emanuel.thesis.checkprime.PrimeChecker;

import java.util.List;
import java.util.Optional;

@RestController
public class PrimeCheckController {

    private final ChecktNumberRepository checktNumberRepository;

    public PrimeCheckController(ChecktNumberRepository checktNumberRepository) {
        this.checktNumberRepository = checktNumberRepository;
    }

    @GetMapping(value = "/checkIsPrimeNumber")
    public ResponseEntity<Boolean> checkPrime(@RequestParam(required = false, defaultValue = "0") long number) {
        Optional<ChecktNumber> checktNumberOpt = this.checktNumberRepository.findById(number);
        boolean isPrime;
        if (checktNumberOpt.isPresent()) {
            isPrime = checktNumberOpt.get().isPrime();
        } else {
            isPrime = PrimeChecker.checkIfPrimeNumber(number);
            this.checktNumberRepository.save(new ChecktNumber(number, isPrime));
        }
        return ResponseEntity.ok(isPrime);
    }

    @GetMapping(value = "/getPrimeNumbers")
    public ResponseEntity<List<ChecktNumber>> getPrimeNumbers() {
        List<ChecktNumber> primeNumbers = this.checktNumberRepository.findByIsPrime(true);
        return ResponseEntity.ok(primeNumbers);
    }
}
