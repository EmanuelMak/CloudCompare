package de.th.ro.thesis.emanuel.cloudCompare.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import de.th.ro.thesis.emanuel.cloudCompare.model.GreetModel;

@RestController
public class GreetController {

    @GetMapping(value = "/greeting", produces = "application/json")
    public  GreetModel greeting(@RequestParam(required = false, defaultValue = "World") String name) {
        return new GreetModel(1, "Hello, " + name + "!");
    }
}
