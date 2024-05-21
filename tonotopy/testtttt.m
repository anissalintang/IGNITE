clc
clear
close all

% Sample data (replace with your own)
frequencies_kHz = [0.250 0.454; 0.454 0.746; 0.746 1.162; 1.162 1.756; 1.756 2.604; 2.604 3.813; 3.813 5.538; 5.538 8.000];
thresholds = [20, 15, 10, 5, 25];

% Calculate center frequencies (geometric mean)
desired_bands_kHz = sqrt(frequencies_kHz(:,1) .* frequencies_kHz(:,2));

% Convert frequencies to ERB
frequencies_erb = arrayfun(@f2nerb, desired_bands_kHz);

% Interpolation
interpolated_thresholds = interp1(frequencies_erb, thresholds, desired_bands_kHz, 'linear');

% Scatter plot
scatter(desired_bands_erb, interpolated_thresholds, 'filled');
xlabel('Frequency (ERB)');
ylabel('Hearing Threshold (dB)');
title('Interpolated Hearing Thresholds across 8 Bands');
grid on;


%%

% Sample data (replace with your own)
frequencies_kHz = [0.5, 1, 2, 4, 8];
thresholds = [20, 15, 10, 5, 25];

% Convert frequencies to ERB
frequencies_erb = arrayfun(@f2nerb, frequencies_kHz);

% Desired bands in kHz (replace with your own)
desired_bands_kHz = [0.6, 1.2, 2.4, 3.8, 5.6, 6.5, 7.3, 8.5];
desired_bands_erb = arrayfun(@f2nerb, desired_bands_kHz);

% Interpolation
interpolated_thresholds = interp1(frequencies_erb, thresholds, desired_bands_erb, 'pchip');

% Scatter plot
scatter(desired_bands_erb, interpolated_thresholds, 'filled');
xlabel('Frequency (ERB)');
ylabel('Hearing Threshold (dB)');
title('Interpolated Hearing Thresholds across 8 Bands');
grid on;


function nerb = f2nerb(f)
    % nerb = integral of 1/erb(f) from 0 to f!
    
    nerb = 1000*log(10)/(24.67*4.37)*log10(4.37*f+1);
end