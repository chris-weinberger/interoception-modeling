% This function will loop through all patient data in the /data directory
% and save weight matrices for each of their profiles (criticism-rest and neutral-rest). 
% For example, patient 2303 will have two associated weight matrices:
% One for criticism-rest, and one for neutral-rest.
%
% All of these weight matrices for patients will be stored in a .mat file
% which contains a single struct with the following layout:
% PatientData
% - Interoceptive
% -- [all patient data for interoceptive]
% - Salience
% -- [all patient data for salience]
% - Executive
% -- [all patient data for executive]

function struct_data=indmodelparameters

%curr_ind is individual curr_state is neutral/criticism
global curr_ind curr_state; 

opts = detectImportOptions('C:\Users\chris\Documents\interoception-modeling\data\executive.dandrois','FileType','text');
A = readmatrix('C:\Users\chris\Documents\interoception-modeling\data\executive.dandrois',opts);

% patient ID's stored in the first column, get all unique values
individuals = unique(A(:,1));

% remove 1500 person which is first item
individuals = individuals(2:length(individuals),:);

for person=1:length(individuals)
    % first get the current indivual
    ind = individuals(person);
    
    % first gather neutral matrix data for current individual
    individual_weight_matrix = find_model_parameters(ind, 'neutral');
    neutral.ind = reshape(individual_weight_matrix, 4 ,4);
    
    % next gather criticism matrix data for current individual
    individual_weight_matrix = find_model_parameters(ind, 'criticism');
    criticism.ind = reshape(individual_weight_matrix, 4, 4);
end

struct_data.neutral = neutral;
struct_data.criticism = criticism;
% individual 
end