package com.example.dockerdemo.controller;

import com.example.dockerdemo.model.Task;
import com.example.dockerdemo.service.TaskService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {
    private final TaskService service;
    public TaskController(TaskService service) { this.service = service; }
    public record Create(@NotBlank @Size(max=255) String title, @Size(max=2000) String description) {}
    public record Replace(@NotBlank @Size(max=255) String title, @Size(max=2000) String description,
                          @NotNull Boolean completed) {}
    private static String description(String value) { return value == null ? "" : value; }
    @GetMapping
    public Map<String, Object> list() {
        var tasks = service.getAllTasks();
        return Map.of("tasks", tasks, "total", tasks.size());
    }
    @GetMapping("/{id}")
    public ResponseEntity<Task> get(@PathVariable String id) {
        return service.getTaskById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }
    @PostMapping
    public ResponseEntity<Task> create(@Valid @RequestBody Create body) {
        return ResponseEntity.status(201).body(service.createTask(body.title(), description(body.description())));
    }
    @PutMapping("/{id}")
    public ResponseEntity<Task> replace(@PathVariable String id, @Valid @RequestBody Replace body) {
        return service.replaceTask(id, body.title(), description(body.description()), body.completed())
            .map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        return service.deleteTask(id) ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }
}
