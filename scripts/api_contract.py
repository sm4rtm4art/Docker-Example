#!/usr/bin/env python3
"""Black-box tests shared by all language tracks; only Python's stdlib is needed."""
import argparse
import json
import re
import unittest
from datetime import datetime
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen
from uuid import UUID


class Contract(unittest.TestCase):
    base_url = "http://127.0.0.1:8080"

    def request(self, method, path, body=None):
        data = None if body is None else json.dumps(body).encode()
        request = Request(self.base_url + path, data=data, method=method,
                          headers={"Content-Type": "application/json"})
        try:
            response = urlopen(request, timeout=10)
        except HTTPError as error:
            response = error
        with response:
            raw = response.read().decode()
            content_type = response.headers.get("Content-Type", "")
            result = json.loads(raw) if raw and "application/json" in content_type else raw
            return response.status, result, content_type

    def setUp(self):
        self.created = []

    def tearDown(self):
        for task_id in self.created:
            self.request("DELETE", f"/api/tasks/{task_id}")

    def create(self, **fields):
        status, task, _ = self.request("POST", "/api/tasks", {"title": "Learn Docker", **fields})
        self.assertEqual(status, 201, task)
        self.created.append(task["id"])
        return task

    def gauges(self):
        status, body, content_type = self.request("GET", "/metrics")
        self.assertEqual(status, 200)
        self.assertIn("text/plain", content_type)
        self.assertIn("version=0.0.4", content_type)
        values = {}
        for name in ("task_count", "task_completed_count", "task_pending_count"):
            self.assertIn(f"# TYPE {name} gauge", body)
            match = re.search(rf"^{name} (\d+)$", body, re.M)
            self.assertIsNotNone(match, body)
            values[name] = int(match[1])
        self.assertEqual(values["task_count"], values["task_completed_count"] + values["task_pending_count"])
        return values

    def test_health_reports_real_storage(self):
        status, body, _ = self.request("GET", "/health")
        self.assertEqual(status, 200)
        self.assertEqual(body["status"], "healthy")
        self.assertEqual(body["storage"], "memory")
        self.assertEqual(body["version"], "1.0.0")
        self.assertNotIn("database", body)

    def test_crud_and_schema(self):
        task = self.create(description="Understand the build context")
        self.assertEqual(str(UUID(task["id"])), task["id"])
        self.assertEqual(task["completed"], False)
        for field in ("created_at", "updated_at"):
            self.assertIsNotNone(datetime.fromisoformat(task[field].replace("Z", "+00:00")).tzinfo)
        status, listing, _ = self.request("GET", "/api/tasks")
        self.assertEqual(status, 200)
        self.assertEqual(listing["total"], len(listing["tasks"]))
        self.assertIn(task, listing["tasks"])
        path = f"/api/tasks/{task['id']}"
        self.assertEqual(self.request("GET", path)[:2], (200, task))
        replacement = {"title": "Apply Docker", "description": "Done", "completed": True}
        status, updated, _ = self.request("PUT", path, replacement)
        self.assertEqual(status, 200)
        for key, value in replacement.items():
            self.assertEqual(updated[key], value)
        self.assertEqual(updated["id"], task["id"])
        self.assertEqual(updated["created_at"], task["created_at"])
        self.assertGreaterEqual(datetime.fromisoformat(updated["updated_at"].replace("Z", "+00:00")),
                                datetime.fromisoformat(task["updated_at"].replace("Z", "+00:00")))
        status, body, _ = self.request("DELETE", path)
        self.assertEqual((status, body), (204, ""))
        self.assertEqual(self.request("GET", path)[0], 404)

    def test_optional_description(self):
        self.assertEqual(self.create()["description"], "")

    def test_invalid_input_is_rejected_without_creating_tasks(self):
        before = self.request("GET", "/api/tasks")[1]["total"]
        for body in ({}, {"title": ""}, {"title": "   "}, {"title": "x" * 256},
                     {"title": "valid", "description": "x" * 2001}):
            with self.subTest(body=str(body)[:60]):
                self.assertIn(self.request("POST", "/api/tasks", body)[0], (400, 422))
        self.assertEqual(self.request("GET", "/api/tasks")[1]["total"], before)

    def test_put_requires_a_complete_replacement(self):
        task = self.create()
        path = f"/api/tasks/{task['id']}"
        self.assertIn(self.request("PUT", path, {"completed": True})[0], (400, 422))
        self.assertIn(self.request("PUT", path, {"title": "missing completed"})[0], (400, 422))
        self.assertEqual(self.request("GET", path)[1], task)

    def test_missing_tasks(self):
        path = "/api/tasks/00000000-0000-0000-0000-000000000000"
        for method, body in (("GET", None), ("DELETE", None),
                             ("PUT", {"title": "missing", "completed": False})):
            self.assertEqual(self.request(method, path, body)[0], 404)

    def test_metrics_follow_creation_completion_and_deletion(self):
        before = self.gauges()
        task = self.create()
        self.assertEqual(self.gauges()["task_count"], before["task_count"] + 1)
        path = f"/api/tasks/{task['id']}"
        self.assertEqual(self.request("PUT", path, {"title": task["title"], "completed": True})[0], 200)
        self.assertEqual(self.gauges()["task_completed_count"], before["task_completed_count"] + 1)
        self.assertEqual(self.request("DELETE", path)[0], 204)
        self.assertEqual(self.gauges(), before)


def run(base_url, report=None):
    Contract.base_url = base_url.rstrip("/")
    result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(Contract))
    if report:
        path = Path(report)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps({"tests": result.testsRun, "failures": len(result.failures),
                                    "errors": len(result.errors), "passed": result.wasSuccessful(),
                                    "details": [(str(test), error) for test, error in result.failures + result.errors]}, indent=2) + "\n")
    return result.wasSuccessful()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", default=Contract.base_url)
    parser.add_argument("--report")
    args = parser.parse_args()
    raise SystemExit(0 if run(args.base_url, args.report) else 1)
