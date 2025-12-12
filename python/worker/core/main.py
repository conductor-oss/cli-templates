from conductor.client.automator.task_handler import TaskHandler
from conductor.client.configuration.configuration import Configuration
from conductor.client.configuration.settings.authentication_settings import AuthenticationSettings
from worker import *

def main():
    configuration = Configuration(server_api_url='{{server_url}}',
        authentication_settings=AuthenticationSettings(key_id='{{auth_key}}',
                                    key_secret='{{auth_secret}}'))
    task_handler = TaskHandler(
        configuration=configuration,
        scan_for_annotated_workers=True
    )
    task_handler.start_processes()

if __name__ == '__main__':
    main()
