# this file contains two functions:
# 1. find_parameters() takes in two arguments
#  individual: int. This is the patient ID
#  test: string. This is the stimulus being tested. Can be neutral or criticism
#  RETURN: returns 1x16 numpy array of parameters fit to data, found by weightsearch()
# 
# 2. weightsearch() takes in one argument
#  weights: numpy array. This is a flattened 1x16 array of the 4x4 weight matrix. 
#  These values are being optimized.
#  RETURN: returns loss function used as error for scipy.optimize

import numpy as np
import pandas as pd
from scipy.optimize import minimize, rosen, rosen_der
from dynamicalmodel import interoceptive_update, external_percept_simulation
from spm_hrf import spm_hrf

def weightsearch(weights): # IMPLEMENT THIS
    # global variables needed to run simulated model
    global globalweights
    global globalstartstates
    global globalinstates

    # global variable needed to dtermine if the in state should include 
    global typetest

    # make globalstartstates globalinstates 
    globalstartstates = np.array([[0, 0.5, 0.5, 0.5]]) # all networks start at 0.5 activation
    globalinstates = np.array([[0, 0, 0, 0]]) # this is neutral case
    globalweights = np.reshape(weights, 4, 4)

    simulateddata = external_percept_simulation('useglobals')

    # since we passed in instates with only one row, only concerned with first layer of simulateddata
    # look at weight matrix info in dynamicalmodel to see which rows hold data for each region
    simulatedexecdata = simulateddata[0, 1, :] 
    simulatedsaliencedata = simulateddata[0, 2, :]
    simulatedinteroceptivedata = simulateddata[0, 3, :]

    # convolution with hemodynamic response function to get simulated BOLD signal
    resamprate = 100
    hemoir = smp_hrf(1/resamprate, [6, 16,1, 1, 6, 0, 32])

    convolvedexecdata = np.convolve(simulatedexecdata, hemoir)
    convolvedsaliencedata = np.convolve(simulatedsaliencedata, hemoir)
    convolvedinteroceptivedata = np.convolve(simulatedinteroceptivedata, hemoir)

    # we need to interpolate fMRI data to be the same length as convolved simulated data
     

    return np.mean(weights)

def find_parameters(individual = 2303, test='neutral'):
    # construct name of files that you want to open
    if test=='neutral': # neutral stimulus
        csv_exec = f'../data/neutral_rest_76_scans/{individual}_executive_{test}_76_scans.csv'
        csv_salience = f'../data/neutral_rest_76_scans/{individual}_salience_forward_{test}_76_scans.csv'
        csv_interoceptive = f'../data/neutral_rest_76_scans/{individual}_interoceptive_forward_{test}_76_scans.csv'
    else: # criticism stimulus
        csv_exec = f'../data/criticism_rest_76_scans/{individual}_executive_{test}_76_scans.csv'
        csv_salience = f'../data/criticism_rest_76_scans/{individual}_salience_forward_{test}_76_scans.csv'
        csv_interoceptive = f'../data/criticism_rest_76_scans/{individual}_interoceptive_forward_{test}_76_scans.csv'

    # grab brain data in prefrontal cortex, amygdala, insula. Shift and scale
    exec_brain_data = (np.array(pd.read_csv(csv_exec)['brain'])-10000)/1000+1
    exec_brain_data = (np.array(pd.read_csv(csv_salience)['brain'])-10000)/1000+1
    exec_brain_data = (np.array(pd.read_csv(csv_interoceptive)['brain'])-10000)/1000+1

    starting_point = np.array([[0.9, 0.15, 0, 0],
                               [0, 0.9, 0.25, 0.25],
                               [-.25, -.04, .9, -.1],
                               [0, .25, .15, .9]])
                                
    weights = np.reshape(starting_point, 1, 16)

    optimized_weights = minimize(weightsearch, weights, method='Powell')
    return optimized_weights

