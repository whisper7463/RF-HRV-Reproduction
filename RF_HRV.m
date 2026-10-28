%% Title: Monitoring Long-term Cardiac Activity with Contactless Radio Frequency Signals
% By @Bin-Bin Zhang
% 2024.2.21
% For demo, the Minimum dataset contains the preprocessed radar and ground truth IBI of 20 patients
% Considering patient privacy, the radar data and the ground truth have both been preprocessed.

% Reference:
%---------------
%       B. Zhang, D. Zhang, Y. Li, Z. Lu, J. Chen, H. Wang, F. Zhou, Y. Pu,
%       Y. Hu, L. Ma, Q. Sun, Y. Chen
%       "Monitoring Long-term Cardiac Activity with Contactless
%       Radio Frequency Signals"
%       Nature Communications.2024      
% ----------------------------------------------------------------------------------------------------

clc;
clear all;

% Initialization
namelist = dir('Minimum_dataset/*.mat');
RT_IBI_error_all = []; 
RMSSD_error_all = [];
SDRR_error_all = [];
pNN50_error_all = [];

disp("===============Program Starts==============")

for i = 1: length(namelist)
    
    %% Read radar and groundtruth data
    i
    data_path = [namelist(i).folder, '/', namelist(i).name];       
    data = load(data_path);                              % Load preprocessed radar and ground truth IBI of Minimum dataset (20 patients)              
    data_all = data.data_all; 
    radardata = cell2mat(data_all(1));                   % The preprocessed radar data consists of time series of distance and angle
    groundtruth = cell2mat(data_all(2));                 % The ground truth of IBI

   %% Step 1: Signal Selection
    range_start = 6;
    range_end = 9;
    azimuth_start = 4;
    azimuth_end = 5;
    V_min = 10000;
    
    for k = range_start : range_end
    
        for jj = azimuth_start: azimuth_end
            
            data_angle = unwrap(angle(squeeze(radardata(:, k, 2, jj))));
            data_angle = gather(data_angle);

           %% Step 2: Beat Frequency Pattern Extraction  
            % Signal decomposition
            imf = vmd(data_angle);            
            imf = normalize(imf);    

            % Selecting high freuqency component to obtain the beat frequency pattern
            High_frequency_component = imf(:,1);                  

            % Calculate the variance of IBI 
            [pks,loc] = findpeaks(High_frequency_component,'Minpeakdistance',50,'MinPeakHeight',0.9);
            IBI_estimation = loc(2:end) - loc(1:end-1);
            V = var(IBI_estimation);

            % Select the signal with the smallest variance of IBI
            if V < V_min && length(IBI_estimation) > 20
                V_min = V;
                Heart_component = High_frequency_component;
            end       
            
        end   
    end

    %% Step 3: HRV estimation
    [pks, loc] = findpeaks(Heart_component,'Minpeakdistance',50,'MinPeakHeight',0.9);
    [RT_IBI_error,RMSSD_err, SDRR_err, pNN50_err] = Beat_Frequency_Pattern_Detection(loc, groundtruth, Heart_component) 

    RT_IBI_error_all = [RT_IBI_error_all, RT_IBI_error];
    RMSSD_error_all = [RMSSD_error_all, RMSSD_err];
    SDRR_error_all = [SDRR_error_all, SDRR_err];
    pNN50_error_all = [pNN50_error_all, pNN50_err];

end

RT_IBI_error_average = mean(RT_IBI_error_all)
save('results\IBIs.mat', 'RT_IBI_error_all');

% Box plot of RT-IBI error
figure;
boxplot(RT_IBI_error_all);
ylabel('RT-IBI error (ms)')
title('Box plot of RT-IBI error');

saveas(gcf,'results\RT_IBI_error_all.png')

disp("=============Program Ends=============")


% Beat frequency pattern extraction and HRV compuation
function [IBI_err, RMSSD_err, SDRR_err, pNN50_err] = Beat_Frequency_Pattern_Detection(loc_estimation, loc_groundtruth, high_component)

    % Input:
    %---------------
    %   loc_estimation  :       The estimated moments when heartbeats occur.
    %   loc_groundtruth :       The groundtruth of IBI
    %   high_component  :       high frequency component
    %---------------
    % Output:
    %---------------
    %
    %   IBI_err      :       IBI error
    %   RMSSD_err    :       RMSSD error
    %   SDRR_err     :       SDRR error
    %   pNN50_err    :       pNN50 error
    %-----------------------------------------------------------------------

IBI_estimation = loc_estimation(2:end) - loc_estimation(1:end-1);
IBI_groundtruth = loc_groundtruth(2:end) - loc_groundtruth(1:end-1);
IBI_mean = mean(IBI_estimation);
IBI_mean_gdt = mean(IBI_groundtruth);

