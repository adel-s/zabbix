# Docker Registry

## What
Monitors a Docker Registry (distribution v3) through its debug listener: the
`/debug/health` endpoint plus the Prometheus `/metrics` endpoint, both polled by
HTTP agent items from the Zabbix server or proxy, so no Zabbix agent is needed
on the registry host. Covers availability, health checks, HTTP request and 5xx
rates, storage action latency, cache efficiency, process resources and restarts.

### Items
| Name                                                  | Key                                    | Type       | Interval |
|-------------------------------------------------------|----------------------------------------|------------|----------|
| Registry: File descriptors used                       | `registry.process.fds.pused`           | Calculated | `1m`     |
| Registry: Get metrics                                 | `registry.metrics`                     | HTTP agent | `1m`     |
| Registry: Goroutines                                  | `registry.process.goroutines`          | Dependent  | -        |
| Registry: HTTP 5xx responses total                    | `registry.http.requests.5xx`           | Dependent  | -        |
| Registry: HTTP request count, per second              | `registry.http.duration.count.rate`    | Dependent  | -        |
| Registry: HTTP request duration, average              | `registry.http.duration.avg`           | Calculated | `1m`     |
| Registry: HTTP request duration, seconds per second   | `registry.http.duration.sum.rate`      | Dependent  | -        |
| Registry: HTTP requests in flight                     | `registry.http.in_flight`              | Dependent  | -        |
| Registry: HTTP requests per second                    | `registry.http.requests.rate`          | Dependent  | -        |
| Registry: Health details                              | `registry.health`                      | HTTP agent | `1m`     |
| Registry: Health status                               | `registry.health.status`               | Dependent  | -        |
| Registry: Max file descriptors                        | `registry.process.fds.max`             | Dependent  | -        |
| Registry: Open file descriptors                       | `registry.process.fds.open`            | Dependent  | -        |
| Registry: Resident memory                             | `registry.process.memory.rss`          | Dependent  | -        |
| Registry: Storage action count, per second            | `registry.storage.duration.count.rate` | Dependent  | -        |
| Registry: Storage action duration, average            | `registry.storage.duration.avg`        | Calculated | `1m`     |
| Registry: Storage action duration, seconds per second | `registry.storage.duration.sum.rate`   | Dependent  | -        |
| Registry: Storage cache errors total                  | `registry.storage.cache.errors`        | Dependent  | -        |
| Registry: Storage cache hit ratio                     | `registry.storage.cache.hit_ratio`     | Calculated | `1m`     |
| Registry: Storage cache hits total                    | `registry.storage.cache.hits`          | Dependent  | -        |
| Registry: Storage cache requests total                | `registry.storage.cache.requests`      | Dependent  | -        |
| Registry: Uptime                                      | `registry.process.uptime`              | Dependent  | -        |

### Triggers
| Name                                                                          | Severity    | Depends on                           |
|-------------------------------------------------------------------------------|-------------|--------------------------------------|
| Registry: Debug endpoint unreachable                                          | High        | -                                    |
| Registry: HTTP 5xx responses in the last {$REGISTRY.ERRORS.PERIOD}            | Warning     | -                                    |
| Registry: Health check failing                                                | High        | Registry: Debug endpoint unreachable |
| Registry: High memory usage (over {$REGISTRY.MEM.WARN} for 5m)                | Warning     | -                                    |
| Registry: Running out of file descriptors (over {$REGISTRY.FDS.WARN}% for 5m) | Warning     | -                                    |
| Registry: Service has been restarted (uptime < 10m)                           | Information | -                                    |
| Registry: Storage cache errors in the last {$REGISTRY.ERRORS.PERIOD}          | Warning     | -                                    |

### Discovery rules
* none

## Prerequisites
- Docker Registry (distribution) v3 with the debug listener enabled in its
  configuration: `http.debug.addr` (for example `:5001`) and
  `http.debug.prometheus.enabled: true`.
- The Zabbix server or proxy that polls the host can reach the debug listener.
  Do not publish this port to the internet: it is unauthenticated.

## How to install
Requires Zabbix 6.4 or newer.
1. Import `docker_registry.yaml` in `Data collection -> Templates -> Import`.
2. Link the template to a host. No host interface is needed.
3. Set `{$REGISTRY.DEBUG.URL}` on the host to the debug listener address.

### Macros
| Macro                       | Default                 | Description                                                                |
|-----------------------------|-------------------------|----------------------------------------------------------------------------|
| `{$REGISTRY.DEBUG.URL}`     | `http://localhost:5001` | Registry debug listener (http.debug.addr), as seen from the Zabbix server. |
| `{$REGISTRY.ERRORS.PERIOD}` | `15m`                   | Window for the 5xx and cache error triggers.                               |
| `{$REGISTRY.FDS.WARN}`      | `80`                    | Open file descriptors, percent of the limit.                               |
| `{$REGISTRY.MEM.WARN}`      | `800M`                  | Resident memory threshold.                                                 |
| `{$REGISTRY.NODATA.PERIOD}` | `5m`                    | No health answer for this long = unreachable.                              |

## Source
Own work.

### Removed
* not applicable

### Added
* not applicable
