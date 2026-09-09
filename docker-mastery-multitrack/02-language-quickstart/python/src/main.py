"""Single-process, in-memory teaching API. Restarting loses all tasks."""
from datetime import datetime, timezone
from uuid import uuid4

from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel, ConfigDict, Field, field_validator

app = FastAPI(title="Task API", version="1.0.0")


class TaskCreate(BaseModel):
    model_config = ConfigDict(strict=True, extra="forbid")
    title: str = Field(min_length=1, max_length=255)
    description: str = Field(default="", max_length=2000)

    @field_validator("title")
    @classmethod
    def nonblank(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("title must not be blank")
        return value


class TaskReplace(TaskCreate):
    completed: bool


class Task(TaskReplace):
    id: str
    created_at: datetime
    updated_at: datetime


tasks: dict[str, Task] = {}


@app.get("/health")
async def health():
    return {"status": "healthy", "version": "1.0.0", "storage": "memory"}


@app.get("/api/tasks")
async def list_tasks():
    return {"tasks": list(tasks.values()), "total": len(tasks)}


@app.post("/api/tasks", status_code=201)
async def create_task(body: TaskCreate):
    now = datetime.now(timezone.utc)
    task = Task(**body.model_dump(), completed=False, id=str(uuid4()),
                created_at=now, updated_at=now)
    tasks[task.id] = task
    return task


def lookup(task_id: str) -> Task:
    if task_id not in tasks:
        raise HTTPException(404, "Task not found")
    return tasks[task_id]


@app.get("/api/tasks/{task_id}")
async def get_task(task_id: str):
    return lookup(task_id)


@app.put("/api/tasks/{task_id}")
async def replace_task(task_id: str, body: TaskReplace):
    previous = lookup(task_id)
    task = Task(**body.model_dump(), id=task_id, created_at=previous.created_at,
                updated_at=datetime.now(timezone.utc))
    tasks[task_id] = task
    return task


@app.delete("/api/tasks/{task_id}", status_code=204)
async def delete_task(task_id: str):
    lookup(task_id)
    del tasks[task_id]
    return Response(status_code=204)


@app.get("/metrics")
async def metrics():
    completed = sum(task.completed for task in tasks.values())
    values = {"task_count": len(tasks), "task_completed_count": completed,
              "task_pending_count": len(tasks) - completed}
    body = "".join(f"# TYPE {name} gauge\n{name} {value}\n"
                   for name, value in values.items())
    return Response(body, media_type="text/plain; version=0.0.4")


@app.get("/")
async def root():
    return {"message": "Task API", "version": "1.0.0", "docker_track": "python",
            "endpoints": {"health": "/health", "tasks": "/api/tasks", "metrics": "/metrics"}}
