package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @RestController
    static class HelloController {
        @GetMapping("/api/hello")
        public String hello() {
            return "Hello from MSA Backend! (Updated: " + java.time.LocalDateTime.now() + ")";
        }
    }
}
