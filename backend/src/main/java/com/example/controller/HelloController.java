package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
public class HelloController {
    
    @GetMapping("/api/hello")
    public String hello() {
        LocalDateTime now = LocalDateTime.now();
        String formattedTime = now.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        return "Hello from MSA Backend! CI/CD Test - " + formattedTime;
    }
}
