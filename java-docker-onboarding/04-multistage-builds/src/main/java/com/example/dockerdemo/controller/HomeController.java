package com.example.dockerdemo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
public class HomeController {
    
    @Value("${spring.application.name:docker-demo}")
    private String applicationName;
    
    @GetMapping("/")
    public Map<String, Object> home() {
        return Map.of(
            "message", "Welcome to Docker Demo API!",
            "application", applicationName,
            "version", "0.0.1",
            "timestamp", LocalDateTime.now(),
            "endpoints", Map.of(
                "tasks", "/api/tasks",
                "health", "/actuator/health",
                "info", "/actuator/info"
            )
        );
    }
}