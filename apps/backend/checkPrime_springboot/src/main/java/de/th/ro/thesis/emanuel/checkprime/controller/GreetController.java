package de.th.ro.thesis.emanuel.checkprime.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import de.th.ro.thesis.emanuel.checkprime.dtos.GreetDTO;
import java.util.List;

@RestController
public class GreetController {

    @GetMapping(value = "/greeting", produces = "application/json")
    public GreetDTO greeting(@RequestParam(required = false, defaultValue = "World") String name) {
        return new GreetDTO(1, "Hello, " + name + "!");
    }
}
