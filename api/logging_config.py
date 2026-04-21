import json
import logging
import sys
from datetime import datetime


class GCPJsonFormatter(logging.Formatter):
    """
    SRE Best Practice: Structured Logging.
    This formatter converts logs into a JSON format that Google Cloud Logging
    can parse automatically into its "JsonPayload" field.
    """

    def format(self, record):
        log_record = {
            "severity": record.levelname,
            "message": record.getMessage(),
            "timestamp": datetime.fromtimestamp(record.created).isoformat() + "Z",
            "logging.googleapis.com/sourceLocation": {
                "file": record.pathname,
                "line": record.lineno,
                "function": record.funcName,
            },
            "logger": record.name,
            "module": record.module,
        }

        # Add extra fields if they exist in the record
        if hasattr(record, "project_id"):
            log_record["project_id"] = record.project_id

        return json.dumps(log_record)


def setup_gcp_logging():
    """Configures the root logger to use JSON formatting for stdout."""
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(GCPJsonFormatter())

    root_logger = logging.getLogger()
    root_logger.handlers = [handler]
    root_logger.setLevel(logging.INFO)
