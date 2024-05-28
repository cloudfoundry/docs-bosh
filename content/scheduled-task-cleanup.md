# Scheduled task-cleanup
Scheduled task-cleanup is a scheduled task in bosh director, to get rid of the completed tasks from the database and disk and to avoid filling the disk with the log files. This task is scheduled to run every 7 days by default and keep last 2000 tasks for each type.

## Configuration
### `director.tasks_cleanup_schedule`
The schedule for the task-cleanup job. The default value is `0 0 0 */7 * * UTC` which means the task-cleanup job will run once every 7 days at midnight UTC.

### `director.max_tasks`
The maximum number of tasks per each type to keep in disk. The default value is `2000`.

### `director.tasks_retention_period`
The generic retention period for tasks and their log files. The default value is `''` and the scheduled job will only consider `max_tasks`. The tasks will be cleaned up if one of the `max_tasks` or `tasks_retention_period` is reached.

The configuration is an integer with unit day.

### `director.tasks_deployments_retention_period`
The retention period for tasks and their log files of specific deployments. The default value is `''` and the scheduled job will only consider `max_tasks`. The tasks will be cleaned up if one of the `max_tasks`, `tasks_retention_period` or `tasks_deployments_retention_period` is reached.

The configuration is an array of map, with retention unit day and deployment name.
### Example configuration:
```yaml
properties:
  director:
    tasks_cleanup_schedule: "0 0 0 */7 * * UTC"  # the task-cleanup job will run once every 7 days at midnight UTC
    max_tasks: 2000  # maximum number of tasks per each type to keep in disk
    tasks_retention_period: 30  # generic retention period 30 days for tasks and their log files
    tasks_deployments_retention_period:  # retention period 14 days for tasks and their log files of specific deployment "deployment-name"
    - deployment_name: "deployment-name"
      retention_period: 14
```
