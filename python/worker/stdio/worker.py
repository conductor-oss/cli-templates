#!/usr/bin/env python3
import sys
import json

# Read task from stdin
task = json.load(sys.stdin)

# Get input parameters
input_data = task.get('inputData', {})
name = input_data.get('name', 'World')

# Process the task
message = f"Hello {name}"

# Return result to stdout
result = {
    "status": "COMPLETED",
    "output": {
        "message": message
    },
    "logs": [f"Processed greeting for {name}"]
}

print(json.dumps(result))