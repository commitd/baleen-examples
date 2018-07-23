ReNoun Relation Extraction
==========================

The ReNoun system requires setup for a particular corpus and set of attributes to extract for.
To complete the full setup as described in the academic paper each pipeline/job must be run consecutively on a corpus.

## Setup

Using the configuration files provided we store the corpus in `./corpora/file` and require a MongoDb to be avaiable on `localhost:27017`.

For the scoring you need a glove word vector model, these can downloaded from here <https://nlp.stanford.edu/projects/glove/> we use the [glove.6B.zip](http://nlp.stanford.edu/data/glove.6B.zip) unzip and add to the `models` folder or use the provided script `getGloveModel.sh`.

We have also provided an `attributes` file to define the attribute to search for. This is just a small example set and should be tuned ot your interests or the corpus. It is also possible to use all found attributes by removing the options form the configuration.

## 0 seed generation

The seed generation step can be used if the dependency parser of model is changed from the default MaltParser. 
The parser and configuration you wish to be used should be configured in the pipeline `0_seed_generation.yml`.

```
java -jar baleen.jar -p ./renoun/0_seed_generation.yml ./configs/default.yml
```


## 1 seed extraction

This pipeline extracts seed facts using a set of hand crafted patterns for the given attributes. 
There is also an option to use all nouns that match the patterns as attributes, if a target attribute list is not known.
The seed facts are stored as relations in mongo.
These should be sanity checked and verified removing any that are not valid before moving on to the next stage. 

```
java -jar baleen.jar -p ./renoun/1_default_seed_extraction.yml ./configs/default.yml
java -jar baleen.jar -p ./renoun/1_generated_seed_extraction.yml ./configs/default.yml
```

## 2 pattern learning

The attribute list and the (refined) seed facts are used by this pipeline to generate more patterns that would have extracted these facts.
These patterns are stored in mongo.

```
java -jar baleen.jar -p ./renoun/2_pattern_learning.yml ./configs/default.yml
```

## 3 fact extraction

Using the extended set of patterns more facts/relations are extracted from the corpus to give the noun based relations.
These are stored as relations in mongo and (optionally) in a specific collection for scoring.

```
java -jar baleen.jar -p ./renoun/3_fact_extraction.yml ./configs/default.yml
```

## 4 fact scoring

This optional post process can score the facts to give you more information about the confidence you should have in the extracted fact. 

```
java -jar baleen.jar -j ./renoun/4_fact_scoring.yml ./configs/default.yml
```