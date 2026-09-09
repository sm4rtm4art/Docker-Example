package com.example.dockerdemo.service;

import com.example.dockerdemo.model.Task;
import org.springframework.stereotype.Service;
import java.time.Instant;
import java.util.*;

@Service
public class TaskService {
    private final Map<String, Task> tasks = new HashMap<>();

    public synchronized List<Task> getAllTasks() { return List.copyOf(tasks.values()); }
    public synchronized Optional<Task> getTaskById(String id) { return Optional.ofNullable(tasks.get(id)); }
    public synchronized Task createTask(String title, String description) {
        Instant now = Instant.now();
        Task task = new Task(UUID.randomUUID().toString(), title, description, false, now, now);
        tasks.put(task.id(), task);
        return task;
    }
    public synchronized Optional<Task> replaceTask(String id, String title, String description, boolean completed) {
        Task previous = tasks.get(id);
        if (previous == null) return Optional.empty();
        Task task = new Task(id, title, description, completed, previous.createdAt(), Instant.now());
        tasks.put(id, task);
        return Optional.of(task);
    }
    public synchronized boolean deleteTask(String id) { return tasks.remove(id) != null; }
}
