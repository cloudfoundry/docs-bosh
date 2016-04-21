---
title: Scheduled Tasks
---
BOSH jobs can schedule tasks by using the cron installed on the stemcell. In
a pre-start script, copy a script from your job's `bin` directory to one of the
following locations:

- /etc/cron.hourly
- /etc/cron.daily
- /etc/cron.weekly

You can also create a file in /etc/cron.d for full control over the cron
schedule.
