import numpy as np
import matplotlib.pyplot as plt
import matplotlib

# Python implementation of dynamic causal model + interoceptive active inference model


# this function gets the current most likely value based on input signal interoception ,
# EDIT: Make this function return only one vector, updates next timestep in matrix where it is called
def interoceptive_update(time_data, t, dt, u):
    
    def g(phi):
        return phi**2

    def epsilon_p_dot(phi, v_p, sigma, epsilon_p):
        return phi - v_p - (sigma * epsilon_p)

    def epsilon_u_dot(u, phi, sigma, epsilon_u):
        return u - g(phi) - (sigma * epsilon_u)

    def v_p_dot(epsilon_p):
        return epsilon_p

    def sigma_p_dot(epsilon_p, sigma_p):
        return (1.0/2.0) * (epsilon_p**2 - (1/sigma_p))

    def sigma_u_dot(epsilon_u, sigma_u):
        return (1.0/2.0) * (epsilon_u**2 - (1/sigma_u))
    
    # First calc phi next timestep
    phi = time_data[0,t]
    epsilon_p = time_data[1,t]
    epsilon_u = time_data[2,t]
    sigma_p = time_data[3,t]
    sigma_u = time_data[4,t]
    v_p = time_data[5,t]
    
    # Here we run a mini simulation that allows the insula to converge on the most likely
     # value for the incoming data. 
     # Then, we update the time_data matrix at the next timestep 
     # with all the values that were converged to at the end of the mini sim
    
    num_steps = 75
    converge_data  = np.zeros((6,num_steps))
    
    for time in range(num_steps-1):
    
        phi += dt * (epsilon_u * 2*phi - epsilon_p)
        converge_data[0,time+1] = phi
    
        epsilon_p += dt * epsilon_p_dot(phi, v_p, sigma_p, epsilon_p)
        converge_data[1,time+1] = epsilon_p
        
        epsilon_u += dt * epsilon_u_dot(u, phi, sigma_u, epsilon_u)
        converge_data[2,time+1] = epsilon_u
        
        sigma_p += dt * sigma_p_dot(epsilon_p, sigma_p)
        converge_data[3,time+1] = sigma_p
    
        sigma_u += dt * sigma_u_dot(epsilon_u, sigma_u)
        converge_data[4,time+1] = sigma_u
    
        v_p += dt * v_p_dot(epsilon_p)
        converge_data[5,time+1] = v_p
    
    # Finally, update the next timestep in time_data with the most recent values from converge_data
    time_data[0,t+1] = converge_data[0,num_steps-1]
    time_data[1,t+1] = converge_data[1,num_steps-1]
    time_data[2,t+1] = converge_data[2,num_steps-1]
    time_data[3,t+1] = converge_data[3,num_steps-1]
    time_data[4,t+1] = converge_data[4,num_steps-1]
    time_data[5,t+1] = converge_data[5,num_steps-1]
    
    return time_data

def slimit(vector, thresh=2, negthresh=0):
    logval = np.clip(vector, negthresh,thresh)
    return logval

