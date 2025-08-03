"""
FastAPI Task Management API
Docker Learning Path - Python Track

A simple REST API for task management that demonstrates Docker concepts.
"""

import logging
import os
from datetime import datetime
from typing import List, Optional
from uuid import uuid4

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("task-api")

# Initialize FastAPI app
app = FastAPI(
    title="Task Management API",
    description="Docker Learning Path - Python Edition",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)


# Task model
class Task(BaseModel):
    id: str
    title: str
    description: str
    completed: bool = False
    created_at: datetime
    updated_at: datetime


class TaskCreate(BaseModel):
    title: str
    description: str


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    completed: Optional[bool] = None


# In-memory storage (Module 04 will add PostgreSQL)
tasks_db: List[Task] = []


# Health check endpoint
@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint for Docker health checks and load balancers"""
    return {
        "status": "healthy",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "environment": os.getenv("ENV", "production"),
        "database": "connected",  # Will be dynamic in Module 04
    }


# Task endpoints
@app.get("/api/tasks", response_model=dict, tags=["Tasks"])
async def list_tasks():
    """List all tasks"""
    logger.info(f"Fetching {len(tasks_db)} tasks")
    return {"tasks": tasks_db, "total": len(tasks_db)}


@app.post(
    "/api/tasks",
    response_model=Task,
    status_code=status.HTTP_201_CREATED,
    tags=["Tasks"],
)
async def create_task(task_data: TaskCreate):
    """Create a new task"""
    task = Task(
        id=str(uuid4()),
        title=task_data.title,
        description=task_data.description,
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )
    tasks_db.append(task)
    logger.info(f"Created task: {task.id} - {task.title}")
    return task


@app.get("/api/tasks/{task_id}", response_model=Task, tags=["Tasks"])
async def get_task(task_id: str):
    """Get a specific task by ID"""
    task = next((t for t in tasks_db if t.id == task_id), None)
    if not task:
        logger.warning(f"Task not found: {task_id}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Task with id {task_id} not found",
        )
    return task


@app.put("/api/tasks/{task_id}", response_model=Task, tags=["Tasks"])
async def update_task(task_id: str, task_update: TaskUpdate):
    """Update a specific task"""
    task = next((t for t in tasks_db if t.id == task_id), None)
    if not task:
        logger.warning(f"Task not found for update: {task_id}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Task with id {task_id} not found",
        )

    # Update fields
    if task_update.title is not None:
        task.title = task_update.title
    if task_update.description is not None:
        task.description = task_update.description
    if task_update.completed is not None:
        task.completed = task_update.completed

    task.updated_at = datetime.now()
    logger.info(f"Updated task: {task_id} - {task.title}")
    return task


@app.delete(
    "/api/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Tasks"]
)
async def delete_task(task_id: str):
    """Delete a specific task"""
    task_index = next((i for i, t in enumerate(tasks_db) if t.id == task_id), None)
    if task_index is None:
        logger.warning(f"Task not found for deletion: {task_id}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Task with id {task_id} not found",
        )

    deleted_task = tasks_db.pop(task_index)
    logger.info(f"Deleted task: {task_id} - {deleted_task.title}")


# Metrics endpoint (Module 08 will expand this)
@app.get("/metrics", tags=["Monitoring"])
async def metrics():
    """Prometheus metrics endpoint"""
    completed_tasks = len([t for t in tasks_db if t.completed])
    pending_tasks = len([t for t in tasks_db if not t.completed])

    metrics_data = f"""# HELP tasks_total Total number of tasks
# TYPE tasks_total counter
tasks_total {len(tasks_db)}

# HELP tasks_completed Number of completed tasks
# TYPE tasks_completed gauge
tasks_completed {completed_tasks}

# HELP tasks_pending Number of pending tasks
# TYPE tasks_pending gauge
tasks_pending {pending_tasks}
"""
    return metrics_data


# Root endpoint with API navigation
@app.get("/", tags=["Root"])
async def root():
    """API root endpoint with navigation"""
    return {
        "message": "Task Management API - Python Edition",
        "version": "1.0.0",
        "docker_track": "python",
        "endpoints": {
            "health": "/health",
            "docs": "/docs",
            "tasks": "/api/tasks",
            "metrics": "/metrics",
        },
        "quick_start": {
            "create_task": "POST /api/tasks",
            "list_tasks": "GET /api/tasks",
            "view_docs": "GET /docs",
        },
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8080)
