clc;
clear;
close all;

% Path to the .wav file
pth = '/Volumes/gdrive4tb/IGNITE/code/tonotopy/scannerNoise';
file = dir(fullfile(pth, 'Scanner_noise*.wav'));
fnam = fullfile(pth, file(1).name);

% Load the waveform
[noi, FS] = audioread(fnam);
info = audioinfo(fnam);
noi = noi';

% Calculate the time vector for the entire audio file
t = (0:length(noi)-1)/FS;

% Define the start and end time in seconds
startTime = 10;  % in seconds
endTime = 11;    % in seconds

% Calculate start and end sample indices
startIndex = round(startTime * FS) + 1;
endIndex = round(endTime * FS);

% Create a time vector for the segment to plot
t_segment = (startIndex:endIndex)/FS;

% Select the segment of the audio signal
noi_segment = noi(startIndex:endIndex);

% Plot the segment of the waveform (1 seconds) to see 15 reps
figure;
plot(t_segment, noi_segment);
title(sprintf('Waveform of the Audio Signal (%d to %d seconds)', startTime, endTime));
xlabel('Time (seconds)');
ylabel('Amplitude');

%% Autocorrelation to check for 15 Hz
% 1. Select a clean portion (sample) of the wave  (10 to 20 seconds)
clean_portion = noi(10*FS+1:20*FS);

% 2. Compute the autocorrelation using xcorr
[acf, lags] = xcorr(clean_portion, 'coeff');

% 3. Find peaks in the ACF excluding the zero lag using findpeaks
% assuming a peak cannot occur more than twice a second >>
% Since the sampling rate is the number of samples per second, dividing it by 2 gives the number of samples in half a second
[peaks, peakLags] = findpeaks(acf(lags > 0), 'MinPeakDistance', FS); 
% lags_positive = lags(lags > 0);
% acf_positive = acf(lags >= 0);

 % The first peak lag
firstPeakLag = (peakLags(1));
M = firstPeakLag;

% 4. Calculate the time onset of repetition
firstPeakTime = (firstPeakLag / FS);

% 5. Calculate the repetition frequency
repetitionFrequency = FS/firstPeakLag;

% Display the first peak lag time
disp(['The time of the first repetition is: ' num2str(firstPeakTime) ' sec']);

% Display the repetition frequency (reps per second)
disp(['The repetition frequency of the signal is: ' num2str(repetitionFrequency) ' Hz']);

% Plot the autocorrelation
figure;
plot(lags/FS, acf);
title('Autocorrelation Function');
xlabel('Lag (seconds)');
ylabel('Autocorrelation');
xlim([0 0.5]);

% Add a line at the first peak
hold on; % Retain the plot so that we can add a line
line([firstPeakTime, firstPeakTime], [min(acf), peaks(1)], 'Color', 'red', 'LineWidth', 1.5, 'LineStyle', '--');
text(firstPeakTime, peaks(1), sprintf(' First peak\n (%.3f s)', firstPeakTime), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'BackgroundColor', 'white');

% Release the plot hold
hold off;
%%
% Duration of the entire audio file in seconds
totalDuration = info.Duration;

% Estimated total number of repetitions in the audio file
totalRepetitions = floor(repetitionFrequency * totalDuration);

% Display the estimated total number of repetitions
disp(['Estimated total number of repetitions in the audio file: ' num2str(totalRepetitions)]);

%% Do FFT from 100 reps from the sample
% Calculate the length of 100 repetitions >> 100/15 = 6.67 seconds
numRepetitions = 100;
repetitionLength = round(FS * firstPeakTime);
segmentLength = round(FS * firstPeakTime * numRepetitions); % Number of samples for 100 repetitions

% Compute the frequency resolution
frequency_resolution = FS / M

% Select the segment for FFT analysis
fft_segment_start = startIndex; % same start index as before (10 sec)
fft_segment_end = fft_segment_start + segmentLength - 1; % End index for the segment

fft_segment = noi(fft_segment_start:fft_segment_end);

%% Plot the segment used for FFT out of the whole signal
figure;
plot(t, noi); % Plot the whole signal in blue
hold on;

% Calculate the start index for the clean portion (10 seconds into the file)
clean_portion_start = round(10 * FS) + 1;
clean_portion_end = round(20 * FS); % End index for the clean portion (20 seconds into the file)

% Plot the clean portion in green
plot(t(clean_portion_start:clean_portion_end), noi(clean_portion_start:clean_portion_end), 'g'); 

% Plot the fft segment with red color and 70% opacity
plot(t(fft_segment_start:fft_segment_end), fft_segment, 'r', 'Color', [1, 0, 0, 0.3]);

title('Segment used for analysis');
xlabel('Time (seconds)');
ylabel('Amplitude');
legend('Full Signal', 'Segment for autocorrelation', 'Segment for FFT');

% Release the plot hold
hold off;


%% Plot the repetition used for FFT out of 10 reps
% Select the segment for the first 10 FFT repetitions
numLinesToPlot = 10; % Only plot 10 repetitions
fft_segment_start_for_plot = fft_segment_start; % Start index for plotting
fft_segment_end_for_plot = fft_segment_start_for_plot + numLinesToPlot * M; % End index for plotting the first 10 repetitions

% Adjust the fft_segment and time vector for plotting
fft_segment_to_plot = noi(fft_segment_start_for_plot:fft_segment_end_for_plot);
t_to_plot = t(fft_segment_start_for_plot:fft_segment_end_for_plot);

