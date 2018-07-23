# Pre-trained models

Data used:

* Re3d (github)[https://github.com/dstl/re3d]
* Amazon reviews (kaggle)[https://www.kaggle.com/bittlingmayer/amazonreviews]

## topic.mallet 
Topic Model trained on re3d with parameters:

<pre>
- class: triage.TopicModelTrainer
  modelFile: ./output/triage/topic.mallet
  numTopics: 25 
# numIterations: 1000
# numThreads: 2
# collection: documents
# field: content
</pre>


## maxent.mallet 
Maxent Classifier trained on re3d for positive and negative labels with parameters:

<pre>
- class: triage.MaxEntClassifierTrainer
  labelsFile: ./pipelines/training/labels
  modelFile: ./output/triage/maxent.mallet
# numIterations: 1000
# variance: 1.0
# collection: documents
# field: content
</pre>


## classify.mallet 
Naive Bayes Classifier trained on amazon reviews data for positive and negative labels with parameters:

<pre>
- class: triage.MalletClassifierTrainer
  trainer: 
  - NaiveBayes
  forTesting: 0.2
  resultFile: ./output/triage/classifyTrials.csv
  modelFile: ./output/triage/classify
#  collection: documents
#  labelField: label
</pre>

Model verification results:

|Accuracy                        | 0.8386777777777777 |
|:------------------------------ | ------------------ |
|F1 for class '__label__1'       | 0.8390470753216231 |
|Precision for class '__label__1'| 0.8365639947277816 |
|F1 for class '__label__2'       | 0.838306781671279  |
|Precision for class '__label__2'| 0.8408139557613312 |
