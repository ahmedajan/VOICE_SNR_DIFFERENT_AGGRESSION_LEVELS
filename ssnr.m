% ssnr_calc.m
% This script estimates the Segmental Signal-to-Noise Ratio (SSNR) of an audio file.
% The audio is divided into overlapping frames. For each frame, the energy is computed,
% and the noise power is estimated from the lowest 10% energy frames.
% The per-frame SNR values (in dB) are then clipped to a specified range and averaged.

% Read the audio file (replace 'audio.wav' with your file)
[inputSignal, fs] = audioread('audio.wav');

% If stereo, convert to mono by averaging the channels
if size(inputSignal, 2) > 1
    inputSignal = mean(inputSignal, 2);
end

% Frame parameters
frameDuration = 0.02;       % 20 ms frames
overlapDuration = 0.01;     % 10 ms overlap
frameSize = round(frameDuration * fs);
overlapSize = round(overlapDuration * fs);
stepSize = frameSize - overlapSize;

% Determine the number of frames
numFrames = floor((length(inputSignal) - overlapSize) / stepSize);
frameEnergy = zeros(numFrames, 1);

% Divide the signal into frames and compute energy for each frame
for i = 1:numFrames
    idxStart = (i - 1) * stepSize + 1;
    idxEnd = idxStart + frameSize - 1;
    frame = inputSignal(idxStart:idxEnd);
    frameEnergy(i) = sum(frame .^ 2) / frameSize;
end

% Estimate noise power as the average energy of the lowest 10% energy frames
percentile = 0.10; 
numNoiseFrames = max(round(percentile * numFrames), 1);
sortedEnergy = sort(frameEnergy);
noisePowerEstimate = mean(sortedEnergy(1:numNoiseFrames));

% Compute per-frame SNR in decibels
frameSNR = 10 * log10(frameEnergy / noisePowerEstimate);

% Clip the SNR values to a common range (e.g., [-10 dB, 35 dB])
SNR_min = -10; % Minimum SNR in dB
SNR_max = 35;  % Maximum SNR in dB
frameSNR_clipped = min(max(frameSNR, SNR_min), SNR_max);

% Calculate the segmental SNR as the average of the clipped SNR values
segmentedSNR = mean(frameSNR_clipped);

% Display the result
fprintf('Segmental SNR (SSNR): %.2f dB\n', segmentedSNR);
