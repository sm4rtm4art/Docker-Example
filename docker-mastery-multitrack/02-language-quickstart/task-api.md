# Task API reference

All three tracks implement a small task service listening on container port 8080. It uses process memory and has no authentication. Use a local learning instance. Restarting the process clears every task; multiple instances have independent data.

## Endpoints

| Method | Path | Successful response |
| --- | --- | --- |
| GET | `/` | Navigation information |
| GET | `/health` | 200; status, version and storage |
| GET | `/api/tasks` | 200; `{"tasks": [], "total": 0}` for an empty store |
| POST | `/api/tasks` | 201; the created task |
| GET | `/api/tasks/{id}` | 200; the task |
| PUT | `/api/tasks/{id}` | 200; the replaced task |
| DELETE | `/api/tasks/{id}` | 204; no response body |
| GET | `/metrics` | 200; Prometheus text exposition |

A task contains a UUID `id`, `title`, `description`, boolean `completed`, and UTC timestamps `created_at` and `updated_at`.

POST requires a nonblank `title` of at most 255 characters. An omitted `description` becomes an empty string; its maximum length is 2,000 characters. New tasks start with `completed: false`.

```bash
curl --fail -H 'Content-Type: application/json'   -d '{"title":"Build an image","description":"Use the Python track"}'   http://127.0.0.1:8080/api/tasks
```

Copy the returned ID into the next request:

```bash
TASK_ID=replace-with-returned-id
curl --fail -X PUT -H 'Content-Type: application/json'   -d '{"title":"Build an image","completed":true}'   "http://127.0.0.1:8080/api/tasks/$TASK_ID"
```

PUT replaces the editable fields: `title` and `completed` are required and an omitted description becomes empty. It preserves `id` and `created_at` and updates `updated_at`. It is not a partial update.

Unknown IDs return 404. Invalid inputs return 400 or 422, with framework-specific error bodies. Type coercion, Unicode length counting and null handling can differ between frameworks; consult the implementation when exploring those edge cases. Python also serves interactive API documentation at `/docs`.

## Health and metrics

`/health` returns `{"status":"healthy","version":"1.0.0","storage":"memory"}`. It does not check a database: the API has no database connection.

`/metrics` returns text, including `task_count`, `task_completed_count` and `task_pending_count`. These are gauges: deletion and completion changes can decrease them. Total tasks equal completed plus pending tasks. Prometheus supplies the scrape-success metric `up` separately.

## Automated checks

From the repository root, against a running local instance:

```bash
python3 scripts/api_contract.py --base-url http://127.0.0.1:8080 --report reports/api.json
```

The seven tests cover health, CRUD, field validation, replacement semantics, missing IDs and metrics. They create and delete their own tasks. Avoid concurrent edits while running them because some assertions compare counts.
