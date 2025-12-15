package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type Task struct {
	InputData map[string]interface{} `json:"inputData"`
}

type Result struct {
	Status string                 `json:"status"`
	Output map[string]interface{} `json:"output"`
	Logs   []string               `json:"logs"`
}

func main() {
	// Read task from stdin
	var task Task
	decoder := json.NewDecoder(os.Stdin)
	if err := decoder.Decode(&task); err != nil {
		fmt.Fprintf(os.Stderr, "Error decoding task: %v\n", err)
		os.Exit(1)
	}

	// Get input parameters
	name := "World"
	if task.InputData != nil {
		if n, ok := task.InputData["name"].(string); ok {
			name = n
		}
	}

	// Process the task
	message := fmt.Sprintf("Hello %s", name)

	// Return result to stdout
	result := Result{
		Status: "COMPLETED",
		Output: map[string]interface{}{
			"message": message,
		},
		Logs: []string{fmt.Sprintf("Processed greeting for %s", name)},
	}

	encoder := json.NewEncoder(os.Stdout)
	if err := encoder.Encode(result); err != nil {
		fmt.Fprintf(os.Stderr, "Error encoding result: %v\n", err)
		os.Exit(1)
	}
}
