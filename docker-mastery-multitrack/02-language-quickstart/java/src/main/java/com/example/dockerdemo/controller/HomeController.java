package com.example.dockerdemo.controller;

import com.example.dockerdemo.service.TaskService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;

@RestController
public class HomeController {
    private final TaskService service;
    public HomeController(TaskService service) { this.service = service; }
    @GetMapping("/")
    public Map<String, Object> root() {
        return Map.of("message", "Task API", "version", "1.0.0", "docker_track", "java",
            "endpoints", Map.of("health", "/health", "tasks", "/api/tasks", "metrics", "/metrics"));
    }
    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "healthy", "version", "1.0.0", "storage", "memory");
    }
    @GetMapping(value="/metrics", produces="text/plain; version=0.0.4; charset=utf-8")
    public String metrics() {
        var tasks = service.getAllTasks();
        long completed = tasks.stream().filter(t -> t.completed()).count();
        return "# TYPE task_count gauge\ntask_count " + tasks.size()
            + "\n# TYPE task_completed_count gauge\ntask_completed_count " + completed
            + "\n# TYPE task_pending_count gauge\ntask_pending_count " + (tasks.size()-completed) + "\n";
    }
}
