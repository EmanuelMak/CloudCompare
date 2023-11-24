package de.th.ro.thesis.emanuel.checkprime.entitys;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.persistence.Id;

@Entity
@Table(name = "employees")
public class ChecktNumber {
    @Id
    private Long number;

    private boolean isPrime;

    protected ChecktNumber() {
    }
    
    public ChecktNumber(long Number, boolean isPrime) {
        this.number = Number;
        this.isPrime = isPrime;
    }

    public Long getNumber() {
        return number;
    }

    public boolean isPrime() {
        return isPrime;
    }
}
