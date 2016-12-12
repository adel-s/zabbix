What is it?
-------------
My zabbix-agent bash scripts for monitoring everything.

Installation
-------------
Scripts must be placed at /scripts directory inside zabbix-agent config dir.  
Corresponding userparameter - at /zabbix.agent.d directory nearby.  
External scripts placed at Zabbix Server at directory specified by 'ExternalScripts' variable at zabbix_server.conf  
Some metrics has no script - all needful is inside the userparameter.conf itself.  


TODO
-------------
Add zabbix .xml templates for scripts usage.  
Add readme to scripts.
