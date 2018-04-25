Jobs can use cron installed on the stemcell to schedule processes. In a [pre-start script](pre-start.md), copy a script from your job's `bin` directory to one of the following locations:

- `/etc/cron.hourly`
- `/etc/cron.daily`
- `/etc/cron.weekly`

You can also create a file in `/etc/cron.d` for full control over the cron schedule.
