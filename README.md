# interoception-modeling

## Introduction
**interoception-modeling** is a research project which develops a dynamic connectionist model of emotion regulation between the insula, amygdala, and prefrontal cortex. In addition, there is a body signal, which acts as a fourth "node" in the network. After developing the theoretical model, the model is then fit to different patient's fMRI data. We can then determine if there is statistical significance between control and ruminative patient's brain network connections. 

The first theoretical model that will be fit is a standard dynamical network with a 4x4 weight matrix connecting each region. The second uses Karl Friston's Free Energy principle to build a more complex model in which the insula generates interoceptive predictions and compares those predictions against the incoming sensory input from the body. The predicition error updates the generative model in the insula and determines the strength of signal from the insula to the other regions. This model is not yet complete and hasn't been fit to data.

## Getting Started
To run one simulation of activity in brain regions with a given weight matrix, `run bada_nn_1999_2.m`. The file `indmodelparameters.m` loops over all the patient data that has been specially formatted and fits a model to each patient's data for two tasks: Criticism and neutral. In the criticism scans, individuals brains were recorded as they recieved criticism for 18 scans, rested for 18 scans, then repeated that sequence. In the neutral scans, individuals brains were recorded as they listened to neutral statements for 18 scans, rested for 18 scans, then repeated that sequence. 
