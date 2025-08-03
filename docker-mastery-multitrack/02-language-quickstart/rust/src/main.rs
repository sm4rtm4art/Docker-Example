/*!
 * Rust Task Management API
 * Docker Learning Path - Rust Track
 *
 * A blazingly fast REST API for task management that demonstrates Docker concepts.
 */

use actix_web::{web, App, HttpServer, HttpResponse, Result, middleware::Logger};
use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use uuid::Uuid;
use chrono::{DateTime, Utc};
use std::collections::HashMap;
use log::info;

// Task models
#[derive(Debug, Clone, Serialize, Deserialize)]
struct Task {
    id: String,
    title: String,
    description: String,
    completed: bool,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
struct TaskCreate {
    title: String,
    description: String,
}

#[derive(Debug, Deserialize)]
struct TaskUpdate {
    title: Option<String>,
    description: Option<String>,
    completed: Option<bool>,
}

// Application state
type TaskStorage = Mutex<HashMap<String, Task>>;

// Health check endpoint
async fn health_check() -> Result<HttpResponse> {
    let health_response = serde_json::json!({
        "status": "healthy",
        "version": "1.0.0",
        "timestamp": Utc::now().to_rfc3339(),
        "environment": std::env::var("ENV").unwrap_or_else(|_| "production".to_string()),
        "database": "connected"
    });

    Ok(HttpResponse::Ok().json(health_response))
}

// List all tasks
async fn list_tasks(data: web::Data<TaskStorage>) -> Result<HttpResponse> {
    let tasks = data.lock().unwrap();
    let task_list: Vec<&Task> = tasks.values().collect();

    info!("Fetching {} tasks", task_list.len());

    let response = serde_json::json!({
        "tasks": task_list,
        "total": task_list.len()
    });

    Ok(HttpResponse::Ok().json(response))
}

// Create new task
async fn create_task(
    task_data: web::Json<TaskCreate>,
    data: web::Data<TaskStorage>,
) -> Result<HttpResponse> {
    let mut tasks = data.lock().unwrap();

    let task = Task {
        id: Uuid::new_v4().to_string(),
        title: task_data.title.clone(),
        description: task_data.description.clone(),
        completed: false,
        created_at: Utc::now(),
        updated_at: Utc::now(),
    };

    info!("Created task: {} - {}", task.id, task.title);
    tasks.insert(task.id.clone(), task.clone());

    Ok(HttpResponse::Created().json(task))
}

// Get specific task
async fn get_task(
    path: web::Path<String>,
    data: web::Data<TaskStorage>,
) -> Result<HttpResponse> {
    let tasks = data.lock().unwrap();
    let task_id = path.into_inner();

    match tasks.get(&task_id) {
        Some(task) => Ok(HttpResponse::Ok().json(task)),
        None => {
            info!("Task not found: {}", task_id);
            Ok(HttpResponse::NotFound().json(serde_json::json!({
                "error": format!("Task with id {} not found", task_id)
            })))
        }
    }
}

// Update task
async fn update_task(
    path: web::Path<String>,
    task_update: web::Json<TaskUpdate>,
    data: web::Data<TaskStorage>,
) -> Result<HttpResponse> {
    let mut tasks = data.lock().unwrap();
    let task_id = path.into_inner();

    match tasks.get_mut(&task_id) {
        Some(task) => {
            if let Some(title) = &task_update.title {
                task.title = title.clone();
            }
            if let Some(description) = &task_update.description {
                task.description = description.clone();
            }
            if let Some(completed) = task_update.completed {
                task.completed = completed;
            }
            task.updated_at = Utc::now();

            info!("Updated task: {} - {}", task.id, task.title);
            Ok(HttpResponse::Ok().json(task.clone()))
        }
        None => {
            info!("Task not found for update: {}", task_id);
            Ok(HttpResponse::NotFound().json(serde_json::json!({
                "error": format!("Task with id {} not found", task_id)
            })))
        }
    }
}

// Delete task
async fn delete_task(
    path: web::Path<String>,
    data: web::Data<TaskStorage>,
) -> Result<HttpResponse> {
    let mut tasks = data.lock().unwrap();
    let task_id = path.into_inner();

    match tasks.remove(&task_id) {
        Some(task) => {
            info!("Deleted task: {} - {}", task.id, task.title);
            Ok(HttpResponse::NoContent().finish())
        }
        None => {
            info!("Task not found for deletion: {}", task_id);
            Ok(HttpResponse::NotFound().json(serde_json::json!({
                "error": format!("Task with id {} not found", task_id)
            })))
        }
    }
}

// Metrics endpoint
async fn metrics(data: web::Data<TaskStorage>) -> Result<HttpResponse> {
    let tasks = data.lock().unwrap();
    let total_tasks = tasks.len();
    let completed_tasks = tasks.values().filter(|t| t.completed).count();
    let pending_tasks = total_tasks - completed_tasks;

    let metrics_data = format!(
        "# HELP tasks_total Total number of tasks\n\
         # TYPE tasks_total counter\n\
         tasks_total {}\n\n\
         # HELP tasks_completed Number of completed tasks\n\
         # TYPE tasks_completed gauge\n\
         tasks_completed {}\n\n\
         # HELP tasks_pending Number of pending tasks\n\
         # TYPE tasks_pending gauge\n\
         tasks_pending {}\n",
        total_tasks, completed_tasks, pending_tasks
    );

    Ok(HttpResponse::Ok()
        .content_type("text/plain")
        .body(metrics_data))
}

// Root endpoint
async fn root() -> Result<HttpResponse> {
    let response = serde_json::json!({
        "message": "Task Management API - Rust Edition",
        "version": "1.0.0",
        "docker_track": "rust",
        "endpoints": {
            "health": "/health",
            "tasks": "/api/tasks",
            "metrics": "/metrics"
        },
        "quick_start": {
            "create_task": "POST /api/tasks",
            "list_tasks": "GET /api/tasks",
            "performance": "Blazingly fast! 🚀"
        }
    });

    Ok(HttpResponse::Ok().json(response))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Initialize logger
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    // Initialize task storage
    let task_storage = web::Data::new(TaskStorage::new(HashMap::new()));

    info!("Starting Rust Task API server on 0.0.0.0:8080");

    HttpServer::new(move || {
        App::new()
            .app_data(task_storage.clone())
            .wrap(Logger::default())
            .route("/", web::get().to(root))
            .route("/health", web::get().to(health_check))
            .route("/metrics", web::get().to(metrics))
            .service(
                web::scope("/api")
                    .route("/tasks", web::get().to(list_tasks))
                    .route("/tasks", web::post().to(create_task))
                    .route("/tasks/{id}", web::get().to(get_task))
                    .route("/tasks/{id}", web::put().to(update_task))
                    .route("/tasks/{id}", web::delete().to(delete_task))
            )
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}
