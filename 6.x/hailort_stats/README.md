# HailoRT Stats

## What
Monitors a Hailo-8 AI accelerator through HailoRT: chip temperatures (two
sensors), power rail voltage, current and power, NPU core frequency and whether
the temperature/overcurrent throttling protection is enabled. One Zabbix agent
UserParameter runs a small Python script that prints all values as JSON once a
minute; every other item is a dependent item parsed from that JSON.

### Items
| Name                         | Key                                           | Type         | Interval |
|------------------------------|-----------------------------------------------|--------------|----------|
| Hailo: Bus voltage           | `hailort_stats.power.bus_voltage`             | Dependent    | -        |
| Hailo: Current               | `hailort_stats.power.current`                 | Dependent    | -        |
| Hailo: Get stats             | `hailort_stats.raw`                           | Zabbix agent | `1m`     |
| Hailo: NPU core frequency    | `hailort_stats.device_info.nn_core_clock_mhz` | Dependent    | -        |
| Hailo: Power                 | `hailort_stats.power.power`                   | Dependent    | -        |
| Hailo: Shunt voltage         | `hailort_stats.power.shunt_voltage`           | Dependent    | -        |
| Hailo: Temperature (TS0)     | `hailort_stats.temperature.ts0`               | Dependent    | -        |
| Hailo: Temperature (TS1)     | `hailort_stats.temperature.ts1`               | Dependent    | -        |
| Hailo: Throttling protection | `hailort_stats.throttling_state`              | Dependent    | -        |

### Triggers
| Name                                                                 | Severity | Depends on                                              |
|----------------------------------------------------------------------|----------|---------------------------------------------------------|
| Hailo: High temperature (over {$HAILO.TEMP.WARN}°C for 5m)           | Warning  | Hailo: No stats from HailoRT for {$HAILO.NODATA.PERIOD} |
| Hailo: NPU core frequency below nominal ({$HAILO.CLOCK.NOMINAL} MHz) | Warning  | Hailo: No stats from HailoRT for {$HAILO.NODATA.PERIOD} |
| Hailo: No stats from HailoRT for {$HAILO.NODATA.PERIOD}              | High     | -                                                       |
| Hailo: Throttling protection is disabled                             | Warning  | Hailo: No stats from HailoRT for {$HAILO.NODATA.PERIOD} |

### Discovery rules
* none

## Prerequisites
- A Hailo-8 module (M.2 or mPCIe) with the HailoRT driver installed and working
  (`hailortcli fw-control identify` sees the device).
- HailoRT 4.19 or newer, with pyhailort (the `hailo_platform` Python package)
  installed for the Python interpreter the agent will run.
- Zabbix agent 2 (or agent) on the same host, running as a user that can open
  the device.

Older HailoRT versions:
- Below 4.19 the script cannot silence HailoRT warnings
  (`HAILORT_CONSOLE_LOGGER_LEVEL` does not exist there). HailoRT then prints a
  warning on every power reading, the agent puts it into the item value and the
  JSON breaks. Append ` 2>/dev/null` to the `UserParameter` line. Note that this
  also hides real errors.
- The script turns off HailoRT log files (`HAILORT_LOGGER_PATH=NONE`, verified
  on HailoRT 4.14 and newer). On an older HailoRT `hailort.log` may keep
  appearing in the agent's working directory and in `~/.hailo/hailort/`: set
  `HAILORT_LOGGER_PATH` to a directory of your choice in the agent's environment,
  or clean the files up periodically.

## How to install
Requires Zabbix 6.4 or newer.
1. Copy `scripts/hailort_stats.py` to the host, for example to
   `/etc/zabbix/scripts/hailort_stats.py`.
2. Copy `conf/hailort_stats.conf` to the agent include directory, for example
   `/etc/zabbix/zabbix_agent2.d/`. Fix the script path, and replace `python3`
   with the interpreter that has pyhailort if it is not the default one (for
   example `python3.11`).
3. Restart the agent and check the output:
   `zabbix_agent2 -t hailort_stats.raw` must print one JSON object.
4. Import `hailort_stats.yaml` in `Data collection -> Templates -> Import` and
   link the template to the host.

### Macros
| Macro                    | Default | Description                                                    |
|--------------------------|---------|----------------------------------------------------------------|
| `{$HAILO.CLOCK.NOMINAL}` | `400`   | Nominal NPU core frequency, MHz. Lower = throttling.           |
| `{$HAILO.NODATA.PERIOD}` | `10m`   | No stats for this long = HailoRT or the device is unavailable. |
| `{$HAILO.TEMP.WARN}`     | `80`    | Chip temperature threshold, °C.                                |

## Source
Own work.

### Removed
* not applicable

### Added
* not applicable
