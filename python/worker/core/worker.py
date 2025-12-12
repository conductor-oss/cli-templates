from conductor.client.worker.worker_task import worker_task

@worker_task(task_definition_name='{{taskname}}')
def workerFn(name: str) -> str:
    return f'hello, {name}'
