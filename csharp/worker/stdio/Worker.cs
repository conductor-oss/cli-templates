using System.Text.Json;
using System.Text.Json.Nodes;

// Read task from stdin
var taskJson = JsonNode.Parse(Console.In.ReadToEnd());

// Get input parameters
var inputData = taskJson?["inputData"];
var name = inputData?["name"]?.GetValue<string>() ?? "World";

// Process the task
var message = $"Hello {name}";

// Return result to stdout
var result = new
{
    status = "COMPLETED",
    output = new { message },
    logs = new[] { $"Processed greeting for {name}" }
};

Console.WriteLine(JsonSerializer.Serialize(result));
