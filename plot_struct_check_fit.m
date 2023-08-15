% this is purely for testing purposes
% load in the data for example three individuals and plot to view how good
% the fits are
%% load the data prepare to plot

load('weight_matrix_fit_to_data.mat')
xaxis=1:60000;
xaxis=xaxis';

%% plot the neutral condition data
hold on;

plot(xaxis, [ans.neutral.individual_2309.timeseries.fMRI(:,1), ans.neutral.individual_2309.timeseries.fMRI(:,2), ans.neutral.individual_2309.timeseries.fMRI(:,3), ans.neutral.individual_2309.timeseries.simulation(:,1), ans.neutral.individual_2309.timeseries.simulation(:,2), ans.neutral.individual_2309.timeseries.simulation(:,3)])

plot(xaxis, [ans.neutral.individual_3548.timeseries.fMRI(:,1), ans.neutral.individual_3548.timeseries.fMRI(:,2), ans.neutral.individual_3548.timeseries.fMRI(:,3), ans.neutral.individual_3548.timeseries.simulation(:,1), ans.neutral.individual_3548.timeseries.simulation(:,2), ans.neutral.individual_3548.timeseries.simulation(:,3)])


plot(xaxis, [ans.neutral.individual_3570.timeseries.fMRI(:,1), ans.neutral.individual_3570.timeseries.fMRI(:,2), ans.neutral.individual_3570.timeseries.fMRI(:,3), ans.neutral.individual_3570.timeseries.simulation(:,1), ans.neutral.individual_3570.timeseries.simulation(:,2), ans.neutral.individual_3570.timeseries.simulation(:,3)])