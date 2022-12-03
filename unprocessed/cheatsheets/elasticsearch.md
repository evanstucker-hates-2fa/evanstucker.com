# Elasticsearch

## Using Cerebro

Start Cerebro on your workstation:

    docker run -d -p 9000:9000 --name cerebro lmenezes/cerebro

Open http://localhost:9000.

Then connect to http://your_elasticsearch_server:9200

## Why are my shards unallocated?!?

https://www.datadoghq.com/blog/elasticsearch-unassigned-shards/

    curl -XGET localhost:9200/_cluster/allocation/explain?pretty

# Updating indices

https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html

```bash
curl -XGET http://localhost:9200/_cat/indices/_all

curl -XGET http://localhost:9200/.kibana/_settings | jq .

curl -XPUT http://localhost:9200/.kibana/_settings -d '{"index":{"number_of_replicas":0}}'

PUT _template/all
{
  "template": "*",
  "settings": {
    "number_of_shards": 7,
    "number_of_replicas": 2
  }
}
```

# Plugins

elasticsearch-plugin list

curl http://localhost:9200/_cluster/state?pretty=true
