% snr_estimate.m
% This script estimates the Signal-to-Noise Ratio (SNR) of an audio file
% without having separate clean and noisy references. It divides the audio 
% into short frames and assumes that the lowest 10% energy frames are mostly noise.

% Read the audio file (replace 'audio.wav' with your file)
[inputSignal, fs] = audioread('audio.wav');

% If stereo, convert to mono by averaging the channels
if size(inputSignal,2) > 1
    inputSignal = mean(inputSignal, 2);
end

% Frame parameters
frameDuration = 0.02;        % frame duration in seconds (20 ms)
overlapDuration = 0.01;      % overlap duration in seconds (10 ms)
frameSize = round(frameDuration * fs);
overlapSize = round(overlapDuration * fs);
stepSize = frameSize - overlapSize;

% Buffer the signal into overlapping frames
numFrames = floor((length(inputSignal) - overlapSize) / stepSize);
frameEnergy = zeros(numFrames,1);

for i = 1:numFrames
    idxStart = (i-1)*stepSize + 1;
    idxEnd = idxStart + frameSize - 1;
    if idxEnd > length(inputSignal)
        break;
    end
    frame = inputSignal(idxStart:idxEnd);
    % Calculate frame energy
    frameEnergy(i) = sum(frame.^2) / frameSize;
end

% Remove any zero or unused frames in case the last frame was incomplete
frameEnergy = frameEnergy(frameEnergy > 0);
numValidFrames = length(frameEnergy);

% Estimate noise power as the average energy of the lowest 10% energy frames
percentile = 0.10; % 10% of the frames
numNoiseFrames = max(round(percentile * numValidFrames), 1);
sortedEnergy = sort(frameEnergy);
noisePowerEstimate = mean(sortedEnergy(1:numNoiseFrames));

% Estimate total signal power over the entire audio
signalPower = mean(inputSignal.^2);

% Calculate the estimated SNR in decibels (dB)
estimatedSNR = 10 * log10(signalPower / noisePowerEstimate);

% Display the result
fprintf('Estimated SNR: %.2f dB\n', estimatedSNR);