def external_percept_simulation(typerun='standard'):
    
    #initial values for interoceptive active inference
    u       = 0.7
    sigma_u = 0.1
    v_p     = 0.0001 #can't be zero - dF/dphi vanishes always if phi is zero
    sigma_p = 1
    phi     = v_p
    dt      = 0.01
    dur     = 6
    steps   = int(dur/dt)
    epsilon_p = 0
    epsilon_u = 0

    # Timestep array, holds most likely val, PEs, and parameters
    # row 0: phi
    # row 1: epsilon_p
    # row 2: epsilon_u
    # row 3: sigma_p
    # row 4: sigma_u
    # row 5: v_p
    time_data = np.zeros((6, steps))
    
    # initialize first values in interoceptive matrix
    time_data[0,0] = phi
    time_data[1,0] = epsilon_p
    time_data[2,0] = epsilon_u
    time_data[3,0] = sigma_p
    time_data[4,0] = sigma_u
    time_data[5,0] = v_p
    
    # Constant values for indexing into weights array
    BODY = 0
    PREFRONTAL_CORTEX = 1
    AMYGDALA = 2
    INSULA = 3
    
    # we need to introduce external percepts here - threat will excite amygdala
    percept = np.array([0, 0, 0.3, 0])
    
    # six combinations of possibilities
    #     1) threat absent vigilant interoceptive
    #     2) threat present vigilant interoceptive
    #     3) threat absent not vigilant interoceptive
    #     4) threat present not vigilant not interoceptive
    #     5) threat absent vigilant not interoceptive
    #     6) threat present not vigilant not interoceptive
    
    startstates = np.array([[0, 0.5, .5, 0.5], # 1) threat present vigilant int
                           [0, 0.5, .5, 0],    # 2) threat present vigilant not int
                           [0, 0.5, 0, 0.5],  # 3) threat present not vigilant int
                           [0, 0.5, 0, 0],    # 4) threat present not vigilant not int
                           [0, 0.5, .5, 0.5],  # 5) threat absent vigilant int
                           [0, 0.5, .5, 0],    # 6) threat absent vigilant not int
                           [0, 0.5, 0, 0.5],  # 7) threat absent not vigilant int
                           [0, 0.5, 0, 0]])   # 8) threat present vigilant not interoceptive
    
    # threat affects the amygdala -> excites the amygdala
    instates= np.array([[0.1, 0, 0, 0],
                       [0.1, 0, 0, 0], 
                       [0.1, 0, 0, 0],  
                       [0.1, 0, 0, 0], 
                       [0, 0, 0, 0],
                       [0, 0, 0, 0],
                       [0, 0, 0, 0],
                       [0, 0, 0, 0]]) 

    # array of the above six states
    instatenames=np.array(['threat present vigilant interoceptive',
                           'threat present vigilant not interoceptive',
                           'threat present not vigilant interoceptive',
                           'threat present not vigilant not interoceptive',
                           'threat absent vigilant interoceptive', 
                           'threat absent vigilant not interoceptive',
                           'threat absent not vigilant interoceptive',
                           'threat absent not vigilant not interoceptive'])
    
    # weight matrix of connections between networks
    #                            FROM ?
    weights = np.array([[0.5, -0.2,   0.3, 0.1],    # body
                        [0,    0.5,  -0.1,-0.2],    # prefrontal cortex     TO ?
                        [0,   -0.4,   0.5, 0.1],    # amygdala
                        [u,      0,     0, 0.5]])   # insula
    
    if typerun=='useglobals':
        startstates = globalstartstates
        instates= globalinstates
        weights = globalweights

    random_weights = np.random.rand(4,4)
    
    # Second timestep array, holds body/control/salience/interoception values
    # row 0: body
    # row 1: prefrontal cortex
    # row 2: amygdala
    # row 3: insula
    
    networks_time_data = np.zeros((4, steps))
    networks_time_data[0,0] = np.random.rand()-0.5
    networks_time_data[1,0] = np.random.rand()-0.5
    networks_time_data[2,0] = 0
    networks_time_data[3,0] = phi
    
    print('body initial state: ' + str(networks_time_data[0,0]))
    print('prefrontal cortex initial state: ' + str(networks_time_data[1,0]))
    
    #possible interesting values...
    # body initial: -0.25102011563253956
    # PFC initial: -0.05979777132863817
    
    # make 3-D matrix for storing all the data.
    # there will be six layers of (4 x steps) matrices. 
    # each layer will hold some combination (ie 'threat absent not vigilant interoceptive')
    # the 4 x steps will be the time data for each of the 4 networks (amygdala, insula, PFC, body)
    circuit_situational_data = np.zeros((8,4,steps))
    
    # ---------------- SIMULATION ------------------- 
    
    for curr_state in range(len(instates)):
        
        perception = 3 * dt * instates[curr_state,:]
        circuit_situational_data[curr_state,:,0] = startstates[curr_state,:]
        
        # print the starting states
        print(startstates[curr_state,:])

        for t in range(steps-1):
            
            # first, get the current value of u
            u = circuit_situational_data[curr_state, BODY,t]         
        
            # simulate interoceptive prediction (give it time to converge to some value)
            time_data = interoceptive_update(time_data, t, dt, u)
        
            # get the current phi prediction generated from interoceptive_update
            phi = time_data[0,t+1]
        
            # update body signal value in the weight matrix
            weights[BODY,INSULA] = u
            
            # update phi value in the weight matrix
            weights[INSULA, BODY] = phi
            
            circuit_situational_data[curr_state, :, t+1] = slimit(perception + \
                                                        circuit_situational_data[curr_state,:,t] + \
                                    dt * np.matmul(circuit_situational_data[curr_state,:,t], weights.T).T,3,-1)
        
    
    # ------------- END OF SIMULATION ---------------    
    
    #plot all network data
    fig, axs = plt.subplots(2,4,figsize=(18,15))
    
    for brain_network in range(4):
        axs[0, 0].plot(np.arange(steps) * dt, circuit_situational_data[0,brain_network,:])
    axs[0,0].set_title(instatenames[0])
    
    for brain_network in range(4):
        axs[0, 1].plot(np.arange(steps) * dt, circuit_situational_data[1,brain_network,:])
    axs[0,1].set_title(instatenames[1])
    
    for brain_network in range(4):
        axs[0, 2].plot(np.arange(steps) * dt, circuit_situational_data[2,brain_network,:])
    axs[0,2].set_title(instatenames[2])
    
    for brain_network in range(4):
        axs[0, 3].plot(np.arange(steps) * dt, circuit_situational_data[3,brain_network,:])
    axs[0,3].set_title(instatenames[2])
    
    for brain_network in range(4):
        axs[1, 0].plot(np.arange(steps) * dt, circuit_situational_data[4,brain_network,:])
    axs[1,0].set_title(instatenames[3])
    
    for brain_network in range(4):
        axs[1, 1].plot(np.arange(steps) * dt, circuit_situational_data[5,brain_network,:])
    axs[1,1].set_title(instatenames[4])
    
    for brain_network in range(4):
        axs[1, 2].plot(np.arange(steps) * dt, circuit_situational_data[6,brain_network,:])
    axs[1,2].set_title(instatenames[5])
    
    for brain_network in range(4):
        axs[1, 3].plot(np.arange(steps) * dt, circuit_situational_data[7,brain_network,:])
    axs[1,3].set_title(instatenames[5])
    
    plt.legend(['body', 'prefrontal cortex', 'amygdala', 'insula'])
    
    
    fig = plt.figure(figsize=(8,8), num='Fig a')
    ax  = fig.add_subplot(1, 1, 1)

    # plot interceptive predictions
    for j in range(3):
        ax.plot(np.arange(steps) * dt, time_data[j,:])
    
    plt.xlabel('time')
    plt.ylabel('Activity')
    plt.legend([r'$\phi$', r'$\epsilon_p$',r'$\epsilon_u$',r'$\Sigma_p$', r'$\Sigma_u$', r'$v_p$'])
    plt.axis([0, dur, -2, 3])
    plt.title('Interoceptive Approximation and Prediction Errors')

    return circuit_situational_data
    plt.show()
    
external_percept_simulation()