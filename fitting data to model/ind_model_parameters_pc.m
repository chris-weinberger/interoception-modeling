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

function struct_data=ind_model_parameters_pc
%curr_ind is individual curr_state is neutral/criticis 
% WINDOWS
opts = detectImportOptions('C:\Users\chris\Documents\interoception-modeling\data\executive.dandrois','FileType','text');
A = readmatrix('C:\Users\chris\Documents\interoception-modeling\data\executive.dandrois',opts);

%UNIX
% opts = detectImportOptions('/data/executive.dandrois','FileType','text');
% A = readmatrix('/data/executive.dandrois',opts);

% patient ID's stored in the first column, get all unique values
individuals = unique(A(:,1));

% remove 1500 person which is first item
individuals = individuals(2:length(individuals),:);

% individuals = [2309 3548 3570]; % choosing three profiles do to for testing

idx=find(individuals > 3000);
patients = individuals(idx(1):idx(10));
controls = individuals(1:10);

patients(6) = 3327;
controls(1) = 2317;

test_subjects = cat(1,patients,controls);

struct_data = struct;

parfor person=1:length(test_subjects)
    % first get the current indivual
    ind = test_subjects(person);
    disp(ind);
    struct_data(person).neutral.(sprintf("individual_%s",string(ind))) = find_model_parameters_pc(ind, 'neutral');
    
    % first gather neutral matrix data for current individual
%     struct_data.neutral.(sprintf("individual_%s",string(ind))) = find_model_parameters_pc(ind, 'neutral');
    
    if ind ~= 2301 % person 2301 doesn't have criticism data
        % next gather criticism matrix data for current individual
          struct_data(person).criticism.(sprintf("individual_%s",string(ind))) = find_model_parameters_pc(ind, 'criticism');
    end
end

save individual_data_criticism.mat struct_data
end
