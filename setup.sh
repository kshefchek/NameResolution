#!/usr/bin/env bash


SOLR_PORT=8983

is_solr_up(){
    echo "Checking if solr is up on http://localhost:$SOLR_PORT/solr/admin/cores"
    http_code=`echo $(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$SOLR_PORT/solr/admin/cores")`
    echo $http_code
    return `test $http_code = "200"`
}

wait_for_solr(){
    while ! is_solr_up; do
        sleep 3
    done
}

wait_for_solr

# add collection
curl -X POST 'http://localhost:8983/solr/admin/collections?action=CREATE&name=name_lookup&numShards=1&replicationFactor=1'

# do not autocreate fields
curl http://localhost:8983/solr/name_lookup/config -d '{"set-user-property": {"update.autoCreateFields":"false"}}'

# add lowercase text type
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field-type" : {
     "name":"LowerTextField",
     "class":"solr.TextField",
     "positionIncrementGap":"100",
     "analyzer" : {
        "tokenizer":{
           "class":"solr.WhitespaceTokenizerFactory" },
        "filters":[{
           "class":"solr.LowerCaseFilterFactory"}]}}
}' 'http://localhost:8983/solr/name_lookup/schema'

# add name field
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"name",
     "type":"LowerTextField",
     "stored":true }
}' 'http://localhost:8983/solr/name_lookup/schema'

# add length field
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"length",
     "type":"plong",
     "stored":true }
}' 'http://localhost:8983/solr/name_lookup/schema'

# add curie field
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"curie",
     "type":"string",
     "stored":true }
}' 'http://localhost:8983/solr/name_lookup/schema'

# add data
curl -X POST -H 'Content-Type: application/json' -d @data/all-synonyms.json \
    'http://localhost:8983/solr/name_lookup/update?commit=true'
