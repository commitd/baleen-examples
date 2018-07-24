# Baleen Examples

This repo contains a set of example uses of [Baleen](https://github.com/dstl/baleen). It contains the pipeline and configurations required and includes docker commands to setup support services.


# Requirements

* This repository uses [Git Large File Storage](https://git-lfs.github.com/) and must be installed to use pre-traned models.
* Java 8
* Docker (optional)
* Baleen - Download from [GitHub](https://github.com/dstl/baleen/releases) or build from source. Name this file baleen.jar and place in this directory (alongside run.sh). Or use in eclipse with Baleen imported. 
* Run `setup.sh` to create directories and then download ML models.
* A Corpus to process - most examples process a corpora of files from `corpora/files`, add the documents you are interested in processing there 
* Run the following command to validate you have a working version of Baleen:
 
```
java -jar baleen.jar
```

* Review the log and/or visit the UI to verify <http://localhost:6413>


## Notes

* The examples are targeted at the 2.6.0 release of Baleen, some examples may work with earlier versions of Baleen but may require some editing
* Some examples require services to be running. Descriptions of how to run these services using Docker are included below and in the example sections files.
* Most examples process files from `corpora/files` and output to Mongo or to the `output/` folder
* The paths in the files are written relative to the root of this folder, regardless of where the describing file is. This relies on running Baleen from this directory and allows the repo to be portable.
* On some platforms (e.g. Windows) you may need to replace localhost in the examples with the docker container ip
* The examples log INFO to console and TRACE to a file in `output/log`.
* If building Baleen from source a pom.xml is provided to copy and rename the built version with `mvn install`.  


## Eclipse

A number of eclipse configurations are supplied to run with Baleen imported into eclipse, these can be ignored if running from a build version.

# Services

## General consumer services

A simple way to run the services required is through Docker. For the consumers use the following containers.


### Mongo

```
docker run -d -p 27017:27017 mongo:3
```

### Elasticsearch

```
docker run -d -p 9200:9200 -p 9300:9300 -e "http.host=0.0.0.0" -e "transport.host=0.0.0.0" -e "xpack.security.enabled=false" -e "discovery.type=single-node" -e "ES_JAVA_OPTS=-Xms750m -Xmx750m" docker.elastic.co/elasticsearch/elasticsearch:5.6.8 
```

# Examples

## General Pipelines

### example 

A vanilla Baleen example using only standard models

```
java -jar baleen.jar configs/example.yml
```
### all

Uses a maximal set of annotators. Missing annotators require specialised models or replicate another.

```
java -jar baleen.jar configs/all.yml
```
 
### templates

Demonstrates how to set up template based extraction

```
java -jar baleen.jar configs/template.yml
```

## Scalability

These examples show the ability to scale the annotation workload across multiple pipelines on the same Baleen instance (vertical) and across multiple instances (horizontal). 
To spread the workload, the corpus must be read by a single pipeline and the work then spread to multiple other pipelines through some transport mechanism. These examples output to Mongo.

### Vertical

For vertical scaling the memory transport system can be used as the information only needs to be transported within the same instance:

```
java -jar baleen.jar configs/scalability/vertical/memory.yml
```

Similar examples exist in `configs/scalability/vertical/` for vertical scaling using the transport services below. 


### Horizontal

For horizontal scaling, an external transport system must be used. We currently support 

* [Redis](https://redis.io)
* [ActiveMQ](http://activemq.apache.org/)
* [RabbitMQ](https://www.rabbitmq.com)
* [Kafka](https://kafka.apache.org/)

For each of these, a vertical scaling example has also been supplied and can be run on a single instance with the transport service running on `localhost` using the following docker commands.

#### *Redis*

```
docker run -d -p 6379:6379 redis:3.2.9
```

#### *RabbitMQ*

```
docker run -d --hostname my-rabbit -p 15672:15672 -p 5672:5672 rabbitmq:3-management
```
You can then go to <http://localhost:15672> in a browser to use the management console with credentials guest:guest


#### *ActiveMQ*

```
docker run -d -e 'ACTIVEMQ_CONFIG_MINMEMORY=512' -e 'ACTIVEMQ_CONFIG_MAXMEMORY=2048' -p 61616:61616 -p 8161:8161 webcenter/activemq:5.14.3
```
You can then go to <http://localhost:8161> in a browser to use the management console with credentials admin:admin

#### *Kafka*

```
docker run -d -p 2181:2181 -p 9092:9092 -e ADVERTISED_HOST=`localhost` -e ADVERTISED_PORT=9092 spotify/kafka
```
NB we use this image as it includes the Zookeeper service in the same image.

### Master

To run a horizontal scaling example you need a master Baleen instance running the master pipelines that reads the corpus and any number of slave Baleen instances to process the documents.
On the master run:

```
java -jar baleen.jar configs/scalability/horizontal/master/*****.yml
```

where `*****` is replaced by the appropriate transport service.

### Slave

On the slave run:

```
java -jar baleen.jar configs/scalability/horizontal/slave/*****.yml
```

where `*****` is replaced by the appropriate transport service.

## Knowledge Representation

This example demonstrates the additional Mongo and Elasticsearch knowledge representations. This includes the relation specific mongo collections and the temporal and location based elasticsearch indexes.

```
java -jar baleen.jar -p ./pipelines/knowledge.yml ./configs/default.yml
```


### Graphs

The following example demonstrates the graph knowledge representation capabilities.

### Simple

This example outputs the document graphs as graphML to `output/knowledge/graph/` and the entity graph is output to rdf in Turtle to `output/knowledge/rdf/`:

```
java -jar baleen.jar -p ./pipelines/graphs.yml configs/default.yml
```

Format and graph options can are supplied in the `/pipeline/graphs.yml` file.


### Entity Graph output to OrientDB

This demonstrates the ability to output the higher level entity graph to a graph database using the [Apache Tinkerpop](http://tinkerpop.apache.org/) abstraction layer on top of [OrientDB](http://orientdb.com/).
This currently only works with the version 3 release candidate. This is may be obsolete soon. To run OrientDB 3.0.0RC1 in Docker use:

```
docker run -d -p 2424:2424 -p 2480:2480 -e ORIENTDB_ROOT_PASSWORD=rootpwd orientdb:3.0.0RC1
```

You must create a database to use named `baleen` from the user interface on http://localhost:2480. Note, the configuration for the graph is stored in `./graph/orient.properties` and this example requires the graph drivers to be on the classpath. This can be done if running from the code by added a maven dependency on

```
<dependency>
	<groupId>com.orientechnologies</groupId>
	<artifactId>orientdb-gremlin</artifactId>
	<version>3.0.0RC1</version>
</dependency>
```

and for convenience, these are commented on the `baleen-graph/pom.xml`. Running from the command line you must download the jars (done in `setup.sh`)

```
 java -cp "baleen.jar:jars/orient/*"  uk.gov.dstl.baleen.runner.Baleen -p ./pipelines/orient.yml ./configs/default.yml
```

or on Windows

```
 java -cp "baleen.jar;jars/orient/*"  uk.gov.dstl.baleen.runner.Baleen -p ./pipelines/orient.yml ./configs/default.yml
```

### Neo4j

This example outputs the graph representation to the [Neo4J](https://neo4j.com/) graph database.
You can run the service in docker with the following command. 

```
docker run -d -p 7474:7474 -p 7687:7687 neo4j:3.0
```

You must set a password for the root user `neo4j` in the UI at http://localhost:7474. The example assumes you set it to `neopass` but can be altered in `./pipelines/neo4j.yml`. Run the example with:

```
java -jar baleen.jar -p ./pipelines/neo4j.yml ./configs/default.yml
```

### RDF output of the Document Graph to Apache Fuseki

This demonstrates the ability to represent the extracted information as RDF and store in a triple store. 
To run this example you must have an instance of Fuseki running with admin password `pw123` and you must create a dataset named `baleen` through the user interface that can be accessed on localhost:3030 with credentials `admin:pw123`. You can run with Docker 

```
docker run -d -p 3030:3030 -e ADMIN_PASSWORD=pw123 stain/jena-fuseki:3.6.0
```
To run the example:

```
java -jar baleen.jar -p ./pipelines/fuseki.yml configs/default.yml
```

You should see triples appearing in the dataset.

## Relations

The following examples demonstrate the capabilities of Baleen in the extraction of relations. In these examples, we output the relations to a CSV file in `./output/relations`, but the Mongo Relations consumer can be uncommented to add to Mongo.

### High Recall Baseline

This example runs a number of annotators which provide a high-recall baseline of relationships (but likely low precision) using simple extraction techniques. We restrict the document relation extraction to Person and Organisation entities that occur within 5 sentences.

```
java -jar baleen.jar  -p ./pipelines/relation-baseline.yml configs/default.yml
```

### Language base extraction

This example uses the Baleen language based relation extractors. The NPVNP and SimpleInteraction extractor are generic. The others are based on manual regular expression style patterns where the pattern can also use types or part of speech. The aim is that the baseline should allow patterns to be identified, these patterns can then be encoded using these extractors.


```
java -jar baleen.jar -p ./pipelines/relation-language.yml configs/default.yml
```

### ReNoun 

Baleen has a system to annotate relation patterns using dependency parse trees. A set of annotators exist to generate these patterns using weak-supervision modelled on the [ReNoun paper](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/42849.pdf). The system to generate, use and evaluate these patterns is described in `./renoun/README.md`, here we include the seed fact extraction as an example.


```
java -jar baleen.jar -p ./pipelines/relation-seed.yml configs/default.yml
```

## Triage

The following examples demonstrate Baleen capabilities in the support of document triage. 

### Topic model

You can create a topic model over a corpus and re-use that model to assign further documents to topics. We run a Beleen job to train the model. In the job configuration file `./pipelines/training/topic.yml` the number of topics to assign can be specified.

```
java -jar baleen.jar -j ./pipelines/training/topic.yml ./configs/default.yml
```
 
This model can then be used in a pipeline by adding the annotator: 

```
- class: TopicModel
  modelPath: ./output/triage/topic.mallet
```

### Suggested keywords

The second way to create a classifier is to define your own classes defined by a given set of keywords. The classes and keywords are defined in a file with format `label feature_1 feature_2 feature_3` For example, we may define a sentiment analysis classifier for the categories `positive` and `negative` as: 

```
positive good love amazing best awesome
negative not can't enemy horrible ain't
```

We then train a maximum entropy classifier with these starting keywords, the longer the list of words the more the algorithm has to use to decide the class. This can be run with the example:

```
java -jar baleen.jar -j ./pipelines/training/maxent.yml ./configs/default.yml
```

### Labelled Data

If you have labelled data then there are further Mallet classifiers that can be trained on the data. The trainer allows multiple classifiers to be trained in the same job and can output an assessment of accuracy based on randomly partitioning the data for training and testing. Then the best performing model can be taken forward.

The following example can then be used to train classifiers based on this labelled data stored in a mongo database `labelled`, with a `documents` collection and a `label` field (these can be edited in the `classify.yml`.

```
java -jar baleen.jar -j ./pipelines/training/classify.yml ./configs/default.yml
```

### Sumarization

The following example includes an example of all the triage focused annotators. It has the two key word annotators, CommonWords and RakeKeywords, it adds a measure of shanon entropy for prioritisation of documents and runs multiple trained classifiers. (See `./trained/README.md`). It also run the word distribution document summary annotator to produce a summary of the document created from selecting sentences from the document that produce a similar word distribution to the original document. To run this example use the following pipeline and look in the Mongo document metadata for the outputs:

```
java -jar baleen.jar -p ./pipelines/triage.yml ./configs/default.yml
```

## Events

The following examples demonstrate Baleen capabilities in the support of event extraction. 

### Simple example

You can create rules for event extraction using the Open Domain INformer (ODIN) event extraction rule language. These are describe in detail: 

* <https://github.com/clulab/processors/wiki/ODIN-(Open-Domain-INformer)>
* <https://arxiv.org/pdf/1509.07513.pdf>

In this example a simple rule is applied to pull out events with Locations and Times

```
java -jar baleen.jar -j ./pipelines/event-simple.yml ./configs/default.yml
```

### Rich example

Some richer examples of rules are supplied in `events/rich.yml`. Here we create some, temporary, token labels and show how they can be used in other rules. We also show how an event type can be a sub event of another (in the attack rule). 


```
java -jar baleen.jar -j ./pipelines/event-rich.yml ./configs/default.yml
```
