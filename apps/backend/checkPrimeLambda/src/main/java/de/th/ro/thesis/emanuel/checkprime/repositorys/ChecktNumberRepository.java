package de.th.ro.thesis.emanuel.checkprime.repositorys;

import java.util.List;
import org.springframework.data.repository.CrudRepository;
import de.th.ro.thesis.emanuel.checkprime.entitys.ChecktNumber;

public interface ChecktNumberRepository extends CrudRepository <ChecktNumber, Long>{
    List<ChecktNumber> findByIsPrime(boolean isPrime);
}