% Plot the segment of the waveform used for FFT
figure;
plot(t_to_plot, fft_segment_to_plot);
hold on; % Keep the plot for further plotting

% Plot vertical lines to show segments over which FFTs are calculated
for i = 0:numLinesToPlot-1
    segmentStartIndex = i * M + 1; % Index for vertical line
    xline(t_to_plot(segmentStartIndex), '--r'); % Plot vertical line at segment start
end

title(sprintf('First 10 Repetitions of the Audio Signal Used for FFT'));
xlabel('Time (seconds)');
ylabel('Amplitude');
hold off; % Release the plot hold

%% Plot the FFT magnitude (in dB)
N2 = 2^nextpow2(M);
fft_accum = zeros(1, N2);

% Compute the FFT for each repetition and accumulate the results
for i = 0:numRepetitions-1
    segmentStart = fft_segment_start + i * M;
    segmentEnd = segmentStart + M - 1;
    
    % Ensure the segment does not exceed the length of noi
    if segmentEnd > length(noi)
        break;
    end
    
    % Select the segment and remove the mean
    current_segment = noi(segmentStart:segmentEnd) - mean(noi(segmentStart:segmentEnd));
    
    % Compute the FFT and update the accumulator
    current_fft = fft(current_segment, N2); % repetitionLength change to radix-2 number
    fft_accum = fft_accum + abs(current_fft);
end

% Average the accumulated FFT results
avg_fft = fft_accum / numRepetitions;
Psqr = avg_fft .^2; % Two-sided spectrum; power (squared magnitude)
P2 = avg_fft / sqrt(N2); % Two-sided spectrum;
P1 = Psqr(1:N2/2+1); % Single-sided spectrum;
f = FS*(0:(N2/2))/N2; % Frequency axis

f_kHz = f/1000;

% Smooth the spectrum and convert to dB
P1_smooth = smoothdata(P1, 'movmean', 100);

% Normalize by dividing by the maximum magnitude in linear units
P1_normalized = P1_smooth / max(P1_smooth);

P1_dB = 20*log10(P1_normalized);

% Plot figure;
figure;
plot(f_kHz, P1_normalized);
title('Magnitude of FFT of the Segment');
xlabel('Frequency (kHz)');
ylabel('Magnitude  (dB)'); %the magnitude of the FFT result
xlim([0 20]);

%% plot the FFT magnitude as a function of NERB frequency
% Frequency vector starting from 5 Hz
f = FS * (0:(N2/2)) / N2;
f(1) = 5;  % Set the first element to 5 Hz to avoid log of 0

% Convert to NERB scale
nerb = f2nerb(f);

% Plot the normalized magnitude spectrum in dB against NERB
figure;
plot(nerb, P1_dB);
title('Magnitude Spectrum');
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');

% Set the x-axis ticks at octave-spaced frequencies
octave_freqs = [500, 1e3, 2e3, 4e3, 8e3, 16e3];  % Octave-spaced frequencies in Hz
octave_nerbs = f2nerb(octave_freqs);  % Convert to NERB scale

% Set the x-ticks and x-tick labels
set(gca, 'XTick', octave_nerbs, 'XTickLabel', arrayfun(@(f) sprintf('%.1f', f/1000), octave_freqs, 'UniformOutput', false));


%%
global_thirdOct = readtable('/Volumes/gdrive4tb/IGNITE/code/tonotopy/scannerNoise/Scanner_noise16-30-18_Globals_1_3 Octave CH1.csv');

% Find the row index where 'Channel1' has the value 'Spectrum', 'Leq', and
% 'SEL'
spectrumRowIndex = find(strcmp(global_thirdOct.Channel1, 'Spectrum'));
LeqRowIndex = find(strcmp(global_thirdOct.Channel1, 'Leq'));
SELRowIndex = find(strcmp(global_thirdOct.Channel1, 'SEL'));

% Extract the 'Spectrum', 'Leq, 'and 'SEL' row for columns 2 to 33
xx = global_thirdOct{spectrumRowIndex, 2:33};
leq = global_thirdOct{LeqRowIndex, 2:33};
sel = global_thirdOct{SELRowIndex, 2:33};

figure;
plot(xx,leq,'r');
hold on;
plot(xx,sel, 'b');
plot(f, P1_dB+100,'g');
set(gca,'Xscale','log')
hold off;

xlabel('Frequency (in log)');
ylabel('Magnitude (dB)');

legend('LEQ','SEL','FFT', 'Location', 'northeastoutside');

%%
thirdOct = readtable('/Volumes/gdrive4tb/IGNITE/code/tonotopy/scannerNoise/Scanner_noise16-30-181_3 Octave CH1.csv');

% Load the dB on the relevant time point used in the FFT (10s to 16.67s)
% from all frequencies (columns)
leq_seg = thirdOct{82:135, 5:36};

% average dB across time points
leq_seg_ave = mean(coba,1);

figure;
plot(xx,leq,'r');
hold on;
plot(xx,sel, 'b');
plot(f, P1_dB+100,'g');
plot(xx, leq_seg_ave, 'c')
set(gca,'Xscale','log')
hold off;

xlabel('Frequency (in log)');
ylabel('Magnitude (dB)');

legend('LEQ','SEL','FFT', 'Matched time points', 'Location', 'northeastoutside');
%%
function nerb = f2nerb(f)
    % Convert frequency to NERB using the Glasberg and Moore formula
    nerb = 21.4 * log10(4.37 * f/1000 + 1);
end

