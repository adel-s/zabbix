**IMPORTANT: This folder contains scripts/templates which were created for Zabbix 2.x, mostly outdated and not applicable to current Zabbix versions!**


What is it?
-------------
My zabbix-agent bash scripts for monitoring everything.

Installation
-------------
Scripts must be placed at /scripts directory inside zabbix-agent config dir.  
Corresponding userparameter - at /zabbix.agent.d directory nearby.  
External scripts placed at Zabbix Server at directory specified by 'ExternalScripts' variable at zabbix_server.conf  
Some metrics has no script - all needful is inside the userparameter.conf itself. 
