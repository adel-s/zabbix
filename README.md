# Zabbix
## What
A set of Zabbix templates and scripts I made:
- [_2.x](_2.x) - old and really outdated scripts, kept just for history;
- [6.x](6.x) - the current set of templates for Zabbix 6.x.

## Layout
Each template has its own folder `<version>.x/<template>/`:
- `<template>.yaml` - the template, exported from a working Zabbix server;
- `README.md` - what it monitors, prerequisites, installation, macros and where the template comes from;
- `scripts/`, `conf/` - helper scripts and agent configuration, only when the template needs them.

## How to install
Read the `README.md` in the template's folder first: some templates need software or agent configuration on the monitored host.

## License
[GPL-2.0](LICENSE). Several templates are modifications of the official Zabbix
templates, which Zabbix 6.x ships under the same license.
