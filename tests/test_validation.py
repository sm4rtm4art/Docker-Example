"""Regression checks for transient failures observed while starting real containers."""
import io
import sys
import unittest
from http.client import RemoteDisconnected
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from validate import wait_json


class StartupWaitTests(unittest.TestCase):
    def test_transient_startup_errors_are_retried(self):
        for error in (ConnectionResetError("starting"), RemoteDisconnected("starting")):
            with self.subTest(error=type(error).__name__):
                responses = [error, io.BytesIO(b'{"status":"healthy"}')]
                with patch("validate.urlopen", side_effect=responses), patch("validate.time.sleep"):
                    self.assertEqual(wait_json("http://127.0.0.1/health"), {"status": "healthy"})

    def test_timeout_is_a_failure(self):
        with patch("validate.time.monotonic", side_effect=[0, 100]):
            with self.assertRaisesRegex(RuntimeError, "Timed out"):
                wait_json("http://127.0.0.1/health", timeout=2)
