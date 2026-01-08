# Metrics Server

!!! note
    This feature is available with BOSH release v270.10.0+. It is an ongoing feature and new functionality will continue to be exposed in later releases.

As of `v270.10.0` the director can now be deployed with a co-located metrics server which will report Prometheus style metrics about the director and it's deployed VMs.

The metrics server can be enabled by setting the `properties.director.metrics_server.enabled` property to true. If you are using [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment), the [`experimental/enable-metrics.yml`](https://github.com/cloudfoundry/bosh-deployment/blob/master/experimental/enable-metrics.yml) operations file will enable the metrics server.

Currently the metrics server is secured using mutual auth TLS. In order to successfully enable the metrics server, you will need to specify the following variables:

* `properties.director.metrics_server.tls.ca`
* `properties.director.metrics_server.tls.certificate`
* `properties.director.metrics_server.tls.private_key`

Similarly when connecting to the metrics server from a client, such as a Prometheus metrics collector, you will need to specify valid client certificate credentials.

By default the metrics server will listen on port 9091, but this can be configured through the `properties.director.metrics_server.port` settings.

## Metrics File Cleanup

!!! note
    This feature is available with BOSH release vXXX+.

The metrics server stores metric data in binary files in `/var/vcap/store/director/metrics`. To prevent unbounded disk usage and problems with stale metrics causing large scrape responses, the director automatically cleans up metric files older than a configurable retention period via a scheduled job that runs periodically.

By default, metric files older than 7 days are deleted by a scheduled job that runs daily at midnight UTC.

This can be configured via:

* `properties.director.metrics_server.file_retention_days` - Number of days to retain (default: 7, set to 0 to disable)
* `properties.director.metrics_server.cleanup_schedule` - Cron schedule for cleanup (default: `'0 0 0 * * * UTC'`)

## Available Metrics

The metrics server serves two endpoints, `/metrics` and `/api_metrics`. Currently it exposes the following metrics:

* `bosh_resurrection_enabled`: Status of resurrection. 0 for disabled, 1 for enabled.
* `bosh_tasks_total`: Number of BOSH active tasks, labeled with their current state (either 'processing' or 'queued') and type.
* `bosh_networks_dynamic_ips_total`: Size of network pool for all dynamically allocated IP addresses.
* `bosh_networks_dynamic_free_ips_total`: Number of free dynamic IP addresses left per network.
* `bosh_unresponsive_agents`: Number of unresponsive agents per deployment
* Generic API metrics for the director's endpoints including number of requests and response time.

## BOSH Director VM Metrics

At the moment the built in director monitoring only provides information about the director's API and resources that it manages. In order to expose metrics about the director's VM, we recommend that you co-locate an agent that performs this functionality.
