using Conductor.Client.Authentication;
using Conductor.Client.Worker;
using Conductor.Client.Models;
using Conductor.Client.Extensions;
using Conductor.Client;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Orkes.Workers
{
    [WorkerTask]
    public class MyWorker
    {
        [WorkerTask(taskType: "{{taskname}}", batchSize: 5, pollIntervalMs: 500, workerId: "csharp-worker")]
        public static TaskResult MyTask(Conductor.Client.Models.Task task)
        {
            var inputData = task.InputData;
            var result = task.ToTaskResult();
            result.OutputData = new Dictionary<string, object>
            {
                ["message"] = "Hello " + inputData.GetValueOrDefault("name", null)
            };
            return result;
        }

        public static void Main(string[] args)
        {
            var conf = new Configuration
            {
                BasePath = "{{server_url}}",
                AuthenticationSettings = new OrkesAuthenticationSettings("{{auth_key}}", "{{auth_secret}}")
            };

            var host = WorkflowTaskHost.CreateWorkerHost(conf, LogLevel.Debug);
            host.Start();

            Console.WriteLine("Press Ctrl+C to exit.");
            var evt = new ManualResetEvent(false);
            Console.CancelKeyPress += (sender, e) =>
            {
                e.Cancel = true;
                Console.WriteLine("Ctrl+C pressed. Shutting down...");
                evt.Set();
            };

            evt.WaitOne();
            host.StopAsync();
        }
    }
}