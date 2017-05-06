#!/usr/bin/python
# coding=utf-8
import os
import sys
import json
import urllib
import time
import re

ttl = 60

stats = {
    'cluster': 'http://localhost:9200/_cluster/stats',
    'nodes'  : 'http://localhost:9200/_nodes/stats',
    'indices': 'http://localhost:9200/_stats',
    'health' : 'http://localhost:9200/_cluster/health'
}

def get_cache(api):
    cache = '/tmp/elastizabbix-{0}.json'.format(api)
    lock = '/tmp/elastizabbix-{0}.lock'.format(api)
    jtime = os.path.exists(cache) and os.path.getmtime(cache) or 0
    if time.time() - jtime > ttl and not os.path.exists(lock):
        open(lock, 'a').close()
        urllib.urlretrieve(stats[api], cache)
        os.remove(lock)
    ltime = os.path.exists(lock) and os.path.getmtime(lock) or None
    if ltime and time.time() - ltime > 300:
        os.remove(lock)
    return json.load(open(cache))

def get_stat(api, stat):
    d = get_cache(api)
    keys = []
    for i in stat.split(':'):
        keys.append(i)
    for i in keys:
        d = d[i]
    return d

def get_stat_groups (api, stat):
    d = get_cache(api)
    keys=[]
    for i in stat.split(':'):
        keys.append(i)

    sum=0
    name = keys[0]

    for subkey in d[api]:
        if name in subkey:
            dd=d[api][subkey]
            for i in keys[1:]:
                dd = dd[i]
            sum += dd
    return  sum

def discover_nodes():
    d = {'data': []}
    for k,v in get_stat('nodes', 'nodes').iteritems():
        d['data'].append({'{#NAME}': v['name'], '{#NODE}': k})
    return json.dumps(d)

def discover_indices():
    d = {'data': []}
    for k,v in get_stat('indices', 'indices').iteritems():
        d['data'].append({'{#NAME}': k})
    return json.dumps(d)

def discover_indices_groups():
    d = {'data': []}
    for k,v in get_stat('indices', 'indices').iteritems():
        match = re.match('(?:(?:^)|(?:\n))([^.]*)(-\d{4}\.\d{2}.\d{2})', k)
        if match and not match.group(1) in (d['{#NAME}'] for d in d['data']):
            d['data'].append({'{#NAME}': match.group(1)})
    return json.dumps(d)

if __name__ == '__main__':
    api = sys.argv[1]
    stat = sys.argv[2]

    if api == 'discover' and stat=='nodes': print discover_nodes()
    elif api == 'discover' and stat=='indices': print discover_indices()
    elif api == 'discover' and stat=='indices_groups': print discover_indices_groups()
    elif api == 'indices' or api == 'nodes' or api == 'health' or api == 'cluster': print get_stat(api, stat)
    elif api == 'indices_groups': print get_stat_groups('indices', stat)
    else: print '-1'