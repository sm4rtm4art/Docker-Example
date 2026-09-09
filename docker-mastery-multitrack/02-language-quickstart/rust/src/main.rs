//! Single-process, in-memory teaching API. Restarting loses all tasks.
use actix_web::{error, middleware::Logger, web, App, HttpResponse, HttpServer, Result};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, sync::{Mutex, MutexGuard}};
use uuid::Uuid;

#[derive(Clone, Serialize)]
struct Task {
    id: String,
    title: String,
    description: String,
    completed: bool,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct TaskCreate {
    title: String,
    #[serde(default)]
    description: String,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct TaskReplace {
    title: String,
    #[serde(default)]
    description: String,
    completed: bool,
}

type Store = Mutex<HashMap<String, Task>>;
fn lock(data: &web::Data<Store>) -> Result<MutexGuard<'_, HashMap<String, Task>>> {
    data.lock().map_err(|_| error::ErrorInternalServerError("Storage unavailable"))
}
fn validate(title: &str, description: &str) -> Result<()> {
    if title.trim().is_empty() || title.chars().count() > 255 || description.chars().count() > 2000 {
        return Err(error::ErrorBadRequest("Invalid title or description length"));
    }
    Ok(())
}
async fn health() -> HttpResponse {
    HttpResponse::Ok().json(serde_json::json!({"status":"healthy", "version":"1.0.0", "storage":"memory"}))
}
async fn list(data: web::Data<Store>) -> Result<HttpResponse> {
    let tasks = lock(&data)?;
    Ok(HttpResponse::Ok().json(serde_json::json!({"tasks": tasks.values().collect::<Vec<_>>(), "total": tasks.len()})))
}
async fn create(body: web::Json<TaskCreate>, data: web::Data<Store>) -> Result<HttpResponse> {
    validate(&body.title, &body.description)?;
    let now = Utc::now();
    let task = Task { id: Uuid::new_v4().to_string(), title: body.title.clone(),
        description: body.description.clone(), completed: false, created_at: now, updated_at: now };
    lock(&data)?.insert(task.id.clone(), task.clone());
    Ok(HttpResponse::Created().json(task))
}
async fn get(id: web::Path<String>, data: web::Data<Store>) -> Result<HttpResponse> {
    let tasks = lock(&data)?;
    let task = tasks.get(id.as_str()).ok_or_else(|| error::ErrorNotFound("Task not found"))?;
    Ok(HttpResponse::Ok().json(task))
}
async fn replace(id: web::Path<String>, body: web::Json<TaskReplace>, data: web::Data<Store>) -> Result<HttpResponse> {
    validate(&body.title, &body.description)?;
    let mut tasks = lock(&data)?;
    let task = tasks.get_mut(id.as_str()).ok_or_else(|| error::ErrorNotFound("Task not found"))?;
    task.title = body.title.clone();
    task.description = body.description.clone();
    task.completed = body.completed;
    task.updated_at = Utc::now();
    Ok(HttpResponse::Ok().json(task.clone()))
}
async fn delete(id: web::Path<String>, data: web::Data<Store>) -> Result<HttpResponse> {
    lock(&data)?.remove(id.as_str()).ok_or_else(|| error::ErrorNotFound("Task not found"))?;
    Ok(HttpResponse::NoContent().finish())
}
async fn metrics(data: web::Data<Store>) -> Result<HttpResponse> {
    let tasks = lock(&data)?;
    let complete = tasks.values().filter(|t| t.completed).count();
    let body = format!("# TYPE task_count gauge\ntask_count {}\n# TYPE task_completed_count gauge\ntask_completed_count {}\n# TYPE task_pending_count gauge\ntask_pending_count {}\n", tasks.len(), complete, tasks.len()-complete);
    Ok(HttpResponse::Ok().content_type("text/plain; version=0.0.4; charset=utf-8").body(body))
}
async fn root() -> HttpResponse {
    HttpResponse::Ok().json(serde_json::json!({"message":"Task API", "version":"1.0.0", "docker_track":"rust", "endpoints":{"health":"/health", "tasks":"/api/tasks", "metrics":"/metrics"}}))
}
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));
    let data = web::Data::new(Store::new(HashMap::new()));
    HttpServer::new(move || App::new().app_data(data.clone()).wrap(Logger::default())
        .route("/", web::get().to(root))
        .route("/health", web::get().to(health))
        .route("/metrics", web::get().to(metrics))
        .route("/api/tasks", web::get().to(list))
        .route("/api/tasks", web::post().to(create))
        .route("/api/tasks/{id}", web::get().to(get))
        .route("/api/tasks/{id}", web::put().to(replace))
        .route("/api/tasks/{id}", web::delete().to(delete)))
        .shutdown_timeout(10).bind(("0.0.0.0", 8080))?.run().await
}
