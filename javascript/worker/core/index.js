const { orkesConductorClient } = require("@io-orkes/conductor-javascript");
const { TaskManager } = require("@io-orkes/conductor-javascript");
const serverSettings = {
  keyId: "{{auth_key}}",
  keySecret: "{{auth_secret}}",
  serverUrl: "{{server_url}}",
};

const clientPromise = orkesConductorClient(serverSettings);
async function createTaskManager() {
  const client = await clientPromise;
  return new TaskManager(
    client,
    [
    {
    taskDefName: "{{taskname}}",
    execute: async ({ inputData }) => {
    
      const message ="Hello world"
      return {
        outputData: { message },
        status: "COMPLETED",
      };
    },
  }
    ],
    {
      logger: console,
      options: { concurrency: 2, pollInterval: 100 },
    }
  );
}

async function main() {
    const taskManager = await createTaskManager();
    taskManager.startPolling();
}

main();