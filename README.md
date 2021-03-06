# Name resolution service

This service takes lexical strings and attempts to map them to identifiers (curies) from a vocabulary or ontology.  
The lookup is not exact, but includes partial matches.

Multiple results may be returned representing possible conceptual matches, but all of the identifiers have been 
correctly normalized using the [NodeNormalization service](https://nodenormalization-sri.renci.org/apidocs).

See the documentation [notebook](documentation/NameResolution.ipynb) for examples of use.

## Docker setup

`docker-compose up`

## native setup

### Solr database

```bash
docker run --name name_lookup -d -p 8983:8983 -t solr -DzkRun
./setup.sh
```

### API

```bash
pip install -r requirements.txt
./main.sh
```

## examples

```bash
curl -X POST "http://localhost:6434/lookup?string=oxycod&offset=0&limit=10" -H "accept: application/json"
```
