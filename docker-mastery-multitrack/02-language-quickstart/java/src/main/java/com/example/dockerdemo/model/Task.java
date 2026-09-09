package com.example.dockerdemo.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.Instant;

public record Task(String id, String title, String description, boolean completed,
                   @JsonProperty("created_at") Instant createdAt,
                   @JsonProperty("updated_at") Instant updatedAt) {}
