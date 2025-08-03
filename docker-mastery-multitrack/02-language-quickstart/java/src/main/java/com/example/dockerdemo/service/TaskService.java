package com.example.dockerdemo.service;

import com.example.dockerdemo.model.Task;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class TaskService {

    private final ConcurrentHashMap<Long, Task> tasks = new ConcurrentHashMap<>();
    private final AtomicLong idCounter = new AtomicLong();

    public TaskService() {
        // Initialize with some sample data
        createTask("Learn Docker", "Understand containerization basics");
        createTask("Setup Spring Boot", "Create REST API with Spring Boot");
        createTask("Connect to Database", "Learn Docker Compose with MariaDB");
    }

    public List<Task> getAllTasks() {
        return new ArrayList<>(tasks.values());
    }

    public Optional<Task> getTaskById(Long id) {
        return Optional.ofNullable(tasks.get(id));
    }

    public Task createTask(String title, String description) {
        Task task = Task.builder()
                .id(idCounter.incrementAndGet())
                .title(title)
                .description(description)
                .completed(false)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        tasks.put(task.getId(), task);
        return task;
    }

    public Optional<Task> updateTask(Long id, Task taskUpdate) {
        return Optional.ofNullable(tasks.computeIfPresent(id, (key, existingTask) -> {
            existingTask.setTitle(taskUpdate.getTitle());
            existingTask.setDescription(taskUpdate.getDescription());
            existingTask.setCompleted(taskUpdate.isCompleted());
            existingTask.setUpdatedAt(LocalDateTime.now());
            return existingTask;
        }));
    }

    public boolean deleteTask(Long id) {
        return tasks.remove(id) != null;
    }

    public long getTaskCount() {
        return tasks.size();
    }
}
