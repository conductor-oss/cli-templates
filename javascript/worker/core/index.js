const { orkesConductorClient } = require("@io-orkes/conductor-javascript");
const { TaskManager } = require("@io-orkes/conductor-javascript");
const serverSettings = {
  keyId: "_auth_key_",
  keySecret: "_auth_secret_",
  serverUrl: "_server_url_",
};

const clientPromise = orkesConductorClient(serverSettings);
async function createTaskManager() {
  const client = await clientPromise;
  return new TaskManager(
    client,
    [
    {
    taskDefName: "_taskname_",
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