Interations Relation Extraction
==========================

The interaction word relationship extraction system requires setup for a particular corpus.

## 1 Pattern extraction

Potential patterns must be extracted from the corpus. This requires the `patterns.PatternExtractor` be run in a pipeline 
after, sentence, work token and part of speech tagging has taken place. 

```
java -jar baleen.jar -p ./relations/1_pattern_extraction.yml ./configs/default.yml
```


## 2 Interaction identification

Run a job to identify the interaction words.

```
java -jar baleen.jar -j ./relations/2_interaction_identification.yml ./configs/default.yml
```

## 3 Interaction enhancement

Run a job to enhance the interations words.

```
java -jar baleen.jar -j ./relations/3_interaction_enhancement.yml ./configs/default.yml
```


## 4 Upload Interactions

Run a job to upload the interactions.

```
java -jar baleen.jar -j ./relations/4_upload_interactions.yml ./configs/default.yml
```


## 5 Upload Interactions

Finally, process the corpus with the relations.UbmreDependency to extract relations.

```
java -jar baleen.jar -p ./relations/5_process_documents.yml ./configs/default.yml
```