#!/usr/bin/env python3
"""Hailo-8 statistics for a Zabbix agent UserParameter.

Prints one JSON object: chip temperatures, power rail readings, throttling
state and device information, read through HailoRT (pyhailort,
`hailo_platform`). Values are in SI units: volts, amperes, watts, MHz, °C.

Requires HailoRT 4.19 or newer with its driver, and pyhailort installed for
the Python interpreter that the agent runs.
"""
import json
import os

# HailoRT warns on stderr on every power reading through the overcurrent
# protection DVM (the only DVM on M.2 modules). The agent merges stderr into
# the item value and breaks the JSON, so keep only errors on the console.
os.environ.setdefault("HAILORT_CONSOLE_LOGGER_LEVEL", "error")
# HailoRT also writes hailort.log to the current directory and to
# ~/.hailo/hailort/ on every run; a monitoring probe does not need either.
os.environ.setdefault("HAILORT_LOGGER_PATH", "NONE")

from hailo_platform import Device, PowerMeasurementTypes


def to_safe(val):
    """Make HailoRT values JSON-serializable (bytes become hex)."""
    if isinstance(val, bytes):
        return val.hex()
    if isinstance(val, list):
        return [to_safe(v) for v in val]
    if isinstance(val, dict):
        return {k: to_safe(v) for k, v in val.items()}
    return val


def parse_supported_features(raw):
    """Turn the 'Feature: Enabled/Disabled' text block into a dict of bools."""
    result = {}
    for line in raw.strip().splitlines()[1:]:
        if ':' in line:
            key, val = line.split(':', 1)
            result[key.strip().lower().replace(' ', '_')] = val.strip().lower() == 'enabled'
    return result


def main():
    # Keep a reference: the device is closed as soon as the Device object is collected.
    device = Device()
    control = device.control
    temp = control.get_chip_temperature()
    power = control.power_measurement
    info = control.get_extended_device_information()

    result = {
        "temperature": {
            "ts0_temperature": round(temp.ts0_temperature, 2),
            "ts1_temperature": round(temp.ts1_temperature, 2),
        },
        "power": {
            # HailoRT returns voltages in mV and current in mA.
            "bus_voltage": round(power(measurement_type=PowerMeasurementTypes.BUS_VOLTAGE) / 1000, 2),
            "shunt_voltage": round(power(measurement_type=PowerMeasurementTypes.SHUNT_VOLTAGE) / 1000, 4),
            "current": round(power(measurement_type=PowerMeasurementTypes.CURRENT) / 1000, 3),
            "power": round(power(measurement_type=PowerMeasurementTypes.POWER), 2),
        },
        "throttling_state": bool(control.get_throttling_state()),
        "device_info": {
            "boot_source": str(info.boot_source),
            "eth_mac_address": to_safe(info.eth_mac_address),
            "lcs": str(info.lcs),
            "nn_core_clock_mhz": info.neural_network_core_clock_rate // 1_000_000,
            "soc_id": to_safe(info.soc_id),
            "soc_pm_values": to_safe(info.soc_pm_values),
            "supported_features": parse_supported_features(str(info.supported_features)),
            "unit_tracking_id": to_safe(info.unit_level_tracking_id),
        },
    }
    print(json.dumps(result))


if __name__ == '__main__':
    main()
