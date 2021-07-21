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

%curr_ind is individual curr_state is neutral/criticis 
% WINDOWS
% opts = detectImportOptions('C:\Users\chris\Documents\interoception-modeling\data\executive.dandrois','FileType','text');
% A = readmatrix('C:\Users\chris\Documents\interoception-modeling\data\executive.dandrois',opts);

%UNIX
opts = detectImportOptions('/data/executive.dandrois','FileType','text');
A = readmatrix('/data/executive.dandrois',opts);


% patient ID's stored in the first column, get all unique values
individuals = unique(A(:,1));

% remove 1500 person which is first item
individuals = individuals(2:length(individuals),:);

for person=1:length(individuals)
    % first get the current indivual
    ind = individuals(person);
    disp(ind);
    
    % first gather neutral matrix data for current individual
    individual_weight_matrix = find_model_parameters(ind, 'neutral');
    struct_data.neutral.(sprintf("individual_%s",string(ind))) = reshape(individual_weight_matrix, 4 ,4);
    
    
    % next gather criticism matrix data for current individual
    individual_weight_matrix = find_model_parameters(ind, 'criticism');
    struct_data.criticism.(sprintf("individual_%s",string(ind))) = reshape(individual_weight_matrix, 4, 4);
end

struct_data.neutral = neutral;
struct_data.criticism = criticism;
% individual 


save individual_weight_matrix.mat struct_data
end