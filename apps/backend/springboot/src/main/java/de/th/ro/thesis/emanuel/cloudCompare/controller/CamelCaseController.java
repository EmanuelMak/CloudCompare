package de.th.ro.thesis.emanuel.cloudCompare.controller;

import com.th.ro.emanuel.thesis.camelcase.CamelCaseConverter;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CamelCaseController {

    @GetMapping(value = "/convertToCamelCase", produces = "text/plain")
    public String convertToCamelCase(@RequestParam String text) {
        return CamelCaseConverter.toCamelCase(text);
    }
}