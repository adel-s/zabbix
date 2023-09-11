## Описание
Скрипт расширяющий функциональность Zabbix-агента, предназначенный для получения метрик из Elasticsearch

## Требования
Python 2.7 + установленные модули: elasticsearch, json, os, sys, time

## Установка
Поместить:

elasticsearch.conf - в каталог конфигураций Zabbix (обычно это /etc/zabbix/zabbix_agentd.conf.d)

es_zabbix.py - в каталог скриптов (/etc/zabbix/scripts)

## Функционал
Вызов скрипта:

    es_zabbix.py api metric

Скрипт работает в двух режимах:

### Режим discovery

    es_zabbix.py discovery [nodes|node|indices]

   * **nodes** - возвращает список всех нод в кластере в виде zabbix json формата, для каждой ноды содержит два параметра: '#NODE' - id ноды в кластере, '#NAME' - имя ноды.
   Пример:

    { "data": [
        {"{#NODE}": "MyizaDUjRKiMiebzpRoNOg", "{#NAME}": "elastic-data1"},
        {"{#NODE}": "d73JzeMSRTKufO3gs1Ysdg", "{#NAME}": "elastic-master1"},
        {"{#NODE}": "g34SmibkR7C2mUKFMTkxbg", "{#NAME}": "elastic-client1"}
        ]}
   
   * **node** - возвращает текущую локальную ноду, на которой скрипт был запущен. Пример:

    { "data": [
        {"{#NODE}": "g34SmibkR7C2mUKFMTkxbg",
        "{#NAME}": "elastic-client1"}
        ]}
    
   * **indices** - возвращает список всех индексов в кластере. Пример:
   
    { "data": [
        {"{#NAME}": ".kibana"},
        {"{#NAME}": ".monitoring-es-6-2018.02.13"},
        {"{#NAME}": "my_cool_index"}
        ]}
    
### Режим получения метрик
    es_zabbix.py [cluster|health|indices|nodes] metric:submetric:submetric2

Для получения значения метрики необходимо выбрать апи из списка поддерживаемых и путь до метрики разделённый символом `:`

#### Пример №1 - получение health метрик:
_cluster/health возвращает следующий JSON:

    {
      "cluster_name" : "my_cluster",
      "status" : "green",
      "timed_out" : false,
      "number_of_nodes" : 10,
      "number_of_data_nodes" : 6,
      "active_primary_shards" : 1000,
      "active_shards" : 500,
      "relocating_shards" : 0,
      "initializing_shards" : 0,
      "unassigned_shards" : 0,
      "delayed_unassigned_shards" : 0,
      "number_of_pending_tasks" : 0,
      "number_of_in_flight_fetch" : 0,
      "task_max_waiting_in_queue_millis" : 0,
      "active_shards_percent_as_number" : 100.0
    }
    
Вызов скрипта для получения метрики status будет выглядеть так:

    # es_zabbix.py health status
    green
    
А соответствующий ему item в Zabbix:

    elasticsearch[health,status]
    
#### Пример №2 - получение метрики "количество данных на ноде"
_nodes/stats возвращает следующий JSON (ниже только начальный фрагмент):

    {
      "_nodes": {
        "total": 10,
        "successful": 10,
        "failed": 0
      },
      "cluster_name": "my_cluster",
      "nodes": {
        "MyizaDUjRKiMiebzpRoNOg": {
          "timestamp": 1525356838762,
          "name": "elastic-data1",
          "transport_address": "169.254.46.35:9300",
          "host": "169.254.46.35",
          "ip": "169.254.46.35:9300",
          "roles": [
            "data"
          ],
          "attributes": {
            "ml.max_open_jobs": "10",
            "rack_id": "lxc-host1",
            "box_type": "warm",
            "ml.enabled": "true"
          },
          "indices": {
            "docs": {
              "count": 10028441640,
              "deleted": 106223
            }
            ...
            
Для получения метрики о количестве записей на ноде вызов скрипта будет выглядеть так:

    # es_zabbix.py nodes nodes:MyizaDUjRKiMiebzpRoNOg:indices:docs:count
    10028441640

А соответствующий ему item в Zabbix:

    elasticsearch[nodes,nodes:MyizaDUjRKiMiebzpRoNOg:indices:docs:count]

#### Пример №3 - получение метрики "время индексирования в мс. по индексу"
_stats api возвращает следующий JSON (фрагмент):

      "indices": {
        "my_cool_index": {
          "primaries": {
            "docs": {
              "count": 1026912,
              "deleted": 0
            },
            "store": {
              "size_in_bytes": 743770384,
              "throttle_time_in_millis": 0
            },
            "indexing": {
              "index_total": 1027144,
              "index_time_in_millis": 240183,
              "index_current": 0,
              "index_failed": 0,
              "delete_total": 0,
              "delete_time_in_millis": 0,
              "delete_current": 0,
              "noop_update_total": 0,
              "is_throttled": false,
              "throttle_time_in_millis": 0
            }
            ...
            
Вызов скрипта:

    # es_zabbix.py indices indices:my_cool_index:primaries:indexing:index_time_in_millis
    240183
    
Соответствующий item в Zabbix:

    elasticsearch[indices,indices:my_cool_index:primaries:indexing:index_time_in_millis]


## Кеширование
Для уменьшения нагрузки на ноду (т.к. в нормальных условиях в минуту с ноды снимается более сотни метрик) и ускорения 
поиска, скрипт по умолчанию кеширует данные по каждому api в файле

    /tmp/es_zabbix-{api_name}.json
    
При каждом обращении к метрике происходит проверка кеша, и если он не старше 55 сек. - обращения к ноде Elasticsearch 
не происходит, данные берутся из кеша. В противном случае - кеш обновляется актуальными данными. Если вам 
необходимо получать изменения метрик чаще чем раз в минуту - измените в скрипте параметр cache_ttl.