% Dynamic findpeak algorithm to address the issue of signal energy instability caused by interference.
index_abnormal = find(IBI_estimation > 140);
IBI_abnormal_sum = sum(IBI_estimation(index_abnormal));
counter = 0;
while (IBI_abnormal_sum > 560)
   high_component = high_component * 1.5;
   [pks_estimation,loc_estimation] = findpeaks(high_component,'Minpeakdistance',50,'MinPeakHeight',0.9);
   IBI_estimation = loc_estimation(2:end) - loc_estimation(1:end-1);
   IBI_mean = mean(IBI_estimation);
   index_abnormal = find(IBI_estimation > 140);
   IBI_abnormal_sum = sum(IBI_estimation(index_abnormal));
   counter = counter + 1;
end

% Computing Real-Time IBI 
estimation_matrix = [];
groundtruth_matrix = [];
for i = 1 : length(IBI_estimation)
    a = IBI_estimation(i);
    est_matrix_one = 0.*rand(IBI_estimation(i),1) + a;
    estimation_matrix = [estimation_matrix, est_matrix_one.'];
end
for i = 1 : length(IBI_groundtruth)
    a = IBI_groundtruth(i);
    gdt_matrix_one = 0.*rand(IBI_groundtruth(i),1) + a;
    groundtruth_matrix = [groundtruth_matrix, gdt_matrix_one.'];
end
start_index = max(loc_estimation(1), loc_groundtruth(1));
if start_index == loc_estimation(1)
    groundtruth_matrix = groundtruth_matrix(loc_estimation(1)-loc_groundtruth(1)+1: end);
else
    estimation_matrix = estimation_matrix(loc_groundtruth(1)-loc_estimation(1)+1: end);
end
if length(groundtruth_matrix) >= length(estimation_matrix)                
    groundtruth_matrix = groundtruth_matrix(1: length(estimation_matrix));
else
    estimation_matrix = estimation_matrix(1: length(groundtruth_matrix));
end

% Outlier detection
% Detecting outliers caused by motion artifacts and noise.
estimation_matrix_new = [];
groundtruth_matrix_new = [];
win_size = 400;
for i = 1: fix(length(estimation_matrix) / win_size)
    estimation_matrix_win = estimation_matrix((i-1)*win_size + 1: i * win_size);
    groundtruth_matrix_win = groundtruth_matrix((i-1)*win_size + 1: i * win_size);
    if mean(estimation_matrix_win) - IBI_mean < 15                                  
        estimation_matrix_new = [estimation_matrix_new, estimation_matrix_win];
        groundtruth_matrix_new = [groundtruth_matrix_new, groundtruth_matrix_win];
    end
end
for j = 3: length(estimation_matrix_new) - 3
    if estimation_matrix_new(j) < 50 
        estimation_matrix_new(j) =  mean(estimation_matrix_new(j-2:j+2));
    elseif estimation_matrix_new(j) > 130
        estimation_matrix_new(j) =  mean(estimation_matrix_new(j-2:j+2));
    end
end
IBI_mean = mean(estimation_matrix_new);
bad_index = find(abs(estimation_matrix_new - IBI_mean) > 15);
if  length(bad_index) > 0
    estimation_matrix_new(bad_index) = IBI_mean;
end
IBI_sequence = IBI_estimation;
successive_diff = IBI_estimation(2:end) - IBI_estimation(1:end-1);
index_sd = find(successive_diff > 10);
index_d = find(abs(IBI_estimation - mean(IBI_estimation)) > 15); 
if length(index_sd) ~= 0
   successive_diff(index_sd) = mean(successive_diff); 
end
if length(index_d) ~= 0 
    IBI_sequence(index_d) = mean(IBI_estimation);
end 

% Computing RT-IBI error
IBI_err = mean(abs(groundtruth_matrix_new - estimation_matrix_new)) * 10;

% Computing RMSSD SDRR pNN50 error
RMSSD = sqrt(mean(successive_diff .* successive_diff));
SDRR = sqrt(mean((IBI_sequence - mean(IBI_estimation)) .* (IBI_sequence - mean(IBI_estimation))));
pNN50 = length(find(abs(successive_diff) > 5)) / length(successive_diff);
RMSSD_gdt = sqrt(mean((IBI_groundtruth(2:end) - IBI_groundtruth(1:end-1)) .* (IBI_groundtruth(2:end) - IBI_groundtruth(1:end-1))));
SDRR_gdt = sqrt(mean((IBI_groundtruth - IBI_mean_gdt) .* (IBI_groundtruth - IBI_mean_gdt)));
pNN50_gdt = length(find(abs((IBI_groundtruth(2:end) - IBI_groundtruth(1:end-1))) > 5)) / (length(IBI_groundtruth)-1);
RMSSD_err = abs(RMSSD - RMSSD_gdt) * 10;
SDRR_err = abs(SDRR - SDRR_gdt) * 10;
pNN50_err = abs(pNN50 - pNN50_gdt) * 100;

end
