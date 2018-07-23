#!/bin/bash

# TODO: Add Baleen download once released 

mkdir models
mkdir files
mkdir jars
cd models
wget http://opennlp.sourceforge.net/models-1.5/en-ner-location.bin
wget http://opennlp.sourceforge.net/models-1.5/en-ner-organization.bin
wget http://opennlp.sourceforge.net/models-1.5/en-ner-person.bin
cd ..
git clone git@github.com:dstl/re3d.git


mkdir jars/orient
cd jars
cd orient
wget http://central.maven.org/maven2/com/orientechnologies/orientdb-core/3.0.0RC1/orientdb-core-3.0.0RC1.jar
wget http://central.maven.org/maven2/com/orientechnologies/orientdb-client/3.0.0RC1/orientdb-client-3.0.0RC1.jar
wget http://central.maven.org/maven2/com/orientechnologies/orientdb-gremlin/3.0.0RC1/orientdb-gremlin-3.0.0RC1.jar
wget http://central.maven.org/maven2/net/java/dev/jna/jna/4.5.0/jna-4.5.0.jar
wget http://central.maven.org/maven2/net/java/dev/jna/jna-platform/4.5.0/jna-platform-4.5.0.jar
wget http://central.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.0.1/snappy-java-1.1.0.1.jar
cd ..
cd ..

